import 'package:flutter/material.dart';
import '../models/stock_search_result.dart';
import '../services/twelve_data_service.dart';

class BuyStocksPage extends StatefulWidget {
  const BuyStocksPage({Key? key}) : super(key: key);

  @override
  _BuyStocksPageState createState() => _BuyStocksPageState();
}

class _BuyStocksPageState extends State<BuyStocksPage> {
  final TwelveDataService _apiService = TwelveDataService();
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
      // Load popular stocks initially
      final results = await _apiService.searchStocks(_showStocks ? 'AAPL' : 'SPY');
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load initial stocks: $e';
        _isLoading = false;
      });
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

  void _showBuyDialog(StockSearchResult stock) {
    final TextEditingController quantityController = TextEditingController(text: '1');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Buy ${stock.symbol}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Company: ${stock.name}'),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Here you would implement the actual purchase logic
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Purchased ${quantityController.text} shares of ${stock.symbol}'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Confirm Purchase'),
          ),
        ],
      ),
    );
  }
}

