<#
  Windows installer for the LSP lint toolkit. Idempotent and safe to re-run.
  Detects before installing, prints what it will do. Run:
    powershell -ExecutionPolicy Bypass -File install.ps1
  Must be run from the repository root. Does not change the execution policy
  outside this process.
#>

$ErrorActionPreference = "Stop"

function Have($name) {
  $null -ne (Get-Command $name -ErrorAction SilentlyContinue)
}

function Say($m) { Write-Host $m }

$root = Split-Path -Parent $MyInvocation.MyCommand.Path

Say "LSP lint toolkit installer (Windows)"
Say ""

if (-not (Have "node")) {
  Say "  MISSING node. Install Node 18 or later first, then re-run."
  exit 1
}
Say ("  ok   node " + (& node --version))

if ((Have "rust-analyzer") -and (Have "rustfmt") -and (Have "cargo-clippy")) {
  Say "  ok   rust-analyzer, rustfmt, clippy"
} elseif (Have "rustup") {
  Say "  installing rust-analyzer rustfmt clippy via rustup"
  & rustup component add rust-analyzer rustfmt clippy
} else {
  Say "  SKIP rust: install rustup from https://rustup.rs first"
}

if ((Have "pyright-langserver") -and (Have "ruff")) {
  Say "  ok   pyright, ruff"
} elseif (Have "python") {
  Say "  installing pyright ruff via pip"
  & python -m pip install --user pyright ruff
} else {
  Say "  SKIP python: no python found"
}

if (Have "gopls") {
  Say "  ok   gopls (gofmt ships with Go)"
} elseif (Have "go") {
  Say "  installing gopls"
  & go install golang.org/x/tools/gopls@latest
} else {
  Say "  SKIP go: no Go toolchain found"
}

if ((Have "clangd") -and (Have "clang-format")) {
  Say "  ok   clangd and clang-format"
} else {
  Say "  SKIP C++: add the C++ Clang tools component in the Visual Studio Installer"
}

if ((Have "typescript-language-server") -and (Have "biome")) {
  Say "  ok   typescript-language-server, biome"
} else {
  Say "  installing typescript typescript-language-server biome"
  & npm install -g typescript typescript-language-server @biomejs/biome
}

if (Have "zls") {
  Say "  ok   zls"
} else {
  Say "  SKIP zig: install zls from its releases, paired with your zig version"
}

Say ""
Say "Building the Windows launcher (lets no-shell spawns resolve typescript-language-server)..."
& powershell -ExecutionPolicy Bypass -File (Join-Path $root "lsp\build.ps1") -OutDir (npm root -g)

Say ""
Say "Done. The .agents/skills directory works with zero config in Claude Code"
Say "and CommandCode. Copy hooks/format.* into your harness hooks directory"
Say "and point each plugin config at lsp/lsp-open-proxy.js."
