# dev_container_cpp

[![Build](https://github.com/abitofhelp/dev_container_cpp/actions/workflows/docker-build.yml/badge.svg)](https://github.com/abitofhelp/dev_container_cpp/actions/workflows/docker-build.yml)
[![Publish](https://github.com/abitofhelp/dev_container_cpp/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/abitofhelp/dev_container_cpp/actions/workflows/docker-publish.yml)
[![License: BSD-3-Clause](https://img.shields.io/badge/License-BSD--3--Clause-blue.svg)](LICENSE)
[![GCC](https://img.shields.io/badge/GCC-13-6f42c1)](#pre-installed-tools)
[![Clang](https://img.shields.io/badge/Clang-20-6f42c1)](#pre-installed-tools)
[![Container](https://img.shields.io/badge/container-ghcr.io%2Fabitofhelp%2Fdev--container--cpp-0A66C2)](#image-names)

Professional C++ development container for desktop and embedded (ARM Cortex-M/A) development.

## Supported Architectures

Both images use Ubuntu 24.04 and support amd64 + arm64 multi-arch builds.

| Image | Base | glibc | GCC (amd64) | GCC (arm64) | Clang (amd64) | Clang (arm64) | CMake (amd64) | CMake (arm64) |
|-------|------|-------|:-----------:|:-----------:|:-------------:|:-------------:|:-------------:|:-------------:|
| `Dockerfile` | Ubuntu 24.04 | 2.39 | 13, apt | 13, apt | 20, LLVM repo | 20, LLVM repo | 4.x, Kitware | 4.x, Kitware |
| `Dockerfile.system` | Ubuntu 24.04 | 2.39 | 13, apt | 13, apt | 18, apt | 18, apt | 3.28, apt | 3.28, apt |

### Upstream Image: Component Sources

| Component | Source | amd64 | arm64 | Version |
|-----------|--------|:-----:|:-----:|---------|
| Base | Ubuntu 24.04 | Y | Y | glibc 2.39 |
| GCC/G++ | apt | Y | Y | 13 |
| Clang/LLVM | apt.llvm.org | Y | Y | 20 |
| clangd | apt.llvm.org | Y | Y | 20 |
| clang-tidy | apt.llvm.org | Y | Y | 20 |
| clang-format | apt.llvm.org | Y | Y | 20 |
| LLDB | apt.llvm.org | Y | Y | 20 |
| CMake | Kitware apt repo | Y | Y | latest (4.x) |
| Ninja | apt | Y | Y | system |
| Meson | apt | Y | Y | system |
| vcpkg | git clone + bootstrap | Y | Y | latest |
| GDB | apt | Y | Y | system |
| arm-none-eabi-gcc | apt | Y | Y | 13.2 |
| arm-linux-gnueabihf-gcc | apt | Y | Y | system |
| gdb-multiarch | apt | Y | Y | system |
| OpenOCD | apt | Y | Y | system |
| stlink-tools | apt | Y | Y | system |
| cppcheck | apt | Y | Y | system |
| ccache | apt | Y | Y | system |
| Valgrind | apt | Y | Y | system |

### System Image: Component Sources

| Component | Source | amd64 | arm64 | Version |
|-----------|--------|:-----:|:-----:|---------|
| Base | Ubuntu 24.04 | Y | Y | glibc 2.39 |
| GCC/G++ | apt | Y | Y | 13 |
| Clang/LLVM | apt | Y | Y | 18 |
| clangd | apt | Y | Y | 18 |
| clang-tidy | apt | Y | Y | 18 |
| clang-format | apt | Y | Y | 18 |
| LLDB | apt | Y | Y | 18 |
| CMake | apt | Y | Y | 3.28 |
| Ninja | apt | Y | Y | system |
| Meson | apt | Y | Y | system |
| Catch2 | apt | Y | Y | v3 |
| GDB | apt | Y | Y | system |
| arm-none-eabi-gcc | apt | Y | Y | 13.2 |
| arm-linux-gnueabihf-gcc | apt | Y | Y | system |
| gdb-multiarch | apt | Y | Y | system |
| OpenOCD | apt | Y | Y | system |
| stlink-tools | apt | Y | Y | system |
| cppcheck | apt | Y | Y | system |
| ccache | apt | Y | Y | system |
| Valgrind | apt | Y | Y | system |

### Verified Test Matrix

| Image | Ubuntu VM (amd64) | macOS Intel (amd64) | MacBook Pro (arm64) |
|-------|:---:|:---:|:---:|
| `dev-container-cpp` | Passed | Passed | Passed |
| `dev-container-cpp-system` | Passed | Passed | Passed |

## Image Names

```text
ghcr.io/abitofhelp/dev-container-cpp          # Upstream toolchains (default)
ghcr.io/abitofhelp/dev-container-cpp-system   # System toolchain (alternate)
```

## Choosing a Dockerfile

This repository ships two Dockerfiles representing two valid toolchain strategies:

| Dockerfile | Base | Compiler source | Architectures | Image name |
|------------|------|-----------------|---------------|------------|
| `Dockerfile` (default) | Ubuntu 24.04 | LLVM repo Clang 20, Kitware CMake, vcpkg | amd64, arm64 | `dev-container-cpp` |
| `Dockerfile.system` | Ubuntu 24.04 | Ubuntu apt packages only | amd64, arm64 | `dev-container-cpp-system` |

**Which should I use?** The deciding factor is **supply chain auditability**.
The system image installs everything from Ubuntu's apt repositories — every
binary is built, signed, and distributed by Canonical. Use it when your
organization requires auditable supply chains with no third-party repositories.
The default image adds LLVM, Kitware, and vcpkg repositories for the latest
tooling. See USER_GUIDE §0 for detailed rationale.

## Why This Container Is Useful

This container provides a reproducible C++ development environment that adapts
to the host user at runtime. Any developer can pull the pre-built image and
run it without rebuilding.

The included `.zshrc` detects when it is running inside a container and
visibly marks the prompt, which helps prevent common mistakes:

- editing files in the wrong terminal
- confusing host and container environments
- forgetting which compiler or toolchain path is active
- debugging UID, GID, or mount issues more slowly than necessary

Example prompt:

```text
parallels@container /workspace (main) [ctr:rootless]
❯
```

## Features

- Multi-architecture support (`linux/amd64` + `linux/arm64`) for both images
- Two Dockerfile variants: upstream toolchains and system-only toolchains
- Desktop C/C++ development (GCC 13, Clang 20 or 18)
- Embedded C/C++ development:
  - ARM Cortex-M bare-metal (STM32F769I and similar)
  - ARM Cortex-A Linux cross-compilation (STM32MP135F and similar)
- Build systems: CMake, Ninja, Meson, Make
- Package management: vcpkg (upstream image only)
- Static analysis: clang-tidy, clang-format, cppcheck
- Language server: clangd
- Debuggers: GDB, LLDB, Valgrind, gdb-multiarch
- Build acceleration: ccache
- Python 3 + venv
- Zsh interactive shell
- Runtime-adaptive user identity (no rebuild needed per developer)
- Container-aware shell prompt
- Designed for nerdctl + containerd (rootless)
- Also works with Docker (rootful), Podman (rootless), and Kubernetes
- GitHub Actions for build verification and container publishing (both variants)
- Makefile for common build and run targets (both variants)

## Pre-installed Tools

Both images ship the same set of developer tools. The C++ toolchain versions
differ (upstream LLVM vs Ubuntu system packages), but all other tools are
identical.

| Category | Tools |
|----------|-------|
| **C++ compilers** | gcc, g++, clang, clang++ |
| **Build systems** | cmake, ninja, meson, make |
| **Package manager** | vcpkg (upstream image only) |
| **Language server** | clangd |
| **Static analysis** | clang-tidy, clang-format, cppcheck |
| **Build acceleration** | ccache |
| **Debuggers / profiling** | gdb, lldb, valgrind, strace, gcov, gcov-tool |
| **Embedded (bare-metal)** | arm-none-eabi-gcc, libnewlib-arm-none-eabi, gdb-multiarch, openocd, stlink-tools |
| **Embedded (Linux cross)** | arm-linux-gnueabihf-gcc, libc6-dev-armhf-cross |
| **Testing** | Catch2 (system image via apt; upstream image via vcpkg) |
| **Compiler infrastructure** | ld, lld, as, ar, nm, objcopy, objdump, ranlib, readelf, size, strings, strip, addr2line |
| **Version control** | git, patch, openssh-client (ssh, scp) |
| **Text processing** | awk, sed, grep, diff, find, xargs, sort, uniq, wc, head, tail, tr, cut, tee |
| **Network** | curl, wget, rsync |
| **Archives** | tar, zip, unzip, xz, gzip, bzip2 |
| **Editors** | vim, nano |
| **Pagers / utilities** | less, more, file, which, lsof, ps, jq |
| **Search** | ripgrep (rg), fd-find (fdfind), fzf |
| **Python** | python3, pip3, python3-venv |
| **Shell** | zsh (default), bash, zsh-autosuggestions, zsh-syntax-highlighting |
| **Container** | gosu, sudo |

## Embedded Board Support

Both images include toolchains for two embedded development workflows:

| Board | SoC | Core | Runtime | Cross-compiler |
|-------|-----|------|---------|----------------|
| STM32F769I Discovery | STM32F769NI | Cortex-M7 | Bare metal | `arm-none-eabi-gcc` |
| STM32MP135F Discovery | STM32MP135F | Cortex-A7 | Linux | `arm-linux-gnueabihf-gcc` |

The bare-metal toolchain includes OpenOCD, stlink-tools, and gdb-multiarch for
flashing and debugging. The Linux cross-compiler includes the full sysroot
(`libc6-dev-armhf-cross`) for building Linux userspace applications.

### Embedded Toolchain Readiness

Both images are fully self-contained for all three targets. No additional
downloads or toolchain installation is required.

| Target | Compiler | Status |
|--------|----------|--------|
| Desktop (native) | `g++` / `clang++` | Pre-installed |
| STM32F769I — Cortex-M7 bare-metal | `arm-none-eabi-g++` | Pre-installed |
| STM32MP135F — Cortex-A7 Linux | `arm-linux-gnueabihf-g++` | Pre-installed |

## STM32 Custom Image

For projects that require ST's proprietary tools, developers can build a custom
image on top of these base images.

ST provides a command-line installer (STM32CubeCLT) that bundles their
toolchain, STM32CubeProgrammer, and build integration:

- [STM32CubeCLT](https://www.st.com/en/development-tools/stm32cubeclt.html) — headless CLI toolchain
- [STM32CubeMX](https://www.st.com/en/development-tools/stm32cubemx.html) — project generator (GUI-based)

These tools require an ST account to download and cannot be automatically
fetched in a Dockerfile. To build a custom image:

1. Download the STM32CubeCLT Linux installer from the link above.
2. Create a `Dockerfile.stm32` that extends one of the base images:
   ```dockerfile
   FROM dev-container-cpp:latest
   COPY STM32CubeCLT_*.sh /tmp/
   RUN chmod +x /tmp/STM32CubeCLT_*.sh && \
       /tmp/STM32CubeCLT_*.sh --mode unattended && \
       rm /tmp/STM32CubeCLT_*.sh
   ```
3. Build: `nerdctl build -f Dockerfile.stm32 -t dev-container-cpp-stm32 .`

---

## Quick Start

### Pull a pre-built image

```bash
# Default (upstream toolchains)
make pull

# System toolchain alternative
make pull-system
```

### Build from source

```bash
# Default (upstream toolchains)
make build

# System toolchain alternative
make build-system
```

### Run

```bash
# Default
cd ~/projects/my_cpp_app
make -f /path/to/dev_container_cpp/Makefile run

# System toolchain alternative
make -f /path/to/dev_container_cpp/Makefile run-system
```

> **Note**: When using `make -f`, the Makefile mounts the caller's current
> directory (not the Makefile's directory) into the container. This is
> intentional — it bind-mounts your project, not the container repository.

The current directory is mounted into the container at `/workspace`. The
entrypoint adapts the container's home directory layout to match your host
user, so bind-mounted files are readable and writable.

### Inspect configured values

```bash
make inspect
```

## Manual Build

```bash
# Default (upstream toolchains)
nerdctl build -t dev-container-cpp .

# System toolchain alternative
nerdctl build -f Dockerfile.system -t dev-container-cpp-system .
```

## Manual Run

```bash
# Default (upstream toolchains)
nerdctl run -it --rm \
  -e HOST_UID=$(id -u) \
  -e HOST_GID=$(id -g) \
  -e HOST_USER=$(whoami) \
  -v "$(pwd)":/workspace \
  -w /workspace \
  dev-container-cpp

# System toolchain alternative
nerdctl run -it --rm \
  -e HOST_UID=$(id -u) \
  -e HOST_GID=$(id -g) \
  -e HOST_USER=$(whoami) \
  -v "$(pwd)":/workspace \
  -w /workspace \
  dev-container-cpp-system
```

## Use Docker or Podman Instead of nerdctl

All Makefile targets use `CONTAINER_CLI`, which defaults to `nerdctl`. Override
it to use Docker or Podman:

```bash
make build CONTAINER_CLI=docker
make run CONTAINER_CLI=docker
```

Or use the convenience aliases:

```bash
make docker-build
make docker-run

make podman-build
make podman-run
```

Podman rootless uses `--userns=keep-id` to map the host user directly into the
container without needing the `HOST_*` environment variables or entrypoint
adaptation. Podman requires `crun` and `fuse-overlayfs`. The `--userns=keep-id`
flag requires kernel support for unprivileged private mounts (see User Guide
for details and known VM limitations).

## Housekeeping

Remove build artifacts (saved images, source archives):

```bash
make clean
```

Create a compressed source archive from the current HEAD:

```bash
make compress
```

## Deployment Environments

This image supports three deployment environments with a single build.

### Local Development (nerdctl rootless)

This is the primary workflow. `make run` passes the host identity and mounts
the current directory:

```bash
cd ~/projects/my_cpp_app
make run
```

The entrypoint sets up the home directory layout to match your host identity.
In rootless mode, the process stays as container UID 0 (which maps to the host
user via the user namespace) for bind-mount correctness. This is safe — no
privilege escalation is possible.

### CI / Docker Rootful

The image runs as the fallback non-root user (`dev:1000:1000`) by default when
no `HOST_*` environment variables are passed. GitHub Actions workflows build
and publish the image using Docker.

### Kubernetes

The image is compatible with Kubernetes out of the box. Source code is
provisioned via PersistentVolumeClaims or init containers (e.g., git-sync),
not bind mounts.

Example pod spec:

```yaml
securityContext:
  runAsUser: 1000
  runAsGroup: 1000
  fsGroup: 1000
  runAsNonRoot: true
containers:
  - name: cpp-dev
    image: ghcr.io/abitofhelp/dev-container-cpp:latest
    workingDir: /workspace
    volumeMounts:
      - name: source
        mountPath: /workspace
volumes:
  - name: source
    persistentVolumeClaim:
      claimName: cpp-source
```

`fsGroup: 1000` ensures the volume is writable by the container user.
Kubernetes manifests and Helm charts are not included in this repository.
Teams should create these per their cluster policies.

## Rootless Security

In rootless container runtimes (nerdctl/containerd rootless, Podman rootless),
the container runs inside a user namespace where container UID 0 maps to the
unprivileged host user. The process cannot escalate beyond the host user's
privileges. The entrypoint script detects this and avoids dropping privileges,
because doing so would map the process to a subordinate UID that cannot access
bind-mounted host files.

| Runtime          | Container UID 0 is...  | Bind mount access via...  | Security boundary      |
|------------------|------------------------|---------------------------|------------------------|
| Docker rootful   | Real root (dangerous)  | gosu drop to HOST_UID     | Container isolation    |
| nerdctl rootless | Host user (safe)       | Stay UID 0 (= host user)  | User namespace         |
| Podman rootless  | Host user (safe)       | --userns=keep-id          | User namespace         |
| Kubernetes       | Blocked by policy      | fsGroup in pod spec       | Pod security standards |

## Version Tags

### Default image (upstream toolchains)

```text
ghcr.io/abitofhelp/dev-container-cpp:latest
ghcr.io/abitofhelp/dev-container-cpp:gcc-13-clang-20
```

### System toolchain image

```text
ghcr.io/abitofhelp/dev-container-cpp-system:latest
ghcr.io/abitofhelp/dev-container-cpp-system:system-gcc-13-clang-18
```

The included publish workflow automatically creates tags in these styles.

## GitHub Actions

This repository includes:

- `docker-build.yml` to verify both Dockerfiles on every push and pull request
  (matrix build: upstream + system variants, both multi-arch)
- `docker-publish.yml` to publish both images to GitHub Container Registry
  (two jobs: `publish-upstream` + `publish-system`)
- automatic tagging based on compiler versions
- all actions pinned by SHA digest for supply-chain security

## Repository Layout

```text
dev_container_cpp/
├── .dockerignore
├── .github/
│   └── workflows/
│       ├── docker-build.yml
│       └── docker-publish.yml
├── .gitignore
├── .zshrc
├── CHANGELOG.md
├── Dockerfile              ← upstream toolchains (Clang 20, CMake 4.x, vcpkg)
├── Dockerfile.system       ← system toolchain (Clang 18, CMake 3.28)
├── entrypoint.sh
├── examples/
│   └── hello_cpp/
├── LICENSE
├── Makefile
├── README.md
└── USER_GUIDE.md
```

## License

BSD-3-Clause — see `LICENSE`.

## AI Assistance and Authorship

This project was developed by Michael Gardner with AI assistance from Claude
(Anthropic) and GPT (OpenAI). AI tools were used for design review,
architecture decisions, and code generation. All code has been reviewed and
approved by the human author. The human maintainer holds responsibility for
all code in this repository.
