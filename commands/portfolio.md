---
description: "Decompose product docs into an approved spec portfolio (.specify/product/spec-portfolio.md) before per-feature SDD."
---

# Auto Spec — Spec portfolio

## User Input

```text
$ARGUMENTS
```

Product name, product key, source doc paths, release cut (R0), or revision instructions (merge/split/approve). If empty, ask what product to decompose and where the docs live, then stop.

## Execution

You **must** follow the bundled **spec-portfolio** skill end to end:

1. Read **`.specify/extensions/auto-spec/skills/spec-portfolio/SKILL.md`**
2. Load references from **`.specify/extensions/auto-spec/skills/spec-portfolio/references/`** when the skill directs you to
3. Use **`.specify/extensions/auto-spec/skills/spec-portfolio/assets/spec-portfolio.template.md`** when creating a new portfolio file

Primary output: **`.specify/product/spec-portfolio.md`** (create `.specify/product/` if missing).

## Rules

- Do **not** create `specs/<NNN-slug>/` or run `/speckit-specify` unless the user explicitly asks in this session.
- Default mode is **review**: iterate the register with the user until they approve or you document blocking `<KEY>-Q-*` items.
- When the user approves, complete **Gate 3** in the skill (status **Approved for SDD**, handoff with next `/speckit-specify` prompt).
- Status lines: `[auto-spec] portfolio <draft|revised|approved> revision=<n>`

## After approval (optional)

If the user wants the next SDD slice immediately, suggest **`/speckit-auto-spec-run`** (Cursor) or **`$speckit-auto-spec-run`** (Codex) with the handoff prompt from section 7 of the portfolio—not auto-start without confirmation.

## Completion report

Include: portfolio path, revision, row count, R0 row ids, open questions count, approved yes/no, and next recommended command (`/speckit-auto-spec-portfolio` for more edits or `/speckit-specify` / auto-spec run for first slice).
