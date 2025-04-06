#!/bin/bash

set -e

unset VERSION
: "${VERSION:=1.1.4}"
REPO_URL="https://raw.githubusercontent.com/levilimagreter/ta-nix-checker/dev/dist"

log() {
  echo "[TA-nix] $1"
}

# Função para checar suporte
check_cmd_or_file() {
  local label=$1
  local test_cmd=$2
  eval "$test_cmd" && echo "[OK] $label suportado" || echo "[X] $label não suportado"
}

log "Detectando sistema operacional..."
echo "[DEBUG] Versão definida: $VERSION"

if [ -f /etc/os-release ]; then
    source /etc/os-release
    DISTRO_ID=$ID
else
    log "Não foi possível detectar a distribuição Linux."
    exit 1
fi

log "Detected $DISTRO_ID-based system"

TMP_DIR=$(mktemp -d -t ta-nix-XXXX)
cd "$TMP_DIR"

case "$DISTRO_ID" in
    ubuntu|debian)
        log "Baixando pacote .deb..."
        eval "wget \"${REPO_URL}/ta-nix-checker_\${VERSION}.deb\" -O ta-nix-checker.deb"
        log "Instalando .deb..."
        sudo dpkg -i ta-nix-checker.deb
        ;;
    rhel|centos|rocky|almalinux|fedora)
        log "Baixando pacote .rpm..."
        eval "wget \"${REPO_URL}/ta-nix-checker-\${VERSION}.rpm\" -O ta-nix-checker.rpm"
        log "Instalando .rpm..."
        sudo rpm -ivh ta-nix-checker.rpm
        ;;
    *)
        log "Distribuição não identificada com precisão, usando fallback .tar.gz"
        eval "wget \"${REPO_URL}/ta-nix-checker-\${VERSION}.tar.gz\" -O ta-nix-checker.tar.gz"
        mkdir -p /opt/ta-nix-checker
        tar -xzf ta-nix-checker.tar.gz -C /opt/ta-nix-checker
        sudo ln -sf /opt/ta-nix-checker/usr/local/bin/ta-nix-check /usr/local/bin/ta-nix-check
        ;;
esac

log "Rodando verificação de suporte aos scripts do TA-nix..."

echo "------------------------ [ Sistema ] ------------------------"
check_cmd_or_file "cpu.sh" "test -r /proc/stat"
check_cmd_or_file "iostat.sh" "command -v iostat >/dev/null"
check_cmd_or_file "vmstat.sh" "test -r /proc/meminfo && test -r /proc/vmstat"
check_cmd_or_file "df.sh" "command -v df >/dev/null"
check_cmd_or_file "ps.sh" "test -r /proc/1/status"
check_cmd_or_file "top.sh" "test -r /proc/loadavg"
check_cmd_or_file "uptime.sh" "test -r /proc/uptime"
check_cmd_or_file "hardware.sh" "test -r /proc/cpuinfo"
check_cmd_or_file "interfaces.sh" "test -d /sys/class/net"

echo "------------------------ [ Rede e Usuários ] ------------------------"
check_cmd_or_file "netstat.sh" "command -v ss >/dev/null"
check_cmd_or_file "lastlog.sh" "test -r /var/log/wtmp"
check_cmd_or_file "lsof.sh" "ls /proc/1/fd >/dev/null 2>&1"
check_cmd_or_file "time.sh" "command -v timedatectl >/dev/null"
check_cmd_or_file "service.sh" "command -v systemctl >/dev/null"

echo "------------------------ [ Segurança e Serviços ] ------------------------"
check_cmd_or_file "rlog.sh" "command -v auditctl >/dev/null"
check_cmd_or_file "nfsiostat.sh" "command -v nfsiostat >/dev/null"
check_cmd_or_file "VsftpdChecker.sh" "ps aux | grep -q [v]sftpd"
check_cmd_or_file "SshdChecker.sh" "test -r /etc/ssh/sshd_config"

log "Verificação concluída."