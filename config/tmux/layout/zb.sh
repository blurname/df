#!/bin/bash

session_name='demo'

tmux has-session -t $session_name
if [ $? != 0 ]
then

    # SESSION

    cd ~
    tmux new-session               -ds $session_name
    # tmux set-window-option          -t $session_name     allow-rename off

    # FIRST WINDOW
    # 1 window

    # tmux send-keys                  -t $session_name:0.0 'htop' C-m
    # tmux split-window      -v -p 25 -t $session_name:0
      
    tmux new-window                 -t $session_name:1
    tmux rename-window              -t $session_name:1   df
    # tmux send-keys                  -t $session_name:1.1 'htop' C-m
    tmux send-keys                  -t $session_name:1.1 'cd ~/df ; clear' C-m

    # 2 WINDOW

    tmux new-window                 -t $session_name:2
    tmux rename-window              -t $session_name:2   blurkit
    tmux send-keys                  -t $session_name:2.1 'cd ~/prjs/blurkit ; clear' C-m
    # tmux send-keys                  -t $session_name:1.0 'cd ~/prjs/blurkit' C-m

    # 3 widnow
    tmux new-window                 -t $session_name:3
    tmux rename-window              -t $session_name:3   nvim
    tmux send-keys                  -t $session_name:3.1 'cd ~/.config/nvim ; clear' C-m
    # tmux send-keys                  -t $session_name:2.0 'cd ~/.config/nvim' C-m

    # tmux split-window      -h -p 50 -t $session_name:1
    # tmux split-window      -v -p 50 -t $session_name:1
    # tmux split-window      -v -p 50 -t $session_name:1
    #
    # tmux select-pane                -t 0
    # tmux split-window      -v -p 50 -t $session_name:1

    # SELECT DEFAULT PANE AFTER OPENING

    tmux select-window              -t $session_name:1
    tmux select-window              -t $session_name:1.1
fi

tmux attach -t $session_name
