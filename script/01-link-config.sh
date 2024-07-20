#!/bin/bash

# 定义链接列表
links=(
    "$HOME/.config/alacritty $HOME/df/config/alacritty"
    "$HOME/.config/.Xmodmap $HOME/df/config/.Xmodmap"
    "$HOME/.config/.pam_environment $HOME/df/config/.pam_environment"
    "$HOME/.config/waybar $HOME/df/config/waybar"
    "$HOME/.config/fcitx5 $HOME/df/config/fcitx5"
    "$HOME/.config/kitty $HOME/df/config/kitty"
    "$HOME/.config/elvish $HOME/df/config/elvish"
    "$HOME/.config/zellij $HOME/df/config/zellij"
    "$HOME/.config/bottom $HOME/df/config/bottom"
    "$HOME/.config/hypr $HOME/df/config/hypr"
    "$HOME/.xinitrc $HOME/df/config/.xinitrc"
    "$HOME/.config/carapace $HOME/df/config/carapace"
    "$HOME/.config/starship.toml $HOME/df/config/starship.toml"
    "$HOME/.config/lazygit $HOME/df/config/lazygit"
    "$HOME/.tmux.conf $HOME/df/config/tmux/.tmux.conf"
    "$HOME/.config/fish $HOME/df/config/fish"
    "$HOME/.bashrc $HOME/df/config/.bashrc"
    "$HOME/.bash_profile $HOME/df/config/.bash_profile"
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
