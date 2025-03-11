import 'package:flutter/material.dart';
import '../models/stock_search_result.dart';
import '../services/finnhub_service.dart';
import '../services/user_service.dart';
import 'dart:math' as Math;

class BuyStocksPage extends StatefulWidget {
  const BuyStocksPage({Key? key}) : super(key: key);

  @override
  _BuyStocksPageState createState() => _BuyStocksPageState();
}

class _BuyStocksPageState extends State<BuyStocksPage> {
  final FinnhubService _apiService = FinnhubService();
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();
  List<StockSearchResult> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _showStocks = true; // true for stocks, false for ETFs/indices

  @override
  void initState() {
    super.initState();
    // Load some initial popular stocks
    _loadInitialStocks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialStocks() async {
  setState(() {
    _isLoading = true;
    _errorMessage = '';
  });

  try {
    List<StockSearchResult> results = [];
    
    if (_showStocks) {
      // Load popular stocks
      final popularStocks = [
        'AAPL', 'MSFT', 'GOOGL', 'AMZN', 'META', 'TSLA', 'NVDA', 
        'JPM', 'BAC', 'WMT', 'DIS', 'NFLX', 'INTC', 'AMD', 'PYPL',
        'ADBE', 'CSCO', 'CRM', 'CMCSA', 'PEP', 'KO', 'NKE', 'MCD',
        'V', 'MA', 'HD', 'PG', 'JNJ', 'UNH', 'XOM'
      ];
      
      // Process stocks in batches to avoid rate limiting
      for (int i = 0; i < Math.min(10, popularStocks.length); i++) {
        try {
          final stockResults = await _apiService.searchStocks(popularStocks[i]);
          if (stockResults.isNotEmpty) {
            // Add the first result which should be the exact match
            results.add(stockResults.first);
          }
          
          // Add a small delay between requests
          if (i < popularStocks.length - 1) {
            await Future.delayed(Duration(milliseconds: 100));
          }
        } catch (e) {
          print('Error loading stock ${popularStocks[i]}: $e');
        }
      }
    } else {
      // Load popular ETFs and indices
      final popularETFs = [
        'SPY', 'QQQ', 'DIA', 'IWM', 'VTI', 'VOO', 'VEA', 'VWO',
        'BND', 'AGG', 'GLD', 'SLV', 'XLF', 'XLK', 'XLE', 'XLV'
      ];
      
      // Process ETFs in batches to avoid rate limiting
      for (int i = 0; i < Math.min(8, popularETFs.length); i++) {
        try {
          final etfResults = await _apiService.searchStocks(popularETFs[i]);
          if (etfResults.isNotEmpty) {
            // Add the first result which should be the exact match
            results.add(etfResults.first);
          }
          
          // Add a small delay between requests
          if (i < popularETFs.length - 1) {
            await Future.delayed(Duration(milliseconds: 100));
          }
        } catch (e) {
          print('Error loading ETF ${popularETFs[i]}: $e');
        }
      }
    }
    
    // If API calls failed, use fallback data
    if (results.isEmpty) {
      results = _getFallbackPopularStocks(_showStocks);
    }
    
    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _errorMessage = 'Failed to load initial stocks: $e';
      _isLoading = false;
      // Use fallback data on error
      _searchResults = _getFallbackPopularStocks(_showStocks);
    });
  }
}

// Add this method to provide fallback data if API calls fail
List<StockSearchResult> _getFallbackPopularStocks(bool showStocks) {
  if (showStocks) {
    // Popular stocks
    return [
      StockSearchResult(
        symbol: 'AAPL',
        name: 'Apple Inc.',
        type: 'Equity',
        region: 'United States',
        marketOpen: '09:30',
        marketClose: '16:00',
        timezone: 'UTC-05',
        currency: 'USD',
        matchScore: 1.0,
      ),
      StockSearchResult(
        symbol: 'MSFT',
        name: 'Microsoft Corporation',
        type: 'Equity',
        region: 'United States',
        marketOpen: '09:30',
        marketClose: '16:00',
        timezone: 'UTC-05',
        currency: 'USD',
        matchScore: 1.0,
      ),
      StockSearchResult(
        symbol: 'GOOGL',
        name: 'Alphabet Inc.',
        type: 'Equity',
        region: 'United States',
        marketOpen: '09:30',
        marketClose: '16:00',
        timezone: 'UTC-05',
        currency: 'USD',
        matchScore: 1.0,
      ),
      StockSearchResult(
        symbol: 'AMZN',
        name: 'Amazon.com Inc.',
        type: 'Equity',
        region: 'United States',
        marketOpen: '09:30',
        marketClose: '16:00',
        timezone: 'UTC-05',
        currency: 'USD',
        matchScore: 1.0,
      ),
      StockSearchResult(
        symbol: 'META',
        name: 'Meta Platforms Inc.',
        type: 'Equity',
        region: 'United States',
        marketOpen: '09:30',
        marketClose: '16:00',
        timezone: 'UTC-05',
        currency: 'USD',
        matchScore: 1.0,
      ),
      StockSearchResult(
        symbol: 'TSLA',
        name: 'Tesla Inc.',
        type: 'Equity',
        region: 'United States',
        marketOpen: '09:30',
        marketClose: '16:00',
        timezone: 'UTC-05',
        currency: 'USD',
        matchScore: 1.0,
      ),
      StockSearchResult(
        symbol: 'NVDA',
        name: 'NVIDIA Corporation',
        type: 'Equity',
        region: 'United States',
        marketOpen: '09:30',
        marketClose: '16:00',
        timezone: 'UTC-05',
        currency: 'USD',
        matchScore: 1.0,
      ),
      StockSearchResult(
        symbol: 'JPM',
        name: 'JPMorgan Chase & Co.',
        type: 'Equity',
        region: 'United States',
        marketOpen: '09:30',
        marketClose: '16:00',
        timezone: 'UTC-05',
        currency: 'USD',
        matchScore: 1.0,
      ),
      StockSearchResult(
        symbol: 'V',
        name: 'Visa Inc.',
        type: 'Equity',
        region: 'United States',
        marketOpen: '09:30',
        marketClose: '16:00',
        timezone: 'UTC-05',
        currency: 'USD',
        matchScore: 1.0,
      ),
      StockSearchResult(
        symbol: 'WMT',
        name: 'Walmart Inc.',
        type: 'Equity',
        region: 'United States',
        marketOpen: '09:30',
        marketClose: '16:00',
        timezone: 'UTC-05',
        currency: 'USD',
        matchScore: 1.0,
      ),
    ];
  } else {
    // Popular ETFs and indices
    return [
      StockSearchResult(
        symbol: 'SPY',
        name: 'SPDR S&P 500 ETF Trust',
        type: 'ETF',
        region: 'United States',
        marketOpen: '09:30',
        marketClose: '16:00',
        timezone: 'UTC-05',
        currency: 'USD',
        matchScore: 1.0,
      ),
      StockSearchResult(
        symbol: 'QQQ',
        name: 'Invesco QQQ Trust',
        type: 'ETF',
        region: 'United States',
        marketOpen: '09:30',
        marketClose: '16:00',
        timezone: 'UTC-05',
        currency: 'USD',
        matchScore: 1.0,
      ),
      StockSearchResult(
        symbol: 'DIA',
        name: 'SPDR Dow Jones Industrial Average ETF',
        type: 'ETF',
        region: 'United States',
        marketOpen: '09:30',
        marketClose: '16:00',
        timezone: 'UTC-05',
        currency: 'USD',
        matchScore: 1.0,
      ),
      StockSearchResult(
        symbol: 'IWM',
        name: 'iShares Russell 2000 ETF',
        type: 'ETF',
        region: 'United States',
        marketOpen: '09:30',
        marketClose: '16:00',
        timezone: 'UTC-05',
        currency: 'USD',
        matchScore: 1.0,
      ),
      StockSearchResult(
        symbol: 'VTI',
        name: 'Vanguard Total Stock Market ETF',
        type: 'ETF',
        region: 'United States',
        marketOpen: '09:30',
        marketClose: '16:00',
        timezone: 'UTC-05',
        currency: 'USD',
        matchScore: 1.0,
      ),
      StockSearchResult(
        symbol: 'GLD',
        name: 'SPDR Gold Shares',
        type: 'ETF',
        region: 'United States',
        marketOpen: '09:30',
        marketClose: '16:00',
        timezone: 'UTC-05',
        currency: 'USD',
        matchScore: 1.0,
      ),
      StockSearchResult(
        symbol: 'XLF',
        name: 'Financial Select Sector SPDR Fund',
        type: 'ETF',
        region: 'United States',
        marketOpen: '09:30',
        marketClose: '16:00',
        timezone: 'UTC-05',
        currency: 'USD',
        matchScore: 1.0,
      ),
      StockSearchResult(
        symbol: 'XLK',
        name: 'Technology Select Sector SPDR Fund',
        type: 'ETF',
        region: 'United States',
        marketOpen: '09:30',
        marketClose: '16:00',
        timezone: 'UTC-05',
        currency: 'USD',
        matchScore: 1.0,
      ),
    ];
  }
}

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      _loadInitialStocks();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final results = await _apiService.searchStocks(query);
      
      // Filter by type if needed
      final filteredResults = _showStocks
          ? results.where((result) => result.type.toLowerCase().contains('equity')).toList()
          : results.where((result) => 
              result.type.toLowerCase().contains('etf') || 
              result.type.toLowerCase().contains('index')).toList();
      
      setState(() {
        _searchResults = filteredResults;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Search failed: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Stocks & ETFs'),
      ),
      body: Column(
        children: [
          // Toggle between stocks and ETFs
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: true,
                  label: Text('Stocks'),
                  icon: Icon(Icons.trending_up),
                ),
                ButtonSegment<bool>(
                  value: false,
                  label: Text('ETFs & Indices'),
                  icon: Icon(Icons.bar_chart),
                ),
              ],
              selected: {_showStocks},
              onSelectionChanged: (Set<bool> selection) {
                setState(() {
                  _showStocks = selection.first;
                  // Reload with appropriate initial data
                  _searchController.clear();
                  _loadInitialStocks();
                });
              },
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for ${_showStocks ? 'stocks' : 'ETFs & indices'}',
                hintText: 'Enter name or symbol',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadInitialStocks();
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                if (value.length >= 2) {
                  _performSearch(value);
                } else if (value.isEmpty) {
                  _loadInitialStocks();
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          // Results list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_errorMessage, textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _searchController.text.isEmpty
                                  ? _loadInitialStocks()
                                  : _performSearch(_searchController.text),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _searchResults.isEmpty
                        ? Center(
                            child: Text(
                              'No ${_showStocks ? 'stocks' : 'ETFs'} found. Try a different search term.',
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final result = _searchResults[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text(result.symbol.substring(0, 1)),
                                ),
                                title: Text(result.symbol),
                                subtitle: Text(result.name),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    // Show buy dialog
                                    _showBuyDialog(result);
                                  },
                                  child: const Text('Buy'),
                                ),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/stock_details',
                                    arguments: result.symbol,
                                  );
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  void _showBuyDialog(StockSearchResult stock) async {
    final TextEditingController quantityController = TextEditingController(text: '1');
    
    // Get current stock price
    final stockQuote = await _apiService.getQuote(stock.symbol);
    final currentPrice = stockQuote.price;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Buy ${stock.symbol}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Company: ${stock.name}'),
            const SizedBox(height: 8),
            Text('Current Price: \$${currentPrice.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Available Balance: \$${_userService.currentUser?.balance.toStringAsFixed(2) ?? '0.00'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Parse quantity
              final quantity = int.tryParse(quantityController.text) ?? 0;
              
              if (quantity <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid quantity'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              // Calculate total cost
              final totalCost = currentPrice * quantity;
              
              // Check if user has enough balance
              if (_userService.currentUser == null || 
                  _userService.currentUser!.balance < totalCost) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Insufficient balance'),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.pop(context);
                return;
              }
              
              // Add to portfolio
              final success = await _userService.addToPortfolio(
                stock, 
                quantity, 
                currentPrice
              );
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Purchased $quantity shares of ${stock.symbol}'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to purchase ${stock.symbol}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              
              Navigator.pop(context);
            },
            child: const Text('Confirm Purchase'),
          ),
        ],
      ),
    );
  }
}

