#!/usr/bin/env bash
# Regression test: reload.sh must not select app-bundle PATH entries for shims.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
ORIGINAL_PATH="$PATH"
TOOL_PATH="/usr/bin:/bin:/usr/sbin:/sbin"

cleanup() {
  PATH="$ORIGINAL_PATH"
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

HELPERS="$TMP_DIR/reload-helpers.sh"
sed '/^write_last_socket_path()/,$d' "$ROOT_DIR/scripts/reload.sh" > "$HELPERS"

FAKE_HOME="$TMP_DIR/home"
APP_BIN="$TMP_DIR/Sublime Text.app/Contents/SharedSupport/bin"
NORMAL_BIN="$TMP_DIR/bin"
APP_CLI_DIR="/Applications/cmux.app/Contents/Resources/bin"

mkdir -p "$FAKE_HOME" "$APP_BIN" "$NORMAL_BIN"

HOME="$FAKE_HOME"
PATH="$APP_BIN:$NORMAL_BIN:$APP_CLI_DIR:$TOOL_PATH"
source "$HELPERS"

target="$(select_cmux_shim_target)"
PATH="$ORIGINAL_PATH"
expected="$NORMAL_BIN/cmux"
if [[ "$target" != "$expected" ]]; then
  echo "FAIL: expected shim target $expected, got $target"
  exit 1
fi

echo "PASS: reload.sh skips app-bundle shim targets"
