# auto-spec (npm)

Thin installer for the [Auto Spec](https://github.com/MahmoudElderby/auto-spec) Spec Kit extension. **No git clone** — downloads the release zip via `specify extension add --from …`.

## One command

```bash
npx @mahmoudelderby/auto-spec install
```

Codex:

```bash
npx @mahmoudelderby/auto-spec install --codex
```

Another directory:

```bash
npx @mahmoudelderby/auto-spec install --project ./my-repo
```

Global (optional):

```bash
npm install -g @mahmoudelderby/auto-spec
auto-spec install
```

## Prerequisites

You need the **Spec Kit CLI** (`specify`) once per machine:

```bash
uv tool install specify-cli --force --from "git+https://github.com/github/spec-kit.git@v0.15.2"
```

If `.specify/` is missing, `auto-spec install` runs `specify init` for you (Cursor or Codex).

## What it does

1. `specify extension add auto-spec --from` GitHub release zip  
2. Creates `models.yml` from template if needed  
3. Copies bundled **spec-portfolio** skill into `.cursor/skills` or `.agents/skills`  
4. Creates `.specify/product/`  
5. Runs model sync when PowerShell is available  

Full docs: [github.com/MahmoudElderby/auto-spec](https://github.com/MahmoudElderby/auto-spec)
