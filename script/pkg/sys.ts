import { execFile, spawn } from "node:child_process";
import { accessSync, constants } from "node:fs";
import { join } from "node:path";

export interface Cmd {
  argv: string[];
  env?: Record<string, string>;
}

export interface RunResult {
  code: number;
  stdout: string;
  stderr: string;
}

export function run(argv: string[]): Promise<RunResult> {
  const [bin, ...args] = argv;
  return new Promise((resolve) => {
    execFile(
      bin!,
      args,
      { encoding: "utf8", maxBuffer: 64 * 1024 * 1024 },
      (err, stdout, stderr) => {
        const code = err ? (typeof (err as { code?: unknown }).code === "number" ? (err as { code: number }).code : 1) : 0;
        resolve({ code, stdout: stdout ?? "", stderr: stderr ?? "" });
      },
    );
  });
}

export function runInherit(cmd: Cmd): Promise<number> {
  const [bin, ...args] = cmd.argv;
  return new Promise((resolve) => {
    const child = spawn(bin!, args, { stdio: "inherit", env: { ...process.env, ...cmd.env } });
    child.on("error", () => resolve(127));
    child.on("close", (code) => resolve(code ?? 1));
  });
}

export function which(bin: string): string | null {
  for (const dir of (process.env.PATH ?? "").split(":")) {
    if (!dir) continue;
    const full = join(dir, bin);
    try {
      accessSync(full, constants.X_OK);
      return full;
    } catch {
      continue;
    }
  }
  return null;
}

export function privileged(argv: string[]): string[] {
  const root = typeof process.getuid === "function" && process.getuid() === 0;
  if (root || !which("sudo")) return argv;
  return ["sudo", ...argv];
}

export function shellQuote(argv: string[]): string {
  return argv.map((a) => (/^[\w@%+=:,./-]+$/.test(a) ? a : `'${a.replace(/'/g, `'\\''`)}'`)).join(" ");
}
