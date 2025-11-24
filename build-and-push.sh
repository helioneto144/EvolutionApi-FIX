#!/bin/bash

# Script para build e push da imagem Docker customizada do Evolution API
# Com correção do issue #512 (som de notificações)

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variáveis
VERSION="2.3.6-fix-notifications"
IMAGE_NAME="evolution-api"

# Função para exibir mensagens
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    log_error "Docker não está instalado. Por favor, instale o Docker primeiro."
    exit 1
fi

# Solicitar nome de usuário do Docker Hub
echo ""
read -p "Digite seu nome de usuário do Docker Hub: " DOCKER_USERNAME

if [ -z "$DOCKER_USERNAME" ]; then
    log_error "Nome de usuário não pode ser vazio!"
    exit 1
fi

# Confirmar ação
echo ""
log_warn "Você está prestes a:"
echo "  1. Fazer build da imagem: ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}"
echo "  2. Fazer push para o Docker Hub"
echo ""
read -p "Deseja continuar? (s/N): " CONFIRM

if [[ ! "$CONFIRM" =~ ^[sS]$ ]]; then
    log_info "Operação cancelada."
    exit 0
fi

# Login no Docker Hub
log_info "Fazendo login no Docker Hub..."
docker login

if [ $? -ne 0 ]; then
    log_error "Falha no login do Docker Hub!"
    exit 1
fi

# Escolher tipo de build
echo ""
log_info "Escolha o tipo de build:"
echo "  1. Build simples (arquitetura atual)"
echo "  2. Build multi-arquitetura (AMD64 + ARM64) - Recomendado"
echo ""
read -p "Opção (1/2): " BUILD_TYPE

if [ "$BUILD_TYPE" == "2" ]; then
    # Build multi-arquitetura
    log_info "Criando builder multi-plataforma..."
    docker buildx create --name multiarch --use 2>/dev/null || docker buildx use multiarch
    
    log_info "Iniciando build multi-arquitetura..."
    docker buildx build \
        --platform linux/amd64,linux/arm64 \
        --tag ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION} \
        --tag ${DOCKER_USERNAME}/${IMAGE_NAME}:latest \
        --push \
        .
    
    if [ $? -eq 0 ]; then
        log_info "✓ Build e push multi-arquitetura concluídos com sucesso!"
    else
        log_error "✗ Falha no build multi-arquitetura!"
        exit 1
    fi
else
    # Build simples
    log_info "Iniciando build da imagem..."
    docker build -t ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION} .
    
    if [ $? -ne 0 ]; then
        log_error "✗ Falha no build da imagem!"
        exit 1
    fi
    
    log_info "✓ Build concluído com sucesso!"
    
    # Tag latest
    log_info "Criando tag 'latest'..."
    docker tag ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION} ${DOCKER_USERNAME}/${IMAGE_NAME}:latest
    
    # Push para Docker Hub
    log_info "Fazendo push da imagem para o Docker Hub..."
    docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}
    docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:latest
    
    if [ $? -eq 0 ]; then
        log_info "✓ Push concluído com sucesso!"
    else
        log_error "✗ Falha no push da imagem!"
        exit 1
    fi
fi

# Resumo
echo ""
log_info "=========================================="
log_info "Build e Push concluídos com sucesso!"
log_info "=========================================="
echo ""
echo "Imagens disponíveis:"
echo "  • ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}"
echo "  • ${DOCKER_USERNAME}/${IMAGE_NAME}:latest"
echo ""
echo "Para usar no Docker:"
echo "  docker pull ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}"
echo ""
echo "Para usar no docker-compose.yml:"
echo "  image: ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}"
echo ""
echo "Para usar no Easypanel:"
echo "  1. Acesse seu Easypanel"
echo "  2. Crie um novo serviço Docker"
echo "  3. Use a imagem: ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}"
echo ""
log_info "Documentação completa em: DOCKER_BUILD.md"
echo ""

