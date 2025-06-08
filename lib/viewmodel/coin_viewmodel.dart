import 'package:flutter/material.dart';
import '../model/crypto_model.dart';
import '../repository/coin_repository.dart';

class CoinViewModel extends ChangeNotifier {
  final CoinRepository repository;

  List<Crypto> _cryptos = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Crypto> get cryptos => _cryptos;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  CoinViewModel(this.repository);

  Future<void> loadCryptos([List<String>? symbols]) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      symbols ??= [
        "BTC",
        "ETH",
        "SOL",
        "BNB",
        "BCH",
        "MKR",
        "AAVE",
        "DOT",
        "SUI",
        "ADA",
        "XRP",
        "TIA",
        "NEO",
        "NEAR",
        "PENDLE",
        "RENDER",
        "LINK",
        "TON",
        "XAI",
        "SEI",
        "IMX",
        "ETHFI",
        "UMA",
        "SUPER",
        "FET",
        "USUAL",
        "GALA",
        "PAAL",
        "AERO",
      ];
      _cryptos = await repository.getCryptos(symbols);
    } catch (e) {
      _cryptos = [];
      _errorMessage = 'Erro ao carregar dados: $e';
    }
    
    _isLoading = false;
    notifyListeners();
  }
}

