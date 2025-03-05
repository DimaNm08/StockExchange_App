import 'package:flutter/material.dart';
import '../services/alpha_vantage_service.dart';
import '../models/stock_search_result.dart';
import '../models/stock_quote.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final AlphaVantageService _apiService = AlphaVantageService();
  
  List<StockSearchResult> _searchResults = [];
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
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
      
      // Use fallback data if API fails
      _loadFallbackData(query);
    }
  }
  
  void _loadFallbackData(String query) {
    List<Map<String, String>> stocks = [
      {"symbol": "AAPL", "name": "Apple Inc."},
      {"symbol": "GOOGL", "name": "Alphabet Inc."},
      {"symbol": "MSFT", "name": "Microsoft Corporation"},
      {"symbol": "AMZN", "name": "Amazon.com Inc."},
      {"symbol": "FB", "name": "Meta Platforms, Inc."},
      {"symbol": "TSLA", "name": "Tesla, Inc."},
      {"symbol": "NVDA", "name": "NVIDIA Corporation"},
      {"symbol": "JPM", "name": "JPMorgan Chase & Co."},
      {"symbol": "V", "name": "Visa Inc."},
      {"symbol": "JNJ", "name": "Johnson & Johnson"},
      {"symbol": "WMT", "name": "Walmart Inc."},
      {"symbol": "MA", "name": "Mastercard Incorporated"},
      {"symbol": "PG", "name": "Procter & Gamble Company"},
      {"symbol": "DIS", "name": "The Walt Disney Company"},
      {"symbol": "ADBE", "name": "Adobe Inc."},
    ];
    
    _searchResults = stocks
        .where((stock) =>
            stock["symbol"]!.toLowerCase().contains(query.toLowerCase()) ||
            stock["name"]!.toLowerCase().contains(query.toLowerCase()))
        .map((stock) => StockSearchResult(
              symbol: stock["symbol"]!,
              name: stock["name"]!,
              type: "Equity",
              region: "United States",
              marketOpen: "09:30",
              marketClose: "16:00",
              timezone: "UTC-05",
              currency: "USD",
              matchScore: 1.0,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Stocks'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _searchStocks,
              decoration: InputDecoration(
                hintText: 'Search for stocks...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty && _searchController.text.isNotEmpty
                    ? const Center(child: Text('No results found'))
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final result = _searchResults[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue[100],
                              child: Text(
                                result.symbol[0],
                                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(result.symbol),
                            subtitle: Text(result.name),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () async {
                              try {
                                // Show loading indicator
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                );
                                
                                // Get quote data
                                StockQuote quote = await _apiService.getQuote(result.symbol);
                                
                                // Close loading indicator
                                Navigator.of(context).pop();
                                
                                // Show stock details
                                _showStockDetails(context, quote, result);
                              } catch (e) {
                                // Close loading indicator
                                Navigator.of(context).pop();
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error fetching stock details: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
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
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
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
  
  void _showStockDetails(BuildContext context, StockQuote quote, StockSearchResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.6,
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
                        quote.symbol,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        result.name,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\$${quote.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '${quote.change >= 0 ? '+' : ''}${quote.change.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: quote.isPositive ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: quote.isPositive ? Colors.green[50] : Colors.red[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              quote.changePercentFormatted,
                              style: TextStyle(
                                color: quote.isPositive ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    'Updated: ${quote.latestTradingDay}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStockStat('Open', '\$${quote.open.toStringAsFixed(2)}'),
                  _buildStockStat('High', '\$${quote.high.toStringAsFixed(2)}'),
                  _buildStockStat('Low', '\$${quote.low.toStringAsFixed(2)}'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStockStat('Prev Close', '\$${quote.previousClose.toStringAsFixed(2)}'),
                  _buildStockStat('Volume', _formatVolume(quote.volume)),
                  _buildStockStat('Currency', result.currency),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/buy_stocks');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'BUY THIS STOCK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildStockStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  String _formatVolume(int volume) {
    if (volume >= 1000000000) {
      return '${(volume / 1000000000).toStringAsFixed(1)}B';
    } else if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K';
    } else {
      return volume.toString();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

