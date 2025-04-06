#!/bin/bash

set -e

VERSION="1.1.4"
REPO_URL="https://example.com/releases"  # Substitua pelo caminho real no GitHub se for usar wget

# Detectar distribuição
if [ -f /etc/os-release ]; then
    source /etc/os-release
    DISTRO_ID=$ID
else
    echo "[ERRO] Não foi possível detectar a distribuição Linux."
    exit 1
fi

echo "[INFO] Detectado sistema: $DISTRO_ID"

TMP_DIR=$(mktemp -d -t ta-nix-XXXX)
cd "$TMP_DIR"

case "$DISTRO_ID" in
    ubuntu|debian)
        echo "[INFO] Instalando pacote .deb..."
        sudo dpkg -i ../ta-nix-checker_1.1.4.deb
        ;;
    rhel|centos|rocky|almalinux|fedora)
        echo "[INFO] Instalando pacote .rpm..."
        sudo rpm -ivh ../ta-nix-checker-1.1.4.rpm
        ;;
    *)
        echo "[INFO] Usando fallback com .tar.gz"
        mkdir -p /opt/ta-nix-checker
        tar -xzf ../ta-nix-checker-1.1.4.tar.gz -C /opt/ta-nix-checker
        sudo ln -sf /opt/ta-nix-checker/usr/local/bin/ta-nix-check /usr/local/bin/ta-nix-check
        ;;
esac

echo "[OK] Rodando verificador..."
sudo ta-nix-check || true