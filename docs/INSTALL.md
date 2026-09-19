# Installation

## One-command bootstrap (recommended)

### Cursor

```powershell
powershell -ExecutionPolicy Bypass -File path\to\auto-spec\install.ps1 `
  -ProjectRoot C:\dev\my-app `
  -Integration cursor-agent
```

### Codex

```powershell
powershell -ExecutionPolicy Bypass -File path\to\auto-spec\install.ps1 `
  -ProjectRoot C:\dev\my-app `
  -Integration codex
```

Parameters:

| Parameter | Default | Description |
|-----------|---------|-------------|
| `-ProjectRoot` | current directory | Target repo (created if missing) |
| `-Integration` | `cursor-agent` | `cursor-agent` or `codex` |
| `-SpecKitVersion` | `v0.15.2` | Git tag for specify-cli |
| `-FromUrl` | (none) | Install extension from release zip instead of local clone |
| `-SkipSpecKitBootstrap` | false | Skip uv/specify/init (project must already have `.specify/`) |
| `-SkipModelSync` | false | Skip agent binder generation |

## What gets installed

| Component | Cursor | Codex |
|-----------|--------|-------|
| Spec Kit skills | `.cursor/skills/speckit-*` | `.agents/skills/speckit-*` |
| Auto Spec skills | `.cursor/skills/speckit-auto-spec-*` | `.agents/skills/speckit-auto-spec-*` |
| Phase agent binders (sync) | `.cursor/agents/speckit-*` | `.agents/agents/speckit-*` |
| Extension files | `.specify/extensions/auto-spec/` | same |

## Already have Spec Kit?

```powershell
cd your-project
specify extension add --dev C:\work\ai\auto-spec --force
powershell -NoProfile -File .\.specify\extensions\auto-spec\scripts\Sync-ModelRouting.ps1
```

## Switch integration later

Re-run init only if you know what you are doing (may overwrite managed files):

```powershell
specify integration switch codex --force
# or
specify integration switch cursor-agent --force
```

Re-install Auto Spec and sync models after switching.

## Verify

```powershell
specify extension list
specify integration status
```

In agent chat:

- Cursor: `/speckit-auto-spec-run Build a hello-world CLI`
- Codex: `$speckit-auto-spec-run Build a hello-world CLI`
