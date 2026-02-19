import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/wallet_validation_service.dart';
import '../../data/datasources/blockchain_remote_datasource.dart';
import '../../data/models/wallet_model.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';

/// Implementação do repositório de carteiras
class WalletRepositoryImpl implements WalletRepository {
  final BlockchainRemoteDataSource remoteDataSource;

  WalletRepositoryImpl({required this.remoteDataSource});

  final List<WalletModel> _savedWallets = [];

  @override
  Future<Either<Failure, ValidationResult>> validateAddress(
    String address,
    String blockchain,
  ) async {
    try {
      final result = WalletValidationService.validateAddress(address, blockchain);

      return Right(
        ValidationResult(
          isValid: result.isValid,
          address: result.address,
          blockchain: result.blockchain,
          timestamp: DateTime.now(),
          errorMessage: result.reason,
          details: result.details,
        ),
      );
    } catch (e) {
      return Left(ValidationFailure('Erro na validação: $e'));
    }
  }

  @override
  Future<Either<Failure, Wallet>> getWalletInfo(
    String address,
    String blockchain,
  ) async {
    try {
      // Validar o endereço primeiro
      final validationResult = WalletValidationService.validateAddress(
        address,
        blockchain,
      );

      if (!validationResult.isValid) {
        return Left(
          ValidationFailure(
            validationResult.reason ?? 'Endereço inválido',
          ),
        );
      }

      // Buscar saldo e informações
      final balanceData = await remoteDataSource.getWalletBalance(
        address,
        blockchain,
      );

      final wallet = Wallet(
        id: '${blockchain}_$address',
        address: address,
        blockchain: blockchain,
        balance: balanceData['balance'],
        balanceSymbol: balanceData['balanceSymbol'],
        balanceInUsd: balanceData['balanceInUsd'],
        transactionCount: balanceData['transactionCount'],
        validatedAt: DateTime.now(),
        validationStatus: WalletValidationStatus.valid,
        metadata: balanceData,
      );

      return Right(wallet);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, code: e.code));
    } on BlockchainException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar informações: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getWalletBalance(
    String address,
    String blockchain,
  ) async {
    try {
      final balanceData = await remoteDataSource.getWalletBalance(
        address,
        blockchain,
      );
      return Right(balanceData);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar saldo: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getWalletTransactions(
    String address,
    String blockchain, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final transactionsData = await remoteDataSource.getWalletTransactions(
        address,
        blockchain,
        limit: limit,
        offset: offset,
      );

      final transactions = transactionsData.map((tx) => Transaction(
        id: tx['hash'] ?? '',
        walletAddress: address,
        blockchain: blockchain,
        type: tx['type'] ?? 'incoming',
        amount: tx['amount'] ?? 0.0,
        symbol: tx['symbol'] ?? blockchain.toUpperCase(),
        timestamp: tx['time'] ?? DateTime.now(),
        confirmations: tx['confirmations'] ?? 0,
        status: tx['confirmations'] != null && tx['confirmations'] > 6
            ? 'confirmed'
            : 'pending',
        fromAddress: tx['from'],
        toAddress: tx['to'],
        hash: tx['hash'],
      )).toList();

      return Right(transactions);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar transações: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveWallet(Wallet wallet) async {
    try {
      final model = WalletModel.fromEntity(wallet);
      
      // Verificar se já existe
      final existingIndex = _savedWallets.indexWhere((w) => w.id == wallet.id);
      
      if (existingIndex >= 0) {
        _savedWallets[existingIndex] = model;
      } else {
        _savedWallets.add(model);
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao salvar carteira: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeWallet(String walletId) async {
    try {
      _savedWallets.removeWhere((w) => w.id == walletId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao remover carteira: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Wallet>>> getSavedWallets() async {
    try {
      final wallets = _savedWallets.map((m) => m.toEntity()).toList();
      return Right(wallets);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar carteiras: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Wallet>>> getFavoriteWallets() async {
    try {
      final favorites = _savedWallets
          .where((w) => w.isFavorite)
          .map((m) => m.toEntity())
          .toList();
      return Right(favorites);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar favoritos: $e'));
    }
  }

  @override
  Future<Either<Failure, Wallet>> toggleFavorite(String walletId) async {
    try {
      final index = _savedWallets.indexWhere((w) => w.id == walletId);
      
      if (index < 0) {
        return Left(CacheFailure('Carteira não encontrada'));
      }

      final updated = _savedWallets[index].copyWith(
        isFavorite: !_savedWallets[index].isFavorite,
      );
      _savedWallets[index] = updated;

      return Right(updated.toEntity());
    } catch (e) {
      return Left(CacheFailure('Erro ao atualizar favorito: $e'));
    }
  }
}
