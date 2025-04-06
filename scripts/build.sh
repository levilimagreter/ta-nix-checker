#!/bin/bash

set -e

cd "$(dirname "$0")/.."  # volta para raiz do projeto

VERSION=$1
echo "Building version: $VERSION"

# Preparar estrutura DEB e TAR.GZ
mkdir -p ta-nix-checker/usr/local/bin
cp ta_nix_verifier/cli.py ta-nix-checker/usr/local/bin/ta_nix_verification_cli.py
echo '#!/bin/bash' > ta-nix-checker/usr/local/bin/ta-nix-check
echo 'exec python3 /usr/local/bin/ta_nix_verification_cli.py "$@"' >> ta-nix-checker/usr/local/bin/ta-nix-check
chmod +x ta-nix-checker/usr/local/bin/ta-nix-check

# Criar arquivo de controle para DEB
mkdir -p ta-nix-checker/DEBIAN
cat <<EOF > ta-nix-checker/DEBIAN/control
Package: ta-nix-checker
Version: $VERSION
Section: utils
Priority: optional
Architecture: all
Maintainer: Levi Lima Greter
Description: Verificador de pré-requisitos para o Splunk Add-on for Unix/Linux (TA-nix)
EOF

# Build .deb
dpkg-deb --build ta-nix-checker
mv ta-nix-checker.deb dist/ta-nix-checker_${VERSION}.deb

# Build .tar.gz
tar -czf dist/ta-nix-checker-${VERSION}.tar.gz ta-nix-checker

# Build .rpm (usando fpm)
mkdir -p rpmroot/usr/local/bin
cp ta_nix_verifier/cli.py rpmroot/usr/local/bin/ta_nix_verification_cli.py
echo '#!/bin/bash' > rpmroot/usr/local/bin/ta-nix-check
echo 'exec python3 /usr/local/bin/ta_nix_verification_cli.py "$@"' >> rpmroot/usr/local/bin/ta-nix-check
chmod +x rpmroot/usr/local/bin/ta-nix-check
fpm -s dir -t rpm -n ta-nix-checker -v "$VERSION" -C rpmroot .
mv ta-nix-checker-${VERSION}-1.x86_64.rpm dist/ta-nix-checker-${VERSION}.rpm

# Limpeza
rm -rf ta-nix-checker rpmroot
