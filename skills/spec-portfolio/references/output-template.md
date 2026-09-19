# Output template — `spec-portfolio.md`

Use this section order exactly. Copy structure from `assets/spec-portfolio.template.md` for new files.

## Header block

- Title: `# <Product name> — Spec portfolio`
- Metadata table: Product key, Portfolio status (`draft` | `Approved for SDD`), Revision (integer), Updated date, Sources (bullet list of paths)
- One paragraph **Intent**: what product increment this portfolio feeds

## Section 1 — Decomposition rules

Bullet list of rules used for this run (reference `slicing-rules.md` defaults + any user overrides).

## Section 2 — Spec register

Markdown table with columns:

| Id | Slug | Title | Outcome (1 line) | Source refs | In scope | Out of scope | Depends on | Priority | Ready for specify? | Status |

**Status** values: `proposed` | `approved` | `specified` | `planned` | `in_progress` | `done` | `deferred` | `superseded`

**Priority**: e.g. R0, R1, P1, Must, Should—or match user's release naming.

**Ready for specify?**: `yes` | `no` — if no, point to `<KEY>-Q-*` in section 4.

When a folder exists, add column or footnote: **Spec path** = `specs/NNN-slug`.

## Section 3 — Sequencing

- Ordered **Suggested specify order** (list of `<KEY>-SPC-*` ids)
- Optional mermaid `flowchart LR` for dependencies (keep ≤12 nodes for readability)

## Section 4 — Open product questions

| Id | Question | Blocks rows | Answer | Status |

Status: `open` | `answered`

## Section 5 — Release cut (optional)

What is in R0 vs later; link rows by id.

## Section 6 — Approval

When not yet approved:

```markdown
**Portfolio status:** draft
**Approved for SDD:** no
```

When approved at Gate 3:

```markdown
**Portfolio status:** Approved for SDD
**Approved on:** YYYY-MM-DD
**Approved by:** <name>
**Notes:** <any cut-line comments>
```

## Section 7 — Handoff to Spec Kit

After approval only:

1. Next row to specify: `<KEY>-SPC-NNN` — `<slug>`
2. **Suggested `/speckit-specify` prompt** (2–4 sentences, outcome-focused, no implementation stack)
3. Reminder: downstream commands use `.specify/feature.json` after specify runs

---

## Optional `spec-portfolio.yaml`

Mirror section 2 as a list:

```yaml
product_key: MKT
status: draft  # or approved_for_sdd
revision: 1
specs:
  - id: MKT-SPC-001
    slug: guest-cart-persist
    title: ...
    outcome: ...
    depends_on: []
    priority: R0
    ready_for_specify: false
    status: proposed
```

Keep yaml in sync when user requests automation; otherwise markdown is source of truth.
