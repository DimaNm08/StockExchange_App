import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/user_service.dart';
import '../services/finnhub_service.dart';
import '../models/stock_quote.dart';
import '../models/portfolio_item.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({Key? key}) : super(key: key);

  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final FinnhubService _apiService = FinnhubService();
  final UserService _userService = UserService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _portfolioWithQuotes = [];
  double _portfolioValue = 0.0;
  double _portfolioGrowth = 0.0;
  
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
      // Get user's portfolio
      final portfolio = _userService.getPortfolio();
      
      if (portfolio.isEmpty) {
        setState(() {
          _portfolioWithQuotes = [];
          _portfolioValue = 0.0;
          _portfolioGrowth = 0.0;
          _isLoading = false;
        });
        return;
      }
      
      // Get current quotes for all portfolio items
      List<Map<String, dynamic>> portfolioWithQuotes = [];
      double totalValue = 0.0;
      double totalCost = 0.0;
      
      for (var item in portfolio) {
        // Get current quote
        final quote = await _apiService.getQuote(item.symbol);
        
        // Calculate current value and gain/loss
        final currentValue = quote.price * item.quantity;
        final purchaseCost = item.purchasePrice * item.quantity;
        final gainLoss = currentValue - purchaseCost;
        final gainLossPercent = purchaseCost > 0 ? (gainLoss / purchaseCost) : 0.0;
        
        totalValue += currentValue;
        totalCost += purchaseCost;
        
        portfolioWithQuotes.add({
          'item': item,
          'quote': quote,
          'currentValue': currentValue,
          'gainLoss': gainLoss,
          'gainLossPercent': gainLossPercent,
        });
      }
      
      // Calculate overall portfolio growth
      final portfolioGrowth = totalCost > 0 ? ((totalValue - totalCost) / totalCost) : 0.0;
      
      setState(() {
        _portfolioWithQuotes = portfolioWithQuotes;
        _portfolioValue = totalValue;
        _portfolioGrowth = portfolioGrowth;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading portfolio data: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
    final user = _userService.currentUser;
    final balance = user?.balance ?? 0.0;
    final isDemo = user?.isDemo ?? false;
    
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
            if (_portfolioValue > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _portfolioGrowth >= 0 ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_portfolioGrowth >= 0 ? '+' : ''}${(_portfolioGrowth * 100).toStringAsFixed(2)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        if (_portfolioValue > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Portfolio Value: \$${_portfolioValue.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPortfolioChart() {
    // Only show chart if there are portfolio items
    if (_portfolioWithQuotes.isEmpty) {
      return const SizedBox.shrink();
    }
    
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
        _portfolioWithQuotes.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No assets found.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Start investing to build your portfolio.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/buy_stocks');
                      },
                      child: const Text('Buy Stocks'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _portfolioWithQuotes.length,
                itemBuilder: (context, index) {
                  final item = _portfolioWithQuotes[index]['item'] as PortfolioItem;
                  final quote = _portfolioWithQuotes[index]['quote'] as StockQuote;
                  final currentValue = _portfolioWithQuotes[index]['currentValue'] as double;
                  final gainLoss = _portfolioWithQuotes[index]['gainLoss'] as double;
                  final gainLossPercent = _portfolioWithQuotes[index]['gainLossPercent'] as double;
                  
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.symbol,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${quote.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '${quote.changePercent >= 0 ? '+' : ''}${(quote.changePercent * 100).toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      color: quote.isPositive ? Colors.green : Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Quantity: ${item.quantity}'),
                              Text('Avg. Price: \$${item.purchasePrice.toStringAsFixed(2)}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Current Value: \$${currentValue.toStringAsFixed(2)}'),
                              Text(
                                '${gainLoss >= 0 ? '+' : ''}\$${gainLoss.toStringAsFixed(2)} (${(gainLossPercent * 100).toStringAsFixed(2)}%)',
                                style: TextStyle(
                                  color: gainLoss >= 0 ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
}

