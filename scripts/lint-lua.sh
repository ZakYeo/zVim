#!/bin/sh
set -eu

if ! command -v lua-language-server >/dev/null 2>&1; then
  xdg_data_home=${XDG_DATA_HOME:-"$HOME/.local/share"}

  for appname in "${NVIM_APPNAME:-}" nvim-lts zvim nvim; do
    [ -n "$appname" ] || continue

    mason_bin="$xdg_data_home/$appname/mason/bin"
    if [ -x "$mason_bin/lua-language-server" ]; then
      PATH="$mason_bin:$PATH"
      export PATH
      break
    fi
  done
fi

if ! command -v lua-language-server >/dev/null 2>&1; then
  echo "lua-language-server not found. Install it with Mason or add it to PATH." >&2
  exit 127
fi

exec lua-language-server \
  --check . \
  --check_format pretty \
  --checklevel Warning \
  --logpath /tmp/nvim-lts-luals-log \
  --metapath /tmp/nvim-lts-luals-meta
