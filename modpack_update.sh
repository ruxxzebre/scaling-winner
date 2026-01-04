#!/bin/sh
set -eu

ZIP_URL_DEFAULT="https://github.com/ruxxzebre/scaling-winner/archive/refs/heads/main.zip"
ZIP_URL="${1:-$ZIP_URL_DEFAULT}"

if [ -f "$0" ]; then
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
else
    SCRIPT_DIR="$(pwd)"
fi

DESTINATION="${2:-$SCRIPT_DIR}"

if [ ! -d "$DESTINATION" ]; then
    echo "Destination path not found: $DESTINATION" >&2
    exit 1
fi

TEMP_ROOT="$(mktemp -d -t pd2-modpack-XXXXXX)"
ZIP_PATH="$TEMP_ROOT/modpack.zip"
EXTRACT_DIR="$TEMP_ROOT/extract"

cleanup() {
    if [ -n "${TEMP_ROOT:-}" ] && [ -d "$TEMP_ROOT" ]; then
        rm -rf "$TEMP_ROOT"
    fi
}

trap cleanup EXIT

mkdir -p "$EXTRACT_DIR"

echo "Downloading modpack zip..."
if command -v curl >/dev/null 2>&1; then
    curl -L --fail --retry 3 --retry-delay 2 -o "$ZIP_PATH" "$ZIP_URL"
elif command -v wget >/dev/null 2>&1; then
    wget -O "$ZIP_PATH" "$ZIP_URL"
else
    echo "curl or wget is required to download the modpack." >&2
    exit 1
fi

echo "Extracting zip..."
if command -v unzip >/dev/null 2>&1; then
    unzip -q "$ZIP_PATH" -d "$EXTRACT_DIR"
else
    echo "unzip is required to extract the modpack." >&2
    exit 1
fi

ROOT_DIR="$(find "$EXTRACT_DIR" -mindepth 1 -maxdepth 1 -type d | head -n 1 || true)"
if [ -z "$ROOT_DIR" ]; then
    echo "Unexpected zip layout: no root folder found." >&2
    exit 1
fi

SRC_MODS="$ROOT_DIR/mods"
DEST_MODS="$DESTINATION/mods"

if [ -d "$DEST_MODS" ]; then
    for item in "$DEST_MODS"/* "$DEST_MODS"/.[!.]* "$DEST_MODS"/..?*; do
        [ -e "$item" ] || continue
        name="$(basename "$item")"
        case "$name" in
            saves|logs|downloads)
                continue
                ;;
        esac
        rm -rf "$item"
    done
else
    mkdir -p "$DEST_MODS"
fi

if [ -d "$SRC_MODS" ]; then
    cp -a "$SRC_MODS/." "$DEST_MODS"
fi

SRC_OVERRIDES="$ROOT_DIR/assets/mod_overrides"
DEST_ASSETS="$DESTINATION/assets"
DEST_OVERRIDES="$DESTINATION/assets/mod_overrides"

if [ -d "$SRC_OVERRIDES" ]; then
    if [ -d "$DEST_OVERRIDES" ]; then
        rm -rf "$DEST_OVERRIDES"
    fi
    mkdir -p "$DEST_ASSETS"
    cp -a "$SRC_OVERRIDES" "$DEST_ASSETS"
fi

for file in WSOCK32.dll README.md .gitignore .luarc.json; do
    if [ -f "$ROOT_DIR/$file" ]; then
        cp -a "$ROOT_DIR/$file" "$DESTINATION/$file"
    fi
done

CACHE_PATH="$DESTINATION/mods/ModpackUpdater/version_cache.json"
CACHE_DIR="$(dirname "$CACHE_PATH")"

if [ -d "$CACHE_DIR" ]; then
    TS="$(date "+%Y-%m-%d %H:%M:%S")"
    cat > "$CACHE_PATH" <<EOF
{
  "version": "zip",
  "commit": "Updated via zip",
  "date": "$TS",
  "cached_at": "$TS"
}
EOF
fi

echo "Update complete. Restart the game to apply changes."
