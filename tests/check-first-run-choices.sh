#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
mkdir -p "$tmp/bin"

cat > "$tmp/bin/gum" <<'MOCK'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$GUM_LOG"
case " $* " in
  *"Select optional apps"*) ;;
  *"Select programming languages"*) printf '%s\n' "$LANGUAGE_SELECTION" ;;
  *"Select Python versions"*) printf '%s\n' 3.13 ;;
  *"Select databases"*) ;;
  *) exit 3 ;;
esac
MOCK
chmod +x "$tmp/bin/gum"

run_choices() {
  LANGUAGE_SELECTION="$1" GUM_LOG="$tmp/gum.log" XDG_CURRENT_DESKTOP=GNOME \
    PATH="$tmp/bin:/usr/bin:/bin" \
    bash -c 'source "$1"; printf "languages=%s\n" "$OLIKUB_FIRST_RUN_LANGUAGES"; printf "python_versions=%s\n" "${OLIKUB_FIRST_RUN_PYTHON_VERSIONS-}"' \
    bash "$root/install/first-run-choices.sh"
}

: > "$tmp/gum.log"
go_result=$(run_choices Go)
[[ "$go_result" == $'languages=Go\npython_versions=' ]]
! grep -q 'Select Python versions' "$tmp/gum.log"

: > "$tmp/gum.log"
python_result=$(run_choices Python)
[[ "$python_result" == $'languages=Python\npython_versions=3.13' ]]
grep -q 'Select Python versions' "$tmp/gum.log"

echo 'First-run choice checks passed.'
