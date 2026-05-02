#!/bin/sh
set -eu

ENV_FILE="${ENV_FILE:-.env}"
VERSION_FILE="${VERSION_FILE:-VERSION}"
REMOTE="${RELEASE_REMOTE:-origin}"
BRANCH="${RELEASE_BRANCH:-main}"

info() {
  printf '%s\n' "$1"
}

fail() {
  printf '%s\n' "release error: $1" >&2
  exit 1
}

need_command() {
  command -v "$1" >/dev/null 2>&1 || fail "missing required command: $1"
}

prompt() {
  message="$1"
  default="${2:-}"

  if [ -n "$default" ]; then
    printf '%s [%s]: ' "$message" "$default" >/dev/tty
  else
    printf '%s: ' "$message" >/dev/tty
  fi

  read answer </dev/tty || fail "could not read input"
  if [ -z "$answer" ] && [ -n "$default" ]; then
    printf '%s\n' "$default"
  else
    printf '%s\n' "$answer"
  fi
}

confirm() {
  message="$1"
  default="${2:-N}"

  answer="$(prompt "$message" "$default")"
  case "$answer" in
    y|Y|yes|YES) return 0 ;;
    n|N|no|NO) return 1 ;;
    *) fail "please answer yes or no" ;;
  esac
}

load_env() {
  if [ -f "$ENV_FILE" ]; then
    # shellcheck disable=SC1090
    set -a
    case "$ENV_FILE" in
      /*) . "$ENV_FILE" ;;
      *) . "./$ENV_FILE" ;;
    esac
    set +a
  fi
}

current_branch() {
  git rev-parse --abbrev-ref HEAD
}

current_version() {
  [ -f "$VERSION_FILE" ] || fail "$VERSION_FILE does not exist"
  version="$(sed -n '1p' "$VERSION_FILE" | tr -d '[:space:]')"

  case "$version" in
    [0-9]*.[0-9]*.[0-9]*) printf '%s\n' "$version" ;;
    *) fail "$VERSION_FILE must contain a SemVer version like 1.2.3" ;;
  esac
}

bump_version() {
  version="$1"
  release_type="$2"

  major="$(printf '%s\n' "$version" | awk -F. '{ print $1 }')"
  minor="$(printf '%s\n' "$version" | awk -F. '{ print $2 }')"
  patch="$(printf '%s\n' "$version" | awk -F. '{ print $3 }')"

  case "$release_type" in
    major) printf '%s.0.0\n' "$((major + 1))" ;;
    minor) printf '%s.%s.0\n' "$major" "$((minor + 1))" ;;
    patch) printf '%s.%s.%s\n' "$major" "$minor" "$((patch + 1))" ;;
    *) fail "release type must be major, minor, or patch" ;;
  esac
}

read_release_notes() {
  printf '%s\n' "Enter the GitHub release description. Finish with a single '.' on its own line." >/dev/tty
  notes=""

  while :; do
    printf '> ' >/dev/tty
    read line </dev/tty || fail "could not read release description"
    [ "$line" = "." ] && break

    if [ -z "$notes" ]; then
      notes="$line"
    else
      notes="${notes}
$line"
    fi
  done

  [ -n "$notes" ] || fail "release description cannot be empty"
  printf '%s\n' "$notes"
}

assert_clean_worktree() {
  if [ -n "$(git status --porcelain)" ]; then
    git status --short
    fail "working tree is not clean. Commit or stash changes before releasing."
  fi
}

assert_synced() {
  git fetch "$REMOTE" "$BRANCH" --tags

  local_head="$(git rev-parse HEAD)"
  remote_head="$(git rev-parse "$REMOTE/$BRANCH")"

  [ "$local_head" = "$remote_head" ] || fail "local HEAD does not match $REMOTE/$BRANCH"
}

assert_tag_available() {
  tag="$1"

  if git rev-parse -q --verify "refs/tags/$tag" >/dev/null; then
    fail "local tag $tag already exists"
  fi

  if git ls-remote --exit-code --tags "$REMOTE" "refs/tags/$tag" >/dev/null 2>&1; then
    fail "remote tag $tag already exists"
  fi
}

create_github_release_with_gh() {
  tag="$1"
  title="$2"
  notes_file="$3"
  draft="$4"
  prerelease="$5"

  args=""
  [ "$draft" = "1" ] && args="$args --draft"
  [ "$prerelease" = "1" ] && args="$args --prerelease"

  # shellcheck disable=SC2086
  gh release create "$tag" --title "$title" --notes-file "$notes_file" $args
}

create_github_release_with_api() {
  tag="$1"
  title="$2"
  notes_file="$3"
  draft="$4"
  prerelease="$5"

  need_command python3

  [ -n "${GITHUB_TOKEN:-}" ] || fail "GITHUB_TOKEN is required in $ENV_FILE when gh is unavailable"
  [ -n "${GITHUB_REPOSITORY:-}" ] || fail "GITHUB_REPOSITORY is required in $ENV_FILE when gh is unavailable, for example ZakYeo/zVim"

  python3 - "$tag" "$title" "$notes_file" "$draft" "$prerelease" <<'PY'
import json
import os
import sys
import urllib.request

tag, title, notes_file, draft, prerelease = sys.argv[1:]
repo = os.environ["GITHUB_REPOSITORY"]
token = os.environ["GITHUB_TOKEN"]

with open(notes_file, "r", encoding="utf-8") as handle:
    body = handle.read()

payload = json.dumps({
    "tag_name": tag,
    "name": title,
    "body": body,
    "draft": draft == "1",
    "prerelease": prerelease == "1",
}).encode("utf-8")

request = urllib.request.Request(
    f"https://api.github.com/repos/{repo}/releases",
    data=payload,
    headers={
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
        "X-GitHub-Api-Version": "2022-11-28",
    },
    method="POST",
)

try:
    with urllib.request.urlopen(request) as response:
        release = json.loads(response.read().decode("utf-8"))
        print(release.get("html_url", "GitHub release created"))
except urllib.error.HTTPError as error:
    print(error.read().decode("utf-8"), file=sys.stderr)
    raise SystemExit(error.code)
PY
}

main() {
  need_command git
  load_env

  [ -t 0 ] || fail "this script must be run interactively"
  [ -t 1 ] || fail "this script must be run interactively"

  branch="$(current_branch)"
  [ "$branch" = "$BRANCH" ] || fail "run releases from $BRANCH, currently on $branch"

  assert_clean_worktree
  assert_synced

  old_version="$(current_version)"
  release_type="$(prompt "Release type: major, minor, or patch" "patch")"
  new_version="$(bump_version "$old_version" "$release_type")"
  tag="v$new_version"

  assert_tag_available "$tag"

  title="$(prompt "Release title" "$tag")"
  notes_file="$(mktemp "${TMPDIR:-/tmp}/zvim-release-notes.XXXXXX")"
  trap 'rm -f "$notes_file"' EXIT HUP INT TERM
  read_release_notes >"$notes_file"

  draft=0
  prerelease=0
  if confirm "Create as a draft GitHub release?" "N"; then
    draft=1
  fi
  if confirm "Mark as a prerelease?" "N"; then
    prerelease=1
  fi

  info ""
  info "Release summary:"
  info "  Version: $old_version -> $new_version"
  info "  Tag: $tag"
  info "  Remote: $REMOTE"
  info "  Branch: $BRANCH"
  [ "$draft" = "1" ] && info "  Draft: yes" || info "  Draft: no"
  [ "$prerelease" = "1" ] && info "  Prerelease: yes" || info "  Prerelease: no"
  info ""

  confirm "Create commit, tag, push to GitHub, and create the GitHub release?" "N" || fail "release cancelled"

  printf '%s\n' "$new_version" >"$VERSION_FILE"
  git add "$VERSION_FILE"
  git commit -m "chore: release $tag"
  git tag -a "$tag" -F "$notes_file"
  git push "$REMOTE" "$BRANCH"
  git push "$REMOTE" "$tag"

  if command -v gh >/dev/null 2>&1; then
    create_github_release_with_gh "$tag" "$title" "$notes_file" "$draft" "$prerelease"
  else
    create_github_release_with_api "$tag" "$title" "$notes_file" "$draft" "$prerelease"
  fi

  info "Released $tag."
}

main "$@"
