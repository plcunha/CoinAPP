import '../model/crypto_model.dart';
import '../data/coin_api_datasource.dart';

class CoinRepository {
  final CoinApiDataSource dataSource;

  CoinRepository(this.dataSource);

  Future<List<Crypto>> getCryptos(List<String> symbols) async {
    final data = await dataSource.fetchCoins(symbols);

    final List<Crypto> result = [];

    data.forEach((symbol, list) {
      if (list is List && list.isNotEmpty) {
        try {
          final crypto = Crypto.fromJson(list.first);
          result.add(crypto);
        } catch (_) {
          // Skip entries that fail to parse
        }
      }
    });

    return result;
  }
}

