# SPDX-License-Identifier: GPL-2.0
# Author: xunicatt
# Project: railm (railm) 
# Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

FLUTTER ?= flutter
BUILD ?= build
RAILM ?= .

VERSION ?= $(shell cat ../version)

RAILAPI_URL ?=
RAILAPI_TOKEN ?=
MAPBOX_TOKEN ?=
GITHUB_VERSION_URL ?=
GITHUB_RELEASE_URL ?=

TARGETS := \
	$(BUILD)/railm-android-unsigned-$(VERSION).apk

ifeq ($(shell uname),Darwin)
  TARGETS += $(BUILD)/railm-ios-unsigned-$(VERSION).ipa
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

  ifndef GITHUB_VERSION_URL
    $(error GITHUB_VERSION_URL not provided)
  endif

  ifndef GITHUB_RELEASE_URL
    $(error GITHUB_RELEASE_URL not provided)
  endif
endif

.PHONY: build build-android build-ios run-debug run-release clean help version

help:
	@echo "Usage: make [options] [envs]"
	@echo "  Options:"
	@echo "    help                                 Prints help."
	@echo "    build                                Builds unsigned android and ios app."
	@echo "    |- build-android                     Builds unsigned android app."
	@echo "    |- build-ios                         Builds unsigned ios app."
	@echo "           [RAILAPI_URL,"
	@echo "           RAILAPI_TOKEN,"
	@echo "           GITHUB_VERSION_URL,"
	@echo "           GITHUB_RELEASE_URL,"
	@echo "           MAPBOX_TOKEN]"
	@echo
	@echo "    run"
	@echo "    |- run-debug                         Builds and runs app in debug mode."
	@echo "    |- run-release                       Builds and runs app in release mode."
	@echo "               [RAILAPI_URL,"
	@echo "               RAILAPI_TOKEN,"
	@echo "               GITHUB_VERSION_URL,"
	@echo "               GITHUB_RELEASE_URL,"
	@echo "               MAPBOX_TOKEN]"
	@echo
	@echo "    clean                                Cleans build artifacts."
	@echo "    version                              Prints current project version."
	@echo
	@echo "  Environment Variables:"
	@echo "    RAILAPI_URL                          Url for Railapi hosted server."
	@echo "    RAILAPI_TOKEN                        Token for Railapi APIs."
	@echo "    MAPBOX_TOKEN                         Token for Mapbox APIs."
	@echo "    GITHUB_VERSION_URL                   Raw file link to the github 'version' file."
	@echo "    GITHUB_RELEASE_URL                   Link for the github release page."
	@echo "    VERSION                              Build Version."

build: $(TARGETS)

version:
	@echo $(VERSION)

build-android: $(BUILD)/railm-android-unsigned-$(VERSION).apk

build-ios: $(BUILD)/railm-ios-unsigned-$(VERSION).ipa

$(BUILD)/railm-android-unsigned-$(VERSION).apk: $(RAILM)/build/app/outputs/apk/release/app-release.apk
	mkdir -p $(BUILD)
	mv $< $@

$(BUILD)/railm-ios-unsigned-$(VERSION).ipa: $(RAILM)/build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app
	mkdir -p $(BUILD)
	cp -r $< $(BUILD)/Payload
	cd $(BUILD) && zip -r app.zip Payload
	rm -r $(BUILD)/Payload
	mv $(BUILD)/app.zip $@

$(RAILM)/build/app/outputs/apk/release/app-release.apk:
	$(FLUTTER) build apk --release \
    	--dart-define=RAILAPI_URL=$(RAILAPI_URL) \
        --dart-define=RAILAPI_TOKEN=$(RAILAPI_TOKEN) \
        --dart-define=MAPBOX_TOKEN=$(MAPBOX_TOKEN) \
        --dart-define=RAILM_APP_VERSION=$(VERSION) \
        --dart-define=GITHUB_RELEASE_URL=$(GITHUB_RELEASE_URL) \
        --dart-define=GITHUB_VERSION_URL=$(GITHUB_VERSION_URL)


$(RAILM)/build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app:
	$(FLUTTER) build ipa --release --no-codesign \
    	--dart-define=RAILAPI_URL=$(RAILAPI_URL) \
        --dart-define=RAILAPI_TOKEN=$(RAILAPI_TOKEN) \
        --dart-define=MAPBOX_TOKEN=$(MAPBOX_TOKEN) \
        --dart-define=RAILM_APP_VERSION=$(VERSION) \
        --dart-define=GITHUB_RELEASE_URL=$(GITHUB_RELEASE_URL) \
        --dart-define=GITHUB_VERSION_URL=$(GITHUB_VERSION_URL)

run-debug:
	$(FLUTTER) run \
    	--dart-define=RAILAPI_URL=$(RAILAPI_URL) \
        --dart-define=RAILAPI_TOKEN=$(RAILAPI_TOKEN) \
        --dart-define=MAPBOX_TOKEN=$(MAPBOX_TOKEN) \
        --dart-define=RAILM_APP_VERSION=$(VERSION)-debug \
        --dart-define=GITHUB_RELEASE_URL=$(GITHUB_RELEASE_URL) \
        --dart-define=GITHUB_VERSION_URL=$(GITHUB_VERSION_URL)

run-release:
	$(FLUTTER) run --release \
    	--dart-define=RAILAPI_URL=$(RAILAPI_URL) \
        --dart-define=RAILAPI_TOKEN=$(RAILAPI_TOKEN) \
        --dart-define=MAPBOX_TOKEN=$(MAPBOX_TOKEN) \
        --dart-define=RAILM_APP_VERSION=$(VERSION) \
        --dart-define=GITHUB_RELEASE_URL=$(GITHUB_RELEASE_URL) \
        --dart-define=GITHUB_VERSION_URL=$(GITHUB_VERSION_URL)

clean:
	flutter clean
	rm -rf $(TARGETS)
