#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="${1:-.}"
INTEGRATION="${AUTO_SPEC_INTEGRATION:-cursor-agent}"
EXT_PATH="${AUTO_SPEC_PATH:-$(cd "$(dirname "$0")" && pwd)}"
FROM_URL="${AUTO_SPEC_FROM_URL:-}"
SPECKIT_TAG="${SPECKIT_TAG:-v0.15.2}"
SKIP_BOOT="${AUTO_SPEC_SKIP_BOOTSTRAP:-0}"

export PYTHONIOENCODING=utf-8
export PYTHONUTF8=1

ensure_uv() {
  if command -v uv >/dev/null 2>&1; then return; fi
  echo "Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
}

ensure_specify() {
  ensure_uv
  if ! command -v specify >/dev/null 2>&1; then
    echo "Installing specify-cli ($SPECKIT_TAG)..."
    uv tool install specify-cli --force --from "git+https://github.com/github/spec-kit.git@${SPECKIT_TAG}"
  fi
  export PATH="$HOME/.local/bin:$PATH"
}

init_spec_kit() {
  if [[ -d "$PROJECT_ROOT/.specify" ]]; then return; fi
  echo "Initializing Spec Kit (integration=$INTEGRATION)..."
  cd "$PROJECT_ROOT"
  if [[ "$INTEGRATION" == "codex" ]]; then
    specify init . --integration codex --script sh --here --force --ignore-agent-tools --integration-options="--skills"
  else
    specify init . --integration cursor-agent --script sh --here --force --ignore-agent-tools
  fi
}

cd "$PROJECT_ROOT"
mkdir -p "$PROJECT_ROOT"

if [[ "$SKIP_BOOT" != "1" ]]; then
  ensure_specify
  init_spec_kit
fi

if [[ -n "$FROM_URL" ]]; then
  specify extension add auto-spec --from "$FROM_URL" --force
else
  specify extension add --dev "$EXT_PATH" --force
fi

EXT_DIR="$PROJECT_ROOT/.specify/extensions/auto-spec"
if command -v pwsh >/dev/null 2>&1 && [[ -f "$EXT_DIR/scripts/Install-BundledSkills.ps1" ]]; then
  pwsh -NoProfile -File "$EXT_DIR/scripts/Install-BundledSkills.ps1" -ProjectRoot "$PROJECT_ROOT" -Integration "$INTEGRATION" -ExtensionPath "$EXT_DIR"
fi
if [[ ! -f "$EXT_DIR/models.yml" && -f "$EXT_PATH/models.template.yml" ]]; then
  cp "$EXT_PATH/models.template.yml" "$EXT_DIR/models.yml"
fi
if [[ -f "$EXT_PATH/pipeline-reference.md" ]]; then
  cp "$EXT_PATH/pipeline-reference.md" "$EXT_DIR/pipeline-reference.md"
fi

SYNC="$EXT_PATH/scripts/Sync-ModelRouting.ps1"
if [[ -f "$SYNC" ]] && command -v pwsh >/dev/null 2>&1; then
  pwsh -NoProfile -File "$SYNC" -ProjectRoot "$(pwd)"
elif [[ -f "$EXT_DIR/scripts/Sync-ModelRouting.ps1" ]] && command -v pwsh >/dev/null 2>&1; then
  pwsh -NoProfile -File "$EXT_DIR/scripts/Sync-ModelRouting.ps1" -ProjectRoot "$(pwd)"
fi

echo "Done. Integration=$INTEGRATION"
if [[ "$INTEGRATION" == "codex" ]]; then
  echo "  \$speckit-auto-spec-portfolio"
  echo "  \$speckit-auto-spec-run"
else
  echo "  /speckit-auto-spec-portfolio"
  echo "  /speckit-auto-spec-run"
fi
