# TA-Nix Checker

Verificador de compatibilidade para o **Splunk Add-on for Unix and Linux**, com suporte automatizado à instalação em distribuições baseadas em `.deb` e `.rpm`.

> Projeto mantido por Levi Lima Greter, sob a licença MIT.
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

## Visão Geral

Este projeto visa simplificar a instalação de verificadores de compatibilidade para ambientes Unix/Linux monitorados via Splunk, validando se os comandos utilizados pelos scripts do add-on estão disponíveis no sistema.

---

## Funcionalidades

- Detecção automática do sistema operacional
- Instalação de pacote `.deb` ou `.rpm` conforme a plataforma
- Logging detalhado em `/var/log/ta-nix-checker-install.log` (ou customizável)
- Interface de linha de comando com suporte a `--help`, `--version` e `--log-file`

---

## Pré-requisitos

- Shell compatível com `bash`
- Permissões para instalar pacotes com `sudo`
- Diretório `dist/` contendo o pacote `.deb` ou `.rpm` correspondente

---

## Instalação

Clone o repositório:

```bash
git clone https://github.com/levilimagreter/ta-nix-checker.git
cd ta-nix-checker
chmod +x install.sh
