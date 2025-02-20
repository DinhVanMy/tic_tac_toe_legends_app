import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';
import 'package:tictactoe_gameapp/Components/friend_zone/friend_zone_map_controller.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Controller/Animations/Overlays/profile_tooltip.dart';
import 'package:tictactoe_gameapp/Data/fetch_firestore_database.dart';
import 'package:tictactoe_gameapp/Enums/popup_position.dart';

import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Components/rippleanimation/ripple_animation_widget.dart';
import 'package:tictactoe_gameapp/Components/friend_zone/tinder_cards/tinder_cards_widget.dart';

class FriendZoneMapPage extends StatelessWidget {
  final FirestoreController firestoreController;
  final UserModel user;
  final LatLng latlng;
  const FriendZoneMapPage({
    super.key,
    required this.user,
    required this.firestoreController,
    required this.latlng,
  });

  @override
  Widget build(BuildContext context) {
    LatLng defaultLatLng = const LatLng(21.0000992, 105.8399243);
    final ProfileTooltip profileTooltip = Get.put(ProfileTooltip());
    final LocationController locationController =
        Get.put(LocationController(userId: user.id!));
    RxString searchText = "".obs;
    final TextEditingController textEditingController = TextEditingController();
    const List<String> mapUrl = [
      "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
      'https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png',
      'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png'
    ];
    RxString selectedUrl = mapUrl[0].obs;
    RxBool isExpanded = false.obs;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Row(
          children: [
            IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 35,
                  color: Colors.redAccent,
                )),
          ],
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 25,
              child: user.image != null && user.image!.isNotEmpty
                  ? CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(user.image!),
                      maxRadius: 55,
                    )
                  : const Icon(Icons.person_2_outlined),
            ),
            const SizedBox(
              width: 5,
            ),
            Expanded(
              child: Obx(() => TextField(
                    controller: textEditingController,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        searchText.value = value;
                      } else {
                        searchText.value = "";
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Search someone...",
                      suffixIcon: searchText.value == ""
                          ? const Icon(
                              Icons.search_off,
                              color: Colors.grey,
                            )
                          : IconButton(
                              onPressed: () async {
                                FocusScope.of(context).unfocus();

                                await Get.showOverlay(
                                  asyncFunction: () async {
                                    await locationController
                                        .findFriendLocationByName(
                                            searchText.value);
                                    if (locationController
                                            .friendLocation.value !=
                                        null) {
                                      await locationController.getRouteToFriend(
                                          userPosition: latlng,
                                          friendPos: locationController
                                              .friendLocation.value!);
                                    }
                                  },
                                  loadingWidget: Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                          GifsPath.transitionGif,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ).then((_) {
                                  if (locationController.friendLocation.value !=
                                      null) {
                                    locationController.mapController
                                        .moveAndRotate(
                                            locationController
                                                    .friendLocation.value ??
                                                latlng,
                                            16,
                                            1);
                                  }
                                });
                                searchText.value = "";
                                textEditingController.clear();
                              },
                              icon: const Icon(
                                Icons.search,
                                color: Colors.blueAccent,
                                size: 30,
                              )),
                    ),
                  )),
            )
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                isExpanded.value = !isExpanded.value;
              },
              icon: Obx(() => Icon(
                    isExpanded.value
                        ? Icons.remove_red_eye
                        : Icons.remove_red_eye_outlined,
                    size: 35,
                    color: Colors.black,
                  ))),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: locationController.mapController,
            options: MapOptions(
              initialCenter: locationController.currentPosition.value == null
                  ? latlng
                  : LatLng(locationController.currentPosition.value!.latitude,
                      locationController.currentPosition.value!.longitude),
              initialZoom: 14.0,
            ),
            children: [
              Obx(() => TileLayer(
                    urlTemplate: selectedUrl.value,
                    userAgentPackageName:
                        'com.example.app/tictactoe_gameapp/11218415.2142003',
                    errorImage: CachedNetworkImageProvider(user.image!),
                  )),
              Obx(() => locationController.routePoints.isNotEmpty
                  ? GestureDetector(
                      onDoubleTap: () => locationController.routePoints.clear(),
                      child: PolylineLayer(
                        polylines: [
                          Polyline(
                            points: locationController.routePoints,
                            gradientColors: [
                              Colors.blue,
                              Colors.blueAccent,
                              Colors.pinkAccent
                            ],
                            strokeWidth: 10,
                          ),
                        ],
                      ),
                    )
                  : const SizedBox()),
              Obx(
                () => MarkerLayer(
                  markers: [
                    Marker(
                      point: locationController.currentPosition.value == null
                          ? latlng
                          : LatLng(
                              locationController
                                  .currentPosition.value!.latitude,
                              locationController
                                  .currentPosition.value!.longitude),
                      height: MediaQuery.sizeOf(context).width,
                      width: MediaQuery.sizeOf(context).width,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.blueAccent, width: 3),
                        ),
                      ),
                    ),
                    Marker(
                      point: locationController.currentPosition.value == null
                          ? latlng
                          : LatLng(
                              locationController
                                  .currentPosition.value!.latitude,
                              locationController
                                  .currentPosition.value!.longitude),
                      height: 100,
                      width: 100,
                      child: const RipplesAnimationCustom(),
                    ),
                    Marker(
                      point: locationController.currentPosition.value == null
                          ? latlng
                          : LatLng(
                              locationController
                                  .currentPosition.value!.latitude,
                              locationController
                                  .currentPosition.value!.longitude),
                      width: 50,
                      height: 50,
                      child: CircleAvatar(
                        radius: 30,
                        child: user.image != null && user.image!.isNotEmpty
                            ? CircleAvatar(
                                backgroundImage:
                                    CachedNetworkImageProvider(user.image!),
                                maxRadius: 55,
                              )
                            : const Icon(Icons.person_2_outlined),
                      ),
                    ),
                    ...firestoreController.friendsList.map((friend) {
                      final LatLng friendLatLng = friend.location == null
                          ? defaultLatLng
                          : LatLng(friend.location!.latitude,
                              friend.location!.longitude);
                      final GlobalKey itemKey = GlobalKey();
                      return Marker(
                        point: friendLatLng,
                        width: 50,
                        height: 50,
                        child: InkWell(
                          key: itemKey,
                          onDoubleTap: () async {
                            await locationController.getRouteToFriend(
                                userPosition: latlng, friendPos: friendLatLng);
                          },
                          onTap: () {
                            profileTooltip.showProfileTooltip(
                              context,
                              itemKey,
                              friend,
                              PopupPosition.above,
                              null,
                              null,
                              null,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.redAccent,
                              border:
                                  Border.all(color: Colors.redAccent, width: 3),
                            ),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage: friend.image != null &&
                                      friend.image!.isNotEmpty
                                  ? CachedNetworkImageProvider(friend.image!)
                                  : null,
                              child:
                                  friend.image == null || friend.image!.isEmpty
                                      ? const Icon(Icons.person_2_outlined)
                                      : null,
                            ),
                          ),
                        ),
                      );
                    }),
                    ...firestoreController.usersList.map((friend) {
                      final randomPosition = _generateRandomLatLng(
                        locationController.currentPosition.value == null
                            ? latlng
                            : LatLng(
                                locationController
                                    .currentPosition.value!.latitude,
                                locationController
                                    .currentPosition.value!.longitude),
                        0.009,
                      );
                      final GlobalKey itemKey = GlobalKey();
                      return Marker(
                        point: randomPosition,
                        width: 50,
                        height: 50,
                        child: InkWell(
                          key: itemKey,
                          onDoubleTap: () async {
                            await locationController.getRouteToFriend(
                                userPosition: latlng,
                                friendPos: randomPosition);
                          },
                          onTap: () {
                            profileTooltip.showProfileTooltip(
                              context,
                              itemKey,
                              friend,
                              PopupPosition.above,
                              null,
                              null,
                              null,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.redAccent,
                              border:
                                  Border.all(color: Colors.redAccent, width: 3),
                            ),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage: friend.image != null &&
                                      friend.image!.isNotEmpty
                                  ? CachedNetworkImageProvider(friend.image!)
                                  : null,
                              child:
                                  friend.image == null || friend.image!.isEmpty
                                      ? const Icon(Icons.person_2_outlined)
                                      : null,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 70,
            left: 10,
            child: Column(
              children: [
                MenuAnchor(
                  builder: (BuildContext context, MenuController controller,
                      Widget? child) {
                    return IconButton(
                      onPressed: () {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          controller.open();
                        }
                      },
                      icon: const Icon(
                        Icons.filter_hdr_sharp,
                        size: 35,
                        color: Colors.blueAccent,
                      ),
                    );
                  },
                  menuChildren: [
                    MenuItemButton(
                      onPressed: () {},
                      child: const Text('All'),
                    ),
                    MenuItemButton(
                      onPressed: () {},
                      child: const Text('Friends'),
                    ),
                    MenuItemButton(
                      onPressed: () {},
                      child: const Text('Nearers'),
                    ),
                  ],
                ),
                MenuAnchor(
                  builder: (BuildContext context, MenuController controller,
                      Widget? child) {
                    return IconButton(
                      onPressed: () {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          controller.open();
                        }
                      },
                      icon: const Icon(
                        Icons.light_mode,
                        size: 35,
                        color: Colors.blueAccent,
                      ),
                    );
                  },
                  menuChildren: [
                    MenuItemButton(
                      onPressed: () {
                        selectedUrl.value = mapUrl[0];
                      },
                      child: const Text('Default'),
                    ),
                    MenuItemButton(
                      onPressed: () {
                        selectedUrl.value = mapUrl[1];
                      },
                      child: const Text('Light'),
                    ),
                    MenuItemButton(
                      onPressed: () {
                        selectedUrl.value = mapUrl[2];
                      },
                      child: const Text('Dark'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 90,
            right: 10,
            child: Obx(() => AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: isExpanded.value ? 80 : 0,
                width: MediaQuery.sizeOf(context).width * 0.8,
                padding: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Obx(() {
                  if (locationController.displayUsers.isEmpty) {
                    return const Center(
                      child: Text(
                        "No User is here?",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  } else {
                    var nearUsers = locationController.displayUsers.toList();
                    return ListView.builder(
                        itemCount: nearUsers.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final nearUser = nearUsers[index];
                          return GestureDetector(
                            onTap: nearUsers.isEmpty
                                ? null
                                : () async {
                                    await Get.dialog(
                                      Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: MapFriendTinderWidget(
                                          users: nearUsers,
                                          initialIndex: index,
                                        ),
                                      )
                                          .animate()
                                          .scale(duration: duration750)
                                          .fadeIn(duration: duration750),
                                    );
                                  },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    AvatarUserWidget(
                                        radius: 20, imagePath: nearUser.image!),
                                    Text(
                                      nearUser.name!,
                                      style: TextStyle(
                                        color: index % 2 == 0
                                            ? Colors.green
                                            : Colors.deepPurple,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                  }
                }))),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 5.0,
        splashColor: Colors.white,
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          locationController.mapController.move(
              locationController.currentPosition.value == null
                  ? latlng
                  : LatLng(locationController.currentPosition.value!.latitude,
                      locationController.currentPosition.value!.longitude),
              15.0);
        },
        child: const Icon(
          Icons.location_searching_rounded,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }

  LatLng _generateRandomLatLng(LatLng center, double maxDistance) {
    final random = Random();
    final dx = (random.nextDouble() - 0.5) * 2 * maxDistance;
    final dy = (random.nextDouble() - 0.5) * 2 * maxDistance;
    return LatLng(center.latitude + dx, center.longitude + dy);
  }
}
