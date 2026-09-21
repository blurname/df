import type { Backend, InstalledPkg, PkgRef } from "./backend.ts";
import { type Cmd, privileged, run } from "./sys.ts";

const APT_ENV = { DEBIAN_FRONTEND: "noninteractive" };
const DPKG_OPTS = ["-o", "Dpkg::Options::=--force-confold", "-o", "Dpkg::Options::=--force-confdef"];

export class AptBackend implements Backend {
  readonly id = "apt" as const;

  async inventory(): Promise<InstalledPkg[]> {
    const query = await run(["dpkg-query", "-W", "-f=${db:Status-Status}\t${Package}\t${Version}\n"]);
    if (query.code !== 0) {
      throw new Error(`dpkg-query failed: ${query.stderr.trim() || query.stdout.trim()}`);
    }

    const manual = new Set<string>();
    const marks = await run(["apt-mark", "showmanual"]);
    for (const line of marks.stdout.split("\n")) {
      const name = line.trim();
      if (name) manual.add(name.split(":")[0]!);
    }

    const pkgs: InstalledPkg[] = [];
    for (const line of query.stdout.split("\n")) {
      const [status, name, version] = line.split("\t");
      if (status !== "installed" || !name || !version) continue;
      pkgs.push({ name, version, manual: manual.has(name) });
    }
    return pkgs;
  }

  refreshCommands(): Cmd[] {
    return [{ argv: privileged(["apt-get", "update", "-qq"]), env: APT_ENV }];
  }

  installCommands(refs: PkgRef[]): Cmd[] {
    if (refs.length === 0) return [];
    const argv = privileged([
      "apt-get",
      "install",
      "-y",
      "--no-install-recommends",
      ...DPKG_OPTS,
      ...refs.map((ref) => ref.name),
    ]);
    return [{ argv, env: APT_ENV }];
  }
}
