class StockQuote {
  final String symbol;
  final double open;
  final double high;
  final double low;
  final double price;
  final int volume;
  final String latestTradingDay;
  final double previousClose;
  final double change;
  final double changePercent;
  
  StockQuote({
    required this.symbol,
    required this.open,
    required this.high,
    required this.low,
    required this.price,
    required this.volume,
    required this.latestTradingDay,
    required this.previousClose,
    required this.change,
    required this.changePercent,
  });
  
  // Factory for Alpha Vantage format (keeping for backward compatibility)
  factory StockQuote.fromJson(Map<String, dynamic> json) {
    try {
      return StockQuote(
        symbol: json['01. symbol'] ?? '',
        open: _parseDouble(json['02. open']),
        high: _parseDouble(json['03. high']),
        low: _parseDouble(json['04. low']),
        price: _parseDouble(json['05. price']),
        volume: _parseInt(json['06. volume']),
        latestTradingDay: json['07. latest trading day'] ?? DateTime.now().toString().substring(0, 10),
        previousClose: _parseDouble(json['08. previous close']),
        change: _parseDouble(json['09. change']),
        changePercent: _parseChangePercent(json['10. change percent']),
      );
    } catch (e) {
      print('Error parsing StockQuote: $e');
      print('JSON data: $json');
      
      // Return a default quote with the symbol if available
      return StockQuote(
        symbol: json['01. symbol'] ?? 'UNKNOWN',
        open: 0.0,
        high: 0.0,
        low: 0.0,
        price: 0.0,
        volume: 0,
        latestTradingDay: DateTime.now().toString().substring(0, 10),
        previousClose: 0.0,
        change: 0.0,
        changePercent: 0.0,
      );
    }
  }
  
  // Factory for Twelve Data format
  factory StockQuote.fromTwelveDataJson(Map<String, dynamic> json) {
    try {
      return StockQuote(
        symbol: json['symbol'] ?? '',
        open: _parseDouble(json['open']),
        high: _parseDouble(json['high']),
        low: _parseDouble(json['low']),
        price: _parseDouble(json['close']),
        volume: _parseInt(json['volume']),
        latestTradingDay: json['datetime'] ?? DateTime.now().toString().substring(0, 10),
        previousClose: _parseDouble(json['previous_close']),
        change: _parseDouble(json['change']),
        changePercent: _parseDouble(json['percent_change']) / 100,
      );
    } catch (e) {
      print('Error parsing Twelve Data StockQuote: $e');
      print('JSON data: $json');
      
      // Return a default quote with the symbol if available
      return StockQuote(
        symbol: json['symbol'] ?? 'UNKNOWN',
        open: 0.0,
        high: 0.0,
        low: 0.0,
        price: 0.0,
        volume: 0,
        latestTradingDay: DateTime.now().toString().substring(0, 10),
        previousClose: 0.0,
        change: 0.0,
        changePercent: 0.0,
      );
    }
  }
  
  // Factory for Finnhub format
  factory StockQuote.fromFinnhubJson(Map<String, dynamic> json, String symbolValue, Map<String, dynamic> companyInfo) {
    try {
      // Finnhub quote endpoint returns:
      // c: Current price, o: Open price, h: High price, l: Low price
      // pc: Previous close price, t: Timestamp
      
      final currentPrice = _parseDouble(json['c']);
      final previousClose = _parseDouble(json['pc']);
      final change = currentPrice - previousClose;
      final changePercent = previousClose > 0 ? change / previousClose : 0.0;
      
      return StockQuote(
        symbol: symbolValue,
        open: _parseDouble(json['o']),
        high: _parseDouble(json['h']),
        low: _parseDouble(json['l']),
        price: currentPrice,
        volume: 0, // Finnhub quote endpoint doesn't return volume, would need separate call
        latestTradingDay: DateTime.fromMillisecondsSinceEpoch((_parseInt(json['t']) * 1000)).toString().substring(0, 10),
        previousClose: previousClose,
        change: change,
        changePercent: changePercent,
      );
    } catch (e) {
      print('Error parsing Finnhub StockQuote: $e');
      print('JSON data: $json');
      
      // Return a default quote with the symbol
      return StockQuote(
        symbol: symbolValue,
        open: 0.0,
        high: 0.0,
        low: 0.0,
        price: 0.0,
        volume: 0,
        latestTradingDay: DateTime.now().toString().substring(0, 10),
        previousClose: 0.0,
        change: 0.0,
        changePercent: 0.0,
      );
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'open': open,
      'high': high,
      'low': low,
      'price': price,
      'volume': volume,
      'latestTradingDay': latestTradingDay,
      'previousClose': previousClose,
      'change': change,
      'changePercent': changePercent,
    };
  }
  
  String get changePercentFormatted => 
    (changePercent >= 0 ? '+' : '') + '${(changePercent * 100).toStringAsFixed(2)}%';
  
  bool get isPositive => changePercent >= 0;
  
  // Helper methods for parsing
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
  
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }
  
  static double _parseChangePercent(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is String) {
      try {
        // Remove % sign and convert to decimal
        String cleaned = value.replaceAll('%', '').trim();
        return double.parse(cleaned) / 100;
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }
}

