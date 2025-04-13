import '../models/user.dart';
import '../models/portfolio_item.dart';
import '../models/stock_search_result.dart';

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
  
  // Update createDemoUser method in UserService
Future<void> createDemoUser({
  required String loginName,
  required String email,
  required String password,  // Add this line
  required double balance,
}) async {
  await saveUser(User.demo(
    loginName: loginName,
    email: email,
    password: password,  // Add this line
    balance: balance,
  ));
}
  
  // Add a stock to the user's portfolio
  Future<bool> addToPortfolio(StockSearchResult stock, int quantity, double price) async {
    if (_currentUser == null) return false;
    
    // Create a new portfolio item
    final portfolioItem = PortfolioItem(
      symbol: stock.symbol,
      name: stock.name,
      quantity: quantity,
      purchasePrice: price,
      purchaseDate: DateTime.now(),
    );
    
    // Calculate the total cost
    final totalCost = price * quantity;
    
    // Check if user has enough balance
    if (_currentUser!.balance < totalCost) return false;
    
    // Create a new portfolio list with the added item
    final updatedPortfolio = List<PortfolioItem>.from(_currentUser!.portfolio);
    
    // Check if the stock is already in the portfolio
    final existingItemIndex = updatedPortfolio.indexWhere(
      (item) => item.symbol == stock.symbol
    );
    
    if (existingItemIndex >= 0) {
      // Update existing item
      final existingItem = updatedPortfolio[existingItemIndex];
      final updatedItem = PortfolioItem(
        symbol: existingItem.symbol,
        name: existingItem.name,
        quantity: existingItem.quantity + quantity,
        purchasePrice: (existingItem.purchasePrice * existingItem.quantity + price * quantity) / 
                      (existingItem.quantity + quantity), // Weighted average price
        purchaseDate: DateTime.now(),
      );
      updatedPortfolio[existingItemIndex] = updatedItem;
    } else {
      // Add new item
      updatedPortfolio.add(portfolioItem);
    }
    
    // Update user with new portfolio and reduced balance
    final updatedUser = _currentUser!.copyWith(
      portfolio: updatedPortfolio,
      balance: _currentUser!.balance - totalCost,
    );
    
    await saveUser(updatedUser);
    return true;
  }
  
  // Get the user's portfolio
  List<PortfolioItem> getPortfolio() {
    return _currentUser?.portfolio ?? [];
  }

  // Add money to the user's balance
  Future<bool> addMoneyToBalance(double amount) async {
    if (_currentUser == null) return false;
    
    // Update user with new balance
    final updatedUser = _currentUser!.copyWith(
      balance: _currentUser!.balance + amount,
    );
    
    await saveUser(updatedUser);
    return true;
  }
}
