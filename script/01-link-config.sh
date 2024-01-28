#!/bin/bash

# 定义链接列表
links=(
    "/home/bl/.config/alacritty /home/bl/df/config/alacritty"
    "/home/bl/.config/.Xmodmap /home/bl/df/config/.Xmodmap"
    "/home/bl/.config/.pam_environment /home/bl/df/config/.pam_environment"
    "/home/bl/.config/waybar /home/bl/df/config/waybar"
    "/home/bl/.config/fcitx5 /home/bl/df/config/fcitx5"
    "/home/bl/.config/kitty /home/bl/df/config/kitty"
    "/home/bl/.config/elvish /home/bl/df/config/elvish"
    "/home/bl/.config/zellij /home/bl/df/config/zellij"
    "/home/bl/.config/bottom /home/bl/df/config/bottom"
    "/home/bl/.config/hypr /home/bl/df/config/hypr"
    "/home/bl/.xinitrc /home/bl/df/config/.xinitrc"
    "/home/bl/.config/carapace /home/bl/df/config/carapace"
    "/home/bl/.config/starship.toml /home/bl/df/config/starship.toml"
    "/home/bl/.config/lazygit /home/bl/df/config/lazygit"
    "/home/bl/.tmux.conf /home/bl/df/config/tmux/.tmux.conf"
)

# 删除软链接或目标文件
function delete_link_or_file {
    local path="$1"
    if [ -L "$path" -o -e "$path" ]; then
        echo "Deleting existing symbolic link or file: $path"
        rm -rf "$path"
    fi
}

# 循环遍历链接列表，创建或更新每个链接
for link_pair in "${links[@]}"; do
    link_name="${link_pair%% *}"
    target_path="${link_pair#* }"
    
    # 如果软链接或目标文件已经存在，删除它
    delete_link_or_file "$link_name"
    
    # 创建新的软链接
    echo "Creating new symbolic link: $link_name -> $target_path"
    ln -sfT "$target_path" "$link_name"
done
