---
name: spec-portfolio
description: Decompose existing product documentation into an approved register of Spec-Driven Development (SDD) slices before running GitHub Spec Kit /speckit-specify. Bundled with Auto Spec; invoke via /speckit-auto-spec-portfolio (Cursor) or $speckit-auto-spec-portfolio (Codex). Produces and iterates on `.specify/product/spec-portfolio.md` (primary) plus optional machine-readable registry and source maps. Use whenever the user has a multi-feature product, PRD pack, architecture docs, story maps, or `.review/*` artifacts and needs a list of specs to iterate through until the portfolio is approved—phrases like "break into specs", "spec portfolio", "SDD backlog", "what goes in specs/001", "before specify", "multi-spec product", or "project plan from docs". Prefer this over jumping straight to /speckit-specify on one feature, over productize (new idea), over feature-revamp-analyst (single legacy feature from code), and over product-owner when the deliverable is Spec Kit folders not story files. Not for writing spec.md/plan.md/tasks.md per feature, not for implementation, and not for go/no-go on a single vague idea (Spec Kit assess).
---

# Spec portfolio (SDD decomposition)

You turn **existing product knowledge** into a **reviewable register of SDD-sized specs**—the list the team iterates until it is safe to run `/speckit-specify` once per row.

The failure mode this skill prevents: dozens of ad-hoc `specs/00N-*` folders with overlapping scope, missing dependencies, and no product-level cut line, because nobody agreed on the slice list first.

## What you deliver

Default location: **`.specify/product/`** (create the directory if Spec Kit is initialized; if not, use `docs/product/` and note that the team should move it under `.specify/product/` after `specify init`).

| File | Required | Contains |
|------|----------|----------|
| `spec-portfolio.md` | **Yes** | Canonical register—the artifact humans iterate on until **Approved for SDD** |
| `spec-portfolio.yaml` | Optional | Same register for scripts / Auto Spec loops; create when the user wants automation |
| `source-map.md` | Optional | PRD / doc section → portfolio row id |
| `non-sdd-work.md` | Optional | Spikes, infra, migrations explicitly **not** turned into SDD specs |
| `portfolio-assumptions.md` | Optional | Decomposition assumptions (portfolio-level, not per-feature clarify) |

Do **not** create `specs/<NNN-slug>/` or `spec.md` in this skill. That is `/speckit-specify`. You may **reserve** slugs and numeric prefixes in the register only.

Read `references/input-contract.md` before ingesting sources. Read `references/slicing-rules.md` before splitting. Read `references/output-template.md` before writing `spec-portfolio.md`. Start from `assets/spec-portfolio.template.md` when the file is new.

## Operating boundary

Planning and decomposition only. No production code, no per-feature `plan.md` / `tasks.md`, no running implement.

Treat source docs as evidence. Label claims:

- **Confirmed** — stated in a cited source or answered at a gate.
- **Inferred** — follows from multiple sources; say so.
- **Unknown** — blocks marking a row *Ready for specify*; list under open questions.

Cite sources as `path/to/doc.md` §section, `.review/<feature>/user-stories.md`, or URL. Do not invent PRD content.

## Stable IDs

Pick a short uppercase **product key** `<KEY>` (e.g. `MKT`, `CHK`, `PORT` for the portfolio itself):

- `<KEY>-SPC-001` — one SDD spec slice in the register (permanent once published)
- `<KEY>-Q-001` — open product question
- `<KEY>-DEP-001` — dependency edge (optional explicit list)
- `<KEY>-GAP-001` — hole in source material that blocks slicing

Mark superseded rows; do not renumber IDs the team may already reference in tickets.

## Workflow

### 1. Intake (Gate 1 — scope)

Confirm:

- Product name and `<KEY>`
- Output directory (default `.specify/product/`)
- Source corpus (paths, links, or paste)
- Target release line if any (R0, MVP, phase name)
- Slicing stance: default **one row = one releasable user-visible outcome** (see slicing rules)

If the user only has a raw idea with no product docs → send them to **productize**, not this skill.

If the user wants stories + TDD ladder without Spec Kit register → **product-owner** or **story-implementation-planner** may fit better; offer to **import** their `user-stories.md` / story map into rows instead of re-analyzing from scratch.

### 2. Decompose (draft register)

1. Scan sources for capabilities, journeys, constraints, and explicit exclusions.
2. Draft rows in `spec-portfolio.md` with status **`proposed`**.
3. Assign each row a **slug** (kebab-case, 2–5 words) suitable for `specs/NNN-<slug>/`.
4. Do not assign final `NNN` until you scan existing `specs/` folders (if any) for the next free number—record *planned* slug in the register; number can be filled at specify time.
5. Write `non-sdd-work.md` when work is real but not SDD-shaped (pure refactor, one-off migration, research spike).
6. Log decomposition assumptions in `portfolio-assumptions.md` when guesses materially affect boundaries.

### 3. Review loop (Gate 2 — iterate)

Present the register summary in chat: count of rows, R0 cut, top dependencies, and **blocking questions** (`<KEY>-Q-*`).

Accept user feedback: merge/split rows, change priority, defer, fix slugs, add exclusions. Update `spec-portfolio.md` in place; bump **Revision** in the document header.

Repeat until the user explicitly approves or you hit unresolved **Unknown** blockers—in the latter case, keep status **`draft`** and list what must be answered.

### 4. Approve (Gate 3 — handoff to Spec Kit)

When the user approves:

1. Set portfolio **Status** to **`Approved for SDD`** with date and approver (name or "user").
2. Set each in-scope R0/R1 row to **`approved`** (register status column).
3. Set **Ready for specify?** to `yes` only where Unknowns are cleared.
4. Add a short **Handoff** section: ordered list of slugs and the one-line outcome to pass as the `/speckit-specify` feature description for the first row.

Do not run `/speckit-specify` unless the user asks you to execute Spec Kit in the same session.

### 5. Maintain (living portfolio)

When a row completes specify, update its status to **`specified`** and note the actual `specs/NNN-slug/` path.

When scope changes mid-program, add rows or mark rows **`superseded`**; prefer new `<KEY>-SPC-*` ids for new slices rather than overloading old ids.

Optional **`project-plan.md`** rollup: only after the user asks and at least one row has a `plan.md`—summarize cross-spec timeline and dependencies; do not replace per-spec plans.

## Integration with other skills

| Upstream | How to use |
|----------|------------|
| `.review/<feature>/user-stories.md`, `story-map.md` | Map stories/epics → `<KEY>-SPC-*` rows; cite story ids in **Source refs** |
| `product-owner` pack | Import `stories/index.json` / coverage as boundaries; SDD rows may span multiple US-* |
| `feature-revamp-analyst` | One revamp feature may become **one** or **several** SPC rows depending on release slices |
| Spec Kit **constitution** | Read `.specify/memory/constitution.md` for constraints that affect slice boundaries |

## Quality bar for each register row

Before marking **Ready for specify?** = yes, the row must have:

- Testable **outcome** (one line, user/business facing)
- Clear **in scope** / **out of scope**
- **Source refs** or explicit **Inferred** boundary rationale
- Dependencies identified (or "none")
- Slug that will not collide with existing `specs/*` folders

Rows that are still epics ("entire checkout revamp") fail the bar—split per slicing rules.

## Conversational stance

Lead with a recommended slice map and tradeoffs, not a blank questionnaire. Ask at most a handful of blocking questions per iteration, each tied to a specific row or `<KEY>-Q-*`.

When the user says "approve" or "good to specify", complete Gate 3 and stop—do not silently start specify.
