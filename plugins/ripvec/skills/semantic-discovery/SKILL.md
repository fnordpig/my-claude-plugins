---
name: semantic-discovery
description: "Use when searching for code by concept, behavior, or intent — when the file and function name are unknown. Triggers on: 'find the code that handles X', 'where is Y implemented', 'how does Z work', 'find authentication logic', 'search for retry handling'. Use instead of Grep when describing WHAT code does rather than WHAT it says."
---

# Semantic Discovery: Concept → Code → Navigate

Find code by meaning, then navigate into it with LSP.

## Tool discovery

MCP tools are deferred. Load before calling:
```
ToolSearch("select:mcp__ripvec__search_code,mcp__ripvec__get_repo_map,mcp__ripvec__find_similar,mcp__ripvec__index_status")
```
Plugin namespace: `mcp__plugin_ripvec_ripvec__*`. Call `index_status` first — wait if indexing.

## When to use

- Describing behavior: "find the retry logic" → `search_code`
- Naming a symbol: "find useAuth hook" → `search_code` or LSP `workspaceSymbol`
- Exact text: "find all TODOs" → Grep (not this skill)

## The pattern

```
search_code("concept")          → candidates with file:line
LSP documentSymbol(file)        → full outline of the best match
LSP goToDefinition(position)    → jump to the definition
LSP hover(position)             → see scope chain + context
LSP findReferences(position)    → all usage sites
```

### Step 1: Search by meaning

```
search_code("authentication middleware that validates JWT tokens")
```

Results are ranked by relevance × structural importance (function-level PageRank).
Functions that many others depend on rank higher.

### Step 2: Examine the best match

```
LSP documentSymbol(file: "auth/middleware.rs")
```

Shows every function, struct, field, constant in the file. Decide which symbol
to investigate. ripvec's LSP covers all 19 supported languages — bash, HCL,
TOML, Ruby, Kotlin, Swift, Scala, JSON, YAML, Markdown included.

### Step 3: Navigate deeper

```
LSP goToDefinition(file, line, char)  → jump to where a called function lives
LSP incomingCalls(file, line, char)   → who calls this function
LSP outgoingCalls(file, line, char)   → what this function calls
find_similar(file, line)              → parallel implementations elsewhere
```

## Grep vs search_code

| User describes | Tool |
|----------------|------|
| Behavior ("retry with backoff") | `search_code` |
| Symbol name ("ConnectionPool") | `search_code` or LSP `workspaceSymbol` |
| Exact string ("TODO: fix") | Grep |
| Pattern/regex | Grep |

## Don't

- Use Grep for conceptual queries
- Read files sequentially hoping to find something
- Skip `index_status` check (empty results during indexing)
