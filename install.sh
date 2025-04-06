#!/bin/bash

# ------------------------------------------------------------------------------
# install.sh - Instalador automatizado do TA-Nix Checker
#
# Este script detecta automaticamente a distribuição Linux (Debian-based ou RHEL-based),
# escolhe o pacote correto (.deb ou .rpm) e realiza a instalação.
# ------------------------------------------------------------------------------
# Versão: 1.0
# Autor: Levi Lima Greter
# Licença: MIT
# ------------------------------------------------------------------------------

# Ativa modo estrito:
set -e  # Encerra o script se qualquer comando retornar erro
set -u  # Encerra o script se variáveis não forem definidas

echo "[INFO] Detectando sistema operacional..."

# Inicializa a variável que armazenará o nome do sistema
OS=""

# Verifica se o arquivo de identificação do SO existe
if [ -f /etc/os-release ]; then
    source /etc/os-release  # Carrega variáveis como ID, VERSION_ID etc.
    OS=$ID                  # Define a variável OS com o ID do sistema (ex: ubuntu, centos)
else
    echo "[ERRO] Sistema operacional não suportado."
    exit 1
fi

echo "[INFO] Sistema detectado: $OS"

# Função que realiza a instalação do pacote apropriado com base no sistema
install_package() {
    case "$OS" in
        ubuntu|debian)
            echo "[INFO] Instalando pacote .deb..."
            sudo dpkg -i dist/ta-nix-checker*.deb || sudo apt-get install -f
            ;;
        centos|rhel|rocky|alma)
            echo "[INFO] Instalando pacote .rpm..."
            sudo rpm -ivh dist/ta-nix-checker*.rpm
            ;;
        *)
            echo "[ERRO] Distribuição $OS não suportada para instalação automática."
            exit 1
            ;;
    esac
}

# Verifica se há pacotes na pasta dist/ antes de tentar instalar
if compgen -G "dist/ta-nix-checker*.deb" > /dev/null || compgen -G "dist/ta-nix-checker*.rpm" > /dev/null; then
    install_package
    echo "[SUCESSO] Instalação concluída com sucesso."
else
    echo "[ERRO] Nenhum pacote .deb ou .rpm encontrado na pasta dist/"
    exit 1
fi
