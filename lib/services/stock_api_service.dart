// lib/services/stock_api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class StockApiService {
  static const String apiKey = 'KGU3IX75YL0D4RJD'; // Replace with your key
  static const String baseUrl = 'https://www.alphavantage.co/query';

  // Get real-time stock data
  Future<Map<String, dynamic>> getStockQuote(String symbol) async {
    final response = await http.get(
      Uri.parse('$baseUrl?function=GLOBAL_QUOTE&symbol=$symbol&apikey=$apiKey'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load stock data');
    }
  }

  // Get historical data for charts
  Future<List<Map<String, dynamic>>> getHistoricalData(String symbol) async {
    final response = await http.get(
      Uri.parse('$baseUrl?function=TIME_SERIES_DAILY&symbol=$symbol&apikey=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final timeSeries = data['Time Series (Daily)'] as Map<String, dynamic>;
      
      return timeSeries.entries.map((entry) {
        final values = entry.value as Map<String, dynamic>;
        return {
          'date': entry.key,
          'close': double.parse(values['4. close']),
          'open': double.parse(values['1. open']),
          'high': double.parse(values['2. high']),
          'low': double.parse(values['3. low']),
          'volume': double.parse(values['5. volume']),
        };
      }).toList();
    } else {
      throw Exception('Failed to load historical data');
    }
  }
}