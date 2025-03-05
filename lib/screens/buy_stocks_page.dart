import 'package:flutter/material.dart';
import '../services/alpha_vantage_service.dart';
import '../models/stock_quote.dart';
import '../models/stock_search_result.dart';

class BuyStocksPage extends StatefulWidget {
  const BuyStocksPage({Key? key}) : super(key: key);

  @override
  _BuyStocksPageState createState() => _BuyStocksPageState();
}

class _BuyStocksPageState extends State<BuyStocksPage> {
  final AlphaVantageService _apiService = AlphaVantageService();
  bool _isLoading = true;
  bool _showStocks = true;
  String _searchQuery = '';
  
  List<StockQuote> _stockQuotes = [];
  List<StockQuote> _indexQuotes = [];
  List<StockSearchResult> _searchResults = [];
  
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }
  
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load popular stocks
      List<String> popularStocks = ['AAPL', 'MSFT', 'GOOGL', 'AMZN', 'TSLA', 'META', 'NFLX'];
      List<StockQuote> quotes = await _apiService.getTopMovers(popularStocks);
      
      // Load market indices
      List<StockQuote> indices = await _apiService.getMarketIndices();
      
      setState(() {
        _stockQuotes = quotes;
        _indexQuotes = indices;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading initial data: $e');
      setState(() {
        _isLoading = false;
      });
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          backgroundColor: Colors.red,
        ),
      );
      
      // Use fallback data if API fails
      _loadFallbackData();
    }
  }
  
  void _loadFallbackData() {
    // Fallback data in case API fails
    _stockQuotes = [
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
      // Add more fallback data as needed
    ];
    
    _indexQuotes = [
      StockQuote(
        symbol: 'SPY',
        open: 510.34,
        high: 512.50,
        low: 508.20,
        price: 510.34,
        volume: 78901200,
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
        volume: 12345600,
        latestTradingDay: '2023-05-01',
        previousClose: 382.90,
        change: 2.77,
        changePercent: 0.0071,
      ),
      // Add more fallback data as needed
    ];
  }
  
  Future<void> _searchStocks(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      List<StockSearchResult> results = await _apiService.searchStocks(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      print('Error searching stocks: $e');
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching stocks: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Stocks & ETFs'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildToggleButtons(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchQuery.isNotEmpty && _searchResults.isNotEmpty
                    ? _buildSearchResultsView()
                    : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search stocks or ETFs...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
          _searchStocks(value);
        },
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _showStocks = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _showStocks ? Colors.blue : Colors.grey[300],
                foregroundColor: _showStocks ? Colors.white : Colors.black,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
              ),
              child: const Text('Stocks'),
            ),
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _showStocks = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: !_showStocks ? Colors.blue : Colors.grey[300],
                foregroundColor: !_showStocks ? Colors.white : Colors.black,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
              ),
              child: const Text('ETFs/Indices'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Text(
                result.symbol[0],
                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              result.symbol,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.name),
                const SizedBox(height: 4),
                Text(
                  '${result.type} • ${result.region}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () async {
                try {
                  final quote = await _apiService.getQuote(result.symbol);
                  _showBuyDialog(context, quote);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error fetching quote: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text('BUY'),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildListView() {
    final dataList = _showStocks ? _stockQuotes : _indexQuotes;
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        final quote = dataList[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Text(
                quote.symbol[0],
                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              quote.symbol,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getCompanyName(quote.symbol)),
                const SizedBox(height: 4),
                Text(
                  '\$${quote.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  quote.changePercentFormatted,
                  style: TextStyle(
                    color: quote.isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    _showBuyDialog(context, quote);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('BUY'),
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  void _showBuyDialog(BuildContext context, StockQuote quote) {
    int quantity = 1;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Buy ${quote.symbol}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_getCompanyName(quote.symbol)} (${quote.symbol})'),
                  const SizedBox(height: 8),
                  Text('Current price: \$${quote.price.toStringAsFixed(2)}'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Quantity: '),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() {
                              quantity--;
                            });
                          }
                        },
                      ),
                      Text('$quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Total: \$${(quote.price * quantity).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Here you would implement the actual purchase logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Successfully purchased $quantity shares of ${quote.symbol}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('CONFIRM PURCHASE'),
                ),
              ],
            );
          }
        );
      },
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
      'SPY': 'S&P 500 ETF',
      'DIA': 'Dow Jones ETF',
      'QQQ': 'Nasdaq 100 ETF',
      'IWM': 'Russell 2000 ETF',
    };
    
    return companyNames[symbol] ?? 'Unknown Company';
  }
}

