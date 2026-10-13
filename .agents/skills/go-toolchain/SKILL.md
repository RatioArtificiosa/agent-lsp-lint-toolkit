---
name: go-toolchain
description: Install and verify the Go language toolchain (gopls, gofmt). Use when Go symbols are missing or formatting does not run.
---

# Go Toolchain

`gofmt` ships inside the Go toolchain. `gopls` does not, and it is the piece most
often missing.

## Install

```bash
go install golang.org/x/tools/gopls@latest
```

Make sure `GOBIN` is on `PATH`, otherwise the binary installs somewhere unreachable.

## Verify

```bash
gopls version
gofmt --help
```

## Known trap

`gopls` needs a `go.mod` to load the package graph. Without one it has nothing to
index, which looks like the server being broken when the project is simply not a
module yet.
