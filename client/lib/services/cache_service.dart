import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Cache Service for GlowStar
/// 
/// Implements caching for API responses and user data
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  final Map<String, CacheEntry> _memoryCache = {};
  static const int MAX_MEMORY_CACHE_SIZE = 100;
  static const Duration DEFAULT_TTL = Duration(hours: 1);

  /// Get cached data
  Future<T?> get<T>(String key) async {
    // Check memory cache first
    if (_memoryCache.containsKey(key)) {
      CacheEntry entry = _memoryCache[key]!;
      if (!entry.isExpired) {
        return entry.data as T;
      }
      _memoryCache.remove(key);
    }

    // Check disk cache
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString(key);
    
    if (cachedData != null) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(cachedData);
        CacheEntry entry = CacheEntry.fromJson(jsonData);
        
        if (!entry.isExpired) {
          // Add to memory cache
          _addToMemoryCache(key, entry);
          return entry.data as T;
        }
        
        // Remove expired cache
        await prefs.remove(key);
      } catch (e) {
        print('Cache parse error: $e');
      }
    }

    return null;
  }

  /// Set cache data
  Future<void> set(String key, dynamic data, {Duration? ttl}) async {
    ttl = ttl ?? DEFAULT_TTL;
    CacheEntry entry = CacheEntry(
      data: data,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      ttl: ttl.inMilliseconds,
    );

    // Add to memory cache
    _addToMemoryCache(key, entry);

    // Add to disk cache
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(entry.toJson()));
  }

  /// Remove cache entry
  Future<void> remove(String key) async {
    _memoryCache.remove(key);
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  /// Clear all cache
  Future<void> clear() async {
    _memoryCache.clear();
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Add to memory cache with size limit
  void _addToMemoryCache(String key, CacheEntry entry) {
    if (_memoryCache.length >= MAX_MEMORY_CACHE_SIZE) {
      // Remove oldest entry
      String? oldestKey;
      int oldestTimestamp = DateTime.now().millisecondsSinceEpoch;
      
      _memoryCache.forEach((k, v) {
        if (v.timestamp < oldestTimestamp) {
          oldestTimestamp = v.timestamp;
          oldestKey = k;
        }
      });
      
      if (oldestKey != null) {
        _memoryCache.remove(oldestKey);
      }
    }
    
    _memoryCache[key] = entry;
  }
}

/// Cache Entry model
class CacheEntry {
  final dynamic data;
  final int timestamp;
  final int ttl;

  CacheEntry({
    required this.data,
    required this.timestamp,
    required this.ttl,
  });

  bool get isExpired {
    return DateTime.now().millisecondsSinceEpoch - timestamp > ttl;
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'timestamp': timestamp,
      'ttl': ttl,
    };
  }

  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      data: json['data'],
      timestamp: json['timestamp'],
      ttl: json['ttl'],
    );
  }
}
