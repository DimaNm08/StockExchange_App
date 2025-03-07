import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../models/stock.dart';
import '../models/stock_quote.dart';
import '../models/stock_search_result.dart';

class TwelveDataService {
  // Twelve Data API base URL
  static const String baseUrl = 'https://api.twelvedata.com';
  
  // Replace with your actual API key from Twelve Data
  static const String apiKey = 'ce2a3f927e3240f5b2794fb46b4b04db';
  
  // Rate limiting variables
  static const int _maxRequestsPerMinute = 8; // Free tier limit
  static final List<DateTime> _requestTimestamps = [];
  static final Map<String, StockQuote> _quoteCache = {}; // Simple cache
  static final Map<String, List<StockSearchResult>> _searchCache = {};
  static final Map<String, Map<String, Stock>> _timeSeriesCache = {};
  
  // Helper method to respect rate limits
  Future<void> _respectRateLimit() async {
    final now = DateTime.now();
    
    // Remove timestamps older than 1 minute
    _requestTimestamps.removeWhere(
      (timestamp) => now.difference(timestamp).inSeconds > 60
    );
    
    // If we've reached the limit, wait until the oldest request is more than a minute old
    if (_requestTimestamps.length >= _maxRequestsPerMinute) {
      final oldestTimestamp = _requestTimestamps.first;
      final timeToWait = 60 - now.difference(oldestTimestamp).inSeconds;
      
      if (timeToWait > 0) {
        print('Rate limit reached. Waiting for $timeToWait seconds...');
        await Future.delayed(Duration(seconds: timeToWait + 1));
      }
    }
    
    // Add current timestamp to the list
    _requestTimestamps.add(DateTime.now());
  }
  
  // Get real-time quote for a symbol
  Future<StockQuote> getQuote(String symbol) async {
    // Check cache first (cache valid for 5 minutes)
    if (_quoteCache.containsKey(symbol)) {
      final cachedTime = _requestTimestamps.firstWhere(
        (timestamp) => true,
        orElse: () => DateTime.now().subtract(Duration(minutes: 10)),
      );
      
      if (DateTime.now().difference(cachedTime).inMinutes < 5) {
        print('Using cached quote for $symbol');
        return _quoteCache[symbol]!;
      }
    }
    
    try {
      // Respect rate limit before making request
      await _respectRateLimit();
      
      final response = await http.get(
        Uri.parse('$baseUrl/quote?symbol=$symbol&apikey=$apiKey'),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Debug the response
        print('Quote response for $symbol: ${response.body}');
        
        if (data.containsKey('symbol') && !data.containsKey('status') && !data.containsKey('code')) {
          final quote = StockQuote.fromTwelveDataJson(data);
          // Cache the result
          _quoteCache[symbol] = quote;
          return quote;
        } else if (data.containsKey('code') && data['code'] == 429) {
          throw Exception('API call frequency limit reached: ${data['message']}');
        } else if (data.containsKey('status') && data['status'] == 'error') {
          throw Exception('API error: ${data['message']}');
        } else {
          throw Exception('Failed to load quote data');
        }
      } else {
        throw Exception('Failed to load quote: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching quote for $symbol: $e');
      // Return a fallback quote for the symbol
      return _getFallbackQuote(symbol);
    }
  }
  
  // Search for stocks by keywords
  Future<List<StockSearchResult>> searchStocks(String keywords) async {
    // Check cache first (cache valid for 1 hour)
    if (_searchCache.containsKey(keywords)) {
      final cachedTime = _requestTimestamps.firstWhere(
        (timestamp) => true,
        orElse: () => DateTime.now().subtract(Duration(hours: 2)),
      );
      
      if (DateTime.now().difference(cachedTime).inHours < 1) {
        print('Using cached search results for $keywords');
        return _searchCache[keywords]!;
      }
    }
    
    try {
      // Respect rate limit before making request
      await _respectRateLimit();
      
      final response = await http.get(
        Uri.parse('$baseUrl/symbol_search?symbol=$keywords&apikey=$apiKey'),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Debug the response
        print('Search response for $keywords: ${response.body}');
        
        if (data.containsKey('data') && data['data'] is List) {
          List<dynamic> matches = data['data'];
          final results = matches.map((match) => StockSearchResult.fromTwelveDataJson(match)).toList();
          
          // Cache the results
          _searchCache[keywords] = results;
          
          return results;
        } else if (data.containsKey('code') && data['code'] == 429) {
          throw Exception('API call frequency limit reached: ${data['message']}');
        } else if (data.containsKey('status') && data['status'] == 'error') {
          throw Exception('API error: ${data['message']}');
        } else {
          return _getFallbackSearchResults(keywords);
        }
      } else {
        throw Exception('Failed to search stocks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching stocks for $keywords: $e');
      return _getFallbackSearchResults(keywords);
    }
  }
  
  // Get time series data for a symbol
  Future<Map<String, Stock>> getTimeSeries(String symbol, {String interval = '1day', int outputSize = 30}) async {
    // Create a cache key
    final cacheKey = '$symbol-$interval-$outputSize';
    
    // Check cache first (cache valid for 1 day)
    if (_timeSeriesCache.containsKey(cacheKey)) {
      final cachedTime = _requestTimestamps.firstWhere(
        (timestamp) => true,
        orElse: () => DateTime.now().subtract(Duration(days: 2)),
      );
      
      if (DateTime.now().difference(cachedTime).inDays < 1) {
        print('Using cached time series for $cacheKey');
        return _timeSeriesCache[cacheKey]!;
      }
    }
    
    try {
      // Respect rate limit before making request
      await _respectRateLimit();
      
      final response = await http.get(
        Uri.parse('$baseUrl/time_series?symbol=$symbol&interval=$interval&outputsize=$outputSize&apikey=$apiKey'),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data.containsKey('values') && data['values'] is List) {
          final List<dynamic> values = data['values'];
          final Map<String, Stock> result = {};
          
          for (var item in values) {
            String date = item['datetime'];
            result[date] = Stock.fromTwelveDataJson(item);
          }
          
          // Cache the results
          _timeSeriesCache[cacheKey] = result;
          
          return result;
        } else if (data.containsKey('code') && data['code'] == 429) {
          throw Exception('API call frequency limit reached: ${data['message']}');
        } else if (data.containsKey('status') && data['status'] == 'error') {
          throw Exception('API error: ${data['message']}');
        } else {
          return _getFallbackTimeSeries(symbol);
        }
      } else {
        throw Exception('Failed to load time series: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching time series for $symbol: $e');
      return _getFallbackTimeSeries(symbol);
    }
  }
  
  // Get top gainers and losers
  Future<List<StockQuote>> getTopMovers(List<String> symbols) async {
    List<StockQuote> quotes = [];
    
    // Process symbols one by one with a delay to respect rate limits
    for (String symbol in symbols) {
      try {
        // Get quote with rate limiting built in
        StockQuote quote = await getQuote(symbol);
        quotes.add(quote);
        
        // Add a small delay between requests to avoid hitting rate limits
        if (symbols.indexOf(symbol) < symbols.length - 1) {
          await Future.delayed(Duration(milliseconds: 200));
        }
      } catch (e) {
        print('Error fetching quote for $symbol: $e');
        // Add fallback quote
        quotes.add(_getFallbackQuote(symbol));
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
    
    // Process indices one by one with a delay to respect rate limits
    for (String index in indices) {
      try {
        // Get quote with rate limiting built in
        StockQuote quote = await getQuote(index);
        quotes.add(quote);
        
        // Add a small delay between requests to avoid hitting rate limits
        if (indices.indexOf(index) < indices.length - 1) {
          await Future.delayed(Duration(milliseconds: 200));
        }
      } catch (e) {
        print('Error fetching index $index: $e');
        // Add fallback quote
        quotes.add(_getFallbackQuote(index));
      }
    }
    
    return quotes;
  }
  
  // Fallback data methods
  StockQuote _getFallbackQuote(String symbol) {
    // Map of fallback data for common symbols
    Map<String, Map<String, dynamic>> fallbackData = {
      'AAPL': {
        'open': 178.72,
        'high': 180.25,
        'low': 177.60,
        'price': 178.72,
        'volume': 65432100,
        'previousClose': 177.00,
        'change': 1.72,
        'changePercent': 0.0063,
      },
      'MSFT': {
        'open': 417.88,
        'high': 420.00,
        'low': 415.50,
        'price': 417.88,
        'volume': 23456700,
        'previousClose': 412.00,
        'change': 5.88,
        'changePercent': 0.0125,
      },
      'GOOGL': {
        'open': 175.98,
        'high': 177.50,
        'low': 174.20,
        'price': 175.98,
        'volume': 34567800,
        'previousClose': 174.30,
        'change': 1.68,
        'changePercent': 0.0089,
      },
      'AMZN': {
        'open': 178.15,
        'high': 180.00,
        'low': 177.00,
        'price': 178.15,
        'volume': 12345678,
        'previousClose': 179.50,
        'change': -1.35,
        'changePercent': -0.0085,
      },
      'TSLA': {
        'open': 177.67,
        'high': 180.00,
        'low': 175.00,
        'price': 177.67,
        'volume': 45678901,
        'previousClose': 173.90,
        'change': 3.77,
        'changePercent': 0.0214,
      },
      'META': {
        'open': 474.99,
        'high': 480.00,
        'low': 470.00,
        'price': 474.99,
        'volume': 5678901,
        'previousClose': 470.20,
        'change': 4.79,
        'changePercent': 0.0089,
      },
      'NFLX': {
        'open': 605.88,
        'high': 610.00,
        'low': 600.00,
        'price': 605.88,
        'volume': 3456789,
        'previousClose': 598.20,
        'change': 7.68,
        'changePercent': 0.0128,
      },
      'ADBE': {
        'open': 420.50,
        'high': 425.00,
        'low': 418.00,
        'price': 420.50,
        'volume': 2345678,
        'previousClose': 419.50,
        'change': 1.00,
        'changePercent': 0.0022,
      },
      'SPY': {
        'open': 510.34,
        'high': 512.00,
        'low': 508.00,
        'price': 510.34,
        'volume': 67890123,
        'previousClose': 507.50,
        'change': 2.84,
        'changePercent': 0.0056,
      },
      'DIA': {
        'open': 425.20,
        'high': 431.60,
        'low': 424.45,
        'price': 430.47,
        'volume': 3015700,
        'previousClose': 425.57,
        'change': 4.90,
        'changePercent': 0.0115,
      },
      'QQQ': {
        'open': 496.20,
        'high': 503.63,
        'low': 491.26,
        'price': 502.01,
        'volume': 46191200,
        'previousClose': 495.55,
        'change': 6.46,
        'changePercent': 0.0130,
      },
      'IWM': {
        'open': 201.45,
        'high': 203.00,
        'low': 200.00,
        'price': 201.45,
        'volume': 9012345,
        'previousClose': 200.80,
        'change': 0.65,
        'changePercent': 0.0033,
      },
    };
    
    // Default fallback data if symbol not found
    Map<String, dynamic> defaultData = {
      'open': 100.00,
      'high': 102.00,
      'low': 98.00,
      'price': 100.00,
      'volume': 1000000,
      'previousClose': 99.00,
      'change': 1.00,
      'changePercent': 0.01,
    };
    
    Map<String, dynamic> data = fallbackData[symbol] ?? defaultData;
    
    return StockQuote(
      symbol: symbol,
      open: data['open'],
      high: data['high'],
      low: data['low'],
      price: data['price'],
      volume: data['volume'],
      latestTradingDay: DateTime.now().toString().substring(0, 10),
      previousClose: data['previousClose'],
      change: data['change'],
      changePercent: data['changePercent'],
    );
  }
  
  List<StockSearchResult> _getFallbackSearchResults(String query) {
    List<Map<String, String>> stocks = [
      {"symbol": "AAPL", "name": "Apple Inc."},
      {"symbol": "GOOGL", "name": "Alphabet Inc."},
      {"symbol": "MSFT", "name": "Microsoft Corporation"},
      {"symbol": "AMZN", "name": "Amazon.com Inc."},
      {"symbol": "META", "name": "Meta Platforms, Inc."},
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
    
    return stocks
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
  
  Map<String, Stock> _getFallbackTimeSeries(String symbol) {
    Map<String, Stock> result = {};
    DateTime now = DateTime.now();
    
    // Generate 30 days of fake data
    for (int i = 0; i < 30; i++) {
      DateTime date = now.subtract(Duration(days: i));
      String dateStr = date.toString().substring(0, 10);
      
      // Base price around 100 with some random variation
      double basePrice = 100.0;
      if (symbol == 'AAPL') basePrice = 178.0;
      if (symbol == 'MSFT') basePrice = 417.0;
      if (symbol == 'GOOGL') basePrice = 175.0;
      if (symbol == 'AMZN') basePrice = 178.0;
      if (symbol == 'TSLA') basePrice = 177.0;
      if (symbol == 'META') basePrice = 474.0;
      if (symbol == 'NFLX') basePrice = 605.0;
      if (symbol == 'SPY') basePrice = 510.0;
      if (symbol == 'DIA') basePrice = 430.0;
      if (symbol == 'QQQ') basePrice = 502.0;
      if (symbol == 'IWM') basePrice = 201.0;
      
      // Add some random variation
      double variation = (i % 5 - 2) * 0.01; // -2% to +2%
      double close = basePrice * (1 + variation);
      double open = close * (1 - 0.005 + 0.01 * (i % 3) / 3); // Slight variation from close
      double high = close * 1.01;
      double low = open * 0.99;
      
      result[dateStr] = Stock(
        open: open,
        high: high,
        low: low,
        close: close,
        volume: 1000000 + (i * 100000),
      );
    }
    
    return result;
  }
}

