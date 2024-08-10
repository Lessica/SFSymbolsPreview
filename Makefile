ARCHS := arm64
TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES := SFSymbolsPreview

include $(THEOS)/makefiles/common.mk

XCODEPROJ_NAME += SFSymbolsPreview

include $(THEOS_MAKE_PATH)/xcodeproj.mk