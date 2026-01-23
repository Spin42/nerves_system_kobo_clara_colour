################################################################################
# af_compat: add missing AF_* constants to sysroot headers
################################################################################

AF_COMPAT_VERSION = 1.0
AF_COMPAT_SITE = $(NERVES_DEFCONFIG_DIR)/package/af_compat
AF_COMPAT_SOURCE = af_compat-$(AF_COMPAT_VERSION).tar.gz
AF_COMPAT_SITE_METHOD = local
AF_COMPAT_LICENSE = MIT
AF_COMPAT_INSTALL_STAGING = YES
AF_COMPAT_INSTALL_TARGET = NO

# Append missing constants if absent
define AF_COMPAT_APPEND_HEADERS
	for hdr in \
		$(STAGING_DIR)/usr/include/linux/socket.h \
		$(HOST_DIR)/arm-buildroot-linux-gnueabihf/sysroot/usr/include/linux/socket.h; do \
		if [ -f $$hdr ] && ! grep -q "AF_KCM" $$hdr; then \
			printf '%s\n' \
			'#ifndef AF_KCM' \
			'#define PF_KCM 41' \
			'#define AF_KCM PF_KCM' \
			'#endif' \
			'#ifndef AF_IB' \
			'#define PF_IB 27' \
			'#define AF_IB PF_IB' \
			'#define PF_MPLS 28' \
			'#define AF_MPLS PF_MPLS' \
			'#endif' >> $$hdr; \
			"#endif" >> $$hdr; \
		fi; \
	done
endef

AF_COMPAT_POST_INSTALL_STAGING_HOOKS += AF_COMPAT_APPEND_HEADERS

$(eval $(generic-package))
