class PortfolioItem {
  final String symbol;
  final String name;
  final int quantity;
  final double purchasePrice;
  final DateTime purchaseDate;
  
  PortfolioItem({
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.purchasePrice,
    required this.purchaseDate,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'quantity': quantity,
      'purchasePrice': purchasePrice,
      'purchaseDate': purchaseDate.toIso8601String(),
    };
  }
  
  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      symbol: json['symbol'],
      name: json['name'],
      quantity: json['quantity'],
      purchasePrice: json['purchasePrice'],
      purchaseDate: DateTime.parse(json['purchaseDate']),
    );
  }
}

