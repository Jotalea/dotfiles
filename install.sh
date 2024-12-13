#!/bin/bash

# Function to check and install dependencies
check_dependency() {
    local package=$1
    if ! command -v "$package" &>/dev/null; then
        echo "$package is not installed. Installing..."
        sudo apt update && sudo apt install -y "$package"
    else
        echo "$package is already installed."
    fi
}

# Check required dependencies
check_dependency "p7zip-full"
check_dependency "gnome-extensions"
check_dependency "gnome-tweaks"

# Check for User Themes extension
if ! gnome-extensions list | grep -q 'user-theme'; then
    echo "User Themes extension is not enabled. Please enable it via GNOME Extensions."
    exit 1
fi

# Prompt user for personalized configurations
read -p "Are you Jotalea? (y/N): " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "Copying Jotalea-only configs..."
    cp -r onlyme/config/* config/
fi

# Validate and extract archives
if [ ! -f themes.7z ]; then
    echo "themes.7z not found. Please place it in the current directory."
    exit 1
fi
7z x themes.7z -o"$HOME/.themes" || { echo "Failed to extract themes."; exit 1; }

if [ ! -f icons.7z ]; then
    echo "icons.7z not found. Please place it in the current directory."
    exit 1
fi
7z x icons.7z -o"$HOME/.icons" || { echo "Failed to extract icons."; exit 1; }

if [ ! -f local/share/gnome-shell.7z ]; then
    echo "local/share/gnome-shell.7z not found. Please place it in the correct directory."
    exit 1
fi
7z x local/share/gnome-shell.7z -o"$HOME/.local/share/gnome-shell" || { echo "Failed to extract GNOME Shell files."; exit 1; }

# Install fonts
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
if [ ! -f local/share/fonts/SF-Pro.ttf ] || [ ! -f local/share/fonts/Mojangles.ttf ]; then
    echo "Required font files are missing in local/share/fonts."
    exit 1
fi
cp local/share/fonts/*.ttf "$FONT_DIR"
fc-cache -f

# Apply GNOME customizations
echo "Applying GNOME customizations..."
gsettings set org.gnome.desktop.wm.preferences button-layout "close,minimize,maximize:"
gsettings set org.gnome.desktop.interface cursor-theme "MacOS-Pixel-vr2"
gsettings set org.gnome.desktop.interface font-name 'SF Pro 10'
gsettings set org.gnome.desktop.interface document-font-name 'SF Pro 10'
gsettings set org.gnome.desktop.interface monospace-font-name 'Mojangles 10'
gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Dark'
gsettings set org.gnome.desktop.interface icon-theme "Mkos-Big-Sur"

# Apply custom configuration files
CONFIG_DIR="$HOME/.config"
if [ -d "$CONFIG_DIR" ]; then
    echo "Backing up existing configuration files..."
    mv "$CONFIG_DIR" "${CONFIG_DIR}.backup.$(date +%s)"
fi
cp -r config/* "$CONFIG_DIR/"

# Completion message and GNOME Shell restart reminder
echo "Dotfiles installed and GNOME customized successfully!"
echo "Please restart GNOME Shell (Alt+F2, type 'r') for changes to take effect."