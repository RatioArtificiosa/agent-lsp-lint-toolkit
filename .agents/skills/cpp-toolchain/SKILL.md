---
name: cpp-toolchain
description: Install and verify the C and C++ language toolchain (clangd, clang-format). Use when C++ symbols are missing or formatting does not run.
---

# C and C++ Toolchain

Two separate installs that are often different versions: a standalone clangd and a
toolchain clang-format. They can disagree about valid syntax when skewed.

## Install

Windows (Visual Studio Installer): add the C++ Clang tools component.

```powershell
# verify after installing
clangd --version
clang-format --version
```

Linux:

```bash
sudo apt install clangd clang-format
```

macOS:

```bash
brew install llvm
```

## Verify

```bash
clangd --version
clang-format --version
```

## Known trap

`compile_commands.json` is needed for accurate include resolution, not for symbols.
Symbols work without it. Also note the extension convention this toolkit follows:
`.c` and `.h` are C, while `.C`, `.H`, `.cpp`, `.hpp` and the rest are C++.
