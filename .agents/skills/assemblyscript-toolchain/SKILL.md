---
name: assemblyscript-toolchain
description: Install and verify the AssemblyScript formatting toolchain (eslint via npx). Use when .ts formatting through eslint does not run.
---

# AssemblyScript Toolchain

There is no separate language server. The TypeScript server covers `.ts` files, and
this entry exists only for the eslint-based formatter path.

## Install

```bash
npm install -g typescript-language-server @biomejs/biome eslint
```

## Verify

```bash
npx --no-install eslint --version
```

## Known trap

eslint resolves through `npx` from its cache and needs a project-local
`eslint.config.js`. Without that config it hard-fails instead of passing silently, so a
missing config looks like a broken formatter when the project is simply unconfigured.
