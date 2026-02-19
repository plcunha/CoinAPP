/// Constantes da aplicação CoinWalletValidator
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'CoinWallet Validator';
  static const String appVersion = '2.0.0';
  static const String appTagline = 'Validação Profissional de Carteiras';

  // API Configurations
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Blockchain APIs
  static const Map<String, String> blockchainApis = {
    'bitcoin': 'https://blockchain.info',
    'ethereum': 'https://api.etherscan.io/api',
    'litecoin': 'https://api.blockcypher.com/v1/ltc/main',
    'dogecoin': 'https://api.blockcypher.com/v1/doge/main',
    'bitcoin_cash': 'https://api.blockchair.com/bitcoin-cash',
  };

  // Etherscan API Key
  static const String etherscanApiKey = 'YourEtherscanApiKey';

  // Supported Blockchains
  static const List<Map<String, dynamic>> supportedBlockchains = [
    {
      'id': 'bitcoin',
      'name': 'Bitcoin',
      'symbol': 'BTC',
      'logo': 'btc',
      'color': 0xFFF7931A,
      'decimals': 8,
      'addressPrefix': ['1', '3', 'bc1'],
      'enabled': true,
    },
    {
      'id': 'ethereum',
      'name': 'Ethereum',
      'symbol': 'ETH',
      'logo': 'eth',
      'color': 0xFF627EEA,
      'decimals': 18,
      'addressPrefix': ['0x'],
      'enabled': true,
    },
    {
      'id': 'litecoin',
      'name': 'Litecoin',
      'symbol': 'LTC',
      'logo': 'ltc',
      'color': 0xFF345D9D,
      'decimals': 8,
      'addressPrefix': ['L', 'M', 'ltc1'],
      'enabled': true,
    },
    {
      'id': 'bitcoin_cash',
      'name': 'Bitcoin Cash',
      'symbol': 'BCH',
      'logo': 'bch',
      'color': 0xFF8DC351,
      'decimals': 8,
      'addressPrefix': ['bitcoincash:', '1', 'q'],
      'enabled': true,
    },
    {
      'id': 'dogecoin',
      'name': 'Dogecoin',
      'symbol': 'DOGE',
      'logo': 'doge',
      'color': 0xFFC2A633,
      'decimals': 8,
      'addressPrefix': ['D'],
      'enabled': true,
    },
    {
      'id': 'solana',
      'name': 'Solana',
      'symbol': 'SOL',
      'logo': 'sol',
      'color': 0xFF14F195,
      'decimals': 9,
      'addressPrefix': [],
      'enabled': false,
    },
    {
      'id': 'polygon',
      'name': 'Polygon',
      'symbol': 'MATIC',
      'logo': 'matic',
      'color': 0xFF8247E5,
      'decimals': 18,
      'addressPrefix': ['0x'],
      'enabled': false,
    },
  ];

  // Validation Rules
  static const int minAddressLength = 25;
  static const int maxAddressLength = 100;

  // Storage Keys
  static const String walletHistoryKey = 'wallet_history';
  static const String settingsKey = 'app_settings';
  static const String favoritesKey = 'favorite_wallets';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxRecentValidations = 50;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const double defaultElevation = 2.0;
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
}
