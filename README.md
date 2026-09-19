# Auto Spec

**Spec Kit extension** that automates Spec-Driven Development for **Cursor** and **Codex**: full/short SDD paths, **checklist**, **implement ↔ converge** loop, and **per-phase model routing**.

Requires [Spec Kit](https://github.com/github/spec-kit) **0.15+** (`specify-cli`). Auto Spec can **install Spec Kit for you** if it is missing.

## What it automates (SDD core)

| Spec Kit skill | Auto Spec |
|----------------|-----------|
| `/speckit-constitution` | Once, if constitution still a template |
| `/speckit-specify` | Yes |
| `/speckit-clarify` | Yes |
| `/speckit-plan` | Yes |
| `/speckit-checklist` | Yes (configurable) |
| `/speckit-tasks` | Yes |
| `/speckit-analyze` | Yes (after tasks, before implement) |
| `/speckit-implement` | Yes |
| `/speckit-converge` | Yes, in a loop with implement |

Not included: `taskstoissues`, bug extension, assess extension (separate Spec Kit processes).

**Multi-spec products:** run **`/speckit-auto-spec-portfolio`** first to produce `.specify/product/spec-portfolio.md`, iterate until approved, then run specify or auto-spec per row.

Pipeline details: [pipeline-reference.md](./pipeline-reference.md).

## Quick install (no git clone)

**npm / npx** (recommended): downloads the extension from GitHub; you only need Node + [Spec Kit `specify` CLI](#prerequisites-spec-kit-cli).

```bash
cd your-project
npx @mahmoudelderby/auto-spec install
```

Codex:

```bash
npx @mahmoudelderby/auto-spec install --codex
```

Global CLI (optional): `npm install -g @mahmoudelderby/auto-spec` then `auto-spec install`.

See [README.npm.md](./README.npm.md) for flags (`--project`, `--no-init`, `--tag`).

### Prerequisites (Spec Kit CLI)

One-time per machine ([uv](https://docs.astral.sh/uv/) required):

```bash
uv tool install specify-cli --force --from "git+https://github.com/github/spec-kit.git@v0.15.2"
```

If `npx auto-spec install` finds no `.specify/` folder, it runs `specify init` for you.

### Full bootstrap (PowerShell, includes uv + specify if missing)

```powershell
git clone https://github.com/MahmoudElderby/auto-spec.git
powershell -ExecutionPolicy Bypass -File auto-spec\install.ps1 -ProjectRoot . -Integration cursor-agent
```

Use this only when you cannot install `specify` yourself. **Cloning the repo is not required** for normal installs.

The installer will, when needed:

1. Install **uv** (if missing)
2. Install **specify-cli** from Spec Kit `v0.15.2`
3. Run **`specify init`** with `cursor-agent` or `codex`
4. Install **auto-spec** extension
5. Create **`models.yml`** and sync phase agent binders

### Linux / macOS

```bash
export AUTO_SPEC_INTEGRATION=cursor-agent   # or codex
bash /path/to/auto-spec/install.sh /path/to/your-project
```

## Commands

| Cursor | Codex | Purpose |
|--------|-------|---------|
| `/speckit-auto-spec-portfolio` | `$speckit-auto-spec-portfolio` | **Multi-spec:** build `.specify/product/spec-portfolio.md` before specify |
| `/speckit-auto-spec-run` | `$speckit-auto-spec-run` | Full-auto pipeline |
| `/speckit-auto-spec-review` | `$speckit-auto-spec-review` | Review gates |
| `/speckit-auto-spec-sync-models` | `$speckit-auto-spec-sync-models` | Apply `models.yml` |

Legacy aliases: `speckit-autopilot-*`.

## Configure pipeline + models

Edit `.specify/extensions/auto-spec/models.yml`:

```yaml
pipeline:
  mode: full          # or short
  include_checklist: true
  max_converge_iterations: 5

phases:
  specify: opus-5
  clarify: opus-5
  plan: composer
  tasks: composer
  analyze: composer
  implement: composer
  converge: composer
```

Then sync models (Cursor or Codex).

## Manual install (Spec Kit already initialized)

```powershell
specify extension add --dev C:\path\to\auto-spec --force
powershell -NoProfile -File .\.specify\extensions\auto-spec\scripts\Sync-ModelRouting.ps1
```

From GitHub release:

```powershell
specify extension add auto-spec --from https://github.com/MahmoudElderby/auto-spec/archive/refs/tags/v1.2.0.zip --force
powershell -NoProfile -File .\.specify\extensions\auto-spec\scripts\Install-BundledSkills.ps1
```

## Docs

- [docs/INSTALL.md](./docs/INSTALL.md)

## License

MIT
