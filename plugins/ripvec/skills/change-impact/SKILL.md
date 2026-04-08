---
name: change-impact
description: "Use when starting from a known piece of code and exploring outward — understanding dependencies, finding similar code, assessing blast radius, tracing call chains. Triggers on: 'what depends on this', 'what breaks if I change this', 'find all callers', 'what's connected to this function', 'find similar implementations', 'trace the flow', 'assess blast radius'."
---

# Change Impact: Code → Context → Connections

Start at a known location. Explore outward with LSP, then search for patterns.

## Tool discovery

MCP tools are deferred. Load before calling:
```
ToolSearch("select:mcp__ripvec__get_repo_map,mcp__ripvec__search_code,mcp__ripvec__find_similar,mcp__ripvec__find_duplicates,mcp__ripvec__index_status")
```
Plugin namespace: `mcp__plugin_ripvec_ripvec__*`. Call `index_status` first — wait if indexing.

## When to use

- "What calls this function?" → LSP `incomingCalls`
- "What does this function call?" → LSP `outgoingCalls`
- "Find all uses of this struct" → LSP `findReferences`
- "Find code similar to this" → `find_similar`
- "What's the blast radius of changing this?" → this full workflow
- "Are there duplicates of this?" → `find_duplicates`

## The pattern

```
LSP documentSymbol(file)           → see what's in the file
LSP incomingCalls(function)        → who depends on this
LSP outgoingCalls(function)        → what this depends on
get_repo_map(focus_file: file)     → structural neighborhood
find_similar(file, line)           → parallel implementations
find_duplicates(threshold: 0.85)   → codebase-wide near-copies
```

### Step 1: Understand the local structure

```
LSP documentSymbol(file: "src/auth/middleware.rs")
```

See every function, field, constant. Identify the function being changed.

### Step 2: Trace the call graph

```
LSP incomingCalls(file, line, char)   → every function that calls this
LSP outgoingCalls(file, line, char)   → every function this calls
```

These use ripvec's function-level call graph — backed by PageRank, not
just text matching. Available for all 19 supported languages.

### Step 3: See the structural neighborhood

```
get_repo_map(focus_file: "src/auth/middleware.rs", max_tokens: 1500)
```

Topic-sensitive PageRank concentrates on the focus file's callers and
callees. Shows which other files are structurally connected.

### Step 4: Find parallel implementations

```
find_similar(file: "src/auth/middleware.rs", line: 42, top_k: 10)
```

Finds code with similar embeddings — different implementations of the
same pattern. If changing a function signature, these likely need the
same change.

### Step 5: Check for duplicates

```
find_duplicates(threshold: 0.90)
```

Near-exact copies (>0.90) are likely copy-paste that should be refactored.
Similar patterns (0.85-0.90) may need coordinated changes.

## Safety checklist before a structural change

- [ ] `LSP incomingCalls` — identify all direct callers
- [ ] `LSP findReferences` — all usage sites (including type annotations)
- [ ] `find_similar` — parallel implementations needing the same change
- [ ] `get_repo_map(focus_file)` — structural neighborhood
- [ ] Run tests on the dependency neighborhood, not just the changed file

## Don't

- Change a function signature without checking `incomingCalls` first
- Assume only one file is affected
- Skip `find_similar` — copy-paste code is everywhere
- Use Grep to find "who uses this" — use LSP `findReferences`
