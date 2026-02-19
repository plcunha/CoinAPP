import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';

/// Estados do validador de carteiras
abstract class WalletValidatorState {
  const WalletValidatorState();
}

class ValidatorInitial extends WalletValidatorState {
  const ValidatorInitial();
}

class ValidatorLoading extends WalletValidatorState {
  const ValidatorLoading();
}

class ValidationSuccess extends WalletValidatorState {
  final ValidationResult result;
  final Wallet? walletInfo;

  const ValidationSuccess({
    required this.result,
    this.walletInfo,
  });
}

class ValidationError extends WalletValidatorState {
  final String message;

  const ValidationError(this.message);
}

class WalletInfoLoading extends WalletValidatorState {
  const WalletInfoLoading();
}

class WalletInfoLoaded extends WalletValidatorState {
  final Wallet wallet;

  const WalletInfoLoaded(this.wallet);
}

/// ViewModel para validação de carteiras
class WalletValidatorViewModel extends ChangeNotifier {
  final WalletRepository repository;

  WalletValidatorViewModel({required this.repository});

  WalletValidatorState _state = const ValidatorInitial();
  WalletValidatorState get state => _state;

  String _selectedBlockchain = 'bitcoin';
  String get selectedBlockchain => _selectedBlockchain;

  List<String> _supportedBlockchains = [
    'bitcoin',
    'ethereum',
    'litecoin',
    'bitcoin_cash',
    'dogecoin',
  ];
  List<String> get supportedBlockchains => _supportedBlockchains;

  void selectBlockchain(String blockchain) {
    _selectedBlockchain = blockchain;
    notifyListeners();
  }

  Future<void> validateAddress(String address) async {
    if (address.trim().isEmpty) {
      _state = const ValidationError('Por favor, insira um endereço');
      notifyListeners();
      return;
    }

    _state = const ValidatorLoading();
    notifyListeners();

    final result = await repository.validateAddress(
      address.trim(),
      _selectedBlockchain,
    );

    result.fold(
      (failure) {
        _state = ValidationError(failure.message);
        notifyListeners();
      },
      (validationResult) async {
        Wallet? walletInfo;
        
        // Se válido, buscar informações adicionais
        if (validationResult.isValid) {
          _state = const WalletInfoLoading();
          notifyListeners();

          final walletResult = await repository.getWalletInfo(
            address.trim(),
            _selectedBlockchain,
          );

          walletResult.fold(
            (failure) {
              // Não falhar se não conseguir buscar informações
              _state = ValidationSuccess(
                result: validationResult,
                walletInfo: null,
              );
            },
            (wallet) {
              walletInfo = wallet;
              _state = WalletInfoLoaded(wallet);
            },
          );
        } else {
          _state = ValidationSuccess(
            result: validationResult,
            walletInfo: null,
          );
        }

        notifyListeners();
      },
    );
  }

  Future<void> fetchWalletInfo(String address, String blockchain) async {
    _state = const WalletInfoLoading();
    notifyListeners();

    final result = await repository.getWalletInfo(
      address.trim(),
      blockchain,
    );

    result.fold(
      (failure) {
        _state = ValidationError(failure.message);
        notifyListeners();
      },
      (wallet) {
        _state = WalletInfoLoaded(wallet);
        notifyListeners();
      },
    );
  }

  void reset() {
    _state = const ValidatorInitial();
    notifyListeners();
  }
}
