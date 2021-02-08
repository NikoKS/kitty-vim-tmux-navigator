#!/usr/bin/env bash

# Kitty Tmux navigator
# SSH aware kitty change window
if-shell '[ $SSH_TTY ]' 'to="--to=tcp:localhost:$KITTY_PORT "' 'to=""'
move='kitty @ ${to}kitten neighboring_window.py'

# Key Binds
bind-key -n 'C-h' if-shell "[ #{pane_at_left} != 1 ]" "select-pane -L" "run-shell '$move left'"
bind-key -n 'C-j' if-shell "[ #{pane_at_bottom} != 1 ]" "select-pane -D" "run-shell '$move bottom'"
bind-key -n 'C-k' if-shell "[ #{pane_at_top} != 1 ]" "select-pane -U" "run-shell '$move top'"
bind-key -n 'C-l' if-shell "[ #{pane_at_right} != 1 ]" "select-pane -R" "run-shell '$move right'"
