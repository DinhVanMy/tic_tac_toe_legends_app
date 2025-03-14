import 'dart:collection';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class RouteService extends GetConnect {
  // Cache với LRU và TTL
  final _routeCache = LinkedHashMap<String, _CacheEntry>(
    equals: (a, b) => a == b,
    hashCode: (key) => key.hashCode,
  );

  // Giới hạn kích thước cache
  static const int _maxCacheSize = 50;
  // Thời gian sống của cache (5 phút)
  static const Duration _cacheTTL = Duration(minutes: 5);

  RouteService() {
    httpClient.baseUrl = 'https://router.project-osrm.org';
    httpClient.timeout = const Duration(seconds: 5); // Timeout 5 giây
  }

  Future<List<LatLng>> fetchRoute(LatLng start, LatLng end) async {
    // Tạo key cho cache
    final cacheKey =
        '${start.latitude.toStringAsFixed(6)},${start.longitude.toStringAsFixed(6)}-${end.latitude.toStringAsFixed(6)},${end.longitude.toStringAsFixed(6)}';

    // Kiểm tra cache
    if (_routeCache.containsKey(cacheKey)) {
      final entry = _routeCache[cacheKey]!;
      if (DateTime.now().difference(entry.timestamp) < _cacheTTL) {
        // Di chuyển mục vừa dùng lên đầu (LRU)
        _routeCache.remove(cacheKey);
        _routeCache[cacheKey] = entry;
        return entry.route;
      } else {
        // Xóa mục hết hạn
        _routeCache.remove(cacheKey);
      }
    }

    // Tạo endpoint với tối ưu hóa dữ liệu
    final endpoint =
        '/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=simplified&geometries=geojson&steps=false';

    // Gửi request với retry
    final response = await _retryRequest(endpoint);

    if (response.statusCode == 200) {
      final data = response.body;
      final List<LatLng> routePoints = [];

      // Parse dữ liệu GeoJSON nhanh hơn với vòng lặp tối ưu
      final coordinates = data['routes'][0]['geometry']['coordinates'] as List;
      routePoints
          .addAll(coordinates.map((coord) => LatLng(coord[1], coord[0])));

      // Quản lý cache
      if (_routeCache.length >= _maxCacheSize) {
        // Xóa mục cũ nhất (đầu tiên trong LinkedHashMap)
        _routeCache.remove(_routeCache.keys.first);
      }
      _routeCache[cacheKey] = _CacheEntry(routePoints, DateTime.now());

      return routePoints;
    } else {
      throw Exception('Failed to fetch route: ${response.statusCode}');
    }
  }

  // Hàm retry request với tối đa 2 lần thử lại
  Future<Response> _retryRequest(String endpoint) async {
    const maxRetries = 2;
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final response =
            await get(endpoint).timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          return response;
        }
      } catch (e) {
        if (attempt == maxRetries) rethrow;
        await Future.delayed(
            Duration(milliseconds: 500 * (attempt + 1))); // Delay tăng dần
      }
    }
    throw Exception('Failed to fetch route after retries');
  }
}

// Lớp lưu trữ dữ liệu cache với thời gian
class _CacheEntry {
  final List<LatLng> route;
  final DateTime timestamp;

  _CacheEntry(this.route, this.timestamp);
}
