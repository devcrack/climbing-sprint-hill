#!/usr/bin/env bash
set -euo pipefail

# Run Maven Wrapper using the same JDK as IntelliJ IDEA (JetBrains Runtime) if available.
# Works on macOS/Linux. On macOS, it auto-detects common IntelliJ Ultimate/CE and Toolbox install paths.
# Falls back to the system's Java 17 via /usr/libexec/java_home.
# Usage: scripts/mvnw-ide.sh clean test

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="${SCRIPT_DIR%/scripts}"

find_idea_jbr_mac() {
  local candidates=(
    "/Applications/IntelliJ IDEA.app/Contents/jbr/Contents/Home"
    "/Applications/IntelliJ IDEA CE.app/Contents/jbr/Contents/Home"
  )

  # JetBrains Toolbox common locations (Ultimate and CE). We try both channel patterns.
  local toolbox_root="$HOME/Library/Application Support/JetBrains/Toolbox/apps"
  if [[ -d "$toolbox_root" ]]; then
    while IFS= read -r -d '' jbr; do
      candidates+=("$jbr")
    done < <(find "$toolbox_root" -type d \( -name "IntelliJ IDEA.app" -o -name "IntelliJ IDEA CE.app" \) -path "*/Contents/jbr/Contents/Home" -print0 2>/dev/null || true)
  fi

  for c in "${candidates[@]}"; do
    if [[ -x "$c/bin/java" ]]; then
      echo "$c"
      return 0
    fi
  done
  return 1
}

find_java17_mac() {
  if command -v /usr/libexec/java_home >/dev/null 2>&1; then
    /usr/libexec/java_home -v 17 2>/dev/null || true
  fi
}

find_idea_jbr_linux() {
  # Try common JetBrains Toolbox locations on Linux
  local candidates=()
  local toolbox_root="$HOME/.local/share/JetBrains/Toolbox/apps"
  if [[ -d "$toolbox_root" ]]; then
    while IFS= read -r -d '' jbr; do
      candidates+=("$jbr")
    done < <(find "$toolbox_root" -type d -path "*/jbr" -print0 2>/dev/null || true)
  fi
  for c in "${candidates[@]}"; do
    if [[ -x "$c/bin/java" ]]; then
      echo "$c"
      return 0
    fi
  done
  return 1
}

resolve_java_home() {
  local os
  os="$(uname -s)"
  case "$os" in
    Darwin)
      local jbr
      jbr="$(find_idea_jbr_mac || true)"
      if [[ -n "${jbr:-}" ]]; then
        echo "$jbr"
        return 0
      fi
      local j17
      j17="$(find_java17_mac || true)"
      if [[ -n "${j17:-}" ]]; then
        echo "$j17"
        return 0
      fi
      ;;
    Linux)
      local jbr
      jbr="$(find_idea_jbr_linux || true)"
      if [[ -n "${jbr:-}" ]]; then
        echo "$jbr"
        return 0
      fi
      ;;
  esac

  # Fallback: if JAVA_HOME is already set and has java, keep it; otherwise try java on PATH
  if [[ -n "${JAVA_HOME:-}" && -x "$JAVA_HOME/bin/java" ]]; then
    echo "$JAVA_HOME"
    return 0
  fi
  if command -v java >/dev/null 2>&1; then
    # Derive JAVA_HOME from java binary path heuristically
    local java_bin
    java_bin="$(command -v java)"
    # Resolve symlinks, then go up two levels to reach JAVA_HOME
    local real
    real="$(readlink -f "$java_bin" 2>/dev/null || /usr/bin/python3 - <<'PY'
import os,sys
p=sys.argv[1]
while os.path.islink(p):
  p=os.path.join(os.path.dirname(p), os.readlink(p))
print(os.path.realpath(p))
PY
"$java_bin")"
    echo "$(cd "${real%/*/*}" && pwd)"
    return 0
  fi
  return 1
}

main() {
  if [[ ! -x "$REPO_ROOT/mvnw" ]]; then
    echo "[ERROR] Maven Wrapper (mvnw) not found at $REPO_ROOT/mvnw" >&2
    exit 1
  }

  local jhome
  if ! jhome="$(resolve_java_home)" || [[ -z "$jhome" ]]; then
    echo "[ERROR] No Java Runtime found. Install JDK 17 or run from IntelliJ.\n" \
         "- En macOS, puedes instalar con: brew install --cask temurin17" >&2
    exit 1
  fi

  export JAVA_HOME="$jhome"
  export PATH="$JAVA_HOME/bin:$PATH"

  echo "[INFO] Using JAVA_HOME=$JAVA_HOME"
  exec "$REPO_ROOT/mvnw" "$@"
}

main "$@"
