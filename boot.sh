#!/bin/bash

set -e

repository=https://github.com/olipet284/olikub.git
install_dir=${OLIKUB_PATH:-${HOME:?HOME is not set}/.local/share/olikub}
directory_was_set=false
[[ -z ${OLIKUB_PATH:-} ]] || directory_was_set=true

is_official_origin() {
  local origin=${1%.git}
  [[ $origin == https://github.com/olipet284/olikub ||
    $origin == git@github.com:olipet284/olikub ||
    $origin == ssh://git@github.com/olipet284/olikub ]]
}

usage() {
  printf 'Usage: boot.sh [--directory PATH]\n'
}

while (($#)); do
  case $1 in
    --directory)
      [[ $# -ge 2 && -n $2 ]] || { usage >&2; exit 2; }
      install_dir=$2
      directory_was_set=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if ! $directory_was_set; then
  script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd -P || true)
  script_origin=$(git -C "$script_dir" config --get remote.origin.url 2>/dev/null || true)
  if [[ -n $script_dir && -f $script_dir/install.sh ]] &&
    is_official_origin "$script_origin" &&
    [[ $(git -C "$script_dir" symbolic-ref --quiet --short HEAD 2>/dev/null || true) == main ]]; then
    install_dir=$script_dir
    directory_was_set=true
  fi
fi

case $install_dir in
  '~') install_dir=$HOME ;;
  '~/'*) install_dir="$HOME/${install_dir:2}" ;;
  /*) ;;
  *) printf 'Checkout path must be absolute: %s\n' "$install_dir" >&2; exit 2 ;;
esac

if ! $directory_was_set && [[ -t 1 && -r /dev/tty && -w /dev/tty ]]; then
  printf 'Olikub checkout directory [%s]: ' "$install_dir" >/dev/tty
  IFS= read -r selected_dir </dev/tty || selected_dir=
  [[ -z $selected_dir ]] || install_dir=$selected_dir
  case $install_dir in
    '~') install_dir=$HOME ;;
    '~/'*) install_dir="$HOME/${install_dir:2}" ;;
    /*) ;;
    *) printf 'Checkout path must be absolute: %s\n' "$install_dir" >&2; exit 2 ;;
  esac
fi

[[ $install_dir != *$'\n'* ]] || { printf 'Checkout path cannot contain a newline.\n' >&2; exit 2; }

ascii_art=' ▄██████▄   ▄█        ▄█     ▄█   ▄█▄ ███    █▄  ▀█████████▄
███    ███ ███       ███    ███ ▄███▀ ███    ███   ███    ███
███    ███ ███       ███▌   ███▐██▀   ███    ███   ███    ███
███    ███ ███       ███▌  ▄█████▀    ███    ███  ▄███▄▄▄██▀
███    ███ ███       ███▌ ▀▀█████▄    ███    ███ ▀▀███▀▀▀██▄
███    ███ ███       ███    ███▐██▄   ███    ███   ███    ██▄
███    ███ ███▌    ▄ ███    ███ ▀███▄ ███    ███   ███    ███
 ▀██████▀  █████▄▄██ █▀     ███   ▀█▀ ████████▀  ▄█████████▀
           ▀                ▀
'

echo -e "$ascii_art"
echo "=> Olikub is for fresh Ubuntu 26.04+ installations only!"
echo -e "\nBegin installation (or abort with ctrl+c)..."

sudo apt-get update >/dev/null
sudo apt-get install -y git >/dev/null

if [[ -e $install_dir || -L $install_dir ]]; then
  [[ -d $install_dir && ! -L $install_dir ]] || { printf 'Checkout path is not a real directory: %s\n' "$install_dir" >&2; exit 1; }
  checkout_root=$(git -C "$install_dir" rev-parse --show-toplevel 2>/dev/null) || { printf 'Not a Git checkout: %s\n' "$install_dir" >&2; exit 1; }
  [[ $(cd "$checkout_root" && pwd -P) == "$(cd "$install_dir" && pwd -P)" ]] || { printf 'Not a checkout root: %s\n' "$install_dir" >&2; exit 1; }
  origin=$(git -C "$install_dir" config --get remote.origin.url 2>/dev/null || true)
  is_official_origin "$origin" || { printf 'Checkout origin differs from %s.\n' "$repository" >&2; exit 1; }
  [[ $(git -C "$install_dir" symbolic-ref --quiet --short HEAD 2>/dev/null || true) == main ]] || { printf 'Checkout must be on branch main: %s\n' "$install_dir" >&2; exit 1; }
  [[ -f $install_dir/install.sh ]] || { printf 'Checkout has no install.sh: %s\n' "$install_dir" >&2; exit 1; }
  echo "Using existing Olikub checkout at $install_dir..."
else
  echo "Cloning Olikub to $install_dir..."
  mkdir -p "$(dirname "$install_dir")"
  git clone --branch main --single-branch "$repository" "$install_dir" >/dev/null
fi

echo "Installation starting..."
export OLIKUB_PATH="$install_dir"
source "$OLIKUB_PATH/install.sh"
