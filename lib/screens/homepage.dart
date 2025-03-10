import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/finnhub_service.dart';
import '../models/stock_quote.dart';
import '../services/user_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FinnhubService _apiService = FinnhubService();
  bool _isLoading = true;
  List<StockQuote> _watchlistQuotes = [];
  List<StockQuote> _popularStockQuotes = [];
  List<StockQuote> _marketIndices = [];
  
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
      // Load watchlist stocks
      List<String> watchlistSymbols = ['AMZN', 'ADBE'];
      List<StockQuote> watchlist = await _apiService.getTopMovers(watchlistSymbols);
      
      // Load popular stocks
      List<String> popularStocks = ['NFLX', 'AAPL', 'META'];
      List<StockQuote> popular = await _apiService.getTopMovers(popularStocks);
      
      // Load market indices
      List<StockQuote> indices = await _apiService.getMarketIndices();
      
      setState(() {
        _watchlistQuotes = watchlist;
        _popularStockQuotes = popular;
        _marketIndices = indices;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
      
      // Use fallback data if API fails
      _loadFallbackData();
    }
  }
  
  void _loadFallbackData() {
    // Fallback data for watchlist
    _watchlistQuotes = [
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
        symbol: 'ADBE',
        open: 420.50,
        high: 425.00,
        low: 418.00,
        price: 420.50,
        volume: 2345678,
        latestTradingDay: '2023-05-01',
        previousClose: 419.50,
        change: 1.00,
        changePercent: 0.0022,
      ),
    ];
    
    // Fallback data for popular stocks
    _popularStockQuotes = [
      StockQuote(
        symbol: 'NFLX',
        open: 605.88,
        high: 610.00,
        low: 600.00,
        price: 605.88,
        volume: 3456789,
        latestTradingDay: '2023-05-01',
        previousClose: 598.20,
        change: 7.68,
        changePercent: 0.0128,
      ),
      StockQuote(
        symbol: 'AAPL',
        open: 178.72,
        high: 180.00,
        low: 177.00,
        price: 178.72,
        volume: 45678901,
        latestTradingDay: '2023-05-01',
        previousClose: 177.60,
        change: 1.12,
        changePercent: 0.0063,
      ),
      StockQuote(
        symbol: 'META',
        open: 474.99,
        high: 480.00,
        low: 470.00,
        price: 474.99,
        volume: 5678901,
        latestTradingDay: '2023-05-01',
        previousClose: 470.20,
        change: 4.79,
        changePercent: 0.0089,
      ),
    ];
    
    // Fallback data for market indices
    _marketIndices = [
      StockQuote(
        symbol: 'SPY',
        open: 510.34,
        high: 512.00,
        low: 508.00,
        price: 510.34,
        volume: 67890123,
        latestTradingDay: '2023-05-01',
        previousClose: 507.50,
        change: 2.84,
        changePercent: 0.0056,
      ),
      StockQuote(
        symbol: 'DIA',
        open: 385.67,
        high: 388.00,
        low: 384.00,
        price: 385.67,
        volume: 7890123,
        latestTradingDay: '2023-05-01',
        previousClose: 382.90,
        change: 2.77,
        changePercent: 0.0071,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildPortfolioValue(),
                          const SizedBox(height: 24),
                          _buildMarketIndices(),
                          const SizedBox(height: 24),
                          _buildWatchlist(),
                          const SizedBox(height: 24),
                          _buildStocksList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/buy_stocks');
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(icon: const Icon(Icons.home), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
          const SizedBox(width: 32),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.pushNamed(context, '/portfolio');
            },
          ),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'StockXA',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioValue() {
  final user = UserService().currentUser;
  final balance = user?.balance ?? 13240.11; // Default value if no user
  final isDemo = user?.isDemo ?? false;
  
  // Calculate a random daily change for demo purposes
  final changePercent = 0.012; // 1.2%
  final change = balance * changePercent;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Text(
            'Portfolio value',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
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
        children: [
          Text(
            '\$${balance.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '+${(changePercent * 100).toStringAsFixed(1)}% (\$${change.toStringAsFixed(2)})',
              style: TextStyle(
                color: Colors.green[700],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      SizedBox(
        height: 100,
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
                color: Colors.green,
                barWidth: 2,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.green.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

  Widget _buildMarketIndices() {
    return Row(
      children: [
        Expanded(
          child: _buildIndexCard(
            _marketIndices.isNotEmpty ? _marketIndices[0].symbol : 'S&P 500',
            _marketIndices.isNotEmpty ? _marketIndices[0].changePercentFormatted : '+0.56%',
            _marketIndices.isNotEmpty && _marketIndices[0].isPositive ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildIndexCard(
            _marketIndices.length > 1 ? _marketIndices[1].symbol : 'DOW',
            _marketIndices.length > 1 ? _marketIndices[1].changePercentFormatted : '+0.71%',
            _marketIndices.length > 1 && _marketIndices[1].isPositive ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildIndexCard(String name, String change, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            change,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlist() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Watchlist',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {},
            ),
          ],
        ),
        for (var quote in _watchlistQuotes)
          _buildStockItem(
            quote.symbol,
            _getCompanyName(quote.symbol),
            quote.changePercentFormatted,
            quote.isPositive ? Colors.green : Colors.red,
          ),
      ],
    );
  }

  Widget _buildStocksList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stocks',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        for (var quote in _popularStockQuotes)
          _buildStockItem(
            quote.symbol,
            _getCompanyName(quote.symbol),
            quote.changePercentFormatted,
            quote.isPositive ? Colors.green : Colors.red,
          ),
      ],
    );
  }

  Widget _buildStockItem(String symbol, String name, String change, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: Text(
              symbol[0],
              style: const TextStyle(color: Colors.black),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symbol,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            height: 30,
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
                    ],
                    isCurved: true,
                    color: color,
                    barWidth: 1,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            change,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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

