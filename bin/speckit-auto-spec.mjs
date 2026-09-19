#!/usr/bin/env node
import { installAutoSpec } from "../lib/install.mjs";

function printHelp() {
  console.log(`
speckit-auto-spec — install Auto Spec (Spec Kit extension) without git clone

Usage:
  npx speckit-auto-spec install [options]

Options:
  --project <dir>       Target project (default: current directory)
  --integration <name>  cursor-agent (default) | codex
  --tag <v1.2.0>        GitHub release tag for extension zip
  --no-init             Skip "specify init" when .specify/ is missing
  --no-sync-models      Skip Sync-ModelRouting.ps1

Prerequisite: Spec Kit CLI on PATH (specify). See README if missing.

Examples:
  npx speckit-auto-spec install
  npx speckit-auto-spec install --integration codex
  npx speckit-auto-spec install --project ./my-app
`);
}

function parseArgs(argv) {
  const cmd = argv[0];
  if (!cmd || cmd === "-h" || cmd === "--help") {
    printHelp();
    process.exit(cmd ? 0 : 1);
  }
  if (cmd !== "install") {
    console.error(`Unknown command: ${cmd}`);
    printHelp();
    process.exit(1);
  }

  const opts = {
    projectRoot: process.cwd(),
    integration: "cursor-agent",
    fromTag: undefined,
    init: true,
    syncModels: true,
  };

  for (let i = 1; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--project") opts.projectRoot = argv[++i];
    else if (a === "--integration") opts.integration = argv[++i];
    else if (a === "--tag") opts.fromTag = argv[++i];
    else if (a === "--no-init") opts.init = false;
    else if (a === "--no-sync-models") opts.syncModels = false;
    else if (a === "--codex") opts.integration = "codex";
    else {
      console.error(`Unknown option: ${a}`);
      process.exit(1);
    }
  }

  if (!["cursor-agent", "codex"].includes(opts.integration)) {
    console.error("--integration must be cursor-agent or codex");
    process.exit(1);
  }

  return opts;
}

const opts = parseArgs(process.argv.slice(2));
await installAutoSpec(opts);
