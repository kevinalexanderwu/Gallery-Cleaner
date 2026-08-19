import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocationCacheService {
  static const String _cacheKey = 'photo_location_cache';

  Future<Map<String, dynamic>> loadCache() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_cacheKey);

    if (raw == null || raw.isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // Ignore invalid cache.
    }

    return {};
  }

  Future<void> saveCache(
    Map<String, dynamic> cache,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _cacheKey,
      jsonEncode(cache),
    );
  }
}