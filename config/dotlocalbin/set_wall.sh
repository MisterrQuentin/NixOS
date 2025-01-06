#!/usr/bin/env bash

set -e

# Check if HOST is set
if [ -z "$HOST" ]; then
    echo "Error: HOST environment variable is not set"
    exit 1
fi

# Add system bin to PATH
export PATH="/run/current-system/sw/bin:$PATH"

# Path to the current wallpaper file
CURRENT_WALLPAPER_FILE="/home/jedwick/.current_wallpaper"
WALLPAPER_DIR="/home/jedwick/zaneyos/config/wallpapers"

# Check if the current wallpaper file exists
if [ ! -f "$CURRENT_WALLPAPER_FILE" ]; then
    echo "Current wallpaper file not found!"
    exit 1
fi

# Read the current wallpaper path
CURRENT_WALLPAPER=$(cat "$CURRENT_WALLPAPER_FILE")

# Get the filename from the path
FILENAME=$(basename "$CURRENT_WALLPAPER")

# Create wallpaper directory if it doesn't exist
mkdir -p "$WALLPAPER_DIR"

# Remove all files in wallpaper directory except zaney-wallpaper.jpg
find "$WALLPAPER_DIR" -type f ! -name 'zaney-wallpaper.jpg' -delete

# Copy the wallpaper with original filename and the name wallpaper.jpg which hyprland will load after a reboot.
cp "$CURRENT_WALLPAPER" "$WALLPAPER_DIR/$FILENAME"   # used by stylix
cp "$CURRENT_WALLPAPER" "$WALLPAPER_DIR/wallpaper.jpg"   # used by hyprland

# Update Wallpaper now.
swww img "$WALLPAPER_DIR/$FILENAME"

# Generate new hash for stylix
NEW_HASH=$(nix-prefetch-url "file://$WALLPAPER_DIR/$FILENAME" 2>/dev/null)

# Update the filename and hash in the stylix configuration file
sed -i -E "s|url = \"file://\\\$\{toString ./wallpapers/.*\}\"|url = \"file://\${toString ./wallpapers/$FILENAME}\"|" "/home/jedwick/zaneyos/config/stylix.nix"
sed -i "s|sha256 = \"sha256:.*\"|sha256 = \"sha256:$NEW_HASH\"|" "/home/jedwick/zaneyos/config/stylix.nix"

# Rebuild NixOS configuration
echo "Files are in place, please rebuild your system with fr command"
# nh os switch --hostname "$HOST" "/home/jedwick/zaneyos"
