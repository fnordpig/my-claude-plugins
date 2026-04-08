---
name: similar
description: Find code similar to a specific location
args: "<file:line>"
---

Find code structurally and semantically similar to the given location.

Parse the argument as `file:line` (e.g., `src/auth.rs:42`). Then call:

```
find_similar(file: "<file>", line: <line>, top_k: 10)
```

Show results ranked by similarity score. For each result, show:
- File path and line range
- Similarity score
- A brief description of what the code does

This is useful for:
- Finding all implementations of a pattern (e.g., all API endpoint handlers)
- Discovering copy-pasted code that should be refactored
- Understanding how similar problems are solved elsewhere in the codebase
