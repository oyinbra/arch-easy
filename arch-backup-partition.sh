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
# Ensure required paths
# -------------------------
sudo mkdir -p "$(dirname "$KEYFILE")"
sudo mkdir -p "$MOUNT_POINT"

# -------------------------
# Validate LUKS
# -------------------------
if ! sudo cryptsetup isLuks "$DEVICE"; then
  echo "[!] $DEVICE is not a LUKS-encrypted volume."
  exit 1
fi

# -------------------------
# Generate keyfile
# -------------------------
if [ ! -f "$KEYFILE" ]; then
  echo "[*] Creating keyfile..."
  sudo dd if=/dev/urandom of="$KEYFILE" bs=512 count=4
  sudo chmod 600 "$KEYFILE"
  echo "[+] Keyfile created at $KEYFILE"
fi

# -------------------------
# Add keyfile to LUKS
# -------------------------
echo "[*] Adding keyfile to LUKS keyslot..."
sudo cryptsetup luksAddKey "$DEVICE" "$KEYFILE"

# -------------------------
# Update /etc/crypttab
# -------------------------
CRYPT_ENTRY="$MAPPER_NAME $DEVICE $KEYFILE luks"
if ! grep -q "^$MAPPER_NAME[[:space:]]" "$CRYPTTAB"; then
  echo "$CRYPT_ENTRY" | sudo tee -a "$CRYPTTAB" > /dev/null
  echo "[+] Added to /etc/crypttab"
fi

# -------------------------
# Update /etc/fstab
# -------------------------
FSTAB_ENTRY="/dev/mapper/$MAPPER_NAME $MOUNT_POINT btrfs noatime,nofail,x-systemd.device-timeout=5,x-systemd.requires=systemd-cryptsetup@$MAPPER_NAME.service,x-systemd.after=systemd-cryptsetup@$MAPPER_NAME.service 0 0"
if ! grep -q "^/dev/mapper/$MAPPER_NAME[[:space:]]" "$FSTAB"; then
  echo "$FSTAB_ENTRY" | sudo tee -a "$FSTAB" > /dev/null
  echo "[+] Added to /etc/fstab"
fi

# -------------------------
# Unlock and mount
# -------------------------
if ! [ -e "/dev/mapper/$MAPPER_NAME" ]; then
  echo "[*] Unlocking encrypted volume with keyfile..."
  sudo cryptsetup open "$DEVICE" "$MAPPER_NAME" --key-file "$KEYFILE"
fi

if ! mountpoint -q "$MOUNT_POINT"; then
  echo "[*] Mounting volume..."
  sudo mount "/dev/mapper/$MAPPER_NAME" "$MOUNT_POINT"
fi

# -------------------------
# Set ownership
# -------------------------
sudo chown -R "$USERNAME:$GROUPNAME" "$MOUNT_POINT"
sudo chmod 755 "$MOUNT_POINT"

# -------------------------
# Add keyfile to initramfs
# -------------------------
if grep -q "^FILES=" /etc/mkinitcpio.conf; then
  if ! grep -q "$KEYFILE" /etc/mkinitcpio.conf; then
    sudo sed -i "s|^FILES=(|FILES=($KEYFILE |" /etc/mkinitcpio.conf
    echo "[+] Keyfile added to existing FILES line in mkinitcpio.conf"
  fi
else
  echo "FILES=($KEYFILE)" | sudo tee -a /etc/mkinitcpio.conf > /dev/null
  echo "[+] FILES line created in mkinitcpio.conf"
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

