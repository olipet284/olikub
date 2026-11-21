#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/running-bin" "$tmp/restricted"

# Obsidian not running by default; a second bin dir reports it running.
cat > "$tmp/bin/pgrep" <<'MOCK'
#!/usr/bin/env bash
exit 1
MOCK
cat > "$tmp/running-bin/pgrep" <<'MOCK'
#!/usr/bin/env bash
exit 0
MOCK
chmod +x "$tmp/bin/pgrep" "$tmp/running-bin/pgrep"

# A restricted PATH without Obsidian, to prove the helper stays quiet.
for tool in grep sed mkdir cp cat readlink ln rm; do
  ln -s "$(command -v "$tool")" "$tmp/restricted/$tool"
done
cp "$tmp/bin/pgrep" "$tmp/restricted/pgrep"

printf '%s\n' '/* fixture obsidian theme */' > "$tmp/fixture.css"

run() {
  HOME="$1" OLIKUB_OBSIDIAN_CSS="$tmp/fixture.css" PATH="$2" \
    /bin/bash -c 'source "$1/themes/set-obsidian-theme.sh"' _ "$root"
}

# Obsidian absent: nothing is created.
mkdir -p "$tmp/absent-home"
run "$tmp/absent-home" "$tmp/restricted"
[[ ! -e "$tmp/absent-home/.local/state/olikub/obsidian" ]]

# Registry and config file vaults, with duplicates and ~ expansion.
home="$tmp/home"
mkdir -p "$home/.config/obsidian" "$home/.config/olikub"
for name in one two three four; do
  mkdir -p "$home/vaults/$name/.obsidian"
done
cat > "$home/.config/obsidian/obsidian.json" <<EOF
{"vaults":{"a":{"path":"$home/vaults/one","ts":1,"open":true},"b":{"path":"$home/vaults/two","ts":2}}}
EOF
cat > "$home/.config/olikub/obsidian-vaults" <<EOF
# extra vaults, one per line
$home/vaults/three

~/vaults/four
$home/vaults/one
EOF

# An existing appearance with a different theme keeps its other settings.
printf '%s\n' '{"cssTheme":"Omarchy","theme":"system"}' > "$home/vaults/two/.obsidian/appearance.json"

# A theme directory Olikub did not create is left untouched.
mkdir -p "$home/vaults/one/.obsidian/themes/Olikub"
printf '%s\n' 'user theme' > "$home/vaults/one/.obsidian/themes/Olikub/theme.css"

# A vault listed but never opened by Obsidian is skipped.
mkdir -p "$home/vaults/not-a-vault"
printf '%s\n' "$home/vaults/not-a-vault" >> "$home/.config/olikub/obsidian-vaults"

run "$home" "$tmp/bin:/usr/bin:/bin"

shared="$home/.local/state/olikub/obsidian"
grep -F '"name": "Olikub"' "$shared/manifest.json" >/dev/null
cmp "$tmp/fixture.css" "$shared/theme.css"

# Vault one had a real theme dir: left alone, not replaced by a symlink.
[[ -d "$home/vaults/one/.obsidian/themes/Olikub" && ! -L "$home/vaults/one/.obsidian/themes/Olikub" ]]
grep -Fx 'user theme' "$home/vaults/one/.obsidian/themes/Olikub/theme.css" >/dev/null

for name in two three four; do
  link="$home/vaults/$name/.obsidian/themes/Olikub"
  [[ -L "$link" ]]
  [[ "$(readlink "$link")" == "$shared" ]]
done

# cssTheme set where missing, and replaced without losing other keys.
grep -F '"cssTheme": "Olikub"' "$home/vaults/two/.obsidian/appearance.json" >/dev/null
grep -F '"theme":"system"' "$home/vaults/two/.obsidian/appearance.json" >/dev/null
grep -F '"cssTheme": "Olikub"' "$home/vaults/three/.obsidian/appearance.json" >/dev/null

# The unopened directory is not themed.
[[ ! -e "$home/vaults/not-a-vault/.obsidian/themes/Olikub" ]]

# Switching theme rewrites the shared CSS only.
printf '%s\n' '/* second fixture */' > "$tmp/second.css"
HOME="$home" OLIKUB_OBSIDIAN_CSS="$tmp/second.css" PATH="$tmp/bin:/usr/bin:/bin" \
  /bin/bash -c 'source "$1/themes/set-obsidian-theme.sh"' _ "$root" >/dev/null
cmp "$tmp/second.css" "$shared/theme.css"

# Obsidian running: theme files update, appearance is left alone.
run_home="$tmp/running-home"
mkdir -p "$run_home/.config/obsidian" "$run_home/vaults/six/.obsidian"
printf '%s\n' "{\"vaults\":{\"a\":{\"path\":\"$run_home/vaults/six\",\"ts\":1}}}" \
  > "$run_home/.config/obsidian/obsidian.json"
output=$(run "$run_home" "$tmp/running-bin:/usr/bin:/bin")
[[ -L "$run_home/vaults/six/.obsidian/themes/Olikub" ]]
[[ ! -e "$run_home/vaults/six/.obsidian/appearance.json" ]]
grep -F 'Obsidian is running' <<<"$output" >/dev/null

echo 'Obsidian theme checks passed.'
