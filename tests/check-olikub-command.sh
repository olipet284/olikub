#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/home" "$tmp/config"

cat > "$tmp/bin/gum" <<'MOCK'
#!/usr/bin/env bash
case " $* " in
  *"Choose your theme"*) printf '%s\n' '<< Back' ;;
  *) printf '%s\n' Quit ;;
esac
MOCK
chmod +x "$tmp/bin/gum"

HOME="$tmp/home" XDG_CONFIG_HOME="$tmp/config" OLIKUB_PATH="$root" \
  PATH="$tmp/bin:/usr/bin:/bin" bash "$root/install/terminal/a-shell.sh" >/dev/null
[[ -x "$tmp/home/.local/bin/olikub" ]]

env -u OLIKUB_PATH HOME="$tmp/home" XDG_CONFIG_HOME="$tmp/config" \
  PATH="$tmp/home/.local/bin:$tmp/bin:/usr/bin:/bin" olikub theme >/dev/null

echo 'Olikub command checks passed.'
