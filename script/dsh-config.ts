#!/usr/bin/env bun
/**
 * Sync DSH (DeepSeek Harness) user config between $HOME and this dotfiles repo.
 *
 * Why copies instead of the symlinks in script/01-link-config.ts: both the
 * profile patch (dsh-config-editor -> writeFileAtomic) and ~/.dsh-tui/settings.json
 * (writeTuiSettings) are replaced through rename(2), so a symlink would be swapped
 * for a fresh regular file and the sync would silently stop.
 *
 *   bun script/dsh-config.ts push    $HOME -> repo   (after changing settings)
 *   bun script/dsh-config.ts pull    repo -> $HOME   (new machine, after first run)
 *   bun script/dsh-config.ts status  report drift, change nothing
 *
 * Credentials (~/.dsh/.credentials.yaml), sessions and caches are never copied.
 */
import { copyFileSync, existsSync, mkdirSync, readFileSync, statSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join } from "node:path";

const HOME = homedir();
const REPO = join(HOME, "df/config/dsh");

/** [path under $HOME, matching path under config/dsh] */
const PAIRS: [homeRel: string, repoRel: string][] = [
  [".dsh/profiles/dsh-tui/cordis.patch.yml", "profiles/dsh-tui/cordis.patch.yml"],
  [".dsh/profiles/web/cordis.patch.yml", "profiles/web/cordis.patch.yml"],
  [".dsh/profiles/headless/cordis.patch.yml", "profiles/headless/cordis.patch.yml"],
  [".dsh-tui/settings.json", "tui/settings.json"],
  [".dsh-tui/theme.json", "tui/theme.json"],
  [".dsh-tui/effort.json", "tui/effort.json"],
  [".dsh-tui/model.json", "tui/model.json"],
];

interface Entry {
  label: string;
  home: string;
  repo: string;
}

const entries: Entry[] = PAIRS.map(([homeRel, repoRel]) => ({
  label: `~/${homeRel}`,
  home: join(HOME, homeRel),
  repo: join(REPO, repoRel),
}));

function same(fileA: string, fileB: string): boolean {
  try {
    if (statSync(fileA).size !== statSync(fileB).size) return false;
    return readFileSync(fileA).equals(readFileSync(fileB));
  } catch {
    return false;
  }
}

function timestamp(): string {
  return new Date().toISOString().replace(/[:.]/g, "-");
}

function push(dryRun: boolean): void {
  let copied = 0;
  for (const entry of entries) {
    if (!existsSync(entry.home)) {
      console.log(`-  ${entry.label}  (missing locally, skipped)`);
      continue;
    }
    if (existsSync(entry.repo) && same(entry.home, entry.repo)) {
      console.log(`=  ${entry.label}`);
      continue;
    }
    console.log(`↑  ${entry.label}`);
    if (dryRun) continue;
    mkdirSync(dirname(entry.repo), { recursive: true });
    copyFileSync(entry.home, entry.repo);
    copied += 1;
  }
  console.log(dryRun ? "\n(dry run, nothing written)" : `\n${copied} file(s) updated in config/dsh`);
}

function pull(dryRun: boolean): void {
  let restored = 0;
  const stamp = timestamp();
  for (const entry of entries) {
    if (!existsSync(entry.repo)) {
      console.log(`-  ${entry.label}  (not in config/dsh, skipped)`);
      continue;
    }
    if (existsSync(entry.home) && same(entry.repo, entry.home)) {
      console.log(`=  ${entry.label}`);
      continue;
    }
    if (existsSync(entry.home)) {
      const backup = `${entry.home}.before-dsh-pull-${stamp}`;
      console.log(`↓  ${entry.label}  (backup: ${backup})`);
      if (!dryRun) copyFileSync(entry.home, backup);
    } else {
      console.log(`↓  ${entry.label}  (new)`);
    }
    if (dryRun) continue;
    mkdirSync(dirname(entry.home), { recursive: true });
    copyFileSync(entry.repo, entry.home);
    restored += 1;
  }
  console.log(dryRun ? "\n(dry run, nothing written)" : `\n${restored} file(s) restored from config/dsh`);
}

function status(): void {
  let drift = 0;
  for (const entry of entries) {
    const homeExists = existsSync(entry.home);
    const repoExists = existsSync(entry.repo);
    if (!homeExists && !repoExists) {
      console.log(`?  ${entry.label}  (neither side exists)`);
      drift += 1;
    } else if (!repoExists) {
      console.log(`→  ${entry.label}  (only local; run push)`);
      drift += 1;
    } else if (!homeExists) {
      console.log(`←  ${entry.label}  (only in repo; run pull)`);
      drift += 1;
    } else if (same(entry.home, entry.repo)) {
      console.log(`=  ${entry.label}`);
    } else {
      console.log(`≠  ${entry.label}  (differs; push or pull)`);
      drift += 1;
    }
  }
  console.log(drift === 0 ? "\nlocal and config/dsh are in sync" : `\n${drift} path(s) out of sync`);
}

const [command, ...flags] = process.argv.slice(2);
const dryRun = flags.includes("--dry-run") || flags.includes("-n");

switch (command) {
  case "push":
    push(dryRun);
    break;
  case "pull":
    pull(dryRun);
    break;
  case "status":
    status();
    break;
  default:
    console.log(`Usage: bun script/dsh-config.ts <push|pull|status> [--dry-run]

  push    copy $HOME config into config/dsh (after editing settings in the app)
  pull    restore config/dsh into $HOME (new machine, after the first dsh-tui run)
  status  show which paths differ

Synced: profile patches for dsh-tui/web/headless, plus ~/.dsh-tui
settings/theme/effort/model. Credentials, sessions and caches stay local.`);
    process.exit(command === undefined || command === "help" ? 0 : 1);
}
