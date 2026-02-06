import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CoinApiDataSource {
  static const String _baseUrl =
      'https://pro-api.coinmarketcap.com/v2/cryptocurrency/quotes/latest';
  static const String _apiKey = String.fromEnvironment(
    'CMC_API_KEY',
    defaultValue: '',
  );
  static const Duration _timeout = Duration(seconds: 30);

  final http.Client _client;

  CoinApiDataSource({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> fetchCoins(List<String> symbols) async {
    if (_apiKey.isEmpty) {
      throw CoinApiException(
        'API key not configured. '
        'Run with: --dart-define=CMC_API_KEY=your_key',
      );
    }

    if (symbols.isEmpty) {
      throw ArgumentError('Symbols list cannot be empty');
    }

    final validatedSymbols = symbols
        .where((symbol) => symbol.isNotEmpty)
        .map((symbol) => symbol.trim().toUpperCase())
        .toSet()
        .toList();

    if (validatedSymbols.isEmpty) {
      throw ArgumentError('No valid symbols provided');
    }

    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'symbol': validatedSymbols.join(','),
        'convert': 'BRL',
      },
    );

    try {
      final response = await _client.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'X-CMC_PRO_API_KEY': _apiKey,
          'User-Agent': 'CoinApp/1.0',
        },
      ).timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      throw CoinApiException('No internet connection available');
    } on FormatException catch (e) {
      throw CoinApiException('Invalid response format: ${e.message}');
    } on http.ClientException catch (e) {
      throw CoinApiException('Network error: ${e.message}');
    } catch (e) {
      throw CoinApiException('Unexpected error: ${e.toString()}');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      try {
        final decodedBody = json.decode(response.body);

        if (decodedBody is! Map<String, dynamic>) {
          throw const FormatException(
              'Response body is not a valid JSON object');
        }

        if (!decodedBody.containsKey('data')) {
          throw const FormatException('Response does not contain data field');
        }

        return decodedBody['data'] as Map<String, dynamic>;
      } on FormatException {
        throw CoinApiException('Invalid JSON response format');
      }
    } else if (response.statusCode == 401) {
      throw CoinApiException('Invalid API key or unauthorized access');
    } else if (response.statusCode == 403) {
      throw CoinApiException(
          'API access forbidden - check your subscription plan');
    } else if (response.statusCode == 429) {
      throw CoinApiException('Rate limit exceeded - too many requests');
    } else if (response.statusCode >= 500) {
      throw CoinApiException('Server error - please try again later');
    } else {
      throw CoinApiException(
          'Request failed with status ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  void dispose() {
    _client.close();
  }
}

class CoinApiException implements Exception {
  final String message;

  const CoinApiException(this.message);

  @override
  String toString() => 'CoinApiException: $message';
}
