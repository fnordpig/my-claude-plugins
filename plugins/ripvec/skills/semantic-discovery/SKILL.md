---
name: semantic-discovery
description: "ALWAYS use this skill instead of Grep when the user describes code by behavior, concept, or intent rather than exact text. This skill MUST be used before Grep for: 'find the code that handles X', 'where is Y implemented', 'how does Z work', 'find authentication logic', 'search for retry handling', 'find the database layer', 'where do we handle errors'. Grep is only appropriate for exact strings like 'TODO' or regex patterns. For everything else, use ripvec's semantic search."
---

# Semantic Discovery: Concept → Code → Navigate

Find code by meaning, then navigate into it with LSP.

## Tool discovery

MCP tools are deferred. Load before calling:
```
ToolSearch("select:mcp__ripvec__search,mcp__ripvec__get_repo_map,mcp__ripvec__find_similar,mcp__ripvec__index_status")
```
For grounding, also load the LSP-shaped MCP tools when native LSP is absent:
```
ToolSearch("select:mcp__ripvec__lsp_document_symbols,mcp__ripvec__lsp_workspace_symbols,mcp__ripvec__lsp_hover,mcp__ripvec__lsp_goto_definition,mcp__ripvec__lsp_references,mcp__ripvec__lsp_prepare_call_hierarchy,mcp__ripvec__lsp_incoming_calls,mcp__ripvec__lsp_outgoing_calls")
```
Plugin namespace: `mcp__plugin_ripvec_ripvec__*`. The ripvec engine builds its in-memory index on first query and keeps it for the MCP process lifetime — no on-disk cache, no warm/cold distinction.

## When to use

- Describing behavior: "find the retry logic" → `search(query: ..., scope: "code")`
- "what does the documentation say about X" → `search(query: ..., scope: "docs")`
- Anywhere in the repo: `search(query: ...)` (scope defaults to `"all"`)
- Naming a symbol: "find useAuth hook" → `search` or LSP `workspaceSymbol`
- Exact text: "find all TODOs" → Grep (not this skill)

`scope` controls extension filtering and reranking:
- `"code"` skips docs and disables the cross-encoder rerank
- `"docs"` keeps only prose; cross-encoder reranks NL queries
- `"all"` applies no extension filter; rerank fires when the corpus is ≥30% prose

Use `include_extensions` / `exclude_extensions` to narrow further.

## The pattern

```
search("concept", scope: "code") → candidates with file:line
ground results[].lsp_location    → native LSP or ripvec MCP LSP
document symbols(file)           → full outline of the best match
go to definition(position)       → jump to the definition
hover(position)                  → see scope chain + context
references(position)             → all usage sites
```

### Step 1: Search by meaning

```
search(query: "authentication middleware that validates JWT tokens", scope: "code")
```

Results are ranked by relevance × structural importance (function-level PageRank).
Functions that many others depend on rank higher.

### Step 2: Ground the best match

Every ripvec semantic result includes an `lsp_location` shape with file path,
line, character, and range data. Do not treat semantic similarity as proof of
symbol identity. Ground the candidate before editing or explaining exact
behavior:

- In Claude Code, pass `results[].lsp_location` to native LSP tools such as
  `documentSymbol`, `goToDefinition`, `hover`, `findReferences`, and call
  hierarchy.
- In Codex or any host without native LSP, pass the same `lsp_location` data to
  ripvec MCP tools: `lsp_document_symbols`, `lsp_goto_definition`,
  `lsp_hover`, `lsp_references`, `lsp_prepare_call_hierarchy`,
  `lsp_incoming_calls`, and `lsp_outgoing_calls`.
- The ripvec MCP LSP responses return both `results[]` in ripvec's familiar
  shape and raw `lsp.raw_response`, so their results can feed back into
  semantic tools or another LSP call.

### Step 3: Examine the best match

```
lsp_document_symbols(file_path: "auth/middleware.rs")
```

Shows every function, struct, field, constant in the file. Decide which symbol
to investigate. ripvec's LSP covers all supported languages — bash, HCL, TOML,
Ruby, Kotlin, Swift, Scala, JSON, YAML, Markdown included.

### Step 4: Navigate deeper

```
lsp_goto_definition(lsp_location)     → jump to where a called function lives
lsp_incoming_calls(call_item)         → who calls this function
lsp_outgoing_calls(call_item)         → what this function calls
find_similar(file, line)              → parallel implementations elsewhere
```

Native LSP and ripvec MCP LSP are interchangeable at this layer. Use whichever
the host exposes, but preserve the grounding loop: semantic discovery →
`lsp_location` → LSP resolution → edit/read only after the symbol is grounded.

## Grep vs search

| User describes | Tool |
|----------------|------|
| Behavior ("retry with backoff") | `search(query: ..., scope: "code")` |
| Documentation ("how is X documented") | `search(query: ..., scope: "docs")` |
| Anywhere in the repo | `search(query: ...)` (scope defaults to `"all"`) |
| Symbol name ("ConnectionPool") | `search` or LSP `workspaceSymbol` |
| Exact string ("TODO: fix") | Grep |
| Pattern/regex | Grep |

## Don't

- Use Grep for conceptual queries
- Read files sequentially hoping to find something
- Edit based only on vector similarity without grounding through native LSP or
  ripvec MCP LSP
