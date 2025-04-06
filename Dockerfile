FROM ubuntu:22.04

# Instala dependências
RUN apt-get update && apt-get install -y \
    ruby ruby-dev build-essential \
    python3 python3-pip curl wget gnupg \
    dpkg-dev rpm tar && \
    gem install --no-document fpm

# Cria diretório de trabalho
WORKDIR /workspace

# Copia todos os arquivos do projeto
COPY . .

# Define comando padrão
CMD ["bash", "./scripts/build.sh", "1.1.14"]
