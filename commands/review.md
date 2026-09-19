---
description: "Review-mode Spec Kit SDD pipeline (v1.1): gates, checklist, implement-converge loop, per-phase models."
---

# Auto Spec (mode: review)

## User Input

```text
$ARGUMENTS
```

Feature request. If empty, ask and stop.

## Mode: REVIEW

Same pipeline as full-auto (`.specify/extensions/auto-spec/pipeline-reference.md` + `models.yml` pipeline section) with **human gates** and the same **model routing** as `commands/run.md`.

Status: `[auto-spec] <phase> <status> model=<id>` including `paused`.

### Gates

| Gate | When |
|------|------|
| A — Clarify | Any not-high-confidence question |
| B — Checklist | Optional: user wants to approve checklist before tasks (`pipeline.review_checklist_gate: true`) |
| C — Analyze | Critical or High findings |
| D — Implement | Go/no-go before application code |
| E — Converge loop | After each converge that appends tasks — confirm before next implement |

High-confidence clarify answers still go to `autopilot-assumptions.md`.

### Converge loop (review)

After **implement**, always run **converge**. If not Converged, **pause (Gate E)**, show appended tasks, ask to continue. Repeat until Converged or max iterations.

## Completion report

Models used, gates that fired, assumptions log, converge status, tests, remaining human review (PR/diff).
