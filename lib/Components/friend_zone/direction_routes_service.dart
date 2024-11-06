import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class RouteService extends GetConnect {
  RouteService() {
    // Khởi tạo URL base để tái sử dụng trong các request khác nếu cần
    httpClient.baseUrl = 'https://router.project-osrm.org';
  }

  Future<List<LatLng>> fetchRoute(LatLng start, LatLng end) async {
    // Tạo endpoint cho API request
    final endpoint = '/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';

    // Gửi request sử dụng GetConnect
    final response = await get(endpoint);

    // Kiểm tra response status
    if (response.statusCode == 200) {
      final data = response.body;
      final List<LatLng> routePoints = [];

      // Lấy và parse dữ liệu từ GeoJSON geometry
      final coordinates = data['routes'][0]['geometry']['coordinates'];
      for (var coord in coordinates) {
        routePoints.add(LatLng(coord[1], coord[0])); // GeoJSON: [lng, lat]
      }

      return routePoints;
    } else {
      // Xử lý lỗi nếu có
      throw Exception('Failed to fetch route');
    }
  }
}
