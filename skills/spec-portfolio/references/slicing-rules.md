# Slicing rules (SDD-sized specs)

Goal: each approved row should become **one** `/speckit-specify` invocation and **one** feature directory under `specs/`, completable through implement/converge without swallowing the whole product.

## Default slice size

**One row = one releasable user-visible outcome** that can be demoed and tested on its own, even if other rows must ship first due to dependencies.

Good slices:

- "Guest can save cart for 7 days"
- "Merchant can configure flash-sale window per shop"
- "Customer sees MSISDN tokenized at checkout"

Too large (split):

- "Checkout v2"
- "Admin portal"
- "Performance improvements"

Too small (merge unless truly independent):

- "Change button color on cart" (unless a standalone experiment with its own success criteria)

## Split heuristics

Split when:

- Multiple actors with unrelated outcomes share one row
- Row mixes **customer**, **merchant**, and **ops/admin** journeys without a single demo
- Success criteria would need unrelated metrics (conversion + audit compliance + search latency)
- Estimated implement/converge loop would exceed what one team can finish in one iteration (team-specific—flag as **Inferred** and offer split options)

Merge when:

- Two rows share the same data contract and cannot ship independently
- One row is only valuable as glue for another (make dependency explicit instead)

## Dependencies

Use **Depends on** column for ordering. Prefer DAG (no cycles). If cycle appears, merge or insert a thin **enabler** row (e.g. shared API contract).

## Non-SDD work

Send to `non-sdd-work.md`:

- Repo-wide migrations with no user story
- Pure refactors with unchanged behavior (unless constitution mandates SDD for risk)
- Open-ended spikes ("investigate Elasticsearch")
- CI/CD-only changes

## Slugs and numbering

- **Slug**: kebab-case, stable, matches Spec Kit short-name guidance (action-noun when possible)
- **NNN**: assign at specify time by scanning `specs/`; in portfolio, optional **Planned path** column `specs/NNN-slug` once numbers are known

## Mapping from user stories

| Story map pattern | Portfolio pattern |
|-------------------|-------------------|
| One release slice with 3–8 stories | Often **one** SPC row if one demo; or one row per story if each is independently shippable |
| Backbone step with many rules | Usually **one** row per **outcome**, not one row per rule |
| Technical enabler story | `non-sdd-work.md` or dependency on a thin enabler SPC row |

## Ready for specify

Set **yes** only when the feature description for specify can be written as 2–4 sentences without [NEEDS CLARIFICATION] on scope boundaries.
