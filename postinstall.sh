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

sudo dnf install neovim htop git tmux kvantum qt-qdbusviewer dnf-plugins-core


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
    ./install.sh
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
    if [[ ! -d "kara/.git" ]]; then
        git clone https://github.com/dhruv8sh/kara.git
    fi
    mkdir -p  ~/.local/share/plasma/plasmoids/org.dhruv8sh.kara
    cp -r kara/*  ~/.local/share/plasma/plasmoids/org.dhruv8sh.kara

    #Catppuchin color scheme for konsole
    if [[ ! -d "konsole/.git" ]]; then
        git clone https://github.com/catppuccin/konsole.git
    fi
    sudo mkdir -p /usr/share/konsole/
    sudo cp konsole/themes/* /usr/share/konsole/
      
    #Copying configuration files
    cd "$REPO_DIR/kde-config"
    mkdir -p "$HOME/bin"
    cp bin/* "$HOME/bin"
    cp -r .config/* "$HOME/.config"
    mkdir -p "$HOME/.local/share/applications"
    cp -r .local/share/* ~/.local/share/
fi

# ---------- Stage 4 ----------
#Installing additional packages and adding repos

read -p "Would you like to install flatpak and enable flathub? [y/N] " REPLY
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    sudo dnf install flatpak &&
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

read -p "Would you like to install timeshift and enable quotas for /? [y/N] " REPLY
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    sudo dnf install timeshift &&
    sudo btrfs quota enable /
fi

read -p "Would you like to install Google Chrome and Brave browser? [y/N] " REPLY
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
     
     #Brave
     sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
     sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
     sudo dnf install brave-browser
     #Chrome
     wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
     sudo dnf install ./google-chrome-stable_current_x86_64.rpm
fi

read -p "Enable rpm fusion free and nonfree repos? [y/N] " REPLY
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    # Enable Free repository
    sudo dnf install \
    https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm

    # Enable Non-Free repository
    sudo dnf install \
    https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
fi

read -p "Install VScodium? [y/N] " REPLY
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    # Enable Free repository
    sudo rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
    printf "[gitlab.com_paulcarroty_vscodium_repo]\nname=download.vscodium.com\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg\nmetadata_expire=1h\n" | sudo tee -a /etc/yum.repos.d/vscodium.repo
    sudo dnf install codium
fi

read -p "Install NVidia drivers (from NVidia repo)[y/N] " REPLY
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    sudo dnf install kernel-devel-matched kernel-headers
    #distro="fedora$(rpm -E %fedora)"
    #There is no fedora43 repo for now, so:
    distro="fedora42"
    arch="x86_64"
    sudo dnf config-manager addrepo --from-repofile=https://developer.download.nvidia.com/compute/cuda/repos/$distro/$arch/cuda-$distro.repo
    sudo dnf clean expire-cache
    sudo dnf install nvidia-open
fi

read -p "Install Intel MKL [y/N] " REPLY
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    tee > oneAPI.repo << EOF
[oneAPI]
name=Intel® oneAPI repository
baseurl=https://yum.repos.intel.com/oneapi
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
EOF

    sudo cp oneAPI.repo /etc/yum.repos.d
    sudo dnf install intel-oneapi-mkl intel-oneapi-mkl-devel   
fi


sudo rm -f "$MARKER"
echo ">>> Post-install completed successfully."