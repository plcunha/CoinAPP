class Crypto {
  final String name;
  final String symbol;
  final double priceUsd;
  final double priceBrl;
  final String dateAdded;

  Crypto({
    required this.name,
    required this.symbol,
    required this.priceUsd,
    required this.priceBrl,
    required this.dateAdded,
  });

  factory Crypto.fromJson(Map<String, dynamic> json) {
    final quote = json['quote'] ?? {};
    final usd = quote['USD'] ?? {};
    final brl = quote['BRL'] ?? {};

    return Crypto(
      name: json['name'] ?? 'N/A',
      symbol: json['symbol'] ?? 'N/A',
      priceUsd: (usd['price'] ?? 0.0).toDouble(),
      priceBrl: (brl['price'] ?? 0.0).toDouble(),
      dateAdded: json['date_added'] ?? 'N/A',
    );
  }
}

