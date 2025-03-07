import '../models/user.dart';

class UserService {
  User? _currentUser;
  
  // Singleton pattern
  static final UserService _instance = UserService._internal();
  
  factory UserService() {
    return _instance;
  }
  
  UserService._internal();
  
  Future<void> init() async {
    // In a real app, we would load user data from storage here
    // For now, we'll just initialize with null
  }
  
  User? get currentUser => _currentUser;
  
  bool get isLoggedIn => _currentUser != null;
  
  bool get isDemo => _currentUser?.isDemo ?? false;
  
  Future<void> saveUser(User user) async {
    _currentUser = user;
    // In a real app, we would save to persistent storage here
  }
  
  Future<User?> loadUser() async {
    // In a real app, we would load from persistent storage here
    return _currentUser;
  }
  
  Future<void> clearUser() async {
    _currentUser = null;
    // In a real app, we would clear from persistent storage here
  }
  
  Future<void> createGuestUser() async {
    await saveUser(User.guest());
  }
  
  Future<void> createDemoUser({
    required String loginName,
    required String email,
    required double balance,
  }) async {
    await saveUser(User.demo(
      loginName: loginName,
      email: email,
      balance: balance,
    ));
  }
}

