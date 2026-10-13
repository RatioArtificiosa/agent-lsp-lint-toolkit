#!/usr/bin/env sh
# Unix installer for the LSP lint toolkit. Idempotent and safe to re-run.
# Detects before installing, prints what it will do, and never requires sudo
# silently. Run from the repository root: sh install.sh
set -eu

say() { printf '%s\n' "$1"; }
have() { command -v "$1" >/dev/null 2>&1; }

ROOT=$(cd "$(dirname "$0")" && pwd)

say "LSP lint toolkit installer (Linux and macOS)"
say ""

need_node() {
  if have node; then
    say "  ok   node $(node --version)"
  else
    say "  MISSING node. Install Node 18 or later first, then re-run."
    exit 1
  fi
}

install_rust() {
  if have rust-analyzer && have rustfmt && have cargo-clippy; then
    say "  ok   rust-analyzer, rustfmt, clippy"
  elif have rustup; then
    say "  installing rust-analyzer rustfmt clippy via rustup"
    rustup component add rust-analyzer rustfmt clippy
  else
    say "  SKIP rust: install rustup from https://rustup.rs first"
  fi
}

install_python() {
  if have pyright-langserver && have ruff; then
    say "  ok   pyright, ruff"
  elif have python3; then
    say "  installing pyright ruff via pip"
    python3 -m pip install --user pyright ruff
  else
    say "  SKIP python: no python3 found"
  fi
}

install_go() {
  if have gopls; then
    say "  ok   gopls (gofmt ships with Go)"
  elif have go; then
    say "  installing gopls"
    go install golang.org/x/tools/gopls@latest
  else
    say "  SKIP go: no Go toolchain found"
  fi
}

install_cpp() {
  if have clangd && have clang-format; then
    say "  ok   clangd $(clangd --version 2>/dev/null | head -1), clang-format"
  else
    say "  SKIP C++: install clangd and clang-format (apt install clangd clang-format, or brew install llvm)"
  fi
}

install_ts() {
  if have typescript-language-server && have biome; then
    say "  ok   typescript-language-server, biome"
  else
    say "  installing typescript typescript-language-server biome"
    npm install -g typescript typescript-language-server @biomejs/biome
  fi
}

install_zig() {
  if have zls; then
    say "  ok   zls ($(zls --version 2>/dev/null || echo unknown))"
  else
    say "  SKIP zig: install zls from its releases, paired with your zig version"
  fi
}

need_node
install_rust
install_python
install_go
install_cpp
install_ts
install_zig

say ""
say "Toolchains done. The .agents/skills directory works with zero config in"
say "Claude Code and CommandCode. Copy hooks/format.* into your harness hooks"
say "directory and point each plugin config at lsp/lsp-open-proxy.js."
say "No launcher binary is needed on Linux or macOS."
