<!-- ====================================================================== -->
<!-- USER_GUIDE.md                                                          -->
<!-- ====================================================================== -->
<!-- Copyright (c) 2025 Michael Gardner, A Bit of Help, Inc.               -->
<!-- SPDX-License-Identifier: BSD-3-Clause                                  -->
<!-- See LICENSE file in the project root.                                  -->
<!-- ====================================================================== -->

# User Guide: dev_container_cpp

**Version**: 1.0.0-rc1
**Date**: 2026-03-09
**Authors**: Michael Gardner, Claude (Anthropic), GPT (OpenAI)

---

## 0. Choosing a Dockerfile

### 0.1 Why there are two Dockerfiles

C++ projects benefit from the latest compiler features (C++20/23/26 support),
the newest static analysis tools (clang-tidy checks), and up-to-date build
systems (CMake 4.x). The upstream image provides these by adding the official
LLVM APT repository, Kitware's CMake repository, and vcpkg for package
management.

At the same time, some teams prefer everything from Ubuntu's apt repositories
with no external dependencies — fewer moving parts, predictable updates tied
to Ubuntu's release cycle.

Rather than declare one approach wrong, this project ships both:

| Dockerfile | Base | Compiler source | Architectures | Image name |
|------------|------|-----------------|---------------|------------|
| `Dockerfile` (default) | Ubuntu 24.04 | LLVM repo Clang 20, Kitware CMake, vcpkg | amd64, arm64 | `dev-container-cpp` |
| `Dockerfile.system` | Ubuntu 24.04 | Ubuntu apt packages only | amd64, arm64 | `dev-container-cpp-system` |

**Start with the default.** It gives you the latest C++ compiler features and
vcpkg for dependency management. Switch to `Dockerfile.system` if you prefer
Ubuntu's packaged compilers and want no external repository dependencies.

### 0.2 Supported architectures

See the architecture compatibility tables in
[README.md](README.md#supported-architectures) for a full breakdown of
component sources and versions per architecture.

Both images use Ubuntu 24.04 and support `linux/amd64` and `linux/arm64`.
Apple Silicon users can use either image for native arm64 performance.

### 0.3 What stays the same

Regardless of which Dockerfile you choose:

- The same `entrypoint.sh` handles runtime user adaptation.
- The same `.zshrc` provides the container-aware prompt.
- The same `examples/hello_cpp/` smoke test works in both images.
- All three deployment environments (rootless nerdctl, rootful Docker,
  Kubernetes) are supported.

### 0.4 Embedded development

Both images include the ARM Cortex-M cross-compiler (`arm-none-eabi-gcc`),
OpenOCD, stlink-tools, and gdb-multiarch for embedded STM32 development. For
ST's proprietary tools (STM32CubeCLT, STM32CubeMX), see the "STM32 Custom
Image" section in [README.md](README.md#stm32-custom-image).

---

## 1. Prerequisites

### 1.1 Primary runtime: nerdctl + containerd (rootless)

This is the default development runtime. Install nerdctl and containerd
following the [nerdctl documentation](https://github.com/containerd/nerdctl).

### 1.2 Optional: Docker Engine (rootful testing)

Docker Engine is required for `make test-docker` and rootful testing.

```bash
# Ubuntu 24.04
sudo apt-get update
sudo apt-get install -y docker.io docker-buildx

# Add your user to the docker group.
sudo usermod -aG docker "$USER"

# Apply the group change — log out and back in.
# Verify after re-login.
docker --version
docker buildx version
```

> **Do not use `newgrp docker`** as a shortcut to apply the group change.
> It sets `docker` as the primary GID, which breaks Podman's `newuidmap`
> if Podman is also installed. A full logout/login picks up `docker` as a
> supplementary group and avoids this conflict.

Docker Engine coexists safely with rootless nerdctl/containerd. Docker runs
a system-level containerd at `/run/containerd/containerd.sock`, while rootless
nerdctl runs a user-space containerd at `~/.local/share/containerd/`. They use
separate storage and do not conflict.

### 1.3 Optional: Podman (rootless testing)

Podman is required for `make test-podman`.

```bash
# Ubuntu 24.04
sudo apt-get update
sudo apt-get install -y podman
```

Podman rootless requires `crun` and `fuse-overlayfs`:

```bash
sudo apt-get install -y crun
```

Configure Podman to use `crun` and `fuse-overlayfs`:

```ini
# ~/.config/containers/containers.conf
[engine]
runtime = "crun"
```

```ini
# ~/.config/containers/storage.conf
[storage]
driver = "overlay"

[storage.options.overlay]
mount_program = "/usr/local/bin/fuse-overlayfs"
```

> **Known limitation**: Podman's `--userns=keep-id` requires kernel support
> for unprivileged private mounts. This does not work in Parallels Desktop
> VMs due to kernel restrictions on mount propagation. Testing on bare-metal
> Ubuntu or non-Parallels VMs is pending. See §14 for testing status.

---

## 2. Design Goals

1. **One image, any developer** — a pre-built image from GHCR works for any
   developer without rebuilding. User identity is provided at run time, not
   baked in at build time.
2. **Bind-mounted source** — the developer's host project directory is
   mounted into the container. Edits inside the container are live on the host.
3. **Correct file permissions** — the container process runs with the host
   user's UID/GID so that bind-mounted files are readable and writable.
4. **Works in all three target environments** — local rootless nerdctl, local
   rootful Docker, and Kubernetes.
5. **Secure by default** — non-root inside the container in rootful runtimes.
   In rootless runtimes, container UID 0 is already unprivileged on the host.

---

## 3. Architecture: Runtime-Adaptive User

The image ships with a **generic fallback user** (`dev:1000:1000`) for CI and
Kubernetes. At run time, the **entrypoint script** reads host identity from
environment variables and creates or adapts the in-container user to match.

```
Host                          Container
─────                         ─────────
$(whoami)  → HOST_USER  ───→  entrypoint.sh creates user
$(id -u)   → HOST_UID   ───→  with matching UID
$(id -g)   → HOST_GID   ───→  and matching GID
$(pwd)     → -v mount   ───→  /workspace (bind mount)
```

---

## 4. File Inventory

```
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
└── USER_GUIDE.md          ← this file
```

---

## 5. Dockerfile Design

### 5.1 Upstream image (`Dockerfile`)

The upstream image adds three external repositories to Ubuntu 24.04:

1. **LLVM APT repository** (`apt.llvm.org`): Provides the latest Clang/LLVM
   toolchain (Clang 20), including clangd, clang-tidy, clang-format, LLDB,
   LLD, and libc++.

2. **Kitware APT repository** (`apt.kitware.com`): Provides the latest CMake
   (4.x series), which includes the newest generator features and presets
   support.

3. **vcpkg** (git clone from GitHub): C++ package manager with CMake-native
   integration and 2300+ packages. Installed at `/opt/vcpkg` with
   `VCPKG_ROOT` set in the environment.

Both GPG keys use the `signed-by` pattern for secure repository verification.

### 5.2 System image (`Dockerfile.system`)

The system image installs everything from Ubuntu's apt repositories. No
external package repositories are added. This provides:

- GCC 13 and Clang 18 from Ubuntu 24.04 packages
- CMake 3.28 from Ubuntu packages
- Catch2 v3 from Ubuntu packages

### 5.3 Shared design

Both images share these design elements:

- Base image pinned by SHA256 digest for reproducibility.
- `ENV HOME` set before `ENV PATH` to ensure correct `${HOME}` resolution.
- `SHELL ["/bin/bash", "-o", "pipefail", "-c"]` for safe pipe handling.
- `update-alternatives` for unversioned compiler symlinks (`clang` → versioned
  binary, `gcc` → `gcc-13`, etc.).
- Build-time user (`dev:1000:1000`) as fallback for CI and Kubernetes.
- LICENSE, README, and USER_GUIDE copied into image at
  `/usr/share/doc/dev-container-cpp/`.
- Entrypoint-based runtime user adaptation.

---

## 6. Entrypoint Script (entrypoint.sh)

### 6.1 Responsibilities

1. Export container-detection environment variables (`IN_CONTAINER=1`,
   `CONTAINER_RUNTIME`) so that `.zshrc` can detect the container environment
   reliably without inspecting `/proc` or sentinel files.
2. Read `HOST_USER`, `HOST_UID`, `HOST_GID` from environment.
3. If they are set and the entrypoint is running as root:
   a. Create a group with the given GID (if it does not exist).
   b. Create or adapt a user with the given username, UID, GID, home
      directory, and shell.
   c. Copy the default `.zshrc` into the new home if it does not exist.
   d. Set ownership on the home directory.
   e. Detect whether the runtime is rootless or rootful.
   f. If rootful: drop privileges via `gosu` and exec the CMD.
   g. If rootless: stay as UID 0 (which is the host user), set
      `HOME=/home/$HOST_USER`, and exec the CMD.
4. If `HOST_*` vars are not set, fall through to the default user (`dev`)
   and exec the CMD directly.

### 6.2 Rootless detection

The entrypoint detects rootless mode by checking whether UID 0 inside the
container maps to a non-root UID on the host:

```bash
is_rootless() {
    if [ -f /proc/self/uid_map ]; then
        local host_uid
        host_uid=$(awk '/^\s*0\s/ { print $2 }' /proc/self/uid_map)
        [ "$host_uid" != "0" ]
    else
        return 1
    fi
}
```

### 6.3 Privilege drop decision

```
if running as UID 0:
    if HOST_USER/HOST_UID/HOST_GID provided:
        create/adapt user
        if rootless:
            # Container UID 0 == host user. Dropping to HOST_UID would
            # map to an unmapped subordinate UID and break bind mounts.
            export HOME=/home/$HOST_USER
            exec "$@"                          # stay UID 0
        else (rootful):
            exec gosu "$HOST_USER" "$@"        # drop to real user
    else:
        # No host identity. Fall through to default user.
        exec gosu dev "$@"
else:
    # Already non-root (e.g., K8s securityContext). Just run.
    exec "$@"
fi
```

### 6.4 Error handling

- If `HOST_UID` is set but `HOST_USER` is not, default `HOST_USER` to `dev`.
- If `HOST_GID` is not set, default to the value of `HOST_UID`.
- The entrypoint must never prevent the container from starting.
- If user/group creation fails (e.g., UID conflict), the fallback is
  deterministic and depends on the runtime:
  - **Rootless**: log a warning, stay as UID 0 (which is the host user),
    set `HOME` to the fallback user's home (`/home/dev`), and exec the CMD.
  - **Rootful**: log a warning, drop to the fallback user via `gosu dev`,
    and exec the CMD.

---

## 7. Container Detection (.zshrc)

The entrypoint script exports `IN_CONTAINER=1` and `CONTAINER_RUNTIME` as
environment variables before exec'ing the shell. The `.zshrc` checks these
directly:

```bash
# Container detection — trust the entrypoint marker first
if [[ -n "$IN_CONTAINER" ]] && (( IN_CONTAINER )); then
    :
elif [[ -f /.dockerenv ]]; then
    ...existing fallback checks...
fi
```

The existing fallback checks (`/.dockerenv`, `/run/.containerenv`,
`/proc/1/cgroup`) are kept for cases where the `.zshrc` is used outside this
image.

---

## 8. Security Model Summary

| Runtime             | Container UID 0 is... | Bind mount access via... | Security boundary        |
|---------------------|-----------------------|--------------------------|--------------------------|
| Docker rootful      | Real root (dangerous) | gosu drop to HOST_UID    | Container isolation      |
| nerdctl rootless    | Host user (safe)      | Stay UID 0 (= host user) | User namespace           |
| Podman rootless     | Host user (safe)      | --userns=keep-id         | User namespace           |
| Kubernetes          | Blocked by policy     | fsGroup in pod spec      | Pod security standards   |

---

## 9. Resolved Questions

1. **Build systems**: CMake + Ninja + Meson + Make. GPRbuild is Ada-only
   and not needed in a pure C++ container. **Decided.**

2. **Package manager**: vcpkg (upstream image only). CMake-native
   integration, no Python dependency, 2300+ packages. **Decided.**

3. **Embedded tools**: arm-none-eabi-gcc, OpenOCD, stlink-tools, gdb-multiarch
   included in both images. STM32Cube tools excluded (GUI-based, require ST
   login); documented as custom image option. **Decided.**

4. **gosu vs su-exec**: `gosu` — more common in Docker ecosystems, available
   in Ubuntu apt. **Decided.**

5. **Container detection**: Entrypoint exports `IN_CONTAINER=1` and
   `CONTAINER_RUNTIME` as environment variables. `.zshrc` checks those first,
   with existing sentinel/cgroup checks as fallback. **Decided.**

6. **Workspace path**: `/workspace` — fixed mount point, decoupled from
   username. **Decided.**

7. **Configurable container CLI**: `CONTAINER_CLI ?= nerdctl` with
   `docker-run` / `docker-build` as convenience aliases. **Decided.**

8. **Podman support**: Added `podman-build` and `podman-run` targets.
   `podman-run` uses `--userns=keep-id` instead of `HOST_*` environment
   variables. **Decided.**

9. **sudo + passwordless sudo**: Kept intentionally for development
   convenience. In rootless runtimes, container UID 0 is already
   unprivileged on the host. **Decided.**

## 10. Remaining Open Questions

None at this time.

---

## 11. CI Workflow Design

### 11.1 docker-build.yml

Matrix build with two entries (upstream, system), both multi-arch:

- Builds with `docker buildx build --platform linux/amd64,linux/arm64`
- Loads amd64 image for smoke test (`--load` only supports single platform)
- Smoke test compiles `examples/hello_cpp` with CMake + Ninja and verifies
  toolchain versions

### 11.2 docker-publish.yml

Two parallel jobs:

- `publish-upstream`: Builds and pushes `dev-container-cpp` for amd64+arm64
- `publish-system`: Builds and pushes `dev-container-cpp-system` for amd64+arm64

Tag scheme:
- Upstream: `latest`, `gcc-13-clang-20`, `v{tag}`
- System: `latest`, `system-gcc-13-clang-18`, `v{tag}`

All GitHub Actions are pinned by SHA digest for supply-chain security.

---

## 12. Shell Aliases (.zshrc)

The `.zshrc` provides C++ development aliases:

| Alias | Command | Description |
|-------|---------|-------------|
| `cb` | `cmake --build build` | Build with CMake |
| `cbr` | `cmake --build build --target clean && cmake --build build` | Clean rebuild |
| `ccfg` | `cmake -B build -G Ninja` | Configure CMake with Ninja |
| `cf` | `clang-format -i` | Format file in-place |
| `ct` | `ctest --test-dir build` | Run tests |
| `ctidy` | `clang-tidy` | Run clang-tidy |
| `mn` | `meson` | Meson build system |
| `nn` | `ninja` | Ninja build tool |

Plus standard git, navigation, file, and search aliases.

---

## 13. Upgrading Component Versions

### 13.1 Ubuntu base image

Both Dockerfiles pin their base image by digest for reproducibility.

```bash
nerdctl pull ubuntu:24.04
nerdctl image inspect ubuntu:24.04 \
  | python3 -c "import json,sys; d=json.load(sys.stdin); print(d[0]['RepoDigests'][0])"
# Update the FROM line in both Dockerfiles with the new digest.
```

Rebuild and test both images after updating.

### 13.2 LLVM/Clang version (upstream image)

1. Check the latest LLVM release at `https://apt.llvm.org/`.
2. Update `ARG CLANG_VERSION=XX` in `Dockerfile`.
3. Rebuild and verify: `clang --version`, `clang-tidy --version`.
4. Update the `gcc-13-clang-XX` tag in `.github/workflows/docker-publish.yml`.

### 13.3 CMake version (upstream image)

CMake is installed from Kitware's APT repository, which always provides the
latest stable release. Rebuilding the image picks up the newest version
automatically.

### 13.4 vcpkg (upstream image)

vcpkg is installed via `git clone` without `--depth 1`, so rebuilding pulls
the latest version. To pin a specific version, add a `git checkout <commit>`
step after the clone.

### 13.5 GCC version

The GCC version is determined by Ubuntu's `gcc-13` package. To upgrade, wait
for Ubuntu to ship a newer `gcc-*` package, then update the `apt-get install`
and `update-alternatives` lines in both Dockerfiles.

### 13.6 System Clang version

The system Clang version is determined by Ubuntu's `clang-18` package. To
upgrade, update the `apt-get install` and `update-alternatives` lines in
`Dockerfile.system`. Update the `system-gcc-13-clang-XX` tag in
`.github/workflows/docker-publish.yml` to match.

### 13.7 ARM cross-compiler

The ARM cross-compiler (`gcc-arm-none-eabi`) is installed from Ubuntu's apt
repository. Version updates come with Ubuntu package updates.

### 13.8 Checklist

- [ ] Update version numbers / digests in all files listed above.
- [ ] Rebuild the upstream image: `make build-no-cache`.
- [ ] Rebuild the system image: `make build-system-no-cache`.
- [ ] Run each image and verify toolchain versions.
- [ ] Commit, tag, and push.

---

## 14. Pre-Release Testing Status

This section tracks testing gaps that should be resolved before the next
release. Remove or update entries as they are verified.

### Upstream toolchain image (`Dockerfile`)

| Area                              | Status       | Notes                                                        |
|-----------------------------------|--------------|--------------------------------------------------------------|
| Rootless nerdctl (local)          | Verified     | Ubuntu 24.04 base, nerdctl. Build + smoke test passed.       |
| Docker rootful (macOS)            | Pending      | Not yet tested.                                              |
| GitHub Actions build workflow     | Pending      | Not yet tested (no push to GitHub yet).                      |
| GitHub Actions publish workflow   | Pending      | Not yet tested (no push to GitHub yet).                      |
| Podman rootless (local)           | Blocked      | `--userns=keep-id` fails in Parallels VM (kernel restriction). |
| Kubernetes deployment             | Not tested   | Image is designed to be compatible; no cluster available.    |

### System toolchain image (`Dockerfile.system`)

| Area                              | Status       | Notes                                                        |
|-----------------------------------|--------------|--------------------------------------------------------------|
| Rootless nerdctl (local)          | Verified     | Ubuntu 24.04 base, nerdctl. Build + smoke test passed.       |
| Docker rootful (macOS)            | Pending      | Not yet tested.                                              |
| GitHub Actions build workflow     | Pending      | Not yet tested (no push to GitHub yet).                      |
| GitHub Actions publish workflow   | Pending      | Not yet tested (no push to GitHub yet).                      |
| Podman rootless (local)           | Blocked      | `--userns=keep-id` fails in Parallels VM (kernel restriction). |
| Kubernetes deployment             | Not tested   | Image is designed to be compatible; no cluster available.    |

---

Copyright (c) 2025 Michael Gardner, A Bit of Help, Inc.
SPDX-License-Identifier: BSD-3-Clause
