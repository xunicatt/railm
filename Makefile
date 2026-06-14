# SPDX-License-Identifier: GPL-2.0
# Author: xunicatt
# Project: railm
# Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

RAILAPI_URL ?=
RAILAPI_TOKEN ?=
MAPBOX_TOKEN ?=

RELEASE ?=

PWD = $(shell pwd)
BUILD ?= $(PWD)/build

RAILAPI = $(PWD)/railapi
RAILM = $(PWD)/railm

DATE = $(shell date +%y%m)
BUILDVER = $(shell cat .build)
VERSION = v$(DATE).$(BUILDVER)

.PHONY: all pre-build railapi railm help version

help:
	@echo "Usage: make [options] [envs]"
	@echo "  Options:"
	@echo "    help                                 Prints help."
	@echo "    build                                Builds whole project."
	@echo "    |- railapi                           Builds server binaries."
	@echo "    |- railm                             Builds android and ios app."
	@echo "           [RAILAPI_URL,"
	@echo "           RAILAPI_TOKEN,"
	@echo "           MAPBOX_TOKEN]"
	@echo
	@echo "    clean                                Cleans build artifacts."
	@echo "    version                              Prints current project version."
	@echo
	@echo "  Environment Variables:"
	@echo "    RAILAPI_URL                          Url for Railapi hosted server."
	@echo "    RAILAPI_TOKEN                        Token for Railapi APIs."
	@echo "    MAPBOX_TOKEN                         Token for Mapbox APIs."
	@echo "    RELEASE=<yes/no>                     Auto increments build number."

TARGETS =

ifeq ($(RELEASE), yes)
	TARGETS += pre-build
endif

TARGETS += railapi railm

pre-build: .build
	@echo `bc -e "$(BUILDVER) + 1"` > .build

build: $(TARGETS)

version:
	@echo $(VERSION)

railapi:
	cd $(RAILAPI); \
	make RAILAPI=$(RAILAPI) \
		BUILD=$(BUILD) \
		VERSION=$(VERSION) \
		build

railm:
	cd $(RAILM); \
	make RAILM=$(RAILM) \
		BUILD=$(BUILD) \
		VERSION=$(VERSION) \
		RAILAPI_URL=$(RAILAPI_URL) \
		RAILAPI_TOKEN=$(RAILAPI_TOKEN) \
		MAPBOX_TOKEN=$(MAPBOX_TOKEN) \
		build \
		-j1

clean:
	cd $(RAILAPI); \
	make BUILD=$(BUILD) \
		VERSION=$(VERSION) \
		clean	
	cd $(RAILM); \
	make BUILD=$(BUILD) \
		VERSION=$(VERSION) \
		clean 
	rm -rf $(BUILD)
