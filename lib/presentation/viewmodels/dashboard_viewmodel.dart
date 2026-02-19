import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';

/// Estados do dashboard
abstract class DashboardState {
  const DashboardState();
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final List<Wallet> recentWallets;
  final List<Wallet> favoriteWallets;
  final Map<String, dynamic> stats;

  const DashboardLoaded({
    required this.recentWallets,
    required this.favoriteWallets,
    required this.stats,
  });
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);
}

/// ViewModel do Dashboard
class DashboardViewModel extends ChangeNotifier {
  final WalletRepository repository;

  DashboardViewModel({required this.repository});

  DashboardState _state = const DashboardInitial();
  DashboardState get state => _state;

  List<Wallet> _recentWallets = [];
  List<Wallet> get recentWallets => _recentWallets;

  List<Wallet> _favoriteWallets = [];
  List<Wallet> get favoriteWallets => _favoriteWallets;

  Map<String, dynamic> _stats = {};
  Map<String, dynamic> get stats => _stats;

  Future<void> loadDashboard() async {
    _state = const DashboardLoading();
    notifyListeners();

    try {
      // Carregar carteiras salvas
      final savedResult = await repository.getSavedWallets();
      savedResult.fold(
        (failure) {
          _state = DashboardError(failure.message);
        },
        (wallets) {
          _recentWallets = wallets.take(5).toList();
        },
      );

      // Carregar favoritos
      final favoritesResult = await repository.getFavoriteWallets();
      favoritesResult.fold(
        (failure) {
          // Silenciar erro de favoritos
        },
        (favorites) {
          _favoriteWallets = favorites;
        },
      );

      // Calcular estatísticas
      _stats = _calculateStats();

      _state = DashboardLoaded(
        recentWallets: _recentWallets,
        favoriteWallets: _favoriteWallets,
        stats: _stats,
      );
      notifyListeners();
    } catch (e) {
      _state = DashboardError('Erro ao carregar dashboard: $e');
      notifyListeners();
    }
  }

  Map<String, dynamic> _calculateStats() {
    final totalWallets = _recentWallets.length;
    final totalFavorites = _favoriteWallets.length;

    // Contar por blockchain
    final blockchainCounts = <String, int>{};
    for (final wallet in _recentWallets) {
      blockchainCounts[wallet.blockchain] =
          (blockchainCounts[wallet.blockchain] ?? 0) + 1;
    }

    return {
      'totalWallets': totalWallets,
      'totalFavorites': totalFavorites,
      'blockchainCounts': blockchainCounts,
      'lastUpdated': DateTime.now(),
    };
  }

  Future<void> toggleFavorite(String walletId) async {
    final result = await repository.toggleFavorite(walletId);
    
    result.fold(
      (failure) {
        // Mostrar erro
      },
      (updatedWallet) {
        // Atualizar listas
        final index = _recentWallets.indexWhere((w) => w.id == walletId);
        if (index >= 0) {
          _recentWallets[index] = updatedWallet;
        }

        if (updatedWallet.isFavorite) {
          _favoriteWallets.add(updatedWallet);
        } else {
          _favoriteWallets.removeWhere((w) => w.id == walletId);
        }

        notifyListeners();
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
        _recentWallets.removeWhere((w) => w.id == walletId);
        _favoriteWallets.removeWhere((w) => w.id == walletId);
        notifyListeners();
      },
    );
  }
}
