# SPDX-License-Identifier: GPL-2.0
# Author: xunicatt
# Project: railm (railm) 
# Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

FLUTTER ?= flutter
BUILD ?= build
RAILM ?= .

DATE := $(shell date +%y%m)
BUILDVER := $(shell cat ../.build)
VERSION ?= v$(DATE).$(BUILDVER)

RAILAPI_URL ?=
RAILAPI_TOKEN ?=
MAPBOX_TOKEN ?=

TARGETS := \
	$(BUILD)/railm-android-$(VERSION).apk

ifeq ($(shell uname),Darwin)
  TARGETS += $(BUILD)/railm-ios-$(VERSION).ipa
endif

ifneq ($(filter build build-android build-ios run-debug run-release,$(MAKECMDGOALS)),)
  ifndef RAILAPI_URL
    $(error RAILAPI_URL not provided)
  endif

  ifndef RAILAPI_TOKEN
    $(error RAILAPI_TOKEN not provided)
  endif

  ifndef MAPBOX_TOKEN
    $(error MAPBOX_TOKEN not provided)
  endif
endif

.PHONY: build build-android build-ios run-debug run-release clean help version

help:
	@echo "Usage: make [options] [envs]"
	@echo "  Options:"
	@echo "    help                                 Prints help."
	@echo "    build                                Builds android and ios app."
	@echo "    |- build-android                     Builds android app."
	@echo "    |- build-ios                         Builds ios app."
	@echo "           [RAILAPI_URL,"
	@echo "           RAILAPI_TOKEN,"
	@echo "           MAPBOX_TOKEN]"
	@echo
	@echo "    run"
	@echo "    |- run-debug                         Builds and runs app in debug mode."
	@echo "    |- run-release                       Builds and runs app in release mode."
	@echo "               [RAILAPI_URL,"
	@echo "               RAILAPI_TOKEN,"
	@echo "               MAPBOX_TOKEN]"
	@echo
	@echo "    clean                                Cleans build artifacts."
	@echo "    version                              Prints current project version."
	@echo
	@echo "  Environment Variables:"
	@echo "    RAILAPI_URL                          Url for Railapi hosted server."
	@echo "    RAILAPI_TOKEN                        Token for Railapi APIs."
	@echo "    MAPBOX_TOKEN                         Token for Mapbox APIs."
	@echo "    VERSION                              Build Version."

build: $(TARGETS)

version:
	@echo $(VERSION)

build-android: $(BUILD)/railm-android-$(VERSION).apk

build-ios: $(BUILD)/railm-ios-$(VERSION).ipa

$(BUILD)/railm-android-$(VERSION).apk: $(RAILM)/build/app/outputs/apk/release/app-release.apk
	mkdir -p $(BUILD)
	mv $< $@

$(BUILD)/railm-ios-$(VERSION).ipa: $(RAILM)/build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app
	mkdir -p $(BUILD)
	cp -r $< $(BUILD)/Payload
	zip -r $(BUILD)/app.zip $(BUILD)/Payload
	rm -r $(BUILD)/Payload
	mv $(BUILD)/app.zip $@

$(RAILM)/build/app/outputs/apk/release/app-release.apk:
	$(FLUTTER) build apk --release \
    	--dart-define=URL=$(RAILAPI_URL) \
        --dart-define=TOKEN=$(RAILAPI_TOKEN) \
        --dart-define=MAPBOX_TOKEN=$(MAPBOX_TOKEN)

$(RAILM)/build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app:
	$(FLUTTER) build ipa --release --no-codesign \
    	--dart-define=URL=$(RAILAPI_URL) \
        --dart-define=TOKEN=$(RAILAPI_TOKEN) \
        --dart-define=MAPBOX_TOKEN=$(MAPBOX_TOKEN)

run-debug:
	$(FLUTTER) run \
    	--dart-define=URL=$(RAILAPI_URL) \
        --dart-define=TOKEN=$(RAILAPI_TOKEN) \
        --dart-define=MAPBOX_TOKEN=$(MAPBOX_TOKEN)

run-release:
	$(FLUTTER) run --release \
    	--dart-define=URL=$(RAILAPI_URL) \
        --dart-define=TOKEN=$(RAILAPI_TOKEN) \
        --dart-define=MAPBOX_TOKEN=$(MAPBOX_TOKEN)

clean:
	flutter clean
	rm -rf $(TARGETS)
