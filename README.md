# dotfiles
These be me dotfiles

## Terminal

Alacritty + tmux, where **every Alacritty window is its own independent tmux
session** — splits, tabs and copy mode, but no shared state between windows.

- `bin/alacritty-tmux` — set as Alacritty's shell; creates a private,
  PID-named tmux session per window and reaps it when the window closes
  (session-scoped `destroy-unattached`).
- `alacritty/alacritty.toml` — points `[terminal.shell]` at the wrapper.
- `tmux/tmux.conf` — prefix-free bindings: `Alt+|` / `Alt+-` split,
  `Alt+h/j/k/l` navigate, `Alt+Shift+h/j/k/l` resize, `Alt+1..9` / `Alt+n/p`
  windows, `Alt+t` new window, `Alt+x` close pane.

### Setup on a new machine

```sh
ln -s ~/Repos/dotfiles/bin/alacritty-tmux ~/.local/bin/alacritty-tmux
cp -r ~/Repos/dotfiles/alacritty ~/.config/alacritty
cp -r ~/Repos/dotfiles/tmux      ~/.config/tmux
```

`helix/` and `nvim/` are symlinked into `~/.config/` instead; `alacritty/`,
`tmux/`, `paru/` and `cosmic/` are copies.

> **Note:** don't replace the wrapper's `destroy-unattached` with a
> `set-hook client-detached kill-session`. When a session is destroyed tmux
> reassigns the client to a *surviving* session before `client-detached` is
> processed, so the hook fires against the wrong session and exiting one
> window kills another.
