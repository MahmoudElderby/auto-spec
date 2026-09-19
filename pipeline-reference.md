# Auto Spec SDD pipeline reference (Spec Kit 0.15+ aligned)

Use this order unless `pipeline.mode: short` in `models.yml`.

## Product portfolio (multi-spec, before SDD)

For products with many features, run **portfolio** first:

0. **portfolio** — `/speckit-auto-spec-portfolio` (Cursor) or `$speckit-auto-spec-portfolio` (Codex). Produces **`.specify/product/spec-portfolio.md`**. Iterate until **Approved for SDD**, then run specify (or auto-spec run) per approved row.

Bundled skill: `.specify/extensions/auto-spec/skills/spec-portfolio/`.

## Full path (production)

1. **constitution** — only if `.specify/memory/constitution.md` is still a template OR user passed constitution text in `$ARGUMENTS`
2. **specify**
3. **clarify**
4. **plan**
5. **checklist** — skip if `pipeline.include_checklist: false`
6. **tasks**
7. **analyze** — after tasks, before implement
8. **implement**
9. **converge** — loop with implement until Converged or `pipeline.max_converge_iterations`

## Short path

specify → plan → tasks → implement → converge loop

## Feature context

Respect `.specify/feature.json` and `SPECIFY_FEATURE` / `SPECIFY_FEATURE_DIRECTORY`.

## Integrations (Cursor + Codex)

| Integration | Skills | Agents (after sync-models) | Invoke |
|-------------|--------|----------------------------|--------|
| `cursor-agent` | `.cursor/skills/speckit-<phase>/` | `.cursor/agents/speckit-<phase>.md` | `/speckit-<phase>` |
| `codex` | `.agents/skills/speckit-<phase>/` | `.agents/agents/speckit-<phase>.md` | `$speckit-<phase>` |

Auto Spec: `/speckit-auto-spec-*` (Cursor) or `$speckit-auto-spec-*` (Codex).
