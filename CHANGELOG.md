# Changelog

## [1.2.0] - 2026-09-19

### Added

- **Spec portfolio** for multi-spec products: bundled `skills/spec-portfolio/` (writes `.specify/product/spec-portfolio.md`).
- Command **`speckit.auto-spec.portfolio`** → `/speckit-auto-spec-portfolio` (Cursor) / `$speckit-auto-spec-portfolio` (Codex).
- `scripts/Install-BundledSkills.ps1` — copies bundled skills into `.cursor/skills` or `.agents/skills` and creates `.specify/product/`.

## [1.1.0] - 2026-09-19

### Changed

- SDD pipeline aligned with Spec Kit 0.15+ **full path**: constitution → specify → clarify → plan → **checklist** → tasks → **analyze** → implement → **converge** loop.
- Short path supported via `pipeline.mode: short` in `models.yml`.
- `implement → converge` repeats until Converged or `pipeline.max_converge_iterations`.

### Added

- `pipeline-reference.md` shipped with extension.
- `pipeline` section in `models.template.yml`.
- **Bootstrap install**: `install.ps1` / `install.sh` install uv + specify-cli + `specify init` when missing.
- **Codex** support: skills under `.agents/skills`, agent binders under `.agents/agents`; install with `-Integration codex`.
- Model sync writes binders for **both** Cursor and Codex layouts.

## [1.0.0] - 2026-09-19

- Initial Auto Spec extension (run, review, sync-models).
