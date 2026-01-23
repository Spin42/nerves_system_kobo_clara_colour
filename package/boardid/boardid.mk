define BOARDID_BUILD_CMDS
	$(MAKE) $(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC) -std=gnu99" \
		CFLAGS="$(TARGET_CFLAGS) -std=gnu99" \
		-C $(@D)
endef
