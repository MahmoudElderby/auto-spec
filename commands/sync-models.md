---
description: "Sync models.yml into phase agent binders for Cursor (.cursor/agents) and Codex (.agents/agents)."
---

# Auto Spec - sync models

## User Input

```text
$ARGUMENTS
```

## Steps

1. Edit `.specify/extensions/auto-spec/models.yml` (phases, aliases, pipeline section).
2. Run:

```powershell
powershell -NoProfile -File ".specify\extensions\auto-spec\scripts\Sync-ModelRouting.ps1"
```

3. Verify `.specify/extensions/auto-spec/models.resolved.json` and agent files under:
   - `.cursor/agents/speckit-*.md` (Cursor)
   - `.agents/agents/speckit-*.md` (Codex)

4. Confirm active integration in `.specify/integration.json` (`cursor-agent` or `codex`) and use matching invoke style in autopilot runs.
