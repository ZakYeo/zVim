#!/bin/sh
set -eu

APPNAME="${ZVIM_APPNAME:-zvim}"
COMMAND_NAME="${ZVIM_COMMAND_NAME:-zvim}"
REPO_URL="${ZVIM_REPO_URL:-https://github.com/ZakYeo/zVim.git}"
NVIM_BIN="${ZVIM_NVIM_BIN:-nvim}"
REQUESTED_VERSION="${ZVIM_VERSION:-latest}"
UPDATE="${ZVIM_UPDATE:-0}"

if [ -z "${HOME:-}" ]; then
  printf '%s\n' "zVim install error: HOME is not set." >&2
  exit 1
fi

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
INSTALL_DIR="${ZVIM_INSTALL_DIR:-$CONFIG_HOME/$APPNAME}"
BIN_DIR="${ZVIM_BIN_DIR:-$HOME/.local/bin}"
LAUNCHER="$BIN_DIR/$COMMAND_NAME"
TMP_DIR="$INSTALL_DIR.tmp.$$"
VERSION_FILE=".zvim-version"

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

normalize_tag() {
  case "$1" in
    v*) printf '%s\n' "$1" ;;
    *) printf 'v%s\n' "$1" ;;
  esac
}

latest_release_tag() {
  tags="$(git ls-remote --tags --refs "$REPO_URL" "v*" 2>/dev/null | sed 's#.*refs/tags/##')"

  if [ -z "$tags" ]; then
    fail "could not find any v* release tags for $REPO_URL."
  fi

  latest="$(printf '%s\n' "$tags" | awk '
    /^v[0-9]+(\.[0-9]+){0,2}$/ {
      version = substr($0, 2)
      split(version, parts, ".")
      major = parts[1] + 0
      minor = parts[2] + 0
      patch = parts[3] + 0

      if (!seen || major > best_major ||
          (major == best_major && minor > best_minor) ||
          (major == best_major && minor == best_minor && patch > best_patch)) {
        seen = 1
        best_major = major
        best_minor = minor
        best_patch = patch
        best_tag = $0
      }
    }
    END {
      if (seen) {
        print best_tag
      }
    }
  ')"

  if [ -z "$latest" ]; then
    fail "could not resolve the latest SemVer release tag for $REPO_URL."
  fi

  printf '%s\n' "$latest"
}

resolve_release_tag() {
  if [ "$REQUESTED_VERSION" = "latest" ]; then
    latest_release_tag
    return
  fi

  normalize_tag "$REQUESTED_VERSION"
}

tag_exists() {
  git ls-remote --exit-code --tags --refs "$REPO_URL" "$1" >/dev/null 2>&1
}

version_gt() {
  awk -v newer="$1" -v older="$2" '
    function clean(version) {
      sub(/^v/, "", version)
      return version
    }
    BEGIN {
      split(clean(newer), a, ".")
      split(clean(older), b, ".")

      for (i = 1; i <= 3; i++) {
        av = a[i] + 0
        bv = b[i] + 0

        if (av > bv) {
          exit 0
        }
        if (av < bv) {
          exit 1
        }
      }

      exit 1
    }
  '
}

installed_version() {
  if [ -f "$INSTALL_DIR/$VERSION_FILE" ]; then
    version="$(sed -n '1p' "$INSTALL_DIR/$VERSION_FILE")"
    if [ -n "$version" ]; then
      normalize_tag "$version"
      return
    fi
  fi

  if [ -d "$INSTALL_DIR/.git" ]; then
    git -C "$INSTALL_DIR" describe --tags --exact-match 2>/dev/null || true
  fi
}

install_is_dirty() {
  if [ ! -d "$INSTALL_DIR/.git" ]; then
    return 1
  fi

  [ -n "$(git -C "$INSTALL_DIR" status --porcelain)" ]
}

can_prompt() {
  [ -t 1 ] || return 1
  : 2>/dev/null >/dev/tty
}

confirm_update() {
  if [ "$UPDATE" = "1" ]; then
    return 0
  fi

  if ! can_prompt; then
    return 1
  fi

  printf 'Update zVim from %s to %s? [y/N] ' "$1" "$2" >/dev/tty
  if ! read answer </dev/tty; then
    return 1
  fi

  case "$answer" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

write_launcher() {
  mkdir -p "$BIN_DIR"

  cat >"$LAUNCHER" <<EOF
#!/bin/sh
export NVIM_APPNAME="$APPNAME"
exec "$RESOLVED_NVIM_BIN" "\$@"
EOF

  chmod +x "$LAUNCHER"
}

clone_release() {
  tag="$1"

  if [ -e "$TMP_DIR" ]; then
    fail "$TMP_DIR already exists. Remove it before installing zVim."
  fi

  git -c advice.detachedHead=false clone --depth 1 --branch "$tag" "$REPO_URL" "$TMP_DIR"
  printf '%s\n' "$tag" >"$TMP_DIR/$VERSION_FILE"
}

replace_install() {
  backup_dir="$INSTALL_DIR.backup.$$"

  if [ -e "$backup_dir" ]; then
    fail "$backup_dir already exists. Remove it before updating zVim."
  fi

  mv "$INSTALL_DIR" "$backup_dir"
  mv "$TMP_DIR" "$INSTALL_DIR"
  rm -rf "$backup_dir"
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
RESOLVED_TAG="$(resolve_release_tag)"

if [ -e "$INSTALL_DIR" ]; then
  CURRENT_TAG="$(installed_version)"

  if [ -z "$CURRENT_TAG" ]; then
    CURRENT_TAG="unknown"
  fi

  if [ "$CURRENT_TAG" != "unknown" ] && [ "$REQUESTED_VERSION" = "latest" ] && ! version_gt "$RESOLVED_TAG" "$CURRENT_TAG"; then
    info "zVim is already up to date at $CURRENT_TAG."
    exit 0
  fi

  if [ "$CURRENT_TAG" != "unknown" ] && [ "$REQUESTED_VERSION" != "latest" ] && [ "$RESOLVED_TAG" = "$CURRENT_TAG" ]; then
    info "zVim is already installed at $CURRENT_TAG."
    exit 0
  fi

  if install_is_dirty; then
    fail "$INSTALL_DIR has local changes. Commit, stash, or back them up before updating zVim."
  fi

  if ! confirm_update "$CURRENT_TAG" "$RESOLVED_TAG"; then
    if can_prompt; then
      info "Skipped zVim update."
    else
      info "A newer zVim release is available: $CURRENT_TAG -> $RESOLVED_TAG."
      info "Run with ZVIM_UPDATE=1 to update non-interactively."
    fi
    exit 0
  fi

  if ! tag_exists "$RESOLVED_TAG"; then
    fail "release tag $RESOLVED_TAG was not found for $REPO_URL."
  fi

  info "Updating zVim from $CURRENT_TAG to $RESOLVED_TAG"
  info "Using Neovim binary: $RESOLVED_NVIM_BIN"
  clone_release "$RESOLVED_TAG"
  replace_install
  write_launcher
  info "Updated zVim launcher at $LAUNCHER"
  info "Run the zVim CLI with: $COMMAND_NAME"
  exit 0
fi

if [ -e "$LAUNCHER" ]; then
  fail "$LAUNCHER already exists. Move it out of the way before installing zVim."
fi

LEGACY_LAUNCHER="$BIN_DIR/zVim"

if [ "$COMMAND_NAME" != "zVim" ] && [ -e "$LEGACY_LAUNCHER" ]; then
  info "Found legacy uppercase launcher at $LEGACY_LAUNCHER. Remove it if you no longer need it."
fi

if [ -e "$TMP_DIR" ]; then
  fail "$TMP_DIR already exists. Remove it before installing zVim."
fi

if ! tag_exists "$RESOLVED_TAG"; then
  fail "release tag $RESOLVED_TAG was not found for $REPO_URL."
fi

info "Installing zVim $RESOLVED_TAG into $INSTALL_DIR"
info "Using Neovim binary: $RESOLVED_NVIM_BIN"
clone_release "$RESOLVED_TAG"
mv "$TMP_DIR" "$INSTALL_DIR"

write_launcher

info "Installed zVim launcher at $LAUNCHER"

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *)
    info "Add $BIN_DIR to your PATH to run $COMMAND_NAME from any shell."
    ;;
esac

info "Run the zVim CLI with: $COMMAND_NAME"
