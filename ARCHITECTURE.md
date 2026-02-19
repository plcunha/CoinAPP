# Documentação da Arquitetura CoinWallet Validator

## Visão Geral

O CoinWallet Validator é um aplicativo Flutter que implementa **Clean Architecture** para validação e verificação de carteiras de criptomoedas.

## Arquitetura em Camadas

### 1. Core Layer
Localização: `lib/core/`

Responsabilidade: Configurações, temas, erros e utilitários compartilhados.

#### Arquivos:
- **app_constants.dart**: Constantes da aplicação
  - APIs blockchain
  - Configurações de timeout
  - Blockchains suportadas
  - Chaves de storage

- **exceptions.dart**: Tratamento de erros
  - Exceções customizadas (AppException, NetworkException, etc.)
  - Failures para camada de domínio

- **app_theme.dart**: Sistema de design
  - Cores (primary, success, error, etc.)
  - Gradientes
  - Temas claro/escuro
  - TextTheme com Google Fonts

- **wallet_validation_service.dart**: Serviço de validação
  - Validação Base58Check
  - Validação Bech32
  - Validação EIP-55 (Ethereum)
  - Detecção automática de blockchain

### 2. Domain Layer
Localização: `lib/domain/`

Responsabilidade: Regras de negócio e entidades.

#### Entidades:
- **Wallet**: Representa uma carteira
  - address, blockchain, balance
  - transactionCount, validationStatus
  - Método copyWith para imutabilidade

- **Blockchain**: Representa uma blockchain suportada
  - id, name, symbol, color
  - addressPrefixes, isEnabled

- **ValidationResult**: Resultado de uma validação
  - isValid, errorMessage, details

- **Transaction**: Representa uma transação
  - hash, amount, confirmations
  - fromAddress, toAddress

#### Repositórios (Interfaces):
- **wallet_repository.dart**: Contrato para operações de carteira

### 3. Data Layer
Localização: `lib/data/`

Responsabilidade: Implementação de acesso a dados.

#### Datasources:
- **blockchain_remote_datasource.dart**: APIs blockchain
  - BlockchainRemoteDataSource (interface)
  - BlockchainRemoteDataSourceImpl (implementação)
  - Integrações: Blockchain.info, Etherscan, BlockCypher, BlockChair

- **local_cache_datasource.dart**: Cache local
  - LocalCacheDataSource (interface)
  - LocalCacheDataSourceImpl (SharedPreferences)

#### Modelos:
- **wallet_model.dart**: Modelos de dados
  - WalletModel: conversão Entity ↔ JSON
  - BlockchainModel
  - ValidationResultModel

#### Repositórios:
- **wallet_repository_impl.dart**: Implementação do repositório
  - Integração de múltiplas datasources
  - Tratamento de erros
  - Cache

### 4. Presentation Layer
Localização: `lib/presentation/`

Responsabilidade: Interface do usuário.

#### ViewModels:
- **dashboard_viewmodel.dart**: Estado do dashboard
  - Estados: DashboardInitial, Loading, Loaded, Error
  - Gerenciamento de favoritos
  - Estatísticas

- **wallet_validator_viewmodel.dart**: Validação de carteiras
  - Estados: ValidatorInitial, Loading, Success, Error
  - Seleção de blockchain
  - Validação de endereços

- **history_viewmodel.dart**: Histórico de validações
  - Filtros por blockchain
  - Busca por endereço
  - Gerenciamento de lista

#### Views:
- **main_screen.dart**: Navegação principal
- **dashboard/dashboard_screen.dart**: Tela inicial com estatísticas
- **validator/validator_screen.dart**: Tela de validação
- **history/history_screen.dart**: Histórico com filtros

#### Componentes Compartilhados:
- **wallet_card.dart**: Card de exibição de carteira
- **wallet_validation_result.dart**: Exibição de resultado
- **empty_state.dart**: Estado vazio
- **shimmer_loading.dart**: Efeito de loading

## Fluxo de Dados

```
UI (View) 
  ↓ (chama)
ViewModel 
  ↓ (usa)
Repository (Interface)
  ↓ (implementa)
RepositoryImpl
  ↓ (usa)
DataSource (Remote/Local)
  ↓ (acessa)
API / Cache
```

## Gerenciamento de Estado

Usamos **Provider** para gerenciamento de estado:

```dart
MultiProvider(
  providers: [
    Provider<WalletRepository>(...),
    ChangeNotifierProvider<DashboardViewModel>(...),
    ChangeNotifierProvider<WalletValidatorViewModel>(...),
    ChangeNotifierProvider<HistoryViewModel>(...),
  ],
)
```

## Tratamento de Erros

Usamos **dartz** para programação funcional:

```dart
Future<Either<Failure, Wallet>> getWalletInfo(...)

result.fold(
  (failure) => // tratar erro
  (wallet) => // usar dados
)
```

## Validação de Endereços

### Bitcoin
- P2PKH (começa com 1)
- P2SH (começa com 3)
- Bech32/SegWit (começa com bc1)

### Ethereum
- Formato: 0x + 40 caracteres hex
- Checksum EIP-55 opcional

### Litecoin
- Legacy (começa com L)
- P2SH (começa com M)
- Bech32 (começa com ltc1)

### Bitcoin Cash
- CashAddr (bitcoincash:)
- Formato legado (1 ou 3)
- Sem prefixo (q ou p)

### Dogecoin
- Formato D
- Comprimento: 26-34 caracteres

## APIs Utilizadas

| Blockchain | API | Endpoint |
|------------|-----|----------|
| Bitcoin | Blockchain.info | /rawaddr/{address} |
| Ethereum | Etherscan | /api?module=account |
| Litecoin | BlockCypher | /v1/ltc/main/addrs/{address} |
| Bitcoin Cash | BlockChair | /dashboards/address/{address} |
| Dogecoin | BlockCypher | /v1/doge/main/addrs/{address} |

## Dependências Principais

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.2
  
  # Network
  dio: ^5.7.0
  http: ^1.2.2
  
  # Crypto
  crypto: ^3.0.5
  base58check: ^2.0.0
  bech32: ^0.2.2
  
  # Storage
  shared_preferences: ^2.3.3
  
  # UI
  shimmer: ^3.0.0
  font_awesome_flutter: ^10.8.0
  google_fonts: ^6.2.1
  
  # Utils
  dartz: ^0.10.1
  equatable: ^2.0.5
```

## Convenções de Código

### Nomenclatura
- Classes: PascalCase (WalletValidationService)
- Métodos/variáveis: camelCase (validateAddress)
- Constantes: SCREAMING_SNAKE_CASE (API_TIMEOUT)
- Arquivos: snake_case (wallet_validation_service.dart)

### Organização de Imports
```dart
// Dart/Flutter
import 'dart:convert';
import 'package:flutter/material.dart';

// Packages externos
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

// Internos (relativos)
import '../core/theme/app_theme.dart';
import '../../domain/entities/wallet.dart';
```

## Testes

### Estrutura de Testes
```
test/
├── core/
│   └── utils/
│       └── wallet_validation_service_test.dart
├── data/
│   ├── datasources/
│   └── repositories/
└── presentation/
    └── viewmodels/
```

### Tipos de Testes
1. **Unit Tests**: Testes de lógica isolada
2. **Widget Tests**: Testes de componentes UI
3. **Integration Tests**: Testes de fluxos completos

## Segurança

### Boas Práticas
- Nunca armazenar chaves privadas
- Validar todos os inputs
- Usar HTTPS para todas as APIs
- Sanitizar dados antes de exibir

## Performance

### Otimizações
- Cache de requisições API
- Lazy loading de listas
- Shimmer effects durante loading
- Debounce em campos de busca

## Internacionalização

Futura implementação:
- Suporte a múltiplos idiomas (i18n)
- Formatação de moedas localizada
- Datas no formato local

## Conclusão

Esta arquitetura proporciona:
- ✅ Separação de responsabilidades
- ✅ Testabilidade
- ✅ Escalabilidade
- ✅ Manutenibilidade
- ✅ Reutilização de código
