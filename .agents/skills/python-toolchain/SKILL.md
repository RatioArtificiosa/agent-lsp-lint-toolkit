---
name: python-toolchain
description: Install and verify the Python language toolchain (pyright, ruff). Use when Python symbols are empty, hover returns nothing, or formatting does not run.
---

# Python Toolchain

Installs the two separate packages Python development needs. They are different
packages from different vendors: the type checker does not bundle the formatter.

## Install

```bash
python -m pip install --user pyright ruff
```

On Linux and macOS, `python3 -m pip` may be the correct interpreter.

## Verify

```bash
pyright-langserver --version
ruff --version
```

## Known trap

pyright returns zero symbols for a document it was never told about. An empty symbol
list can mean the client skipped the open notification, not that the file has no
symbols. Give the server a moment after opening before re-querying.
