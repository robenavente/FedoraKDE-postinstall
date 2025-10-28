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
  sudo dnf --refresh upgrade 
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

sudo dnf install neovim htop git tmux kvantum


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
    #Install Orchis theme
    if [[ ! -d "Orchis-kde/.git" ]]; then
      git clone https://github.com/vinceliuice/Orchis-kde.git
    fi
    cd "Orchis-kde"
    sudo ./install.sh
    cd ".."

    #Install Qogir theme
    if [[ ! -d "Qogir-kde/.git" ]]; then
      git clone https://github.com/vinceliuice/Qogir-kde.git
    fi
    cd "Qogir-kde"
    sudo ./install.sh
    cd ".."
    
    #Install Colloid Theme
    if [[ ! -d "Colloid-kde/.git" ]]; then
      git clone https://github.com/vinceliuice/Colloid-kde.git
    fi
    cd "Colloid-kde"
    sudo ./install.sh
    cd ".."

    #Install catppuccin Theme
    if [[ ! -d "kde/.git" ]]; then
      git clone https://github.com/catppuccin/kde.git
    fi
    cd "kde"
    ./install.sh
    cd ".."
    
    #Install Colloid icon theme
    if [[ ! -d "Colloid-icon-theme/.git" ]]; then
        git clone https://github.com/vinceliuice/Colloid-icon-theme.git
    fi
    cd "Colloid-icon-theme"
    sudo ./install.sh -s all -t all
    cd ".."

    #Install Qogir icon theme
    if [[ ! -d "Qogir-icon-theme/.git" ]]; then
        git clone https://github.com/vinceliuice/Qogir-icon-theme.git
    fi
    cd "Qogir-icon-theme"
    sudo ./install.sh 
    cd ".."
  
    #Install Tela circle icon theme
    if [[ ! -d "Tela-circle-icon-theme/.git" ]]; then
        git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git
    fi
    cd "Tela-circle-icon-theme"
    sudo ./install.sh -a
    cd ".."

    #Install Nordzy icon theme
    if [[ ! -d "Nordzy-icon/.git" ]]; then
        git clone https://github.com/MolassesLover/Nordzy-icon.git
    fi
    cd "Nordzy-icon"
    sudo ./install.sh
    cd ".."

    #Install WhiteSur cursor theme
    if [[ ! -d "WhiteSur-cursors/.git" ]]; then
        git clone https://github.com/vinceliuice/WhiteSur-cursors.git
    fi
    cd "WhiteSur-cursors"
    sudo ./install.sh 
    cd ".."

    #Install Graphite cursor theme
    if [[ ! -d "Graphite-cursors/.git" ]]; then
        git clone https://github.com/vinceliuice/Graphite-cursors.git
    fi
    cd "Graphite-cursors"
    sudo ./install.sh 
    cd ".."

    #Install Vimix cursor theme
    if [[ ! -d "Vimix-cursors/.git" ]]; then
        git clone https://github.com/vinceliuice/Vimix-cursors.git
    fi
    cd "Vimix-cursors"
    sudo ./install.sh 
    cd ".."

    #Install Vimix cursor theme
    if [[ ! -d "WhiteSur-cursors/.git" ]]; then
        git clone https://github.com/vinceliuice/WhiteSur-cursors.git
    fi
    cd "WhiteSur-cursors"
    sudo ./install.sh 
    cd ".."


    ##################################
    #Applying theme and configuration
    ##################################
    
    #Getting KARA plasmoid:
    if [[ ! -d "WhiteSur-cursors/.git" ]]; then
        git clone https://github.com/dhruv8sh/kara.git
    fi
    cp -r "kara"  ~/.local/share/plasma/plasmoids/org.dhruv8sh.kara
    
    




    

fi
sudo rm -f "$MARKER"
echo ">>> Post-install completed successfully."