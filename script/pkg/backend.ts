import { AptBackend } from "./apt.ts";
import { BrewBackend } from "./brew.ts";
import { type Cmd, which } from "./sys.ts";

export type BackendId = "apt" | "brew";

export const BACKEND_IDS: BackendId[] = ["apt", "brew"];

export interface PkgRef {
  name: string;
  cask?: boolean;
  tap?: string;
}

export interface InstalledPkg {
  name: string;
  version: string;
  manual: boolean;
  cask?: boolean;
}

export interface Backend {
  readonly id: BackendId;
  inventory(): Promise<InstalledPkg[]>;
  refreshCommands(): Cmd[];
  installCommands(refs: PkgRef[]): Cmd[];
}

export function refKey(ref: { name: string; cask?: boolean }): string {
  return ref.cask ? `cask:${ref.name}` : ref.name;
}

export function refLabel(ref: PkgRef): string {
  const full = ref.tap ? `${ref.tap}/${ref.name}` : ref.name;
  return ref.cask ? `${full} (cask)` : full;
}

export function selectBackend(explicit?: string): Backend {
  if (explicit && !(BACKEND_IDS as string[]).includes(explicit)) {
    throw new Error(`unknown backend "${explicit}" (expected ${BACKEND_IDS.join(" or ")})`);
  }
  const id = explicit ?? (which("brew") ? "brew" : which("apt-get") ? "apt" : null);
  if (!id) throw new Error("no supported package manager found (need brew or apt-get) — pass --backend");
  return id === "apt" ? new AptBackend() : new BrewBackend();
}
