import { readdir } from "node:fs/promises";
import { join } from "node:path";
import type { Backend, InstalledPkg, PkgRef } from "./backend.ts";
import { type Cmd, run } from "./sys.ts";

function fullName(ref: PkgRef): string {
  return ref.tap ? `${ref.tap}/${ref.name}` : ref.name;
}

export class BrewBackend implements Backend {
  readonly id = "brew" as const;

  async inventory(): Promise<InstalledPkg[]> {
    const formulae = await run(["brew", "list", "--formula", "--versions"]);
    if (formulae.code !== 0) {
      throw new Error(`brew list failed: ${formulae.stderr.trim() || formulae.stdout.trim()}`);
    }

    const requested = new Set<string>();
    const leaves = await run(["brew", "leaves", "--installed-on-request"]);
    for (const line of leaves.stdout.split("\n")) {
      const name = line.trim();
      if (name) requested.add(name);
    }

    const pkgs: InstalledPkg[] = [];
    for (const line of formulae.stdout.split("\n")) {
      const [name, ...versions] = line.trim().split(/\s+/);
      if (!name || versions.length === 0) continue;
      pkgs.push({ name, version: versions[0]!, manual: requested.has(name) });
    }
    for (const [token, version] of await this.casks()) {
      pkgs.push({ name: token, version, manual: true, cask: true });
    }
    return pkgs;
  }

  private async casks(): Promise<[string, string][]> {
    const list = await run(["brew", "list", "--cask"]);
    if (list.code !== 0) return [];
    const prefix = (await run(["brew", "--prefix"])).stdout.trim() || "/opt/homebrew";

    const casks: [string, string][] = [];
    for (const line of list.stdout.split("\n")) {
      const token = line.trim();
      if (!token) continue;
      // `brew list --cask --versions` refuses to read casks from untrusted
      // taps, so take the version from the Caskroom layout instead.
      const versions = (await readdir(join(prefix, "Caskroom", token)).catch(() => [] as string[]))
        .filter((entry) => !entry.startsWith("."));
      casks.push([token, versions[0] ?? "installed"]);
    }
    return casks;
  }

  refreshCommands(): Cmd[] {
    return [];
  }

  installCommands(refs: PkgRef[]): Cmd[] {
    const formulae = refs.filter((ref) => !ref.cask).map(fullName);
    const casks = refs.filter((ref) => ref.cask).map(fullName);

    const cmds: Cmd[] = [];
    if (formulae.length > 0) cmds.push({ argv: ["brew", "install", ...formulae] });
    if (casks.length > 0) cmds.push({ argv: ["brew", "install", "--cask", ...casks] });
    return cmds;
  }
}
