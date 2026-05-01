# Repository Guidelines

## Project Structure & Module Organization

This repository is a Neovim configuration named zVim. `init.lua` is the entrypoint: it sets leaders, loads shared configuration, and bootstraps plugins. Core editor behavior lives in `lua/config/`, with focused modules such as `options.lua`, `keymaps.lua`, `lsp.lua`, `terminal.lua`, and `explorer.lua`. Plugin specifications live in `lua/plugins/`, one concern per file, for example `telescope.lua`, `treesitter.lua`, `formatting.lua`, and `git.lua`. `install.sh` installs zVim and creates the launcher. `lazy-lock.json` pins plugin revisions and should be updated intentionally after plugin syncs.

## Build, Test, and Development Commands

- `nvim-lts --headless -i NONE '+Lazy! sync' +qa`: install or update plugins using the locked config.
- `nvim-lts --headless -i NONE '+lua require("neo-tree")' +qa`: smoke-test that a plugin can load.
- `nvim-lts --headless -i NONE '+checkhealth' +qa`: run Neovim health checks for providers, plugins, and tooling.
- `./install.sh`: test the installer locally. Use environment overrides such as `ZVIM_INSTALL_DIR=/tmp/zvim-test` and `ZVIM_COMMAND_NAME=zvim-test` to avoid touching an existing setup.

## Coding Style & Naming Conventions

Use Lua for Neovim modules and POSIX `sh` for installer scripts. Keep Lua indentation at two spaces, prefer double-quoted strings, and return plugin specs as simple tables from files in `lua/plugins/`. Name files by feature or plugin area using lowercase words and underscores when needed, such as `smooth_scroll_setup.lua`. Keep configuration modules small and require them from `init.lua` or `lua/config/lazy.lua` rather than adding large blocks inline.

## Testing Guidelines

There is no formal test suite. Validate changes with headless Neovim commands and by opening `nvim-lts` interactively when UI behavior changes. For installer edits, run against temporary paths before publishing. For plugin changes, confirm `lazy.nvim` sync succeeds and require any newly added plugin module in headless mode.

## Commit & Pull Request Guidelines

Recent history uses concise Conventional Commit-style prefixes: `feat:`, `fix:`, and `docs:`. Keep commits scoped to one behavior change when practical, for example `fix: validate zvim neovim launcher`. Pull requests should include a short description, validation commands run, linked issues when applicable, and screenshots for visible UI changes such as dashboard, explorer, bufferline, or colorscheme updates.

## Agent-Specific Instructions

Do not rewrite unrelated user configuration. Preserve `lazy-lock.json` unless plugin versions intentionally change. Prefer minimal, local edits that match the existing module boundaries.
