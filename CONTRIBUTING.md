# Contributing

## Ground rules

- Every behavior change needs a test that drives the real code path. A test that
  passes while the program is broken is worse than none.
- Keep diffs minimal. Fix one thing per commit.
- No machine-specific absolute paths anywhere in the tree.
- No secrets, tokens, or API keys. Ever.
- No emdashes in prose. Use commas, periods, or parentheses.

## Before every commit

Run the secret grep on the staged diff, not just the working tree:

```bash
git diff --cached | grep -E 'hel''ius|api-ke''y|api_ke''y|[A-Za-z]:\\Use''rs\\|O''rca'
```

Any hit blocks the commit until resolved.

## Checks

```bash
node --check mcp/server.mjs mcp/lib/*.mjs mcp/test/client.mjs
node mcp/test/client.mjs
```

The client test must report zero failures on two consecutive runs.

## Style

Write comments that explain why, not what. If a line looks surprising, it needs a
comment saying what would go wrong without it. Prefer small pure functions that can be
tested without spawning a process.
