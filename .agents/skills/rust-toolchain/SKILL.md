---
name: rust-toolchain
description: Install and verify the Rust language toolchain (rust-analyzer, rustfmt, clippy). Use when Rust language intelligence is missing, formatting does not run, or diagnostics mention clippy.
---

# Rust Toolchain

Installs the three separate pieces Rust development needs. They are three distinct
rustup components, not one download: the language server does not bundle the
formatter or the linter.

## Install

```bash
rustup component add rust-analyzer rustfmt clippy
```

If `rustup` itself is missing, install it first from https://rustup.rs, then run the
command above.

## Verify

```bash
rust-analyzer --version
rustfmt --version
cargo-clippy --version
```

Each must print a version. A missing binary is the common failure, and it shows up as
"command not found" rather than a useful error.

## Known trap

rust-analyzer stays silent on a directory with no `Cargo.toml` above it. It also shells
out to `cargo-clippy` as a subprocess rather than bundling it, so setting the editor to
use clippy diagnostics requires the clippy component to be installed separately.
