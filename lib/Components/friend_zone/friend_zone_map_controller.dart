import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:tictactoe_gameapp/Components/friend_zone/direction_routes_service.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';

class LocationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final MapController mapController;

  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final Rx<LatLng?> friendLocation = Rx<LatLng?>(null);
  final RxDouble viewRadius = 5000.0.obs;
  final RxList<UserModel> displayUsers = RxList<UserModel>();
  final RouteService _routeService = RouteService();
  final RxList<LatLng> routePoints = <LatLng>[].obs;

  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _debounceTimer;

  final String userId;
  LocationController({required this.userId});

  @override
  void onInit() {
    super.onInit();
    mapController = MapController();
    mapController.mapEventStream.listen((event) {
      if (event is MapEventMoveEnd) {
        lazyLoadOnCameraMove();
      }
      //  else if (event is MapEventMove) {
      //   printInfo(info: "Camera move");
      // }
    });
    _initializeLocationUpdates();
  }

  Future<void> _initializeLocationUpdates() async {
    await _requestPermission();
    await _fetchCurrentPosition();
    // _listenToPositionUpdates();
  }

  Future<void> _requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      await Geolocator.openLocationSettings();
    }
  }

  Future<void> _fetchCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      currentPosition.value = position;
      _debouncedUpdateUserLocation(position);
    } catch (e) {
      errorMessage("Lỗi khi lấy vị trí hiện tại: $e");
    }
  }

  void _listenToPositionUpdates() {
    _positionStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      currentPosition.value = position;
      _debouncedUpdateUserLocation(position);
      _fetchNearbyUsers(viewRadius.value);
    });
  }

  void _debouncedUpdateUserLocation(Position position) {
    _debounceTimer = Timer(const Duration(seconds: 10), () {
      _updateUserLocation(position);
    });
  }

  Future<void> _updateUserLocation(Position position) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'location': GeoPoint(position.latitude, position.longitude),
      });
    } catch (e) {
      errorMessage("Lỗi khi cập nhật vị trí: $e");
    }
  }

  Future<void> findFriendLocationByName(String friendName) async {
    try {
      // Truy vấn Firestore để tìm người dùng với tên trùng khớp
      final querySnapshot = await _firestore
          .collection('users')
          .where('name', isEqualTo: friendName)
          .get();

      // Kiểm tra nếu tìm thấy người dùng có tên trùng khớp
      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;

        final GeoPoint? location = userDoc['location'];

        if (location != null) {
          friendLocation.value = LatLng(location.latitude, location.longitude);
        } else {
          errorMessage("Người dùng không có thông tin tọa độ.");
          return;
        }
      } else {
        errorMessage("Không tìm thấy bạn bè với tên này.");
        return;
      }
    } catch (e) {
      errorMessage("Có lỗi xảy ra khi tìm kiếm: $e");
      return;
    }
  }

  // Hàm fetch những người gần vị trí hiện tại
  void _fetchNearbyUsers(double radius) {
    final userPosition = currentPosition.value;
    if (userPosition == null) return;

    _firestore.collection('users').snapshots().listen((snapshot) {
      displayUsers.clear();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data.containsKey('location') && data['location'] != null) {
          final GeoPoint location = data['location'];
          final distance = Geolocator.distanceBetween(
            userPosition.latitude,
            userPosition.longitude,
            location.latitude,
            location.longitude,
          );

          if (distance <= radius) {
            final UserModel user = UserModel.fromJson(doc.data());
            displayUsers.add(user);
            // printInfo(info: "Distance: $distance");
          }
        }
      }
    });
  }

  // Hàm lazy load khi camera di chuyển
  void lazyLoadOnCameraMove() {
    try {
      final cameraCenter = mapController.camera.center;
      if (currentPosition.value != null) {
        final radius = Geolocator.distanceBetween(
          cameraCenter.latitude,
          cameraCenter.longitude,
          currentPosition.value!.latitude,
          currentPosition.value!.longitude,
        );
        _fetchNearbyUsers(radius);
      } else {
        errorMessage("Your current position is out of date?");
        return;
      }
    } catch (e) {
      errorMessage("Error getting camera bounds: $e");
    }
  }

  Future<void> getRouteToFriend(
      {required LatLng userPosition, required LatLng friendPos}) async {
    try {
      // Fetch route from RouteService
      routePoints.clear();
      final route = await _routeService.fetchRoute(userPosition, friendPos);
      routePoints.assignAll(route); // Update the route points

      // Move camera to the starting position
      mapController.move(friendPos, mapController.camera.zoom);
    } catch (e) {
      errorMessage("Error fetching route: $e");
    }
  }

  @override
  void onClose() {
    _positionStreamSubscription?.cancel();
    _debounceTimer?.cancel();
    mapController.dispose();
    super.onClose();
  }
}
