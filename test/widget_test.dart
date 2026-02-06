import 'package:flutter_test/flutter_test.dart';
import 'package:coin_aplication/model/crypto_model.dart';

void main() {
  group('Crypto model', () {
    test('fromJson parses valid data correctly', () {
      final json = {
        'name': 'Bitcoin',
        'symbol': 'BTC',
        'date_added': '2013-04-28T00:00:00.000Z',
        'quote': {
          'USD': {'price': 50000.0, 'percent_change_24h': 2.5},
          'BRL': {'price': 250000.0},
        },
      };

      final crypto = Crypto.fromJson(json);

      expect(crypto.name, 'Bitcoin');
      expect(crypto.symbol, 'BTC');
      expect(crypto.priceUsd, 50000.0);
      expect(crypto.priceBrl, 250000.0);
      expect(crypto.percentChange24h, 2.5);
      expect(crypto.dateAdded, '2013-04-28T00:00:00.000Z');
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final crypto = Crypto.fromJson(json);

      expect(crypto.name, 'N/A');
      expect(crypto.symbol, 'N/A');
      expect(crypto.priceUsd, 0.0);
      expect(crypto.priceBrl, 0.0);
      expect(crypto.percentChange24h, 0.0);
      expect(crypto.dateAdded, 'N/A');
    });

    test('fromJson handles partial quote data', () {
      final json = {
        'name': 'Ethereum',
        'symbol': 'ETH',
        'date_added': '2015-08-07T00:00:00.000Z',
        'quote': {
          'USD': {'price': 3000.0},
        },
      };

      final crypto = Crypto.fromJson(json);

      expect(crypto.name, 'Ethereum');
      expect(crypto.symbol, 'ETH');
      expect(crypto.priceUsd, 3000.0);
      expect(crypto.priceBrl, 0.0);
      expect(crypto.percentChange24h, 0.0);
    });

    test('fromJson handles negative percent change', () {
      final json = {
        'name': 'Solana',
        'symbol': 'SOL',
        'date_added': '2020-04-10T00:00:00.000Z',
        'quote': {
          'USD': {'price': 100.0, 'percent_change_24h': -5.3},
          'BRL': {'price': 500.0},
        },
      };

      final crypto = Crypto.fromJson(json);

      expect(crypto.percentChange24h, -5.3);
    });
  });
}
