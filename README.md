# zVim, a custom IDE layer for Neovim

zVim, short for Zak's Vim, is a Neovim IDE layer built around `lazy.nvim`. The entrypoint is intentionally small: `init.lua` sets leaders, loads shared config from `lua/config/`, and imports plugin specs from `lua/plugins/`.

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

- Neovim 0.11 or newer
- Git
- `make`
- `tree-sitter` CLI
- `ripgrep`
- `lazygit` for the `<leader>gg` Git UI command
- Formatter tools managed by Mason: `stylua`, `prettier`, `shfmt`, and `markdownlint-cli2`
- A system clipboard provider for `unnamedplus`
- Optional Nerd Font for plugin icons

## Installation

Install zVim from GitHub:

```sh
curl -fsSL https://raw.githubusercontent.com/ZakYeo/zVim/main/install.sh | sh
```

The installer clones zVim into `~/.config/zvim` and creates a `zvim` launcher in `~/.local/bin`. The launcher runs Neovim with `NVIM_APPNAME=zvim`, so zVim can live next to an existing Neovim setup.

By default, the installer uses the `nvim` command from your `PATH`. If your default `nvim` is older than Neovim 0.11, set `ZVIM_NVIM_BIN` to a compatible command or absolute path:

```sh
curl -fsSL https://raw.githubusercontent.com/ZakYeo/zVim/main/install.sh | ZVIM_NVIM_BIN=nvim-lts sh
```

Run zVim with:

```sh
zvim
```

If `zvim` is not found after installation, add `~/.local/bin` to your `PATH`.

The installer stops if `~/.config/zvim` or `~/.local/bin/zvim` already exists. Move or remove the existing path before reinstalling.

To uninstall an existing zVim installation before reinstalling:

```sh
rm -rf ~/.config/zvim
rm -rf ~/.local/share/zvim ~/.local/state/zvim ~/.cache/zvim
rm -f ~/.local/bin/zvim ~/.local/bin/zVim
```

## Setup And Validation

After installation:

```sh
zvim --headless -i NONE '+Lazy! sync' +qa
zvim --headless -i NONE '+lua require("neo-tree")' +qa
zvim
```

Internally, this repository is validated with the `nvim-lts` binary:

```sh
nvim-lts --headless -i NONE '+Lazy! sync' +qa
nvim-lts --headless -i NONE '+lua require("neo-tree")' +qa
```

## Plugins

- `lazy.nvim`: plugin manager.
- `catppuccin/nvim`: colorscheme.
- `mason.nvim`: language server installer.
- `mason-lspconfig.nvim`: Mason integration for `nvim-lspconfig`.
- `mason-tool-installer.nvim`: Mason integration for formatter tools.
- `nvim-lspconfig`: LSP configurations.
- `blink.cmp`: completion engine.
- `friendly-snippets`: snippet collection for completion.
- `conform.nvim`: formatter orchestration and format-on-save.
- `gitsigns.nvim`: Git signs and hunk actions.
- `nvim-treesitter`: Treesitter parser and highlighting support.
- `telescope.nvim`: file finding and search UI.
- `telescope-fzf-native.nvim`: native FZF sorter for Telescope.
- `todo-comments.nvim`: TODO/FIX/FIXME highlighting and search.
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
- `<leader>ft`: TODO comments.
- `<leader>fT`: TODO/FIX/FIXME comments.

Todo comments:

- `[t`: previous TODO-style comment.
- `]t`: next TODO-style comment.

Git:

- `[c`: previous Git hunk.
- `]c`: next Git hunk.
- `<leader>gs`: stage hunk.
- `<leader>gr`: reset hunk.
- `<leader>gS`: stage buffer.
- `<leader>gR`: reset buffer.
- `<leader>gp`: preview hunk.
- `<leader>gb`: blame line.
- `<leader>gd`: diff file.
- `<leader>gg`: open LazyGit fullscreen. Requires the `lazygit` executable.
- `<leader>gq`: send hunks to quickfix.
- `ih`: select hunk text object.

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

- `<C-y>`: accept completion.
- `<C-n>`: select next completion item.
- `<C-p>`: select previous completion item.
- `<C-Space>`: open completion or documentation.
- `<C-e>`: close completion menu.
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
