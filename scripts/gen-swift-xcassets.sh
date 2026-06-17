#!/usr/bin/env bash
# gen-swift-xcassets.sh
#
# Generates the Xcode asset catalog used by the ChessgroundAssets Swift package
# from the canonical Flutter assets that live in this repo.
#
# Run this script whenever board textures or piece sets are added, removed, or
# updated, then commit the resulting changes in
#   swift/Sources/ChessgroundAssets/Assets.xcassets/
#
#   ./scripts/gen-swift-xcassets.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BOARDS_SRC="$REPO_ROOT/assets/boards"
PIECES_SRC="$REPO_ROOT/assets/piece_sets"
CATALOG="$REPO_ROOT/swift/Sources/ChessgroundAssets/Assets.xcassets"

# ---------------------------------------------------------------------------
# 1. Wipe existing board_ and piece_ imagesets so removed assets don't linger
# ---------------------------------------------------------------------------

find "$CATALOG" -maxdepth 1 -type d \( -name "board_*.imageset" -o -name "piece_*.imageset" \) \
    -exec rm -rf {} + 2>/dev/null || true

# ---------------------------------------------------------------------------
# 2. Board textures
#
# Each entry is "<asset-name> <source-filename>" where the asset-name matches
# the ChessboardColorScheme Dart constant (used as Image("board_<name>") in Swift).
# ---------------------------------------------------------------------------

# "<asset name> <source file>"
BOARD_ENTRIES=(
    "blue2        blue2.jpg"
    "blue3        blue3.jpg"
    "blueMarble   blue-marble.jpg"
    "canvas       canvas2.jpg"
    "greenPlastic green-plastic.webp"
    "grey         grey.jpg"
    "horsey       horsey.jpg"
    "leather      leather.jpg"
    "maple        maple.jpg"
    "maple2       maple2.jpg"
    "marble       marble.jpg"
    "metal        metal.jpg"
    "newspaper    newspaper.webp"
    "olive        olive.jpg"
    "pinkPyramid  pink-pyramid.webp"
    "purple       purple.webp"
    "purpleDiag   purple-diag.webp"
    "wood         wood.jpg"
    "wood2        wood2.jpg"
    "wood3        wood3.jpg"
    "wood4        wood4.jpg"
)

board_count=0
for entry in "${BOARD_ENTRIES[@]}"; do
    name=$(echo "$entry" | awk '{print $1}')
    src_file=$(echo "$entry" | awk '{print $2}')
    ext="${src_file##*.}"
    dest="$CATALOG/board_${name}.imageset"
    mkdir -p "$dest"
    cp "$BOARDS_SRC/$src_file" "$dest/board.$ext"
    cat > "$dest/Contents.json" <<EOF
{
  "images" : [
    { "filename" : "board.$ext", "idiom" : "universal", "scale" : "1x" },
    { "idiom" : "universal", "scale" : "2x" },
    { "idiom" : "universal", "scale" : "3x" }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
EOF
    board_count=$((board_count + 1))
done

echo "  boards: $board_count imagesets written"

# ---------------------------------------------------------------------------
# 3. Piece images (1x / 2x / 3x)
#
# Each piece-set directory follows Flutter's scale convention:
#   <piece>.png       — 1x
#   2.0x/<piece>.png  — 2x
#   3.0x/<piece>.png  — 3x
#
# Sets whose root directory does not contain the standard bB.png layout
# (e.g. "mono") are skipped.
# ---------------------------------------------------------------------------

PIECES=(bB bK bN bP bQ bR wB wK wN wP wQ wR)

# Converts kebab-case to camelCase (e.g. "kiwen-suwi" → "kiwenSuwi") so asset
# names match the Dart PieceSet enum .name values used by the Flutter app.
to_camel_case() {
    echo "$1" | awk -F'-' '{
        r = $1
        for (i = 2; i <= NF; i++) r = r toupper(substr($i, 1, 1)) substr($i, 2)
        print r
    }'
}

set_count=0
for set_dir in "$PIECES_SRC"/*/; do
    set_name=$(basename "$set_dir")
    asset_name=$(to_camel_case "$set_name")

    if [[ ! -f "$set_dir/bB.png" ]]; then
        echo "  skipping '$set_name' (non-standard layout)"
        continue
    fi

    for piece in "${PIECES[@]}"; do
        dest="$CATALOG/piece_${asset_name}_${piece}.imageset"
        mkdir -p "$dest"
        cp "$set_dir/${piece}.png"       "$dest/${piece}.png"
        cp "$set_dir/2.0x/${piece}.png"  "$dest/${piece}@2x.png"
        cp "$set_dir/3.0x/${piece}.png"  "$dest/${piece}@3x.png"
        cat > "$dest/Contents.json" <<EOF
{
  "images" : [
    { "filename" : "${piece}.png",    "idiom" : "universal", "scale" : "1x" },
    { "filename" : "${piece}@2x.png", "idiom" : "universal", "scale" : "2x" },
    { "filename" : "${piece}@3x.png", "idiom" : "universal", "scale" : "3x" }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
EOF
    done
    set_count=$((set_count + 1))
done

echo "  pieces: $set_count sets × ${#PIECES[@]} pieces = $(( set_count * ${#PIECES[@]} )) imagesets written"
echo "Done. Commit the changes in swift/Sources/ChessgroundAssets/Assets.xcassets/"
