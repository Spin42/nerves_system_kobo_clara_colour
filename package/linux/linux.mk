# Buildroot external extension: support split kernel tarballs
#
# Kobo publishes the kernel sources for the Clara Colour as split files, e.g.:
#   kernel.tar.zst.part-aa + kernel.tar.zst.part-ab
#
# The linux package can download extra files via LINUX_EXTRA_DOWNLOADS,
# but extraction expects a single archive. When the selected custom
# tarball ends with ".part-aa", also download ".part-ab", concatenate
# them to rebuild the original archive, and extract it.

# Linux 4.9 predates the LICENSES/ directory layout (added in 4.14);
# only COPYING exists for legal-info collection.
LINUX_LICENSE_FILES = COPYING

# Linux 4.9 predates GCC 10/11; newer compilers promote a handful of
# warnings that old kernel code trips over (and some vendor Makefiles
# add -Werror). Silence the known-noisy ones — these are all warnings
# that upstream stable kernels also suppressed when adding modern GCC
# support.
LINUX_CFLAGS += \
	-Wno-array-bounds \
	-Wno-zero-length-bounds \
	-Wno-stringop-overread \
	-Wno-stringop-overflow \
	-Wno-maybe-uninitialized \
	-Wno-address-of-packed-member \
	-Wno-misleading-indentation \
	-Wno-format-truncation \
	-Wno-stringop-truncation \
	-Wno-restrict \
	-Wno-packed-not-aligned \
	-Wno-format-overflow \
	-Wno-missing-attributes

LINUX_KOBO_SPLIT_TARBALL_AA := $(filter %.part-aa,$(LINUX_SOURCE))

ifneq ($(LINUX_KOBO_SPLIT_TARBALL_AA),)
LINUX_KOBO_SPLIT_TARBALL_AB := $(patsubst %.part-aa,%.part-ab,$(LINUX_KOBO_SPLIT_TARBALL_AA))
LINUX_KOBO_SPLIT_TARBALL_JOINED := $(patsubst %.part-aa,%,$(LINUX_KOBO_SPLIT_TARBALL_AA))

# Download the second part from the same site.
LINUX_EXTRA_DOWNLOADS += $(LINUX_SITE)/$(LINUX_KOBO_SPLIT_TARBALL_AB)

# Extra downloads must have a hash, otherwise the download step fails.
# The kernel tarball itself is already typically exempted from hash checking
# for custom sources; do the same for the additional split part.
BR_NO_CHECK_HASH_FOR += $(LINUX_KOBO_SPLIT_TARBALL_AB)

# We'll run zstdcat (via suitable-extractor) ourselves.
LINUX_DEPENDENCIES += host-zstd

define LINUX_EXTRACT_CMDS
	$(Q)mkdir -p $(@D)
	$(Q)cat $(LINUX_DL_DIR)/$(LINUX_KOBO_SPLIT_TARBALL_AA) \
		$(LINUX_DL_DIR)/$(LINUX_KOBO_SPLIT_TARBALL_AB) \
		> $(@D)/$(LINUX_KOBO_SPLIT_TARBALL_JOINED)
	$(Q)$(call suitable-extractor,$(LINUX_KOBO_SPLIT_TARBALL_JOINED)) \
		$(@D)/$(LINUX_KOBO_SPLIT_TARBALL_JOINED) | \
		$(TAR) --strip-components=1 -C $(@D) $(TAR_OPTIONS) -
	$(Q)if [ ! -f "$(@D)/Makefile" ] && [ -f "$(@D)/v4.9/Makefile" ]; then \
		cp -a "$(@D)/v4.9/." "$(@D)/"; \
		rm -rf "$(@D)/v4.9"; \
	fi
endef

# Build connectivity drivers (wifi & bt) after the kernel
# Each driver subdirectory has its own Makefile and must be built separately
# Order matters: wmt_mt66xx -> adapter_mt66xx -> gen4m_mt66xx (depends on adapter) -> bt_driver
define LINUX_BUILD_CONNECTIVITY_CMDS
	$(Q)if [ -d "$(@D)/connectivity/wmt_mt66xx" ]; then \
		$(LINUX_MAKE_ENV) $(MAKE) $(LINUX_MAKE_FLAGS) \
			-C $(@D) M=$(@D)/connectivity/wmt_mt66xx modules; \
	fi
	$(Q)if [ -d "$(@D)/connectivity/wlan_driver/adapter_mt66xx" ]; then \
		$(LINUX_MAKE_ENV) $(MAKE) $(LINUX_MAKE_FLAGS) \
			-C $(@D) M=$(@D)/connectivity/wlan_driver/adapter_mt66xx modules \
			KCPPFLAGS="-I$(@D)/connectivity/wmt_mt66xx/common_main/include -I$(@D)/connectivity/wmt_mt66xx/common_main/linux/include -I$(@D)/connectivity/wmt_mt66xx/debug_utility -I$(@D)/drivers/misc/mediatek/include/mt-plat" \
			KBUILD_EXTRA_SYMBOLS=$(@D)/connectivity/wmt_mt66xx/Module.symvers; \
	fi
	$(Q)if [ -d "$(@D)/connectivity/wlan_driver/gen4m_mt66xx" ]; then \
		$(LINUX_MAKE_ENV) $(MAKE) $(LINUX_MAKE_FLAGS) \
			-C $(@D) M=$(@D)/connectivity/wlan_driver/gen4m_mt66xx modules \
			TARGET_PLATFORM=mt8113 \
			MODULE_NAME=wlan_drv_gen4m \
			KBUILD_EXTRA_SYMBOLS="$(@D)/connectivity/wmt_mt66xx/Module.symvers $(@D)/connectivity/wlan_driver/adapter_mt66xx/Module.symvers"; \
	fi
	$(Q)if [ -d "$(@D)/connectivity/bt_driver/mt66xx" ]; then \
		$(LINUX_MAKE_ENV) $(MAKE) $(LINUX_MAKE_FLAGS) \
			-C $(@D) M=$(@D)/connectivity/bt_driver/mt66xx modules \
			CONNECTIVITY_SRC=$(@D)/connectivity \
			KERNEL_VER=$(LINUX_VERSION) \
			KCPPFLAGS="-I$(@D)/drivers/misc/mediatek/include/mt-plat" \
			KBUILD_EXTRA_SYMBOLS=$(@D)/connectivity/wmt_mt66xx/Module.symvers; \
	fi
endef

LINUX_POST_BUILD_HOOKS += LINUX_BUILD_CONNECTIVITY_CMDS

# Install connectivity modules to target in wmt_loader expected directory
define LINUX_INSTALL_CONNECTIVITY_MODULES
	$(Q)mkdir -p $(TARGET_DIR)/drivers/mt8113t-ntx/mt66xx
	$(Q)if [ -d "$(@D)/connectivity/wmt_mt66xx" ]; then \
		cp -f $(@D)/connectivity/wmt_mt66xx/*.ko $(TARGET_DIR)/drivers/mt8113t-ntx/mt66xx/ 2>/dev/null || true; \
	fi
	$(Q)if [ -d "$(@D)/connectivity/wlan_driver/adapter_mt66xx" ]; then \
		cp -f $(@D)/connectivity/wlan_driver/adapter_mt66xx/*.ko $(TARGET_DIR)/drivers/mt8113t-ntx/mt66xx/ 2>/dev/null || true; \
	fi
	$(Q)if [ -d "$(@D)/connectivity/wlan_driver/gen4m_mt66xx" ]; then \
		cp -f $(@D)/connectivity/wlan_driver/gen4m_mt66xx/*.ko $(TARGET_DIR)/drivers/mt8113t-ntx/mt66xx/ 2>/dev/null || true; \
	fi
	$(Q)if [ -d "$(@D)/connectivity/bt_driver/mt66xx" ]; then \
		cp -f $(@D)/connectivity/bt_driver/mt66xx/*.ko $(TARGET_DIR)/drivers/mt8113t-ntx/mt66xx/ 2>/dev/null || true; \
	fi
endef

LINUX_POST_INSTALL_TARGET_HOOKS += LINUX_INSTALL_CONNECTIVITY_MODULES

endif
