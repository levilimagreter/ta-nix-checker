#!/bin/bash

# ------------------------------------------------------------------------------
# install.sh - Instalador automatizado do TA-Nix Checker
#
# Este script detecta automaticamente a distribuição Linux, escolhe o pacote
# correto (.deb ou .rpm) e realiza a instalação. Suporta argumentos:
# --help, --version e --log-file customizado.
# ------------------------------------------------------------------------------
# Versão: 1.1
# Autor: Levi Lima Greter
# Licença: MIT
# ------------------------------------------------------------------------------

set -euo pipefail

SCRIPT_VERSION="1.1"
DEFAULT_LOG="/var/log/ta-nix-checker-install.log"
LOG_FILE="$DEFAULT_LOG"

# ------------------------------------------------------------------------------
# Funções utilitárias
# ------------------------------------------------------------------------------

show_help() {
    echo "TA-Nix Checker Installer - v$SCRIPT_VERSION"
    echo ""
    echo "Uso: ./install.sh [--log-file <arquivo>] [--help] [--version]"
    echo ""
    echo "  --log-file <arquivo>  Define caminho do log (padrão: $DEFAULT_LOG)"
    echo "  --help                Exibe esta ajuda"
    echo "  --version             Exibe a versão do instalador"
    exit 0
}

show_version() {
    echo "TA-Nix Checker Installer v$SCRIPT_VERSION"
    exit 0
}

log() {
    local msg="[INFO] $1"
    echo "$msg"
    echo "$(date '+%Y-%m-%d %H:%M:%S') $msg" >> "$LOG_FILE"
}

log_error() {
    local msg="[ERRO] $1"
    echo "$msg" >&2
    echo "$(date '+%Y-%m-%d %H:%M:%S') $msg" >> "$LOG_FILE"
    exit 1
}

# ------------------------------------------------------------------------------
# Processa argumentos com getopts
# ------------------------------------------------------------------------------

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            show_help
            ;;
        --version)
            show_version
            ;;
        --log-file)
            shift
            LOG_FILE="$1"
            ;;
        *)
            log_error "Argumento desconhecido: $1"
            ;;
    esac
    shift
done

# Garante que o arquivo de log pode ser escrito
touch "$LOG_FILE" 2>/dev/null || log_error "Não foi possível escrever no log: $LOG_FILE"

# ------------------------------------------------------------------------------
# Detecção do sistema operacional
# ------------------------------------------------------------------------------

log "Detectando sistema operacional..."

OS=""
if [ -f /etc/os-release ]; then
    source /etc/os-release
    OS=$ID
else
    log_error "Sistema operacional não suportado."
fi

log "Sistema detectado: $OS"

# ------------------------------------------------------------------------------
# Instalação baseada na distribuição
# ------------------------------------------------------------------------------

install_package() {
    case "$OS" in
        ubuntu|debian)
            log "Instalando pacote .deb..."
            sudo dpkg -i dist/ta-nix-checker*.deb || sudo apt-get install -f
            ;;
        centos|rhel|rocky|alma)
            log "Instalando pacote .rpm..."
            sudo rpm -ivh dist/ta-nix-checker*.rpm
            ;;
        *)
            log_error "Distribuição $OS não suportada para instalação automática."
            ;;
    esac
}

# ------------------------------------------------------------------------------
# Execução
# ------------------------------------------------------------------------------

if compgen -G "dist/ta-nix-checker*.deb" > /dev/null || compgen -G "dist/ta-nix-checker*.rpm" > /dev/null; then
    install_package
    log "Instalação concluída com sucesso."
else
    log_error "Nenhum pacote .deb ou .rpm encontrado na pasta dist/"
fi
