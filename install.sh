#!/bin/sh
set -eu

APPNAME="${ZVIM_APPNAME:-zvim}"
COMMAND_NAME="${ZVIM_COMMAND_NAME:-zvim}"
REPO_URL="${ZVIM_REPO_URL:-https://github.com/ZakYeo/zVim.git}"
NVIM_BIN="${ZVIM_NVIM_BIN:-nvim}"

if [ -z "${HOME:-}" ]; then
  printf '%s\n' "zVim install error: HOME is not set." >&2
  exit 1
fi

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
INSTALL_DIR="${ZVIM_INSTALL_DIR:-$CONFIG_HOME/$APPNAME}"
BIN_DIR="${ZVIM_BIN_DIR:-$HOME/.local/bin}"
LAUNCHER="$BIN_DIR/$COMMAND_NAME"
TMP_DIR="$INSTALL_DIR.tmp.$$"

info() {
  printf '%s\n' "$1"
}

fail() {
  printf '%s\n' "zVim install error: $1" >&2
  exit 1
}

need_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    fail "missing required command: $1"
  fi
}

resolve_command() {
  if command -v "$1" >/dev/null 2>&1; then
    command -v "$1"
    return
  fi

  fail "missing required command: $1"
}

check_neovim_version() {
  version_output="$("$1" --version 2>/dev/null | sed -n '1p')"
  major_version="$(printf '%s\n' "$version_output" | sed -n 's/^NVIM v\([0-9][0-9]*\)\..*/\1/p')"
  minor_version="$(printf '%s\n' "$version_output" | sed -n 's/^NVIM v[0-9][0-9]*\.\([0-9][0-9]*\).*/\1/p')"

  if [ -n "$major_version" ] && [ "$major_version" -ge 1 ]; then
    return
  fi

  if [ "$major_version" = "0" ] && [ -n "$minor_version" ] && [ "$minor_version" -ge 11 ]; then
    return
  fi

  fail "$1 must be Neovim 0.11 or newer. Set ZVIM_NVIM_BIN to a compatible Neovim binary."
}

cleanup() {
  if [ -d "$TMP_DIR" ]; then
    rm -rf "$TMP_DIR"
  fi
}

trap cleanup EXIT INT TERM

need_command git
RESOLVED_NVIM_BIN="$(resolve_command "$NVIM_BIN")"
check_neovim_version "$RESOLVED_NVIM_BIN"

if [ -e "$INSTALL_DIR" ]; then
  fail "$INSTALL_DIR already exists. Move it out of the way before installing zVim."
fi

if [ -e "$LAUNCHER" ]; then
  fail "$LAUNCHER already exists. Move it out of the way before installing zVim."
fi

LEGACY_LAUNCHER="$BIN_DIR/zVim"

if [ "$COMMAND_NAME" != "zVim" ] && [ -e "$LEGACY_LAUNCHER" ]; then
  info "Found legacy launcher at $LEGACY_LAUNCHER. Remove it if you no longer need the old zVim command."
fi

if [ -e "$TMP_DIR" ]; then
  fail "$TMP_DIR already exists. Remove it before installing zVim."
fi

info "Installing zVim into $INSTALL_DIR"
info "Using Neovim binary: $RESOLVED_NVIM_BIN"
git clone --depth 1 "$REPO_URL" "$TMP_DIR"
mv "$TMP_DIR" "$INSTALL_DIR"

mkdir -p "$BIN_DIR"

cat >"$LAUNCHER" <<EOF
#!/bin/sh
export NVIM_APPNAME="$APPNAME"
exec "$RESOLVED_NVIM_BIN" "\$@"
EOF

chmod +x "$LAUNCHER"

info "Installed zVim launcher at $LAUNCHER"

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *)
    info "Add $BIN_DIR to your PATH to run $COMMAND_NAME from any shell."
    ;;
esac

info "Run zVim with: $COMMAND_NAME"
