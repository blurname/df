import { readFile } from "node:fs/promises";
import type { BackendId, PkgRef } from "./backend.ts";

export type BrewSpec = string | { formula?: string; cask?: string; tap?: string };
export type RawEntry = string | { apt?: string; brew?: BrewSpec; note?: string };

export interface PackageList {
  install?: Partial<Record<BackendId, string[]>>;
  groups: Record<string, Record<string, RawEntry>>;
}

export interface Entry {
  group: string;
  id: string;
  ref: PkgRef | null;
  note: string | null;
}

export async function readList(file: string): Promise<PackageList> {
  const list = JSON.parse(await readFile(file, "utf8")) as PackageList;
  for (const [backend, groups] of Object.entries(list.install ?? {})) {
    for (const group of groups) {
      if (!(group in list.groups)) {
        throw new Error(`install.${backend} refers to unknown group "${group}"`);
      }
    }
  }
  return list;
}

export function groupsOf(list: PackageList): string[] {
  return Object.keys(list.groups);
}

export function installGroups(list: PackageList, backend: BackendId): string[] {
  return list.install?.[backend] ?? groupsOf(list);
}

export function entriesFor(list: PackageList, backend: BackendId, groups?: string[]): Entry[] {
  const entries: Entry[] = [];
  for (const [group, items] of Object.entries(list.groups)) {
    if (groups && !groups.includes(group)) continue;
    for (const [id, raw] of Object.entries(items)) {
      entries.push({
        group,
        id,
        ref: resolveRef(raw, backend),
        note: typeof raw === "object" && raw.note ? raw.note : null,
      });
    }
  }
  return entries;
}

export function resolveRef(raw: RawEntry, backend: BackendId): PkgRef | null {
  if (typeof raw === "string") return { name: raw };
  if (backend === "apt") return raw.apt ? { name: raw.apt } : null;

  const brew = raw.brew;
  if (!brew) return null;
  if (typeof brew === "string") return { name: brew };
  if (brew.cask) return { name: brew.cask, cask: true, ...(brew.tap ? { tap: brew.tap } : {}) };
  if (brew.formula) return { name: brew.formula, ...(brew.tap ? { tap: brew.tap } : {}) };
  return null;
}
