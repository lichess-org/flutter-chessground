#!/usr/bin/env bash
# Convert the Lichess-approved Şahî Ivory Brown SVGs to Flutter/Swift WebP assets.
# Source: https://github.com/lichess-org/lila/tree/master/public/piece/shahi-ivory-brown
# Original desktop contribution: https://github.com/lichess-org/lila/pull/18836
# Copyright Tamer Karatekin. See assets/piece_sets/shahi-ivory-brown/LICENSE.txt.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$ROOT/assets/piece_sets/shahi-ivory-brown"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Pin to a reviewed upstream revision rather than silently following master.
LILA_COMMIT="bd6d1987c21e35570af5fcdc9d512cec08e6a34f"
SOURCE_URL="https://raw.githubusercontent.com/lichess-org/lila/${LILA_COMMIT}/public/piece/shahi-ivory-brown"

for program in curl inkscape cwebp; do
  command -v "$program" >/dev/null || { echo "Missing dependency: $program" >&2; exit 1; }
done

for piece in bB bK bN bP bQ bR wB wK wN wP wQ wR; do
  echo "Preparing Şahî $piece"
  curl --fail --location --silent --show-error \
    "$SOURCE_URL/$piece.svg" -o "$TMP/$piece.svg"
  for factor in 1 2 3; do
    size=$((128 * factor))
    if (( factor == 1 )); then
      folder="$DEST"
    else
      folder="$DEST/${factor}.0x"
    fi
    mkdir -p "$folder"
    inkscape "$TMP/$piece.svg" --export-type=png \
      --export-width="$size" --export-height="$size" \
      --export-filename="$TMP/${piece}-${factor}.png" >/dev/null
    cwebp -quiet -lossless -z 9 "$TMP/${piece}-${factor}.png" \
      -o "$folder/$piece.webp"
  done
done

# Keep the native Swift package's Xcode asset catalog in sync with Flutter.
"$ROOT/scripts/gen-swift-xcassets.sh"
echo "Şahî assets generated for Flutter (1x/2x/3x) and Swift."
