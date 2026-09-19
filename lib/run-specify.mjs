import { spawnSync } from "node:child_process";

function which(cmd) {
  const r = spawnSync(cmd, ["--version"], {
    shell: true,
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"],
  });
  return r.status === 0;
}

export function requireSpecifyCli() {
  if (which("specify")) return;
  console.error(`
Spec Kit CLI (specify) is not on your PATH.

Install it once (requires uv — https://docs.astral.sh/uv/):

  uv tool install specify-cli --force --from "git+https://github.com/github/spec-kit.git@v0.15.2"

Then initialize your project (if .specify/ does not exist yet):

  specify init . --integration cursor-agent --script ps --here --force --ignore-agent-tools

Re-run: npx speckit-auto-spec install
`);
  process.exit(1);
}

/**
 * @param {string[]} args
 * @param {string} [cwd]
 */
export function runSpecify(args, cwd) {
  const result = spawnSync("specify", args, {
    cwd,
    shell: true,
    encoding: "utf8",
    input: "y\n",
    stdio: ["pipe", "inherit", "inherit"],
  });
  if (result.status !== 0) {
    process.exit(result.status ?? 1);
  }
}
