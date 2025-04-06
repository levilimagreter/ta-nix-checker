#!/usr/bin/env python3
"""
ta_nix_verification_cli.py

Verifica se os comandos e caminhos esperados pelos scripts do
Splunk Add-on for Unix and Linux (TA-nix) estão disponíveis no sistema.

Suporta saída em texto legível ou JSON.
"""

import os
import shutil
import json
import argparse
import logging
from typing import List, Dict

# ------------------------------------------------------------------------------
# Configuração de logging
# ------------------------------------------------------------------------------
logging.basicConfig(
    level=logging.INFO,
    format='[%(levelname)s] %(message)s'
)

# ------------------------------------------------------------------------------
# Tabelas de referência (podem ser extraídas de um arquivo futuramente)
# ------------------------------------------------------------------------------
commands_expected = [
    'df', 'iostat', 'vmstat', 'uptime', 'top', 'ps', 'netstat', 'sar', 'who'
]

paths_expected = [
    '/usr/bin/df', '/usr/bin/iostat', '/usr/bin/vmstat', '/usr/bin/uptime'
]

# ------------------------------------------------------------------------------
# Funções utilitárias
# ------------------------------------------------------------------------------
def check_command_exists(command: str) -> bool:
    return shutil.which(command) is not None

def check_path_exists(path: str) -> bool:
    return os.path.exists(path)

def check_all(items: List[str], check_func) -> Dict[str, bool]:
    return {item: check_func(item) for item in items}

def print_table(results: Dict[str, bool], title: str):
    print(f"\n{title}")
    print("-" * len(title))
    for item, status in results.items():
        status_str = "OK" if status else "FALHA"
        print(f"{item:35} {status_str}")

def output_json(commands: Dict[str, bool], paths: Dict[str, bool]):
    output = {
        "commands": commands,
        "paths": paths
    }
    print(json.dumps(output, indent=2))

# ------------------------------------------------------------------------------
# Função principal
# ------------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(
        description="Verificador de comandos e caminhos do TA-nix (Splunk Add-on)"
    )
    parser.add_argument(
        '--output',
        choices=['text', 'json'],
        default='text',
        help='Formato da saída (padrão: text)'
    )

    args = parser.parse_args()

    logging.info("Iniciando verificação...")

    commands_status = check_all(commands_expected, check_command_exists)
    paths_status = check_all(paths_expected, check_path_exists)

    if args.output == 'json':
        output_json(commands_status, paths_status)
    else:
        print_table(commands_status, "Verificação de Comandos")
        print_table(paths_status, "Verificação de Caminhos")

    logging.info("Verificação concluída.")

# ------------------------------------------------------------------------------
# Proteção padrão
# ------------------------------------------------------------------------------
if __name__ == '__main__':
    main()
