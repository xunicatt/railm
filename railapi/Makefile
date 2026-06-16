# SPDX-License-Identifier: GPL-2.0
# Author: xunicatt
# Project: railm (railapi) 
# Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

GO ?= go
BUILD ?= build
RAILAPI ?= .

DATE := $(shell date +%y%m)
BUILDVER := $(shell cat ../.build)
VERSION ?= v$(DATE).$(BUILDVER)

PORT ?=
TURSO_DATABASE_URL ?=
TURSO_DATABASE_TOKEN ?=

TARGETS := \
	$(BUILD)/railapi-linux-amd64-$(VERSION) \
	$(BUILD)/railapi-linux-arm64-$(VERSION) \
	$(BUILD)/railapi-darwin-arm64-$(VERSION)

ifneq ($(filter run,$(MAKECMDGOALS)),)
  ifndef TURSO_DATABASE_URL
    $(error TURSO_DATABASE_URL not provided)
  endif

  ifndef TURSO_DATABASE_TOKEN
    $(error TURSO_DATABASE_TOKEN not provided)
  endif
endif

.PHONY: build build-minimal run clean help version

help:
	@echo "Usage: make [options] [envs]"
	@echo "  Options:"
	@echo "    help                                 Prints help."
	@echo "    build                                Builds server binaries for multiple platforms."
	@echo "    |- build-minimal                     Builds server binaries for current platform."
	@echo "    run [PORT,                           Run server."
	@echo "         TURSO_DATABASE_URL,"
	@echo "         TURSO_DATABASE_TOKEN]"
	@echo
	@echo "    clean                                Cleans build artifacts."
	@echo "    version                              Prints current project version."
	@echo
	@echo "  Environment Variables:"
	@echo "    PORT (default: 3000)                 Url for Railapi hosted server."
	@echo "    TURSO_DATABASE_URL                   Url for TursoDB."
	@echo "    TURSO_DATABASE_TOKEN                 Token for TursoDB."
	@echo "    VERSION                              Build Version."

build: $(TARGETS)

build-minimal: $(BUILD)/server

version:
	@echo $(VERSION)

run: $(BUILD)/server
	./$<
	
$(BUILD)/server: $(RAILAPI)/cmd/server/main.go
	$(GO) build -o $@ $<

$(BUILD)/railapi-linux-amd64-$(VERSION): $(RAILAPI)/cmd/server/main.go
	GOOS=linux GOARCH=amd64 $(GO) build -o $@ $<

$(BUILD)/railapi-linux-arm64-$(VERSION): $(RAILAPI)/cmd/server/main.go
	GOOS=linux GOARCH=arm64 $(GO) build -o $@ $<

$(BUILD)/railapi-darwin-arm64-$(VERSION): $(RAILAPI)/cmd/server/main.go
	GOOS=linux GOARCH=arm64 $(GO) build -o $@ $<

clean:
	rm -rf $(BUILD)/server
	rm -rf $(TARGETS)
