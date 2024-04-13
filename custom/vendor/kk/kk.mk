
############################ kk server product ######################################
PRODUCT_PACKAGES += \
    libhv \
    libkk_http_server_service_aidl \
    libkk_http_server_service \
    kk_http_server \
	HTTPServerManager

############################ adb network debugging port ######################################
ifeq ($(TARGET_BUILD_VARIANT),eng)
    PRODUCT_COPY_FILES += \
        vendor/kk/init.set_adb_tcp_port.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.set_adb_tcp_port.rc
endif

ifeq ($(TARGET_BUILD_VARIANT),userdebug)
    PRODUCT_COPY_FILES += \
        vendor/kk/init.set_adb_tcp_port.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.set_adb_tcp_port.rc
endif
