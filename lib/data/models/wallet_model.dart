import '../../domain/entities/wallet.dart';

/// Modelo de dados para Wallet (camada de dados)
class WalletModel {
  final String id;
  final String address;
  final String blockchain;
  final String? label;
  final double? balance;
  final String? balanceSymbol;
  final double? balanceInUsd;
  final int? transactionCount;
  final DateTime? lastTransactionDate;
  final DateTime? validatedAt;
  final String validationStatus;
  final bool isFavorite;
  final Map<String, dynamic>? metadata;

  WalletModel({
    required this.id,
    required this.address,
    required this.blockchain,
    this.label,
    this.balance,
    this.balanceSymbol,
    this.balanceInUsd,
    this.transactionCount,
    this.lastTransactionDate,
    this.validatedAt,
    this.validationStatus = 'pending',
    this.isFavorite = false,
    this.metadata,
  });

  factory WalletModel.fromEntity(Wallet entity) {
    return WalletModel(
      id: entity.id,
      address: entity.address,
      blockchain: entity.blockchain,
      label: entity.label,
      balance: entity.balance,
      balanceSymbol: entity.balanceSymbol,
      balanceInUsd: entity.balanceInUsd,
      transactionCount: entity.transactionCount,
      lastTransactionDate: entity.lastTransactionDate,
      validatedAt: entity.validatedAt,
      validationStatus: _statusToString(entity.validationStatus),
      isFavorite: entity.isFavorite,
      metadata: entity.metadata,
    );
  }

  Wallet toEntity() {
    return Wallet(
      id: id,
      address: address,
      blockchain: blockchain,
      label: label,
      balance: balance,
      balanceSymbol: balanceSymbol,
      balanceInUsd: balanceInUsd,
      transactionCount: transactionCount,
      lastTransactionDate: lastTransactionDate,
      validatedAt: validatedAt,
      validationStatus: _stringToStatus(validationStatus),
      isFavorite: isFavorite,
      metadata: metadata,
    );
  }

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as String,
      address: json['address'] as String,
      blockchain: json['blockchain'] as String,
      label: json['label'] as String?,
      balance: json['balance'] != null ? (json['balance'] as num).toDouble() : null,
      balanceSymbol: json['balanceSymbol'] as String?,
      balanceInUsd: json['balanceInUsd'] != null ? (json['balanceInUsd'] as num).toDouble() : null,
      transactionCount: json['transactionCount'] as int?,
      lastTransactionDate: json['lastTransactionDate'] != null
          ? DateTime.parse(json['lastTransactionDate'] as String)
          : null,
      validatedAt: json['validatedAt'] != null
          ? DateTime.parse(json['validatedAt'] as String)
          : null,
      validationStatus: json['validationStatus'] as String? ?? 'pending',
      isFavorite: json['isFavorite'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'blockchain': blockchain,
      'label': label,
      'balance': balance,
      'balanceSymbol': balanceSymbol,
      'balanceInUsd': balanceInUsd,
      'transactionCount': transactionCount,
      'lastTransactionDate': lastTransactionDate?.toIso8601String(),
      'validatedAt': validatedAt?.toIso8601String(),
      'validationStatus': validationStatus,
      'isFavorite': isFavorite,
      'metadata': metadata,
    };
  }

  WalletModel copyWith({
    String? id,
    String? address,
    String? blockchain,
    String? label,
    double? balance,
    String? balanceSymbol,
    double? balanceInUsd,
    int? transactionCount,
    DateTime? lastTransactionDate,
    DateTime? validatedAt,
    String? validationStatus,
    bool? isFavorite,
    Map<String, dynamic>? metadata,
  }) {
    return WalletModel(
      id: id ?? this.id,
      address: address ?? this.address,
      blockchain: blockchain ?? this.blockchain,
      label: label ?? this.label,
      balance: balance ?? this.balance,
      balanceSymbol: balanceSymbol ?? this.balanceSymbol,
      balanceInUsd: balanceInUsd ?? this.balanceInUsd,
      transactionCount: transactionCount ?? this.transactionCount,
      lastTransactionDate: lastTransactionDate ?? this.lastTransactionDate,
      validatedAt: validatedAt ?? this.validatedAt,
      validationStatus: validationStatus ?? this.validationStatus,
      isFavorite: isFavorite ?? this.isFavorite,
      metadata: metadata ?? this.metadata,
    );
  }

  static String _statusToString(WalletValidationStatus status) {
    switch (status) {
      case WalletValidationStatus.pending:
        return 'pending';
      case WalletValidationStatus.valid:
        return 'valid';
      case WalletValidationStatus.invalid:
        return 'invalid';
      case WalletValidationStatus.validating:
        return 'validating';
      case WalletValidationStatus.error:
        return 'error';
    }
  }

  static WalletValidationStatus _stringToStatus(String status) {
    switch (status) {
      case 'valid':
        return WalletValidationStatus.valid;
      case 'invalid':
        return WalletValidationStatus.invalid;
      case 'validating':
        return WalletValidationStatus.validating;
      case 'error':
        return WalletValidationStatus.error;
      default:
        return WalletValidationStatus.pending;
    }
  }
}

/// Modelo para Blockchain
class BlockchainModel {
  final String id;
  final String name;
  final String symbol;
  final String? logoUrl;
  final int color;
  final int decimals;
  final List<String> addressPrefixes;
  final bool isEnabled;
  final String? explorerUrl;

  BlockchainModel({
    required this.id,
    required this.name,
    required this.symbol,
    this.logoUrl,
    required this.color,
    required this.decimals,
    required this.addressPrefixes,
    this.isEnabled = true,
    this.explorerUrl,
  });

  factory BlockchainModel.fromJson(Map<String, dynamic> json) {
    return BlockchainModel(
      id: json['id'] as String,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      logoUrl: json['logoUrl'] as String?,
      color: json['color'] as int,
      decimals: json['decimals'] as int,
      addressPrefixes: List<String>.from(json['addressPrefixes'] as List),
      isEnabled: json['isEnabled'] as bool? ?? true,
      explorerUrl: json['explorerUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'logoUrl': logoUrl,
      'color': color,
      'decimals': decimals,
      'addressPrefixes': addressPrefixes,
      'isEnabled': isEnabled,
      'explorerUrl': explorerUrl,
    };
  }

  Blockchain toEntity() {
    return Blockchain(
      id: id,
      name: name,
      symbol: symbol,
      logoUrl: logoUrl,
      color: color,
      decimals: decimals,
      addressPrefixes: addressPrefixes,
      isEnabled: isEnabled,
      explorerUrl: explorerUrl,
    );
  }
}

/// Modelo para resultado de validação
class ValidationResultModel {
  final bool isValid;
  final String? errorMessage;
  final String address;
  final String blockchain;
  final DateTime timestamp;
  final Map<String, dynamic>? details;

  ValidationResultModel({
    required this.isValid,
    this.errorMessage,
    required this.address,
    required this.blockchain,
    required this.timestamp,
    this.details,
  });

  factory ValidationResultModel.fromJson(Map<String, dynamic> json) {
    return ValidationResultModel(
      isValid: json['isValid'] as bool,
      errorMessage: json['errorMessage'] as String?,
      address: json['address'] as String,
      blockchain: json['blockchain'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isValid': isValid,
      'errorMessage': errorMessage,
      'address': address,
      'blockchain': blockchain,
      'timestamp': timestamp.toIso8601String(),
      'details': details,
    };
  }

  ValidationResult toEntity() {
    return ValidationResult(
      isValid: isValid,
      errorMessage: errorMessage,
      address: address,
      blockchain: blockchain,
      timestamp: timestamp,
      details: details,
    );
  }
}
