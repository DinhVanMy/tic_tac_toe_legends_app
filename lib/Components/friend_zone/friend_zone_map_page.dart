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
    final FocusNode searchFocusNode =
        FocusNode(); // Thêm FocusNode để quản lý focus
    const List<String> mapUrl = [
      "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
      'https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png',
      'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png'
    ];
    RxString selectedUrl = mapUrl[0].obs;
    RxBool isExpanded = false.obs;
    RxBool isSearching = false.obs;

    return Scaffold(
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
                    ...locationController.displayUsers.map((nearUser) {
                      final LatLng nearUserLatLng = nearUser.location == null
                          ? defaultLatLng
                          : LatLng(
                              nearUser.location!.latitude,
                              nearUser.location!.longitude,
                            );
                      final GlobalKey markerKey = GlobalKey();
                      return Marker(
                        point: nearUserLatLng,
                        width: 50,
                        height: 50,
                        child: InkWell(
                          key: markerKey,
                          onDoubleTap: () async {
                            await locationController.getRouteToFriend(
                              userPosition:
                                  locationController.currentPosition.value ==
                                          null
                                      ? latlng
                                      : LatLng(
                                          locationController
                                              .currentPosition.value!.latitude,
                                          locationController.currentPosition
                                              .value!.longitude),
                              friendPos: nearUserLatLng,
                            );
                          },
                          onTap: () {
                            profileTooltip.showProfileTooltip(
                              context,
                              markerKey,
                              nearUser,
                              PopupPosition.above,
                              null,
                              null,
                              null,
                            );
                          },
                          child: AvatarUserWidget(
                            radius: 30,
                            imagePath: nearUser.image!,
                            gradientColors:
                                user.avatarFrame ?? ["#FF4CAF50", "#FF81C784"],
                          ),
                        ),
                      );
                    }),
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
                      child: AvatarUserWidget(
                        radius: 30,
                        imagePath: user.image!,
                        gradientColors: user.avatarFrame,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 10,
            child: Obx(() => AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: isExpanded.value ? 80 : 0,
                width: MediaQuery.sizeOf(context).width,
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Obx(() {
                  if (locationController.displayUsers.isEmpty) {
                    return const Center(
                      child: Text(
                        "No User is here?",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
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
                                      radius: 20,
                                      imagePath: nearUser.image!,
                                      gradientColors: nearUser.avatarFrame,
                                    ),
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
          Obx(() => isSearching.value
              ? Positioned(
                  top: 50, // Đặt vị trí cố định để tránh chồng lấn
                  left: 10,
                  right: 10,
                  child: Obx(
                    () => TextField(
                      controller: textEditingController,
                      focusNode: searchFocusNode, // Gắn FocusNode
                      textInputAction: TextInputAction.done,
                      onChanged: (value) {
                        searchText.value = value;
                      },
                      decoration: InputDecoration(
                        hintText: "Search someone...",
                        suffixIcon: searchText.value.isEmpty
                            ? const Icon(
                                Icons.search_off,
                                color: Colors.grey,
                              )
                            : IconButton(
                                onPressed: () async {
                                  if (searchText.value.isNotEmpty) {
                                    await Get.showOverlay(
                                      asyncFunction: () async {
                                        await locationController
                                            .findFriendLocationByName(
                                                searchText.value);
                                        if (locationController
                                                .friendLocation.value !=
                                            null) {
                                          await locationController
                                              .getRouteToFriend(
                                            userPosition: latlng,
                                            friendPos: locationController
                                                .friendLocation.value!,
                                          );
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
                                      if (locationController
                                              .friendLocation.value !=
                                          null) {
                                        locationController.mapController
                                            .moveAndRotate(
                                          locationController
                                                  .friendLocation.value ??
                                              latlng,
                                          16,
                                          1,
                                        );
                                      }
                                      textEditingController.clear();
                                      searchText.value = "";
                                      searchFocusNode.unfocus();
                                    });
                                  }
                                },
                                icon: const Icon(
                                  Icons.search,
                                  color: Colors.blueAccent,
                                  size: 30,
                                ),
                              ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink()),
          Positioned(
            bottom: 20,
            left: 50,
            right: 50,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.85),
                borderRadius: BorderRadius.circular(50),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        isExpanded.value = !isExpanded.value;
                      },
                      icon: const Icon(
                        Icons.location_history,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        isSearching.value = !isSearching.value;
                        if (isSearching.value) {
                          Future.delayed(const Duration(milliseconds: 100),
                              () => searchFocusNode.requestFocus());
                        }
                      },
                      icon: const Icon(
                        Icons.search_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          locationController.mapController.move(
                              locationController.currentPosition.value == null
                                  ? latlng
                                  : LatLng(
                                      locationController
                                          .currentPosition.value!.latitude,
                                      locationController
                                          .currentPosition.value!.longitude),
                              14.0);
                        },
                        icon: const Icon(
                          Icons.location_on,
                          size: 40,
                          color: Colors.purpleAccent,
                        ),
                      ),
                    ),
                    MenuAnchor(
                      builder: (context, controller, child) {
                        return IconButton(
                          onPressed: () {
                            if (controller.isOpen) {
                              controller.close();
                            } else {
                              controller.open();
                            }
                          },
                          icon: const Icon(
                            Icons.settings,
                            size: 40,
                            color: Colors.white,
                          ),
                        );
                      },
                      menuChildren: [
                        MenuItemButton(
                          onPressed: () => selectedUrl.value = mapUrl[0],
                          child: const Text('Default'),
                        ),
                        MenuItemButton(
                          onPressed: () => selectedUrl.value = mapUrl[1],
                          child: const Text('Light'),
                        ),
                        MenuItemButton(
                          onPressed: () => selectedUrl.value = mapUrl[2],
                          child: const Text('Dark'),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(
                        Icons.exit_to_app_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// Marker(
                    //   point: locationController.currentPosition.value == null
                    //       ? latlng
                    //       : LatLng(
                    //           locationController
                    //               .currentPosition.value!.latitude,
                    //           locationController
                    //               .currentPosition.value!.longitude),
                    //   height: MediaQuery.sizeOf(context).width,
                    //   width: MediaQuery.sizeOf(context).width,
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       color: Colors.blue.withOpacity(0.1),
                    //       shape: BoxShape.circle,
                    //       border:
                    //           Border.all(color: Colors.blueAccent, width: 3),
                    //     ),
                    //   ),
                    // ),
 // ...firestoreController.friendsList.map((friend) {
                    //   final LatLng friendLatLng = friend.location == null
                    //       ? defaultLatLng
                    //       : LatLng(friend.location!.latitude,
                    //           friend.location!.longitude);
                    //   final GlobalKey itemKey = GlobalKey();
                    //   return Marker(
                    //     point: friendLatLng,
                    //     width: 50,
                    //     height: 50,
                    //     child: InkWell(
                    //       key: itemKey,
                    //       onDoubleTap: () async {
                    //         await locationController.getRouteToFriend(
                    //             userPosition: latlng, friendPos: friendLatLng);
                    //       },
                    //       onTap: () {
                    //         profileTooltip.showProfileTooltip(
                    //           context,
                    //           itemKey,
                    //           friend,
                    //           PopupPosition.above,
                    //           null,
                    //           null,
                    //           null,
                    //         );
                    //       },
                    //       child: Container(
                    //         decoration: BoxDecoration(
                    //           shape: BoxShape.circle,
                    //           color: Colors.redAccent,
                    //           border:
                    //               Border.all(color: Colors.redAccent, width: 3),
                    //         ),
                    //         child: CircleAvatar(
                    //           radius: 30,
                    //           backgroundImage: friend.image != null &&
                    //                   friend.image!.isNotEmpty
                    //               ? CachedNetworkImageProvider(friend.image!)
                    //               : null,
                    //           child:
                    //               friend.image == null || friend.image!.isEmpty
                    //                   ? const Icon(Icons.person_2_outlined)
                    //                   : null,
                    //         ),
                    //       ),
                    //     ),
                    //   );
                    // }),

                    // ...firestoreController.usersList.map(
                    //   (friend) {
                    //     final randomPosition = _generateRandomLatLng(
                    //       locationController.currentPosition.value == null
                    //           ? latlng
                    //           : LatLng(
                    //               locationController
                    //                   .currentPosition.value!.latitude,
                    //               locationController
                    //                   .currentPosition.value!.longitude),
                    //       0.009,
                    //     );
                    //     final GlobalKey itemKey = GlobalKey();
                    //     return Marker(
                    //       point: randomPosition,
                    //       width: 50,
                    //       height: 50,
                    //       child: InkWell(
                    //         key: itemKey,
                    //         onDoubleTap: () async {
                    //           await locationController.getRouteToFriend(
                    //               userPosition: latlng,
                    //               friendPos: randomPosition);
                    //         },
                    //         onTap: () {
                    //           profileTooltip.showProfileTooltip(
                    //             context,
                    //             itemKey,
                    //             friend,
                    //             PopupPosition.above,
                    //             null,
                    //             null,
                    //             null,
                    //           );
                    //         },
                    //         child: Container(
                    //           decoration: BoxDecoration(
                    //             shape: BoxShape.circle,
                    //             color: Colors.redAccent,
                    //             border: Border.all(
                    //                 color: Colors.redAccent, width: 3),
                    //           ),
                    //           child: CircleAvatar(
                    //             radius: 30,
                    //             backgroundImage: friend.image != null &&
                    //                     friend.image!.isNotEmpty
                    //                 ? CachedNetworkImageProvider(friend.image!)
                    //                 : null,
                    //             child: friend.image == null ||
                    //                     friend.image!.isEmpty
                    //                 ? const Icon(Icons.person_2_outlined)
                    //                 : null,
                    //           ),
                    //         ),
                    //       ),
                    //     );
                    //   },
                    // ),