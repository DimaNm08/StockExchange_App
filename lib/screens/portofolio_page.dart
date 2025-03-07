import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/user_service.dart';
import '../services/twelve_data_service.dart';
import '../models/stock_quote.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({Key? key}) : super(key: key);

  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final TwelveDataService _apiService = TwelveDataService();
  bool _isLoading = true;
  List<StockQuote> _topStocks = [];
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load top stocks as sample portfolio assets
      List<String> topStockSymbols = ['AAPL', 'MSFT', 'AMZN', 'GOOGL', 'TSLA'];
      List<StockQuote> stocks = await _apiService.getTopMovers(topStockSymbols);
      
      setState(() {
        _topStocks = stocks;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading portfolio data: $e');
      setState(() {
        _isLoading = false;
      });
      
      // Use fallback data if API fails
      _loadFallbackData();
    }
  }
  
  void _loadFallbackData() {
    _topStocks = [
      StockQuote(
        symbol: 'AAPL',
        open: 178.72,
        high: 180.25,
        low: 177.60,
        price: 178.72,
        volume: 65432100,
        latestTradingDay: '2023-05-01',
        previousClose: 177.00,
        change: 1.72,
        changePercent: 0.0063,
      ),
      StockQuote(
        symbol: 'MSFT',
        open: 417.88,
        high: 420.00,
        low: 415.50,
        price: 417.88,
        volume: 23456700,
        latestTradingDay: '2023-05-01',
        previousClose: 412.00,
        change: 5.88,
        changePercent: 0.0125,
      ),
      StockQuote(
        symbol: 'AMZN',
        open: 178.15,
        high: 180.00,
        low: 177.00,
        price: 178.15,
        volume: 12345678,
        latestTradingDay: '2023-05-01',
        previousClose: 179.50,
        change: -1.35,
        changePercent: -0.0085,
      ),
      StockQuote(
        symbol: 'GOOGL',
        open: 175.98,
        high: 177.50,
        low: 174.20,
        price: 175.98,
        volume: 34567800,
        latestTradingDay: '2023-05-01',
        previousClose: 174.30,
        change: 1.68,
        changePercent: 0.0089,
      ),
      StockQuote(
        symbol: 'TSLA',
        open: 177.67,
        high: 180.00,
        low: 175.00,
        price: 177.67,
        volume: 45678901,
        latestTradingDay: '2023-05-01',
        previousClose: 173.90,
        change: 3.77,
        changePercent: 0.0214,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Portfolio'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCurrentBalance(),
                      const SizedBox(height: 24),
                      _buildPortfolioChart(),
                      const SizedBox(height: 24),
                      _buildAssetsList(),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushNamed(context, '/homepage');
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
          const SizedBox(width: 32),
          IconButton(icon: const Icon(Icons.bar_chart), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/account');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentBalance() {
    final user = UserService().currentUser;
    final balance = user?.balance ?? 15750.23; // Default value if no user
    final isDemo = user?.isDemo ?? false;
    
    // Calculate portfolio growth (for demo purposes)
    final portfolioGrowth = 5.23;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Current Balance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isDemo)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: const Text(
                  'DEMO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${balance.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '+${portfolioGrowth.toStringAsFixed(2)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPortfolioChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Portfolio Performance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    const FlSpot(0, 3),
                    const FlSpot(2.6, 2),
                    const FlSpot(4.9, 5),
                    const FlSpot(6.8, 3.1),
                    const FlSpot(8, 4),
                    const FlSpot(9.5, 3),
                    const FlSpot(11, 4),
                  ],
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssetsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Assets',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _topStocks.isEmpty
            ? const Center(
                child: Text('No assets found. Start investing to build your portfolio.'),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _topStocks.length,
                itemBuilder: (context, index) {
                  final stock = _topStocks[index];
                  return Card(
                    child: ListTile(
                      title: Text(_getCompanyName(stock.symbol)),
                      subtitle: Text(stock.symbol),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${stock.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            stock.changePercentFormatted,
                            style: TextStyle(
                              color: stock.isPositive ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }
  
  String _getCompanyName(String symbol) {
    // This is a simple mapping function. In a real app, you might want to store this data
    // or fetch it from an API
    Map<String, String> companyNames = {
      'AAPL': 'Apple Inc.',
      'MSFT': 'Microsoft Corporation',
      'GOOGL': 'Alphabet Inc.',
      'AMZN': 'Amazon.com Inc.',
      'TSLA': 'Tesla, Inc.',
      'META': 'Meta Platforms, Inc.',
      'NFLX': 'Netflix, Inc.',
      'ADBE': 'Adobe, Inc.',
      'FB': 'Meta, Inc.',
      'SPY': 'S&P 500 ETF',
      'DIA': 'Dow Jones ETF',
      'QQQ': 'Nasdaq 100 ETF',
      'IWM': 'Russell 2000 ETF',
    };
    
    return companyNames[symbol] ?? 'Unknown Company';
  }
}

