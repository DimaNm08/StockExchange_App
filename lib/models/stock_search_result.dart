class StockSearchResult {
  final String symbol;
  final String name;
  final String type;
  final String region;
  final String marketOpen;
  final String marketClose;
  final String timezone;
  final String currency;
  final double matchScore;
  
  StockSearchResult({
    required this.symbol,
    required this.name,
    required this.type,
    required this.region,
    required this.marketOpen,
    required this.marketClose,
    required this.timezone,
    required this.currency,
    required this.matchScore,
  });
  
  factory StockSearchResult.fromJson(Map<String, dynamic> json) {
    return StockSearchResult(
      symbol: json['1. symbol'],
      name: json['2. name'],
      type: json['3. type'],
      region: json['4. region'],
      marketOpen: json['5. marketOpen'],
      marketClose: json['6. marketClose'],
      timezone: json['7. timezone'],
      currency: json['8. currency'],
      matchScore: double.parse(json['9. matchScore']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      '1. symbol': symbol,
      '2. name': name,
      '3. type': type,
      '4. region': region,
      '5. marketOpen': marketOpen,
      '6. marketClose': marketClose,
      '7. timezone': timezone,
      '8. currency': currency,
      '9. matchScore': matchScore.toString(),
    };
  }
}

