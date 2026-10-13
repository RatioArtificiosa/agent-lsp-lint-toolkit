#!/usr/bin/env python3
"""Cross-platform installer for the LSP lint toolkit. Idempotent and safe.

Detects before installing, prints what it will do, and never requires sudo
silently. Run from the repository root: python3 install.py
"""

import platform
import shutil
import subprocess
import sys

WIN = platform.system() == "Windows"


def say(m):
    print(m)


def have(name):
    return shutil.which(name) is not None


def run(cmd):
    print("  $ " + " ".join(cmd))
    return subprocess.run(cmd)


def main():
    say("LSP lint toolkit installer (%s)" % platform.system())
    say("")

    if not have("node"):
        say("  MISSING node. Install Node 18 or later first, then re-run.")
        return 1
    say("  ok   node")

    if all(have(b) for b in ("rust-analyzer", "rustfmt", "cargo-clippy")):
        say("  ok   rust-analyzer, rustfmt, clippy")
    elif have("rustup"):
        say("  installing rust-analyzer rustfmt clippy via rustup")
        run(["rustup", "component", "add", "rust-analyzer", "rustfmt", "clippy"])
    else:
        say("  SKIP rust: install rustup from https://rustup.rs first")

    if have("pyright-langserver") and have("ruff"):
        say("  ok   pyright, ruff")
    else:
        py = "python" if WIN else "python3"
        if have(py):
            say("  installing pyright ruff via pip")
            run([py, "-m", "pip", "install", "--user", "pyright", "ruff"])
        else:
            say("  SKIP python: no interpreter found")

    if have("gopls"):
        say("  ok   gopls (gofmt ships with Go)")
    elif have("go"):
        say("  installing gopls")
        run(["go", "install", "golang.org/x/tools/gopls@latest"])
    else:
        say("  SKIP go: no Go toolchain found")

    if have("clangd") and have("clang-format"):
        say("  ok   clangd and clang-format")
    else:
        hint = (
            "add the C++ Clang tools component in the Visual Studio Installer"
            if WIN
            else "apt install clangd clang-format, or brew install llvm"
        )
        say("  SKIP C++: " + hint)

    if have("typescript-language-server") and have("biome"):
        say("  ok   typescript-language-server, biome")
    else:
        say("  installing typescript typescript-language-server biome")
        npm = "npm.cmd" if WIN else "npm"
        run(
            [
                npm,
                "install",
                "-g",
                "typescript",
                "typescript-language-server",
                "@biomejs/biome",
            ]
        )

    if have("zls"):
        say("  ok   zls")
    else:
        say("  SKIP zig: install zls from its releases, paired with your zig version")

    say("")
    say("Done. The .agents/skills directory works with zero config in Claude Code")
    say("and CommandCode. On Windows, also run lsp/build.ps1 to build the launcher.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
