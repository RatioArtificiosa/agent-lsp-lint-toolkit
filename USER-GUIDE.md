# User Guide

Everything the README summarizes, explained fully. If you are new to language
servers, start at the top. If you already know what a language server is, jump to
the language table or the troubleshooting section.

## What a language server actually is

When you hover over a variable in an editor and see its type, or right-click a
function name and jump to where it is defined, that is a language server doing
the work. It is a small program that reads your code and answers questions about
it: what is this, where is that defined, what goes here.

AI coding agents need the same answers. Without a language server, an agent can
only search your code as text. With one, it understands your code the way your
editor does. That difference shows up fast: fewer wrong guesses, fewer repeated
attempts, better first drafts.

## What a formatter and a linter do

A formatter rewrites your code so it looks consistent: same indentation, same
spacing, same layout everywhere. A linter reads your code and points out likely
mistakes, like an unused variable or a risky pattern. Formatters change code.
Linters only comment on it.

This toolkit wires formatters to run automatically every time your agent writes a
file. Linters are available through the language servers and the skills.

## The two problems this toolkit solves

### Problem 1: language servers that will not start on Windows

Here is what happens. Your agent wants to start a language server, so it launches
the program by name. On Windows, launching a program by bare name only finds files
ending in `.exe`. That is a platform rule, not a bug in your setup.

The catch: servers installed through npm (the JavaScript package manager) do not
come as `.exe` files. They come as small wrapper scripts. So the launch fails with
"not found" even though the server is installed and works fine from a terminal.
This hits the TypeScript and Python servers on every Windows machine.

The fix in this toolkit is a tiny launcher program, about 7KB. It is a real
`.exe`, so Windows finds it, and all it does is start the real server and connect
it. The file is `lsp/launcher.cs`, and `lsp/build.ps1` builds it. You do not need
it on macOS or Linux, where the normal install already works.

### Problem 2: the agent asks questions the server cannot answer

A language server needs to be told when a file is opened before it can answer
questions about that file. Some agent software skips that step and jumps straight
to asking. The server, having never seen the file, answers from nothing: hover
comes back empty, jump-to-definition goes nowhere.

The fix in this toolkit is a small relay called a proxy (`lsp/lsp-open-proxy.js`).
It sits between your agent and the server and passes every message through
untouched, byte for byte. It only adds the missing open notification (called
`didOpen` in the protocol) when it is needed. It also notices when a file changes on disk and
tells the server (a `didChange` message), so answers never come from stale text.

What the proxy will never do: edit your files, run formatters, install anything,
or record what your code says. It only delivers messages. Set the
`GROK_LSP_PROXY_DEBUG` environment variable to `1` if you ever want to watch
which notifications it sends.

## What is in the box

- `.agents/skills/`: one folder per language. Each one says what to install (with
  the exact command), how to check it worked, and the one trap most people hit
  with that language. Your agent reads these itself.
- `hooks/`: the auto-format setup. A hook is a rule your agent software runs
  automatically after your agent writes a file. Ours runs the right formatter for
  the file type. Files that are already clean are left byte-for-byte identical.
  Anything the hook cannot handle is skipped quietly instead of breaking your
  agent's work.
- `lsp/`: the proxy and the Windows launcher source described above.
- `mcp/`: a helper server your agent can ask about its own setup (more below).
- `plugins/`: ready-made language server settings, one folder per language.
- `install.ps1`, `install.sh`, `install.py`: the installers.

## Installing

Pick the installer for your machine and run it from the folder you downloaded.
Each one looks at what you already have before installing anything, prints what
it is about to do, and can be run again safely. Nothing asks for administrator
or `sudo` access without telling you first. On Windows, the installer also
builds the small launcher program described above.

## The MCP helper server

MCP is a standard way for an agent to call tools. The helper server in `mcp/`
gives your agent five tools for understanding its own toolbox:

- **`probe_toolchains`**: lists every language, whether its server and formatter
  are installed, where they live, and which version. A missing tool shows up as a
  fact, never as a crash.
- **`doctor`**: one combined health report. It flags incomplete setups and warns
  when a server and its formatter are such different versions they might
  disagree.
- **`install_missing`**: returns the exact commands that would fix what `doctor`
  found. Read-only: it tells you the commands, it never runs them. You stay in
  charge of your machine.
- **`language_for_file`**: given a file path, answers which language it belongs
  to. Useful when your agent is unsure how to treat a file.
- **`readme`**: returns the project documentation, so the agent can read
  instructions without internet access.

## Language-by-language reference

| Language | Server program | Format program | The trap to know |
| --- | --- | --- | --- |
| Rust | rust-analyzer | rustfmt, plus clippy checks | The project needs a `Cargo.toml` file at its root, or the server stays silent. The lint checks come from a separate piece called clippy. |
| Python | pyright | ruff | The server and the formatter are separate downloads. Also, the server returns nothing for a file it was never told was opened, so give it a few seconds after opening before asking. |
| Go | gopls | gofmt | The formatter comes with Go. The server does not, and it needs a `go.mod` file to understand your project. |
| C / C++ | clangd | clang-format | A file called `compile_commands.json` helps with locating included headers, but symbols work without it. By convention here, `.c` and `.h` mean C, while `.C`, `.H`, `.cpp` and friends mean C++. |
| TypeScript / JS | typescript-language-server | biome | Your project needs its own TypeScript, and it must be version 5. Version 7 removed a file the server needs, and the error misleadingly blames a missing install. Pin it with `npm install --save-dev typescript@5`. |
| Zig | zls | zig fmt | The server needs a `build.zig` file to map your project. Without it there is nothing to look at, which looks like slowness but is not. Keep Zig and zls versions paired. |
| AssemblyScript | Uses the TypeScript server | eslint | Needs an `eslint.config.js` file in your project. Without it, the formatter fails loudly instead of doing nothing. |

## Troubleshooting

| What you see | What it usually means | What to do |
| --- | --- | --- |
| "No LSP server configured" for `.ts` on Windows | The small launcher program is missing | Run `lsp/build.ps1`, telling it to put the result in your global npm folder |
| Hover is empty but symbol lists work | The server connection is stale, or the request is not going through the proxy | Check that the plugin settings point at the proxy, then restart your agent software |
| The TypeScript server says it cannot find TypeScript | Your project has version 7 or none at all | Run `npm install --save-dev typescript@5` in your project |
| rust-analyzer says nothing | No `Cargo.toml` above the file | Open a file inside a cargo project instead |
| pyright returns zero symbols | It was never told the file was open | Wait a few seconds after opening, then ask again |
| Formatting changed nothing | The file was already clean, or the extension is not covered | Check the extension list in `hooks/format.json` |
| The hook never runs in CommandCode | File writing is blocked without full trust mode | Run with `--trust --yolo`, or check the hooks audit log |

Still stuck? The `doctor` tool in the MCP server is the fastest next step. It checks everything above in one call.
