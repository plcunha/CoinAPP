import 'package:equatable/equatable.dart';

/// Entidade representando uma carteira de criptomoeda
class Wallet extends Equatable {
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
  final WalletValidationStatus validationStatus;
  final bool isFavorite;
  final Map<String, dynamic>? metadata;

  const Wallet({
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
    this.validationStatus = WalletValidationStatus.pending,
    this.isFavorite = false,
    this.metadata,
  });

  Wallet copyWith({
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
    WalletValidationStatus? validationStatus,
    bool? isFavorite,
    Map<String, dynamic>? metadata,
  }) {
    return Wallet(
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

  @override
  List<Object?> get props => [
        id,
        address,
        blockchain,
        label,
        balance,
        balanceSymbol,
        balanceInUsd,
        transactionCount,
        lastTransactionDate,
        validatedAt,
        validationStatus,
        isFavorite,
      ];
}

/// Status de validação da carteira
enum WalletValidationStatus {
  pending,
  valid,
  invalid,
  validating,
  error,
}

/// Entidade representando uma blockchain suportada
class Blockchain extends Equatable {
  final String id;
  final String name;
  final String symbol;
  final String? logoUrl;
  final int color;
  final int decimals;
  final List<String> addressPrefixes;
  final bool isEnabled;
  final String? explorerUrl;
  final double? minAmount;
  final double? maxAmount;

  const Blockchain({
    required this.id,
    required this.name,
    required this.symbol,
    this.logoUrl,
    required this.color,
    required this.decimals,
    required this.addressPrefixes,
    this.isEnabled = true,
    this.explorerUrl,
    this.minAmount,
    this.maxAmount,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        symbol,
        color,
        decimals,
        addressPrefixes,
        isEnabled,
      ];
}

/// Entidade representando o resultado de uma validação
class ValidationResult extends Equatable {
  final bool isValid;
  final String? errorMessage;
  final String address;
  final String blockchain;
  final DateTime timestamp;
  final Map<String, dynamic>? details;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
    required this.address,
    required this.blockchain,
    required this.timestamp,
    this.details,
  });

  factory ValidationResult.valid({
    required String address,
    required String blockchain,
    Map<String, dynamic>? details,
  }) {
    return ValidationResult(
      isValid: true,
      address: address,
      blockchain: blockchain,
      timestamp: DateTime.now(),
      details: details,
    );
  }

  factory ValidationResult.invalid({
    required String address,
    required String blockchain,
    required String errorMessage,
  }) {
    return ValidationResult(
      isValid: false,
      address: address,
      blockchain: blockchain,
      errorMessage: errorMessage,
      timestamp: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        isValid,
        errorMessage,
        address,
        blockchain,
        timestamp,
        details,
      ];
}

/// Entidade representando uma transação
class Transaction extends Equatable {
  final String id;
  final String walletAddress;
  final String blockchain;
  final String type; // 'incoming' ou 'outgoing'
  final double amount;
  final String symbol;
  final double? amountInUsd;
  final String? fromAddress;
  final String? toAddress;
  final DateTime timestamp;
  final int confirmations;
  final String status; // 'pending', 'confirmed', 'failed'
  final double? fee;
  final String? hash;

  const Transaction({
    required this.id,
    required this.walletAddress,
    required this.blockchain,
    required this.type,
    required this.amount,
    required this.symbol,
    this.amountInUsd,
    this.fromAddress,
    this.toAddress,
    required this.timestamp,
    required this.confirmations,
    required this.status,
    this.fee,
    this.hash,
  });

  @override
  List<Object?> get props => [
        id,
        walletAddress,
        blockchain,
        type,
        amount,
        symbol,
        timestamp,
        confirmations,
        status,
      ];
}
