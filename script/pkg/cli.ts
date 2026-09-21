#!/usr/bin/env bun
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import {
  type Backend,
  type InstalledPkg,
  type PkgRef,
  refKey,
  refLabel,
  selectBackend,
} from "./backend.ts";
import { type Entry, entriesFor, groupsOf, installGroups, readList } from "./packages.ts";
import { runInherit, shellQuote } from "./sys.ts";

const LIST_FILE = join(dirname(fileURLToPath(import.meta.url)), "packages.json");

const color = process.stdout.isTTY && !process.env.NO_COLOR;
const paint = (code: number) => (s: string) => (color ? `\x1b[${code}m${s}\x1b[0m` : s);
const c = {
  bold: paint(1),
  dim: paint(2),
  red: paint(31),
  green: paint(32),
  yellow: paint(33),
  blue: paint(34),
};

const HELP = `${c.bold("df pkg")} — one software list, installed through apt (Debian) or brew (macOS)

USAGE
  bun run script/pkg/cli.ts <command> [options]

COMMANDS
  status              what the list declares vs what the machine has
  list                every entry with its package name on this backend
  install             install the entries that are missing
  help                show this help

OPTIONS
  --backend <apt|brew>   force a backend (default: brew if present, else apt)
  --group <a,b>          only these groups (status/list default: all,
                         install default: the backend's set in packages.json)
  -n, --dry-run          print the commands instead of running them
  --all                  do not truncate the untracked list
  -h, --help             show this help

The list itself lives in script/pkg/packages.json.`;

interface Options {
  backend?: string;
  groups?: string[];
  dryRun: boolean;
  all: boolean;
  help: boolean;
}

function parseArgs(argv: string[]): { command: string; opts: Options } {
  const opts: Options = { dryRun: false, all: false, help: false };
  const positionals: string[] = [];

  for (let i = 0; i < argv.length; i++) {
    const tok = argv[i]!;
    if (tok === "--backend") opts.backend = argv[++i];
    else if (tok === "--group") opts.groups = (argv[++i] ?? "").split(",").filter(Boolean);
    else if (tok === "-n" || tok === "--dry-run") opts.dryRun = true;
    else if (tok === "--all") opts.all = true;
    else if (tok === "-h" || tok === "--help") opts.help = true;
    else if (tok.startsWith("-")) throw new Error(`unknown option "${tok}"`);
    else positionals.push(tok);
  }
  return { command: positionals[0] ?? "status", opts };
}

function table(rows: string[][]): string {
  const width = (s: string) => s.replace(/\x1b\[[0-9;]*m/g, "").length;
  const widths = rows[0]!.map((_, col) => Math.max(...rows.map((row) => width(row[col] ?? ""))));
  return rows
    .map((row) =>
      row
        .map((cell, col) => cell + " ".repeat(Math.max(0, widths[col]! - width(cell))))
        .join("  ")
        .trimEnd(),
    )
    .join("\n");
}

interface Ctx {
  backend: Backend;
  entries: Entry[];
  allEntries: Entry[];
  installScope: string[];
  installed: Map<string, InstalledPkg>;
  inventory: InstalledPkg[];
  opts: Options;
}

async function context(opts: Options): Promise<Ctx> {
  const backend = selectBackend(opts.backend);
  const list = await readList(LIST_FILE);

  const known = groupsOf(list);
  for (const group of opts.groups ?? []) {
    if (!known.includes(group)) throw new Error(`unknown group "${group}" (have ${known.join(", ")})`);
  }

  const inventory = await backend.inventory();
  const installed = new Map(inventory.map((pkg) => [refKey(pkg), pkg]));
  return {
    backend,
    entries: entriesFor(list, backend.id, opts.groups),
    allEntries: entriesFor(list, backend.id),
    installScope: opts.groups ?? installGroups(list, backend.id),
    installed,
    inventory,
    opts,
  };
}

const missingOf = (ctx: Ctx): Entry[] =>
  ctx.entries.filter((e) => e.ref && !ctx.installed.has(refKey(e.ref)));

const inScope = (ctx: Ctx, entry: Entry): boolean => ctx.installScope.includes(entry.group);

const missingRows = (entries: Entry[]): string[][] =>
  entries.map((e) => [`  ${c.blue("+")} ${e.id}`, refLabel(e.ref!), c.dim(e.group)]);

function untrackedOf(ctx: Ctx): InstalledPkg[] {
  const declared = new Set(ctx.allEntries.flatMap((e) => (e.ref ? [refKey(e.ref)] : [])));
  return ctx.inventory.filter((pkg) => pkg.manual && !declared.has(refKey(pkg)));
}

function cmdStatus(ctx: Ctx): number {
  const declared = ctx.entries.filter((e) => e.ref);
  const missing = missingOf(ctx);
  const wanted = missing.filter((e) => inScope(ctx, e));
  const optional = missing.filter((e) => !inScope(ctx, e));
  const untracked = untrackedOf(ctx);
  const unmapped = ctx.entries.filter((e) => !e.ref);

  if (wanted.length > 0) {
    console.log(c.bold(`missing (${wanted.length})`));
    console.log(table(missingRows(wanted)));
  }

  if (optional.length > 0) {
    const groups = [...new Set(optional.map((e) => e.group))];
    console.log(
      c.bold(`\nmissing outside the ${ctx.backend.id} install set (${optional.length})`) +
        c.dim(`  install with --group ${groups.join(",")}`),
    );
    console.log(table(missingRows(optional)));
  }

  if (untracked.length > 0) {
    console.log(c.bold(`\nuntracked (${untracked.length})`) + c.dim("  installed by hand, not in packages.json"));
    const shown = ctx.opts.all ? untracked : untracked.slice(0, 15);
    console.log(table(shown.map((pkg) => [`  ${c.yellow("?")} ${pkg.name}${pkg.cask ? c.dim(" (cask)") : ""}`, c.dim(pkg.version)])));
    if (shown.length < untracked.length) {
      console.log(c.dim(`  … ${untracked.length - shown.length} more (--all)`));
    }
  }

  if (missing.length === 0 && untracked.length === 0) {
    console.log(`${c.green("✓")} list and machine agree`);
  }

  const parts = [
    `${declared.length} declared`,
    `${declared.length - missing.length} installed`,
    wanted.length > 0 ? c.blue(`${wanted.length} missing`) : "0 missing",
    untracked.length > 0 ? c.yellow(`${untracked.length} untracked`) : "0 untracked",
  ];
  if (optional.length > 0) parts.push(c.dim(`${optional.length} outside the install set`));
  if (unmapped.length > 0) parts.push(c.dim(`${unmapped.length} not via ${ctx.backend.id}`));
  console.log(c.dim(`\n— backend ${ctx.backend.id} · install set ${ctx.installScope.join(",")} · ${parts.join(" · ")}`));
  return 0;
}

function cmdList(ctx: Ctx): number {
  const rows = [[c.bold("GROUP"), c.bold("NAME"), c.bold("PACKAGE"), c.bold("STATUS"), c.bold("VERSION"), ""]];
  for (const entry of ctx.entries) {
    const pkg = entry.ref ? ctx.installed.get(refKey(entry.ref)) : undefined;
    const status = !entry.ref ? c.dim("—") : pkg ? c.green("ok") : c.blue("missing");
    rows.push([
      c.dim(entry.group),
      entry.id,
      entry.ref ? refLabel(entry.ref) : c.dim("—"),
      status,
      pkg ? c.dim(pkg.version) : c.dim("—"),
      entry.note ? c.dim(entry.note) : "",
    ]);
  }
  console.log(table(rows));
  console.log(c.dim(`\n— backend ${ctx.backend.id} · ${ctx.entries.length} entries`));
  return 0;
}

async function cmdInstall(ctx: Ctx): Promise<number> {
  const missing = missingOf(ctx).filter((entry) => inScope(ctx, entry));
  const scope = ctx.installScope.join(",");
  if (missing.length === 0) {
    console.log(`${c.green("✓")} nothing to install — ${scope} is fully present`);
    return 0;
  }

  const refs: PkgRef[] = missing.map((entry) => entry.ref!);
  console.log(c.bold(`installing ${missing.length} package(s) via ${ctx.backend.id}`) + c.dim(` (${scope})`));
  console.log(table(missingRows(missing)));

  const cmds = [...ctx.backend.refreshCommands(), ...ctx.backend.installCommands(refs)];
  for (const cmd of cmds) {
    console.log(c.dim(`\n$ ${shellQuote(cmd.argv)}`));
    if (ctx.opts.dryRun) continue;
    const code = await runInherit(cmd);
    if (code !== 0) {
      console.error(c.red(`command failed with exit code ${code}`));
      return code;
    }
  }
  if (ctx.opts.dryRun) console.log(c.dim("\n(dry run — nothing was installed)"));
  return 0;
}

async function main(argv: string[]): Promise<number> {
  const { command, opts } = parseArgs(argv);
  if (opts.help || command === "help") {
    console.log(HELP);
    return 0;
  }

  const ctx = await context(opts);
  switch (command) {
    case "status":
      return cmdStatus(ctx);
    case "list":
    case "ls":
      return cmdList(ctx);
    case "install":
      return cmdInstall(ctx);
    default:
      throw new Error(`unknown command "${command}" — try \`help\``);
  }
}

main(process.argv.slice(2))
  .then((code) => process.exit(code))
  .catch((err: Error) => {
    console.error(`${c.red("error")} ${err.message}`);
    process.exit(1);
  });
