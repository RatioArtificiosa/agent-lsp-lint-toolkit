---
name: typescript-toolchain
description: Install and verify the TypeScript and JavaScript toolchain (typescript-language-server, biome, typescript). Use when .ts files get no hover, no symbols, or no formatting.
---

# TypeScript and JavaScript Toolchain

## Install

```bash
npm install -g typescript typescript-language-server @biomejs/biome
```

On Windows, one more step is required (see the trap below).

## Verify

```bash
typescript-language-server --version
biome --version
```

## Known trap

Two of them. First, the project needs a local `typescript`, and it must be 5.x.
TypeScript 7 removed `lib/tsserver.js`, so a bare `npm install typescript` installs a
version the server cannot drive, and the error blames a missing installation. Pin it:
`npm install --save-dev typescript@5`.

Second, on Windows, npm installs this server as `.cmd` and `.ps1` shims and never as a
`.exe`, and a no-shell spawn can only resolve `.exe`. The fix is a small launcher
binary built from `lsp/launcher.cs` with the bundled .NET compiler and installed next
to the npm package as `typescript-language-server.exe`. See `lsp/build.ps1`. Linux and
macOS need no launcher.
