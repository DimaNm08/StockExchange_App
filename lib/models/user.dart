import 'portfolio_item.dart';

// Add password field to User class
class User {
  final String id;
  final String loginName;
  final String email;
  final String password;  // Add this line
  final double balance;
  final bool isDemo;
  final List<PortfolioItem> portfolio;
  
  User({
    required this.id,
    required this.loginName,
    required this.email,
    required this.password,  // Add this line
    required this.balance,
    required this.isDemo,
    required this.portfolio,
  });
  
  // Update copyWith to include password
  User copyWith({
    String? id,
    String? loginName,
    String? email,
    String? password,  // Add this line
    double? balance,
    bool? isDemo,
    List<PortfolioItem>? portfolio,
  }) {
    return User(
      id: id ?? this.id,
      loginName: loginName ?? this.loginName,
      email: email ?? this.email,
      password: password ?? this.password,  // Add this line
      balance: balance ?? this.balance,
      isDemo: isDemo ?? this.isDemo,
      portfolio: portfolio ?? this.portfolio,
    );
  }
  
  // Update factory methods
  factory User.guest() {
    return User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      loginName: 'Guest',
      email: 'guest@example.com',
      password: '',  // Add this line
      balance: 10000.0,
      isDemo: false,
      portfolio: [],
    );
  }
  
  // Update demo factory to include password
  factory User.demo({
    required String loginName,
    required String email,
    required String password,  // Add this line
    required double balance,
  }) {
    return User(
      id: 'demo_${DateTime.now().millisecondsSinceEpoch}',
      loginName: loginName,
      email: email,
      password: password,  // Add this line
      balance: balance,
      isDemo: true,
      portfolio: [],
    );
  }
  
  // Update toJson and fromJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loginName': loginName,
      'email': email,
      'password': password,  // Add this line (consider encryption in real app)
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
      password: json['password'],  // Add this line
      balance: json['balance'],
      isDemo: json['isDemo'],
      portfolio: (json['portfolio'] as List)
          .map((item) => PortfolioItem.fromJson(item))
          .toList(),
    );
  }
}

