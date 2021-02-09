Kitty Vim Tmux Navigator
==================

This plugin is a fork from [vim-kitty-navigator](https://github.com/knubie/vim-kitty-navigator) extending it's capabilities to also work with tmux pane navigation. The aim is to make navigation between Kitty windows, tmux panes, and vim splits seamless. With some extra configuration, kitty-tmux navigation works even through SSH!

**NOTE**:
- This requires kitty v0.13.1 or higher.
- Requires newer version of tmux with 'pane_at_*' format feature. (Not sure which version, but tested tmux 2.1 and didn't work)
- Works only 2 nested layer deep. So navigation for vim splits inside tmux inside kitty is not supported.

Usage
-----

This plugin provides the following mappings which allow you to move between
Vim splits, tmux panes, and kitty window seamlessly.

- `<ctrl-h>` => Left
- `<ctrl-j>` => Down
- `<ctrl-k>` => Up
- `<ctrl-l>` => Right

Installation
------------

### VIM

Use your favorite plugin manager and add the following repo to your plugin list
```vim
'NikoKS/kitty-vim-tmux-navigator'
```
And then run the plugin installation function

### KITTY

To configure kitty, do the following steps:

1. Copy both `pass_keys.py` and `neighboring_window.py` kittens to the `~/.config/kitty/`.

2. Add the following to your `~/.config/kitty/kitty.conf` file:

```sh
map ctrl+j kitten pass_keys.py bottom ctrl+j
map ctrl+k kitten pass_keys.py top    ctrl+k
map ctrl+h kitten pass_keys.py left   ctrl+h
map ctrl+l kitten pass_keys.py right  ctrl+l
```

`kitty-vim-tmux-navigator` changes `vim-kitty-navigator` vim detection method from using title name to running foreground process name. So it removes the capability to change title regex.

3. Enable kitty `allow_remote_control` and `listen_on` option:

Set it on the `~/.config/kitty/kitty.conf` file:

```conf
allow_remote_control yes
listen_on unix:/tmp/mykitty
```

**OR**

Start kitty with the `listen_on` option so that vim can send commands to it.

```
kitty -o allow_remote_control=yes --listen-on unix:/tmp/mykitty
```

The listening address can be customized in your vimrc by setting `g:kitty_navigator_listening_on_address`. It defaults to `unix:/tmp/mykitty`.

### TMUX

If you're using [TPM](https://github.com/tmux-plugins/tpm), just add this snippet to your tmux.conf:

```conf
set -g @plugin 'NikoKS/kitty-vim-tmux-navigator'
```

And update your plugin

**Otherwise**

Add the following snippet to your tmux.conf:

```sh
# SSH aware kitty change window
if-shell '[ $SSH_TTY ]' 'to="--to=tcp:localhost:$KITTY_PORT "' 'to=""'
move='kitty @ ${to}kitten neighboring_window.py'

# Key Binds
bind-key -n 'C-h' if-shell "[ #{pane_at_left} != 1 ]" "select-pane -L" "run-shell '$move left'"
bind-key -n 'C-j' if-shell "[ #{pane_at_bottom} != 1 ]" "select-pane -D" "run-shell '$move bottom'"
bind-key -n 'C-k' if-shell "[ #{pane_at_top} != 1 ]" "select-pane -U" "run-shell '$move top'"
bind-key -n 'C-l' if-shell "[ #{pane_at_right} != 1 ]" "select-pane -R" "run-shell '$move right'"
```

SSH Compatibility
-----------------

With the settings above, navigation should work well locally. But if you need kitty-tmux navigation also work through ssh, follow steps below:

1. Install kitty on your remote machine. [How To](https://sw.kovidgoyal.net/kitty/binary.html?highlight=install).
With kitty installed on your remote system and remote control enabled, you should be able to use remote control from ssh. But because of reasons explained [here](https://github.com/kovidgoyal/kitty/issues/2338), it won't work from inside tmux. So we're going to need some workarounds.

2. Set remote port forwarding when using SSH.

```sh
ssh -R 50000:${KITTY_LISTEN_ON#*:} user@host
```

The remote TCP port 50000 can be changed to anything depending on your needs.

You can put it as an alias on your shell rc file so you don't type it all the time.

```sh
alias ssh='ssh -R 50000:${KITTY_LISTEN_ON#*:}'
```

3. Add the following snippet to your remote machine's `.bashrc` or something similar on other shell:

```sh
# Source kitty binary
export PATH=$PATH:~/.local/kitty.app/bin/

# Set KITTY_PORT env variable
if [[ $SSH_TTY ]] && ! [ -n "$TMUX" ]; then
  export KITTY_PORT=`kitty @ ls 2>/dev/null | grep "[0-9]:/tmp/mykitty" | head -n 1 | cut -d : -f 1 | cut -d \" -f 2`
fi

# Kitty Terminal Navigation
bind -x '"\C-h": kitty @ kitten neighboring_window.py left'
bind -x '"\C-j": kitty @ kitten neighboring_window.py top'
bind -x '"\C-k": kitty @ kitten neighboring_window.py bottom'
bind -x '"\C-l": kitty @ kitten neighboring_window.py right'
```

  **Explanation**:
- Source kitty path so the binary can be called from anywhere
- Set the KITTY_PORT environment variable automatically from the foreground process that call ssh.
- Set terminal key binding for changing kitty window when not using tmux

4. Don't forget to install the tmux plugin on your remote system also.
