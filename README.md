<div align="center">

# Agent LSP Lint Toolkit

[![CI](https://github.com/RatioArtificiosa/agent-lsp-lint-toolkit/actions/workflows/ci.yml/badge.svg)](https://github.com/RatioArtificiosa/agent-lsp-lint-toolkit/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platforms](https://img.shields.io/badge/platforms-Windows%20%7C%20macOS%20%7C%20Linux-blue.svg)](#-get-started-in-five-minutes)
[![Node](https://img.shields.io/badge/node-18%2B-brightgreen.svg)](https://nodejs.org/)

**Your AI coding agent is only as good as the tools behind it. This toolkit makes those tools work.**

[Get started](#-get-started-in-five-minutes) ·
[User Guide](USER-GUIDE.md) ·
[Contributing](CONTRIBUTING.md)

</div>

---

Your agent writes code. Then it needs three things: to understand the code it just wrote, to format it correctly, and to tell you when its own setup is not right. Most agents struggle with all three, not because the model is weak, but because the tools it depends on are missing, misconfigured, or failing without telling you.

This toolkit fixes that. It gives your agent working language servers, automatic formatting, and a way to check its own toolchain. One install, five minutes, seven languages.

## What changes on day one

> [!TIP]
> **Your agent stops guessing what code means.** It can jump to definitions, see types on hover, and list every symbol in a file. That is the difference between an agent that understands your project and one that greps around hoping for the best.

> [!TIP]
> **Formatting stops being your problem.** Every file your agent writes comes out formatted. Not sometimes. Every time. You never review whitespace again.

> [!TIP]
> **Unhealthy setups diagnose themselves.** When something is missing, your agent finds out what, and what command fixes it, instead of failing in confusing ways.

## The languages

| Language                | Code intelligence   | Formatting              |
| :---------------------- | :-----------------: | :---------------------: |
| Rust                    |         Yes         | Yes, plus lint guidance |
| Python                  |         Yes         |           Yes           |
| Go                      |         Yes         |           Yes           |
| C / C++                 |         Yes         |           Yes           |
| TypeScript / JavaScript |         Yes         |           Yes           |
| Zig                     |         Yes         |           Yes           |
| AssemblyScript          | Through TypeScript  |           Yes           |

## Get started in five minutes

Pick the installer for your machine. Each one checks what you already have before it installs anything, and you can run it again any time.

<details open>
<summary><b>Windows</b> (PowerShell)</summary>

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

</details>

<details open>
<summary><b>Linux or macOS</b></summary>

```bash
sh install.sh
```

</details>

<details open>
<summary><b>Any machine with Python 3</b></summary>

```bash
python3 install.py
```

</details>

Then confirm everything works:

```bash
node --check mcp/server.mjs
node mcp/test/client.mjs
```

> [!IMPORTANT]
> That last command must report zero failures. If it does not, the output tells you exactly what is missing.

## Go deeper

| Guide | What it covers |
| :---- | :------------- |
| **[User Guide](USER-GUIDE.md)** | How each piece works, what each language needs, the full troubleshooting table, and what the proxy does and does not do. Written so a beginner can follow it and an expert will not roll their eyes. |
| **[Contributing](CONTRIBUTING.md)** | How to add a language, fix a bug, or improve the docs. Small proven changes beat big speculative ones. |

## One honest paragraph

This toolkit cannot write good code for you. It cannot replace tests, code review, or judgment. What it does is remove an entire category of avoidable failures: the missing server, the unformatted file, the mystery error that turns out to be a version mismatch. Your agent gets a workspace where the basics work, so its effort goes into your actual problem.

---

<div align="center">

*One install, five minutes, seven languages.*

</div>
