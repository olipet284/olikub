#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/pipx/venvs/gnome-extensions-cli/bin" "$tmp/home"

cat > "$tmp/bin/pipx" <<'MOCK'
#!/usr/bin/env bash
if [[ $1 == environment && $2 == --value && $3 == PIPX_HOME ]]; then
  printf '%s\n' "$PIPX_HOME_TEST"
fi
MOCK
cat > "$tmp/bin/sudo" <<'MOCK'
#!/usr/bin/env bash
exit 0
MOCK
cat > "$tmp/bin/gum" <<'MOCK'
#!/usr/bin/env bash
exit 0
MOCK
cat > "$tmp/bin/gext" <<'MOCK'
#!/usr/bin/env bash
printf 'PATH gext should not run\n' >> "$GEXT_LOG"
exit 1
MOCK
for command in apt gnome-extensions gsettings glib-compile-schemas; do
  cat > "$tmp/bin/$command" <<'MOCK'
#!/usr/bin/env bash
exit 0
MOCK
done
cat > "$tmp/pipx/venvs/gnome-extensions-cli/bin/gext" <<'MOCK'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$GEXT_LOG"
MOCK
chmod +x "$tmp/bin/"* "$tmp/pipx/venvs/gnome-extensions-cli/bin/gext"

HOME="$tmp/home" PIPX_HOME_TEST="$tmp/pipx" GEXT_LOG="$tmp/gext.log" \
  PATH="$tmp/bin:/usr/bin:/bin" bash "$root/install/desktop/set-gnome-extensions.sh"
[[ $(wc -l < "$tmp/gext.log") == 7 ]]
grep -Fx 'install tactile@lundal.io' "$tmp/gext.log" >/dev/null
grep -Fx 'install AlphabeticalAppGrid@stuarthayhurst' "$tmp/gext.log" >/dev/null

echo 'GNOME extension checks passed.'
