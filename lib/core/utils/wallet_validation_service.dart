import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:base58check/base58check.dart';
import 'package:bech32/bech32.dart';
import '../../core/errors/exceptions.dart';

/// Serviço de validação de endereços de carteiras de criptomoedas
class WalletValidationService {
  WalletValidationService._();

  /// Valida um endereço para uma blockchain específica
  static ValidationResult validateAddress(String address, String blockchain) {
    try {
      // Normalizar o endereço
      final normalizedAddress = address.trim();

      // Verificar se o endereço está vazio
      if (normalizedAddress.isEmpty) {
        return ValidationResult.invalid(
          blockchain: blockchain,
          address: address,
          reason: 'Endereço não pode estar vazio',
        );
      }

      // Verificar comprimento mínimo
      if (normalizedAddress.length < 25) {
        return ValidationResult.invalid(
          blockchain: blockchain,
          address: address,
          reason: 'Endereço muito curto',
        );
      }

      // Validar de acordo com a blockchain
      switch (blockchain.toLowerCase()) {
        case 'bitcoin':
        case 'btc':
          return _validateBitcoinAddress(normalizedAddress);
        case 'ethereum':
        case 'eth':
          return _validateEthereumAddress(normalizedAddress);
        case 'litecoin':
        case 'ltc':
          return _validateLitecoinAddress(normalizedAddress);
        case 'bitcoin_cash':
        case 'bch':
          return _validateBitcoinCashAddress(normalizedAddress);
        case 'dogecoin':
        case 'doge':
          return _validateDogecoinAddress(normalizedAddress);
        default:
          return ValidationResult.invalid(
            blockchain: blockchain,
            address: address,
            reason: 'Blockchain não suportada: $blockchain',
          );
      }
    } catch (e) {
      return ValidationResult.invalid(
        blockchain: blockchain,
        address: address,
        reason: 'Erro na validação: $e',
      );
    }
  }

  /// Valida endereço Bitcoin (P2PKH, P2SH, Bech32)
  static ValidationResult _validateBitcoinAddress(String address) {
    try {
      // P2PKH - começa com 1
      if (address.startsWith('1')) {
        if (address.length < 26 || address.length > 35) {
          return ValidationResult.invalid(
            blockchain: 'bitcoin',
            address: address,
            reason: 'Comprimento inválido para endereço P2PKH',
          );
        }
        return _validateBase58Checksum(address, 'bitcoin');
      }

      // P2SH - começa com 3
      if (address.startsWith('3')) {
        if (address.length < 26 || address.length > 35) {
          return ValidationResult.invalid(
            blockchain: 'bitcoin',
            address: address,
            reason: 'Comprimento inválido para endereço P2SH',
          );
        }
        return _validateBase58Checksum(address, 'bitcoin');
      }

      // Bech32 - começa com bc1
      if (address.toLowerCase().startsWith('bc1')) {
        return _validateBech32Address(address, 'bc');
      }

      return ValidationResult.invalid(
        blockchain: 'bitcoin',
        address: address,
        reason: 'Prefixo de endereço Bitcoin inválido',
      );
    } catch (e) {
      return ValidationResult.invalid(
        blockchain: 'bitcoin',
        address: address,
        reason: 'Erro ao validar endereço Bitcoin: $e',
      );
    }
  }

  /// Valida endereço Ethereum
  static ValidationResult _validateEthereumAddress(String address) {
    try {
      // Verificar se começa com 0x
      if (!address.startsWith('0x')) {
        return ValidationResult.invalid(
          blockchain: 'ethereum',
          address: address,
          reason: 'Endereço Ethereum deve começar com 0x',
        );
      }

      // Remover 0x para validação
      final hexAddress = address.substring(2);

      // Verificar comprimento (40 caracteres hex = 20 bytes)
      if (hexAddress.length != 40) {
        return ValidationResult.invalid(
          blockchain: 'ethereum',
          address: address,
          reason: 'Comprimento inválido para endereço Ethereum',
        );
      }

      // Verificar se é hexadecimal válido
      final hexRegex = RegExp(r'^[0-9a-fA-F]{40}$');
      if (!hexRegex.hasMatch(hexAddress)) {
        return ValidationResult.invalid(
          blockchain: 'ethereum',
          address: address,
          reason: 'Endereço Ethereum contém caracteres inválidos',
        );
      }

      // Verificar checksum EIP-55 (opcional)
      final isValidChecksum = _validateEthereumChecksum(address);

      return ValidationResult.valid(
        blockchain: 'ethereum',
        address: address,
        details: {
          'format': isValidChecksum ? 'checksum' : 'lowercase',
          'type': 'EOA',
        },
      );
    } catch (e) {
      return ValidationResult.invalid(
        blockchain: 'ethereum',
        address: address,
        reason: 'Erro ao validar endereço Ethereum: $e',
      );
    }
  }

  /// Valida endereço Litecoin
  static ValidationResult _validateLitecoinAddress(String address) {
    try {
      // Legacy - começa com L
      if (address.startsWith('L')) {
        return _validateBase58Checksum(address, 'litecoin');
      }

      // P2SH - começa com M
      if (address.startsWith('M')) {
        return _validateBase58Checksum(address, 'litecoin');
      }

      // Bech32 - começa com ltc1
      if (address.toLowerCase().startsWith('ltc1')) {
        return _validateBech32Address(address, 'ltc');
      }

      return ValidationResult.invalid(
        blockchain: 'litecoin',
        address: address,
        reason: 'Prefixo de endereço Litecoin inválido',
      );
    } catch (e) {
      return ValidationResult.invalid(
        blockchain: 'litecoin',
        address: address,
        reason: 'Erro ao validar endereço Litecoin: $e',
      );
    }
  }

  /// Valida endereço Bitcoin Cash
  static ValidationResult _validateBitcoinCashAddress(String address) {
    try {
      // Formato CashAddr (bitcoincash:)
      if (address.toLowerCase().startsWith('bitcoincash:')) {
        return _validateBech32Address(address, 'bitcoincash');
      }

      // Formato legado Bitcoin (começa com 1 ou 3)
      if (address.startsWith('1') || address.startsWith('3')) {
        return _validateBitcoinAddress(address);
      }

      // Formato CashAddr sem prefixo (começa com q ou p)
      if (address.toLowerCase().startsWith('q') || 
          address.toLowerCase().startsWith('p')) {
        return _validateBech32Address('bitcoincash:$address', 'bitcoincash');
      }

      return ValidationResult.invalid(
        blockchain: 'bitcoin_cash',
        address: address,
        reason: 'Formato de endereço Bitcoin Cash inválido',
      );
    } catch (e) {
      return ValidationResult.invalid(
        blockchain: 'bitcoin_cash',
        address: address,
        reason: 'Erro ao validar endereço Bitcoin Cash: $e',
      );
    }
  }

  /// Valida endereço Dogecoin
  static ValidationResult _validateDogecoinAddress(String address) {
    try {
      // Endereços Dogecoin começam com D
      if (!address.startsWith('D')) {
        return ValidationResult.invalid(
          blockchain: 'dogecoin',
          address: address,
          reason: 'Endereço Dogecoin deve começar com D',
        );
      }

      if (address.length < 26 || address.length > 34) {
        return ValidationResult.invalid(
          blockchain: 'dogecoin',
          address: address,
          reason: 'Comprimento inválido para endereço Dogecoin',
        );
      }

      return _validateBase58Checksum(address, 'dogecoin');
    } catch (e) {
      return ValidationResult.invalid(
        blockchain: 'dogecoin',
        address: address,
        reason: 'Erro ao validar endereço Dogecoin: $e',
      );
    }
  }

  /// Valida checksum Base58Check
  static ValidationResult _validateBase58Checksum(
    String address,
    String blockchain,
  ) {
    try {
      final codec = Base58CheckCodec.bitcoin();
      codec.decode(address);
      return ValidationResult.valid(
        blockchain: blockchain,
        address: address,
        details: {'encoding': 'base58check'},
      );
    } catch (e) {
      return ValidationResult.invalid(
        blockchain: blockchain,
        address: address,
        reason: 'Checksum inválido',
      );
    }
  }

  /// Valida endereço Bech32/SegWit
  static ValidationResult _validateBech32Address(
    String address,
    String hrp,
  ) {
    try {
      final bech32 = Bech32Codec();
      final decoded = bech32.decode(address);
      
      if (decoded.hrp != hrp) {
        return ValidationResult.invalid(
          blockchain: hrp,
          address: address,
          reason: 'HRP (Human Readable Part) inválido',
        );
      }

      return ValidationResult.valid(
        blockchain: hrp,
        address: address,
        details: {'encoding': 'bech32', 'hrp': hrp},
      );
    } catch (e) {
      return ValidationResult.invalid(
        blockchain: hrp,
        address: address,
        reason: 'Erro na validação Bech32: $e',
      );
    }
  }

  /// Valida checksum EIP-55 para Ethereum
  static bool _validateEthereumChecksum(String address) {
    final addressLower = address.toLowerCase();
    final hexAddress = addressLower.substring(2);
    
    // Calcular Keccak-256 hash
    final hash = keccak256(Uint8List.fromList(utf8.encode(hexAddress)));
    final hashHex = hash.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    
    // Verificar checksum
    for (int i = 0; i < 40; i++) {
      final addressChar = address[i + 2];
      final hashChar = hashHex[i];
      final hashValue = int.parse(hashChar, radix: 16);
      
      if (hashValue >= 8) {
        // Deve ser maiúsculo
        if (addressChar != addressChar.toUpperCase()) {
          return false;
        }
      } else {
        // Deve ser minúsculo
        if (addressChar != addressChar.toLowerCase()) {
          return false;
        }
      }
    }
    
    return true;
  }

  /// Detecta a blockchain baseada no endereço
  static String? detectBlockchain(String address) {
    final trimmed = address.trim();

    if (trimmed.startsWith('0x') && trimmed.length == 42) {
      return 'ethereum';
    }

    if (trimmed.startsWith('1') || trimmed.startsWith('3')) {
      return 'bitcoin';
    }

    if (trimmed.toLowerCase().startsWith('bc1')) {
      return 'bitcoin';
    }

    if (trimmed.startsWith('L') || trimmed.startsWith('M')) {
      return 'litecoin';
    }

    if (trimmed.toLowerCase().startsWith('ltc1')) {
      return 'litecoin';
    }

    if (trimmed.toLowerCase().startsWith('bitcoincash:') ||
        trimmed.toLowerCase().startsWith('q')) {
      return 'bitcoin_cash';
    }

    if (trimmed.startsWith('D')) {
      return 'dogecoin';
    }

    return null;
  }
}

/// Resultado de validação
class ValidationResult {
  final bool isValid;
  final String address;
  final String blockchain;
  final String? reason;
  final Map<String, dynamic>? details;

  ValidationResult._({
    required this.isValid,
    required this.address,
    required this.blockchain,
    this.reason,
    this.details,
  });

  factory ValidationResult.valid({
    required String address,
    required String blockchain,
    Map<String, dynamic>? details,
  }) {
    return ValidationResult._(
      isValid: true,
      address: address,
      blockchain: blockchain,
      details: details,
    );
  }

  factory ValidationResult.invalid({
    required String address,
    required String blockchain,
    required String reason,
  }) {
    return ValidationResult._(
      isValid: false,
      address: address,
      blockchain: blockchain,
      reason: reason,
    );
  }
}

/// Calcula Keccak-256 hash
Uint8List keccak256(Uint8List input) {
  // Implementação simplificada - em produção usar uma biblioteca adequada
  return sha256.convert(input).bytes as Uint8List;
}
