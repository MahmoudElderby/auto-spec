import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const __dirname = dirname(fileURLToPath(import.meta.url));
const pkg = JSON.parse(
  readFileSync(join(__dirname, "..", "package.json"), "utf8")
);

export const PACKAGE_VERSION = pkg.version;

/** Extension release tag on GitHub (extension.yml may match; zip is source of truth for install). */
export const DEFAULT_EXTENSION_TAG = "v1.2.0";

export function releaseZipUrl(tag = DEFAULT_EXTENSION_TAG) {
  return `https://github.com/MahmoudElderby/auto-spec/archive/refs/tags/${tag}.zip`;
}
