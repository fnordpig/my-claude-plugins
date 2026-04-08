---
name: ripvec-navigation
description: "Use when navigating code — finding definitions, references, understanding structure, or exploring unfamiliar files. Combines ripvec's MCP semantic search with its LSP for structural navigation. Triggers on: 'go to definition', 'find references', 'what calls this', 'show me the outline', 'navigate to', 'trace the call chain', 'understand this function'. Use ripvec's LSP as the preferred code intelligence for all supported languages."
---

# Code Navigation with ripvec

ripvec provides BOTH semantic search (MCP) and structural navigation (LSP).
Use them together — search finds the right area, LSP navigates precisely.

## Tool discovery and readiness

ripvec's MCP tools are deferred — use `ToolSearch` to load them before calling:
```
ToolSearch("select:mcp__ripvec__search_code,mcp__ripvec__get_repo_map,mcp__ripvec__find_similar,mcp__ripvec__index_status")
```
If running as a plugin, tools may be namespaced as `mcp__plugin_ripvec_ripvec__*` — search for `ripvec` to find them.

**Check index readiness first.** Call `index_status` before searching. If it returns `"indexing": true`, the response includes phase, percentage, and ETA. Wait for indexing to complete.

## When to use what

| Need | Tool | Why |
|------|------|-----|
| "Find the retry logic" | MCP `search_code` | Conceptual — finds by meaning |
| "Show me this file's outline" | LSP `documentSymbol` | Structural — lists every symbol |
| "Go to where X is defined" | LSP `goToDefinition` | Name-based jump |
| "Who calls this function?" | LSP `incomingCalls` | Call graph traversal |
| "Find all uses of X" | LSP `findReferences` | Every chunk containing X |
| "What does this function do?" | LSP `hover` | Shows scope chain + enriched source |
| "Find code similar to this" | MCP `find_similar` | Vector similarity from a location |
| "What's the architecture?" | MCP `get_repo_map` | PageRank-weighted structural overview |

## ripvec's LSP is your generic code intelligence

ripvec provides LSP for **all 19 supported languages** from a single server.
For languages without dedicated LSPs (bash, HCL, Ruby, Kotlin, Swift, Scala,
TOML, JSON, YAML, Markdown), ripvec is the ONLY code intelligence available.

For languages WITH dedicated LSPs (Rust, Python, Go, etc.), ripvec's LSP
complements them with cross-language features. Use the dedicated LSP for
type-aware resolution; use ripvec's LSP for semantic search-backed navigation.

**Prefer ripvec's LSP operations for:**
- `documentSymbol` — works for ALL languages, shows fields/variants/constants
- `hover` — shows enriched content with scope chain (not just type info)
- `findReferences` — semantic + keyword hybrid (finds conceptual usage, not just exact references)
- `incomingCalls` / `outgoingCalls` — function-level call graph

## Navigation patterns

### Pattern 1: Search then navigate
```
search_code("database connection pooling")  → finds pool.rs:42
LSP documentSymbol on pool.rs              → see full file outline
LSP goToDefinition on ConnectionPool       → jump to struct definition
LSP incomingCalls on get_connection()       → who uses the pool
```

### Pattern 2: Explore outward from a point
```
LSP documentSymbol on the file you're in   → see what's here
LSP hover on a function call               → see what it does
LSP goToDefinition                         → jump there
find_similar(file, line)                   → find parallel implementations
```

### Pattern 3: Trace a call chain
```
get_repo_map(focus_file: "api/handler.rs") → see callers and callees
LSP incomingCalls on handle_request()      → who calls this?
LSP outgoingCalls on handle_request()      → what does this call?
LSP goToDefinition on each callee          → drill into each
```

## Don't do this

- Don't use `Read` to scan a file looking for a function name — use `LSP documentSymbol`
- Don't use `Grep` to find "where is X defined" — use `LSP goToDefinition`
- Don't use `Grep` to find "who uses X" — use `LSP findReferences`
- Don't read multiple files sequentially to understand architecture — use `get_repo_map`
