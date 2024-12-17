import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Models/live_sream_model.dart';

class LiveStreamController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ScrollController để hỗ trợ lazy load
  late final ScrollController scrollController;

  // Danh sách live streams
  var liveStreamsList = <LiveStreamModel>[].obs;

  // Biến để theo dõi trạng thái tải
  bool isFetching = false;
  DocumentSnapshot? lastDocument;
  final int pageSize = 6;

  late StreamSubscription subscriptionListenStreams;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    fetchInitialLiveStreams();
    listenToLiveStreamChanges();

    // Lắng nghe sự kiện scroll để tải thêm dữ liệu
    // scrollController.addListener(() {
    //   if (scrollController.position.pixels >=
    //           scrollController.position.maxScrollExtent &&
    //       !isFetching) {
    //     fetchMoreLiveStreams();
    //   }
    // });
  }

  // Hàm tải dữ liệu trang đầu tiên
  Future<void> fetchInitialLiveStreams() async {
    if (isFetching) return;
    isFetching = true;

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('liveStreams')
          .orderBy('createdAt', descending: true)
          .limit(pageSize)
          .get();

      if (snapshot.docs.isNotEmpty) {
        liveStreamsList.value = snapshot.docs.map((doc) {
          return LiveStreamModel.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();
        lastDocument = snapshot.docs.last;
      }
    } catch (e) {
      print("Error fetching live streams: $e");
    } finally {
      isFetching = false;
    }
  }

  // Hàm tải thêm dữ liệu (lazy load)
  Future<void> fetchMoreLiveStreams() async {
    if (isFetching || lastDocument == null) return;
    isFetching = true;

    try {
      Query query = _firestore
          .collection('liveStreams')
          .orderBy('createdAt', descending: true)
          .startAfterDocument(lastDocument!)
          .limit(pageSize);

      QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        liveStreamsList.value = snapshot.docs.map((doc) {
          return LiveStreamModel.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();
        lastDocument = snapshot.docs.last;
      } else {
        lastDocument = null; // Không còn dữ liệu để tải
      }
    } catch (e) {
      print("Error fetching more live streams: $e");
    } finally {
      isFetching = false;
    }
  }

  // Lắng nghe các thay đổi của collection liveStreams
  void listenToLiveStreamChanges() {
    subscriptionListenStreams = _firestore
        .collection('liveStreams')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          liveStreamsList.insert(
              0,
              LiveStreamModel.fromJson(
                  change.doc.data() as Map<String, dynamic>));
        } else if (change.type == DocumentChangeType.modified) {
          int index = liveStreamsList
              .indexWhere((live) => live.streamId == change.doc.id);
          if (index != -1) {
            liveStreamsList[index] = LiveStreamModel.fromJson(
                change.doc.data() as Map<String, dynamic>);
          }
        } else if (change.type == DocumentChangeType.removed) {
          liveStreamsList.removeWhere((live) => live.streamId == change.doc.id);
        }
      }
    });
  }

  @override
  void onClose() {
    subscriptionListenStreams.cancel();
    scrollController.dispose();
    super.onClose();
  }
}
