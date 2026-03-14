# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.2] - 2026-03-14

### Added

- Neovim text editor.

## [1.1.1] - 2026-03-09

### Added

- "Embedded Toolchain Readiness" table in README confirming all three targets
  (desktop, Cortex-M7 bare-metal, Cortex-A7 Linux) are pre-installed.
- CMake toolchain file examples in USER_GUIDE §0.4 for desktop, bare-metal,
  and Linux cross-compilation targets.

### Fixed

- README tagline: "ARM Cortex-M" changed to "ARM Cortex-M/A" to reflect
  Cortex-A7 Linux cross-compilation support added in v1.1.0.
- README test matrix: MacBook Pro (arm64) marked as Passed.
- README badges placed on a single line for correct inline rendering.

## [1.1.0] - 2026-03-10

### Added

- ARM Cortex-A Linux cross-compiler (`gcc-arm-linux-gnueabihf`,
  `libc6-dev-armhf-cross`) for STM32MP135F and similar Cortex-A7 boards
  running Linux.
- "Embedded Board Support" section in README documenting both supported
  boards (STM32F769I bare-metal, STM32MP135F Linux).
- Updated USER_GUIDE §0.4 with embedded board support table.
- Updated component source tables in README with `arm-linux-gnueabihf-gcc`.
- Verification step in both Dockerfiles for the Linux cross-compiler.

## [1.0.0] - 2026-03-09

### Changed

- Clarified two-image rationale: the deciding factor is supply chain
  auditability (system image uses only Canonical-signed apt packages), not
  features. Updated README, USER_GUIDE, and both Dockerfile headers.

### Fixed

- Removed duplicate "see Dockerfile.system" comment in Dockerfile header.
- Removed unused `software-properties-common` package from upstream Dockerfile
  (GPG keys are handled directly via `gpg --dearmor`).
- Added `--depth 1` to vcpkg `git clone` to save ~200MB of history during build.

### Verified

- GitHub Actions: Docker Build workflow (multi-arch matrix + smoke test) passed.
- GitHub Actions: Docker Publish workflow (both images pushed to GHCR) passed.
- Upstream image: nerdctl rootless (Ubuntu VM amd64), Docker rootful (macOS
  Intel amd64). Both passed.
- System image: nerdctl rootless (Ubuntu VM amd64), Docker rootful (macOS
  Intel amd64). Both passed.

## [1.0.0-rc1] - 2026-03-09

### Added

- Ubuntu 24.04 base image pinned by digest for reproducibility.
- Two Dockerfile variants:
  - `Dockerfile` (default): upstream toolchains — LLVM repo Clang 20, Kitware
    CMake 4.x, vcpkg package manager.
  - `Dockerfile.system`: system toolchains — Ubuntu apt packages only (GCC 13,
    Clang 18, CMake 3.28, Catch2).
- Both images support `linux/amd64` and `linux/arm64` multi-arch builds.
- Desktop C/C++ development: GCC 13, Clang 20/18, CMake, Ninja, Meson, Make.
- Embedded C/C++ development: arm-none-eabi-gcc, libnewlib-arm-none-eabi,
  OpenOCD, stlink-tools, gdb-multiarch.
- Static analysis: clang-tidy, clang-format, cppcheck, ccache.
- Debuggers: GDB, LLDB, Valgrind.
- Language server: clangd.
- Package management: vcpkg (upstream image only).
- Python 3 with venv support.
- Zsh interactive shell with autosuggestions and syntax highlighting.
- Runtime-adaptive user identity via `entrypoint.sh` — no rebuild needed
  per developer.
- Rootless detection via `/proc/self/uid_map` inspection.
- Rootful privilege drop via `gosu`.
- `DISPLAY_USER` environment variable for correct prompt identity in
  rootless mode.
- Container detection markers (`IN_CONTAINER`, `CONTAINER_RUNTIME`)
  exported by entrypoint for reliable `.zshrc` detection.
- Container-aware Zsh prompt with git branch and runtime indicator.
- C++ development aliases: `cb`, `cbr`, `ccfg`, `cf`, `ct`, `ctidy`,
  `mn`, `nn`.
- `container_info` shell function for quick environment diagnostics.
- Makefile with targets: `build`, `build-no-cache`, `build-system`,
  `build-system-no-cache`, `run`, `run-root`, `run-shell`, `run-system`,
  `run-root-system`, `run-shell-system`, `pull`, `pull-system`, `test`,
  `test-system`, `test-docker`, `test-docker-system`, `test-podman`,
  `test-podman-system`, `inspect`, `save`, `save-system`, `show-tags`,
  `show-tags-system`, `tag-version`, `tag-latest`, `tag-system`,
  `tag-latest-system`, `clean`, `compress`.
- Docker convenience aliases: `docker-pull`, `docker-pull-system`,
  `docker-build`, `docker-build-system`, `docker-run`, `docker-run-system`.
- Podman convenience aliases: `podman-pull`, `podman-pull-system`,
  `podman-build`, `podman-build-system`, `podman-run`, `podman-run-system`
  with `--userns=keep-id`.
- Configurable container CLI via `CONTAINER_CLI` variable (default: nerdctl).
- GitHub Actions build workflow with multi-arch matrix and smoke test.
- GitHub Actions publish workflow with two jobs (upstream + system).
- `examples/hello_cpp/` smoke test project with CMake and Meson build files.
- LICENSE, README, and USER_GUIDE copied into image at
  `/usr/share/doc/dev-container-cpp/`.
- Comprehensive USER_GUIDE.md covering architecture, security model,
  version upgrade procedures, and design decisions.
- STM32 custom image documentation with links to STM32CubeCLT.

### Security

- Base image pinned by SHA256 digest.
- All GitHub Actions pinned by SHA digest for supply-chain security.
- `latest` tag only published on semver tags or explicit opt-in.
- `run-root` bypasses entrypoint to guarantee a true root shell.
- Passwordless sudo kept for development convenience; documented as an
  explicit design decision.
