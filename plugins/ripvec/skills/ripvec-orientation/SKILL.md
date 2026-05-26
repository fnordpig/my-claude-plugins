---
name: ripvec-orientation
description: >
  Use when starting any non-trivial codebase task — orientation, debugging,
  refactoring, teaching, or quality audit. Triages which ripvec orientation
  (Cartographer / Detective / Refactorer / Onboarder / Sentinel) fits the
  task and routes to the corresponding hub-skill. Fires before narrower
  ripvec skills to prevent picking the wrong orientation mid-stream. Load
  early in any codebase session.
graph:
  generalizes_to: []
  specializes_into:
    - ripvec:cartographer
    - ripvec:detective
    - ripvec:refactorer
    - ripvec:onboarder
    - ripvec:sentinel
  cross_references:
    - ripvec:intent-routing
    - ripvec:recipes
    - ripvec:codebase-orientation
    - ripvec:change-impact
    - ripvec:semantic-discovery
  escalate_to: null  # terminal hub — escalation routes through specializes_into
---

# ripvec-orientation

**Be terse. Tokens cost.** Sections cite the graph; don't restate it.

Top-level entry point for the ripvec plugin. Triage which orientation
fits the task, locate the right hub-skill, and route to its first recipe.

The territory this skill teaches: `docs/SKILL_SEMANTIC_GRAPH.md` (the
graph layer) and `docs/SKILL_TASK_INTENT_INDEX.md` (the inverse
intent→recipe lookup). Both live in the ripvec engine repo.

---

## §1 — The 5 orientations: decision tree

| Trigger phrasing | Hub | Hub-skill | Specializes into |
|---|---|---|---|
| "What matters?" / "How is this organized?" / "Where does X live?" | **Cartographer** | `ripvec:cartographer` | CL-STRUCTURAL-SPINE, CL-CONCEPT-TOUR, CL-FOCUS-DELTA, CL-NAMES-TAXONOMY, CL-RECURSIVE-CARTOGRAPHY |
| "This looks wrong." / "Works in isolation, fails in integration." / "Invariant violated." | **Detective** | `ripvec:detective` | CL-SIBLING-DIFF, CL-CAUSAL-INTERVENTION, CL-CONTRACT-AUDIT, CL-INDIRECT-DISPATCH-DIAGNOSIS |
| "Before I rename X." / "What's the blast radius?" / "Should I extract these?" | **Refactorer** | `ripvec:refactorer` | CL-BLAST-RADIUS, CL-CONTRACT-SURVEY, CL-FALSE-TWINS, CL-HIDE-VS-EXPOSE, CL-NAMING-DRIFT, CL-DUPLICATE-ANCHORED-EXTRACTION |
| "Teach me how Z works." / "Bring me up to speed." / "Explain the architecture." | **Onboarder** | `ripvec:onboarder` | CL-ARCHITECTURAL-TOUR, CL-CONCEPT-BY-EXAMPLE, CL-RECURSIVE-NARRATION, CL-IDIOM-CRYSTALLIZATION, CL-INVARIANT-LAYER |
| "Find dead code." / "What's wrong with this module?" / "Find god-modules." | **Sentinel** | `ripvec:sentinel` | CL-DEAD-CODE-SWEEP, CL-ORPHAN-TRAIT, CL-COHESION-REFRACTION, CL-DUPLICATION-AS-MODULE, CL-PAGERANK-POLARITY, CL-CORPUS-CAP-AUDIT |

The five stances from `SKILL_SEMANTIC_GRAPH.md §2` (HUB-C through HUB-S).

---

## §2 — When to use which sub-skill

**Cartographer** — you don't know the territory. First call is structural
(`get_repo_map`), then semantic to anchor, then precision to confirm.

**Detective** — you have a symptom. Use the codebase as its own oracle.
The divergence IS the diagnostic (Naur 1985; Pearl 2009 do-calculus).

**Refactorer** — you're about to change something. Quantify before moving.
Blast radius is a number, not a guess.

**Onboarder** — you're teaching (yourself or another agent). Curate
evidence that induces the right mental model. Examples before definitions
(Bruner 1966).

**Sentinel** — you're auditing. Start with a probe; the probe's polarity
decides what it found. Every finding declares its falsification rule in
advance (Popper 1934).

---

## §3 — Tool surface

**Claude Code** — MCP tools are deferred; load via `ToolSearch`:

```
ToolSearch("ripvec")
ToolSearch("select:mcp__ripvec__get_repo_map,mcp__ripvec__search,mcp__ripvec__find_similar,mcp__ripvec__find_duplicates,mcp__ripvec__find_dead_code")
ToolSearch("select:mcp__ripvec__lsp_prepare_call_hierarchy,mcp__ripvec__lsp_incoming_calls,mcp__ripvec__lsp_outgoing_calls,mcp__ripvec__lsp_workspace_symbols,mcp__ripvec__lsp_goto_implementation")
```

The namespace is `mcp__ripvec__*` (project `.mcp.json`) or
`mcp__plugin_ripvec_ripvec__*` (plugin binary). Prefer the **native
`LSP()` tool** in Claude Code for call hierarchy and references when
a language server is configured; use ripvec MCP `lsp_*` as fallback.

**Codex** — bare names directly. No `ToolSearch`, no prefix. The ripvec
MCP `lsp_*` tools ARE the LSP path (Codex has no native LSP).

**Index lifecycle.** Auto-reconcile on every search (blake3-confirmed
mtime/size/inode diff). No manual reindex needed. CPU-only Model2Vec;
no on-disk cache.

---

## §3.5 — Dispatch discipline (MANDATORY for agent briefings)

**When you brief a sibling agent for any ripvec-shaped task, the briefing
MUST open with these blocks before the agent's first non-MCP action.
Tool-availability alone does not produce ripvec-first behavior; the
skills teach the discipline that the tools enact.**

### Required dispatch preamble

Every briefing for an agent doing codebase orientation / debugging /
refactoring / teaching / audit work MUST include the skill-load block
and a host-conditional tool-availability block.

**Block 1 — Skill loads (host-agnostic; works on Claude Code AND
Codex; both honor the `Skill` tool with this exact shape):**

```
## MANDATORY FIRST ACTIONS (in order, before any other tool call)

Skill("ripvec:ripvec-orientation")
Skill("ripvec:<primary-hub>")     # cartographer | detective | refactorer | onboarder | sentinel
Skill("ripvec:<secondary-hub>")   # optional but encouraged when work crosses orientations
Skill("ripvec:intent-routing")    # always — phrasal routing for sub-tasks the agent surfaces
Skill("ripvec:recipes")           # always — the named-compositional-pattern library
# If the corpus is language-specific, add the matching language skill:
Skill("ripvec:<language>-recipes")   # c | javascript | python | rust | go | jvm | polyglot
```

**Block 2 — Tool availability (host-conditional; pick ONE of the
following based on the agent's runtime):**

*If the briefing targets a **Claude Code** subagent* (tools are
deferred and must be loaded via `ToolSearch`):

```
ToolSearch("select:mcp__ripvec__get_repo_map,mcp__ripvec__search,mcp__ripvec__find_similar,mcp__ripvec__find_duplicates,mcp__ripvec__find_dead_code")
ToolSearch("select:mcp__ripvec__lsp_workspace_symbols,mcp__ripvec__lsp_document_symbols,mcp__ripvec__lsp_hover,mcp__ripvec__lsp_references,mcp__ripvec__lsp_prepare_call_hierarchy,mcp__ripvec__lsp_incoming_calls,mcp__ripvec__lsp_outgoing_calls")
# Cite by name; do not wildcard. Drop any tool the front truly does not need.
# Some hosts namespace as mcp__plugin_ripvec_ripvec__* — try that prefix if
# the unprefixed mcp__ripvec__* form fails.
```

*If the briefing targets a **Codex** subagent* (tools are bare-named
and always available, no loading required):

```
# No ToolSearch needed on Codex. Ripvec tools are callable by bare name:
#   get_repo_map, search, find_similar, find_duplicates, find_dead_code,
#   lsp_workspace_symbols, lsp_document_symbols, lsp_hover, lsp_references,
#   lsp_prepare_call_hierarchy, lsp_incoming_calls, lsp_outgoing_calls
# The Codex LSP() native tool is unavailable; ripvec MCP lsp_* tools ARE
# the LSP path on Codex.
```

**Failure clause (BOTH hosts):**

```
STOP and report BLOCKED if any required Skill fails to load, or if
the Claude Code agent's ToolSearch returns no matches for the named
tools, or if a Codex agent's first ripvec tool call returns
"tool not found". Do NOT fall back to grep/Read — the bug class is
silent-wrong-answer.
```

### Why this is mandatory (empirical)

Without this preamble, agents revert to `Grep` / `Read` even when
ripvec MCP tools are present. **The skill content teaches the
*discipline*; the tool list alone makes the tools *options among
many*.** Constitutional-cycle observation across the 4.1.x release
arc: briefings with the `Skill()` opener produce ripvec-first
behavior (verified across 12 fronts in Cycles 11-12); briefings
that only mention tool names produce grep-first behavior (5 fronts
in Cycle 12 Wave 1 regressed when this preamble was dropped).

### How to pick `<primary-hub>`

Match the task shape to the orientation per §1 above. If unsure,
default to `Skill("ripvec:intent-routing")` and let the agent
self-route. Never name all five hubs — token cost grows with no
discipline gain.

### What NOT to do

- Don't say "use ripvec" in the briefing without a `Skill()` opener — it doesn't work.
- Don't list MCP tools without a `Skill()` opener — tools without discipline produce grep-fallback.
- Don't permit a "fallback to grep is allowed if ripvec is slow" clause — ripvec indexes at ~23ms per repo; the fallback is never warranted on cost.
- Don't omit the `STOP and report BLOCKED if any fail` clause — silent fallback hides regressions.
- Don't ship a Claude-Code-only `ToolSearch(...)` block to a Codex agent — `ToolSearch` is a Claude Code primitive and will error on Codex. Pick Block 2's host-matching variant.
- Don't ship a Codex bare-name-list to a Claude Code agent — bare ripvec tool calls without prior `ToolSearch` registration will be rejected as `InputValidationError`. Pick Block 2's host-matching variant.

### How to identify host at dispatch time

- If you are dispatching via Claude Code's `Agent` tool with
  `subagent_type` set: Claude Code host. Use the ToolSearch block.
- If you are dispatching via Codex's `task` / `delegate` mechanism:
  Codex host. Use the bare-name block.
- If you are uncertain: include BOTH blocks, prefixed with `# CLAUDE
  CODE ONLY:` and `# CODEX ONLY:` comment fences. The agent's first
  action discards the irrelevant block.

### When dispatching `ripvec:*` subagents (not raw `general-purpose`)

The 4 executive-function subagents (`refactor-planner`, `bug-detective`,
`codebase-teacher`, `drift-auditor`) already preload their hub skills
via the `skills:` frontmatter field. For these, the per-briefing
`Skill()` preamble is redundant but not harmful — leave it in for
explicitness and as a verification anchor for the agent's report.

For `general-purpose` and `swarm-orchestration:swarm-front-implementer`
subagents, the preamble is load-bearing — they don't preload anything.

---

## §4 — Plugin surface (4.1.10)

### Skills (this plugin — 4.1.10)

| Skill | Role |
|---|---|
| `ripvec:ripvec-orientation` | This skill — entry point and triage |
| `ripvec:intent-routing` | Phrasal intent → hub/cluster/first-recipe lookup table |
| `ripvec:cartographer` | Map-building orientation hub (Track B) |
| `ripvec:detective` | Debugging orientation hub (Track B) |
| `ripvec:refactorer` | Refactoring orientation hub (Track B) |
| `ripvec:onboarder` | Teaching orientation hub (Track B) |
| `ripvec:sentinel` | Quality-audit orientation hub (Track B) |
| `ripvec:codebase-orientation` | Structural spine entry (legacy; still fires on phrasing) |
| `ripvec:change-impact` | Blast radius entry (legacy; still fires on phrasing) |
| `ripvec:semantic-discovery` | Semantic search entry (legacy; still fires on phrasing) |
| `ripvec:recipes` | Graph-bridged recipe index (3.1.2-era names → 4.1.x clusters) |
| Language skills (7) | `c-recipes`, `javascript-recipes`, `python-recipes`, `rust-recipes`, `go-recipes`, `jvm-recipes`, `polyglot-recipes` (Track C) |

### Commands

| Command | When to invoke |
|---|---|
| `/orient` | Top-level entry — triggers this triage then routes |
| `/cartograph` | Cartographer hub — T1/T2/T5/C1 with optional --focus-file or --concept |
| `/blast-radius $SYMBOL` | Refactorer T10 chain — lsp_workspace_symbols → call hierarchy fixed-point |
| `/dead-code` | Sentinel T16 sweep — confidence-band-aware |
| `/audit` | Sentinel multi-cluster — C11 PageRank Polarity first, fans out |
| `/teach $CONCEPT` | Onboarder T13+T14 — architectural tour + concept-by-example |
| `/trace $SYMBOL` | Detective T7 Recursive Caller Climb |
| `/map` | Quick `get_repo_map` with optional focus |
| `/find` | `search` shorthand |
| `/similar` | `find_similar` shorthand |
| `/hotspots` | Top-PageRank functions |
| `/duplicates` | `find_duplicates` shorthand |

### Agents (executive-function specialists, 4.1.10)

| Agent | Hub | When to escalate |
|---|---|---|
| `ripvec:refactor-planner` | Refactorer | Long-running, multi-file refactor where T10 blast-radius needs invariant-grouped commit plan |
| `ripvec:bug-detective` | Detective | Root-cause investigation needing Pearl do-calculus + log_level intervention |
| `ripvec:codebase-teacher` | Onboarder | Inducing mental model in a learner agent via curated evidence (T13+T14+C9) |
| `ripvec:drift-auditor` | Sentinel | Multi-cluster quality probe with falsifiable findings (C11 → fan-out) |
| `ripvec:code-explorer` | Cartographer+Onboarder | Broad exploration when no specific hub dominates |
| `ripvec:duplicate-detector` | Sentinel+Refactorer | Duplication-focused; feeds both audit and extract decisions |

---

## §5 — When NOT to use this plugin

- You need an **exact string** → `Grep` / `rg`
- You need a **regex match** → `Grep`
- You need **file paths matching a glob** → `Glob`
- You **know the file** you need → `Read` it directly
- You have a **known symbol** → native `LSP() go_to_definition`

This plugin is for the "I don't know where to start" moment and
for structured compositional work (blast radius, sibling diff,
dead-code sweep, etc.). Once oriented, switch to precise tools.

---

## §6 — Recommended entry: `/orient`

`/orient` wraps this triage. Pass args:

```
/orient "what matters in this codebase?"     → routes to Cartographer → T1
/orient "why does the auth fail in staging?" → routes to Detective → T7/T9
/orient "before I rename EmbedBackend"       → routes to Refactorer → T10
```

If the answer to "which orientation?" is ambiguous, check
`ripvec:intent-routing` — it has verbatim phrasal matches from
`SKILL_TASK_INTENT_INDEX.md §§1-8`.
