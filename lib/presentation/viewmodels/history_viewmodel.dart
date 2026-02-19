import 'package:flutter/material.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';

/// Estados do histórico
abstract class HistoryState {
  const HistoryState();
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoaded extends HistoryState {
  final List<Wallet> wallets;
  final List<Wallet> filteredWallets;
  final String? filterBlockchain;
  final String? searchQuery;

  const HistoryLoaded({
    required this.wallets,
    required this.filteredWallets,
    this.filterBlockchain,
    this.searchQuery,
  });
}

class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);
}

/// ViewModel do Histórico
class HistoryViewModel extends ChangeNotifier {
  final WalletRepository repository;

  HistoryViewModel({required this.repository});

  HistoryState _state = const HistoryInitial();
  HistoryState get state => _state;

  List<Wallet> _allWallets = [];
  String? _currentFilter;
  String? _currentSearch;

  Future<void> loadHistory() async {
    _state = const HistoryLoading();
    notifyListeners();

    final result = await repository.getSavedWallets();

    result.fold(
      (failure) {
        _state = HistoryError(failure.message);
        notifyListeners();
      },
      (wallets) {
        _allWallets = wallets;
        _applyFilters();
      },
    );
  }

  void filterByBlockchain(String? blockchain) {
    _currentFilter = blockchain;
    _applyFilters();
  }

  void search(String? query) {
    _currentSearch = query?.toLowerCase().trim();
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = List<Wallet>.from(_allWallets);

    // Aplicar filtro de blockchain
    if (_currentFilter != null && _currentFilter!.isNotEmpty) {
      filtered = filtered
          .where((w) => w.blockchain == _currentFilter)
          .toList();
    }

    // Aplicar busca
    if (_currentSearch != null && _currentSearch!.isNotEmpty) {
      filtered = filtered.where((w) {
        return w.address.toLowerCase().contains(_currentSearch!) ||
            (w.label?.toLowerCase().contains(_currentSearch!) ?? false);
      }).toList();
    }

    _state = HistoryLoaded(
      wallets: _allWallets,
      filteredWallets: filtered,
      filterBlockchain: _currentFilter,
      searchQuery: _currentSearch,
    );
    notifyListeners();
  }

  Future<void> toggleFavorite(String walletId) async {
    final result = await repository.toggleFavorite(walletId);
    
    result.fold(
      (failure) {
        // Mostrar erro
      },
      (updatedWallet) {
        final index = _allWallets.indexWhere((w) => w.id == walletId);
        if (index >= 0) {
          _allWallets[index] = updatedWallet;
          _applyFilters();
        }
      },
    );
  }

  Future<void> removeWallet(String walletId) async {
    final result = await repository.removeWallet(walletId);
    
    result.fold(
      (failure) {
        // Mostrar erro
      },
      (_) {
        _allWallets.removeWhere((w) => w.id == walletId);
        _applyFilters();
      },
    );
  }

  void clearFilters() {
    _currentFilter = null;
    _currentSearch = null;
    _applyFilters();
  }
}
