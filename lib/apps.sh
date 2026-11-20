#!/bin/bash

# Shared helpers for the Olikub app catalog.
#
# Catalog layout is fixed at three levels:
#
#   apps/<kind>/<topic>/<app>.sh
#
# kind is how the app is used (cli, tui, gui), topic is what it is used for
# (coding-harness, browser, multiplexer, ...). Each app file defines
# APP_NAME, APP_DESCRIPTION, APP_DEFAULT, and the functions app_installed,
# app_install, and app_uninstall. app_installed is optional and falls back to
# looking for APP_BIN (or the file name) on PATH.
#
# App files are always sourced in a subshell so they can all use the same
# function names.

APPS_DIR="${OLIKUB_PATH}/apps"
APP_KINDS=(cli tui gui)

has_command() {
  command -v "$1" >/dev/null 2>&1
}

mise_manages_command() {
  has_command mise || return 1
  local resolved
  resolved="$(mise which "$1" 2>/dev/null)" || return 1
  [[ "$resolved" == */installs/* ]]
}

DPKG_INSTALLED_PACKAGES=

dpkg_load_installed_packages() {
  [[ -n "$DPKG_INSTALLED_PACKAGES" ]] && return 0
  DPKG_INSTALLED_PACKAGES=" $(dpkg-query -W -f='${db:Status-Status} ${Package}\n' 2>/dev/null |
    awk '$1 == "installed" { printf "%s ", $2 }') "
  export DPKG_INSTALLED_PACKAGES
}

dpkg_installed() {
  dpkg_load_installed_packages
  [[ "$DPKG_INSTALLED_PACKAGES" == *" $1 "* ]]
}

flatpak_installed() {
  has_command flatpak || return 1
  flatpak list --app --columns=application 2>/dev/null | grep -Fxq "$1"
}

snap_installed() {
  has_command snap || return 1
  snap list "$1" >/dev/null 2>&1
}

desktop_file_exists() {
  [[ -f "/usr/share/applications/$1" || -f "${XDG_DATA_HOME:-$HOME/.local/share}/applications/$1" ]]
}

apt_remove() {
  local label="$1"
  shift
  local packages=() package
  for package in "$@"; do
    dpkg_installed "$package" && packages+=("$package")
  done

  if ((${#packages[@]})); then
    sudo apt-get remove -y "${packages[@]}"
  else
    echo "$label is installed outside a supported APT package; leaving it in place."
  fi
}

remove_local_binary() {
  local label="$1" path="$2"
  if [[ -f "$path" || -L "$path" ]]; then
    sudo rm -f -- "$path"
  else
    echo "$label is installed outside $path; leaving it in place."
  fi
}

remove_user_binary() {
  local label="$1" path="$2"
  if [[ -f "$path" || -L "$path" ]]; then
    rm -f -- "$path"
  else
    echo "$label is not linked at $path; leaving it in place."
  fi
}

# Managed location for apps that are installed from a Git checkout. User data
# such as git-user profiles lives here, beside the checkout, and is preserved
# by uninstall.
olikub_apps_data_dir() {
  printf '%s\n' "${XDG_DATA_HOME:-$HOME/.local/share}/olikub/apps"
}

# Clone (or fast-forward) a managed app checkout and print its path. The caller
# decides what to run inside it.
olikub_app_clone() {
  local id="$1" url="$2" dir
  dir="$(olikub_apps_data_dir)/$id"
  if [[ -d "$dir/.git" ]]; then
    git -C "$dir" pull --ff-only >&2 || return 1
  else
    mkdir -p "$(dirname "$dir")" || return 1
    git clone "$url" "$dir" >&2 || return 1
  fi
  printf '%s\n' "$dir"
}

app_files() {
  local kind
  for kind in "${APP_KINDS[@]}"; do
    [[ -d "$APPS_DIR/$kind" ]] || continue
    find "$APPS_DIR/$kind" -mindepth 2 -maxdepth 2 -name '*.sh' -print | sort
  done
}

app_path_parts() {
  local file="$1"
  APP_ID="$(basename "$file" .sh)"
  APP_TOPIC="$(basename "$(dirname "$file")")"
  APP_KIND="$(basename "$(dirname "$(dirname "$file")")")"
}

app_meta() {
  local file="$1"
  (
    APP_NAME=""
    APP_DESCRIPTION=""
    APP_DEFAULT=0
    APP_BIN=""
    # shellcheck disable=SC1090
    source "$file"

    if declare -F app_installed >/dev/null; then
      if app_installed; then installed=1; else installed=0; fi
    else
      if has_command "${APP_BIN:-$(basename "$file" .sh)}"; then installed=1; else installed=0; fi
    fi

    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
      "$(basename "$file" .sh)" \
      "$(basename "$(dirname "$(dirname "$file")")")" \
      "$(basename "$(dirname "$file")")" \
      "$APP_NAME" \
      "$APP_DESCRIPTION" \
      "$APP_DEFAULT" \
      "$installed"
  )
}

app_is_installed() {
  local file="$1"
  (
    APP_BIN=""
    # shellcheck disable=SC1090
    source "$file"
    if declare -F app_installed >/dev/null; then
      app_installed
    else
      has_command "${APP_BIN:-$(basename "$file" .sh)}"
    fi
  )
}

app_run() {
  local file="$1" action="$2"
  (
    # shellcheck disable=SC1090
    source "$file"
    "app_${action}"
  )
}

app_find() {
  local wanted="$1" file
  while IFS= read -r file; do
    if [[ "$(basename "$file" .sh)" == "$wanted" ]]; then
      printf '%s\n' "$file"
      return 0
    fi
  done < <(app_files)
  return 1
}

app_kind_label() {
  case "$1" in
    cli) printf '%s' CLI ;;
    tui) printf '%s' TUI ;;
    gui) printf '%s' GUI ;;
    *) printf '%s' "$1" ;;
  esac
}

app_topic_label() {
  local topic="${1//-/ }"
  case "$topic" in
    ai) printf '%s' AI ;;
    *) printf '%s' "${topic^}" ;;
  esac
}

app_group_label() {
  local key="$1" kind="${1%%/*}" topic="${1#*/}"
  printf '%s / %s' "$(app_kind_label "$kind")" "$(app_topic_label "$topic")"
}

# Print the paths of catalog apps that belong in the given menu mode.
# install   -> apps that are not installed yet
# uninstall -> apps that are currently installed
apps_candidates() {
  local mode="$1" file installed
  dpkg_load_installed_packages
  while IFS= read -r file; do
    installed="$(app_meta "$file" | cut -f7)"
    case "$mode" in
      install) [[ "$installed" == 0 ]] && printf '%s\n' "$file" ;;
      uninstall) [[ "$installed" == 1 ]] && printf '%s\n' "$file" ;;
      *) return 2 ;;
    esac || true
  done < <(app_files)
  return 0
}

apps_files_in_group() {
  local mode="$1" group="$2" file kind topic
  while IFS= read -r file; do
    app_path_parts "$file"
    kind="$APP_KIND"
    topic="$APP_TOPIC"
    if [[ "$kind/$topic" == "$group" ]]; then
      printf '%s\n' "$file"
    fi
  done < <(apps_candidates "$mode")
  return 0
}

# Print the kinds (cli, tui, gui) that have candidates in the given mode, in
# catalog order. Emits kind, label, count.
apps_kinds() {
  local mode="$1" file kind
  local -A seen=() count=()
  local -a order=()

  while IFS= read -r file; do
    app_path_parts "$file"
    kind="$APP_KIND"
    [[ -n "${seen[$kind]:-}" ]] || order+=("$kind")
    seen["$kind"]=1
    count["$kind"]=$(( ${count[$kind]:-0} + 1 ))
  done < <(apps_candidates "$mode")

  for kind in "${order[@]}"; do
    printf '%s\t%s\t%s\n' "$kind" "$(app_kind_label "$kind")" "${count[$kind]}"
  done
}

# Print the categories (kind/topic) available within the requested kinds.
# Emits kind/topic, label, count. The label carries the kind prefix only when
# several kinds are requested, so same-named topics stay distinguishable.
apps_categories() {
  local mode="$1"
  shift
  local -a kinds=("$@")
  local multi=0
  ((${#kinds[@]} > 1)) && multi=1

  local file kind topic key want label k
  local -A seen=() count=()
  local -a order=()

  while IFS= read -r file; do
    app_path_parts "$file"
    kind="$APP_KIND"
    topic="$APP_TOPIC"
    want=0
    for k in "${kinds[@]}"; do
      [[ "$k" == "$kind" ]] && want=1
    done
    ((want)) || continue
    key="$kind/$topic"
    [[ -n "${seen[$key]:-}" ]] || order+=("$key")
    seen["$key"]=1
    count["$key"]=$(( ${count[$key]:-0} + 1 ))
  done < <(apps_candidates "$mode")

  for key in "${order[@]}"; do
    kind="${key%%/*}"
    topic="${key#*/}"
    if ((multi)); then
      label="$(app_kind_label "$kind") / $(app_topic_label "$topic")"
    else
      label="$(app_topic_label "$topic")"
    fi
    printf '%s\t%s\t%s\n' "$key" "$label" "${count[$key]}"
  done
}

apps_apply() {
  local mode="$1"
  shift
  dpkg_load_installed_packages
  local file meta id name gerund verb
  local -a chosen=() labels=()

  for file in "$@"; do
    meta="$(app_meta "$file")"
    IFS=$'\t' read -r id _ _ name _ _ _ <<<"$meta"
    chosen+=("$file")
    labels+=("$name")
  done
  ((${#chosen[@]})) || return 0

  case "$mode" in
    install) verb=Install gerund=Installing ;;
    uninstall) verb=Uninstall gerund=Uninstalling ;;
    *) return 2 ;;
  esac

  if [[ "${OLIKUB_APPS_ASSUME_YES:-0}" != 1 ]]; then
    if ! gum confirm "$verb these apps? $(IFS=', '; printf '%s' "${labels[*]}")"; then
      gum style --foreground 214 "$verb cancelled."
      return 0
    fi
  fi

  for file in "${chosen[@]}"; do
    meta="$(app_meta "$file")"
    IFS=$'\t' read -r id _ _ name _ _ _ <<<"$meta"
    echo "$gerund $name..."
    if ! app_run "$file" "$mode"; then
      echo "error: failed to $mode $name" >&2
      return 1
    fi
    # Package state changed; refresh detection for the next app.
    DPKG_INSTALLED_PACKAGES=
    if [[ "$mode" == install ]] && ! app_is_installed "$file"; then
      echo "warning: $name is still not detected after install." >&2
    elif [[ "$mode" == uninstall ]] && app_is_installed "$file"; then
      echo "warning: $name is still detected after uninstall; an unsupported or shared install may remain." >&2
    fi
  done
}

# Let the user choose apps from one category and print the chosen file paths.
# Returns 1 when the chooser is cancelled, so callers can step back.
apps_choose_in_group() {
  local mode="$1" group="$2" file meta id name description display prefix line
  local -a displays=()
  local -A display_file=()

  while IFS= read -r file; do
    meta="$(app_meta "$file")"
    IFS=$'\t' read -r id _ _ name description _ _ <<<"$meta"
    display="$name"
    [[ -n "${display_file[$display]:-}" ]] && display="$name ($id)"
    display_file["$display"]="$file"
    if [[ -n "$description" ]]; then
      displays+=("$display — $description")
    else
      displays+=("$display")
    fi
  done < <(apps_files_in_group "$mode" "$group")

  ((${#displays[@]})) || return 0

  local height=${#displays[@]}
  ((height < 4)) && height=4
  ((height > 20)) && height=20

  local output
  if ! output="$(gum choose --no-limit --height "$height" \
    --header "Select $(app_group_label "$group") apps to $mode" "${displays[@]}")"; then
    return 1
  fi
  [[ -z "$output" ]] && return 0

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    # Displays may carry a description after the em dash; match the app part.
    if [[ -n "${display_file[$line]:-}" ]]; then
      printf '%s\n' "${display_file[$line]}"
      continue
    fi
    prefix="${line%% — *}"
    [[ -n "${display_file[$prefix]:-}" ]] && printf '%s\n' "${display_file[$prefix]}"
  done <<<"$output"
}

apps_recipes() {
  local mode="$1" choice i
  local -a labels=() paths=()

  if [[ "$mode" == install ]]; then
    labels=("Dev language" "Dev database" "Web apps" "Windows VM" "<< Back")
    paths=(
      "install/terminal/select-dev-language.sh"
      "install/terminal/select-dev-storage.sh"
      "install/desktop/optional/select-web-apps.sh"
      "install/desktop/optional/app-windows.sh"
    )
  else
    labels=("Dev language" "Docker" "UV" "Python venv CLI" "Web apps" "<< Back")
    paths=(
      "uninstall/dev-language.sh"
      "uninstall/docker.sh"
      "uninstall/uv.sh"
      "uninstall/venv-cli.sh"
      "uninstall/select-web-apps.sh"
    )
  fi

  if ! choice="$(gum choose "${labels[@]}" --height 8 --header "Olikub recipes")"; then
    return 1
  fi
  [[ -z "$choice" || "$choice" == "<< Back" ]] && return 0

  for i in "${!labels[@]}"; do
    if [[ "${labels[i]}" == "$choice" ]]; then
      # shellcheck disable=SC1090
      source "$OLIKUB_PATH/${paths[i]}"
      return 0
    fi
  done
}

apps_menu() {
  local mode="$1" choice line
  local -a kinds=() groups=() files=() kind_menu=() cat_menu=()
  local -A kind_key=() group_key=()

  while true; do
    # Types step: pick one or more of cli/tui/gui, or jump to recipes.
    kinds=()
    kind_menu=()
    kind_key=()
    while IFS=$'\t' read -r key label count; do
      kind_menu+=("$label ($count)")
      kind_key["$label ($count)"]="$key"
    done < <(apps_kinds "$mode")

    if ((${#kind_menu[@]} == 0)); then
      gum style --foreground 214 "No apps are available to $mode right now."
      return 0
    fi

    if ! choice="$(gum choose --no-limit "${kind_menu[@]}" "Recipes…" "<< Back" \
      --height 15 --header "Select app types to $mode")"; then
      return 0
    fi
    [[ -z "$choice" ]] && return 0

    local saw_back=0 saw_recipes=0
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      case "$line" in
        "<< Back") saw_back=1 ;;
        "Recipes…") saw_recipes=1 ;;
        *) [[ -n "${kind_key[$line]:-}" ]] && kinds+=("${kind_key[$line]}") ;;
      esac
    done <<<"$choice"

    ((saw_back)) && return 0
    if ((saw_recipes)); then
      # Recipes run their own interactive flows, so treat them as a leaf.
      apps_recipes "$mode"
      return 0
    fi
    ((${#kinds[@]})) || continue

    # Categories step: pick one or more categories within the chosen types.
    while true; do
      groups=()
      cat_menu=()
      group_key=()
      while IFS=$'\t' read -r key label count; do
        cat_menu+=("$label ($count)")
        group_key["$label ($count)"]="$key"
      done < <(apps_categories "$mode" "${kinds[@]}")

      if ! choice="$(gum choose --no-limit "${cat_menu[@]}" "<< Back" \
        --height 15 --header "Select categories to $mode")"; then
        break
      fi
      [[ -z "$choice" ]] && break

      saw_back=0
      while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        if [[ "$line" == "<< Back" ]]; then
          saw_back=1
        else
          [[ -n "${group_key[$line]:-}" ]] && groups+=("${group_key[$line]}")
        fi
      done <<<"$choice"
      ((saw_back)) && break
      ((${#groups[@]})) || continue

      # Apps step: choose apps in every chosen category, then confirm once for
      # the whole batch.
      files=()
      local group output cancelled=0
      for group in "${groups[@]}"; do
        if ! output="$(apps_choose_in_group "$mode" "$group")"; then
          cancelled=1
          break
        fi
        while IFS= read -r line; do
          [[ -n "$line" ]] && files+=("$line")
        done <<<"$output"
      done
      ((cancelled)) && continue
      ((${#files[@]})) || continue

      apps_apply "$mode" "${files[@]}"
      return 0
    done
  done
}

olikub_apps_install_defaults() {
  local file meta id kind name default installed
  local kinds="${OLIKUB_APP_KINDS:-cli tui gui}"
  local -a pending=()
  dpkg_load_installed_packages

  while IFS= read -r file; do
    meta="$(app_meta "$file")"
    IFS=$'\t' read -r id kind _ name _ default installed <<<"$meta"
    [[ " $kinds " == *" $kind "* ]] || continue
    [[ "$default" == 1 && "$installed" == 0 ]] && pending+=("$file")
  done < <(app_files)

  ((${#pending[@]})) || return 0

  for file in "${pending[@]}"; do
    meta="$(app_meta "$file")"
    IFS=$'\t' read -r id _ _ name _ _ _ <<<"$meta"
    echo "Installing $name..."
    app_run "$file" install
    DPKG_INSTALLED_PACKAGES=
  done
}

olikub_apps_status() {
  local file meta id kind topic name default installed
  dpkg_load_installed_packages
  printf '%-10s %-20s %-28s %s\n' KIND TOPIC APP STATUS
  while IFS= read -r file; do
    meta="$(app_meta "$file")"
    IFS=$'\t' read -r id kind topic name _ default installed <<<"$meta"
    [[ "$installed" == 1 ]] && installed=installed || installed=missing
    printf '%-10s %-20s %-28s %s\n' "$(app_kind_label "$kind")" "$(app_topic_label "$topic")" "$id" "$installed"
  done < <(app_files)
}
