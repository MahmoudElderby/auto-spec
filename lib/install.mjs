import { existsSync, mkdirSync } from "node:fs";
import { resolve } from "node:path";
import { copyBundledSkills } from "./copy-bundled-skills.mjs";
import { ensureModelsYml } from "./ensure-models.mjs";
import { DEFAULT_EXTENSION_TAG, releaseZipUrl } from "./constants.mjs";
import { requireSpecifyCli, runSpecify } from "./run-specify.mjs";
import { spawnSync } from "node:child_process";

/**
 * @param {{
 *   projectRoot?: string;
 *   integration?: "cursor-agent"|"codex";
 *   fromTag?: string;
 *   init?: boolean;
 *   syncModels?: boolean;
 * }} opts
 */
export async function installAutoSpec(opts) {
  const projectRoot = resolve(opts.projectRoot ?? process.cwd());
  const integration = opts.integration ?? "cursor-agent";
  const tag = opts.fromTag ?? DEFAULT_EXTENSION_TAG;
  const zipUrl = releaseZipUrl(tag);

  mkdirSync(projectRoot, { recursive: true });

  requireSpecifyCli();

  const specifyDir = joinSafe(projectRoot, ".specify");
  if (opts.init !== false && !existsSync(specifyDir)) {
    console.log(`Initializing Spec Kit (${integration})…`);
    const initArgs = [
      "init",
      ".",
      "--integration",
      integration,
      "--script",
      process.platform === "win32" ? "ps" : "sh",
      "--here",
      "--force",
      "--ignore-agent-tools",
    ];
    if (integration === "codex") {
      initArgs.push("--integration-options", "--skills");
    }
    runSpecify(initArgs, projectRoot);
  }

  console.log(`Installing Auto Spec extension from ${tag}…`);
  runSpecify(
    ["extension", "add", "auto-spec", "--from", zipUrl, "--force"],
    projectRoot
  );

  ensureModelsYml(projectRoot);
  copyBundledSkills(projectRoot, integration);

  if (opts.syncModels !== false) {
    syncModelsIfPossible(projectRoot);
  }

  printDone(integration);
}

function joinSafe(root, ...parts) {
  return resolve(root, ...parts);
}

function syncModelsIfPossible(projectRoot) {
  const ps1 = resolve(
    projectRoot,
    ".specify",
    "extensions",
    "auto-spec",
    "scripts",
    "Sync-ModelRouting.ps1"
  );
  if (!existsSync(ps1)) return;

  const pwsh =
    spawnSync("pwsh", ["-NoProfile", "-Command", "$null"], {
      encoding: "utf8",
      stdio: "ignore",
    }).status === 0
      ? "pwsh"
      : spawnSync("powershell", ["-NoProfile", "-Command", "$null"], {
            encoding: "utf8",
            stdio: "ignore",
          }).status === 0
        ? "powershell"
        : null;

  if (!pwsh) {
    console.warn(
      "Skipped model sync (PowerShell not found). Run Sync-ModelRouting.ps1 manually if you use models.yml."
    );
    return;
  }

  console.log("Syncing phase model binders…");
  spawnSync(
    pwsh,
    ["-NoProfile", "-File", ps1, "-ProjectRoot", projectRoot],
    { stdio: "inherit", cwd: projectRoot }
  );
}

function printDone(integration) {
  console.log("\nAuto Spec installed.\n");
  if (integration === "codex") {
    console.log("  $speckit-auto-spec-portfolio");
    console.log("  $speckit-auto-spec-run");
  } else {
    console.log("  /speckit-auto-spec-portfolio");
    console.log("  /speckit-auto-spec-run");
  }
}
