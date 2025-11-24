# Evolution API v2.3.6 - Fix Notificações WhatsApp 🔔

<div align="center">

[![Docker Hub](https://img.shields.io/badge/Docker%20Hub-heliomenezes%2Fevolution--api-blue?logo=docker)](https://hub.docker.com/r/heliomenezes/evolution-api)
[![Version](https://img.shields.io/badge/version-2.3.6--fix--notifications-green)](https://github.com/helioneto144/EvolutionApi-FIX/releases)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue)](LICENSE)
[![Evolution API](https://img.shields.io/badge/Evolution%20API-v2.3.6-orange)](https://github.com/EvolutionAPI/evolution-api)
[![Issue](https://img.shields.io/badge/Fix-Issue%20%23512-success)](https://github.com/EvolutionAPI/evolution-api/issues/512)

</div>

<div align="center"><img src="./public/images/cover.png"></div>

## 🎯 Sobre Este Fork

Este é um fork customizado do **Evolution API v2.3.6** com correção aplicada para resolver o problema de **som de notificações do WhatsApp** que param de funcionar após conectar uma sessão via API.

**Issue Original**: [EvolutionAPI/evolution-api#512](https://github.com/EvolutionAPI/evolution-api/issues/512)

## ✨ Problema Resolvido

Quando uma sessão do WhatsApp é conectada via Evolution API, o som das notificações para de funcionar no celular, mesmo com a configuração `alwaysOnline: false`. Esta versão implementa a correção sugerida pela comunidade.

### Correção Aplicada

- ✅ **Atualização automática de presença** para "unavailable" a cada 5 minutos
- ✅ **Presença após envio** definida como "unavailable" após cada mensagem enviada
- ✅ **Respeita configuração** `alwaysOnline` da instância
- ✅ **Limpeza de intervalos** em caso de reconexão (evita memory leaks)

**Baseado em**: [Comentário #3140336013](https://github.com/EvolutionAPI/evolution-api/issues/512#issuecomment-3140336013) por [@jlenon7](https://github.com/jlenon7)

## 🚀 Uso Rápido

### Docker Hub (Recomendado)

```bash
# Última versão com correção
docker pull heliomenezes/evolution-api:latest

# Versão específica
docker pull heliomenezes/evolution-api:2.3.6-fix-notifications
```

### Docker Run

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
  heliomenezes/evolution-api:latest
```

### Docker Compose

```bash
# Use o arquivo fornecido
docker-compose -f docker-compose.easypanel.yml up -d
```

## 📋 Configuração Importante

Para que a correção funcione, configure a instância com `alwaysOnline: false`:

```bash
curl -X POST http://localhost:8080/instance/settings/sua-instancia \
  -H "apikey: SUA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "alwaysOnline": false
  }'
```

## 🔧 Mudanças no Código

### Arquivo Modificado

**`src/api/integrations/channel/whatsapp/whatsapp.baileys.service.ts`**

**1. Nova propriedade** para controle do intervalo:
```typescript
private presenceIntervalId: any = null;
```

**2. Intervalo de atualização** (a cada 5 minutos):
```typescript
this.presenceIntervalId = setInterval(() => {
  if (!this.localSettings.alwaysOnline) {
    this.setPresence({ presence: 'unavailable' });
  }
}, 300000);
```

**3. Presença após envio de mensagem**:
```typescript
if (!this.localSettings.alwaysOnline) {
  await this.client.sendPresenceUpdate('unavailable');
}
```

## 📚 Documentação Completa

- **[PUBLICACAO_CONCLUIDA.md](PUBLICACAO_CONCLUIDA.md)** - Guia completo de uso e deploy
- **[QUICKSTART.md](QUICKSTART.md)** - Início rápido
- **[DOCKER_BUILD.md](DOCKER_BUILD.md)** - Build e deploy detalhado
- **[COMO_PROCEDER.md](COMO_PROCEDER.md)** - Próximos passos
- **[README_CUSTOM.md](README_CUSTOM.md)** - Visão geral do projeto customizado
- **[RESUMO_IMPLEMENTACAO.md](RESUMO_IMPLEMENTACAO.md)** - Resumo técnico

## 🐳 Docker Hub

**Repositório**: [heliomenezes/evolution-api](https://hub.docker.com/r/heliomenezes/evolution-api)

**Tags disponíveis**:
- `latest` - Última versão com correção
- `2.3.6-fix-notifications` - Versão específica

**Digest**: `sha256:3be59ddd289300594df74d4d2a168f155151f479fd704420453091cdb2850ca5`

## 📦 Versão Base

- **Evolution API**: v2.3.6
- **Node.js**: 24-alpine
- **Correção**: Issue #512 aplicada

## 🛠️ Build Local

```bash
# Clone o repositório
git clone https://github.com/helioneto144/EvolutionApi-FIX.git
cd EvolutionApi-FIX

# Build da imagem
docker build -t evolution-api:local .

# Ou use o script automatizado
chmod +x build-and-push.sh
./build-and-push.sh
```

## 🤝 Créditos

- **Evolution API**: [EvolutionAPI/evolution-api](https://github.com/EvolutionAPI/evolution-api)
- **Correção original**: [@jlenon7](https://github.com/jlenon7)
- **Issue**: [#512](https://github.com/EvolutionAPI/evolution-api/issues/512)
- **Desenvolvido por**: [Helio Neto](https://github.com/helioneto144)

## 🆘 Suporte

- **Issues deste fork**: [GitHub Issues](https://github.com/helioneto144/EvolutionApi-FIX/issues)
- **Evolution API Docs**: https://doc.evolution-api.com/
- **Discord**: https://evolution-api.com/discord
- **WhatsApp Group**: https://evolution-api.com/whatsapp

## 📄 Licença

Este projeto mantém a mesma licença do Evolution API original: **Apache License 2.0**

---

## 📖 Sobre o Evolution API Original

Evolution API began as a WhatsApp controller API based on [CodeChat](https://github.com/code-chat-br/whatsapp-api), which in turn implemented the [Baileys](https://github.com/WhiskeySockets/Baileys) library. While originally focused on WhatsApp, Evolution API has grown into a comprehensive platform supporting multiple messaging services and integrations.

Today, Evolution API is not limited to WhatsApp. It integrates with various platforms such as Typebot, Chatwoot, Dify, and OpenAI, offering a broad array of functionalities beyond messaging. Evolution API supports both the Baileys-based WhatsApp API and the official WhatsApp Business API, with upcoming support for Instagram and Messenger.

## Looking for a Lightweight Version?
For those who need a more streamlined and performance-optimized version, check out [Evolution API Lite](https://github.com/EvolutionAPI/evolution-api-lite). It's designed specifically for microservices, focusing solely on connectivity without integrations or audio conversion features. Ideal for environments that prioritize simplicity and efficiency.

## Types of Connections

Evolution API supports multiple types of connections to WhatsApp, enabling flexible and powerful integration options:

- *WhatsApp API - Baileys*:
  - A free API based on WhatsApp Web, leveraging the [Baileys library](https://github.com/WhiskeySockets/Baileys).
  - This connection type allows control over WhatsApp Web functionalities through a RESTful API, suitable for multi-service chats, service bots, and other WhatsApp-integrated systems.
  - Note: This method relies on the web version of WhatsApp and may have limitations compared to official APIs.

- *WhatsApp Cloud API*:
  - The official API provided by Meta (formerly Facebook).
  - This connection type offers a robust and reliable solution designed for businesses needing higher volumes of messaging and better integration support.
  - The Cloud API supports features such as end-to-end encryption, advanced analytics, and more comprehensive customer service tools.
  - To use this API, you must comply with Meta's policies and potentially pay for usage based on message volume and other factors.

## Integrations

Evolution API supports various integrations to enhance its functionality. Below is a list of available integrations and their uses:

- [Typebot](https://typebot.io/):
  - Build conversational bots using Typebot, integrated directly into Evolution with trigger management.

- [Chatwoot](https://www.chatwoot.com/):
  - Direct integration with Chatwoot for handling customer service for your business.

- [RabbitMQ](https://www.rabbitmq.com/):
  - Receive events from the Evolution API via RabbitMQ.

- [Apache Kafka](https://kafka.apache.org/):
  - Receive events from the Evolution API via Apache Kafka for real-time event streaming and processing.

- [Amazon SQS](https://aws.amazon.com/pt/sqs/):
  - Receive events from the Evolution API via Amazon SQS.

- [Socket.io](https://socket.io/):
  - Receive events from the Evolution API via WebSocket.

- [Dify](https://dify.ai/):
  - Integrate your Evolution API directly with Dify AI for seamless trigger management and multiple agents.

- [OpenAI](https://openai.com/):
  - Integrate your Evolution API with OpenAI for AI capabilities, including audio-to-text conversion, available across all Evolution integrations.

- Amazon S3 / Minio:
  - Store media files received in [Amazon S3](https://aws.amazon.com/pt/s3/) or [Minio](https://min.io/).

## Community & Feedback

We value community input and feedback to continuously improve Evolution API:

### 🚀 Feature Requests & Roadmap
- **[Feature Requests](https://evolutionapi.canny.io/feature-requests)**: Submit new feature ideas and vote on community proposals
- **[Roadmap](https://evolutionapi.canny.io/feature-requests)**: View planned features and development progress
- **[Changelog](https://evolutionapi.canny.io/changelog)**: Stay updated with the latest releases and improvements

### 💬 Community Support
- **[WhatsApp Group](https://evolution-api.com/whatsapp)**: Join our community for support and discussions
- **[Discord Community](https://evolution-api.com/discord)**: Real-time chat with developers and users
- **[GitHub Issues](https://github.com/EvolutionAPI/evolution-api/issues)**: Report bugs and technical issues

### 🔒 Security
- **[Security Policy](./SECURITY.md)**: Guidelines for reporting security vulnerabilities
- **Security Contact**: contato@evolution-api.com

## Telemetry Notice

To continuously improve our services, we have implemented telemetry that collects data on the routes used, the most accessed routes, and the version of the API in use. We would like to assure you that no sensitive or personal data is collected during this process. The telemetry helps us identify improvements and provide a better experience for users.

## Evolution Support Premium

Join our Evolution Pro community for expert support and a weekly call to answer questions. Visit the link below to learn more and subscribe:

[Click here to learn more](https://evolution-api.com/suporte-pro)

# Donate to the project.

#### Github Sponsors

https://github.com/sponsors/EvolutionAPI

# Content Creator Partners

We are proud to collaborate with the following content creators who have contributed valuable insights and tutorials about Evolution API:

- [Promovaweb](https://www.youtube.com/@promovaweb)
- [Sandeco](https://www.youtube.com/@canalsandeco)
- [Comunidade ZDG](https://www.youtube.com/@ComunidadeZDG)
- [Francis MNO](https://www.youtube.com/@FrancisMNO)
- [Pablo Cabral](https://youtube.com/@pablocabral)
- [XPop Digital](https://www.youtube.com/@xpopdigital)
- [Costar Wagner Dev](https://www.youtube.com/@costarwagnerdev)
- [Dante Testa](https://youtube.com/@dantetesta_)
- [Rubén Salazar](https://youtube.com/channel/UCnYGZIE2riiLqaN9sI6riig)
- [OrionDesign](youtube.com/OrionDesign_Oficial)
- [IMPA 365](youtube.com/@impa365_ofc)
- [Comunidade Hub Connect](https://youtube.com/@comunidadehubconnect)
- [dSantana Automações](https://www.youtube.com/channel/UCG7DjUmAxtYyURlOGAIryNQ?view_as=subscriber)
- [Edison Martins](https://www.youtube.com/@edisonmartinsmkt)
- [Astra Online](https://www.youtube.com/@astraonlineweb)
- [MKT Seven Automações](https://www.youtube.com/@sevenautomacoes)
- [Vamos automatizar](https://www.youtube.com/vamosautomatizar)

## License

Evolution API is licensed under the Apache License 2.0, with the following additional conditions:

1. **LOGO and copyright information**: In the process of using Evolution API's frontend components, you may not remove or modify the LOGO or copyright information in the Evolution API console or applications. This restriction is inapplicable to uses of Evolution API that do not involve its frontend components.

2. **Usage Notification Requirement**: If Evolution API is used as part of any project, including closed-source systems (e.g., proprietary software), the user is required to display a clear notification within the system that Evolution API is being utilized. This notification should be visible to system administrators and accessible from the system's documentation or settings page. Failure to comply with this requirement may result in the necessity for a commercial license, as determined by the producer.

Please contact contato@evolution-api.com to inquire about licensing matters.

Apart from the specific conditions mentioned above, all other rights and restrictions follow the Apache License 2.0. Detailed information about the Apache License 2.0 can be found at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).

© 2025 Evolution API
