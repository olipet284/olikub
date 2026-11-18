#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/fixture/install/desktop/optional"

cat > "$tmp/bin/gum" <<'MOCK'
#!/usr/bin/env bash
case " $* " in
  *" Select optional apps "*)
    for arg in "$@"; do [[ "$arg" == --selected ]] && exit 2; done
    printf '%s\n' Spotify
    ;;
  *" Select programming languages "*) printf '%s\n' Python ;;
  *" Select Python versions "*) printf '%s\n' 3.13 ;;
  *" Select databases "*) printf '%s\n' MySQL ;;
  *) exit 3 ;;
esac
MOCK
chmod +x "$tmp/bin/gum"

selected=$(XDG_CURRENT_DESKTOP=GNOME PATH="$tmp/bin:/usr/bin:/bin" \
  bash -c 'source "$1"; printf "%s" "$OLIKUB_FIRST_RUN_OPTIONAL_APPS"' \
  bash "$root/install/first-run-choices.sh")
[[ "$selected" == Spotify ]]

cat > "$tmp/fixture/install/desktop/optional/app-spotify.sh" <<'MOCK'
printf '%s\n' loaded > "$APP_LOG"
MOCK
APP_LOG="$tmp/app.log" OLIKUB_PATH="$tmp/fixture" OLIKUB_FIRST_RUN_OPTIONAL_APPS=Spotify \
  bash -c 'source "$1"' bash "$root/install/desktop/select-optional-apps.sh"
[[ $(<"$tmp/app.log") == loaded ]]

if APP_LOG="$tmp/app.log" OLIKUB_PATH="$tmp/fixture" \
  OLIKUB_FIRST_RUN_OPTIONAL_APPS='usage: gum choose' \
  bash -c 'source "$1"' bash "$root/install/desktop/select-optional-apps.sh" \
  >"$tmp/stdout" 2>"$tmp/stderr"; then
  printf 'invalid optional app selection was accepted\n' >&2
  exit 1
fi
grep -F 'No optional app installer for selected item: usage:' "$tmp/stderr" >/dev/null

echo 'Optional app checks passed.'
