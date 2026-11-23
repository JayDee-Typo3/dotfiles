# Neovim configuration

Personal Neovim setup on top of [LazyVim](https://lazyvim.github.io). Lives in
`dotfiles/config/nvim/`. Unlike the other folders in `config/`, the folder itself is
**not** symlinked: `~/.config/nvim/` is a real directory and only its entries are
linked one by one (see [Installation](#installation)).

- **Neovim version:** 0.12
- **Distribution:** LazyVim (plugin manager: [lazy.nvim](https://github.com/folke/lazy.nvim))
- **Theme:** Catppuccin, `mocha` flavour
- **PHP language server:** Intelephense
- **Main use:** PHP / TYPO3 projects that are also opened in PhpStorm

---

## Layout

```
config/nvim/
├── init.lua                      # bootstraps lazy.nvim -> lua/config/lazy.lua
├── lazyvim.json                  # enabled LazyVim extras (managed via :LazyExtras)
└── lua/
    ├── config/
    │   ├── lazy.lua              # lazy.nvim setup, spec imports, update checker
    │   ├── options.lua           # vim options (PHP LSP = intelephense)
    │   ├── keymaps.lua           # own keymaps
    │   └── autocmds.lua          # own autocmds (currently empty)
    └── plugins/
        ├── php-formatting.lua    # php-cs-fixer / phpcs aligned with PhpStorm
        ├── example.lua           # LazyVim starter example, disabled
        ├── coding/
        │   └── mini-surround.lua # surround keymaps
        └── themes/
            └── catppuccin.lua    # colour scheme
```

Every file under `lua/plugins/` (and the sub folders `coding/` and `themes/`, which are
imported explicitly in `lazy.lua`) is loaded automatically by lazy.nvim.

Not in this repo, created locally in `~/.config/nvim/`: `lazy-lock.json` (pinned plugin
versions), `.neoconf.json`, `stylua.toml`, `LICENSE`, `README.md` from the LazyVim starter.

---

## LazyVim extras

Enabled in `lazyvim.json` (toggle with `:LazyExtras`):

| Extra | What it adds |
|-------|--------------|
| `ai.claudecode` | Claude Code integration |
| `coding.mini-comment` | Commenting via mini.comment |
| `coding.mini-surround` | Add / delete / replace surroundings (keys see below) |
| `coding.yanky` | Yank history |
| `dap.core` | Debugger (nvim-dap + UI), used for PHP / Xdebug |
| `lang.docker` | Dockerfile / compose LSP + hadolint |
| `lang.java` | jdtls |
| `lang.php` | Intelephense, php-cs-fixer (format), phpcs (lint), php-debug-adapter |
| `lang.sql` | vim-dadbod, SQL completion, sqlfluff |
| `lang.yaml` | yaml-language-server + SchemaStore |

---

## Formatting and linting (PhpStorm parity)

Goal: Neovim and PhpStorm must produce the **same** formatting, so files don't flip
back and forth between the two editors. Both use the project's own config files as the
single source of truth. Implemented in `lua/plugins/php-formatting.lua`.

### Format on save

| File type | On save | Manually (`<leader>cf`) |
|-----------|---------|-------------------------|
| PHP | yes, php-cs-fixer | yes |
| Lua | yes, stylua | yes |
| everything else (YAML, JSON, HTML/Fluid, JS, CSS, …) | **no** | yes |

PhpStorm doesn't reformat on save, so Neovim leaves everything except PHP and Lua alone.
`<leader>uf` (buffer) / `<leader>uF` (global) toggle auto-format as usual in LazyVim.

Indentation, final newline and trailing whitespace come from the project's
`.editorconfig`, which both Neovim (built in) and PhpStorm read.

### php-cs-fixer

- Config: the **outermost** `.php-cs-fixer.dist.php` / `.php-cs-fixer.php` above the
  file, i.e. the project root, same as PhpStorm's `$PROJECT_DIR$`. A config inside a
  single package (`packages/*/`) is ignored.
- Binary: `<root>/vendor/bin/php-cs-fixer` (never the global Mason one).
- Working directory: the project root, and the config is passed explicitly via `--config`.
- **No project config or no `vendor/bin/php-cs-fixer` → PHP is not formatted at all.**
  Without a config php-cs-fixer would use its own defaults, and newer versions even start
  an interactive wizard that writes a `.php-cs-fixer.dist.php` into the directory.

Why it is needed: LazyVim's default uses the nearest `composer.json` as working
directory. In monorepos that is the package (`packages/ui_ce/`), where no fixer config
exists, so files were silently formatted with the fixer's default rules instead of the
project's TYPO3 rules.

### phpcs

- Ruleset: the outermost `.phpcs.xml` / `phpcs.xml` / `.phpcs.xml.dist` /
  `phpcs.xml.dist` (project root), passed via `--standard`.
- Binary: `<root>/vendor/bin/phpcs`.
- **No ruleset → no phpcs diagnostics** (phpcs would otherwise fall back to the PEAR
  standard and report lots of false positives).

### PhpStorm side

To make `Cmd + Alt + L` in PhpStorm produce exactly what Neovim produces, set in each
project: **Settings → PHP → Quality Tools → External formatters → PHP CS Fixer**.
Otherwise PhpStorm's built-in formatter is used, which can disagree with php-cs-fixer.

---

## Keybindings

`<leader>` is `Space` (LazyVim default). Only own / changed bindings are listed; for
everything else see the [LazyVim keymaps](https://lazyvim.github.io/keymaps) or press
`<leader>` and wait for which-key.

### Own keymaps (`lua/config/keymaps.lua`)

| Keys | Mode | Action |
|------|------|--------|
| `jk` | insert | Leave insert mode (`Esc`) |

### Surround (`lua/plugins/coding/mini-surround.lua`)

| Keys | Action |
|------|--------|
| `gsa` | Add surrounding (normal + visual), e.g. `gsaiw"` |
| `gsd` | Delete surrounding, e.g. `gsd"` |
| `gsr` | Replace surrounding, e.g. `gsr"'` |
| `gsf` / `gsF` | Find surrounding to the right / left |
| `gsh` | Highlight surrounding |
| `gsn` | Change how many lines are searched |

These deliberately use the `gs` prefix: `<leader>sa`, `<leader>sd` and `<leader>sr` stay
LazyVim's *Autocmds*, *Diagnostics* and *Search and Replace* (grug-far).

### Useful LazyVim defaults for this setup

| Keys | Action |
|------|--------|
| `<leader>cf` | Format buffer / selection |
| `<leader>uf` / `<leader>uF` | Toggle auto-format (buffer / global) |
| `<leader>cm` | Mason (installed tools) |
| `<leader>l` | Lazy (plugin manager) |
| `:ConformInfo` | Shows which formatter runs for the current buffer and with which command |
| `:LazyExtras` | Enable / disable extras |

---

## Plugin updates

`lazy.lua` checks for plugin updates in the background without notifying
(`checker.notify = false`). Update with `<leader>l` → `U`, or `:Lazy update`.
All plugins track the latest git commit (`version = false`); the exact versions are
pinned in `~/.config/nvim/lazy-lock.json`.

---

## Installation

Done by `bash/setup-new-mac.sh`:

1. Clones the LazyVim starter to `~/.config/nvim` (backs up an existing config first).
2. Symlinks every entry of `dotfiles/config/nvim/` into `~/.config/nvim/`
   (`init.lua`, `lazyvim.json`, `lua/`, this `README.md`), replacing the starter's versions.
3. Runs `nvim --headless "+Lazy! sync" +qa` to install the plugins.

Manually, after cloning the repo:

```sh
git clone https://github.com/LazyVim/starter ~/.config/nvim && rm -rf ~/.config/nvim/.git
for f in init.lua lazyvim.json lua; do
  rm -rf ~/.config/nvim/$f
  ln -s ~/Development/Repositories/dotfiles/config/nvim/$f ~/.config/nvim/$f
done
nvim
```

Requirements: Neovim ≥ 0.10 (uses `vim.fs.root` / `vim.uv`), git, a Nerd Font
(JetBrainsMono Nerd Font is installed by the setup script), PHP + Composer for the PHP
tooling. Mason installs the language servers and tools on first start.
