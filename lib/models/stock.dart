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
  
  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      open: double.parse(json['1. open']),
      high: double.parse(json['2. high']),
      low: double.parse(json['3. low']),
      close: double.parse(json['4. close']),
      volume: int.parse(json['5. volume']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      '1. open': open.toString(),
      '2. high': high.toString(),
      '3. low': low.toString(),
      '4. close': close.toString(),
      '5. volume': volume.toString(),
    };
  }
}

