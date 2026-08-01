#!/usr/bin/env bash
set -euo pipefail

# cd to the directory this script lives in
cd "$(dirname "$0")"

slugfont_exe="slugfont.exe"

# Check for wine
if ! command -v wine &>/dev/null; then
    echo "Error: wine is not installed or not on your PATH."
    echo ""
    echo "Install Wine for your distribution:"
    echo "  Ubuntu/Debian:  sudo apt install wine"
    echo "  Fedora:         sudo dnf install wine"
    echo "  Arch:           sudo pacman -S wine"
    echo ""
    echo "If you use Steam/Proton, you can symlink Proton's wine binary:"
    echo "  ln -s ~/.steam/steam/compatibilitytools.d/GE-ProtonX-XX/files/bin/wine ~/.local/bin/wine"
    exit 1
fi

# Check for slugfont.exe
if [[ ! -f "$slugfont_exe" ]]; then
    echo "Error: $slugfont_exe not found in $(pwd)"
    echo ""
    echo "You can find $slugfont_exe in your ESO installation."
    echo ""
    echo "Common locations (inside your Wine/Proton prefix):"
    echo "  ~/.steam/steam/steamapps/common/Zenimax Online/The Elder Scrolls Online/game/client/$slugfont_exe"
    echo ""
    echo "Lutris users: check the Wine prefix under ~/.local/share/lutris/runners/wine/"
    echo "or your game's own prefix."
    echo ""
    echo "Copy $slugfont_exe into this directory ($(pwd)) and re-run this script."
    exit 1
fi

# Check for ttf files
shopt -s nullglob
ttf_files=(ttfs/*.ttf)
shopt -u nullglob

if [[ ${#ttf_files[@]} -eq 0 ]]; then
    echo "No .ttf files found in ttfs/"
    echo "Place your font files in $(pwd)/ttfs/ and re-run this script."
    exit 1
fi

echo "Found ${#ttf_files[@]} font(s) to convert."

# Convert ttf files to slug files
mkdir -p slugs

failed=0
for ttf in "${ttf_files[@]}"; do
    name="$(basename "${ttf%.ttf}")"
    echo "Generating ${name}.slug"
    if ! wine "$slugfont_exe" "$ttf" -o "slugs/${name}.slug" 2>/dev/null; then
        echo "  Warning: failed to convert $ttf"
        ((++failed))
    fi
done

echo ""
if [[ $failed -gt 0 ]]; then
    echo "$failed font(s) failed to convert."
else
    echo "Fonts have been converted to slugs!"
fi

# Generate CustomFontOptions.lua
output_file="../CustomFontOptions.lua"

shopt -s nullglob
slug_files=(slugs/*.slug)
shopt -u nullglob

if [[ ${#slug_files[@]} -eq 0 ]]; then
    echo "No .slug files found in slugs/ — skipping CustomFontOptions.lua generation."
    exit 0
fi

{
    echo "-- DON'T EDIT THIS FILE DIRECTLY --"
    echo "-- technically you can, but you should really place your"
    echo "-- font files in the fonts/ttfs directory and re-run fonts/slug.bat (Windows)"
    echo "-- or fonts/slug.sh (Linux)"
    echo "local FC = FontChanger or {}"
    echo "FC.CUSTOM_FONT_CHOICES = {"

    for slug in "${slug_files[@]}"; do
        name="$(basename "${slug%.slug}")"
        printf '\t"%s",\n' "$name"
    done

    echo "}"
    echo "FC.CUSTOM_FONT_VALUES = {"

    for slug in "${slug_files[@]}"; do
        name="$(basename "${slug%.slug}")"
        printf '\t"FontChanger/fonts/slugs/%s.slug",\n' "$name"
    done

    echo "}"
} > "$output_file"

echo "Updated $output_file."
