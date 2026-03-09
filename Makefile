# ============================================================================
# Makefile
# ============================================================================
# Copyright (c) 2025 Michael Gardner, A Bit of Help, Inc.
# SPDX-License-Identifier: BSD-3-Clause
# See LICENSE file in the project root.
# ============================================================================
#
# Helpful targets for building, testing, tagging, and publishing the
# dev_container_cpp image.
#
# User identity is passed at runtime via HOST_USER, HOST_UID, and HOST_GID.
# The image adapts to the host user at container startup via entrypoint.sh.
# ============================================================================

.DEFAULT_GOAL := help

# ----------------------------------------------------------------------------
# Terminal colors
# ----------------------------------------------------------------------------
CYAN             := \033[36m
GREEN            := \033[32m
NC               := \033[0m

# ----------------------------------------------------------------------------
# Project settings
# ----------------------------------------------------------------------------
PROJECT_NAME     ?= dev_container_cpp

# ----------------------------------------------------------------------------
# Image settings
# ----------------------------------------------------------------------------
IMAGE_NAME       ?= dev-container-cpp
SYSTEM_IMAGE_NAME ?= $(IMAGE_NAME)-system
IMAGE_REGISTRY   ?= ghcr.io/abitofhelp
IMAGE_REF        ?= $(IMAGE_REGISTRY)/$(IMAGE_NAME)
SYSTEM_IMAGE_REF ?= $(IMAGE_REGISTRY)/$(SYSTEM_IMAGE_NAME)

# ----------------------------------------------------------------------------
# Host identity (runtime — passed to entrypoint.sh)
# ----------------------------------------------------------------------------
HOST_USER        ?= $(shell whoami)
HOST_UID         ?= $(shell id -u)
HOST_GID         ?= $(shell id -g)

# ----------------------------------------------------------------------------
# Container CLI (override with CONTAINER_CLI=docker)
# ----------------------------------------------------------------------------
CONTAINER_CLI    ?= nerdctl

.PHONY: help
help:
	@echo "Upstream image (Dockerfile — Clang 20, latest CMake, vcpkg — amd64 + arm64):"
	@echo "  pull                 Pull the upstream image from GHCR"
	@echo "  build                Build the upstream image"
	@echo "  build-no-cache       Build the upstream image without cache"
	@echo "  run                  Run the upstream image interactively"
	@echo "  run-root             Run as root, bypassing the entrypoint (diagnostic)"
	@echo "  run-shell            Open zsh in the user home directory"
	@echo "  test                 Smoke test (nerdctl rootless)"
	@echo "  test-docker          Smoke test (docker rootful)"
	@echo "  test-podman          Smoke test (podman rootless)"
	@echo "  save                 Save the image to dist/"
	@echo "  show-tags            Show suggested tags"
	@echo "  tag-version          Tag local image with compiler versions"
	@echo "  tag-latest           Tag local image as latest"
	@echo ""
	@echo "System-toolchain image (Dockerfile.system — GCC 13, Clang 18 — amd64 + arm64):"
	@echo "  pull-system          Pull the system image from GHCR"
	@echo "  build-system         Build the system-toolchain image"
	@echo "  build-system-no-cache Build the system-toolchain image without cache"
	@echo "  run-system           Run the system-toolchain image interactively"
	@echo "  run-root-system      Run as root, bypassing the entrypoint (diagnostic)"
	@echo "  run-shell-system     Open zsh in the user home directory"
	@echo "  test-system          Smoke test (nerdctl rootless)"
	@echo "  test-docker-system   Smoke test (docker rootful)"
	@echo "  test-podman-system   Smoke test (podman rootless)"
	@echo "  save-system          Save the system image to dist/"
	@echo "  show-tags-system     Show suggested tags"
	@echo "  tag-system           Tag local image with system-gcc-13-clang-18"
	@echo "  tag-latest-system    Tag local image as latest"
	@echo ""
	@echo "Docker convenience aliases:"
	@echo "  docker-pull          Pull the upstream image with docker"
	@echo "  docker-pull-system   Pull the system image with docker"
	@echo "  docker-build         Build the upstream image with docker"
	@echo "  docker-build-system  Build the system image with docker"
	@echo "  docker-run           Run the upstream image with docker"
	@echo "  docker-run-system    Run the system image with docker"
	@echo ""
	@echo "Podman convenience aliases:"
	@echo "  podman-pull          Pull the upstream image with podman"
	@echo "  podman-pull-system   Pull the system image with podman"
	@echo "  podman-build         Build the upstream image with podman"
	@echo "  podman-build-system  Build the system image with podman"
	@echo "  podman-run           Run with podman (--userns=keep-id)"
	@echo "  podman-run-system    Run system image with podman (--userns=keep-id)"
	@echo ""
	@echo "General:"
	@echo "  inspect              Show configured image and runtime settings"
	@echo "  clean                Remove build artifacts (dist/, archives)"
	@echo "  compress             Create a compressed source archive from HEAD"
	@echo ""
	@echo "Variables:"
	@echo "  CONTAINER_CLI        Container CLI to use (default: nerdctl)"
	@echo "  HOST_USER            Host username (default: $$(whoami))"
	@echo "  HOST_UID             Host user ID (default: $$(id -u))"
	@echo "  HOST_GID             Host group ID (default: $$(id -g))"

# ----------------------------------------------------------------------------
# Pull targets (pull from GHCR and tag for local use)
# ----------------------------------------------------------------------------
.PHONY: pull
pull:
	$(CONTAINER_CLI) pull $(IMAGE_REF):latest
	$(CONTAINER_CLI) tag $(IMAGE_REF):latest $(IMAGE_NAME):latest

.PHONY: pull-system
pull-system:
	$(CONTAINER_CLI) pull $(SYSTEM_IMAGE_REF):latest
	$(CONTAINER_CLI) tag $(SYSTEM_IMAGE_REF):latest $(SYSTEM_IMAGE_NAME):latest

# ----------------------------------------------------------------------------
# Build targets
# ----------------------------------------------------------------------------
.PHONY: build
build:
	$(CONTAINER_CLI) build -f Dockerfile \
		-t $(IMAGE_NAME) .

.PHONY: build-no-cache
build-no-cache:
	$(CONTAINER_CLI) build --no-cache -f Dockerfile \
		-t $(IMAGE_NAME) .

# ----------------------------------------------------------------------------
# System-toolchain build targets
# ----------------------------------------------------------------------------
.PHONY: build-system
build-system:
	$(CONTAINER_CLI) build -f Dockerfile.system \
		-t $(SYSTEM_IMAGE_NAME) .

.PHONY: build-system-no-cache
build-system-no-cache:
	$(CONTAINER_CLI) build --no-cache -f Dockerfile.system \
		-t $(SYSTEM_IMAGE_NAME) .

# ----------------------------------------------------------------------------
# Run targets
# ----------------------------------------------------------------------------
.PHONY: run
run:
	$(CONTAINER_CLI) run -it --rm \
		-e HOST_UID=$(HOST_UID) \
		-e HOST_GID=$(HOST_GID) \
		-e HOST_USER=$(HOST_USER) \
		-v "$(CURDIR)":/workspace \
		-w /workspace \
		$(IMAGE_NAME)

.PHONY: run-root
run-root:
	$(CONTAINER_CLI) run -it --rm \
		--entrypoint /usr/bin/zsh \
		-u 0 \
		-v "$(CURDIR)":/workspace \
		-w /workspace \
		$(IMAGE_NAME)

.PHONY: run-shell
run-shell:
	$(CONTAINER_CLI) run -it --rm \
		-e HOST_UID=$(HOST_UID) \
		-e HOST_GID=$(HOST_GID) \
		-e HOST_USER=$(HOST_USER) \
		-v "$(CURDIR)":/workspace \
		-w /home/$(HOST_USER) \
		$(IMAGE_NAME)

.PHONY: run-system
run-system:
	$(CONTAINER_CLI) run -it --rm \
		-e HOST_UID=$(HOST_UID) \
		-e HOST_GID=$(HOST_GID) \
		-e HOST_USER=$(HOST_USER) \
		-v "$(CURDIR)":/workspace \
		-w /workspace \
		$(SYSTEM_IMAGE_NAME)

.PHONY: run-root-system
run-root-system:
	$(CONTAINER_CLI) run -it --rm \
		--entrypoint /usr/bin/zsh \
		-u 0 \
		-v "$(CURDIR)":/workspace \
		-w /workspace \
		$(SYSTEM_IMAGE_NAME)

.PHONY: run-shell-system
run-shell-system:
	$(CONTAINER_CLI) run -it --rm \
		-e HOST_UID=$(HOST_UID) \
		-e HOST_GID=$(HOST_GID) \
		-e HOST_USER=$(HOST_USER) \
		-v "$(CURDIR)":/workspace \
		-w /home/$(HOST_USER) \
		$(SYSTEM_IMAGE_NAME)

# ----------------------------------------------------------------------------
# Test targets
# ----------------------------------------------------------------------------
EXAMPLE_DIR      := examples/hello_cpp

define TEST_SCRIPT
set -e
echo "=== Environment ==="
echo "USER=$$(whoami) UID=$$(id -u) GID=$$(id -g) HOME=$$HOME"
echo "DISPLAY_USER=$$DISPLAY_USER"
echo "CONTAINER_RUNTIME=$$CONTAINER_RUNTIME"
echo ""
echo "=== Compile test (CMake + Ninja) ==="
cmake -B build -G Ninja -DCMAKE_CXX_STANDARD=20
cmake --build build
echo ""
echo "=== Run test ==="
./build/hello_cpp
echo ""
echo "=== Toolchain versions ==="
gcc --version | head -1
g++ --version | head -1
clang --version | head -1
cmake --version | head -1
ninja --version
arm-none-eabi-gcc --version | head -1
echo "=== Test passed ==="
endef
export TEST_SCRIPT

define TEST_SCRIPT_SYSTEM
set -e
echo "=== Environment ==="
echo "USER=$$(whoami) UID=$$(id -u) GID=$$(id -g) HOME=$$HOME"
echo "DISPLAY_USER=$$DISPLAY_USER"
echo "CONTAINER_RUNTIME=$$CONTAINER_RUNTIME"
echo ""
echo "=== Compile test (CMake + Ninja) ==="
cmake -B build -G Ninja -DCMAKE_CXX_STANDARD=20
cmake --build build
echo ""
echo "=== Run test ==="
./build/hello_cpp
echo ""
echo "=== Toolchain versions ==="
gcc --version | head -1
g++ --version | head -1
clang --version | head -1
cmake --version | head -1
ninja --version
arm-none-eabi-gcc --version | head -1
echo "=== Test passed ==="
endef
export TEST_SCRIPT_SYSTEM

.PHONY: test
test:
	$(CONTAINER_CLI) run --rm \
		-e HOST_UID=$(HOST_UID) \
		-e HOST_GID=$(HOST_GID) \
		-e HOST_USER=$(HOST_USER) \
		-v "$(CURDIR)":/workspace \
		-w /workspace/$(EXAMPLE_DIR) \
		$(IMAGE_NAME) \
		bash -c "$$TEST_SCRIPT"

.PHONY: test-system
test-system:
	$(CONTAINER_CLI) run --rm \
		-e HOST_UID=$(HOST_UID) \
		-e HOST_GID=$(HOST_GID) \
		-e HOST_USER=$(HOST_USER) \
		-v "$(CURDIR)":/workspace \
		-w /workspace/$(EXAMPLE_DIR) \
		$(SYSTEM_IMAGE_NAME) \
		bash -c "$$TEST_SCRIPT_SYSTEM"

.PHONY: test-docker
test-docker:
	docker run --rm \
		-e HOST_UID=$(HOST_UID) \
		-e HOST_GID=$(HOST_GID) \
		-e HOST_USER=$(HOST_USER) \
		-v "$(CURDIR)":/workspace \
		-w /workspace/$(EXAMPLE_DIR) \
		$(IMAGE_NAME) \
		bash -c "$$TEST_SCRIPT"

.PHONY: test-docker-system
test-docker-system:
	docker run --rm \
		-e HOST_UID=$(HOST_UID) \
		-e HOST_GID=$(HOST_GID) \
		-e HOST_USER=$(HOST_USER) \
		-v "$(CURDIR)":/workspace \
		-w /workspace/$(EXAMPLE_DIR) \
		$(SYSTEM_IMAGE_NAME) \
		bash -c "$$TEST_SCRIPT_SYSTEM"

.PHONY: test-podman
test-podman:
	podman run --rm \
		--userns=keep-id \
		-v "$(CURDIR)":/workspace \
		-w /workspace/$(EXAMPLE_DIR) \
		$(IMAGE_NAME) \
		bash -c "$$TEST_SCRIPT"

.PHONY: test-podman-system
test-podman-system:
	podman run --rm \
		--userns=keep-id \
		-v "$(CURDIR)":/workspace \
		-w /workspace/$(EXAMPLE_DIR) \
		$(SYSTEM_IMAGE_NAME) \
		bash -c "$$TEST_SCRIPT_SYSTEM"

# ----------------------------------------------------------------------------
# Docker convenience aliases
# ----------------------------------------------------------------------------
.PHONY: docker-pull
docker-pull:
	$(MAKE) pull CONTAINER_CLI=docker

.PHONY: docker-pull-system
docker-pull-system:
	$(MAKE) pull-system CONTAINER_CLI=docker

.PHONY: docker-build
docker-build:
	$(MAKE) build CONTAINER_CLI=docker

.PHONY: docker-build-system
docker-build-system:
	$(MAKE) build-system CONTAINER_CLI=docker

.PHONY: docker-run
docker-run:
	$(MAKE) run CONTAINER_CLI=docker

.PHONY: docker-run-system
docker-run-system:
	$(MAKE) run-system CONTAINER_CLI=docker

# ----------------------------------------------------------------------------
# Podman convenience aliases
# ----------------------------------------------------------------------------
# Podman rootless uses --userns=keep-id to map the host UID/GID directly
# into the container, so HOST_* env vars and entrypoint adaptation are not
# needed.  The entrypoint detects a non-root UID and execs the CMD directly.
# ----------------------------------------------------------------------------
.PHONY: podman-pull
podman-pull:
	$(MAKE) pull CONTAINER_CLI=podman

.PHONY: podman-pull-system
podman-pull-system:
	$(MAKE) pull-system CONTAINER_CLI=podman

.PHONY: podman-build
podman-build:
	$(MAKE) build CONTAINER_CLI=podman

.PHONY: podman-build-system
podman-build-system:
	$(MAKE) build-system CONTAINER_CLI=podman

.PHONY: podman-run
podman-run:
	podman run -it --rm \
		--userns=keep-id \
		-v "$(CURDIR)":/workspace \
		-w /workspace \
		$(IMAGE_NAME)

.PHONY: podman-run-system
podman-run-system:
	podman run -it --rm \
		--userns=keep-id \
		-v "$(CURDIR)":/workspace \
		-w /workspace \
		$(SYSTEM_IMAGE_NAME)

# ----------------------------------------------------------------------------
# Image management
# ----------------------------------------------------------------------------
.PHONY: inspect
inspect:
	@echo "IMAGE_NAME         = $(IMAGE_NAME)"
	@echo "SYSTEM_IMAGE_NAME  = $(SYSTEM_IMAGE_NAME)"
	@echo "IMAGE_REF          = $(IMAGE_REF)"
	@echo "SYSTEM_IMAGE_REF   = $(SYSTEM_IMAGE_REF)"
	@echo "CONTAINER_CLI      = $(CONTAINER_CLI)"
	@echo "HOST_USER          = $(HOST_USER)"
	@echo "HOST_UID           = $(HOST_UID)"
	@echo "HOST_GID           = $(HOST_GID)"

# ----------------------------------------------------------------------------
# Image management (upstream image)
# ----------------------------------------------------------------------------
.PHONY: save
save:
	mkdir -p dist
	$(CONTAINER_CLI) save -o dist/$(IMAGE_NAME)-gcc-13-clang-20.tar $(IMAGE_NAME)

.PHONY: show-tags
show-tags:
	@echo "$(IMAGE_REF):latest"
	@echo "$(IMAGE_REF):gcc-13-clang-20"

.PHONY: tag-version
tag-version:
	$(CONTAINER_CLI) tag $(IMAGE_NAME) $(IMAGE_REF):gcc-13-clang-20

.PHONY: tag-latest
tag-latest:
	$(CONTAINER_CLI) tag $(IMAGE_NAME) $(IMAGE_REF):latest

# ----------------------------------------------------------------------------
# Image management (system image)
# ----------------------------------------------------------------------------
.PHONY: save-system
save-system:
	mkdir -p dist
	$(CONTAINER_CLI) save -o dist/$(SYSTEM_IMAGE_NAME)-system-gcc-13-clang-18.tar $(SYSTEM_IMAGE_NAME)

.PHONY: show-tags-system
show-tags-system:
	@echo "$(SYSTEM_IMAGE_REF):latest"
	@echo "$(SYSTEM_IMAGE_REF):system-gcc-13-clang-18"

.PHONY: tag-system
tag-system:
	$(CONTAINER_CLI) tag $(SYSTEM_IMAGE_NAME) $(SYSTEM_IMAGE_REF):system-gcc-13-clang-18

.PHONY: tag-latest-system
tag-latest-system:
	$(CONTAINER_CLI) tag $(SYSTEM_IMAGE_NAME) $(SYSTEM_IMAGE_REF):latest

# ----------------------------------------------------------------------------
# Cleanup
# ----------------------------------------------------------------------------
.PHONY: clean
clean:
	@echo "$(CYAN)Removing build artifacts...$(NC)"
	rm -rf dist/
	rm -f $(PROJECT_NAME).tar.gz
	@echo "$(GREEN)Clean complete.$(NC)"

# ----------------------------------------------------------------------------
# Source archive
# ----------------------------------------------------------------------------
.PHONY: compress
compress:
	@echo "$(CYAN)Creating compressed source archive...$(NC)"
	git archive --format=tar.gz --prefix=$(PROJECT_NAME)/ -o $(PROJECT_NAME).tar.gz HEAD
	@echo "$(GREEN)Archive created: $(PROJECT_NAME).tar.gz$(NC)"
