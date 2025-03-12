import 'package:flutter/material.dart';
import 'screens/onboarding.dart';
import 'screens/homepage.dart';
import 'screens/signin.dart';
import 'screens/account.dart';
import 'screens/search_page.dart';
import 'screens/portofolio_page.dart';
import 'screens/buy_stocks_page.dart';
import 'screens/account_selection_screen.dart';
import 'screens/demo_setup_screen.dart';
import 'services/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize user service
  await UserService().init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StockXA',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      initialRoute: _getInitialRoute(),
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/signup': (context) => AccountSelectionScreen(),
        '/signin': (context) => const SignInScreen(),
        '/homepage': (context) => const HomePage(),
        '/account': (context) => const AccountScreen(),
        '/search': (context) => const SearchPage(),
        '/portfolio': (context) => const PortfolioPage(),
        '/buy_stocks': (context) => const BuyStocksPage(),
        '/demo_setup': (context) => const DemoSetupScreen(),
      },
    );
  }
  
  String _getInitialRoute() {
    // If user is already logged in, go to home page
    // Otherwise, go to onboarding screen
    return UserService().isLoggedIn ? '/homepage' : '/';
  }
}

