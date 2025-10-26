#!/usr/bin/env bash
set -e

MARKER=/var/lib/postinstall_stage1_done

# ---------- Stage 1 ----------
if [[ ! -f "$MARKER" ]]; then
  echo ">>> Performing initial system upgrade..."
  sudo dnf --refresh upgrade -y
  echo ">>> System is now up to date."

  # Create marker so we know the first stage is finished
  sudo mkdir -p "$(dirname "$MARKER")"
  echo "ok" | sudo tee "$MARKER" >/dev/null

  echo ">>> Reboot is required to continue setup."
  read -p "Reboot now? [y/N] " REBOOT
  if [[ "$REBOOT" =~ ^[Yy]$ ]]; then
    sudo systemctl reboot
  fi

  # Stop here until the next boot
  exit 0
fi

# ---------- Stage 2 ----------
echo ">>> Stage 2: continuing configuration after reboot..."
# (put the rest of your setup here)
# e.g. install packages, themes, drivers, etc.

sudo rm -f "$MARKER"
echo ">>> Post-install completed successfully."

