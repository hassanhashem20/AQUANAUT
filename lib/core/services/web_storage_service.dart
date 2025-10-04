import 'dart:html' as html;

class WebStorageService {
  static const String _prefix = 'nasa_app_';

  // Save data to localStorage
  static Future<void> setString(String key, String value) async {
    try {
      html.window.localStorage['$_prefix$key'] = value;
    } catch (e) {
      print('Error saving to localStorage: $e');
    }
  }

  static Future<void> setInt(String key, int value) async {
    await setString(key, value.toString());
  }

  static Future<void> setBool(String key, bool value) async {
    await setString(key, value.toString());
  }

  static Future<void> setStringList(String key, List<String> value) async {
    await setString(key, value.join(','));
  }

  // Get data from localStorage
  static Future<String?> getString(String key) async {
    try {
      return html.window.localStorage['$_prefix$key'];
    } catch (e) {
      print('Error reading from localStorage: $e');
      return null;
    }
  }

  static Future<int?> getInt(String key) async {
    final value = await getString(key);
    return value != null ? int.tryParse(value) : null;
  }

  static Future<bool?> getBool(String key) async {
    final value = await getString(key);
    return value != null ? value.toLowerCase() == 'true' : null;
  }

  static Future<List<String>?> getStringList(String key) async {
    final value = await getString(key);
    return value != null ? value.split(',') : null;
  }

  // Remove data from localStorage
  static Future<void> remove(String key) async {
    try {
      html.window.localStorage.remove('$_prefix$key');
    } catch (e) {
      print('Error removing from localStorage: $e');
    }
  }

  // Clear all app data
  static Future<void> clear() async {
    try {
      final keys = html.window.localStorage.keys.toList();
      for (final key in keys) {
        if (key.startsWith(_prefix)) {
          html.window.localStorage.remove(key);
        }
      }
    } catch (e) {
      print('Error clearing localStorage: $e');
    }
  }
}

