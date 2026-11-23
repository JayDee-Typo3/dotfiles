# tmux configuration

Personal tmux setup. Lives in `dotfiles/config/tmux/` and is symlinked to
`~/.config/tmux/`, so tmux reads it as `~/.config/tmux/tmux.conf`.

- **tmux version:** 3.7b
- **Prefix:** `Ctrl + Space` (the default `Ctrl + b` is unbound)
- **Theme:** Catppuccin, `mocha` flavour
- **Copy mode:** vi keys
- **Plugin manager:** [TPM](https://github.com/tmux-plugins/tpm)

---

## The prefix

The prefix is **`Ctrl + Space`**. Every "prefix +" binding below means: press
`Ctrl + Space`, release, then press the next key.

To send a literal `Ctrl + Space` through to the running program, press the
prefix twice (`Ctrl + Space`, then `Ctrl + Space` again).

---

## Keybindings

### Panes

| Keys | Action | Prefix? |
|------|--------|---------|
| `prefix` + `h` / `j` / `k` / `l` | Select pane left / down / up / right | yes |
| `Alt` + `←` / `↓` / `↑` / `→` | Select pane left / down / up / right | no |
| `prefix` + `"` | Split pane top/bottom (new pane below), keep current path | yes |
| `prefix` + `%` | Split pane left/right (new pane to the right), keep current path | yes |

> `vim-tmux-navigator` (plugin) also gives you `Ctrl + h/j/k/l` to move between
> panes **and** Neovim splits seamlessly — no prefix needed. See plugins below.

### Windows

| Keys | Action | Prefix? |
|------|--------|---------|
| `Shift` + `←` | Previous window | no |
| `Shift` + `→` | Next window | no |
| `Ctrl + Alt` + `h` | Previous window | no |
| `Ctrl + Alt` + `l` | Next window | no |

> Windows and panes are numbered from **1** (not 0), and windows renumber
> automatically when one is closed, so there are never gaps.

### Copy mode (vi keys)

Enter copy mode with `prefix` + `[`. Then:

| Keys | Action |
|------|--------|
| `v` | Begin selection |
| `Ctrl + v` | Toggle rectangle (block) selection |
| `y` | Copy selection and exit copy mode |
| `q` / `Esc` | Exit copy mode |

Mouse selection is also enabled (see below).

---

## Behaviour / options

| Setting | Value | Why |
|---------|-------|-----|
| `mouse` | on | Click to select panes/windows, drag borders to resize, scroll to enter copy mode |
| `base-index` / `pane-base-index` | 1 | Windows and panes start at 1 |
| `renumber-windows` | on | No gaps in window numbers after closing one |
| `mode-keys` | vi | vi-style navigation in copy mode |
| `terminal-overrides` | `xterm*:Tc` | Enables 24-bit true color |
| `prefix` | `C-Space` | `C-b` unbound and replaced |

---

## Plugins

Managed by [TPM](https://github.com/tmux-plugins/tpm). Declared with
`set -g @plugin '...'` in `tmux.conf` and loaded by the final
`run '~/.tmux/plugins/tpm/tpm'` line.

| Plugin | Purpose |
|--------|---------|
| [`tmux-plugins/tpm`](https://github.com/tmux-plugins/tpm) | Plugin manager |
| [`tmux-plugins/tmux-sensible`](https://github.com/tmux-plugins/tmux-sensible) | Sane baseline defaults (faster escape time, larger history, focus events, etc.) |
| [`christoomey/vim-tmux-navigator`](https://github.com/christoomey/vim-tmux-navigator) | `Ctrl + h/j/k/l` moves between tmux panes and Vim/Neovim splits transparently |
| [`dreamsofcode-io/catppuccin-tmux`](https://github.com/dreamsofcode-io/catppuccin-tmux) | Catppuccin status-bar theme (`mocha` flavour) |
| [`tmux-plugins/tmux-yank`](https://github.com/tmux-plugins/tmux-yank) | Copy to the system clipboard from copy mode |

### TPM plugin management

| Keys | Action |
|------|--------|
| `prefix` + `I` | Install plugins listed in `tmux.conf` |
| `prefix` + `U` | Update plugins |
| `prefix` + `Alt + u` | Remove plugins no longer listed |

**First-time setup** — clone TPM, then install:

```sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
tmux             # start a session
# press: prefix + I   (Ctrl+Space, then Shift+i)
```

---

## Window-manager coexistence (important)

This machine runs a global tiling window manager — **[AeroSpace](https://github.com/nikitabobko/AeroSpace)**.
It reserves **`Alt` (Option)** based shortcuts *globally*, and a global hotkey
daemon always intercepts a key before it reaches the terminal / tmux.

The rule that keeps them from fighting:

> **The window manager owns `Alt`. tmux stays on its `Ctrl + Space` prefix, plus
> `Ctrl` and `Shift` combos.**

Because of this, window switching uses **`Ctrl + Alt + h/l`** (and `Shift +
arrows`) rather than `Alt + Shift + h/l` — the latter is the window manager's
"move window" shortcut and would never reach tmux.

The tmux `Alt + arrow` pane bindings are safe only because the window manager
binds `Alt + letter`, not `Alt + arrow`. If arrow bindings are ever added to
AeroSpace, move these pane bindings off `Alt` too.

---

## Reloading the config

After editing `tmux.conf`, apply it without restarting tmux:

```sh
tmux source-file ~/.config/tmux/tmux.conf
```

Changes also take effect automatically the next time a fresh tmux server starts.
