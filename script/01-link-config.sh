#!/bin/bash
#ln -sfT /home/bl/df/config/.config/alacritty /home/bl/.config/alacritty
#ln -sfT /home/bl/df/config/.config/.Xmodmap /home/bl/.config/..Xmodmap
#ln -sfT /home/bl/df/config/.config/.pam_environment /home/bl/.config/.pam_environment
#ln -sfT /home/bl/df/config/.config/starship.toml /home/bl/.config/starship.toml
#ln -sfT /home/bl/df/config/.config/waybar /home/bl/.config/waybar
#ln -sfT /home/bl/df/config/.config/fcitx5 /home/bl/.config/fcitx5
#ln -sfT /home/bl/df/config/.config/kitty /home/bl/.config/kitty
#ln -sfT /home/bl/df/config/.config/elvish /home/bl/.config/elvish
#ln -sfT /home/bl/df/config/.config/zellij /home/bl/.config/zellij
#ln -sfT /home/bl/df/config/.config/bottom /home/bl/.config/bottom
#ln -sfT /home/bl/df/config/.config/hypr /home/bl/.config/hypr
#ln -sfT /home/bl/df/config/.config/.xinitrc /home/bl/.xinitrc
#ln -sfT /home/bl/df/config/.config/carapace /home/bl/carapace
#ln -sfT /home/bl/df/config/fcitx5 /home/bl/.local/share/fcitx5


#!/bin/bash

# 要创建软链接的文件或目录路径列表
targets=(
    "/home/bl/df/config/.config/alacritty"
    "/home/bl/df/config/.config/.Xmodmap"
    "/home/bl/df/config/.config/.pam_environment"
    "/home/bl/df/config/.config/waybar"
    "/home/bl/df/config/.config/fcitx5"
    "/home/bl/df/config/.config/kitty"
    "/home/bl/df/config/.config/elvish"
    "/home/bl/df/config/.config/zellij"
    "/home/bl/df/config/.config/bottom"
    "/home/bl/df/config/.config/zellij"
    "/home/bl/df/config/.config/hypr"
    "/home/bl/df/config/.config/.xinitrc"
    "/home/bl/df/config/.config/carapace"
)

# 要创建的软链接名称列表
links=(
    "/home/bl/.config/alacritty"
    "/home/bl/.config/.Xmodmap"
    "/home/bl/.config/.pam_environment"
    "/home/bl/.config/waybar"
    "/home/bl/.config/fcitx5"
    "/home/bl/.config/kitty"
    "/home/bl/.config/elvish"
    "/home/bl/.config/zellij"
    "/home/bl/.config/bottom"
    "/home/bl/.config/zellij"
    "/home/bl/.config/hypr"
    "/home/bl/.xinitrc"
    "/home/bl/carapace"
)

# 循环遍历链接列表，创建每个链接
for (( i=0; i<${#targets[@]}; i++ )); do
    target_path="${targets[$i]}"
    link_name="${links[$i]}"
    
    # 如果软链接或目标文件已经存在，删除它
    if [ -L "$link_name" -o -e "$link_name" ]; then
        echo "Deleting existing symbolic link: $link_name"
        rm -rf "$link_name"
    fi
    
    # 创建新的软链接
    echo "Creating new symbolic link: $link_name -> $target_path"
    ln -sfT "$target_path" "$link_name"
done
