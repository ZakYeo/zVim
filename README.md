# Neovim LTS Config

Personal Neovim configuration built around `lazy.nvim`. The entrypoint is intentionally small: `init.lua` sets leaders, loads shared config from `lua/config/`, and imports plugin specs from `lua/plugins/`.

## Structure

- `init.lua`: startup entrypoint.
- `lua/config/options.lua`: editor options.
- `lua/config/keymaps.lua`: global keymaps.
- `lua/config/highlights.lua`: transparent background highlight handling.
- `lua/config/smooth_scroll.lua`: local smooth scrolling implementation.
- `lua/config/smooth_scroll_setup.lua`: smooth scrolling options.
- `lua/config/lsp.lua`: diagnostics, LSP defaults, `lua_ls`, and LSP attach keymaps.
- `lua/config/explorer.lua`: Neo-tree helper behavior.
- `lua/config/terminal.lua`: terminal helper behavior and terminal-mode navigation.
- `lua/config/lazy.lua`: `lazy.nvim` bootstrap and plugin import.
- `lua/plugins/`: plugin specs.

## Requirements

- Neovim
- Git
- `make`
- `tree-sitter` CLI
- `ripgrep`
- A system clipboard provider for `unnamedplus`
- Optional Nerd Font for plugin icons

## Installation

For a regular Neovim setup:

```sh
git clone <repo-url> ~/.config/nvim
nvim
```

For a parallel setup next to an existing Neovim config, use `NVIM_APPNAME`. This example calls the setup `nvim-z` and installs it into `~/.config/nvim-z`:

```sh
git clone <repo-url> ~/.config/nvim-z
NVIM_APPNAME=nvim-z nvim
```

`nvim-z` is only an example name. You can choose any app name, as long as it matches the directory under `~/.config/`.

## Setup And Validation

Regular setup:

```sh
nvim --headless -i NONE '+Lazy! sync' +qa
nvim --headless -i NONE '+lua require("neo-tree")' +qa
nvim
```

Parallel `nvim-z` setup:

```sh
NVIM_APPNAME=nvim-z nvim --headless -i NONE '+Lazy! sync' +qa
NVIM_APPNAME=nvim-z nvim --headless -i NONE '+lua require("neo-tree")' +qa
NVIM_APPNAME=nvim-z nvim
```

Internally, this repository is validated with the `nvim-lts` binary. The examples above use `nvim` because they are the normal user-facing commands.

## Plugins

- `lazy.nvim`: plugin manager.
- `catppuccin/nvim`: colorscheme.
- `mason.nvim`: language server installer.
- `mason-lspconfig.nvim`: Mason integration for `nvim-lspconfig`.
- `nvim-lspconfig`: LSP configurations.
- `nvim-treesitter`: Treesitter parser and highlighting support.
- `telescope.nvim`: file finding and search UI.
- `telescope-fzf-native.nvim`: native FZF sorter for Telescope.
- `plenary.nvim`: shared Lua utility dependency.
- `which-key.nvim`: keymap discovery.
- `toggleterm.nvim`: terminal management.
- `bufferline.nvim`: buffer tabline.
- `neo-tree.nvim`: file explorer.
- `nui.nvim`: Neo-tree UI dependency.
- `nvim-web-devicons`: file and plugin icons.

## Keybinds

Config:

- `<leader>lc`: open `init.lua`.

Explorer:

- `<leader>e`: toggle Neo-tree and reveal the current file.
- `<leader>E`: open Neo-tree at the current working directory.

File finding and search:

- `<leader>ff`: find files.
- `<leader>fw`: live grep.
- `<leader>fb`: find buffers.
- `<leader>fh`: help tags.
- `<leader>fr`: recent files.
- `<leader>fc`: commands.

Buffers:

- `<S-l>`: next buffer tab.
- `<S-h>`: previous buffer tab.
- `<leader>0`: last buffer tab.
- `<leader>1` through `<leader>9`: buffer tab 1 through 9.
- `<leader>bd`: close current buffer.

Terminal:

- `<leader>tt`: toggle bottom terminal. Prefix with a count to target a terminal id.
- `<leader>tn`: open a new bottom terminal split.
- `<leader>tc`: close the current terminal or buffer.
- `<leader>tT`: open a full-buffer terminal.
- `<leader>ts`: select a terminal.

LSP and diagnostics:

- `gd`: go to definition.
- `gD`: go to declaration.
- `gi`: go to implementation.
- `gr`: list references.
- `K`: hover.
- `<leader>rn`: rename.
- `<leader>ca`: code action.
- `<leader>lf`: format.
- `<leader>ld`: line diagnostic.
- `[d`: previous diagnostic.
- `]d`: next diagnostic.

Terminal-mode navigation:

- `<Esc>`: leave terminal mode.
- `<C-h>`: leave terminal mode and move left.
- `<C-j>`: leave terminal mode and move down.
- `<C-k>`: leave terminal mode and move up.
- `<C-l>`: leave terminal mode and move right.

Smooth scrolling:

- `<C-d>`: half page down.
- `<C-u>`: half page up.
- `<C-f>`: page down.
- `<C-b>`: page up.
- `<C-e>`: line down.
- `<C-y>`: line up.
