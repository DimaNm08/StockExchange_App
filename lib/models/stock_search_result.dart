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
  
  // Factory for Alpha Vantage format (keeping for backward compatibility)
  factory StockSearchResult.fromJson(Map<String, dynamic> json) {
    try {
      return StockSearchResult(
        symbol: json['1. symbol'] ?? '',
        name: json['2. name'] ?? '',
        type: json['3. type'] ?? '',
        region: json['4. region'] ?? '',
        marketOpen: json['5. marketOpen'] ?? '',
        marketClose: json['6. marketClose'] ?? '',
        timezone: json['7. timezone'] ?? '',
        currency: json['8. currency'] ?? 'USD',
        matchScore: _parseDouble(json['9. matchScore']),
      );
    } catch (e) {
      print('Error parsing StockSearchResult: $e');
      print('JSON data: $json');
      
      // Return default values with symbol if available
      return StockSearchResult(
        symbol: json['1. symbol'] ?? 'UNKNOWN',
        name: json['2. name'] ?? 'Unknown Company',
        type: 'Equity',
        region: 'United States',
        marketOpen: '09:30',
        marketClose: '16:00',
        timezone: 'UTC-05',
        currency: 'USD',
        matchScore: 1.0,
      );
    }
  }
  
  // Factory for Twelve Data format
  factory StockSearchResult.fromTwelveDataJson(Map<String, dynamic> json) {
    try {
      return StockSearchResult(
        symbol: json['symbol'] ?? '',
        name: json['instrument_name'] ?? '',
        type: json['instrument_type'] ?? 'Equity',
        region: json['exchange'] ?? 'United States',
        marketOpen: '09:30', // Twelve Data doesn't provide this directly
        marketClose: '16:00', // Twelve Data doesn't provide this directly
        timezone: 'UTC-05', // Twelve Data doesn't provide this directly
        currency: json['currency'] ?? 'USD',
        matchScore: 1.0, // Twelve Data doesn't provide this
      );
    } catch (e) {
      print('Error parsing Twelve Data StockSearchResult: $e');
      print('JSON data: $json');
      
      // Return default values with symbol if available
      return StockSearchResult(
        symbol: json['symbol'] ?? 'UNKNOWN',
        name: json['instrument_name'] ?? 'Unknown Company',
        type: 'Equity',
        region: 'United States',
        marketOpen: '09:30',
        marketClose: '16:00',
        timezone: 'UTC-05',
        currency: 'USD',
        matchScore: 1.0,
      );
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'type': type,
      'region': region,
      'marketOpen': marketOpen,
      'marketClose': marketClose,
      'timezone': timezone,
      'currency': currency,
      'matchScore': matchScore,
    };
  }
  
  // Helper method for parsing
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }
}

