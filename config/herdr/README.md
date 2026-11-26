# herdr

Helper scripts for [herdr](https://herdr.dev), the terminal workspace manager for AI
coding agents.

| Path | What it is |
|------|------------|
| [`bin/hws`](bin/hws) | Creates a herdr workspace with three tabs: `cli`, `claude`, `nvim` |
| [`install.sh`](install.sh) | Symlinks everything in `bin/` into `~/.local/bin` |

## Install

```sh
~/Development/Repositories/dotfiles/config/herdr/install.sh
```

- Creates `~/.local/bin` if it is missing and links each file from `bin/` into it.
- You can run it again safely. Links that already point here are left alone; anything
  else in the way is moved to `<name>.bak.<timestamp>`.
- It warns if `~/.local/bin` is not in your `PATH`, or if `herdr`, `jq`, `claude` or
  `nvim` is missing.

Because these are symlinks, changes to `bin/hws` in the repo take effect right away.

## hws

```sh
hws                       # workspace for the current directory, named after it
hws ~/Development/foo     # workspace for ~/Development/foo, named "foo"
hws ~/Development/foo bar # same directory, named "bar"
hws --help
```

The new workspace gets focus and has three tabs, all in the given directory:

| Tab | Label | Runs |
|-----|-------|------|
| 1 | `cli` | plain shell |
| 2 | `claude` | `claude` |
| 3 | `nvim` | `nvim` (lazygit is reachable from inside nvim) |

Needs a running herdr server (start `herdr` first), plus `jq`, `claude` and `nvim`.

### Why a script?

herdr (as of 0.9.5) has no `config.toml` option for workspace templates or default tabs,
and no hook that fires when a workspace is created. `hws` uses the herdr CLI to build the
layout instead:

1. `herdr workspace create --cwd DIR --label LABEL --focus` creates the workspace and its
   first tab, which `herdr tab rename` names `cli`.
2. `herdr tab create --workspace ID --cwd DIR --label claude|nvim --no-focus` adds the
   other two tabs.
3. `herdr pane run PANE_ID claude|nvim` starts the program in each tab's pane.

herdr's own "new workspace" shortcut still creates a single tab. To get the three tabs,
call `hws` from a shell, or bind it to a key in `~/.config/herdr/config.toml` with a
`[[keys.command]]` entry of `type = "shell"`.

## Note on `bash/setup-new-mac.sh`

Step 9 of the setup script links every folder in `config/` to `~/.config/<name>`. On a
new Mac this would turn `~/.config/herdr` into a link to this folder, and herdr would
write its sockets, logs and `session.json` into the repo. Until the setup script skips
`herdr`, create `~/.config/herdr` as a real directory before running it, then run
`install.sh`.
