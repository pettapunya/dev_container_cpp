# syntax=docker/dockerfile:1.7
# ============================================================================
# Dockerfile — Upstream toolchains (default)
# ============================================================================
# Copyright (c) 2025 Michael Gardner, A Bit of Help, Inc.
# SPDX-License-Identifier: BSD-3-Clause
# See LICENSE file in the project root.
# ============================================================================
#
# C++ Development Container — Upstream Toolchains
#
# Repository: dev_container_cpp
# Docker Image: ghcr.io/abitofhelp/dev-container-cpp
#
# This Dockerfile uses Ubuntu 24.04 as the base image and adds:
#   • Latest Clang/LLVM from the official LLVM APT repository
#   • Latest CMake from the Kitware APT repository
#   • vcpkg for C++ package management
#   • GCC 13 from Ubuntu's system packages
#   • ARM cross-compiler for embedded development
#
# Recommended for:
#   • Teams that want the latest C++20/23/26 compiler features and tooling
#   • Projects using vcpkg for dependency management
#
# For auditable supply chains with no third-party repositories, use
# Dockerfile.system instead — every binary comes from Ubuntu's apt.
#
# Purpose
# -------
# Reproducible development environment for:
#   • Desktop C/C++ development (GCC 13, Clang from LLVM repo)
#   • Embedded C/C++ development (ARM Cortex-M bare-metal, ARM Cortex-A Linux)
#   • Build systems: CMake (latest), Ninja, Meson, Make
#   • Package management: vcpkg
#   • Static analysis: clang-tidy, clang-format, cppcheck
#   • Python 3 + venv
#   • Zsh interactive shell
#
# Supported architectures: linux/amd64, linux/arm64 (Apple Silicon).
#
# Designed for nerdctl + containerd (rootless).
#
# Files expected in the build context:
# - Dockerfile
# - .dockerignore
# - .zshrc
# - entrypoint.sh
#
# Build example:
# nerdctl build -t dev-container-cpp .
#
# Run example:
# nerdctl run -it --rm \
#   -e HOST_UID=$(id -u) \
#   -e HOST_GID=$(id -g) \
#   -e HOST_USER=$(whoami) \
#   -v "$(pwd)":/workspace \
#   -w /workspace \
#   dev-container-cpp
#
# Notes
# -----
# - User identity is adapted at runtime by entrypoint.sh, not baked in at
#   build time. The build-time user (dev:1000:1000) is a fallback for CI
#   and Kubernetes environments where no HOST_* variables are passed.
# - In rootless runtimes, container UID 0 maps to the host user via the
#   user namespace. The entrypoint detects this and stays as UID 0 rather
#   than dropping privileges, which would break bind-mount access.
# - In rootful runtimes, the entrypoint drops to the adapted user via gosu.
# - GNU Make is installed explicitly because many embedded projects use
#   Makefiles as the orchestration layer.
#
# ============================================================================
# Pinned by digest for reproducibility. Update periodically:
#   nerdctl pull ubuntu:24.04
#   nerdctl image inspect ubuntu:24.04 | grep -A1 RepoDigests
FROM ubuntu:24.04@sha256:d1e2e92c075e5ca139d51a140fff46f84315c0fdce203eab2807c7e495eff4f9

# ----------------------------------------------------------------------------
# Build arguments (alphabetized)
# ----------------------------------------------------------------------------
ARG CLANG_VERSION=20
ARG DEBIAN_FRONTEND=noninteractive
ARG USER_GID=1000
ARG USERNAME=dev
ARG USER_UID=1000

# ----------------------------------------------------------------------------
# Environment variables (alphabetized)
# ----------------------------------------------------------------------------
ENV HOME=/home/${USERNAME}
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    PATH=${HOME}/.local/bin:/usr/local/bin:${PATH} \
    SHELL=/usr/bin/zsh \
    TERM=xterm-256color \
    TZ=UTC \
    VCPKG_ROOT=/opt/vcpkg

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# ----------------------------------------------------------------------------
# Base packages (alphabetized)
# ----------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    bzip2 \
    ca-certificates \
    curl \
    fd-find \
    file \
    fzf \
    git \
    gnupg \
    gosu \
    jq \
    less \
    locales \
    lsof \
    make \
    nano \
    neovim \
    openssh-client \
    patch \
    pkg-config \
    procps \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    ripgrep \
    rsync \
    strace \
    sudo \
    tzdata \
    unzip \
    vim \
    wget \
    xz-utils \
    zip \
    zsh \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
    # ------------------------------------------------------------------
    # GCC compiler (system version, secondary compiler)
    # ------------------------------------------------------------------
    build-essential \
    g++-13 \
    gcc-13 \
    # ------------------------------------------------------------------
    # Build systems
    # ------------------------------------------------------------------
    meson \
    ninja-build \
    # ------------------------------------------------------------------
    # Debuggers
    # ------------------------------------------------------------------
    gdb \
    gdb-multiarch \
    valgrind \
    # ------------------------------------------------------------------
    # Embedded: ARM Cortex-M bare-metal cross-compiler and tools
    # ------------------------------------------------------------------
    gcc-arm-none-eabi \
    libnewlib-arm-none-eabi \
    openocd \
    stlink-tools \
    # ------------------------------------------------------------------
    # Embedded: ARM Cortex-A Linux cross-compiler (STM32MP1)
    # ------------------------------------------------------------------
    gcc-arm-linux-gnueabihf \
    libc6-dev-armhf-cross \
    # ------------------------------------------------------------------
    # Static analysis and build acceleration
    # ------------------------------------------------------------------
    ccache \
    cppcheck \
 && locale-gen en_US.UTF-8 \
 && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
 && rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------------------------
# Add LLVM APT repository and install latest Clang/LLVM toolchain
# ----------------------------------------------------------------------------
RUN wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key \
    | gpg --dearmor -o /usr/share/keyrings/llvm-archive-keyring.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/llvm-archive-keyring.gpg] \
    http://apt.llvm.org/noble/ llvm-toolchain-noble-${CLANG_VERSION} main" \
    > /etc/apt/sources.list.d/llvm.list \
 && apt-get update && apt-get install -y --no-install-recommends \
    clang-${CLANG_VERSION} \
    clang-format-${CLANG_VERSION} \
    clang-tidy-${CLANG_VERSION} \
    clang-tools-${CLANG_VERSION} \
    clangd-${CLANG_VERSION} \
    libc++-${CLANG_VERSION}-dev \
    libc++abi-${CLANG_VERSION}-dev \
    lld-${CLANG_VERSION} \
    lldb-${CLANG_VERSION} \
 && rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------------------------
# Add Kitware APT repository and install latest CMake
# ----------------------------------------------------------------------------
RUN wget -qO- https://apt.kitware.com/keys/kitware-archive-latest.asc \
    | gpg --dearmor -o /usr/share/keyrings/kitware-archive-keyring.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] \
    https://apt.kitware.com/ubuntu/ noble main" \
    > /etc/apt/sources.list.d/kitware.list \
 && apt-get update && apt-get install -y --no-install-recommends \
    cmake \
 && rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------------------------
# Set up update-alternatives so unversioned commands point to correct variants
# ----------------------------------------------------------------------------
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100 \
 && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 100 \
 && update-alternatives --install /usr/bin/gcov gcov /usr/bin/gcov-13 100 \
 && update-alternatives --install /usr/bin/gcov-tool gcov-tool /usr/bin/gcov-tool-13 100 \
 && update-alternatives --install /usr/bin/clang clang /usr/bin/clang-${CLANG_VERSION} 100 \
 && update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-${CLANG_VERSION} 100 \
 && update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-${CLANG_VERSION} 100 \
 && update-alternatives --install /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-${CLANG_VERSION} 100 \
 && update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-${CLANG_VERSION} 100 \
 && update-alternatives --install /usr/bin/lld lld /usr/bin/lld-${CLANG_VERSION} 100 \
 && update-alternatives --install /usr/bin/lldb lldb /usr/bin/lldb-${CLANG_VERSION} 100

# ----------------------------------------------------------------------------
# Create developer user
# ----------------------------------------------------------------------------
RUN set -eux; \
    if ! getent group "${USER_GID}" >/dev/null; then \
        groupadd --gid "${USER_GID}" "${USERNAME}"; \
    fi; \
    if id -u "${USERNAME}" >/dev/null 2>&1; then \
        usermod --uid "${USER_UID}" --gid "${USER_GID}" --shell /usr/bin/zsh "${USERNAME}"; \
    elif getent passwd "${USER_UID}" >/dev/null; then \
        EXISTING_USER="$(getent passwd "${USER_UID}" | cut -d: -f1)"; \
        usermod --login "${USERNAME}" --home "/home/${USERNAME}" --move-home \
            --gid "${USER_GID}" --shell /usr/bin/zsh "${EXISTING_USER}"; \
    else \
        useradd --uid "${USER_UID}" --gid "${USER_GID}" -m -s /usr/bin/zsh "${USERNAME}"; \
    fi; \
    usermod -aG sudo "${USERNAME}"; \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${USERNAME}"; \
    chmod 0440 "/etc/sudoers.d/${USERNAME}"

# ----------------------------------------------------------------------------
# License
# ----------------------------------------------------------------------------
COPY LICENSE /usr/share/doc/dev-container-cpp/LICENSE
COPY README.md /usr/share/doc/dev-container-cpp/README.md
COPY USER_GUIDE.md /usr/share/doc/dev-container-cpp/USER_GUIDE.md

# ----------------------------------------------------------------------------
# Install vcpkg (C++ package manager)
# ----------------------------------------------------------------------------
RUN git clone --depth 1 https://github.com/microsoft/vcpkg.git /opt/vcpkg \
 && /opt/vcpkg/bootstrap-vcpkg.sh -disableMetrics \
 && ln -s /opt/vcpkg/vcpkg /usr/local/bin/vcpkg \
 && chown -R "${USER_UID}:${USER_GID}" /opt/vcpkg

# ----------------------------------------------------------------------------
# Switch to developer user
# ----------------------------------------------------------------------------
USER ${USERNAME}
WORKDIR ${HOME}

RUN mkdir -p \
    "${HOME}/.docker/completions" \
    "${HOME}/.local/bin" \
    "${HOME}/workspace"

COPY --chown=${USER_UID}:${USER_GID} .zshrc ${HOME}/.zshrc

# ----------------------------------------------------------------------------
# Verify toolchain installation
# ----------------------------------------------------------------------------
RUN echo "" \
 && echo "=== Upstream toolchain ===" \
 && gcc --version | head -1 \
 && g++ --version | head -1 \
 && clang --version | head -1 \
 && cmake --version | head -1 \
 && ninja --version \
 && meson --version \
 && echo "" \
 && echo "=== Embedded toolchain (bare-metal) ===" \
 && arm-none-eabi-gcc --version | head -1 \
 && echo "" \
 && echo "=== Embedded toolchain (Linux cross) ===" \
 && arm-linux-gnueabihf-gcc --version | head -1 \
 && echo "" \
 && echo "=== Analysis tools ===" \
 && clang-tidy --version | head -1 \
 && cppcheck --version \
 && ccache --version | head -1 \
 && echo "" \
 && echo "=== Package manager ===" \
 && vcpkg version | head -2

# ----------------------------------------------------------------------------
# Install entrypoint and set runtime defaults
# ----------------------------------------------------------------------------
USER root

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/bin/zsh", "-l"]
