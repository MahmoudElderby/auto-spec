import { copyFileSync, existsSync } from "node:fs";
import { join } from "node:path";

export function ensureModelsYml(projectRoot) {
  const extDir = join(projectRoot, ".specify", "extensions", "auto-spec");
  const target = join(extDir, "models.yml");
  if (existsSync(target)) return;

  const template = join(extDir, "models.template.yml");
  if (existsSync(template)) {
    copyFileSync(template, target);
    console.log("Created models.yml from models.template.yml");
  }
}
