#!/bin/sh
# 复刻 zellij 的 mr-prjs-layout.kdl：为每个项目开一个 herdr workspace
# 用法：先启动 herdr，再在任意终端运行本脚本（或在 herdr 里的 pane 跑）
herdr workspace create --cwd "$HOME/df" --label df --no-focus
herdr workspace create --cwd "$HOME/prj/luv-sic" --label luv-sic --no-focus
herdr workspace create --cwd "$HOME/.config/nvim" --label nvim --no-focus
