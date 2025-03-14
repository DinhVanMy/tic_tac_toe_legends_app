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
  final RxDouble viewRadius = 5000.0.obs; // Bán kính tìm kiếm (mét)
  final RxList<UserModel> displayUsers = RxList<UserModel>();
  final RouteService _routeService = RouteService();
  final RxList<LatLng> routePoints = <LatLng>[].obs;

  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<QuerySnapshot>? _nearbyUsersSubscription;
  Timer? _debounceTimer;

  final String userId;
  LocationController({required this.userId});

  @override
  void onInit() {
    super.onInit();
    mapController = MapController();
    mapController.mapEventStream.listen((event) {
      if (event is MapEventMoveEnd) {
        _lazyLoadOnCameraMove();
      }
    });
    _initializeLocationUpdates();
    // _startGpsMonitoring();
  }

  /// Khởi tạo cập nhật vị trí
  Future<void> _initializeLocationUpdates() async {
    await _fetchCurrentPosition();
    _listenToPositionUpdates();
    _fetchNearbyUsers(viewRadius.value);
  }

  /// Lấy vị trí hiện tại
  Future<void> _fetchCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      currentPosition.value = position;
      _debouncedUpdateUserLocation(position);
      mapController.move(
        LatLng(position.latitude, position.longitude),
        14.0,
      );
    } catch (e) {
      errorMessage("Failed to get current location: $e");
    }
  }

  /// Theo dõi cập nhật vị trí theo thời gian thực
  void _listenToPositionUpdates() {
    _positionStreamSubscription = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.best,
      distanceFilter: 10, // Chỉ cập nhật khi di chuyển 10m
    ).listen(
      (Position position) {
        currentPosition.value = position;
        _debouncedUpdateUserLocation(position);
        _fetchNearbyUsers(viewRadius.value);
      },
      onError: (e) {
        errorMessage("Location updates failed: $e");
        // _checkGpsStatus();
      },
    );
  }

  /// Debounce cập nhật vị trí lên Firestore
  void _debouncedUpdateUserLocation(Position position) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 5), () {
      _updateUserLocation(position);
    });
  }

  /// Cập nhật vị trí người dùng lên Firestore
  Future<void> _updateUserLocation(Position position) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'location': GeoPoint(position.latitude, position.longitude),
        'lastUpdated': FieldValue.serverTimestamp(),
      }).catchError((e) => errorMessage("Error when update loaction: $e"));
    } catch (e) {
      errorMessage("Failed to update location: $e");
    }
  }

  /// Tìm kiếm bạn bè theo tên
  Future<void> findFriendLocationByName(String friendName) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('name', isEqualTo: friendName)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        final GeoPoint? location = userDoc['location'];
        if (location != null) {
          friendLocation.value = LatLng(location.latitude, location.longitude);
          mapController.move(friendLocation.value!, 14.0);
        } else {
          errorMessage("This user has no location data.");
        }
      } else {
        errorMessage("No friend found with this name.");
      }
    } catch (e) {
      errorMessage("Error searching for friend: $e");
    }
  }

  /// Lấy danh sách người dùng gần đó
  void _fetchNearbyUsers(double radius) {
    final userPosition = currentPosition.value;
    if (userPosition == null) return;

    _nearbyUsersSubscription
        ?.cancel(); // Hủy subscription cũ để tránh trùng lặp
    _nearbyUsersSubscription = _firestore
        .collection('users')
        .where('location', isNotEqualTo: null)
        .snapshots()
        .listen((snapshot) {
      displayUsers.clear();
      for (var doc in snapshot.docs) {
        if (doc.id == userId) continue; // Bỏ qua chính người dùng
        final data = doc.data();
        final GeoPoint? location = data['location'];
        if (location != null) {
          final distance = Geolocator.distanceBetween(
            userPosition.latitude,
            userPosition.longitude,
            location.latitude,
            location.longitude,
          );
          if (distance <= radius) {
            final user = UserModel.fromJson(data);
            displayUsers.add(user);
          }
        }
      }
    }, onError: (e) {
      errorMessage("Error fetching nearby users: $e");
    });
  }

  /// Lazy load khi camera di chuyển
  void _lazyLoadOnCameraMove() {
    try {
      final cameraCenter = mapController.camera.center;
      if (currentPosition.value != null) {
        final radius = Geolocator.distanceBetween(
          cameraCenter.latitude,
          cameraCenter.longitude,
          currentPosition.value!.latitude,
          currentPosition.value!.longitude,
        );
        if (radius > viewRadius.value) {
          viewRadius.value = radius + 1000;
        }
        _fetchNearbyUsers(viewRadius.value);
      }
    } catch (e) {
      errorMessage("Error during camera move: $e");
    }
  }

  /// Lấy tuyến đường đến bạn bè
  Future<void> getRouteToFriend({
    required LatLng userPosition,
    required LatLng friendPos,
  }) async {
    try {
      routePoints.clear();
      final route = await _routeService.fetchRoute(userPosition, friendPos);
      routePoints.assignAll(route);
      mapController.move(friendPos, 14.0);
    } catch (e) {
      errorMessage("Error fetching route: $e");
    }
  }

  // /// Theo dõi trạng thái GPS
  // void _startGpsMonitoring() {
  //   _gpsCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
  //     if (!await FriendZoneMapService.ensureLocationPermission()) {
  //       isGpsEnabled.value = false;
  //     } else {
  //       isGpsEnabled.value = true;
  //     }
  //   });
  // }

  // /// Kiểm tra trạng thái GPS khi có lỗi
  // void _checkGpsStatus() async {
  //   if (!await FriendZoneMapService.ensureLocationPermission()) {
  //     isGpsEnabled.value = false;
  //   }
  // }

  @override
  void onClose() {
    _positionStreamSubscription?.cancel();
    _nearbyUsersSubscription?.cancel();
    _debounceTimer?.cancel();
    // _gpsCheckTimer?.cancel();
    mapController.dispose();
    super.onClose();
  }
}
