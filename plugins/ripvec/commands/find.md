---
name: find
description: Semantic code search — find code by meaning, not text
arguments:
  - name: query
    description: Natural language description of what you're looking for
    required: true
---

Call the `search` MCP tool with the user's query, defaulting to code scope:
```
search(query: "<query argument>", scope: "code", top_k: 5)
```

Results include full source code in fenced blocks. Present the top results with:
- File path and line range
- Similarity score
- The code content

If results seem off-topic, suggest the user try:
- More specific phrasing
- `search(query: ..., scope: "docs")` for documentation/comments
- `search(query: ...)` with no `scope` to search everything (default `"all"`)
- `Grep` if they're looking for an exact string
