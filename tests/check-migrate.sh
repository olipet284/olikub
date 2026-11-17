#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/checkout/migrations"
export OLIKUB_PATH="$tmp/checkout" TEST_PULL_LOG="$tmp/pull.log" TEST_BRANCH=main TEST_DIRTY=false TEST_ORIGIN=https://github.com/olipet284/olikub TEST_PULL_FAIL=false TEST_LAST_UPDATED=9999999999 TEST_MIGRATION_LOG="$tmp/migrations.log"
printf 'printf ran >> "$TEST_MIGRATION_LOG"\n' > "$OLIKUB_PATH/migrations/100.sh"

cat > "$tmp/bin/git" <<'MOCK'
#!/usr/bin/env bash
set -euo pipefail
case $1 in
  rev-parse) pwd -P ;;
  symbolic-ref) printf '%s\n' "$TEST_BRANCH" ;;
  config) printf '%s\n' "$TEST_ORIGIN" ;;
  status) if [[ $TEST_DIRTY == true ]]; then printf '%s\n' ' M local-file'; fi ;;
  log) printf '%s\n' "$TEST_LAST_UPDATED" ;;
  pull) printf '%s\n' "$*" >> "$TEST_PULL_LOG"; [[ $TEST_PULL_FAIL != true ]] ;;
  *) exit 20 ;;
esac
MOCK
chmod +x "$tmp/bin/git"
export PATH="$tmp/bin:/usr/bin:/bin"

bash "$root/bin/olikub-sub/migrate.sh" >/dev/null
[[ $(<"$TEST_PULL_LOG") == 'pull --ff-only origin main' ]]
[[ ! -e $TEST_MIGRATION_LOG ]]

TEST_PULL_FAIL=true TEST_LAST_UPDATED=0
if bash "$root/bin/olikub-sub/migrate.sh" >/dev/null 2>&1; then
  printf 'failed update was accepted\n' >&2
  exit 1
fi
[[ ! -e $TEST_MIGRATION_LOG ]]

for invalid in branch dirty origin; do
  : > "$TEST_PULL_LOG"
  TEST_BRANCH=main TEST_DIRTY=false TEST_ORIGIN=https://github.com/olipet284/olikub TEST_PULL_FAIL=false TEST_LAST_UPDATED=9999999999
  case $invalid in
    branch) TEST_BRANCH=feature ;;
    dirty) TEST_DIRTY=true ;;
    origin) TEST_ORIGIN=https://example.com/not-olikub.git ;;
  esac
  if bash "$root/bin/olikub-sub/migrate.sh" >/dev/null 2>&1; then
    printf 'unsafe %s checkout was accepted\n' "$invalid" >&2
    exit 1
  fi
  [[ ! -s $TEST_PULL_LOG ]]
done

echo 'Migration checks passed.'
