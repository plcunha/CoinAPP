# 📱 CoinAPP

Aplicativo Flutter para acompanhamento de criptomoedas em tempo real, com preços em USD e BRL, variação percentual de 24h e detalhes completos.

## 🚀 Requisitos

- Flutter instalado na máquina (SDK ^3.5.0)
- Dispositivo ou emulador configurado para execução
- Chave de API do [CoinMarketCap](https://coinmarketcap.com/api/)

## 🔑 Configuração da API Key

Este app utiliza a API do CoinMarketCap. A chave de API deve ser fornecida de forma segura via `--dart-define`, **nunca** deve ser inserida diretamente no código-fonte.

1. Crie uma conta gratuita em [CoinMarketCap](https://coinmarketcap.com/api/)
2. Obtenha sua chave de API no painel do desenvolvedor

## 🔧 Como executar

```bash
flutter pub get
flutter run --dart-define=CMC_API_KEY=sua_chave_aqui
```

Esses comandos irão:

- Baixar todas as dependências do projeto (`flutter pub get`)
- Iniciar o aplicativo com a API key configurada de forma segura

## 🧪 Testes

```bash
flutter test
```

## 📁 Arquitetura

O projeto utiliza o padrão **MVVM** (Model-View-ViewModel):

- `lib/model/` — Modelos de dados (Crypto)
- `lib/data/` — Fonte de dados da API (CoinMarketCap)
- `lib/repository/` — Repositório para acesso a dados
- `lib/viewmodel/` — ViewModels com gerenciamento de estado (Provider)
- `lib/view/` — Widgets e telas da interface
