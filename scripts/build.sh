#!/bin/bash

set -e

# Obtém a versão da tag atual no GitHub Actions ou manualmente via argumento
if [ -n "$GITHUB_REF" ]; then
    VERSION=$(basename "$GITHUB_REF")
else
    VERSION=${1:-"1.1.4"}
fi

# Remove prefixo "v" se existir
VERSION=${VERSION#v}

echo "Building version: $VERSION"

# Criação do diretório de saída
mkdir -p dist/usr/local/bin
cp ta-nix-checker dist/usr/local/bin/
cp ta_nix_verification_cli.py dist/usr/local/bin/

# Gerar pacotes
fpm -s dir -t deb -n ta-nix-checker -v "$VERSION" --license MIT \
  --description "TA-nix prerequisite checker for Splunk Add-on for Unix/Linux" \
  --maintainer "Levi Lima Greter" --prefix=/ dist

fpm -s dir -t rpm -n ta-nix-checker -v "$VERSION" --license MIT \
  --description "TA-nix prerequisite checker for Splunk Add-on for Unix/Linux" \
  --maintainer "Levi Lima Greter" --prefix=/ dist

tar -czf "ta-nix-checker-$VERSION.tar.gz" -C dist .
