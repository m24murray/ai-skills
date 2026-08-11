#!/usr/bin/env bash

set -e

# Target directory
TARGET_DIR="$HOME/.copilot/skills"

# Script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔧 Creating Copilot skills directory at: $TARGET_DIR"
mkdir -p "$TARGET_DIR"

echo "📁 Looking for folders named 'skills' in: $SCRIPT_DIR"

# Find top-level 'skills' directories inside the script directory
FOUND=false
for dir in "$SCRIPT_DIR"/skills*/ ; do
    if [ -d "$dir" ]; then
        FOUND=true
        echo "➡️  Installing: $dir → $TARGET_DIR"
        rm -rf "$TARGET_DIR/$(basename "$dir")"
        cp -r "$dir" "$TARGET_DIR/"
    fi
done

if [ "$FOUND" = false ]; then
    echo "❌ No skills directories found next to the script."
    exit 1
fi

echo "✅ Done!"
echo "Your skills folders are now located in: $TARGET_DIR"