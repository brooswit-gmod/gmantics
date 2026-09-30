#!/usr/bin/env bash
# Conservative textual guard; comments and strings count too.
set -euo pipefail
pattern=$(paste -sd '|' test/gmod-globals.txt)
if grep -REn "\b(${pattern})\b" lua/gmantics/core/; then
  echo 'GMod-only name found in portable core' >&2
  exit 1
else
  status=$?
  if [ "$status" -ne 1 ]; then exit "$status"; fi
fi
