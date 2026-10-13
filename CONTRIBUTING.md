# Contributing

Good contributions are small and proven. Here is how to make one.

## The bar

Every behavior change needs a test that exercises the real code, not a copy of
the logic inside the test. A test that passes while the program is broken is
worse than no test at all.

Fix one thing per commit. Keep the diff as small as the fix allows.

## Three rules that are never negotiable

1. **No machine-specific paths.** Nothing in this tree may contain a path from
   your computer. Use relative paths, or compute locations at runtime.
2. **No secrets.** No tokens, no API keys, no credentials of any kind.
3. **No emdashes in prose.** Use commas, periods, or parentheses.

## Before every commit

Run the secret check on what you staged, not just your working files:

```bash
git diff --cached | grep -E 'hel''ius|api-ke''y|api_ke''y|[A-Za-z]:\\Use''rs\\|O''rca'
```

Shell joins neighboring quoted pieces, so that pattern checks for the real
secret markers while this file never contains them back to back. If it did, the
documentation would flag itself. Any hit blocks the commit until you resolve it.

## Checks to run

```bash
node --check mcp/server.mjs mcp/lib/*.mjs mcp/test/client.mjs
node mcp/test/client.mjs
```

The client test starts the real server, performs a handshake, calls every tool,
and checks each response. It must report zero failures on two runs in a row.

## How to write code here

Explain why, not what. If a line looks surprising, add a comment saying what
would break without it. Prefer small functions that do not touch the disk or the
network, so they can be tested without setting anything up.

## Adding a language

Copy the closest existing skill folder under `.agents/skills/`, rename it, and
fill in the install command, the verify command, and the one trap everyone hits.
Then add the server and formatter to the language table in `mcp/lib/`, add the
plugin settings under `plugins/`, and extend the hook config in
`hooks/format.json`. Test every step for real before you commit.
