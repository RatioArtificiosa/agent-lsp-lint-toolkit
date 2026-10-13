---
name: zig-toolchain
description: Install and verify the Zig language toolchain (zls, zig fmt). Use when Zig symbols are missing or formatting does not run.
---

# Zig Toolchain

`zig fmt` ships with Zig. `zls` does not, and the two versions must stay paired.

## Install

Install Zig 0.16.0, then add `zls` from the zls releases (or via `zigup`).

## Verify

```bash
zls --version
zig version
```

## Known trap

`zls` needs a `build.zig` to build a module graph. It is not slow, it has nothing to
index until that file exists. Keep the zig and zls versions paired or diagnostics drift.
