import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/wallet_model.dart';

/// Datasource remoto para APIs blockchain
abstract class BlockchainRemoteDataSource {
  /// Busca saldo de uma carteira na blockchain
  Future<Map<String, dynamic>> getWalletBalance(
    String address,
    String blockchain,
  );

  /// Busca transações de uma carteira
  Future<List<Map<String, dynamic>>> getWalletTransactions(
    String address,
    String blockchain, {
    int limit = 20,
    int offset = 0,
  });

  /// Verifica se um endereço existe na blockchain
  Future<bool> addressExists(String address, String blockchain);

  /// Busca informações detalhadas de uma transação
  Future<Map<String, dynamic>?> getTransactionDetails(
    String txHash,
    String blockchain,
  );
}

/// Implementação do datasource remoto
class BlockchainRemoteDataSourceImpl implements BlockchainRemoteDataSource {
  final Dio _dio;

  BlockchainRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? _createDio();

  static Dio _createDio() {
    return Dio(
      BaseOptions(
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  @override
  Future<Map<String, dynamic>> getWalletBalance(
    String address,
    String blockchain,
  ) async {
    try {
      switch (blockchain.toLowerCase()) {
        case 'bitcoin':
        case 'btc':
          return await _getBitcoinBalance(address);
        case 'ethereum':
        case 'eth':
          return await _getEthereumBalance(address);
        case 'litecoin':
        case 'ltc':
          return await _getLitecoinBalance(address);
        case 'bitcoin_cash':
        case 'bch':
          return await _getBitcoinCashBalance(address);
        case 'dogecoin':
        case 'doge':
          return await _getDogecoinBalance(address);
        default:
          throw BlockchainException(
            'Blockchain não suportada: $blockchain',
            code: 'UNSUPPORTED_BLOCKCHAIN',
          );
      }
    } on SocketException {
      throw const NetworkException(
        'Sem conexão com a internet',
        code: 'NO_INTERNET',
      );
    } on DioException catch (e) {
      throw NetworkException.fromStatusCode(
        e.response?.statusCode ?? 500,
        message: e.message,
      );
    } catch (e) {
      throw BlockchainException(
        'Erro ao buscar saldo: $e',
        code: 'BALANCE_ERROR',
      );
    }
  }

  Future<Map<String, dynamic>> _getBitcoinBalance(String address) async {
    final response = await _dio.get(
      '${AppConstants.blockchainApis['bitcoin']}/rawaddr/$address',
    );

    if (response.statusCode == 200) {
      final data = response.data;
      return {
        'balance': (data['final_balance'] ?? 0) / 100000000, // Satoshi para BTC
        'balanceSymbol': 'BTC',
        'totalReceived': (data['total_received'] ?? 0) / 100000000,
        'totalSent': (data['total_sent'] ?? 0) / 100000000,
        'transactionCount': data['n_tx'] ?? 0,
      };
    }

    throw NetworkException.fromStatusCode(response.statusCode ?? 500);
  }

  Future<Map<String, dynamic>> _getEthereumBalance(String address) async {
    final response = await _dio.get(
      AppConstants.blockchainApis['ethereum']!,
      queryParameters: {
        'module': 'account',
        'action': 'balance',
        'address': address,
        'tag': 'latest',
        'apikey': AppConstants.etherscanApiKey,
      },
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['status'] == '1') {
        final balanceWei = BigInt.parse(data['result']);
        final balanceEth = balanceWei / BigInt.from(10).pow(18);

        // Buscar contagem de transações
        final txCountResponse = await _dio.get(
          AppConstants.blockchainApis['ethereum']!,
          queryParameters: {
            'module': 'account',
            'action': 'txlist',
            'address': address,
            'startblock': 0,
            'endblock': 99999999,
            'page': 1,
            'offset': 1,
            'apikey': AppConstants.etherscanApiKey,
          },
        );

        return {
          'balance': balanceEth,
          'balanceSymbol': 'ETH',
          'balanceInWei': balanceWei.toString(),
          'transactionCount': txCountResponse.data['result'] is List
              ? (txCountResponse.data['result'] as List).length
              : 0,
        };
      }
    }

    throw NetworkException.fromStatusCode(response.statusCode ?? 500);
  }

  Future<Map<String, dynamic>> _getLitecoinBalance(String address) async {
    final response = await _dio.get(
      '${AppConstants.blockchainApis['litecoin']}/addrs/$address/balance',
    );

    if (response.statusCode == 200) {
      final data = response.data;
      return {
        'balance': (data['balance'] ?? 0) / 100000000,
        'balanceSymbol': 'LTC',
        'totalReceived': (data['total_received'] ?? 0) / 100000000,
        'totalSent': (data['total_sent'] ?? 0) / 100000000,
        'transactionCount': data['n_tx'] ?? 0,
      };
    }

    throw NetworkException.fromStatusCode(response.statusCode ?? 500);
  }

  Future<Map<String, dynamic>> _getBitcoinCashBalance(String address) async {
    final response = await _dio.get(
      '${AppConstants.blockchainApis['bitcoin_cash']}/dashboards/address/$address',
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final addressData = data['data']?[address];
      
      if (addressData != null) {
        return {
          'balance': (addressData['address']['balance'] ?? 0) / 100000000,
          'balanceSymbol': 'BCH',
          'transactionCount': addressData['address']['transaction_count'] ?? 0,
        };
      }
    }

    throw NetworkException.fromStatusCode(response.statusCode ?? 500);
  }

  Future<Map<String, dynamic>> _getDogecoinBalance(String address) async {
    final response = await _dio.get(
      '${AppConstants.blockchainApis['dogecoin']}/addrs/$address/balance',
    );

    if (response.statusCode == 200) {
      final data = response.data;
      return {
        'balance': (data['balance'] ?? 0) / 100000000,
        'balanceSymbol': 'DOGE',
        'totalReceived': (data['total_received'] ?? 0) / 100000000,
        'totalSent': (data['total_sent'] ?? 0) / 100000000,
        'transactionCount': data['n_tx'] ?? 0,
      };
    }

    throw NetworkException.fromStatusCode(response.statusCode ?? 500);
  }

  @override
  Future<List<Map<String, dynamic>>> getWalletTransactions(
    String address,
    String blockchain, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      switch (blockchain.toLowerCase()) {
        case 'bitcoin':
        case 'btc':
          return await _getBitcoinTransactions(address, limit, offset);
        case 'ethereum':
        case 'eth':
          return await _getEthereumTransactions(address, limit, offset);
        default:
          return [];
      }
    } catch (e) {
      throw BlockchainException(
        'Erro ao buscar transações: $e',
        code: 'TRANSACTIONS_ERROR',
      );
    }
  }

  Future<List<Map<String, dynamic>>> _getBitcoinTransactions(
    String address,
    int limit,
    int offset,
  ) async {
    final response = await _dio.get(
      '${AppConstants.blockchainApis['bitcoin']}/rawaddr/$address',
      queryParameters: {
        'limit': limit,
        'offset': offset,
      },
    );

    if (response.statusCode == 200) {
      final txs = response.data['txs'] as List<dynamic>? ?? [];
      return txs.map((tx) => {
        'hash': tx['hash'],
        'time': DateTime.fromMillisecondsSinceEpoch(tx['time'] * 1000),
        'amount': (tx['result'] ?? 0) / 100000000,
        'fee': (tx['fee'] ?? 0) / 100000000,
        'confirmations': tx['block_height'] != null ? 
            response.data['height'] - tx['block_height'] + 1 : 0,
      }).toList();
    }

    return [];
  }

  Future<List<Map<String, dynamic>>> _getEthereumTransactions(
    String address,
    int limit,
    int offset,
  ) async {
    final response = await _dio.get(
      AppConstants.blockchainApis['ethereum']!,
      queryParameters: {
        'module': 'account',
        'action': 'txlist',
        'address': address,
        'startblock': 0,
        'endblock': 99999999,
        'page': (offset / limit).floor() + 1,
        'offset': limit,
        'sort': 'desc',
        'apikey': AppConstants.etherscanApiKey,
      },
    );

    if (response.statusCode == 200 && response.data['status'] == '1') {
      final txs = response.data['result'] as List<dynamic>? ?? [];
      return txs.map((tx) => {
        'hash': tx['hash'],
        'time': DateTime.fromMillisecondsSinceEpoch(
          int.parse(tx['timeStamp']) * 1000,
        ),
        'from': tx['from'],
        'to': tx['to'],
        'amount': double.parse(tx['value']) / 1e18,
        'fee': (double.parse(tx['gasPrice']) * double.parse(tx['gasUsed'])) / 1e18,
        'confirmations': int.parse(tx['confirmations']),
      }).toList();
    }

    return [];
  }

  @override
  Future<bool> addressExists(String address, String blockchain) async {
    try {
      final balance = await getWalletBalance(address, blockchain);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>?> getTransactionDetails(
    String txHash,
    String blockchain,
  ) async {
    // Implementação específica por blockchain
    return null;
  }
}
