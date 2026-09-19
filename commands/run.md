---
description: "Full-auto Spec Kit SDD pipeline (v1.1): full/short path, checklist, implement-converge loop, per-phase models."
---

# Auto Spec (mode: full)

## User Input

```text
$ARGUMENTS
```

Feature request (and optional constitution hints). If empty, ask for a one-sentence feature description and stop.

## Mode: FULL AUTO

Run Spec-Driven Development end-to-end. Human reviews artifacts and diffs after completion.

### Rules

1. Load pipeline settings from `.specify/extensions/auto-spec/models.yml` → `pipeline:` (defaults: mode=full, include_checklist=true, max_converge_iterations=5, skip_constitution_if_present=true).
2. Follow phase order in `.specify/extensions/auto-spec/pipeline-reference.md` (full vs short).
3. Status after each phase: `[auto-spec] <phase> <status> model=<id>` where status is `started|completed|failed`.
4. Stop only on hard failures (missing skill, script error, unrecoverable validation).
5. **clarify**: auto-answer; log every assumption in `specs/<slug>/autopilot-assumptions.md`.
6. **analyze**: if Critical/High findings, fix upstream artifacts and re-run analyze until clear (full-auto).
7. **implement → converge loop** until Converged or max iterations; then stop with report.
8. **Model routing** (below) is mandatory when models are configured.

## Model routing

1. Read `.specify/extensions/auto-spec/models.resolved.json` or `models.yml`.
2. `inherit` → run phase in parent agent; else **Task/subagent** with resolved model (prefer agent `speckit-<phase>` from integration agent dir).
3. If binders missing: tell user to run `/speckit-auto-spec-sync-models` (Cursor) or `$speckit-auto-spec-sync-models` (Codex).

Resolve skill paths from `default_integration` in `.specify/integration.json` (see pipeline reference).

## Phase execution notes

- **constitution**: skip when `skip_constitution_if_present` and constitution has no placeholder tokens.
- **checklist**: generate custom checklist; in full-auto, evaluate gaps and fix spec/plan via clarify/specify as needed before tasks.
- **implement**: respect checklist gate behavior from core skill (note unchecked items in report; proceed in full-auto with logged risk if custom checklist incomplete).
- **converge**: never skip after implement; drive the loop until Converged or cap.

## Completion report

Include: feature dir, pipeline mode, models per phase, assumptions log, converge iterations, Converged yes/no, test summary, human review checklist.
