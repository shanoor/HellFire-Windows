# HellFire-Windows — Agent Guidelines

Guidelines and repository context for AI coding agents working on **HellFire-Windows**.

---

## 1. Project Overview

**HellFire-Windows** is dedicated to automated building and releasing of high-performance, source-unmodified Firefox builds on Microsoft Windows (x86_64).
- **Core Goal**: Maximum performance builds using advanced compiler optimizations (`-O3`, PGO, Full LTO, `x86-64-v3` architecture targeting) without modifying Firefox source code or core web standards behavior.
- **Upstream**: Downstream/fork of [CYFARE/HellFire](https://github.com/CYFARE/HellFire). While upstream primarily targets GNU/Linux, this repository is the dedicated Windows pipeline.

---

## 2. Repository Structure

- `MozConfigs/Win64/mozconfig`: Windows-specific Firefox build configuration, optimization settings, compiler flags (`CFLAGS`, `CXXFLAGS`, `LDFLAGS`, `RUSTFLAGS`), and packaging options.
- `.github/workflows/`:
  - `build-and-release.yaml`: Main dispatch and scheduled workflow checking for new Firefox versions and orchestrating builds.
  - `template-build.yaml`: Windows build workflow running on `windows-latest` with MozillaBuild, MSVC, Rust, and sccache.
  - `template-release.yaml`: Release publisher using GitHub Releases for `.exe` installer and `.zip` portable archives.
- `release/`: Local staging directory where build artifacts (`objdir-opt/dist/`) are staged prior to upload/release.
- `Assets/` & `Benchmarks/`: Logos, branding assets, and performance benchmark data.

---

## 3. Toolchain & Build Environment

Building Firefox for Windows locally or in CI requires:
- **Git Long Paths**: `git config --system core.longpaths true`
- **MozillaBuild**: Installed at `C:/mozilla-build` (env: `MOZILLABUILD=C:/mozilla-build`, `MACH_PS1_USE_MOZILLABUILD=true`).
- **Rust Toolchain**: `stable-x86_64-pc-windows-msvc`
- **Compiler / Cache**: MSVC + LLVM/Clang integration via MozillaBuild and `sccache`.
- **Build Commands** (executed from inside the `mozilla-source/firefox` checkout):
  ```powershell
  # Copy custom mozconfig
  cp MozConfigs/Win64/mozconfig mozilla-source/firefox/.mozconfig

  # Build & package
  ./mach.cmd build
  ./mach.cmd package
  ```

---

## 4. Compiler & Optimization Rules

When editing `MozConfigs/Win64/mozconfig`:
- **Architecture Baseline**: Optimized for `x86-64-v3` (`AVX2`, `FMA`, `BMI1`, `BMI2`, `AES`). Do not downgrade flags unless diagnosing specific MSVC/LLVM compiler ICEs.
- **Optimizations**: Keep PGO enabled (`MOZ_PGO=1`), Full LTO (`--enable-lto=full`), and release configuration (`--enable-release`, `--disable-debug`, `--disable-tests`).
- **Telemetry & Services**: Maintain privacy and bloat-reduction flags (`MOZ_TELEMETRY_REPORTING=0`, `--disable-crashreporter`, `--disable-updater`).

---

## 5. Development & Agent Conventions

- **Surgical Changes**: Touch only files directly relevant to the user request. Do not format or refactor unrelated sections in workflow files or mozconfigs.
- **Git & GitButler**: This repository utilizes GitButler virtual branch management (`gitbutler/workspace`). Avoid raw destructive git operations (such as hard resets or checking out branches outside GitButler) that could disrupt the virtual branch state.
- **Windows Shell**: Use PowerShell (`pwsh`) syntax for all shell commands. When running terminal commands in pair programming sessions, prefix commands with `rtk` where applicable.
