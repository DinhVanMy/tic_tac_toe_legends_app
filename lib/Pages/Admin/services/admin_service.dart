import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tictactoe_gameapp/Pages/Admin/models/user_model.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Trong AdminService.getAllUsers()
  Future<List<UserModel>> getAllUsers({
    String? searchQuery,
    String? role,
    bool? verified,
    bool? suspended,
    String? orderBy,
    bool descending = false,
    int limit = 100, // Tăng giới hạn lên
    DocumentSnapshot? startAfter,
  }) async {
    try {
      // Bỏ qua tất cả các điều kiện lọc nếu muốn hiển thị tất cả
      Query query = _firestore.collection('users');

      // Chỉ áp dụng bộ lọc theo vai trò nếu được chỉ định
      if (role != null && role != 'all') {
        query = query.where('role', isEqualTo: role);
      }

      // Luôn lấy toàn bộ người dùng
      query = query.limit(limit);

      final snapshot = await query.get();
      final users = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Đảm bảo ID được đưa vào
        return UserModel.fromJson(data);
      }).toList();

      return users;
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Ensure the ID is included
      return UserModel.fromJson(data);
    } catch (e) {
      print('Error getting user by id: $e');
      return null;
    }
  }

  Future<bool> updateUserRole(String userId, String newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating user role: $e');
      return false;
    }
  }

  Future<bool> batchUserOperation(
      List<String> userIds, String operation) async {
    try {
      final batch = _firestore.batch();

      for (final userId in userIds) {
        final userRef = _firestore.collection('users').doc(userId);

        switch (operation) {
          case 'verify':
            batch.update(userRef, {
              'verified': true,
              'updatedAt': FieldValue.serverTimestamp(),
            });
            break;
          case 'suspend':
            batch.update(userRef, {
              'suspended': true,
              'updatedAt': FieldValue.serverTimestamp(),
            });
            break;
          case 'activate':
            batch.update(userRef, {
              'suspended': false,
              'updatedAt': FieldValue.serverTimestamp(),
            });
            break;
          case 'delete':
            batch.delete(userRef);
            break;
          default:
            throw Exception('Unknown operation: $operation');
        }
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Error performing batch operation: $e');
      return false;
    }
  }

  // Content Moderation
  Future<List<Map<String, dynamic>>> getReportedContent({
    String? contentType,
    String? status,
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore.collection('reported_content');

      if (contentType != null && contentType != 'all') {
        query = query.where('contentType', isEqualTo: contentType);
      }

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      query = query.orderBy('reportedAt', descending: true);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      query = query.limit(limit);

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting reported content: $e');
      return [];
    }
  }

  Future<bool> moderateContent({
    required String contentType,
    required String contentId,
    required String action,
    String? reason,
  }) async {
    try {
      // Get the current user (admin)
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // Create moderation record
      final moderationRef = _firestore.collection('content_moderation').doc();

      await moderationRef.set({
        'contentType': contentType,
        'contentId': contentId,
        'action': action,
        'reason': reason,
        'moderatorId': currentUser.uid,
        'moderatedAt': FieldValue.serverTimestamp(),
      });

      // Update the content based on action
      final contentRef = _getContentReference(contentType, contentId);

      switch (action) {
        case 'hide':
          await contentRef.update({
            'hidden': true,
            'hiddenBy': currentUser.uid,
            'hiddenAt': FieldValue.serverTimestamp(),
            'hiddenReason': reason,
          });
          break;
        case 'delete':
          await contentRef.delete();
          break;
        case 'restore':
          await contentRef.update({
            'hidden': false,
            'restoredBy': currentUser.uid,
            'restoredAt': FieldValue.serverTimestamp(),
          });
          break;
        case 'warn':
          // Get the user who created the content
          final contentData =
              (await contentRef.get()).data() as Map<String, dynamic>?;
          if (contentData != null && contentData['userId'] != null) {
            final userRef =
                _firestore.collection('users').doc(contentData['userId']);

            // Add warning to user
            await userRef.collection('warnings').add({
              'contentType': contentType,
              'contentId': contentId,
              'reason': reason,
              'warnedBy': currentUser.uid,
              'warnedAt': FieldValue.serverTimestamp(),
            });

            // Update warning count
            await userRef.update({
              'warningCount': FieldValue.increment(1),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
          break;
        default:
          throw Exception('Unknown action: $action');
      }

      // Update status in reported_content collection
      await _firestore
          .collection('reported_content')
          .where('contentType', isEqualTo: contentType)
          .where('contentId', isEqualTo: contentId)
          .get()
          .then((snapshot) {
        final batch = _firestore.batch();
        for (final doc in snapshot.docs) {
          batch.update(doc.reference, {
            'status': action,
            'resolvedBy': currentUser.uid,
            'resolvedAt': FieldValue.serverTimestamp(),
          });
        }
        return batch.commit();
      });

      return true;
    } catch (e) {
      print('Error moderating content: $e');
      return false;
    }
  }

  DocumentReference _getContentReference(String contentType, String contentId) {
    switch (contentType) {
      case 'post':
        return _firestore.collection('posts').doc(contentId);
      case 'comment':
        return _firestore.collection('comments').doc(contentId);
      case 'reel':
        return _firestore.collection('reels').doc(contentId);
      case 'user':
        return _firestore.collection('users').doc(contentId);
      default:
        throw Exception('Unknown content type: $contentType');
    }
  }

  // Analytics
  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      // Get user analytics
      final usersSnapshot = await _firestore.collection('users').get();
      final usersByRole = <String, int>{};

      for (final doc in usersSnapshot.docs) {
        final data = doc.data();
        final role = data['role'] as String? ?? 'user';
        usersByRole[role] = (usersByRole[role] ?? 0) + 1;
      }

      // Get content analytics
      final postsSnapshot = await _firestore.collection('posts').get();
      final recentPostsSnapshot = await _firestore
          .collection('posts')
          .where('createdAt',
              isGreaterThan: Timestamp.fromDate(
                  DateTime.now().subtract(const Duration(days: 7))))
          .get();

      // Get reported content analytics
      final reportedContentSnapshot =
          await _firestore.collection('reported_content').get();

      // Get game analytics
      final gameDataSnapshot = await _firestore
          .collection('game_data')
          .where('status', isEqualTo: 'active')
          .get();

      return {
        'totalUsers': usersSnapshot.docs.length,
        'usersByRole': usersByRole,
        'totalPosts': postsSnapshot.docs.length,
        'recentPosts': recentPostsSnapshot.docs.length,
        'reportedContent': reportedContentSnapshot.docs.length,
        'activeGames': gameDataSnapshot.docs.length,
      };
    } catch (e) {
      print('Error getting analytics: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getCustomAnalyticsRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final startTimestamp = Timestamp.fromDate(startDate);
      final endTimestamp = Timestamp.fromDate(endDate);

      // Get new users in range
      final newUsersSnapshot = await _firestore
          .collection('users')
          .where('createdAt', isGreaterThanOrEqualTo: startTimestamp)
          .where('createdAt', isLessThanOrEqualTo: endTimestamp)
          .get();

      // Get new posts in range
      final newPostsSnapshot = await _firestore
          .collection('posts')
          .where('createdAt', isGreaterThanOrEqualTo: startTimestamp)
          .where('createdAt', isLessThanOrEqualTo: endTimestamp)
          .get();

      // Get games played in range
      final gamesPlayedSnapshot = await _firestore
          .collection('game_data')
          .where('createdAt', isGreaterThanOrEqualTo: startTimestamp)
          .where('createdAt', isLessThanOrEqualTo: endTimestamp)
          .get();

      return {
        'newUsers': newUsersSnapshot.docs.length,
        'newPosts': newPostsSnapshot.docs.length,
        'gamesPlayed': gamesPlayedSnapshot.docs.length,
        'startDate': startDate,
        'endDate': endDate,
      };
    } catch (e) {
      print('Error getting custom analytics: $e');
      return {};
    }
  }

  // Announcements
  Future<List<Map<String, dynamic>>> getAnnouncements({
    bool activeOnly = false,
    String? type,
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore.collection('announcements');

      if (activeOnly) {
        final now = Timestamp.fromDate(DateTime.now());

        query = query
            .where('active', isEqualTo: true)
            .where('startDate', isLessThanOrEqualTo: now);

        // We can't use multiple range operators in a compound query
        // So we'll filter end dates in the app
      }

      if (type != null && type != 'all') {
        query = query.where('type', isEqualTo: type);
      }

      query = query.orderBy(activeOnly ? 'startDate' : 'createdAt',
          descending: true);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      query = query.limit(limit);

      final snapshot = await query.get();

      List<Map<String, dynamic>> announcements = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      // If activeOnly, filter out announcements with passed end dates
      if (activeOnly) {
        final now = DateTime.now();

        announcements = announcements.where((announcement) {
          if (announcement['endDate'] == null) return true;

          final endDate = (announcement['endDate'] as Timestamp).toDate();
          return endDate.isAfter(now);
        }).toList();
      }

      return announcements;
    } catch (e) {
      print('Error getting announcements: $e');
      return [];
    }
  }

  Future<bool> createAnnouncement({
    required String title,
    required String message,
    required String type,
    String? targetAudience,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final announcementRef = _firestore.collection('announcements').doc();

      await announcementRef.set({
        'title': title,
        'message': message,
        'type': type,
        'targetAudience': targetAudience ?? 'all',
        'startDate':
            startDate != null ? Timestamp.fromDate(startDate) : Timestamp.now(),
        'endDate': endDate != null ? Timestamp.fromDate(endDate) : null,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': _auth.currentUser?.uid,
        'active': true,
      });

      return true;
    } catch (e) {
      print('Error creating announcement: $e');
      return false;
    }
  }

  Future<bool> updateAnnouncement(
      String announcementId, Map<String, dynamic> updateData) async {
    try {
      final Map<String, dynamic> dataToUpdate = {};

      // Convert DateTime to Timestamp for Firestore
      updateData.forEach((key, value) {
        if (value is DateTime) {
          dataToUpdate[key] = Timestamp.fromDate(value);
        } else {
          dataToUpdate[key] = value;
        }
      });

      dataToUpdate['updatedAt'] = FieldValue.serverTimestamp();
      dataToUpdate['updatedBy'] = _auth.currentUser?.uid;

      await _firestore
          .collection('announcements')
          .doc(announcementId)
          .update(dataToUpdate);

      return true;
    } catch (e) {
      print('Error updating announcement: $e');
      return false;
    }
  }

  Future<bool> deleteAnnouncement(String announcementId) async {
    try {
      await _firestore.collection('announcements').doc(announcementId).delete();
      return true;
    } catch (e) {
      print('Error deleting announcement: $e');
      return false;
    }
  }

  // Game Management
  Future<List<Map<String, dynamic>>> getGameLeaderboard(String gameId) async {
    try {
      final snapshot = await _firestore
          .collection('game_leaderboards')
          .doc(gameId)
          .collection('entries')
          .orderBy('score', descending: true)
          .limit(100)
          .get();

      List<Map<String, dynamic>> leaderboard = [];

      // For each leaderboard entry, get the user data
      for (final doc in snapshot.docs) {
        Map<String, dynamic> entry = doc.data();
        entry['id'] = doc.id;

        if (entry['userId'] != null) {
          final userDoc =
              await _firestore.collection('users').doc(entry['userId']).get();
          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>;
            entry['user'] = {
              'id': userDoc.id,
              'name': userData['name'],
              'image': userData['image'],
              'role': userData['role'],
            };
          }
        }

        leaderboard.add(entry);
      }

      return leaderboard;
    } catch (e) {
      print('Error getting game leaderboard: $e');
      return [];
    }
  }

  Future<bool> updateGameConfig(
      String gameId, Map<String, dynamic> config) async {
    try {
      await _firestore.collection('game_configs').doc(gameId).set(
        {
          ...config,
          'updatedAt': FieldValue.serverTimestamp(),
          'updatedBy': _auth.currentUser?.uid,
        },
        SetOptions(merge: true),
      );
      return true;
    } catch (e) {
      print('Error updating game config: $e');
      return false;
    }
  }

  // Admin Settings
  Future<Map<String, dynamic>> getAdminSettings() async {
    try {
      final doc = await _firestore.collection('admin').doc('settings').get();

      if (!doc.exists) {
        // Create default settings if they don't exist
        final defaultSettings = {
          'maintenanceMode': false,
          'enableRealTimeReports': true,
          'enableBackupDaily': true,
          'notifyAdminsOnReport': true,
          'autoDeleteReportsAfterDays': 30,
          'createdAt': FieldValue.serverTimestamp(),
        };

        await _firestore
            .collection('admin')
            .doc('settings')
            .set(defaultSettings);
        return defaultSettings;
      }

      return doc.data() as Map<String, dynamic>;
    } catch (e) {
      print('Error getting admin settings: $e');
      return {};
    }
  }

  Future<bool> updateAdminSettings(Map<String, dynamic> settings) async {
    try {
      await _firestore.collection('admin').doc('settings').update({
        ...settings,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _auth.currentUser?.uid,
      });
      return true;
    } catch (e) {
      print('Error updating admin settings: $e');
      return false;
    }
  }

  // Authentication Checks
  Future<bool> isCurrentUserAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) return false;

      final userData = userDoc.data() as Map<String, dynamic>;
      return userData['role'] == 'admin';
    } catch (e) {
      print('Error checking admin access: $e');
      return false;
    }
  }
}
