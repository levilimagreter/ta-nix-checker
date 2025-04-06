#!/bin/bash

set -e

VERSION="1.1.4"
REPO_URL="https://raw.githubusercontent.com/levilimagreter/ta-nix-checker/main/dist"

# Detectar distribuição
if [ -f /etc/os-release ]; then
    source /etc/os-release
    DISTRO_ID=$ID
else
    echo "[ERRO] Não foi possível detectar a distribuição Linux."
    exit 1
fi

echo "[INFO] Detectado sistema: $DISTRO_ID"

# Criar diretório temporário
TMP_DIR=$(mktemp -d -t ta-nix-XXXX)
cd "$TMP_DIR"

case "$DISTRO_ID" in
    ubuntu|debian)
        echo "[INFO] Baixando pacote .deb..."
        wget "$REPO_URL/ta-nix-checker_${VERSION}.deb" -O ta-nix-checker.deb
        echo "[INFO] Instalando pacote .deb..."
        sudo dpkg -i ta-nix-checker.deb
        ;;
    rhel|centos|rocky|almalinux|fedora)
        echo "[INFO] Baixando pacote .rpm..."
        wget "$REPO_URL/ta-nix-checker-${VERSION}.rpm" -O ta-nix-checker.rpm
        echo "[INFO] Instalando pacote .rpm..."
        sudo rpm -ivh ta-nix-checker.rpm
        ;;
    *)
        echo "[INFO] Baixando fallback .tar.gz..."
        wget "$REPO_URL/ta-nix-checker-${VERSION}.tar.gz" -O ta-nix-checker.tar.gz
        mkdir -p /opt/ta-nix-checker
        tar -xzf ta-nix-checker.tar.gz -C /opt/ta-nix-checker
        sudo ln -sf /opt/ta-nix-checker/usr/local/bin/ta-nix-check /usr/local/bin/ta-nix-check
        ;;
esac

echo "[OK] Instalação concluída. Rodando verificação..."
sudo ta-nix-check || true