import 'portfolio_item.dart';

class User {
  final String id;
  final String loginName;
  final String email;
  final double balance;
  final bool isDemo;
  final List<PortfolioItem> portfolio;
  
  User({
    required this.id,
    required this.loginName,
    required this.email,
    required this.balance,
    required this.isDemo,
    required this.portfolio,
  });
  
  // Create a copy of the user with updated fields
  User copyWith({
    String? id,
    String? loginName,
    String? email,
    double? balance,
    bool? isDemo,
    List<PortfolioItem>? portfolio,
  }) {
    return User(
      id: id ?? this.id,
      loginName: loginName ?? this.loginName,
      email: email ?? this.email,
      balance: balance ?? this.balance,
      isDemo: isDemo ?? this.isDemo,
      portfolio: portfolio ?? this.portfolio,
    );
  }
  
  // Factory for creating a guest user
  factory User.guest() {
    return User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      loginName: 'Guest',
      email: 'guest@example.com',
      balance: 10000.0,
      isDemo: false,
      portfolio: [],
    );
  }
  
  // Factory for creating a demo user
  factory User.demo({
    required String loginName,
    required String email,
    required double balance,
  }) {
    return User(
      id: 'demo_${DateTime.now().millisecondsSinceEpoch}',
      loginName: loginName,
      email: email,
      balance: balance,
      isDemo: true,
      portfolio: [], // Demo users start with an empty portfolio
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loginName': loginName,
      'email': email,
      'balance': balance,
      'isDemo': isDemo,
      'portfolio': portfolio.map((item) => item.toJson()).toList(),
    };
  }
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      loginName: json['loginName'],
      email: json['email'],
      balance: json['balance'],
      isDemo: json['isDemo'],
      portfolio: (json['portfolio'] as List)
          .map((item) => PortfolioItem.fromJson(item))
          .toList(),
    );
  }
}

