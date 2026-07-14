#!/usr/bin/env bun
//
// prjfork <source> <target> — fork a project directory.
//
// Derived from soma's workspace provisioner (soma/server/src/fleet/
// workspace.ts, `source: "copy"` branch): a *local fork* that keeps the tree
// as-is — including .git, so history/branches come along without the remote
// weirdness a fresh `git clone` would introduce — but SKIPS regenerable junk
// (node_modules, build outputs, caches). See EXCLUDE below; edit to taste.
//
// Both names resolve against the current directory (where you run it):
//   - a bare name      → <cwd>/<name>
//   - a relative path  → resolved against <cwd>
//   - an absolute path → used as-is
//
//   cd ~/prj && prjfork source target   →  ~/prj/source  →  ~/prj/target

import { cpSync, existsSync, readdirSync, statSync } from "node:fs";
import { basename, resolve } from "node:path";

// Directory/file names skipped anywhere in the tree (exact basename match, so
// e.g. `distribution/` is kept while `dist/` is dropped). Regenerable only —
// .git is intentionally NOT here, a fork keeps its history.
const EXCLUDE: ReadonlySet<string> = new Set([
  // deps
  "node_modules",
  ".venv",
  "venv",
  // JS/TS build & framework outputs
  "dist",
  "build",
  "out",
  ".next",
  ".nuxt",
  ".svelte-kit",
  ".output",
  ".astro",
  // caches
  ".turbo",
  ".cache",
  ".parcel-cache",
  ".vite",
  "coverage",
  "__pycache__",
  // other-language build dirs
  "target", // Rust / JVM
  ".gradle",
  // cruft
  ".DS_Store",
]);

type Fork = { sourceAbs: string; targetAbs: string };

function fail(reason: string): never {
  process.stderr.write(`prjfork: ${reason}\n`);
  process.exit(1);
}

function usage(): never {
  process.stderr.write(
    "usage: prjfork <source> <target>   (both resolved against the current directory)\n" +
      "  e.g. cd ~/prj && prjfork voyager voyager-3   fork ./voyager into ./voyager-3\n",
  );
  process.exit(1);
}

function plan(source: string, target: string): Fork {
  // resolve() handles bare names, relative paths, and absolute paths uniformly.
  return { sourceAbs: resolve(source), targetAbs: resolve(target) };
}

function main(): void {
  const [source, target, ...rest] = process.argv.slice(2);
  if (!source || !target || rest.length > 0) usage();

  const { sourceAbs, targetAbs } = plan(source, target);

  if (!existsSync(sourceAbs)) fail(`source not found: ${sourceAbs}`);
  if (!statSync(sourceAbs).isDirectory()) fail(`source is not a directory: ${sourceAbs}`);
  if (sourceAbs === targetAbs) fail("source and target are the same path");
  if (existsSync(targetAbs)) fail(`target already exists: ${targetAbs}`);

  process.stdout.write(`forking ${sourceAbs}\n     -> ${targetAbs}\n`);

  // Surface what we drop at the top level (nested matches are dropped too).
  const droppedTop = readdirSync(sourceAbs)
    .filter((n) => EXCLUDE.has(n))
    .sort();
  if (droppedTop.length > 0) {
    process.stdout.write(`skipping: ${droppedTop.join(", ")} (and any nested occurrences)\n`);
  }

  try {
    cpSync(sourceAbs, targetAbs, {
      recursive: true,
      verbatimSymlinks: true, // copy symlinks as-is, never dereference
      filter: (src) => !EXCLUDE.has(basename(src)),
    });
  } catch (err) {
    fail(`copy failed: ${err instanceof Error ? err.message : String(err)}`);
  }

  process.stdout.write(`done. ${targetAbs}\n`);
}

main();
