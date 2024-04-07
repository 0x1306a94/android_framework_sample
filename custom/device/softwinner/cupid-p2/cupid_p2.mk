# LOCAL_PATH MUST defined in Makefile top location
LOCAL_PATH := $(shell dirname $(lastword $(MAKEFILE_LIST)))

$(call inherit-product, device/softwinner/cupid-common/cupid-common.mk)
$(call inherit-product, $(LOCAL_PATH)/hal.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/gsi_keys.mk)
$(call inherit-product-if-exists, device/softwinner/cupid-p2/tv_base.mk)

ifneq ($(wildcard $(LOCAL_PATH)/modules/modules),)
PRODUCT_COPY_FILES += $(call find-copy-subdir-files,*,$(LOCAL_PATH)/modules/modules,$(TARGET_COPY_OUT_VENDOR)/modules)
endif

DEVICE_PACKAGE_OVERLAYS := $(LOCAL_PATH)/overlay \
                           $(DEVICE_PACKAGE_OVERLAYS)

# Disable APEX_LIBS_ABSENCE_CHECK
# We got offending entrie if enable check: libicui18n and libicuuc.
# Both are dependencies of libcedarx. We must fix the dependencies and then enable check.
DISABLE_APEX_LIBS_ABSENCE_CHECK := true

# build & split configs
PRODUCT_ENFORCE_RRO_TARGETS := framework-res
BOARD_PROPERTY_OVERRIDES_SPLIT_ENABLED := true
PRODUCT_FULL_TREBLE_OVERRIDE := true

PRODUCT_PACKAGES += Update

PRODUCT_USE_DYNAMIC_PARTITIONS := true

ifeq ($(PRODUCT_USE_DYNAMIC_PARTITIONS),true)
PRODUCT_PACKAGES += \
    fastbootd \
    android.hardware.fastboot@1.0-impl
endif

# all devices got ram size equal to or less than 1GB should be defined as low ram device.
CONFIG_LOW_RAM_DEVICE := false
ifeq ($(CONFIG_LOW_RAM_DEVICE),true)
    $(call inherit-product, $(LOCAL_PATH)/configs/go/go_base.mk)
    #$(call inherit-product, build/target/product/go_defaults.mk)
    # use special go config
    $(call inherit-product, device/softwinner/common/go_common.mk)

    DEVICE_PACKAGE_OVERLAYS := $(LOCAL_PATH)/overlay_go \
                               $(DEVICE_PACKAGE_OVERLAYS)
    # Strip the local variable table and the local variable type table to reduce
    # the size of the system image. This has no bearing on stack traces, but will
    # leave less information available via JDWP.
    PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true

    # Do not generate libartd.
    PRODUCT_ART_TARGET_INCLUDE_DEBUG_BUILD := false

    # Enable DM file preopting to reduce first boot time
    PRODUCT_DEX_PREOPT_GENERATE_DM_FILES :=true
    PRODUCT_DEX_PREOPT_DEFAULT_COMPILER_FILTER := verify

    # Reduces GC frequency of foreground apps by 50% (not recommanded for 512M devices)
    PRODUCT_SYSTEM_DEFAULT_PROPERTIES += dalvik.vm.foreground-heap-growth-multiplier=2.0


    # include gms package for go
    #$(call inherit-product-if-exists, vendor/partner_gms/products/gms_go-mandatory.mk)

    # limit dex2oat threads to improve thermals
    PRODUCT_PROPERTY_OVERRIDES += \
        dalvik.vm.boot-dex2oat-threads=4 \
        dalvik.vm.dex2oat-threads=3 \
        dalvik.vm.image-dex2oat-threads=4

    PRODUCT_PROPERTY_OVERRIDES += \
        dalvik.vm.dex2oat-flags=--no-watch-dog \
        dalvik.vm.jit.codecachesize=0

    PRODUCT_PROPERTY_OVERRIDES += \
        pm.dexopt.boot=extract \
        dalvik.vm.heapstartsize=8m \
        dalvik.vm.heaptargetutilization=0.75 \
        dalvik.vm.heapminfree=512k \
        dalvik.vm.heapmaxfree=8m

   PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
        dalvik.vm.madvise-random=true

else # ifeq ($(CONFIG_LOW_RAM_DEVICE),true)
    $(call inherit-product, build/target/product/full_base.mk)


    # include gms package
    #$(call inherit-product-if-exists, vendor/partner_gms/products/gms-mandatory.mk)

    PRODUCT_PROPERTY_OVERRIDES += \
        dalvik.vm.heapstartsize=8m \
        dalvik.vm.heapgrowthlimit=256m \
        dalvik.vm.heapsize=512m \
        dalvik.vm.heaptargetutilization=0.75 \
        dalvik.vm.heapminfree=512k \
        dalvik.vm.heapmaxfree=8m

endif# ifeq ($(CONFIG_LOW_RAM_DEVICE),true)


# enable property split
PRODUCT_COMPATIBLE_PROPERTY_OVERRIDE := true

# set product shipping(first) api level
PRODUCT_SHIPPING_API_LEVEL := 29

# secure config
BOARD_HAS_SECURE_OS := true

# drm config
BOARD_WIDEVINE_OEMCRYPTO_LEVEL := 3

# camera hal config
USE_CAMERA_HAL_3_4 := false
USE_CAMERA_HAL_1_0 := true

# dm-verity relative
#$(call inherit-product, build/target/product/verity.mk)
# PRODUCT_SUPPORTS_BOOT_SIGNER must be false,otherwise error will be find when boota check boot partition
#PRODUCT_SUPPORTS_BOOT_SIGNER := false
#PRODUCT_SUPPORTS_VERITY_FEC := false
#PRODUCT_SYSTEM_VERITY_PARTITION := /dev/block/by-name/system
#PRODUCT_VENDOR_VERITY_PARTITION := /dev/block/by-name/vendor
#PRODUCT_PACKAGES += \
#	slideshow \
#	verity_warning_images


PRODUCT_PACKAGES += \
    SoundRecorder

PRODUCT_PACKAGES += AllwinnerGmsIntegration

############################# WiFi/Bluetooth Support ############################
include device/softwinner/common/config/wireless/wireless_config.mk

############################### 3G Dongle Support ###############################
# Radio Packages and Configuration Flie
#$(call inherit-product-if-exists, vendor/aw/public/prebuild/lib/librild/radio_common.mk)

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/fstab.sun50iw9p1:$(TARGET_COPY_OUT_RAMDISK)/fstab.sun50iw9p1 \
    $(LOCAL_PATH)/fstab.sun50iw9p1:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.sun50iw9p1

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/kernel:kernel \
    $(LOCAL_PATH)/init.device.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.device.rc \
    $(LOCAL_PATH)/init.recovery.sun50iw9p1.rc:root/init.recovery.sun50iw9p1.rc

PRODUCT_COPY_FILES += \
    device/softwinner/common/config/tv_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/tv_core_hardware.xml \
    frameworks/native/data/etc/android.hardware.camera.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.software.verified_boot.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.verified_boot.xml \
    frameworks/native/data/etc/android.hardware.ethernet.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.ethernet.xml \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.accelerometer.xml

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/camera.cfg:$(TARGET_COPY_OUT_VENDOR)/etc/camera.cfg \
    $(LOCAL_PATH)/configs/media_profiles.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_profiles_V1_0.xml \
    $(LOCAL_PATH)/configs/media_codecs_performance.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_performance.xml \
    $(LOCAL_PATH)/configs/gsensor.cfg:$(TARGET_COPY_OUT_VENDOR)/etc/gsensor.cfg \
    device/softwinner/common/config/awbms_config:$(TARGET_COPY_OUT_VENDOR)/etc/awbms_config \

PRODUCT_COPY_FILES += \
    hardware/aw/camera/1_0/libstd/libstdc++.so:$(TARGET_COPY_OUT_VENDOR)/lib/libstdc++.so

#camera config for camera detector
#PRODUCT_COPY_FILES += \
#    $(LOCAL_PATH)/hawkview/sensor_list_cfg.ini:vendor/etc/hawkview/sensor_list_cfg.ini

# audio
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/audio_mixer_paths.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_mixer_paths.xml

#lmkd whitelist
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/lmkd_whitelist:$(TARGET_COPY_OUT_SYSTEM)/etc/lmkd_whitelist

# bootanimation
#PRODUCT_COPY_FILES += \
#    $(LOCAL_PATH)/media/bootanimation.zip:system/media/bootanimation.zip

# preferred activity
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/preferred-apps/custom.xml:system/etc/preferred-apps/custom.xml

PRODUCT_PROPERTY_OVERRIDES += \
    ro.frp.pst=/dev/block/by-name/frp

ifneq (,$(filter userdebug eng,$(TARGET_BUILD_VARIANT)))
# default set fasle,you can adb set persist.debug.logpersistd=true to enable it
PRODUCT_DEBUG := true
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    persist.sys.usb.config=mtp,adb \
    ro.adb.secure=0

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.sys.dis_app_animation=true
else
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    persist.sys.usb.config=mtp \
    ro.adb.secure=1
endif

PRODUCT_PROPERTY_OVERRIDES += \
    ro.sf.lcd_density=320

PRODUCT_PROPERTY_OVERRIDES += \
    ro.lmk.use_new_strategy=false \
    ro.lmk.downgrade_pressure=95 \
    ro.lmk.upgrade_pressure=50

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    persist.sys.timezone=Asia/Shanghai \
    persist.sys.country=US \
    persist.sys.language=en

# stoarge
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    persist.fw.force_adoptable=true

#booevent true=enable bootevent,false=disable bootevent
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += persist.sys.bootevent=true

# for adiantum encryption
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
	ro.crypto.fde_algorithm=adiantum \
	ro.crypto.fde_sector_size=4096 \
	ro.crypto.volume.contents_mode=adiantum \
	ro.crypto.volume.filenames_mode=adiantum

# for ota
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.build.version.ota=9.0.1 \
    ro.vendor.sys.ota.license=a468243df01f65575218136bdcc17d47a25ccc96b604d6a6b5d62c5f8c96dde1fcba2e168eab23d8


# display
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    persist.display.smart_backlight=1 \
    persist.display.enhance_mode=0 \

#PRODUCT_ROTATION := 90

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
	ro.sf.disablerotation = 1

PRODUCT_CHARACTERISTICS := tv

PRODUCT_AAPT_CONFIG := mdpi xlarge hdpi xhdpi large
PRODUCT_AAPT_PREF_CONFIG := tvdpi

PRODUCT_BRAND := Allwinner
PRODUCT_NAME := cupid_p2
PRODUCT_DEVICE := cupid-p2
# PRODUCT_BOARD must equals the board name in kernel
PRODUCT_BOARD := p2
PRODUCT_MODEL := QUAD-CORE H616 P2
PRODUCT_MANUFACTURER := Allwinner

#writeback de0 to de1, fix issues like de1 not show afbc
HWC_WRITEBACK_ENABLE := enable
#active when HWC_WRITEBACK_ENABLE=enable
#mode=onneed:just wb when afbc layer come
#mode=always:alway wb
HWC_WRITEBACK_MODE := onneed

UI_WITDH := 1920
UI_HEIGHT := 1080

$(call inherit-product-if-exists, vendor/aw/public/tool.mk)

############################ kk server product ######################################
PRODUCT_PACKAGES += \
    libhv \
    libkk_http_server_service_aidl \
    libkk_http_server_service \
    kk_http_server

############################ adb network debugging port ######################################
ifeq ($(TARGET_BUILD_VARIANT),eng)
    PRODUCT_COPY_FILES += \
        vendor/kk/init.set_adb_tcp_port.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.set_adb_tcp_port.rc
endif

ifeq ($(TARGET_BUILD_VARIANT),userdebug)
    PRODUCT_COPY_FILES += \
        vendor/kk/init.set_adb_tcp_port.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.set_adb_tcp_port.rc
endif

