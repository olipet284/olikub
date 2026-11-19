#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
# bash is called by absolute path below because PATH is deliberately minimal.
bash_bin=${BASH:-/bin/bash}
mkdir -p "$tmp/home/.local/bin" "$tmp/home/.cargo"

# External commands the shell init might reach for. uv/uvx live in
# ~/.local/bin because the init script calls them by absolute path.
cat > "$tmp/home/.local/bin/mise" <<'MOCK'
#!/bin/bash
exit 0
MOCK
cat > "$tmp/home/.local/bin/zoxide" <<'MOCK'
#!/bin/bash
exit 0
MOCK
cat > "$tmp/home/.local/bin/uv" <<'MOCK'
#!/bin/bash
printf '%s\n' "uv $*" >> "$UV_LOG"
MOCK
cat > "$tmp/home/.local/bin/uvx" <<'MOCK'
#!/bin/bash
printf '%s\n' "uvx $*" >> "$UVX_LOG"
exit 1
MOCK
chmod +x "$tmp/home/.local/bin/"*
: > "$tmp/home/.cargo/env"

# uv may generate completions; uvx must never be invoked as a tool runner.
UV_LOG="$tmp/uv.log" UVX_LOG="$tmp/uvx.log" HOME="$tmp/home" \
  PATH="$tmp/home/.local/bin" \
  "$bash_bin" -c 'source "$1"' _ "$root/defaults/bash/init" >/dev/null 2>&1 || true
[[ -e "$tmp/uv.log" ]]
[[ ! -e "$tmp/uvx.log" ]]

# configs/bashrc sources optional private fragments from ~/dotfiles/bash.
fixture="$tmp/fixture"
mkdir -p "$fixture/defaults/bash"
printf '%s\n' 'true' > "$fixture/defaults/bash/rc"

mkdir -p "$tmp/home/dotfiles/bash"
OLIKUB_PATH="$fixture" HOME="$tmp/home" \
  "$bash_bin" -c 'source "$1"' _ "$root/configs/bashrc" 2> "$tmp/empty.err"
[[ ! -s "$tmp/empty.err" ]]

printf '%s\n' 'OLIKUB_TEST_MARK=loaded' > "$tmp/home/dotfiles/bash/10-marker.sh"
mark=$(OLIKUB_PATH="$fixture" HOME="$tmp/home" \
  "$bash_bin" -c 'source "$1"; printf "%s" "${OLIKUB_TEST_MARK:-}"' _ "$root/configs/bashrc")
[[ "$mark" == loaded ]]

rm -rf "$tmp/home/dotfiles"
OLIKUB_PATH="$fixture" HOME="$tmp/home" \
  "$bash_bin" -c 'source "$1"' _ "$root/configs/bashrc" 2> "$tmp/missing.err"
[[ ! -s "$tmp/missing.err" ]]

echo 'Shell init checks passed.'
