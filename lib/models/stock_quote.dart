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
  
  factory StockQuote.fromJson(Map<String, dynamic> json) {
    return StockQuote(
      symbol: json['01. symbol'],
      open: double.parse(json['02. open']),
      high: double.parse(json['03. high']),
      low: double.parse(json['04. low']),
      price: double.parse(json['05. price']),
      volume: int.parse(json['06. volume']),
      latestTradingDay: json['07. latest trading day'],
      previousClose: double.parse(json['08. previous close']),
      change: double.parse(json['09. change']),
      changePercent: double.parse(json['10. change percent'].replaceAll('%', '')) / 100,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      '01. symbol': symbol,
      '02. open': open.toString(),
      '03. high': high.toString(),
      '04. low': low.toString(),
      '05. price': price.toString(),
      '06. volume': volume.toString(),
      '07. latest trading day': latestTradingDay,
      '08. previous close': previousClose.toString(),
      '09. change': change.toString(),
      '10. change percent': '${(changePercent * 100).toStringAsFixed(2)}%',
    };
  }
  
  String get changePercentFormatted => 
    (changePercent >= 0 ? '+' : '') + '${(changePercent * 100).toStringAsFixed(2)}%';
  
  bool get isPositive => changePercent >= 0;
}

