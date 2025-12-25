#!/usr/bin/env bun

import { existsSync, lstatSync, rmSync, symlinkSync, mkdirSync } from "fs";
import { dirname, join } from "path";
import { homedir, platform } from "os";

const HOME = homedir();
const DF = join(HOME, "df/config");

// 根据操作系统设置 lazygit 配置路径
const lazygitConfigPath =
  platform() === "darwin"
    ? join(HOME, "Library/Application Support/lazygit")
    : join(HOME, ".config/lazygit");

type LinkDef = [linkRel: string, targetRel: string];
type AbsoluteLinkDef = [linkPath: string, targetPath: string];

// 定义链接列表: [链接位置(相对HOME), 目标路径(相对DF)]
const links: LinkDef[] = [
  [".config/alacritty", "alacritty"],
  [".config/.Xmodmap", ".Xmodmap"],
  [".config/.pam_environment", ".pam_environment"],
  [".config/waybar", "waybar"],
  [".config/fcitx5", "fcitx5"],
  [".config/kitty", "kitty"],
  [".config/elvish", "elvish"],
  [".config/zellij", "zellij"],
  [".config/bottom", "bottom"],
  [".config/btop", "btop"],
  [".config/hypr", "hypr"],
  [".xinitrc", ".xinitrc"],
  [".config/carapace", "carapace"],
  [".config/starship.toml", "starship.toml"],
  [".config/ghostty/config", "ghostty/config"],
  [".tmux.conf", "tmux/.tmux.conf"],
  [".config/fish", "fish"],
  [".bashrc", ".bashrc"],
  [".bash_profile", ".bash_profile"],
];

// 特殊路径链接（使用绝对路径）
const specialLinks: AbsoluteLinkDef[] = [
  [lazygitConfigPath, join(DF, "lazygit")],
];

function createLink(linkPath: string, targetPath: string): void {
  // 确保父目录存在
  const parentDir = dirname(linkPath);
  if (!existsSync(parentDir)) {
    console.log(`📁 Creating directory: ${parentDir}`);
    mkdirSync(parentDir, { recursive: true });
  }

  // 删除已存在的链接或文件
  try {
    const stat = lstatSync(linkPath);
    if (stat) {
      console.log(`🗑️  Deleting existing: ${linkPath}`);
      rmSync(linkPath, { recursive: true, force: true });
    }
  } catch {
    // 文件不存在，忽略
  }

  // 创建软链接
  console.log(`🔗 Creating symlink: ${linkPath} -> ${targetPath}`);
  symlinkSync(targetPath, linkPath);
}

// 处理常规链接
for (const [linkRel, targetRel] of links) {
  const linkPath = join(HOME, linkRel);
  const targetPath = join(DF, targetRel);
  createLink(linkPath, targetPath);
}

// 处理特殊链接
for (const [linkPath, targetPath] of specialLinks) {
  createLink(linkPath, targetPath);
}

console.log("\n✅ All symlinks created successfully!");
