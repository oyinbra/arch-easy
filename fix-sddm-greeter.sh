#!/bin/bash
set -e

echo "[*] Installing SDDM greeter + required Qt5 modules..."
sudo pacman -Syu --needed --noconfirm \
    sddm \
    qt5-graphicaleffects \
    qt5-quickcontrols2 \
    plasma-workspace

echo "[*] Creating SDDM config directory..."
sudo mkdir -p /etc/sddm.conf.d

echo "[*] Setting Breeze theme as current greeter..."
sudo tee /etc/sddm.conf.d/theme.conf > /dev/null <<EOF
[Theme]
Current=breeze
EOF

echo "[*] Enabling and restarting SDDM service..."
sudo systemctl enable sddm.service
sudo systemctl restart sddm.service

echo "[✓] SDDM greeter fix (Qt5) applied. Reboot if display does not appear automatically."