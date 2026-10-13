# Agent LSP Lint Toolkit

Language servers, linters and formatters for seven languages, working on Windows,
macOS and Linux. Drop the `.agents` folder into a project and your agent gets
toolchain skills with zero config.

## Why this exists

Two bugs make language tooling fail silently, and both look like broken plugins when
the plugins are fine.

First, on Windows, tools that spawn language servers without a shell can only resolve
`.exe` files. That is how libuv works: it appends `.exe` and nothing else. But npm
installs Node-based servers as `.cmd` and `.ps1` shims, never as a `.exe`. So
`typescript-language-server` and `pyright-langserver` fail with "not found" on Windows
while working everywhere else. This repo ships a 7KB launcher binary that fixes it.

Second, some agent harnesses never send the `didOpen` notification before asking for
hover or definitions. The server has no document content, so it answers from an empty
buffer: hover comes back empty, go-to-definition returns null. This repo ships a small
proxy that injects the missing lifecycle messages, so hover works.

## What you get

- `.agents/skills/` with one skill per language: what to install, the one command that
  installs it, how to verify, and the known trap for that language.
- `hooks/` with an auto-format hook that runs after every write. Six languages
  reformat, clean input stays byte-identical, and anything it cannot handle exits
  quietly instead of breaking the tool call.
- `lsp/lsp-open-proxy.js`, the lifecycle injection proxy described above.
- `lsp/launcher.cs` and `lsp/build.ps1`, the Windows launcher described above.
- `mcp/` with a toolchain server: it probes what is installed, reports versions,
  flags skew between a server and its formatter, and tells you the exact install
  commands for what is missing.
- `plugins/` with per-language server configs.

## Install

Pick one. Each is idempotent and safe to re-run.

```powershell
# Windows
powershell -ExecutionPolicy Bypass -File install.ps1
```

```bash
# Linux and macOS
sh install.sh
```

```bash
# Any platform with Python 3
python3 install.py
```

Each installer detects before installing and prints what it will do. Nothing requires
sudo silently. On Windows, the installer also builds the launcher binary.

## Verify

```bash
node --check mcp/server.mjs
node mcp/test/client.mjs
```

The client test starts the real server, checks the handshake, calls every tool, and
asserts the response shape. It must report zero failures.

## Languages

| Language | Server | Formatter | Trap |
| --- | --- | --- | --- |
| Rust | rust-analyzer | rustfmt (+ clippy) | Needs `Cargo.toml` at the workspace root or the server stays silent |
| Python | pyright | ruff | pyright returns zero symbols for a document it was never opened |
| Go | gopls | gofmt | Needs `go.mod`; gofmt ships with Go, gopls does not |
| C / C++ | clangd | clang-format | `compile_commands.json` is for includes, not symbols; `.C` means C++ |
| TypeScript / JS | typescript-language-server | biome | Project typescript must be 5.x; Windows needs the launcher |
| Zig | zls | zig fmt | Needs `build.zig` for a module graph; keep versions paired |
| AssemblyScript | (TypeScript server) | eslint via npx | Needs a project-local `eslint.config.js` |

## How the proxy works, and what it will not do

The proxy sits between the agent and the language server. It forwards every message
byte for byte and only intervenes to supply the document lifecycle the client skips:
it sends `didOpen` when a request names an unopened document, and `didChange` when the
file on disk no longer matches what was sent. It deliberately leaves `documentSymbol`
out of nothing, it injects for every position-based request including symbols, because
some servers need it and the rest ignore the extra message harmlessly.

What it will not do: it never edits your files, never runs formatters, never installs
anything, and never logs message contents. Set `GROK_LSP_PROXY_DEBUG=1` to trace which
notifications it injects.

## Troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| "No LSP server configured" for `.ts` on Windows | The `.exe` launcher is missing | Run `lsp/build.ps1` with an output dir of your global npm directory |
| Hover empty but symbols work | Stale server, or the proxy is not in the command chain | Confirm the plugin config points at the proxy, then restart the harness |
| `typescript-language-server` reports no valid TypeScript | Project has TypeScript 7 or none | `npm install --save-dev typescript@5` |
| rust-analyzer silent | No `Cargo.toml` above the file | Add the file to a cargo workspace |
| pyright returns zero symbols | Document was never opened | Wait a few seconds after opening, then re-query |
| Formatter changed nothing | File was already clean, or the extension is not covered | Check the extension list in `hooks/format.json` |
| Hook never fires in CommandCode | `write_file` is blocked without `--yolo` | Run with `--trust --yolo`, or check the hooks audit log |

## Contributing

Small, proven changes beat large speculative ones. Every behavior change needs a test
that drives the real code path, not a reimplementation of it inside the test. No
machine-specific paths, no secrets, no emdashes in prose. Run the secret grep before
every commit and keep the diff minimal.
