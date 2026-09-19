# Input contract

## Accepted inputs

Any combination of:

- Product PRD / MRD / brief (markdown, Confluence export, PDF summarized by user)
- Architecture or domain docs (`docs/`, ADRs, `.review/architecture.md`)
- Feature analysis packs (`.review/<slug>/user-stories.md`, `story-map.md`, `tdd-plan.md`)
- Product-owner packs (`stories/`, `po-analysis.md`, `story-map.data.json`)
- Existing Spec Kit tree (`specs/*/` already present—treat as **occupied** slugs/numbers)
- User chat paste (treat as **Confirmed** only for what they explicitly state)

## Minimum to start drafting

Without at least one of:

- A named product and stated goal (MVP / R0 / phase), or
- A bounded doc set the user points to,

stop and ask for scope in one message. Do not fabricate a portfolio from a single sentence.

## Spec Kit presence

| State | Behavior |
|-------|----------|
| `.specify/` exists | Write to `.specify/product/`; read `constitution.md` and list `specs/` |
| No Spec Kit yet | Write to `docs/product/`; header note: "Relocate to `.specify/product/` after `specify init`" |

## Conflicts between sources

When PRD and story map disagree, record both in the row **Notes** and open `<KEY>-Q-*`. Do not pick a winner silently unless the user delegated product authority in chat.

## Increment scoping

If the user names a sprint, increment, or epic, filter rows to that scope but keep a **Deferred** section so the portfolio stays whole-product aware.
