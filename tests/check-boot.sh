#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/home"
export HOME="$tmp/home" PATH="$tmp/bin:/usr/bin:/bin" TEST_LOG="$tmp/log"
unset OLIKUB_PATH

cat > "$tmp/bin/sudo" <<'MOCK'
#!/usr/bin/env bash
exit 0
MOCK

cat > "$tmp/bin/git" <<'MOCK'
#!/usr/bin/env bash
set -euo pipefail
case $1 in
  clone)
    [[ $2 == --branch && $3 == main && $4 == --single-branch ]] || exit 20
    target=$6
    printf 'clone %s\n' "$target" >> "$TEST_LOG"
    mkdir -p "$target"
    printf '%s\n' 'https://github.com/olipet284/olikub' > "$target/.origin"
    printf '%s\n' main > "$target/.branch"
    cat > "$target/install.sh" <<'INSTALL'
printf '%s\n' "$OLIKUB_PATH" >> "$TEST_LOG"
INSTALL
    ;;
  -C)
    target=$2
    shift 2
    case $1 in
      rev-parse) printf '%s\n' "$target" ;;
      config) cat "$target/.origin" ;;
      symbolic-ref) cat "$target/.branch" ;;
      *) exit 21 ;;
    esac
    ;;
  *) exit 22 ;;
esac
MOCK
chmod +x "$tmp/bin/sudo" "$tmp/bin/git"

target="$HOME/repos/Olikub checkout"
bash "$root/boot.sh" --directory "$target" >/dev/null
[[ $(<"$TEST_LOG") == $'clone '"$target"$'\n'"$target" ]]

: > "$TEST_LOG"
bash "$root/boot.sh" --directory "$target" >/dev/null
[[ $(<"$TEST_LOG") == "$target" ]]

printf '%s\n' feature > "$target/.branch"
if bash "$root/boot.sh" --directory "$target" >/dev/null 2>&1; then
  printf 'non-main checkout was accepted\n' >&2
  exit 1
fi
printf '%s\n' main > "$target/.branch"
printf '%s\n' https://example.com/not-olikub.git > "$target/.origin"
if bash "$root/boot.sh" --directory "$target" >/dev/null 2>&1; then
  printf 'unofficial checkout was accepted\n' >&2
  exit 1
fi

if bash "$root/boot.sh" --directory relative/path >/dev/null 2>&1; then
  printf 'relative checkout path was accepted\n' >&2
  exit 1
fi

tilde_target="$HOME/from tilde"
: > "$TEST_LOG"
bash "$root/boot.sh" --directory '~/from tilde' >/dev/null
[[ $(<"$TEST_LOG") == $'clone '"$tilde_target"$'\n'"$tilde_target" ]]

local_checkout="$HOME/repos/local Olikub"
mkdir -p "$local_checkout" "$HOME/.config/olikub" "$HOME/.cargo" "$HOME/dotfiles/bash"
cp "$root/boot.sh" "$local_checkout/boot.sh"
printf '%s\n' 'https://github.com/olipet284/olikub' > "$local_checkout/.origin"
printf '%s\n' main > "$local_checkout/.branch"
cat > "$local_checkout/install.sh" <<'INSTALL'
printf '%s\n' "$OLIKUB_PATH" >> "$TEST_LOG"
INSTALL
: > "$HOME/.cargo/env"
: > "$HOME/dotfiles/bash/empty.sh"
: > "$TEST_LOG"
bash "$local_checkout/boot.sh" >/dev/null
[[ $(<"$TEST_LOG") == "$local_checkout" ]]

ln -s "$root" "$HOME/Olikub checkout"
printf '%s\n' "$HOME/Olikub checkout" > "$HOME/.config/olikub/path"
XDG_CONFIG_HOME="$HOME/.config" bash -c 'source "$1"; [[ $OLIKUB_PATH == "$2" ]]' bash "$root/configs/bashrc" "$HOME/Olikub checkout"

echo 'Boot checks passed.'
