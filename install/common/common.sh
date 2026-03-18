#!/bin/bash
echo "RUNNING modules/music-module/install/common/common.sh"
export MODULE_ROOT="$ROOT/modules/music-module"

# --- CONFIGURATION ---
MODULE_NAME=$(basename "$MODULE_ROOT")   # infer module name from dir name
MODULE_CLASS="common"
MODULE_ID=$MODULE_NAME-$MODULE_CLASS
SERVICE_SRC="$MODULE_ROOT/install/common/$MODULE_ID.service"
SERVICE_DST="/usr/lib/systemd/user/$MODULE_ID.service"

# Install audio stack
sudo apt install -y pipewire pipewire-alsa pipewire-pulse pipewire-bin pipewire-audio wireplumber libspa-0.2-modules

# Install mpd and mpc

sudo apt install -y mpd mpc

# Copy config
cp $MODULE_ROOT/config/common/mpd.conf ~/.config/mpd/mpd.conf

# Install ymuse

sudo apt install -y ./ymuse_0.22_linux_arm64.deb

# --- INSTALL SYSTEMD SERVICES ---
echo "Installing systemd service: $SERVICE_DST"
sudo cp "$SERVICE_SRC" "$SERVICE_DST"
sudo chmod 644 "$SERVICE_DST"

# Reload systemd to pick up new/changed service file
echo "Reloading systemd daemon"
systemctl --user daemon-reload

# --- ENABLE & START SERVICE ---
echo "Enabling Services"
systemctl --user enable mpd.service
systemctl --user enable "$MODULE_ID.service"

echo "Starting Services"
systemctl --user restart mpd.service
systemctl --user restart "$MODULE_ID.service"

echo "Deployment complete for module: $MODULE_ID"

