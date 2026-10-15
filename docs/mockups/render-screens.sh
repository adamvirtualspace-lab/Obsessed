#!/usr/bin/env bash
# Renders the HTML mockups to the PNGs in docs/images/ that PLAN.md shows.
# Run from Git Bash in the repo root:  bash docs/mockups/render-screens.sh
#
# Each screenshot is a copy of a mockup plus a small script that, once the cards are dealt,
# switches CSS transitions off (so the picture shows the end state, not a frame mid-animation)
# and clicks the toggles for that state. Needs Chrome or Edge.
set -u
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
OUT="$REPO/docs/images"
FLOW="$REPO/docs/mockups/obsessed-flow.html"
HAND="$REPO/docs/mockups/obsessed-hand.html"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

for c in "/c/Program Files/Google/Chrome/Application/chrome.exe" \
         "/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe" \
         "/c/Program Files/Microsoft/Edge/Application/msedge.exe"; do
  [ -f "$c" ] && BROWSER="$c" && break
done
[ -n "${BROWSER:-}" ] || { echo "Chrome or Edge not found"; exit 1; }
mkdir -p "$OUT"

shot() { # name source width height js-to-run
  local name=$1 src=$2 w=$3 h=$4 js=$5
  {
    cat "$src"
    cat <<HTML

<script>
setTimeout(function () {
  var st = document.createElement('style');
  st.textContent = '*{transition:none !important}.row.flash,.task.flash{animation:none !important}';
  document.head.appendChild(st);
  $js
}, 1500);
</script>
HTML
  } > "$TMP/$name.html"
  "$BROWSER" --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=1 \
    --user-data-dir="$(cygpath -w "$TMP/profile")" --no-first-run \
    --window-size="$w,$h" --virtual-time-budget=9000 \
    --screenshot="$(cygpath -w "$OUT/$name.png")" "file:///$(cygpath -m "$TMP/$name.html")" 2>/dev/null
  echo "docs/images/$name.png"
}

shot flow-overview  "$FLOW" 1920 1080 "document.getElementById('z-fit').click();"
shot flow-before    "$FLOW" 1600 1000 ""
shot flow-after     "$FLOW" 1600 1000 "document.querySelector('.row[data-task=\"a2\"] .check').click(); setTimeout(function(){document.querySelector('.row[data-task=\"f2\"] .check').click();}, 200);"
shot flow-markdown  "$FLOW" 1600 1000 "document.getElementById('v-md').click();"
shot flow-spotlight "$FLOW" 1600 1000 "document.querySelectorAll('.slot')[0].focus();"
shot flow-navy      "$FLOW" 1920 1080 "document.getElementById('p-navy').click(); document.getElementById('z-fit').click();"
shot hand-flat      "$HAND" 1440 960 ""
shot hand-selected  "$HAND" 1440 960 "document.querySelectorAll('.slot')[4].dispatchEvent(new KeyboardEvent('keydown', {key: 'Enter', bubbles: true}));"
shot hand-lowpoly   "$HAND" 1440 960 "document.getElementById('skin-poly').click();"
