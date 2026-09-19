import { cpSync, existsSync, mkdirSync, readdirSync, rmSync } from "node:fs";
import { join } from "node:path";

/**
 * @param {string} projectRoot
 * @param {"cursor-agent"|"codex"} integration
 */
export function copyBundledSkills(projectRoot, integration) {
  const extDir = join(projectRoot, ".specify", "extensions", "auto-spec");
  const skillsSrc = join(extDir, "skills");
  if (!existsSync(skillsSrc)) {
    console.warn(`No bundled skills at ${skillsSrc}`);
    return;
  }

  const destRoot =
    integration === "codex" ? join(".agents", "skills") : join(".cursor", "skills");
  const destBase = join(projectRoot, destRoot);
  mkdirSync(destBase, { recursive: true });

  for (const name of readdirSync(skillsSrc, { withFileTypes: true })) {
    if (!name.isDirectory()) continue;
    const dest = join(destBase, name.name);
    if (existsSync(dest)) rmSync(dest, { recursive: true, force: true });
    cpSync(join(skillsSrc, name.name), dest, { recursive: true });
    console.log(`Installed bundled skill: ${destRoot}/${name.name}`);
  }

  const productDir = join(projectRoot, ".specify", "product");
  if (!existsSync(productDir)) {
    mkdirSync(productDir, { recursive: true });
    console.log("Created .specify/product/");
  }
}
