# Binary name
BINARY_NAME=bootstrap

# Build directories
BUILD_DIR=build
DIST_DIR=.

# Assets directories
ASSETS_DIR=assets

# Detect OS
ifeq ($(OS),Windows_NT)
    DETECTED_OS := Windows
    SHELL := powershell.exe
    .SHELLFLAGS := -NoProfile -Command
    MKDIR = if (!(Test-Path "$(1)")) { New-Item -ItemType Directory -Path "$(1)" | Out-Null }
    RM = if (Test-Path "$(1)") { Remove-Item -Recurse -Force "$(1)" }
    DATE_CMD = Get-Date -Format 'yyyy-MM-dd_HH:mm:ss' -AsUTC
    SET_ENV = $$env:$(1)='$(2)';
else
    DETECTED_OS := $(shell uname -s)
    MKDIR = mkdir -p $(1)
    RM = rm -rf $(1)
    DATE_CMD = date -u '+%Y-%m-%d_%H:%M:%S'
    SET_ENV = $(1)=$(2)
endif

# Version info (can be overridden)
ifeq ($(DETECTED_OS),Windows)
    VERSION ?= $(shell git describe --tags --always --dirty 2>$$null; if (!$$?) { 'dev' })
    BUILD_TIME = $(shell Get-Date -UFormat '%Y-%m-%d_%H:%M:%S')
else
    VERSION ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo 'dev')
    BUILD_TIME = $(shell date -u '+%Y-%m-%d_%H:%M:%S')
endif

# Go build flags
LDFLAGS=-ldflags "-X main.Version=$(VERSION) -X main.BuildTime=$(BUILD_TIME)"

.PHONY: all build clean test build-all build-windows build-linux build-macos

# Default build for current platform
build:
ifeq ($(DETECTED_OS),Windows)
	@if (!(Test-Path "$(BUILD_DIR)")) { New-Item -ItemType Directory -Path "$(BUILD_DIR)" | Out-Null }
	go build $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME).exe
else
	@mkdir -p $(BUILD_DIR)
	go build $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)
endif

# Build for all platforms
build-all: build-windows build-linux build-macos

# Windows builds
build-windows:
ifeq ($(DETECTED_OS),Windows)
	@if (!(Test-Path "$(DIST_DIR)")) { New-Item -ItemType Directory -Path "$(DIST_DIR)" | Out-Null }
	$$env:GOOS='windows'; $$env:GOARCH='arm64'; go build $(LDFLAGS) -o $(DIST_DIR)/$(BINARY_NAME)-windows-arm64.exe -tags lambda.norpc
else
	GOOS=windows GOARCH=arm64 go build $(LDFLAGS) -o $(DIST_DIR)/$(BINARY_NAME)-windows-arm64.exe -tags lambda.norpc
endif

# Linux builds
build-linux:
ifeq ($(DETECTED_OS),Windows)
	@if (!(Test-Path "$(DIST_DIR)")) { New-Item -ItemType Directory -Path "$(DIST_DIR)" | Out-Null }
	$$env:GOOS='linux'; $$env:GOARCH='arm64'; go build $(LDFLAGS) -o $(DIST_DIR)/$(BINARY_NAME)-linux-arm64 -tags lambda.norpc
else
	GOOS=linux GOARCH=arm64 go build $(LDFLAGS) -o $(DIST_DIR)/$(BINARY_NAME)-linux-arm64 -tags lambda.norpc
endif

# macOS builds
build-macos:
ifeq ($(DETECTED_OS),Windows)
	@if (!(Test-Path "$(DIST_DIR)")) { New-Item -ItemType Directory -Path "$(DIST_DIR)" | Out-Null }
	$$env:GOOS='darwin'; $$env:GOARCH='arm64'; go build $(LDFLAGS) -o $(DIST_DIR)/$(BINARY_NAME)-darwin-arm64 -tags lambda.norpc
else
	GOOS=darwin GOARCH=arm64 go build $(LDFLAGS) -o $(DIST_DIR)/$(BINARY_NAME)-darwin-arm64 -tags lambda.norpc
endif

# Clean build artifacts
clean:
ifeq ($(DETECTED_OS),Windows)
	@if (Test-Path "$(BUILD_DIR)") { Remove-Item -Recurse -Force "$(BUILD_DIR)" }
	@if (Test-Path "$(DIST_DIR)/bootstrap") { Remove-Item "$(DIST_DIR)/bootstrap" }
else
	@[ -d $(BUILD_DIR) ] && rm -rf $(BUILD_DIR) || true
	@[ -f $(DIST_DIR)/bootstrap ] && rm $(DIST_DIR)/bootstrap || true
endif

# Run tests
test:
	go test -v ./...

package: clean build-linux
ifeq ($(DETECTED_OS),Windows)
	Move-Item -Path "$(DIST_DIR)/$(BINARY_NAME)-linux-arm64" -Destination "$(DIST_DIR)/$(BINARY_NAME)" -Force
	zip -r $(DIST_DIR)/bootstrap.zip $(DIST_DIR)/$(BINARY_NAME) $(ASSETS_DIR)
else
	mv $(DIST_DIR)/$(BINARY_NAME)-linux-arm64 $(DIST_DIR)/$(BINARY_NAME)
	zip -r $(DIST_DIR)/bootstrap.zip $(DIST_DIR)/$(BINARY_NAME) $(ASSETS_DIR)
endif