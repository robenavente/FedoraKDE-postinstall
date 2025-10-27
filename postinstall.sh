#!/usr/bin/env bash
set -e

# always read from terminal
exec </dev/tty

MARKER=/var/lib/postinstall_stage1_done
POST_INSTALL_DIR="$HOME/postinstall"
REPO_DIR="$POST_INSTALL_DIR/FedoraKDE-postinstall"

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
echo "Installing essential packages"

mkdir -p "$POST_INSTALL_DIR"
cd "$POST_INSTALL_DIR"

sudo dnf install neovim htop git tmux 
if [[ ! -d "$REPO_DIR/.git" ]]; then
  echo ">>> Cloning postinstall repo..."
  git clone https://github.com/robenavente/FedoraKDE-postinstall.git "$REPO_DIR"
else
  echo ">>> Repository already exists, pulling latest changes..."
  (cd "$REPO_DIR" && git pull --ff-only)
fi
# ---------- Stage 3 ----------

read -p "Would you like to configure and theme the workspace? [y/N] " REPLY
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
  echo "cool"
fi
sudo rm -f "$MARKER"
echo ">>> Post-install completed successfully."