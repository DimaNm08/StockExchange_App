import 'package:flutter/material.dart';
import '../screens/onboarding.dart';
import '../screens/signup.dart';
import '../screens/homepage.dart';
import '../screens/signin.dart';
import '../screens/account.dart';
import '../screens/search_page.dart';
import '../screens/portofolio_page.dart';
import '../screens/buy_stocks_page.dart';

void main() {
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
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/signup': (context) => const SignUpPage(),
        '/signin': (context) => const SignInScreen(),
        '/homepage': (context) => const HomePage(),
        '/account': (context) => const AccountPage(),
        '/search': (context) => const SearchPage(),
        '/portfolio': (context) => const PortfolioPage(),
        '/buy_stocks': (context) => const BuyStocksPage(),
      },
    );
  }
}

