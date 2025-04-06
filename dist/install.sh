#!/bin/bash
set -e

echo "[TA-nix] Detectando sistema operacional..."

if [ -f /etc/debian_version ]; then
    echo "[TA-nix] Detected Debian-based system"
    PKG_URL=$(curl -s https://api.github.com/repos/levilimagreter/ta-nix-checker/releases/latest | grep browser_download_url | grep .deb | cut -d '"' -f 4)
    curl -sL "$PKG_URL" -o ta-nix.deb
    sudo dpkg -i ta-nix.deb

elif [ -f /etc/redhat-release ] || [ -f /etc/centos-release ]; then
    echo "[TA-nix] Detected RHEL-based system"
    PKG_URL=$(curl -s https://api.github.com/repos/levilimagreter/ta-nix-checker/releases/latest | grep browser_download_url | grep .rpm | cut -d '"' -f 4)
    curl -sL "$PKG_URL" -o ta-nix.rpm
    sudo rpm -Uvh ta-nix.rpm

else
    echo "[TA-nix] Sistema operacional não suportado automaticamente."
    exit 1
fi

echo "[TA-nix] Instalação concluída. Execute: ta-nix-check --verbose --output-format both"