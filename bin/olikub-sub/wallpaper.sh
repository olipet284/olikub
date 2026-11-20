#!/bin/bash

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/olikub"
BACKGROUND_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/backgrounds"
THEME_STATE="$STATE_DIR/theme"
INDEX_STATE="$STATE_DIR/wallpaper-index"

die() {
  printf '%s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<EOF
Usage: olikub wallpaper [next|prev|apply|generate] [theme]

  next      Apply the next wallpaper for the active theme.
  prev      Apply the previous wallpaper for the active theme.
  apply     Apply the theme's Ubuntu wallpaper (the default).
  generate  Write the theme's Ubuntu wallpaper without applying it.
            Pass "all" to generate one for every theme.
EOF
}

load_theme_conf() {
  local theme=$1 conf="$OLIKUB_PATH/themes/$1/theme.conf"
  [[ -d "$OLIKUB_PATH/themes/$theme" ]] || die "Unknown Olikub theme: $theme"
  [[ -f $conf ]] || die "Missing theme config: $conf"

  OLIKUB_THEME_NAME=""
  OLIKUB_THEME_WALLPAPER_BG=""
  OLIKUB_THEME_WALLPAPER_ACCENT=""
  # shellcheck disable=SC1090
  source "$conf"

  [[ $OLIKUB_THEME_WALLPAPER_BG =~ ^#[0-9a-fA-F]{6}$ ]] ||
    die "Invalid background color in $conf"
  [[ $OLIKUB_THEME_WALLPAPER_ACCENT =~ ^#[0-9a-fA-F]{6}$ ]] ||
    die "Invalid accent color in $conf"
}

resolve_theme() {
  local theme=${1:-}
  if [[ -z $theme ]]; then
    theme=$(cat "$THEME_STATE" 2>/dev/null || true)
  fi
  [[ -n $theme ]] || die 'No Olikub theme is active; pass a theme name.'
  [[ -d "$OLIKUB_PATH/themes/$theme" ]] || die "Unknown Olikub theme: $theme"
  printf '%s\n' "$theme"
}

render_logo() {
  local theme=$1 template="$OLIKUB_PATH/themes/assets/ubuntu-wallpaper.svg.template"
  local destination temporary

  load_theme_conf "$theme"
  [[ -f $template ]] || die "Missing wallpaper template: $template"

  mkdir -p "$BACKGROUND_DIR" || die "Cannot create $BACKGROUND_DIR"
  destination="$BACKGROUND_DIR/olikub-$theme-ubuntu.svg"
  temporary=$(mktemp "$destination.XXXXXX") || die 'Cannot create temporary file'

  if sed -e "s|@BACKGROUND@|$OLIKUB_THEME_WALLPAPER_BG|g" \
    -e "s|@ACCENT@|$OLIKUB_THEME_WALLPAPER_ACCENT|g" \
    "$template" >"$temporary"; then
    mv -f -- "$temporary" "$destination" || die "Cannot write $destination"
  else
    rm -f -- "$temporary"
    die "Cannot render $destination"
  fi

  printf '%s\n' "$destination"
}

build_candidates() {
  local theme=$1 dir="$OLIKUB_PATH/themes/$1/wallpapers" file logo

  logo=$(render_logo "$theme") || exit 1
  CANDIDATES=("$logo")

  [[ -d $dir ]] || return 0
  while IFS= read -r -d '' file; do
    CANDIDATES+=("$file")
  done < <(find "$dir" -maxdepth 1 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o \
    -iname '*.webp' -o -iname '*.svg' \) -print0 | LC_ALL=C sort -z)
}

copy_wallpaper() {
  local source=$1 destination=$2 temporary

  if [[ -L $destination && ! -e $destination ]]; then
    temporary=$(mktemp "${destination}.XXXXXX") || return 1
    if cp "$source" "$temporary" && mv -f -- "$temporary" "$destination"; then
      return 0
    fi
    rm -f -- "$temporary"
    return 1
  fi
  cp "$source" "$destination"
}

apply_wallpaper() {
  local theme=$1 source=$2 destination

  mkdir -p "$STATE_DIR" || die "Cannot create $STATE_DIR"

  if [[ $source == "$BACKGROUND_DIR/olikub-$theme-ubuntu.svg" ]]; then
    destination=$source
  else
    destination="$BACKGROUND_DIR/olikub-$theme-$(basename "$source")"
    copy_wallpaper "$source" "$destination" || die "Cannot copy $source"
  fi

  gsettings set org.gnome.desktop.background picture-uri "$destination" ||
    die 'Cannot set the GNOME background'
  gsettings set org.gnome.desktop.background picture-uri-dark "$destination" ||
    die 'Cannot set the GNOME dark background'
  gsettings set org.gnome.desktop.background picture-options 'zoom' ||
    die 'Cannot set the GNOME background options'

  printf '%s\n' "$theme" >"$THEME_STATE"
  printf 'Wallpaper: %s\n' "$(basename "$destination")"
}

current_index() {
  local index
  index=$(cat "$INDEX_STATE" 2>/dev/null || true)
  [[ $index =~ ^[0-9]+$ ]] || index=0
  printf '%s\n' "$index"
}

step_wallpaper() {
  local direction=$1 theme index total
  theme=$(resolve_theme "${2:-}")
  build_candidates "$theme"
  total=${#CANDIDATES[@]}
  index=$(current_index)
  index=$(((index + direction) % total))
  [[ $index -ge 0 ]] || index=$((index + total))
  apply_wallpaper "$theme" "${CANDIDATES[$index]}"
  printf '%s\n' "$index" >"$INDEX_STATE"
}

apply_default_wallpaper() {
  local theme
  theme=$(resolve_theme "${1:-}")
  build_candidates "$theme"
  apply_wallpaper "$theme" "${CANDIDATES[0]}"
  printf '0\n' >"$INDEX_STATE"
}

generate_wallpaper() {
  local theme=${1:-} theme_dir

  if [[ $theme == all ]]; then
    for theme_dir in "$OLIKUB_PATH"/themes/*/; do
      [[ -f $theme_dir/theme.conf ]] || continue
      render_logo "$(basename "$theme_dir")"
    done
  else
    render_logo "$(resolve_theme "$theme")"
  fi
}

case ${1:-} in
next)
  shift
  step_wallpaper 1 "${1:-}"
  ;;
prev)
  shift
  step_wallpaper -1 "${1:-}"
  ;;
apply)
  shift
  apply_default_wallpaper "${1:-}"
  ;;
generate)
  shift
  generate_wallpaper "${1:-}"
  ;;
help | -h | --help | '')
  usage
  ;;
*)
  die "Unknown wallpaper command: $1"
  ;;
esac