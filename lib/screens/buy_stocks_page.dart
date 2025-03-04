import 'package:flutter/material.dart';

class BuyStocksPage extends StatefulWidget {
  const BuyStocksPage({Key? key}) : super(key: key);

  @override
  _BuyStocksPageState createState() => _BuyStocksPageState();
}

class _BuyStocksPageState extends State<BuyStocksPage> {
  final List<Map<String, dynamic>> _availableStocks = [
    {'symbol': 'AAPL', 'name': 'Apple Inc.', 'price': 178.72, 'change': '+0.63%'},
    {'symbol': 'MSFT', 'name': 'Microsoft Corporation', 'price': 417.88, 'change': '+1.25%'},
    {'symbol': 'GOOGL', 'name': 'Alphabet Inc.', 'price': 175.98, 'change': '+0.89%'},
    {'symbol': 'AMZN', 'name': 'Amazon.com Inc.', 'price': 178.15, 'change': '-0.85%'},
    {'symbol': 'TSLA', 'name': 'Tesla, Inc.', 'price': 177.67, 'change': '+2.14%'},
    {'symbol': 'META', 'name': 'Meta Platforms, Inc.', 'price': 474.99, 'change': '+0.89%'},
    {'symbol': 'NFLX', 'name': 'Netflix, Inc.', 'price': 605.88, 'change': '+1.28%'},
  ];

  final List<Map<String, dynamic>> _availableIndices = [
    {'symbol': 'SPY', 'name': 'S&P 500 ETF', 'price': 510.34, 'change': '+0.56%'},
    {'symbol': 'DIA', 'name': 'Dow Jones ETF', 'price': 385.67, 'change': '+0.71%'},
    {'symbol': 'QQQ', 'name': 'Nasdaq 100 ETF', 'price': 430.12, 'change': '+0.92%'},
    {'symbol': 'IWM', 'name': 'Russell 2000 ETF', 'price': 201.45, 'change': '+0.33%'},
  ];

  bool _showStocks = true;
  String _searchQuery = '';
  
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
            child: _buildListView(),
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

  Widget _buildListView() {
    final dataList = _showStocks ? _availableStocks : _availableIndices;
    final filteredList = dataList.where((item) {
      return item['symbol'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
             item['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final item = filteredList[index];
        final isPositive = item['change'].toString().contains('+');
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Text(
                item['symbol'][0],
                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              item['symbol'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name']),
                const SizedBox(height: 4),
                Text(
                  '\$${item['price']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item['change'],
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    _showBuyDialog(context, item);
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

  void _showBuyDialog(BuildContext context, Map<String, dynamic> item) {
    int quantity = 1;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Buy ${item['symbol']}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${item['name']} (${item['symbol']})'),
                  const SizedBox(height: 8),
                  Text('Current price: \$${item['price']}'),
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
                    'Total: \$${(item['price'] * quantity).toStringAsFixed(2)}',
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
                        content: Text('Successfully purchased $quantity shares of ${item['symbol']}'),
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
}

