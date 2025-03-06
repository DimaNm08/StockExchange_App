import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock.dart';
import '../models/stock_quote.dart';
import '../models/stock_search_result.dart';

class AlphaVantageService {
  static const String baseUrl = 'https://www.alphavantage.co/query';
  static const String apiKey = 'KGU3IX75YL0D4RJD'; // Replace with your Alpha Vantage API key
  
  // Get real-time quote for a symbol
  Future<StockQuote> getQuote(String symbol) async {
    final response = await http.get(
      Uri.parse('$baseUrl?function=GLOBAL_QUOTE&symbol=$symbol&apikey=$apiKey'),
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      if (data.containsKey('Global Quote')) {
        return StockQuote.fromJson(data['Global Quote']);
      } else if (data.containsKey('Note')) {
        throw Exception('API call frequency limit reached: ${data['Note']}');
      } else {
        throw Exception('Failed to load quote data');
      }
    } else {
      throw Exception('Failed to load quote: ${response.statusCode}');
    }
  }
  
  // Search for stocks by keywords
  Future<List<StockSearchResult>> searchStocks(String keywords) async {
    final response = await http.get(
      Uri.parse('$baseUrl?function=SYMBOL_SEARCH&keywords=$keywords&apikey=$apiKey'),
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      if (data.containsKey('bestMatches')) {
        List<dynamic> matches = data['bestMatches'];
        return matches.map((match) => StockSearchResult.fromJson(match)).toList();
      } else if (data.containsKey('Note')) {
        throw Exception('API call frequency limit reached: ${data['Note']}');
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to search stocks: ${response.statusCode}');
    }
  }
  
  // Get daily time series data for a symbol
  Future<Map<String, Stock>> getDailyTimeSeries(String symbol, {int outputSize = 100}) async {
    final response = await http.get(
      Uri.parse('$baseUrl?function=TIME_SERIES_DAILY&symbol=$symbol&outputsize=${outputSize > 100 ? 'full' : 'compact'}&apikey=$apiKey'),
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      if (data.containsKey('Time Series (Daily)')) {
        final Map<String, dynamic> timeSeries = data['Time Series (Daily)'];
        final Map<String, Stock> result = {};
        
        timeSeries.forEach((date, values) {
          result[date] = Stock.fromJson(values);
        });
        
        return result;
      } else if (data.containsKey('Note')) {
        throw Exception('API call frequency limit reached: ${data['Note']}');
      } else {
        throw Exception('Failed to load time series data');
      }
    } else {
      throw Exception('Failed to load time series: ${response.statusCode}');
    }
  }
  
  // Get intraday time series data for a symbol
  Future<Map<String, Stock>> getIntradayTimeSeries(String symbol, {String interval = '5min'}) async {
    final response = await http.get(
      Uri.parse('$baseUrl?function=TIME_SERIES_INTRADAY&symbol=$symbol&interval=$interval&apikey=$apiKey'),
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String timeSeriesKey = 'Time Series ($interval)';
      
      if (data.containsKey(timeSeriesKey)) {
        final Map<String, dynamic> timeSeries = data[timeSeriesKey];
        final Map<String, Stock> result = {};
        
        timeSeries.forEach((date, values) {
          result[date] = Stock.fromJson(values);
        });
        
        return result;
      } else if (data.containsKey('Note')) {
        throw Exception('API call frequency limit reached: ${data['Note']}');
      } else {
        throw Exception('Failed to load intraday data');
      }
    } else {
      throw Exception('Failed to load intraday: ${response.statusCode}');
    }
  }
  
  // Get top gainers and losers
  Future<List<StockQuote>> getTopMovers(List<String> symbols) async {
    List<StockQuote> quotes = [];
    
    for (String symbol in symbols) {
      try {
        StockQuote quote = await getQuote(symbol);
        quotes.add(quote);
      } catch (e) {
        print('Error fetching quote for $symbol: $e');
      }
    }
    
    // Sort by percent change
    quotes.sort((a, b) => b.changePercent.abs().compareTo(a.changePercent.abs()));
    
    return quotes;
  }
  
  // Get market indices
  Future<List<StockQuote>> getMarketIndices() async {
    List<String> indices = ['SPY', 'DIA', 'QQQ', 'IWM']; // ETFs that track major indices
    List<StockQuote> quotes = [];
    
    for (String index in indices) {
      try {
        StockQuote quote = await getQuote(index);
        quotes.add(quote);
      } catch (e) {
        print('Error fetching index $index: $e');
      }
    }
    
    return quotes;
  }
}

