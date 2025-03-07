class User {
  final String? id;
  final String? loginName;
  final String? email;
  final double balance;
  final bool isDemo;
  
  User({
    this.id,
    this.loginName,
    this.email,
    this.balance = 0.0,
    this.isDemo = false,
  });
  
  User copyWith({
    String? id,
    String? loginName,
    String? email,
    double? balance,
    bool? isDemo,
  }) {
    return User(
      id: id ?? this.id,
      loginName: loginName ?? this.loginName,
      email: email ?? this.email,
      balance: balance ?? this.balance,
      isDemo: isDemo ?? this.isDemo,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loginName': loginName,
      'email': email,
      'balance': balance,
      'isDemo': isDemo,
    };
  }
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      loginName: json['loginName'],
      email: json['email'],
      balance: json['balance'] ?? 0.0,
      isDemo: json['isDemo'] ?? false,
    );
  }
  
  factory User.guest() {
    return User(
      id: 'guest-${DateTime.now().millisecondsSinceEpoch}',
      isDemo: false,
    );
  }
  
  factory User.demo({
    required String loginName,
    required String email,
    required double balance,
  }) {
    return User(
      id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
      loginName: loginName,
      email: email,
      balance: balance,
      isDemo: true,
    );
  }
}

