# Evolution API - Guia Rápido de Início

## 🎯 Sobre esta Versão

Esta é uma versão customizada do **Evolution API v2.3.6** com a correção aplicada para o **issue #512** - problema de som de notificações do WhatsApp que param de funcionar após conectar uma sessão.

### ✅ Correção Aplicada

O problema ocorria quando uma sessão do WhatsApp era conectada via Evolution API - o som das notificações parava de funcionar no celular, mesmo com `always_online: false`.

**Solução implementada:**
- Atualização automática de presença para "unavailable" a cada 5 minutos
- Definição de presença como "unavailable" após cada mensagem enviada
- Respeita a configuração `alwaysOnline` da instância

## 🚀 Início Rápido

### Opção 1: Build e Publicar no Docker Hub

1. **Clone o repositório (se ainda não fez)**
   ```bash
   cd "/home/helio/Downloads/Evolution API"
   ```

2. **Execute o script de build**
   ```bash
   ./build-and-push.sh
   ```
   
   O script irá:
   - Solicitar seu nome de usuário do Docker Hub
   - Fazer login no Docker Hub
   - Construir a imagem (com opção multi-arquitetura)
   - Publicar no Docker Hub

3. **Aguarde o build completar**
   - Build simples: ~5-10 minutos
   - Build multi-arquitetura: ~10-20 minutos

### Opção 2: Build Local (sem publicar)

```bash
# Build da imagem localmente
docker build -t evolution-api:2.3.6-fix-notifications .

# Testar localmente
docker run -d \
  -p 8080:8080 \
  -e DATABASE_PROVIDER=postgresql \
  -e DATABASE_CONNECTION_URI=postgresql://user:pass@host:5432/db \
  -e AUTHENTICATION_API_KEY=sua-chave-aqui \
  evolution-api:2.3.6-fix-notifications
```

## 📦 Deploy no Easypanel

### Passo 1: Preparar o docker-compose.yml

1. Edite o arquivo `docker-compose.easypanel.yml`
2. Substitua `seu-usuario` pelo seu nome de usuário do Docker Hub
3. Altere as seguintes variáveis:
   - `AUTHENTICATION_API_KEY`: Sua chave API segura
   - `SERVER_URL`: URL do seu domínio
   - `POSTGRES_PASSWORD`: Senha segura para o PostgreSQL

### Passo 2: Deploy no Easypanel

**Método 1: Via Interface Web**

1. Acesse seu Easypanel
2. Crie um novo projeto
3. Adicione um serviço "Docker Compose"
4. Cole o conteúdo do `docker-compose.easypanel.yml` (editado)
5. Clique em "Deploy"

**Método 2: Via CLI**

```bash
# Copie o arquivo para seu servidor
scp docker-compose.easypanel.yml user@seu-servidor:/path/to/deploy/

# SSH no servidor
ssh user@seu-servidor

# Deploy
cd /path/to/deploy/
docker-compose -f docker-compose.easypanel.yml up -d
```

### Passo 3: Verificar o Deploy

```bash
# Ver logs
docker logs -f evolution-api

# Verificar status
docker ps | grep evolution-api

# Testar API
curl http://localhost:8080/
```

## 🔧 Configuração Inicial

### 1. Criar uma Instância

```bash
curl -X POST http://localhost:8080/instance/create \
  -H "apikey: SUA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "instanceName": "minha-instancia",
    "qrcode": true,
    "integration": "WHATSAPP-BAILEYS"
  }'
```

### 2. Conectar ao WhatsApp

```bash
# Obter QR Code
curl http://localhost:8080/instance/connect/minha-instancia \
  -H "apikey: SUA_API_KEY"
```

Escaneie o QR Code com seu WhatsApp.

### 3. Configurar Always Online como False

```bash
curl -X POST http://localhost:8080/instance/settings/minha-instancia \
  -H "apikey: SUA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "alwaysOnline": false
  }'
```

### 4. Testar Notificações

1. Envie uma mensagem para o número conectado
2. Verifique se o som de notificação está funcionando no celular
3. ✅ O som deve funcionar normalmente!

## 📊 Monitoramento

### Verificar Logs de Presença

```bash
# Ver logs relacionados à presença
docker logs evolution-api 2>&1 | grep -i "presence\|unavailable"

# Ver logs em tempo real
docker logs -f evolution-api
```

### Verificar Status da Instância

```bash
curl http://localhost:8080/instance/fetchInstances \
  -H "apikey: SUA_API_KEY"
```

## 🔍 Troubleshooting

### Som ainda não funciona

1. **Verifique a configuração**
   ```bash
   curl http://localhost:8080/instance/settings/minha-instancia \
     -H "apikey: SUA_API_KEY"
   ```
   Confirme que `alwaysOnline: false`

2. **Reinicie a instância**
   ```bash
   curl -X DELETE http://localhost:8080/instance/logout/minha-instancia \
     -H "apikey: SUA_API_KEY"
   
   # Reconecte
   curl http://localhost:8080/instance/connect/minha-instancia \
     -H "apikey: SUA_API_KEY"
   ```

3. **Verifique os logs**
   ```bash
   docker logs evolution-api --tail 100
   ```

### Container não inicia

1. **Verifique variáveis de ambiente**
   ```bash
   docker inspect evolution-api | grep -A 20 Env
   ```

2. **Verifique conexão com banco**
   ```bash
   docker exec -it postgres psql -U evolution -d evolution -c "SELECT 1;"
   ```

3. **Verifique portas**
   ```bash
   netstat -tulpn | grep 8080
   ```

### Erro de conexão com banco de dados

```bash
# Verificar se o PostgreSQL está rodando
docker ps | grep postgres

# Verificar logs do PostgreSQL
docker logs postgres

# Testar conexão
docker exec -it postgres psql -U evolution -d evolution
```

## 📚 Documentação Adicional

- **Documentação completa de build**: [DOCKER_BUILD.md](DOCKER_BUILD.md)
- **Documentação oficial Evolution API**: https://doc.evolution-api.com/
- **Issue #512 (correção aplicada)**: https://github.com/EvolutionAPI/evolution-api/issues/512

## 🆘 Suporte

- **Issues do projeto original**: https://github.com/EvolutionAPI/evolution-api/issues
- **Documentação oficial**: https://doc.evolution-api.com/
- **Discord da comunidade**: https://evolution-api.com/discord

## 📝 Notas Importantes

1. **Segurança**: Sempre altere a `AUTHENTICATION_API_KEY` para uma chave segura
2. **Backup**: Faça backup regular dos volumes Docker (instances, store, postgres_data)
3. **Atualizações**: Esta versão é baseada na v2.3.6 com correção customizada
4. **Produção**: Para produção, considere usar Redis e S3 para melhor performance

## ✨ Próximos Passos

Após o deploy bem-sucedido:

1. Configure webhooks para receber eventos
2. Integre com seu sistema (CRM, chatbot, etc.)
3. Configure backup automático
4. Configure monitoramento (opcional: Prometheus + Grafana)
5. Configure SSL/TLS no Easypanel

## 🎉 Pronto!

Sua Evolution API está rodando com a correção de notificações aplicada!

Para mais informações, consulte a documentação completa em [DOCKER_BUILD.md](DOCKER_BUILD.md).

