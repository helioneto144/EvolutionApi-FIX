# Evolution API v2.3.6 - Versão Customizada com Correção de Notificações

[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Node.js](https://img.shields.io/badge/node.js-6DA55F?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org/)
[![TypeScript](https://img.shields.io/badge/typescript-%23007ACC.svg?style=for-the-badge&logo=typescript&logoColor=white)](https://www.typescriptlang.org/)

## 📋 Sobre

Esta é uma versão customizada do **Evolution API v2.3.6** com a correção aplicada para o **[issue #512](https://github.com/EvolutionAPI/evolution-api/issues/512)** - problema onde o som de notificações do WhatsApp para de funcionar após conectar uma sessão via API.

### 🐛 Problema Original

Quando uma sessão do WhatsApp era conectada via Evolution API, o som das notificações parava de funcionar no celular, mesmo com a configuração `always_online: false`. As notificações apareciam, mas sem som.

### ✅ Solução Implementada

A correção foi baseada na [solução proposta por @jlenon7](https://github.com/EvolutionAPI/evolution-api/issues/512#issuecomment-3140336013):

1. **Intervalo de atualização de presença**: A cada 5 minutos, a presença é atualizada para "unavailable" quando `alwaysOnline` está desabilitado
2. **Presença após envio de mensagem**: Após cada mensagem enviada, a presença é definida como "unavailable"
3. **Respeita configuração**: A correção só é aplicada quando `alwaysOnline: false`

### 📝 Mudanças no Código

**Arquivo modificado**: `src/api/integrations/channel/whatsapp/whatsapp.baileys.service.ts`

1. **Nova propriedade** (linha ~250):
   ```typescript
   private presenceIntervalId: any = null;
   ```

2. **Intervalo de atualização** (após linha ~681):
   ```typescript
   /**
    * Limpa o intervalo se já existir. Importante para casos 
    * de reconnect ao WhatsApp.
    */
   if (this.presenceIntervalId) {
     clearInterval(this.presenceIntervalId);
   }

   /**
    * Cria um novo intervalo para atualizar a presença
    * a cada 5 minutos.
    */
   this.presenceIntervalId = setInterval(() => {
     /**
      * Apenas atualiza a presença se a flag alwaysOnline estiver desabilitada.
      */
     if (!this.localSettings.alwaysOnline) {
       this.setPresence({ presence: 'unavailable' });
     }
   }, 300000);
   ```

3. **Presença após envio** (antes do return em sendMessageWithTyping, linha ~2415):
   ```typescript
   // Força presença como unavailable após envio de mensagem para evitar mute das notificações
   if (!this.localSettings.alwaysOnline) {
     try {
       await this.client.sendPresenceUpdate('unavailable');
     } catch (error) {
       this.logger.warn('Erro ao definir presença como unavailable');
     }
   }
   ```

## 🚀 Como Usar

### Opção 1: Usar Imagem Pré-construída (Recomendado)

Se você já publicou a imagem no Docker Hub:

```bash
docker pull seu-usuario/evolution-api:2.3.6-fix-notifications
```

### Opção 2: Build Local

```bash
# Clone este repositório
git clone <seu-repositorio>
cd evolution-api

# Build da imagem
docker build -t evolution-api:2.3.6-fix-notifications .
```

### Opção 3: Build e Publicar no Docker Hub

```bash
# Execute o script automatizado
./build-and-push.sh
```

O script irá:
- Solicitar seu nome de usuário do Docker Hub
- Fazer login
- Construir a imagem (com opção multi-arquitetura)
- Publicar no Docker Hub

## 📦 Deploy

### Docker Compose (Recomendado)

Use o arquivo `docker-compose.easypanel.yml` fornecido:

```bash
# Edite o arquivo e configure suas variáveis
nano docker-compose.easypanel.yml

# Inicie os serviços
docker-compose -f docker-compose.easypanel.yml up -d
```

### Easypanel

1. Acesse seu Easypanel
2. Crie um novo projeto
3. Adicione um serviço "Docker Compose"
4. Cole o conteúdo do `docker-compose.easypanel.yml` (editado)
5. Configure as variáveis de ambiente
6. Deploy!

### Docker Run (Simples)

```bash
docker run -d \
  --name evolution-api \
  -p 8080:8080 \
  -e DATABASE_PROVIDER=postgresql \
  -e DATABASE_CONNECTION_URI=postgresql://user:pass@host:5432/db \
  -e AUTHENTICATION_API_KEY=sua-chave-segura \
  -e SERVER_URL=https://seu-dominio.com \
  -v evolution_instances:/evolution/instances \
  -v evolution_store:/evolution/store \
  seu-usuario/evolution-api:2.3.6-fix-notifications
```

## 🔧 Configuração

### Variáveis de Ambiente Essenciais

```bash
# Database
DATABASE_PROVIDER=postgresql
DATABASE_CONNECTION_URI=postgresql://user:pass@host:5432/db

# Authentication
AUTHENTICATION_API_KEY=sua-chave-segura

# Server
SERVER_URL=https://seu-dominio.com
SERVER_PORT=8080

# Para garantir que a correção funcione
# Certifique-se de configurar alwaysOnline como false na instância
```

### Configurar Instância

```bash
# Criar instância
curl -X POST http://localhost:8080/instance/create \
  -H "apikey: SUA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "instanceName": "minha-instancia",
    "qrcode": true,
    "integration": "WHATSAPP-BAILEYS"
  }'

# Configurar always_online como false
curl -X POST http://localhost:8080/instance/settings/minha-instancia \
  -H "apikey: SUA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "alwaysOnline": false
  }'
```

## ✅ Testando a Correção

1. Conecte uma instância do WhatsApp
2. Configure `alwaysOnline: false`
3. Envie uma mensagem para o número conectado
4. Verifique se o som de notificação está funcionando no celular
5. ✅ O som deve funcionar normalmente!

## 📚 Documentação

- **[QUICKSTART.md](QUICKSTART.md)** - Guia rápido de início
- **[DOCKER_BUILD.md](DOCKER_BUILD.md)** - Documentação completa de build e deploy
- **[Documentação oficial Evolution API](https://doc.evolution-api.com/)** - Documentação completa da API

## 🔍 Troubleshooting

### Som ainda não funciona

```bash
# 1. Verifique a configuração
curl http://localhost:8080/instance/settings/minha-instancia \
  -H "apikey: SUA_API_KEY"

# 2. Verifique os logs
docker logs evolution-api --tail 100

# 3. Reinicie a instância
curl -X DELETE http://localhost:8080/instance/logout/minha-instancia \
  -H "apikey: SUA_API_KEY"
```

### Ver logs de presença

```bash
docker logs evolution-api 2>&1 | grep -i "presence\|unavailable"
```

## 📊 Estrutura do Projeto

```
.
├── src/
│   └── api/
│       └── integrations/
│           └── channel/
│               └── whatsapp/
│                   └── whatsapp.baileys.service.ts  # Arquivo modificado
├── Dockerfile                                        # Dockerfile atualizado
├── docker-compose.easypanel.yml                     # Docker Compose para Easypanel
├── build-and-push.sh                                # Script de build automatizado
├── QUICKSTART.md                                    # Guia rápido
├── DOCKER_BUILD.md                                  # Documentação de build
└── README_CUSTOM.md                                 # Este arquivo
```

## 🤝 Contribuindo

Esta é uma versão customizada baseada no Evolution API oficial. Para contribuir com o projeto original:

- **Repositório oficial**: https://github.com/EvolutionAPI/evolution-api
- **Issue #512**: https://github.com/EvolutionAPI/evolution-api/issues/512

## 📄 Licença

Este projeto mantém a mesma licença do Evolution API original.

## 🙏 Créditos

- **Evolution API**: [Davidson Gomes](https://github.com/DavidsonGomes) e contribuidores
- **Correção do issue #512**: [@jlenon7](https://github.com/jlenon7) e [@Erickjonatthan](https://github.com/Erickjonatthan)
- **Versão customizada**: Baseada nas soluções propostas pela comunidade

## 📞 Suporte

- **Issues do projeto original**: https://github.com/EvolutionAPI/evolution-api/issues
- **Documentação oficial**: https://doc.evolution-api.com/
- **Discord da comunidade**: https://evolution-api.com/discord

---

**Versão**: 2.3.6-fix-notifications  
**Data**: 2025-11-10  
**Status**: ✅ Testado e funcionando

