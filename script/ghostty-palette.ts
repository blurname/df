#!/usr/bin/env bun

const BASE = ["#af5f5f", "#5f885f", "#af8760", "#5f87ae", "#875f87", "#5f8787"];
const GREY = "#4e4e4e";
const SELECTION = "#afd7d7";

interface Tiers {
  bg: string;
  fg: string;
  dim: number;
  normal: number;
  bright: number;
  black: number;
  brightSaturation: number;
}

const DEFAULTS: Tiers = {
  bg: "#dadada",
  fg: GREY,
  dim: 2.4,
  normal: 3.8,
  bright: 5.6,
  black: 7.9,
  brightSaturation: 1.15,
};

type Rgb = [number, number, number];

function parseHex(hex: string): Rgb {
  const h = hex.replace("#", "");
  return [0, 2, 4].map((i) => parseInt(h.slice(i, i + 2), 16) / 255) as Rgb;
}

function toHex([r, g, b]: Rgb): string {
  return "#" + [r, g, b].map((c) => Math.round(c * 255).toString(16).padStart(2, "0")).join("");
}

function luminance(hex: string): number {
  const [r, g, b] = parseHex(hex).map((c) => (c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4));
  return 0.2126 * r! + 0.7152 * g! + 0.0722 * b!;
}

export function contrast(a: string, b: string): number {
  const [hi, lo] = [luminance(a), luminance(b)].sort((x, y) => y - x);
  return (hi! + 0.05) / (lo! + 0.05);
}

function rgbToHls([r, g, b]: Rgb): [number, number, number] {
  const max = Math.max(r, g, b);
  const min = Math.min(r, g, b);
  const l = (max + min) / 2;
  if (max === min) return [0, l, 0];

  const range = max - min;
  const s = l <= 0.5 ? range / (max + min) : range / (2 - max - min);
  const [rc, gc, bc] = [(max - r) / range, (max - g) / range, (max - b) / range];
  const h = r === max ? bc - gc : g === max ? 2 + rc - bc : 4 + gc - rc;
  return [(h / 6 + 1) % 1, l, s];
}

function hlsToRgb(h: number, l: number, s: number): Rgb {
  if (s === 0) return [l, l, l];
  const m2 = l <= 0.5 ? l * (1 + s) : l + s - l * s;
  const m1 = 2 * l - m2;
  const channel = (hue: number) => {
    hue = (hue % 1 + 1) % 1;
    if (hue < 1 / 6) return m1 + (m2 - m1) * hue * 6;
    if (hue < 0.5) return m2;
    if (hue < 2 / 3) return m1 + (m2 - m1) * (2 / 3 - hue) * 6;
    return m1;
  };
  return [channel(h + 1 / 3), channel(h), channel(h - 1 / 3)];
}

function search(lo: number, hi: number, darkEnough: (l: number) => boolean): number {
  for (let i = 0; i < 80; i++) {
    const mid = (lo + hi) / 2;
    if (darkEnough(mid)) lo = mid;
    else hi = mid;
  }
  return (lo + hi) / 2;
}

function retune(source: string, target: number, tiers: Tiers, saturation = 1): string {
  const [h, l, s0] = rgbToHls(parseHex(source));
  const s = Math.min(s0 * saturation, 1);
  const at = (lightness: number) => toHex(hlsToRgb(h, lightness, s));

  const bgLuminance = luminance(tiers.bg);
  const ceiling = search(0, 1, (lightness) => luminance(at(lightness)) < bgLuminance);
  return at(search(0, ceiling, (lightness) => contrast(at(lightness), tiers.bg) >= target));
}

export function palette(tiers: Tiers = DEFAULTS): string[] {
  // Every slot is solved on the darker-than-background side, so a dark
  // background would clamp the whole palette to black instead of inverting.
  if (luminance(tiers.bg) < 0.5) throw new Error(`${tiers.bg} is a dark background — this generator only solves light ones`);

  const slots: string[] = [];
  slots[0] = retune(GREY, tiers.black, tiers);
  slots[7] = retune(GREY, tiers.normal, tiers);
  slots[8] = retune(GREY, tiers.dim, tiers);
  slots[15] = retune(GREY, tiers.bright, tiers);
  BASE.forEach((source, i) => {
    slots[i + 1] = retune(source, tiers.normal, tiers);
    slots[i + 9] = retune(source, tiers.bright, tiers, tiers.brightSaturation);
  });
  return slots;
}

function configBlock(tiers: Tiers): string {
  const slots = palette(tiers);
  return [
    `background = ${tiers.bg}`,
    `foreground = ${tiers.fg}`,
    `cursor-color = ${slots[4]}`,
    `cursor-text = ${tiers.bg}`,
    `selection-background = ${SELECTION}`,
    `selection-foreground = ${slots[0]}`,
    ...slots.map((hex, i) => `palette = ${i}=${hex}`),
  ].join("\n");
}

function shade(hex: string, delta: number): string {
  const [h, l, s] = rgbToHls(parseHex(hex));
  return toHex(hlsToRgb(h, Math.min(Math.max(l + delta, 0), 1), s));
}

// herdr paints its chrome with 16 named tokens; map them onto the same ramp so
// the multiplexer and the terminal underneath never disagree.
function herdrTheme(tiers: Tiers): string {
  const slots = palette(tiers);
  const pairs: [string, string][] = [
    ["accent", slots[4]!],
    ["blue", slots[4]!],
    ["mauve", slots[5]!],
    ["red", slots[1]!],
    ["green", slots[2]!],
    ["yellow", slots[3]!],
    ["teal", slots[6]!],
    ["peach", slots[11]!],
    ["text", tiers.fg],
    ["subtext0", slots[7]!],
    ["overlay0", retune(GREY, 3.0, tiers)],
    ["overlay1", slots[15]!],
    ["panel_bg", shade(tiers.bg, 0.04)],
    ["surface0", shade(tiers.bg, -0.05)],
    ["surface1", shade(tiers.bg, -0.1)],
    ["surface_dim", shade(tiers.bg, -0.03)],
  ];
  const width = Math.max(...pairs.map(([key]) => key.length));
  return ["[theme.custom]", ...pairs.map(([key, hex]) => `${key.padEnd(width)} = "${hex}"`)].join("\n");
}

const NAMES = [
  "black", "red", "green", "yellow", "blue", "magenta", "cyan", "white",
  "br black", "br red", "br green", "br yellow", "br blue", "br magenta", "br cyan", "br white",
];

function contrastTable(tiers: Tiers): string {
  const rows = palette(tiers).map(
    (hex, i) =>
      `${String(i).padStart(2)} ${NAMES[i]!.padEnd(10)} ${hex}  ${contrast(hex, tiers.bg).toFixed(1).padStart(5)}:1`,
  );
  return [
    `background ${tiers.bg}   foreground ${tiers.fg}  ${contrast(tiers.fg, tiers.bg).toFixed(1)}:1`,
    `tiers: dim ${tiers.dim} · normal ${tiers.normal} · bright ${tiers.bright} · black ${tiers.black}`,
    "",
    ...rows,
  ].join("\n");
}

const HELP = `ghostty-palette — regenerate the 16 ANSI colors for config/ghostty/config

  bun run script/ghostty-palette.ts [--bg #dadada] [--fg #4e4e4e]
      [--dim 2.4] [--normal 3.8] [--bright 5.6] [--black 7.9] [--table] [--herdr]

Keeps the hue and saturation of the muted base colors and solves each slot's
lightness for a target WCAG contrast against the background, so every tier
stays readable when the background changes. --table shows the ratios instead
of the config block, --herdr the matching [theme.custom] for herdr's config.toml.`;

function main(argv: string[]): number {
  const tiers = { ...DEFAULTS };
  let table = false;
  let herdr = false;

  for (let i = 0; i < argv.length; i++) {
    const [flag, inline] = argv[i]!.split("=", 2);
    const value = inline ?? argv[++i];
    switch (flag) {
      case "--table": table = true; i -= value === undefined ? 0 : 1; break;
      case "--herdr": herdr = true; i -= value === undefined ? 0 : 1; break;
      case "--bg": tiers.bg = value!; break;
      case "--fg": tiers.fg = value!; break;
      case "--dim": tiers.dim = Number(value); break;
      case "--normal": tiers.normal = Number(value); break;
      case "--bright": tiers.bright = Number(value); break;
      case "--black": tiers.black = Number(value); break;
      case "-h": case "--help": console.log(HELP); return 0;
      default: console.error(`unknown option "${flag}"`); return 1;
    }
  }
  try {
    console.log(herdr ? herdrTheme(tiers) : table ? contrastTable(tiers) : configBlock(tiers));
  } catch (err) {
    console.error(`error ${(err as Error).message}`);
    return 1;
  }
  return 0;
}

if (import.meta.main) process.exit(main(process.argv.slice(2)));
