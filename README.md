<div align="center">

# Agent LSP & Lint Toolkit

[![CI](https://github.com/RatioArtificiosa/agent-lsp-lint-toolkit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/RatioArtificiosa/agent-lsp-lint-toolkit/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platforms](https://img.shields.io/badge/platforms-Windows%20%7C%20macOS%20%7C%20Linux-blue.svg)](#get-started)
[![Node](https://img.shields.io/badge/node-18%2B-brightgreen.svg)](https://nodejs.org/)

**Give your AI coding agent a better feedback loop.**

[Get started](#get-started) ·
[User Guide](USER-GUIDE.md) ·
[Contributing](CONTRIBUTING.md)

</div>

---

## The problem is not always the model. Sometimes it is the tools.

> Imagine it is 3:07 a.m. Your AI coding agent has refactored the same function for the third time. Each attempt looks more convincing. The bug is still there.
>
> You ask it to jump to a definition. Nothing useful comes back. A formatter that should clean up the file is not connected. A language server may be missing, using the wrong version, or failing because the agent never sent the document information it needs.
>
> The agent is trying to solve a problem without reliable feedback. Another prompt might help. But it cannot replace a working toolchain.

**This toolkit helps fix that gap.** It brings language-specific guidance, language-server compatibility fixes, formatting hooks, and toolchain diagnostics into one place, so a compatible coding agent can work with better information and spend less time repeating avoidable corrections.

It is not another AI agent. It is support infrastructure for the agent you already use.

---

## What gets better when the tools work

### 1. Your agent can navigate code instead of guessing

Language servers provide code-aware information such as hover details and go-to-definition results. The toolkit includes language-server configurations and a lightweight proxy for clients that skip document lifecycle messages some servers depend on.

That means fewer dead ends when your agent needs to understand a symbol, inspect a definition, or work through an unfamiliar part of a project. The benefit depends on your agent harness using the supplied LSP configuration and on the relevant language tools being installed.

### 2. Formatting becomes part of the normal workflow

When connected to a compatible agent's write or edit hook, the formatter hook runs the configured language tools after supported files change. Instead of relying on the model to remember every spacing, layout, or formatting rule, the project can apply those rules consistently.

The toolkit includes formatting integrations for Rust, Python, Go, C/C++, TypeScript/JavaScript, and Zig, plus language-specific guidance and checks where provided. An AssemblyScript-specific plugin configuration is also included. Each tool still needs the appropriate project setup.

### 3. You can find out what is wrong with the toolchain

An agent can make poor recommendations when it does not know what is actually installed on your machine. The MCP server gives it a way to check the environment rather than assume.

It can report which language servers and formatters are present, show resolved paths and versions, identify missing tools, and flag version mismatches that may cause problems. It can also return the relevant installation instructions and Windows launcher step.

That turns a vague problem such as the language server is not working into a more useful answer: this tool is missing, this version does not match, or this is the next command to run.

### 4. Windows-specific friction gets a practical fix

Some tools installed through npm are exposed on Windows as command shims such as `.cmd` or `.ps1`. Certain clients that start processes without a shell expect an `.exe`, so a server that works from a terminal can still fail when an agent tries to launch it.

The toolkit includes a small Windows launcher for the TypeScript language server case covered by this repository. It also includes an LSP proxy that supplies missing document lifecycle notifications for clients that need them.

These are focused compatibility fixes for specific failure modes, not a claim that every LSP issue on every platform disappears.

### 5. Your agent gets reusable language-specific guidance

The `.agents/skills/` directory contains guidance for each supported language family. The skills explain what tools are needed, how to install them, how to verify the setup, and which common project or configuration traps to watch for.

That gives compatible agents a repeatable reference instead of forcing them to rediscover the same setup details on every project.

---

## Supported language families

| Language                | Language server          | Formatting and checks        |
| :---------------------- | :----------------------- | :--------------------------- |
| Rust                    | `rust-analyzer`          | `rustfmt`, with Clippy guidance |
| Python                  | Pyright                  | Ruff                         |
| Go                      | `gopls`                  | `gofmt`                      |
| C / C++                 | `clangd`                 | `clang-format`               |
| TypeScript / JavaScript | `typescript-language-server` | Biome                    |
| Zig                     | `zls`                    | `zig fmt`                    |
| AssemblyScript          | TypeScript language server | ESLint through `npx`, with project configuration |

The exact capabilities depend on the language tools installed, the structure of your project, and how your agent harness is configured. For example, language servers may need project files such as `Cargo.toml`, `go.mod`, or a TypeScript configuration to understand the workspace correctly.

---

## One MCP server. A clearer picture of your setup.

The Model Context Protocol (MCP) lets a compatible AI client call tools through a consistent interface. This repository's MCP server focuses on the language toolchain:

- **`probe_toolchains`** checks which supported tools are available and reports their paths and versions.
- **`doctor`** summarizes toolchain gaps, version mismatches, and optional configuration checks.
- **`install_missing`** returns a plan and the commands that can address missing tools, including the Windows launcher step when relevant.
- **`language_for_file`** identifies the language family associated with a file path.
- **`readme`** makes the toolkit's own instructions available to the agent without a network lookup.

One important detail: the MCP server's repair plan is read-only. It reports what is missing and what to do next, but it does not execute installation commands or silently change your machine. You stay in control of software installation.

---

## How the pieces work together

Here is the intended workflow:

1. Your agent reads the relevant language skill and uses the language tools configured for your project.
2. Your agent edits a supported file. If the formatting hook is wired into the harness, the configured formatter or check runs as part of that workflow.
3. When code navigation is needed, the language server provides code-aware information. The proxy helps with a known lifecycle issue in clients that omit required document notifications.
4. If a tool fails or the setup looks incomplete, the agent can call the MCP server to inspect the installed toolchain and get specific next steps.

The value is not one magic command. It is a better-connected feedback loop: guidance, code intelligence, formatting, and diagnostics each do their job.

---

## Get started

Run the installer that matches your platform from the repository root. The scripts detect available tools and report their actions.

<details open>
<summary><b>Windows PowerShell</b></summary>

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
<summary><b>Python installer</b></summary>

```bash
python3 install.py
```

</details>

After installation, connect the relevant language-server configurations and formatting hooks to the agent harness you use. Copy or include the `.agents/skills/` directory in your project as appropriate for that harness.

Different agents support skills, LSP, and hooks in different ways. The toolkit provides reusable components and configurations, but one installer cannot automatically wire every possible AI coding agent.

Explore the [language skills](.agents/skills/), [agent plugin configurations](plugins/), [formatting hooks](hooks/), [LSP compatibility tools](lsp/), and [MCP server](mcp/) to see the individual pieces.

---

## A better feedback loop, with clear boundaries

The goal is practical: make language tools easier to use, apply predictable formatting, and make toolchain problems easier to diagnose. The MCP server reports findings and returns suggested repair commands for review. It does not execute those commands or silently change your machine.

The toolkit is designed to reduce avoidable rework, not promise perfect code. It complements tests, code review, and engineering judgment. It is also not a sandbox, malware scanner, or dependency supply-chain security system. It gives an agent a better-equipped workspace, but it cannot prove that generated code is correct or safe.

## Give your agent a better starting point

AI can accelerate implementation. A reliable feedback loop helps turn that speed into progress you can actually use.

Set up the tools. Connect the integrations your agent supports. Let code intelligence, formatting, and toolchain checks handle the repetitive work they are good at, so you and your agent can focus more attention on the problem you are trying to solve.

For development checks and contribution guidance, see [CONTRIBUTING.md](CONTRIBUTING.md). For the full technical reference, see the [User Guide](USER-GUIDE.md).

---

<div align="center">

*Support infrastructure for the agent you already use.*

</div>
