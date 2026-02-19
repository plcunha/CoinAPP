import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/wallet.dart';

/// Interface do repositório de carteiras
abstract class WalletRepository {
  /// Valida um endereço de carteira
  Future<Either<Failure, ValidationResult>> validateAddress(
    String address,
    String blockchain,
  );

  /// Busca informações da carteira na blockchain
  Future<Either<Failure, Wallet>> getWalletInfo(
    String address,
    String blockchain,
  );

  /// Busca saldo da carteira
  Future<Either<Failure, Map<String, dynamic>>> getWalletBalance(
    String address,
    String blockchain,
  );

  /// Busca histórico de transações
  Future<Either<Failure, List<Transaction>>> getWalletTransactions(
    String address,
    String blockchain, {
    int limit = 20,
    int offset = 0,
  });

  /// Salva uma carteira nos favoritos
  Future<Either<Failure, void>> saveWallet(Wallet wallet);

  /// Remove uma carteira dos favoritos
  Future<Either<Failure, void>> removeWallet(String walletId);

  /// Busca todas as carteiras salvas
  Future<Either<Failure, List<Wallet>>> getSavedWallets();

  /// Busca carteiras favoritas
  Future<Either<Failure, List<Wallet>>> getFavoriteWallets();

  /// Alterna status de favorito
  Future<Either<Failure, Wallet>> toggleFavorite(String walletId);
}
