#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT

fixture="$tmp/fixture"
markers="$tmp/markers"
log="$tmp/actions.log"
mkdir -p "$fixture/apps/cli/fake" "$fixture/apps/gui/fake" "$markers"
export MARKERS="$markers" ACTION_LOG="$log"

cat > "$fixture/apps/cli/fake/installed-app.sh" <<'APP'
#!/bin/bash
APP_NAME="Installed App"
APP_DESCRIPTION="Already on the system"
APP_DEFAULT=1
app_installed() { [[ -f "$MARKERS/installed-app" ]]; }
app_install() { printf 'install %s\n' installed-app >> "$ACTION_LOG"; touch "$MARKERS/installed-app"; }
app_uninstall() { printf 'uninstall %s\n' installed-app >> "$ACTION_LOG"; rm -f "$MARKERS/installed-app"; }
APP

cat > "$fixture/apps/cli/fake/missing-app.sh" <<'APP'
#!/bin/bash
APP_NAME="Missing App"
APP_DESCRIPTION="Not on the system"
APP_DEFAULT=1
app_installed() { [[ -f "$MARKERS/missing-app" ]]; }
app_install() { printf 'install %s\n' missing-app >> "$ACTION_LOG"; touch "$MARKERS/missing-app"; }
app_uninstall() { printf 'uninstall %s\n' missing-app >> "$ACTION_LOG"; rm -f "$MARKERS/missing-app"; }
APP

cat > "$fixture/apps/gui/fake/optional-app.sh" <<'APP'
#!/bin/bash
APP_NAME="Optional App"
APP_DESCRIPTION="Only from the menu"
APP_DEFAULT=0
APP_BIN=optional-app
app_install() { printf 'install %s\n' optional-app >> "$ACTION_LOG"; }
app_uninstall() { printf 'uninstall %s\n' optional-app >> "$ACTION_LOG"; }
APP

touch "$markers/installed-app"

OLIKUB_PATH="$fixture"
export OLIKUB_PATH
# shellcheck disable=SC1090
source "$root/lib/apps.sh"

basenames() {
  while IFS= read -r file; do basename "$file" .sh; done
}

install_candidates="$(apps_candidates install | basenames | sort | tr '\n' ' ')"
uninstall_candidates="$(apps_candidates uninstall | basenames | sort | tr '\n' ' ')"
[[ "$install_candidates" == 'missing-app optional-app ' ]]
[[ "$uninstall_candidates" == 'installed-app ' ]]

groups="$(apps_groups install)"
grep -Fx $'cli/fake\tCLI / Fake\t1' <<<"$groups" >/dev/null
grep -Fx $'gui/fake\tGUI / Fake\t1' <<<"$groups" >/dev/null
if apps_candidates uninstall | grep -q missing-app; then
  printf 'installed filtering failed\n' >&2
  exit 1
fi

# A default install only installs missing APP_DEFAULT=1 apps.
: > "$log"
olikub_apps_install_defaults
[[ "$(<"$log")" == 'install missing-app' ]]
[[ -f "$markers/missing-app" ]]

# Dispatch calls only the requested action.
: > "$log"
OLIKUB_APPS_ASSUME_YES=1 apps_apply install "$fixture/apps/gui/fake/optional-app.sh"
[[ "$(<"$log")" == 'install optional-app' ]]

: > "$log"
OLIKUB_APPS_ASSUME_YES=1 apps_apply uninstall "$fixture/apps/cli/fake/installed-app.sh"
[[ "$(<"$log")" == 'uninstall installed-app' ]]
[[ ! -f "$markers/installed-app" ]]

# The two-level menu only shows installable apps and maps the chosen display
# back to the right app file.
mockbin="$tmp/mockbin"
mkdir -p "$mockbin"
cat > "$mockbin/gum" <<'GUM'
#!/usr/bin/env bash
case "$*" in
  *"Install application"*)
    printf '%s\n' 'CLI / Fake (1)'
    ;;
  *"Select CLI / Fake apps to install"*)
    printf '%s\n' 'Missing App — Not on the system'
    ;;
  confirm*) exit 0 ;;
  style*) exit 0 ;;
  *) exit 1 ;;
esac
GUM
chmod +x "$mockbin/gum"
rm -f "$markers/missing-app"
touch "$markers/installed-app"
: > "$log"
OLIKUB_PATH="$fixture" APPS_DIR="$fixture/apps" PATH="$mockbin:$PATH" \
  bash -c 'source "$1/lib/apps.sh"; apps_menu install' bash "$root"
[[ "$(<"$log")" == 'install missing-app' ]]

# Status output must report the same detection used by the menus.
[[ "$(olikub_apps_status | awk '$3 == "installed-app" { print $4 }')" == installed ]]
[[ "$(olikub_apps_status | awk '$3 == "optional-app" { print $4 }')" == missing ]]

# The real catalog is well formed: every app declares metadata and handlers,
# and every path is apps/<kind>/<topic>/<id>.sh.
unset OLIKUB_PATH
OLIKUB_PATH="$root"
APPS_DIR="$root/apps"
export OLIKUB_PATH
while IFS= read -r file; do
  rel="${file#"$root/apps/"}"
  [[ "$rel" =~ ^(cli|tui|gui)/[^/]+/[^/]+\.sh$ ]] || {
    printf 'bad catalog path: %s\n' "$rel" >&2
    exit 1
  }
  metadata="$( (
    # shellcheck disable=SC1090
    source "$file"
    declare -F app_install >/dev/null || exit 4
    declare -F app_uninstall >/dev/null || exit 5
    [[ -n "${APP_NAME:-}" ]] || exit 6
    [[ -n "${APP_DESCRIPTION:-}" ]] || exit 7
    printf 'ok\n'
  ) )" || {
    printf 'invalid app file: %s\n' "$rel" >&2
    exit 1
  }
  [[ "$metadata" == ok ]]
done < <(app_files)

echo 'App catalog checks passed.'
