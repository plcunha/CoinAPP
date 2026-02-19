# CoinWallet Validator

Sistema profissional de validação e verificação de carteiras de criptomoedas.

## 🚀 Funcionalidades

### ✅ Validação de Endereços
- **Bitcoin (BTC)** - Suporte a P2PKH, P2SH e Bech32 (SegWit)
- **Ethereum (ETH)** - Com verificação de checksum EIP-55
- **Litecoin (LTC)** - Legacy, P2SH e Bech32
- **Bitcoin Cash (BCH)** - Formato CashAddr e legado
- **Dogecoin (DOGE)** - Formato padrão

### 📊 Verificação na Blockchain
- Consulta de saldo em tempo real
- Contagem de transações
- Última atividade
- Informações detalhadas da carteira

### 💎 Interface Profissional
- Design moderno e intuitivo
- Suporte a tema claro e escuro
- Animações suaves
- Componentes reutilizáveis

### 📱 Recursos Adicionais
- Histórico de validações
- Favoritos
- Filtros e busca
- Cópia rápida de endereços

## 🏗️ Arquitetura

O projeto segue a **Clean Architecture** com as seguintes camadas:

```
lib/
├── core/                    # Camada central
│   ├── constants/           # Constantes da aplicação
│   ├── errors/             # Exceções e falhas
│   ├── theme/              # Tema e design system
│   └── utils/              # Utilitários
├── data/                    # Camada de dados
│   ├── datasources/        # Fontes de dados (API, Cache)
│   ├── models/             # Modelos de dados
│   └── repositories/       # Implementações de repositórios
├── domain/                  # Camada de domínio
│   ├── entities/           # Entidades de negócio
│   ├── repositories/       # Interfaces de repositórios
│   └── usecases/           # Casos de uso
└── presentation/            # Camada de apresentação
    ├── viewmodels/         # Gerenciamento de estado
    ├── views/              # Telas
    └── widgets/            # Componentes reutilizáveis
```

## 🛠️ Tecnologias

- **Flutter 3.x** - Framework UI
- **Dart 3.x** - Linguagem
- **Provider** - Gerenciamento de estado
- **Dio** - Cliente HTTP
- **dartz** - Programação funcional
- **font_awesome_flutter** - Ícones
- **shimmer** - Efeitos de loading
- **shared_preferences** - Cache local
- **crypto** - Funções criptográficas
- **base58check** - Validação Base58
- **bech32** - Validação Bech32

## 📦 Instalação

1. **Clone o repositório**
```bash
git clone https://github.com/seu-usuario/coin-wallet-validator.git
cd coin-wallet-validator
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Execute o app**
```bash
flutter run
```

## ⚙️ Configuração

### APIs Blockchain

O app utiliza as seguintes APIs públicas:
- **Blockchain.info** - Bitcoin
- **Etherscan.io** - Ethereum
- **BlockCypher** - Litecoin e Dogecoin
- **BlockChair** - Bitcoin Cash

> ⚠️ Para Ethereum, configure sua chave de API no arquivo `lib/core/constants/app_constants.dart`

## 🧪 Testes

```bash
# Testes unitários
flutter test

# Cobertura de código
flutter test --coverage
```

## 🚀 Build

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## 📝 Licença

Este projeto está licenciado sob a Licença MIT.

---

<p align="center">
  Feito com ❤️ e ☕
</p>
