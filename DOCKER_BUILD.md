# Evolution API - Build e Deploy Docker

Este documento contém instruções para construir e publicar a imagem Docker customizada do Evolution API com a correção do issue #512 (som de notificações).

## Correção Aplicada

Esta versão inclui a correção para o problema de som de notificações do WhatsApp que param de funcionar após conectar uma sessão. A correção foi baseada no [issue #512](https://github.com/EvolutionAPI/evolution-api/issues/512#issuecomment-3140336013).

### Mudanças implementadas:

1. **Propriedade `presenceIntervalId`**: Adicionada para gerenciar o intervalo de atualização de presença
2. **Intervalo de 5 minutos**: Atualiza a presença para "unavailable" a cada 5 minutos quando `alwaysOnline` está desabilitado
3. **Presença após envio**: Define presença como "unavailable" após cada mensagem enviada

## Build da Imagem Docker

### Pré-requisitos

- Docker instalado
- Conta no Docker Hub (para publicar a imagem)

### Build Local

```bash
# Build da imagem
docker build -t evolution-api:2.3.6-fix-notifications .

# Ou com tag customizada
docker build -t seu-usuario/evolution-api:2.3.6-fix-notifications .
```

### Build Multi-arquitetura (AMD64 e ARM64)

Para criar uma imagem que funcione em diferentes arquiteturas:

```bash
# Criar builder multi-plataforma (apenas uma vez)
docker buildx create --name multiarch --use

# Build e push para Docker Hub
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag seu-usuario/evolution-api:2.3.6-fix-notifications \
  --tag seu-usuario/evolution-api:latest \
  --push \
  .
```

## Publicar no Docker Hub

### 1. Login no Docker Hub

```bash
docker login
```

### 2. Tag da imagem

```bash
docker tag evolution-api:2.3.6-fix-notifications seu-usuario/evolution-api:2.3.6-fix-notifications
docker tag evolution-api:2.3.6-fix-notifications seu-usuario/evolution-api:latest
```

### 3. Push para Docker Hub

```bash
docker push seu-usuario/evolution-api:2.3.6-fix-notifications
docker push seu-usuario/evolution-api:latest
```

## Uso no Easypanel

### Docker Compose

Crie um arquivo `docker-compose.yml`:

```yaml
version: '3.8'

services:
  evolution-api:
    image: seu-usuario/evolution-api:2.3.6-fix-notifications
    container_name: evolution-api
    restart: always
    ports:
      - "8080:8080"
    environment:
      # Database
      - DATABASE_PROVIDER=postgresql
      - DATABASE_CONNECTION_URI=postgresql://user:password@postgres:5432/evolution
      - DATABASE_SAVE_DATA_INSTANCE=true
      - DATABASE_SAVE_DATA_NEW_MESSAGE=true
      - DATABASE_SAVE_MESSAGE_UPDATE=true
      - DATABASE_SAVE_DATA_CONTACTS=true
      - DATABASE_SAVE_DATA_CHATS=true
      
      # Authentication
      - AUTHENTICATION_API_KEY=sua-chave-api-aqui
      
      # Server
      - SERVER_TYPE=http
      - SERVER_PORT=8080
      - SERVER_URL=https://seu-dominio.com
      
      # CORS
      - CORS_ORIGIN=*
      - CORS_METHODS=GET,POST,PUT,DELETE
      - CORS_CREDENTIALS=true
      
      # Log
      - LOG_LEVEL=ERROR
      - LOG_COLOR=true
      - LOG_BAILEYS=false
      
      # Instance
      - DEL_INSTANCE=false
      
      # QR Code
      - QRCODE_LIMIT=30
      - QRCODE_COLOR=#198754
      
      # Webhook
      - WEBHOOK_GLOBAL_URL=
      - WEBHOOK_GLOBAL_ENABLED=false
      - WEBHOOK_GLOBAL_WEBHOOK_BY_EVENTS=false
      
      # Redis (opcional)
      - REDIS_ENABLED=false
      - REDIS_URI=redis://redis:6379
      - REDIS_PREFIX_KEY=evolution
      
      # RabbitMQ (opcional)
      - RABBITMQ_ENABLED=false
      
      # S3 (opcional)
      - S3_ENABLE=false
      
    volumes:
      - evolution_instances:/evolution/instances
      - evolution_store:/evolution/store
    networks:
      - evolution-network
    depends_on:
      - postgres

  postgres:
    image: postgres:15-alpine
    container_name: postgres
    restart: always
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=evolution
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - evolution-network

volumes:
  evolution_instances:
  evolution_store:
  postgres_data:

networks:
  evolution-network:
    driver: bridge
```

### Variáveis de Ambiente Importantes

Para garantir que a correção funcione corretamente:

```bash
# Certifique-se de que always_online está como false (padrão)
# Isso pode ser configurado por instância via API
```

### Deploy no Easypanel

1. Acesse seu Easypanel
2. Crie um novo projeto
3. Adicione um serviço Docker
4. Use a imagem: `seu-usuario/evolution-api:2.3.6-fix-notifications`
5. Configure as variáveis de ambiente necessárias
6. Configure o banco de dados PostgreSQL
7. Deploy!

## Testando a Correção

Após o deploy:

1. Conecte uma instância do WhatsApp
2. Configure `always_online: false` na instância
3. Envie uma mensagem para o número conectado
4. Verifique se o som de notificação está funcionando no celular

## Verificação de Logs

Para verificar se a correção está funcionando:

```bash
# Ver logs do container
docker logs -f evolution-api

# Procurar por mensagens relacionadas à presença
docker logs evolution-api 2>&1 | grep -i "presence\|unavailable"
```

## Troubleshooting

### Som ainda não funciona

1. Verifique se `always_online` está realmente como `false`
2. Reinicie a instância do WhatsApp
3. Verifique os logs para erros

### Container não inicia

1. Verifique as variáveis de ambiente
2. Verifique a conexão com o banco de dados
3. Verifique os logs: `docker logs evolution-api`

## Suporte

Para problemas relacionados à correção, abra uma issue no repositório original:
https://github.com/EvolutionAPI/evolution-api/issues/512

## Licença

Este projeto mantém a mesma licença do Evolution API original.

