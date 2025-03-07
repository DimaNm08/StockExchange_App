class Stock {
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;
  
  Stock({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });
  
  // Factory for Alpha Vantage format (keeping for backward compatibility)
  factory Stock.fromJson(Map<String, dynamic> json) {
    try {
      return Stock(
        open: _parseDouble(json['1. open']),
        high: _parseDouble(json['2. high']),
        low: _parseDouble(json['3. low']),
        close: _parseDouble(json['4. close']),
        volume: _parseInt(json['5. volume']),
      );
    } catch (e) {
      print('Error parsing Stock: $e');
      print('JSON data: $json');
      
      // Return default values
      return Stock(
        open: 0.0,
        high: 0.0,
        low: 0.0,
        close: 0.0,
        volume: 0,
      );
    }
  }
  
  // Factory for Twelve Data format
  factory Stock.fromTwelveDataJson(Map<String, dynamic> json) {
    try {
      return Stock(
        open: _parseDouble(json['open']),
        high: _parseDouble(json['high']),
        low: _parseDouble(json['low']),
        close: _parseDouble(json['close']),
        volume: _parseInt(json['volume']),
      );
    } catch (e) {
      print('Error parsing Twelve Data Stock: $e');
      print('JSON data: $json');
      
      // Return default values
      return Stock(
        open: 0.0,
        high: 0.0,
        low: 0.0,
        close: 0.0,
        volume: 0,
      );
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
    };
  }
  
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
}

