import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OfflineService {
  static const String _cachePrefix = 'nasa_app_cache_';
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const Duration _cacheExpiry = Duration(hours: 24);

  // Check if device is online by making a simple request
  static Future<bool> isOnline() async {
    try {
      final response = await http.get(
        Uri.parse('https://www.google.com'),
      ).timeout(Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Cache data with timestamp
  static Future<void> cacheData(String key, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await prefs.setString('$_cachePrefix$key', json.encode(cacheData));
    } catch (e) {
      print('Error caching data: $e');
    }
  }

  // Retrieve cached data if not expired
  static Future<Map<String, dynamic>?> getCachedData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString('$_cachePrefix$key');
      
      if (cachedString != null) {
        final cacheData = json.decode(cachedString);
        final timestamp = DateTime.fromMillisecondsSinceEpoch(cacheData['timestamp']);
        
        if (DateTime.now().difference(timestamp) < _cacheExpiry) {
          return Map<String, dynamic>.from(cacheData['data']);
        }
      }
    } catch (e) {
      print('Error retrieving cached data: $e');
    }
    return null;
  }

  // Clear expired cache
  static Future<void> clearExpiredCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (String key in keys) {
        if (key.startsWith(_cachePrefix)) {
          final cachedString = prefs.getString(key);
          if (cachedString != null) {
            final cacheData = json.decode(cachedString);
            final timestamp = DateTime.fromMillisecondsSinceEpoch(cacheData['timestamp']);
            
            if (DateTime.now().difference(timestamp) >= _cacheExpiry) {
              await prefs.remove(key);
            }
          }
        }
      }
    } catch (e) {
      print('Error clearing expired cache: $e');
    }
  }

  // Fetch data with offline support
  static Future<Map<String, dynamic>?> fetchWithOfflineSupport(
    String url,
    String cacheKey, {
    Map<String, String>? headers,
  }) async {
    try {
      // Try to fetch fresh data if online
      if (await isOnline()) {
        final response = await http.get(
          Uri.parse(url),
          headers: headers,
        ).timeout(Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          await cacheData(cacheKey, data);
          await _updateLastSync();
          return data;
        }
      }

      // Fall back to cached data
      final cachedData = await getCachedData(cacheKey);
      if (cachedData != null) {
        return cachedData;
      }

      return null;
    } catch (e) {
      print('Error fetching data: $e');
      // Try cached data as fallback
      return await getCachedData(cacheKey);
    }
  }

  // Update last sync timestamp
  static Future<void> _updateLastSync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error updating last sync: $e');
    }
  }

  // Get last sync time
  static Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_lastSyncKey);
      return timestamp != null 
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
    } catch (e) {
      print('Error getting last sync time: $e');
      return null;
    }
  }

  // Cache user progress
  static Future<void> cacheUserProgress(Map<String, dynamic> progress) async {
    await cacheData('user_progress', progress);
  }

  // Get cached user progress
  static Future<Map<String, dynamic>?> getCachedUserProgress() async {
    return await getCachedData('user_progress');
  }

  // Cache NASA images
  static Future<void> cacheNasaImages(String query, List<Map<String, dynamic>> images) async {
    await cacheData('nasa_images_$query', {'images': images});
  }

  // Get cached NASA images
  static Future<List<Map<String, dynamic>>?> getCachedNasaImages(String query) async {
    final data = await getCachedData('nasa_images_$query');
    if (data != null && data['images'] != null) {
      return List<Map<String, dynamic>>.from(data['images']);
    }
    return null;
  }

  // Cache ISS data
  static Future<void> cacheISSData(Map<String, dynamic> issData) async {
    await cacheData('iss_data', issData);
  }

  // Get cached ISS data
  static Future<Map<String, dynamic>?> getCachedISSData() async {
    return await getCachedData('iss_data');
  }

  // Clear all cache
  static Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (String key in keys) {
        if (key.startsWith(_cachePrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      print('Error clearing all cache: $e');
    }
  }

  // Get cache size info
  static Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      int totalSize = 0;
      int itemCount = 0;
      
      for (String key in keys) {
        if (key.startsWith(_cachePrefix)) {
          final value = prefs.getString(key);
          if (value != null) {
            totalSize += value.length;
            itemCount++;
          }
        }
      }
      
      return {
        'itemCount': itemCount,
        'totalSizeBytes': totalSize,
        'totalSizeKB': (totalSize / 1024).round(),
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      };
    } catch (e) {
      print('Error getting cache info: $e');
      return {'itemCount': 0, 'totalSizeBytes': 0, 'totalSizeKB': 0, 'totalSizeMB': '0.00'};
    }
  }
}
