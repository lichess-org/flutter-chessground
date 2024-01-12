#!/bin/bash

# This script converts all SVGs in the lila/public/piece folder to PNGs in the output folder using Inkscape.
# Script taken from @tiagoamaro's PR: https://github.com/lichess-org/flutter-chessground/pull/28

SOURCE_DIR="./lila/public/piece"
DEST_DIR="./output"
SCALING_FACTORS=("1 ." "2 ./2.0x" "3 ./3.0x" "4 ./4.0x")

for dname in $(ls -d $SOURCE_DIR/*); do
    if [ -d "$dname" ]; then
        for factor_folder in "${SCALING_FACTORS[@]}"; do
            read -r -a factor_folder_array <<< "$factor_folder"
            factor=${factor_folder_array[0]}
            folder=${factor_folder_array[1]}
            for fname in $(ls $dname); do
                fpath="$dname/$fname"
                if [ -f "$fpath" ]; then
                    out_folder="$DEST_DIR/${dname##*/}/$folder"
                    echo $out_folder
                    mkdir -p $out_folder
                    fname_without_extension="${fname%.*}"
                    png="$out_folder/$fname_without_extension.png"
                    echo "Converting $fpath to $png"
                    size=$((128 * factor))
                    inkscape --export-type="png" --export-width="$size" --export-height="$size" --export-filename="$png" $fpath &
                fi
            done
        done
    fi
done
