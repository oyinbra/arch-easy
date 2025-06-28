#!/bin/bash
set -euo pipefail

# -------------------------
# ASCII Header
# -------------------------
cat << "EOF"
 _____                             _           _
| ____|_ __   ___ _ __ _   _ _ __ | |_ ___  __| |
|  _| | '_ \ / __| '__| | | | '_ \| __/ _ \/ _` |
| |___| | | | (__| |  | |_| | |_) | ||  __/ (_| |
|_____|_| |_|\___|_|   \__, | .__/ \__\___|\__,_|
                       |___/|_|
EOF

# -------------------------
# Prompt for username
# -------------------------
read -rp "Enter your system username (for chown): " USERNAME
GROUPNAME="$USERNAME"

# -------------------------
# Config
# -------------------------
DEVICE="/dev/nvme0n1p5"
MAPPER_NAME="encrypted_backup"
MOUNT_POINT="/backup"
KEYFILE="/etc/keys/backup.key"
CRYPTTAB="/etc/crypttab"
FSTAB="/etc/fstab"

# -------------------------
# Ensure preconditions
# -------------------------
sudo mkdir -p "$(dirname "$KEYFILE")"
sudo mkdir -p "$MOUNT_POINT"

if ! sudo cryptsetup isLuks "$DEVICE"; then
  echo "[!] $DEVICE is not a LUKS-encrypted volume."
  exit 1
fi

# -------------------------
# Generate keyfile if missing
# -------------------------
if [ ! -f "$KEYFILE" ]; then
  echo "[*] Creating keyfile..."
  sudo dd if=/dev/urandom of="$KEYFILE" bs=512 count=4
  sudo chmod 600 "$KEYFILE"
fi

# -------------------------
# Add keyfile to LUKS
# -------------------------
echo "[*] Adding keyfile to LUKS keyslot..."
sudo cryptsetup luksAddKey "$DEVICE" "$KEYFILE"

# -------------------------
# Update crypttab
# -------------------------
CRYPT_ENTRY="$MAPPER_NAME $DEVICE $KEYFILE luks"
if ! grep -q "^$MAPPER_NAME[[:space:]]" "$CRYPTTAB"; then
  echo "$CRYPT_ENTRY" | sudo tee -a "$CRYPTTAB" > /dev/null
  echo "[+] Added to crypttab"
fi

# -------------------------
# Update fstab
# -------------------------
FSTAB_ENTRY="/dev/mapper/$MAPPER_NAME $MOUNT_POINT btrfs defaults,nofail,x-systemd.device-timeout=5 0 0"
if ! grep -q "^/dev/mapper/$MAPPER_NAME[[:space:]]" "$FSTAB"; then
  echo "$FSTAB_ENTRY" | sudo tee -a "$FSTAB" > /dev/null
  echo "[+] Added to fstab"
fi

# -------------------------
# Unlock + mount now
# -------------------------
if ! [ -e "/dev/mapper/$MAPPER_NAME" ]; then
  echo "[*] Unlocking encrypted volume with keyfile..."
  sudo cryptsetup open "$DEVICE" "$MAPPER_NAME" --key-file "$KEYFILE"
fi

if ! mountpoint -q "$MOUNT_POINT"; then
  echo "[*] Mounting..."
  sudo mount "/dev/mapper/$MAPPER_NAME" "$MOUNT_POINT"
fi

# -------------------------
# Set ownership
# -------------------------
sudo chown -R "$USERNAME:$GROUPNAME" "$MOUNT_POINT"
sudo chmod 755 "$MOUNT_POINT"

# -------------------------
# Include keyfile in initramfs
# -------------------------
if ! grep -q "^FILES=.*$KEYFILE" /etc/mkinitcpio.conf; then
  sudo sed -i "/^FILES=/ s|)| $KEYFILE)|" /etc/mkinitcpio.conf || \
  echo "FILES=($KEYFILE)" | sudo tee -a /etc/mkinitcpio.conf > /dev/null
fi

echo "[*] Regenerating initramfs..."
sudo mkinitcpio -P

# -------------------------
# Done
# -------------------------
cat << "EOF"
 ____   ___  _   _ _____
|  _ \ / _ \| \ | | ____|
| | | | | | |  \| |  _|
| |_| | |_| | |\  | |___
|____/ \___/|_| \_|_____|
EOF