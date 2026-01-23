define ERLINIT_BUILD_CMDS
	$(MAKE) $(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC) -std=gnu99" \
		CFLAGS="$(TARGET_CFLAGS) -std=gnu99 -I$(NERVES_DEFCONFIG_DIR)/package/erlinit/include" \
		-C $(@D)
endef
