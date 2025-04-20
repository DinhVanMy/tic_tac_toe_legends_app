# Source Code Summary

## Directory Structure
```
./
  app_routes.dart
  controllers/
    admin_controller.dart
    dashboard_overview_controller.dart
    support_system_controller.dart
  middlewares/
    admin_middleware.dart
  models/
    user_model.dart
  Pages/
    admin_home_page.dart
    admin_setting_page.dart
    dashboard_overview.dart
    tabs/
      analytics_tab.dart
      announcements_tab.dart
      content_moderation_tab.dart
      game_management_tab.dart
      user_management_tab.dart
      user_support_system_tab.dart
    widgets/
      admin_access_widget.dart
  services/
    admin_service.dart
```


## File Contents


### app_routes.dart

```dart
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Pages/Admin/middlewares/admin_middleware.dart';
import 'package:tictactoe_gameapp/Pages/Admin/Pages/admin_setting_page.dart';
import 'package:tictactoe_gameapp/Pages/Admin/Pages/admin_home_page.dart';

class AdminRoutes {
  static List<GetPage> routes = [
    GetPage(
      name: '/admin',
      page: () => const AdminDashboardPage(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: '/admin/settings',
      page: () => const AdminSettingsPage(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: '/admin/home',
      page: () => const AdminDashboardPage(),
      middlewares: [AdminMiddleware()],
    ),
  ];

  static void setupAdminRoutes() {
    // Đăng ký các routes cho phần admin
    Get.addPages(routes);
  }
}
```

---


### controllers\admin_controller.dart

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Pages/Admin/models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Admin/services/admin_service.dart';

class AdminController extends GetxController with GetSingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  
  // Tab controller for admin dashboard
  late final TabController tabController;
  
  // User management variables
  final RxList<UserModel> users = <UserModel>[].obs;
  final RxBool isLoadingUsers = false.obs;
  DocumentSnapshot? lastUserDocument;
  final RxString userSearchQuery = ''.obs;
  final RxString selectedRoleFilter = 'all'.obs;
  final Rx<UserModel?> selectedUser = Rx<UserModel?>(null);
  
  // Content moderation variables
  final RxList<Map<String, dynamic>> reportedContent = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingReports = false.obs;
  DocumentSnapshot? lastReportDocument;
  final RxString contentTypeFilter = 'all'.obs;
  
  // Analytics variables
  final Rx<Map<String, dynamic>> analytics = Rx<Map<String, dynamic>>({});
  final RxBool isLoadingAnalytics = false.obs;
  final Rx<DateTime> analyticsStartDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  final Rx<DateTime> analyticsEndDate = DateTime.now().obs;
  
  // Announcements variables
  final RxList<Map<String, dynamic>> announcements = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingAnnouncements = false.obs;
  DocumentSnapshot? lastAnnouncementDocument;
  final RxString announcementTypeFilter = 'all'.obs;
  final Rx<Map<String, dynamic>> currentEditAnnouncement = Rx<Map<String, dynamic>>({});
  
  // Game management variables
  final RxMap<String, List<Map<String, dynamic>>> gameLeaderboards = <String, List<Map<String, dynamic>>>{}.obs;
  final RxBool isLoadingLeaderboards = false.obs;
  final RxString selectedGame = 'tictactoe'.obs;
  final RxMap<String, dynamic> gameConfig = <String, dynamic>{}.obs;
  
  // Selected users for batch operations
  final RxList<String> selectedUserIds = <String>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 5, vsync: this);
    
    // Initialize data
    fetchUsers();
    fetchReportedContent();
    fetchAnalytics();
    fetchAnnouncements();
    fetchGameLeaderboard('tictactoe');
    
    // Set up listeners for filters
    ever(userSearchQuery, (_) => debounce(
      () => fetchUsers(refresh: true),
      const Duration(milliseconds: 500),
    ));
    
    ever(selectedRoleFilter, (_) => fetchUsers(refresh: true));
    ever(contentTypeFilter, (_) => fetchReportedContent(refresh: true));
    ever(announcementTypeFilter, (_) => fetchAnnouncements(refresh: true));
    ever(selectedGame, (_) => fetchGameLeaderboard(selectedGame.value));
  }
  
  // Helper for search debounce
  void debounce(VoidCallback action, Duration duration) {
    Future.delayed(duration, action);
  }
  
  // User Management Functions
  
  Future<void> fetchUsers({bool refresh = false}) async {
    if (isLoadingUsers.value) return;
    isLoadingUsers.value = true;
    
    try {
      if (refresh) {
        lastUserDocument = null;
      }
      
      String? roleFilter;
      if (selectedRoleFilter.value != 'all') {
        roleFilter = selectedRoleFilter.value;
      }
      
      final fetchedUsers = await _adminService.getAllUsers(
        searchQuery: userSearchQuery.value.isEmpty ? null : userSearchQuery.value,
        role: roleFilter,
        startAfter: lastUserDocument,
      );
      
      if (refresh) {
        users.clear();
      }
      
      if (fetchedUsers.isNotEmpty) {
        users.addAll(fetchedUsers);
        // Update the last document for pagination
        // This is approximate - ideally we'd pass back the DocumentSnapshot directly from the service
        if (fetchedUsers.isNotEmpty) {
          final lastUserId = fetchedUsers.last.id;
          if (lastUserId != null) {
            final doc = await FirebaseFirestore.instance.collection('users').doc(lastUserId).get();
            lastUserDocument = doc;
          }
        }
      }
    } catch (e) {
      errorMessage("Error fetching users: $e");
    } finally {
      isLoadingUsers.value = false;
    }
  }
  
  Future<void> selectUser(String userId) async {
    try {
      final user = await _adminService.getUserById(userId);
      selectedUser.value = user;
    } catch (e) {
      errorMessage("Error fetching user details: $e");
    }
  }
  
  Future<bool> updateUserRole(String userId, String newRole) async {
    try {
      final success = await _adminService.updateUserRole(userId, newRole);
      if (success) {
        // Update local user in the list
        final index = users.indexWhere((user) => user.id == userId);
        if (index != -1) {
          final updatedUser = users[index].copyWith(role: newRole);
          users[index] = updatedUser;
          
          // Update selected user if this is the one being viewed
          if (selectedUser.value?.id == userId) {
            selectedUser.value = updatedUser;
          }
        }
      }
      return success;
    } catch (e) {
      errorMessage("Error updating user role: $e");
      return false;
    }
  }
  
  Future<bool> performBatchOperation(String operation) async {
    if (selectedUserIds.isEmpty) {
      errorMessage("No users selected");
      return false;
    }
    
    try {
      final success = await _adminService.batchUserOperation(
        selectedUserIds.toList(),
        operation,
      );
      
      if (success) {
        // Refresh user list after batch operation
        fetchUsers(refresh: true);
        // Clear selection
        selectedUserIds.clear();
      }
      
      return success;
    } catch (e) {
      errorMessage("Error performing batch operation: $e");
      return false;
    }
  }
  
  void toggleUserSelection(String userId) {
    if (selectedUserIds.contains(userId)) {
      selectedUserIds.remove(userId);
    } else {
      selectedUserIds.add(userId);
    }
  }
  
  void clearUserSelection() {
    selectedUserIds.clear();
  }
  
  // Content Moderation Functions
  
  Future<void> fetchReportedContent({bool refresh = false}) async {
    if (isLoadingReports.value) return;
    isLoadingReports.value = true;
    
    try {
      if (refresh) {
        lastReportDocument = null;
      }
      
      String? typeFilter;
      if (contentTypeFilter.value != 'all') {
        typeFilter = contentTypeFilter.value;
      }
      
      final reports = await _adminService.getReportedContent(
        contentType: typeFilter,
        startAfter: lastReportDocument,
      );
      
      if (refresh) {
        reportedContent.clear();
      }
      
      if (reports.isNotEmpty) {
        reportedContent.addAll(reports);
        
        // Update the last document for pagination
        if (reports.isNotEmpty) {
          final lastReportId = reports.last['id'] as String;
          final doc = await FirebaseFirestore.instance
              .collection('reported_content')
              .doc(lastReportId)
              .get();
          lastReportDocument = doc;
        }
      }
    } catch (e) {
      errorMessage("Error fetching reported content: $e");
    } finally {
      isLoadingReports.value = false;
    }
  }
  
  Future<bool> moderateContent(String contentType, String contentId, String action, {String? reason}) async {
    try {
      final success = await _adminService.moderateContent(
        contentType: contentType,
        contentId: contentId,
        action: action,
        reason: reason,
      );
      
      if (success) {
        // Refresh reported content after moderation
        fetchReportedContent(refresh: true);
      }
      
      return success;
    } catch (e) {
      errorMessage("Error moderating content: $e");
      return false;
    }
  }
  
  // Analytics Functions
  
  Future<void> fetchAnalytics() async {
    if (isLoadingAnalytics.value) return;
    isLoadingAnalytics.value = true;
    
    try {
      final data = await _adminService.getAnalytics();
      analytics.value = data;
    } catch (e) {
      errorMessage("Error fetching analytics: $e");
    } finally {
      isLoadingAnalytics.value = false;
    }
  }
  
  Future<void> fetchCustomAnalytics() async {
    if (isLoadingAnalytics.value) return;
    isLoadingAnalytics.value = true;
    
    try {
      final data = await _adminService.getCustomAnalyticsRange(
        analyticsStartDate.value,
        analyticsEndDate.value,
      );
      
      // Merge with existing analytics
      analytics.value = {
        ...analytics.value,
        'customRange': data,
      };
    } catch (e) {
      errorMessage("Error fetching custom analytics: $e");
    } finally {
      isLoadingAnalytics.value = false;
    }
  }
  
  void setAnalyticsDateRange(DateTime start, DateTime end) {
    analyticsStartDate.value = start;
    analyticsEndDate.value = end;
    fetchCustomAnalytics();
  }
  
  // Announcements Functions
  
  Future<void> fetchAnnouncements({bool refresh = false}) async {
    if (isLoadingAnnouncements.value) return;
    isLoadingAnnouncements.value = true;
    
    try {
      if (refresh) {
        lastAnnouncementDocument = null;
      }
      
      String? typeFilter;
      if (announcementTypeFilter.value != 'all') {
        typeFilter = announcementTypeFilter.value;
      }
      
      final fetchedAnnouncements = await _adminService.getAnnouncements(
        activeOnly: false,  // Admin should see all announcements
        type: typeFilter,
        startAfter: lastAnnouncementDocument,
      );
      
      if (refresh) {
        announcements.clear();
      }
      
      if (fetchedAnnouncements.isNotEmpty) {
        announcements.addAll(fetchedAnnouncements);
        
        // Update the last document for pagination
        if (fetchedAnnouncements.isNotEmpty) {
          final lastId = fetchedAnnouncements.last['id'] as String;
          final doc = await FirebaseFirestore.instance
              .collection('announcements')
              .doc(lastId)
              .get();
          lastAnnouncementDocument = doc;
        }
      }
    } catch (e) {
      errorMessage("Error fetching announcements: $e");
    } finally {
      isLoadingAnnouncements.value = false;
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
      final success = await _adminService.createAnnouncement(
        title: title,
        message: message,
        type: type,
        targetAudience: targetAudience,
        startDate: startDate,
        endDate: endDate,
      );
      
      if (success) {
        // Refresh announcements after creation
        fetchAnnouncements(refresh: true);
      }
      
      return success;
    } catch (e) {
      errorMessage("Error creating announcement: $e");
      return false;
    }
  }
  
  Future<bool> updateAnnouncement(String announcementId, Map<String, dynamic> updateData) async {
    try {
      final success = await _adminService.updateAnnouncement(announcementId, updateData);
      
      if (success) {
        // Refresh announcements after update
        fetchAnnouncements(refresh: true);
      }
      
      return success;
    } catch (e) {
      errorMessage("Error updating announcement: $e");
      return false;
    }
  }
  
  Future<bool> deleteAnnouncement(String announcementId) async {
    try {
      final success = await _adminService.deleteAnnouncement(announcementId);
      
      if (success) {
        // Refresh announcements after deletion
        fetchAnnouncements(refresh: true);
      }
      
      return success;
    } catch (e) {
      errorMessage("Error deleting announcement: $e");
      return false;
    }
  }
  
  void editAnnouncement(Map<String, dynamic> announcement) {
    currentEditAnnouncement.value = announcement;
  }
  
  // Game Management Functions
  
  Future<void> fetchGameLeaderboard(String gameId) async {
    if (isLoadingLeaderboards.value) return;
    isLoadingLeaderboards.value = true;
    
    try {
      final leaderboard = await _adminService.getGameLeaderboard(gameId);
      gameLeaderboards[gameId] = leaderboard;
    } catch (e) {
      errorMessage("Error fetching game leaderboard: $e");
    } finally {
      isLoadingLeaderboards.value = false;
    }
  }
  
  Future<void> fetchGameConfig(String gameId) async {
    try {
      // Fetch game configuration from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('game_configs')
          .doc(gameId)
          .get();
          
      if (doc.exists) {
        gameConfig.value = doc.data() as Map<String, dynamic>;
      } else {
        gameConfig.value = {};
      }
    } catch (e) {
      errorMessage("Error fetching game config: $e");
      gameConfig.value = {};
    }
  }
  
  Future<bool> updateGameConfig(String gameId, Map<String, dynamic> config) async {
    try {
      final success = await _adminService.updateGameConfig(gameId, config);
      
      if (success) {
        // Update local state
        gameConfig.value = {
          ...gameConfig.value,
          ...config,
        };
      }
      
      return success;
    } catch (e) {
      errorMessage("Error updating game config: $e");
      return false;
    }
  }
  
  // Authentication check
  Future<bool> checkAdminAccess() async {
    return await _adminService.isCurrentUserAdmin();
  }
  
  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
```

---


### controllers\dashboard_overview_controller.dart

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Pages/Admin/models/user_model.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';

class DashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Loading state
  final RxBool isLoading = true.obs;

  // Dashboard data
  final Rx<Map<String, dynamic>> summaryStats = Rx<Map<String, dynamic>>({});
  final Rx<Map<String, dynamic>> systemHealth = Rx<Map<String, dynamic>>({});
  final RxList<Map<String, dynamic>> userActivityData = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> recentReports = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> activeAnnouncements = <Map<String, dynamic>>[].obs;
  final RxList<UserModel> topUsers = <UserModel>[].obs;
  final RxList<Map<String, dynamic>> topGames = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> systemLogs = <Map<String, dynamic>>[].obs;

  // Filters and settings
  final RxString activityTimeRange = 'week'.obs;
  final RxString userSortCriteria = 'coins'.obs;
  final RxString gameSortCriteria = 'plays'.obs;
  final RxInt maxUserActivity = 1000.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllData();
  }

  Future<void> loadAllData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        loadSummaryStats(),
        loadUserActivityData(),
        loadRecentReports(),
        loadActiveAnnouncements(),
        loadTopUsers(),
        loadTopGames(),
        loadSystemHealth(),
        loadSystemLogs(),
      ]);
    } catch (e) {
      errorMessage('Error loading dashboard data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshAllData() async {
    try {
      isLoading.value = true;
      await loadAllData();
      successMessage('Dashboard refreshed');
    } catch (e) {
      errorMessage('Error refreshing dashboard: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSummaryStats() async {
    try {
      // Get total users count
      final userCount = await _firestore.collection('users').count().get();
      
      // Get new users today
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final newUsersToday = await _firestore
          .collection('users')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .count()
          .get();
      
      // Get pending reports count
      final pendingReports = await _firestore
          .collection('reported_content')
          .where('status', isEqualTo: 'pending')
          .count()
          .get();
      
      // Get critical reports count (reports with high severity)
      final criticalReports = await _firestore
          .collection('reported_content')
          .where('status', isEqualTo: 'pending')
          .where('severity', isEqualTo: 'high')
          .count()
          .get();
      
      // Get active games count
      final activeGames = await _firestore
          .collection('game_data')
          .where('status', isEqualTo: 'active')
          .count()
          .get();
      
      // Get new games started today
      final newGamesToday = await _firestore
          .collection('game_data')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .count()
          .get();
      
      // Mock revenue data (in a real app, you'd get this from a payments collection)
      const revenue = 2450;
      const revenueChange = 12.5; // Percentage change from last week
      
      // Update summaryStats
      summaryStats.value = {
        'totalUsers': userCount.count,
        'newUsers': newUsersToday.count,
        'pendingReports': pendingReports.count,
        'criticalReports': criticalReports.count,
        'activeGames': activeGames.count,
        'newGames': newGamesToday.count,
        'revenue': revenue,
        'revenueChange': revenueChange,
      };
    } catch (e) {
      print('Error loading summary stats: $e');
      // Provide fallback data if there's an error
      summaryStats.value = {
        'totalUsers': 0,
        'newUsers': 0,
        'pendingReports': 0,
        'criticalReports': 0,
        'activeGames': 0,
        'newGames': 0,
        'revenue': 0,
        'revenueChange': 0,
      };
    }
  }

  Future<void> loadUserActivityData({String? timeRange}) async {
    try {
      if (timeRange != null) {
        activityTimeRange.value = timeRange;
      }
      
      // Generate mock data for user activity (in a real app, you'd get this from analytics)
      final List<Map<String, dynamic>> mockData = [];
      
      DateTime now = DateTime.now();
      int dataPoints;
      String labelFormat;
      
      switch (activityTimeRange.value) {
        case 'day':
          dataPoints = 24; // Hours in a day
          labelFormat = 'HH:00'; // Hour format
          for (int i = 0; i < dataPoints; i++) {
            final hour = now.hour - (dataPoints - 1 - i);
            final dateTime = DateTime(now.year, now.month, now.day, hour >= 0 ? hour : hour + 24);
            mockData.add({
              'timestamp': dateTime,
              'label': '${dateTime.hour}:00',
              'activeUsers': 100 + (i * 10) + (dateTime.hour * 5),
              'newUsers': 10 + (i * 2),
              'gameSessions': 50 + (i * 15) + (dateTime.hour * 3),
            });
          }
          break;
          
        case 'week':
          dataPoints = 7; // Days in a week
          labelFormat = 'E'; // Day of week format
          for (int i = 0; i < dataPoints; i++) {
            final day = now.day - (dataPoints - 1 - i);
            final dateTime = DateTime(now.year, now.month, day);
            mockData.add({
              'timestamp': dateTime,
              'label': dateTime.weekday.toString(),
              'activeUsers': 500 + (i * 100) + (dateTime.weekday * 50),
              'newUsers': 50 + (i * 10) + (dateTime.weekday * 5),
              'gameSessions': 300 + (i * 80) + (dateTime.weekday * 30),
            });
          }
          break;
          
        case 'month':
          dataPoints = 30; // Days in a month (approximately)
          labelFormat = 'MM/dd'; // Month/day format
          for (int i = 0; i < dataPoints; i++) {
            final day = now.day - (dataPoints - 1 - i);
            final dateTime = DateTime(now.year, now.month, day);
            mockData.add({
              'timestamp': dateTime,
              'label': '${dateTime.month}/${dateTime.day}',
              'activeUsers': 1000 + (i * 50) + (dateTime.day * 20),
              'newUsers': 100 + (i * 5) + (dateTime.day * 2),
              'gameSessions': 600 + (i * 30) + (dateTime.day * 15),
            });
          }
          break;
          
        default:
          dataPoints = 7; // Default to week
          labelFormat = 'E';
          for (int i = 0; i < dataPoints; i++) {
            final day = now.day - (dataPoints - 1 - i);
            final dateTime = DateTime(now.year, now.month, day);
            mockData.add({
              'timestamp': dateTime,
              'label': dateTime.weekday.toString(),
              'activeUsers': 500 + (i * 100),
              'newUsers': 50 + (i * 10),
              'gameSessions': 300 + (i * 80),
            });
          }
      }
      
      // Update UI data
      userActivityData.assignAll(mockData);
      
      // Calculate maximum value for chart scaling
      int maxValue = 0;
      for (final data in mockData) {
        final activeUsers = data['activeUsers'] as int;
        final newUsers = data['newUsers'] as int;
        final gameSessions = data['gameSessions'] as int;
        
        maxValue = [maxValue, activeUsers, newUsers, gameSessions].reduce((a, b) => a > b ? a : b);
      }
      
      // Add 10% margin to max value for better chart visualization
      maxUserActivity.value = (maxValue * 1.1).round();
    } catch (e) {
      print('Error loading user activity data: $e');
      userActivityData.clear();
      maxUserActivity.value = 1000;
    }
  }

  Future<void> loadRecentReports() async {
    try {
      final snapshot = await _firestore
          .collection('reported_content')
          .orderBy('reportedAt', descending: true)
          .limit(10)
          .get();
      
      List<Map<String, dynamic>> reports = [];
      
      for (final doc in snapshot.docs) {
        Map<String, dynamic> report = doc.data();
        report['id'] = doc.id;
        
        // Convert Timestamp to DateTime for easier handling
        if (report['reportedAt'] != null) {
          report['reportedAt'] = (report['reportedAt'] as Timestamp).toDate();
        }
        
        // Fetch reporter data
        if (report['reporterId'] != null) {
          final reporterDoc = await _firestore
              .collection('users')
              .doc(report['reporterId'] as String)
              .get();
          
          if (reporterDoc.exists) {
            final reporterData = reporterDoc.data();
            report['reporter'] = {
              'id': reporterDoc.id,
              'name': reporterData?['name'] ?? 'Unknown',
              'image': reporterData?['image'] ?? '',
            };
          } else {
            report['reporter'] = {
              'id': report['reporterId'],
              'name': 'Unknown',
              'image': '',
            };
          }
        } else {
          report['reporter'] = {
            'id': '',
            'name': 'System',
            'image': '',
          };
        }
        
        reports.add(report);
      }
      
      recentReports.assignAll(reports);
    } catch (e) {
      print('Error loading recent reports: $e');
      recentReports.clear();
    }
  }

  Future<void> loadActiveAnnouncements() async {
    try {
      final now = Timestamp.fromDate(DateTime.now());
      
      final snapshot = await _firestore
          .collection('announcements')
          .where('active', isEqualTo: true)
          .where('startDate', isLessThanOrEqualTo: now)
          .orderBy('startDate', descending: true)
          .limit(10)
          .get();
      
      List<Map<String, dynamic>> announcements = [];
      
      for (final doc in snapshot.docs) {
        Map<String, dynamic> announcement = doc.data();
        announcement['id'] = doc.id;
        
        // Convert Timestamps to DateTimes for easier handling
        if (announcement['startDate'] != null) {
          announcement['startDate'] = (announcement['startDate'] as Timestamp).toDate();
        }
        
        if (announcement['endDate'] != null) {
          announcement['endDate'] = (announcement['endDate'] as Timestamp).toDate();
          
          // Skip announcements that have ended
          if ((announcement['endDate'] as DateTime).isBefore(DateTime.now())) {
            continue;
          }
        }
        
        announcements.add(announcement);
      }
      
      activeAnnouncements.assignAll(announcements);
    } catch (e) {
      print('Error loading active announcements: $e');
      activeAnnouncements.clear();
    }
  }

  Future<void> loadTopUsers({String? sortBy}) async {
    try {
      if (sortBy != null) {
        userSortCriteria.value = sortBy;
      }
      
      String fieldToSort;
      bool isNumeric = true;
      
      switch (userSortCriteria.value) {
        case 'coins':
          fieldToSort = 'totalCoins';
          break;
        case 'wins':
          fieldToSort = 'totalWins';
          break;
        case 'activity':
          fieldToSort = 'lastActive';
          isNumeric = false;
          break;
        default:
          fieldToSort = 'totalCoins';
      }
      
      Query query = _firestore.collection('users');
      
      if (isNumeric) {
        // For numeric fields, we need to do some special handling since they're stored as strings
        // In a real app, you'd store these as numbers or convert them to numbers in a Cloud Function
        query = query.orderBy(fieldToSort, descending: true);
      } else {
        // For date fields
        query = query.orderBy(fieldToSort, descending: true);
      }
      
      final snapshot = await query.limit(10).get();
      
      List<UserModel> users = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return UserModel.fromJson(data);
      }).toList();
      
      topUsers.assignAll(users);
    } catch (e) {
      print('Error loading top users: $e');
      topUsers.clear();
    }
  }

  Future<void> loadTopGames({String? sortBy}) async {
    try {
      if (sortBy != null) {
        gameSortCriteria.value = sortBy;
      }
      
      // Mock game data (in a real app, you'd get this from Firestore)
      final List<Map<String, dynamic>> mockGames = [
        {
          'id': 'tictactoe',
          'name': 'Tic Tac Toe',
          'image': '',
          'plays': 12500,
          'active': 850,
          'revenue': 2300,
          'growth': 15,
        },
        {
          'id': 'sudoku',
          'name': 'Sudoku',
          'image': '',
          'plays': 8200,
          'active': 620,
          'revenue': 1200,
          'growth': 8,
        },
        {
          'id': 'minesweeper',
          'name': 'Minesweeper',
          'image': '',
          'plays': 6400,
          'active': 410,
          'revenue': 850,
          'growth': -3,
        },
        {
          'id': 'match3',
          'name': 'Match 3',
          'image': '',
          'plays': 15800,
          'active': 1050,
          'revenue': 3600,
          'growth': 22,
        },
        {
          'id': '2048',
          'name': '2048',
          'image': '',
          'plays': 9300,
          'active': 580,
          'revenue': 1500,
          'growth': 5,
        },
      ];
      
      // Sort the games based on the selected criteria
      mockGames.sort((a, b) {
        final aValue = a[gameSortCriteria.value] as int;
        final bValue = b[gameSortCriteria.value] as int;
        return bValue.compareTo(aValue); // Descending order
      });
      
      topGames.assignAll(mockGames);
    } catch (e) {
      print('Error loading top games: $e');
      topGames.clear();
    }
  }

  Future<void> loadSystemHealth() async {
    try {
      // Mock system health data (in a real app, you'd get this from a monitoring service)
      final Map<String, dynamic> mockHealth = {
        'apiStatus': 'good',
        'apiResponseTime': 42,
        'dbStatus': 'good',
        'dbConnections': 28,
        'storageStatus': 'good',
        'storageUsage': 67,
        'cacheStatus': 'good',
        'cacheHitRate': 92,
        'lastChecked': DateTime.now(),
      };
      
      systemHealth.value = mockHealth;
    } catch (e) {
      print('Error loading system health: $e');
      systemHealth.value = {
        'apiStatus': 'unknown',
        'dbStatus': 'unknown',
        'storageStatus': 'unknown',
        'cacheStatus': 'unknown',
      };
    }
  }

  Future<void> loadSystemLogs() async {
    try {
      // Mock system logs (in a real app, you'd get this from Firestore or a logging service)
      final List<Map<String, dynamic>> mockLogs = [
        {
          'level': 'info',
          'message': 'User authentication successful',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
        },
        {
          'level': 'warning',
          'message': 'High database load detected',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
        },
        {
          'level': 'error',
          'message': 'Failed to process payment for user xyz123',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 25)),
        },
        {
          'level': 'info',
          'message': 'Daily backup completed successfully',
          'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
        },
        {
          'level': 'info',
          'message': 'New user registration: user123@example.com',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        },
      ];
      
      systemLogs.assignAll(mockLogs);
    } catch (e) {
      print('Error loading system logs: $e');
      systemLogs.clear();
    }
  }
}
```

---


### controllers\support_system_controller.dart

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';

class SupportSystemController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Loading state
  final RxBool isLoading = true.obs;

  // Form controllers
  final TextEditingController searchController = TextEditingController();
  final TextEditingController replyController = TextEditingController();

  // Search and filter state
  final RxString searchQuery = ''.obs;
  final RxString selectedStatusFilter = 'all'.obs;
  final RxString selectedPriorityFilter = 'all'.obs;
  final RxString sortCriteria = 'date'.obs;

  // Selected ticket
  final RxString selectedTicketId = ''.obs;

  // Ticket data
  final RxList<Map<String, dynamic>> allTickets = <Map<String, dynamic>>[].obs;

  // Knowledge base data
  final RxList<Map<String, dynamic>> knowledgeBaseArticles =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();

    // Set up reactive search
    searchController.addListener(() {
      searchQuery.value = searchController.text.trim();
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    replyController.dispose();
    super.onClose();
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    await loadData();
  }

  Future<void> loadData() async {
    try {
      await Future.wait([
        loadTickets(),
        loadKnowledgeBase(),
      ]);
    } catch (e) {
      print('Error loading support data: $e');
      errorMessage('Failed to load support data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTickets() async {
    try {
      // In a real app, this would fetch tickets from Firestore
      // For this example, we'll generate mock data

      final List<Map<String, dynamic>> tickets = [];
      final now = DateTime.now();

      // Mock ticket statuses
      final List<String> statuses = ['open', 'pending', 'resolved'];

      // Mock ticket priorities
      final List<String> priorities = ['low', 'medium', 'high'];

      // Mock ticket categories
      final List<String> categories = [
        'Account',
        'Billing',
        'Game Play',
        'Technical',
        'Feature Request',
        'Bug Report',
        'Other',
      ];

      // Generate mock tickets
      for (int i = 0; i < 20; i++) {
        final status = statuses[i % statuses.length];
        final priority = priorities[i % priorities.length];
        final category = categories[i % categories.length];
        final createdAt = now.subtract(Duration(days: i * 2));
        final lastUpdated = now.subtract(Duration(days: i));

        // Generate messages if status is not resolved
        final List<Map<String, dynamic>> messages = [];

        if (status != 'resolved') {
          // Add some mock messages
          final messageCount = 1 + (i % 3);

          for (int j = 0; j < messageCount; j++) {
            final isUserMessage = j % 2 == 0;

            messages.add({
              'sender': isUserMessage ? 'User ${i + 1}' : 'Support Agent',
              'senderImage': '',
              'content': isUserMessage
                  ? 'I\'m still experiencing the issue. Can you provide more information?'
                  : 'Thank you for the update. We\'ll look into this further.',
              'timestamp': now.subtract(Duration(days: i, hours: j * 6)),
              'isUser': isUserMessage,
            });
          }
        }

        tickets.add({
          'id': 'ticket${1000 + i}',
          'subject': getTicketSubject(category, i),
          'description': getTicketDescription(category, i),
          'userId': 'user${1000 + i}',
          'userName': 'User ${i + 1}',
          'userEmail': 'user${i + 1}@example.com',
          'userImage': '',
          'status': status,
          'priority': priority,
          'category': category,
          'assignedTo': i % 4 == 0 ? 'Agent ${i % 3 + 1}' : null,
          'createdAt': createdAt,
          'lastUpdated': lastUpdated,
          'messages': messages,
          'hasNewMessage': i % 5 == 0,
          'tags': getTags(category, i),
          'platform': i % 2 == 0 ? 'iOS' : 'Android',
          'deviceInfo': i % 2 == 0 ? 'iPhone 13' : 'Samsung Galaxy S21',
          'appVersion': '1.${5 + (i % 3)}.0',
        });
      }

      allTickets.assignAll(tickets);

      // If a ticket was selected, update it with the latest data
      if (selectedTicketId.isNotEmpty) {
        final ticketIndex = tickets
            .indexWhere((ticket) => ticket['id'] == selectedTicketId.value);
        if (ticketIndex == -1) {
          // Selected ticket no longer exists
          selectedTicketId.value = '';
        }
      }
    } catch (e) {
      print('Error loading tickets: $e');
      errorMessage('Failed to load tickets: $e');
    }
  }

  Future<void> loadKnowledgeBase() async {
    try {
      // In a real app, this would fetch articles from Firestore
      // For this example, we'll generate mock data

      final List<Map<String, dynamic>> articles = [];
      final now = DateTime.now();

      // Mock categories
      final List<String> categories = [
        'Account',
        'Billing',
        'Game Play',
        'Technical',
        'Feature Request',
        'Bug Report',
        'Other',
      ];

      // Generate mock articles
      for (int i = 0; i < 15; i++) {
        final category = categories[i % categories.length];

        articles.add({
          'id': 'article${1000 + i}',
          'title': getArticleTitle(category, i),
          'content': getArticleContent(category, i),
          'summary': getArticleSummary(category, i),
          'category': category,
          'author': 'Admin',
          'createdAt': now.subtract(Duration(days: i * 10)),
          'updatedAt': now.subtract(Duration(days: i * 5)),
          'views': 100 - (i * 5),
          'helpful': 50 - (i * 3),
        });
      }

      knowledgeBaseArticles.assignAll(articles);
    } catch (e) {
      print('Error loading knowledge base: $e');
      errorMessage('Failed to load knowledge base: $e');
    }
  }

  List<Map<String, dynamic>> getFilteredTickets() {
    // Apply filters to the tickets
    return allTickets.where((ticket) {
      // Apply search filter
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        final subject = (ticket['subject'] as String).toLowerCase();
        final description = (ticket['description'] as String).toLowerCase();
        final userName = (ticket['userName'] as String).toLowerCase();
        final ticketId = (ticket['id'] as String).toLowerCase();

        if (!subject.contains(query) &&
            !description.contains(query) &&
            !userName.contains(query) &&
            !ticketId.contains(query)) {
          return false;
        }
      }

      // Apply status filter
      if (selectedStatusFilter.value != 'all' &&
          ticket['status'] != selectedStatusFilter.value) {
        return false;
      }

      // Apply priority filter
      if (selectedPriorityFilter.value != 'all' &&
          ticket['priority'] != selectedPriorityFilter.value) {
        return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        // Apply sorting
        switch (sortCriteria.value) {
          case 'date':
            return (b['lastUpdated'] as DateTime)
                .compareTo(a['lastUpdated'] as DateTime);
          case 'priority':
            final priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
            return priorityOrder[a['priority']]!
                .compareTo(priorityOrder[b['priority']]!);
          case 'status':
            final statusOrder = {'open': 0, 'pending': 1, 'resolved': 2};
            return statusOrder[a['status']]!
                .compareTo(statusOrder[b['status']]!);
          default:
            return (b['lastUpdated'] as DateTime)
                .compareTo(a['lastUpdated'] as DateTime);
        }
      });
  }

  List<Map<String, dynamic>> getAllTickets() {
    return allTickets;
  }

  Map<String, dynamic>? getSelectedTicket() {
    if (selectedTicketId.isEmpty) return null;

    final ticketIndex = allTickets
        .indexWhere((ticket) => ticket['id'] == selectedTicketId.value);
    if (ticketIndex == -1) return null;

    return allTickets[ticketIndex];
  }

  void selectTicket(String ticketId) {
    selectedTicketId.value = ticketId;

    // Mark any new messages as read
    final ticketIndex =
        allTickets.indexWhere((ticket) => ticket['id'] == ticketId);
    if (ticketIndex != -1) {
      final ticket = Map<String, dynamic>.from(allTickets[ticketIndex]);
      if (ticket['hasNewMessage'] == true) {
        ticket['hasNewMessage'] = false;
        allTickets[ticketIndex] = ticket;
      }
    }
  }

  List<Map<String, dynamic>> getRelatedArticles(String category) {
    return knowledgeBaseArticles
        .where((article) => article['category'] == category)
        .toList();
  }

  List<Map<String, dynamic>> getFilteredKnowledgeBaseArticles(
      String query, String? category) {
    return knowledgeBaseArticles.where((article) {
      // Apply search filter
      if (query.isNotEmpty) {
        final lowercaseQuery = query.toLowerCase();
        final title = (article['title'] as String).toLowerCase();
        final content = (article['content'] as String).toLowerCase();
        final summary = (article['summary'] as String).toLowerCase();

        if (!title.contains(lowercaseQuery) &&
            !content.contains(lowercaseQuery) &&
            !summary.contains(lowercaseQuery)) {
          return false;
        }
      }

      // Apply category filter
      if (category != null && article['category'] != category) {
        return false;
      }

      return true;
    }).toList();
  }

  void resetFilters() {
    searchController.clear();
    searchQuery.value = '';
    selectedStatusFilter.value = 'all';
    selectedPriorityFilter.value = 'all';
    sortCriteria.value = 'date';
  }

  // Ticket management methods
  Future<bool> sendReply(String ticketId, String message) async {
    try {
      final ticketIndex =
          allTickets.indexWhere((ticket) => ticket['id'] == ticketId);
      if (ticketIndex == -1) return false;

      final ticket = Map<String, dynamic>.from(allTickets[ticketIndex]);
      final messages = List<Map<String, dynamic>>.from(
          ticket['messages'] as List<dynamic>? ?? []);

      // Add new message
      messages.add({
        'sender': 'Support Agent',
        'senderImage': '',
        'content': message,
        'timestamp': DateTime.now(),
        'isUser': false,
      });

      // Update ticket
      ticket['messages'] = messages;
      ticket['lastUpdated'] = DateTime.now();
      ticket['status'] =
          'pending'; // Change status to pending when agent replies

      // Update ticket in list
      allTickets[ticketIndex] = ticket;

      return true;
    } catch (e) {
      print('Error sending reply: $e');
      errorMessage('Failed to send reply: $e');
      return false;
    }
  }

  Future<bool> resolveTicket(String ticketId, String resolution) async {
    try {
      final ticketIndex =
          allTickets.indexWhere((ticket) => ticket['id'] == ticketId);
      if (ticketIndex == -1) return false;

      final ticket = Map<String, dynamic>.from(allTickets[ticketIndex]);
      final messages = List<Map<String, dynamic>>.from(
          ticket['messages'] as List<dynamic>? ?? []);

      // Add resolution message
      messages.add({
        'sender': 'Support Agent',
        'senderImage': '',
        'content': resolution,
        'timestamp': DateTime.now(),
        'isUser': false,
        'isResolution': true,
      });

      // Update ticket
      ticket['messages'] = messages;
      ticket['lastUpdated'] = DateTime.now();
      ticket['status'] = 'resolved';
      ticket['resolution'] = resolution;

      // Update ticket in list
      allTickets[ticketIndex] = ticket;

      return true;
    } catch (e) {
      print('Error resolving ticket: $e');
      errorMessage('Failed to resolve ticket: $e');
      return false;
    }
  }

  Future<bool> reopenTicket(String ticketId, String reason) async {
    try {
      final ticketIndex =
          allTickets.indexWhere((ticket) => ticket['id'] == ticketId);
      if (ticketIndex == -1) return false;

      final ticket = Map<String, dynamic>.from(allTickets[ticketIndex]);
      final messages = List<Map<String, dynamic>>.from(
          ticket['messages'] as List<dynamic>? ?? []);

      // Add reopen message
      messages.add({
        'sender': 'Support Agent',
        'senderImage': '',
        'content': 'Ticket reopened: $reason',
        'timestamp': DateTime.now(),
        'isUser': false,
        'isReopen': true,
      });

      // Update ticket
      ticket['messages'] = messages;
      ticket['lastUpdated'] = DateTime.now();
      ticket['status'] = 'open';
      ticket.remove('resolution');

      // Update ticket in list
      allTickets[ticketIndex] = ticket;

      return true;
    } catch (e) {
      print('Error reopening ticket: $e');
      errorMessage('Failed to reopen ticket: $e');
      return false;
    }
  }

  Future<bool> assignTicket(
      String ticketId, String agentId, String agentName) async {
    try {
      final ticketIndex =
          allTickets.indexWhere((ticket) => ticket['id'] == ticketId);
      if (ticketIndex == -1) return false;

      final ticket = Map<String, dynamic>.from(allTickets[ticketIndex]);

      // Update ticket
      ticket['assignedTo'] = agentName;
      ticket['assignedToId'] = agentId;
      ticket['lastUpdated'] = DateTime.now();

      // Update ticket in list
      allTickets[ticketIndex] = ticket;

      return true;
    } catch (e) {
      print('Error assigning ticket: $e');
      errorMessage('Failed to assign ticket: $e');
      return false;
    }
  }

  Future<bool> unassignTicket(String ticketId) async {
    try {
      final ticketIndex =
          allTickets.indexWhere((ticket) => ticket['id'] == ticketId);
      if (ticketIndex == -1) return false;

      final ticket = Map<String, dynamic>.from(allTickets[ticketIndex]);

      // Update ticket
      ticket.remove('assignedTo');
      ticket.remove('assignedToId');
      ticket['lastUpdated'] = DateTime.now();

      // Update ticket in list
      allTickets[ticketIndex] = ticket;

      return true;
    } catch (e) {
      print('Error unassigning ticket: $e');
      errorMessage('Failed to unassign ticket: $e');
      return false;
    }
  }

  Future<bool> changeTicketPriority(String ticketId, String priority) async {
    try {
      final ticketIndex =
          allTickets.indexWhere((ticket) => ticket['id'] == ticketId);
      if (ticketIndex == -1) return false;

      final ticket = Map<String, dynamic>.from(allTickets[ticketIndex]);

      // Update ticket
      ticket['priority'] = priority;
      ticket['lastUpdated'] = DateTime.now();

      // Update ticket in list
      allTickets[ticketIndex] = ticket;

      return true;
    } catch (e) {
      print('Error changing ticket priority: $e');
      errorMessage('Failed to change ticket priority: $e');
      return false;
    }
  }

  Future<bool> changeTicketCategory(String ticketId, String category) async {
    try {
      final ticketIndex =
          allTickets.indexWhere((ticket) => ticket['id'] == ticketId);
      if (ticketIndex == -1) return false;

      final ticket = Map<String, dynamic>.from(allTickets[ticketIndex]);

      // Update ticket
      ticket['category'] = category;
      ticket['lastUpdated'] = DateTime.now();

      // Update ticket in list
      allTickets[ticketIndex] = ticket;

      return true;
    } catch (e) {
      print('Error changing ticket category: $e');
      errorMessage('Failed to change ticket category: $e');
      return false;
    }
  }

  Future<bool> addTagToTicket(String ticketId, String tag) async {
    try {
      final ticketIndex =
          allTickets.indexWhere((ticket) => ticket['id'] == ticketId);
      if (ticketIndex == -1) return false;

      final ticket = Map<String, dynamic>.from(allTickets[ticketIndex]);
      final tags = List<String>.from(ticket['tags'] as List<dynamic>? ?? []);

      // Add tag if it doesn't already exist
      if (!tags.contains(tag)) {
        tags.add(tag);
        ticket['tags'] = tags;
        ticket['lastUpdated'] = DateTime.now();

        // Update ticket in list
        allTickets[ticketIndex] = ticket;
      }

      return true;
    } catch (e) {
      print('Error adding tag to ticket: $e');
      errorMessage('Failed to add tag to ticket: $e');
      return false;
    }
  }

  Future<bool> removeTagFromTicket(String ticketId, String tag) async {
    try {
      final ticketIndex =
          allTickets.indexWhere((ticket) => ticket['id'] == ticketId);
      if (ticketIndex == -1) return false;

      final ticket = Map<String, dynamic>.from(allTickets[ticketIndex]);
      final tags = List<String>.from(ticket['tags'] as List<dynamic>? ?? []);

      // Remove tag if it exists
      if (tags.contains(tag)) {
        tags.remove(tag);
        ticket['tags'] = tags;
        ticket['lastUpdated'] = DateTime.now();

        // Update ticket in list
        allTickets[ticketIndex] = ticket;
      }

      return true;
    } catch (e) {
      print('Error removing tag from ticket: $e');
      errorMessage('Failed to remove tag from ticket: $e');
      return false;
    }
  }

  Future<bool> addInternalNote(String ticketId, String note) async {
    try {
      final ticketIndex =
          allTickets.indexWhere((ticket) => ticket['id'] == ticketId);
      if (ticketIndex == -1) return false;

      final ticket = Map<String, dynamic>.from(allTickets[ticketIndex]);
      final notes = List<Map<String, dynamic>>.from(
          ticket['internalNotes'] as List<dynamic>? ?? []);

      // Add note
      notes.add({
        'note': note,
        'author': 'Support Agent',
        'timestamp': DateTime.now(),
      });

      // Update ticket
      ticket['internalNotes'] = notes;
      ticket['lastUpdated'] = DateTime.now();

      // Update ticket in list
      allTickets[ticketIndex] = ticket;

      return true;
    } catch (e) {
      print('Error adding internal note: $e');
      errorMessage('Failed to add internal note: $e');
      return false;
    }
  }

  Future<bool> mergeTickets(
      String sourceTicketId, String targetTicketId) async {
    try {
      final sourceIndex =
          allTickets.indexWhere((ticket) => ticket['id'] == sourceTicketId);
      final targetIndex =
          allTickets.indexWhere((ticket) => ticket['id'] == targetTicketId);

      if (sourceIndex == -1 || targetIndex == -1) return false;

      final sourceTicket = allTickets[sourceIndex];
      final targetTicket = Map<String, dynamic>.from(allTickets[targetIndex]);

      // Merge messages
      final sourceMessages = List<Map<String, dynamic>>.from(
          sourceTicket['messages'] as List<dynamic>? ?? []);
      final targetMessages = List<Map<String, dynamic>>.from(
          targetTicket['messages'] as List<dynamic>? ?? []);

      // Add a merge note to the beginning of source messages
      sourceMessages.insert(0, {
        'sender': 'System',
        'content':
            'The following messages were merged from ticket #${sourceTicketId.substring(0, 8)}',
        'timestamp': DateTime.now(),
        'isUser': false,
        'isMergeNote': true,
      });

      // Combine messages (target + source)
      targetMessages.addAll(sourceMessages);
      targetTicket['messages'] = targetMessages;

      // Update target ticket
      targetTicket['lastUpdated'] = DateTime.now();

      // Add a note about the merge
      final notes = List<Map<String, dynamic>>.from(
          targetTicket['internalNotes'] as List<dynamic>? ?? []);
      notes.add({
        'note': 'Merged with ticket #${sourceTicketId.substring(0, 8)}',
        'author': 'Support Agent',
        'timestamp': DateTime.now(),
      });
      targetTicket['internalNotes'] = notes;

      // Update target ticket in list
      allTickets[targetIndex] = targetTicket;

      // Remove source ticket
      allTickets.removeAt(sourceIndex);

      // If the source ticket was selected, select the target ticket instead
      if (selectedTicketId.value == sourceTicketId) {
        selectedTicketId.value = targetTicketId;
      }

      return true;
    } catch (e) {
      print('Error merging tickets: $e');
      errorMessage('Failed to merge tickets: $e');
      return false;
    }
  }

  // Knowledge base methods
  Future<bool> createKnowledgeBaseArticle({
    required String title,
    required String content,
    required String summary,
    required String category,
  }) async {
    try {
      final now = DateTime.now();

      // Create new article
      final article = {
        'id': 'article${knowledgeBaseArticles.length + 1000}',
        'title': title,
        'content': content,
        'summary': summary,
        'category': category,
        'author': 'Admin',
        'createdAt': now,
        'updatedAt': now,
        'views': 0,
        'helpful': 0,
      };

      // Add to list
      knowledgeBaseArticles.add(article);

      return true;
    } catch (e) {
      print('Error creating knowledge base article: $e');
      errorMessage('Failed to create article: $e');
      return false;
    }
  }

  // Helper methods to generate mock data
  String getTicketSubject(String category, int index) {
    switch (category) {
      case 'Account':
        return 'Cannot log in to my account';
      case 'Billing':
        return 'Payment failed for recent purchase';
      case 'Game Play':
        return 'Game freezes during multiplayer match';
      case 'Technical':
        return 'App crashes after the latest update';
      case 'Feature Request':
        return 'Suggestion for new game mode';
      case 'Bug Report':
        return 'Found a bug in the tournament system';
      default:
        return 'Question about the game';
    }
  }

  String getTicketDescription(String category, int index) {
    switch (category) {
      case 'Account':
        return 'I\'m trying to log in to my account but it keeps saying "Invalid credentials" even though I\'m sure my password is correct. I\'ve tried resetting my password but I\'m not receiving the reset email.';
      case 'Billing':
        return 'I tried to purchase 1000 coins yesterday but the payment failed. My card was charged but I didn\'t receive the coins in my account. The transaction ID is TRX${10000 + index}.';
      case 'Game Play':
        return 'Every time I play a multiplayer match, the game freezes after about 2 minutes. I have to force close the app and restart it, which counts as a loss for me. This is really frustrating!';
      case 'Technical':
        return 'Since updating to version 1.5.0, the app crashes immediately after launching. I\'ve tried reinstalling but the problem persists. I\'m using an iPhone 13 with iOS 15.4.';
      case 'Feature Request':
        return 'I think it would be great if you could add a team mode where players can form teams and compete against other teams. This would add a new dimension to the game and encourage more social play.';
      case 'Bug Report':
        return 'I\'ve found a bug in the tournament system. When I join a tournament and then leave, I can rejoin the same tournament multiple times and get matched against myself, which shouldn\'t be possible.';
      default:
        return 'I have a question about the game that isn\'t covered in the FAQ. Can you please provide more information about how the ranking system works?';
    }
  }

  List<String> getTags(String category, int index) {
    switch (category) {
      case 'Account':
        return ['login-issue', 'account-access'];
      case 'Billing':
        return ['payment-failed', 'transaction-issue'];
      case 'Game Play':
        return ['game-freeze', 'multiplayer-issue'];
      case 'Technical':
        return ['app-crash', 'update-issue'];
      case 'Feature Request':
        return ['new-feature', 'enhancement'];
      case 'Bug Report':
        return ['bug', 'tournament-issue'];
      default:
        return ['question', 'game-mechanics'];
    }
  }

  String getArticleTitle(String category, int index) {
    switch (category) {
      case 'Account':
        return 'How to Recover Your Account';
      case 'Billing':
        return 'Troubleshooting Payment Issues';
      case 'Game Play':
        return 'Tips for Winning Multiplayer Matches';
      case 'Technical':
        return 'Fixing App Crashes After Updates';
      case 'Feature Request':
        return 'Upcoming Features in Next Release';
      case 'Bug Report':
        return 'Known Issues and Workarounds';
      default:
        return 'Frequently Asked Questions';
    }
  }

  String getArticleSummary(String category, int index) {
    switch (category) {
      case 'Account':
        return 'Learn how to recover your account if you\'ve forgotten your password or can\'t access your email.';
      case 'Billing':
        return 'Steps to resolve common payment issues and get help with failed transactions.';
      case 'Game Play':
        return 'Expert strategies and tips to improve your skills in multiplayer matches.';
      case 'Technical':
        return 'Solutions for common app crashes and performance issues after updating.';
      case 'Feature Request':
        return 'Preview of exciting new features coming in our next app update.';
      case 'Bug Report':
        return 'List of known issues in the current version and temporary solutions.';
      default:
        return 'Answers to the most common questions about gameplay, accounts, and more.';
    }
  }

  String getArticleContent(String category, int index) {
    switch (category) {
      case 'Account':
        return '''
# How to Recover Your Account

If you're having trouble accessing your account, follow these steps to recover it:

## Password Reset

1. Go to the login screen and tap "Forgot Password"
2. Enter the email address associated with your account
3. Check your email for a password reset link
4. Click the link and follow the instructions to set a new password

## Not Receiving Reset Emails

If you're not receiving password reset emails:

1. Check your spam folder
2. Make sure you're using the correct email address
3. Add our domain to your safe senders list
4. Contact support if you still don't receive the email

## Account Locked

If your account is locked due to too many failed login attempts:

1. Wait 30 minutes before trying again
2. Use the password reset function to set a new password
3. Make sure you're not using a VPN that might trigger security measures

## Still Can't Access Your Account?

If you've tried the steps above and still can't access your account, please contact our support team with the following information:

1. Username or display name
2. Email address associated with the account
3. Approximate date when you created the account
4. Any transaction IDs from purchases you've made
''';
      case 'Billing':
        return '''
# Troubleshooting Payment Issues

Common payment problems and how to solve them:

## Failed Payments

If your payment fails, check the following:

1. Verify that your card details are entered correctly
2. Ensure you have sufficient funds in your account
3. Check if your bank is blocking the transaction
4. Try a different payment method

## Charged But No Items Received

If you were charged but didn't receive your purchase:

1. Wait 15 minutes as sometimes there's a delay in processing
2. Check your in-game mail for the items
3. Restart the app to refresh your inventory
4. Contact support with your transaction ID and purchase receipt

## Subscription Issues

For problems with recurring subscriptions:

1. Check your subscription status in your account settings
2. Verify your payment method is up to date
3. Cancel and resubscribe if needed
4. Contact support for assistance with specific subscription issues

## Refunds

Our refund policy:

1. Accidental purchases may be eligible for a refund if requested within 48 hours
2. Subscription cancellations do not automatically trigger refunds for unused time
3. To request a refund, contact support with your transaction ID and reason for the refund
''';
      case 'Game Play':
        return '''
# Tips for Winning Multiplayer Matches

Improve your skills and increase your win rate with these expert tips:

## Basic Strategies

1. Focus on controlling the center of the board
2. Don't make moves reactively - plan ahead
3. Watch your opponent's patterns and adapt your strategy
4. Save power-ups for critical moments rather than using them immediately

## Advanced Techniques

1. Use the "corner trap" technique to force your opponent into making mistakes
2. Practice the "double threat" move to create two winning opportunities
3. Learn to recognize and counter common opening strategies
4. Develop a flexible playstyle that can adapt to different opponents

## Managing Your Resources

1. Use coins efficiently to upgrade your most-used items
2. Focus on upgrading a core set of items rather than spreading resources too thin
3. Save premium currency for limited-time special items
4. Complete daily missions to maximize resource acquisition

## Tournament Play

1. Rest between matches to maintain focus
2. Study the meta and popular strategies before participating
3. Practice against friends in friendly matches to prepare
4. Keep track of top players and learn from their techniques
''';
      default:
        return '''
# ${getArticleTitle(category, index)}

This is a comprehensive guide about ${category.toLowerCase()}-related issues and solutions.

## Common Problems

Users often encounter these issues:

1. Problem one description and details
2. Problem two with more specific information
3. Third common issue that users face

## Solutions

Here are the recommended solutions:

1. Step-by-step guidance for first problem
2. Detailed instructions for solving the second issue
3. Multiple approaches for addressing the third problem

## Prevention

To avoid these issues in the future:

1. Preventative measure one
2. Second tip for avoiding problems
3. Best practices for optimal experience

## Contact Support

If you're still experiencing issues after trying these solutions, please contact our support team with the following information:

1. Your device model and operating system
2. App version
3. Detailed description of the issue
4. Screenshots if applicable
''';
    }
  }
}

```

---


### middlewares\admin_middleware.dart

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';

class AdminMiddleware extends GetMiddleware {
  @override
  int? get priority => 2;

  // Cache để lưu trữ quyền truy cập admin để tránh truy vấn lặp lại
  static final Map<String, bool> _adminAccessCache = {};
  static DateTime _lastCacheClear = DateTime.now();

  @override
  RouteSettings? redirect(String? route) {
    // Kiểm tra quyền truy cập admin - sử dụng FutureBuilder trong UI thay vì async ở đây
    _checkAdminAccess().then((hasAccess) {
      if (!hasAccess) {
        // Hiển thị thông báo lỗi
        errorMessage('Bạn không có quyền truy cập vào trang quản trị');

        // Chuyển hướng về trang chính
        Get.offAllNamed('/mainHome');
      }
    }).catchError((error) {
      errorMessage('Lỗi khi kiểm tra quyền truy cập: $error');
      Get.offAllNamed('/mainHome');
    });

    // Trả về null để ngăn chặn chuyển hướng nếu người dùng đã có quyền truy cập
    // Chúng ta sẽ thực hiện chuyển hướng thủ công trong hàm _checkAdminAccess nếu cần
    return null;
  }

  Future<bool> _checkAdminAccess() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      // Kiểm tra cache để tránh truy vấn quá nhiều vào Firestore
      final userId = user.uid;

      // Xóa cache mỗi 15 phút để cập nhật quyền
      _clearCacheIfNeeded();

      // Nếu đã có trong cache, trả về kết quả
      if (_adminAccessCache.containsKey(userId)) {
        return _adminAccessCache[userId]!;
      }

      // Truy vấn Firestore để lấy thông tin người dùng
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) return false;

      final userData = userDoc.data() as Map<String, dynamic>;
      final isAdmin = userData['role'] == 'admin';

      // Lưu kết quả vào cache
      _adminAccessCache[userId] = isAdmin;

      return isAdmin;
    } catch (e) {
      print('Error checking admin access: $e');
      return false;
    }
  }

  // Xóa cache mỗi 15 phút để cập nhật quyền
  void _clearCacheIfNeeded() {
    final now = DateTime.now();
    if (now.difference(_lastCacheClear).inMinutes >= 15) {
      _adminAccessCache.clear();
      _lastCacheClear = now;
    }
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    if (page != null) {
      _logAccess(page.name);
    }
    return page;
  }

  // Ghi log khi có người truy cập trang admin
  void _logAccess(String route) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        FirebaseFirestore.instance.collection('admin_access_logs').add({
          'userId': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'route': route,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        // Chỉ ghi log, không ảnh hưởng đến luồng chính
        print('Error logging admin access: $e');
      }
    }
  }
}

```

---


### models\user_model.dart

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? id;
  String? name;
  String? email;
  String? image;
  String? totalWins;
  String? role;
  String? totalCoins;
  String? quickMess;
  String? quickEmote;
  List<String>? friendsList;
  String? status;
  Timestamp? lastActive;
  GeoPoint? location;
  List<String>? avatarFrame;
  bool? suspended;
  bool? verified;
  String? bio;
  Timestamp? createdAt;
  bool? isOnline;
  int? warningCount;

  UserModel({
    this.role,
    this.id,
    this.name,
    this.email,
    this.image,
    this.totalWins,
    this.totalCoins,
    this.quickMess,
    this.quickEmote,
    this.friendsList,
    this.status,
    this.lastActive,
    this.location,
    this.avatarFrame,
    this.suspended,
    this.verified,
    this.bio,
    this.createdAt,
    this.isOnline,
    this.warningCount,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    if (json["id"] is String) {
      id = json["id"];
    }
    if (json["name"] is String) {
      name = json["name"];
    }
    if (json["email"] is String) {
      email = json["email"];
    }
    if (json["image"] is String) {
      image = json["image"];
    }
    if (json["totalWins"] is String) {
      totalWins = json["totalWins"];
    }
    if (json["role"] is String) {
      role = json["role"];
    }
    if (json["totalCoins"] is String) {
      totalCoins = json["totalCoins"];
    }
    if (json["quickMess"] is String) {
      quickMess = json["quickMess"];
    }
    if (json["quickEmote"] is String) {
      quickEmote = json["quickEmote"];
    }
    if (json["friendsList"] is List) {
      friendsList = List<String>.from(json["friendsList"]);
    }
    if (json["status"] is String) {
      status = json["status"];
    }
    if (json["lastActive"] is Timestamp) {
      lastActive = json["lastActive"];
    }
    location = json["location"] as GeoPoint?;
    if (json["avatarFrame"] is List) {
      avatarFrame = List<String>.from(json["avatarFrame"]);
    }
    if (json["suspended"] is bool) {
      suspended = json["suspended"];
    }
    if (json["verified"] is bool) {
      verified = json["verified"];
    }
    if (json["bio"] is String) {
      bio = json["bio"];
    }
    if (json["createdAt"] is Timestamp) {
      createdAt = json["createdAt"];
    }
    if (json["isOnline"] is bool) {
      isOnline = json["isOnline"];
    }
    if (json["warningCount"] is int) {
      warningCount = json["warningCount"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["name"] = name;
    data["email"] = email;
    data["image"] = image;
    data["totalWins"] = totalWins;
    data["role"] = role;
    data["totalCoins"] = totalCoins;
    data["quickMess"] = quickMess;
    data["quickEmote"] = quickEmote;
    data["friendsList"] = friendsList;
    data["status"] = status;
    data["lastActive"] = lastActive;
    data["location"] = location;
    data["avatarFrame"] = avatarFrame;
    data["suspended"] = suspended;
    data["verified"] = verified;
    data["bio"] = bio;
    data["createdAt"] = createdAt;
    data["isOnline"] = isOnline;
    data["warningCount"] = warningCount;
    return data;
  }

  // Add the copyWith method to fix the 'copyWith' isn't defined for the type 'UserModel' error
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? image,
    String? totalWins,
    String? role,
    String? totalCoins,
    String? quickMess,
    String? quickEmote,
    List<String>? friendsList,
    String? status,
    Timestamp? lastActive,
    GeoPoint? location,
    List<String>? avatarFrame,
    bool? suspended,
    bool? verified,
    String? bio,
    Timestamp? createdAt,
    bool? isOnline,
    int? warningCount,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      image: image ?? this.image,
      totalWins: totalWins ?? this.totalWins,
      role: role ?? this.role,
      totalCoins: totalCoins ?? this.totalCoins,
      quickMess: quickMess ?? this.quickMess,
      quickEmote: quickEmote ?? this.quickEmote,
      friendsList: friendsList ?? this.friendsList,
      status: status ?? this.status,
      lastActive: lastActive ?? this.lastActive,
      location: location ?? this.location,
      avatarFrame: avatarFrame ?? this.avatarFrame,
      suspended: suspended ?? this.suspended,
      verified: verified ?? this.verified,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      isOnline: isOnline ?? this.isOnline,
      warningCount: warningCount ?? this.warningCount,
    );
  }
}

```

---


### Pages\admin_home_page.dart

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Pages/Admin/Pages/dashboard_overview.dart';
import 'package:tictactoe_gameapp/Pages/Admin/Pages/tabs/user_support_system_tab.dart';
import 'package:tictactoe_gameapp/Pages/Splace/splace_page.dart';
import 'package:tictactoe_gameapp/Pages/Admin/controllers/admin_controller.dart';
import 'package:tictactoe_gameapp/Pages/Admin/Pages/tabs/user_management_tab.dart';
import 'package:tictactoe_gameapp/Pages/Admin/Pages/tabs/content_moderation_tab.dart';
import 'package:tictactoe_gameapp/Pages/Admin/Pages/tabs/analytics_tab.dart';
import 'package:tictactoe_gameapp/Pages/Admin/Pages/tabs/announcements_tab.dart';
import 'package:tictactoe_gameapp/Pages/Admin/Pages/tabs/game_management_tab.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  late AdminController controller;
  final RxInt currentTabIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    // Make sure the controller is injected
    controller = Get.put(AdminController());

    // Listen to tab changes and update our reactive variable
    controller.tabController.addListener(() {
      if (controller.tabController.indexIsChanging) {
        currentTabIndex.value = controller.tabController.index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.deepPurpleAccent,
        bottom: TabBar(
          controller: controller.tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(
              icon: Icon(Icons.people),
              text: 'Users',
            ),
            Tab(
              icon: Icon(Icons.report),
              text: 'Moderation',
            ),
            Tab(
              icon: Icon(Icons.analytics),
              text: 'Analytics',
            ),
            Tab(
              icon: Icon(Icons.announcement),
              text: 'Announcements',
            ),
            Tab(
              icon: Icon(Icons.games),
              text: 'Games',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Get.toNamed('/admin/settings');
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
            onPressed: () {
              _showHelpDialog(context);
            },
          ),
        ],
      ),
      drawer: _buildAdminDrawer(context),
      body: TabBarView(
        controller: controller.tabController,
        children: const [
          UserManagementTab(),
          ContentModerationTab(),
          AnalyticsTab(),
          AnnouncementsTab(),
          GameManagementTab(),
        ],
      ),
      floatingActionButton: Obx(() {
        // Show different FAB based on the current tab
        // Now using our reactive variable
        switch (currentTabIndex.value) {
          case 0: // Users tab
            return FloatingActionButton(
              onPressed: () => _showAddUserDialog(context),
              backgroundColor: Colors.deepPurpleAccent,
              child: const Icon(Icons.person_add),
            );
          case 1: // Moderation tab
            return FloatingActionButton(
              onPressed: () => controller.fetchReportedContent(refresh: true),
              backgroundColor: Colors.deepPurpleAccent,
              child: const Icon(Icons.refresh),
            );
          case 3: // Announcements tab
            return FloatingActionButton(
              onPressed: () => _showCreateAnnouncementDialog(),
              backgroundColor: Colors.deepPurpleAccent,
              child: const Icon(Icons.add),
            );
          default:
            return const SizedBox.shrink(); // No FAB for other tabs
        }
      }),
    );
  }

  Widget _buildAdminDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.deepPurpleAccent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 30,
                    color: Colors.deepPurpleAccent,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                FutureBuilder<bool>(
                  future: controller.checkAdminAccess(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data == true) {
                      return const Text(
                        'You have full access',
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      );
                    }
                    return const Text(
                      'Loading permissions...',
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Get.to(() => const DashboardOverviewPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Support System'),
            onTap: () {
              Get.to(() => const SupportSystemPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('Content Moderation'),
            onTap: () {
              Get.back();
              controller.tabController.animateTo(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Analytics'),
            onTap: () {
              Get.back();
              controller.tabController.animateTo(2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.announcement),
            title: const Text('Announcements'),
            onTap: () {
              Get.back();
              controller.tabController.animateTo(3);
            },
          ),
          ListTile(
            leading: const Icon(Icons.games),
            title: const Text('Game Management'),
            onTap: () {
              Get.back();
              controller.tabController.animateTo(4);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Admin Settings'),
            onTap: () {
              Get.back();
              Get.toNamed('/admin/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Documentation'),
            onTap: () {
              Get.back();
              _showHelpDialog(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Back to App'),
            onTap: () {
              Get.to(const SplacePage());
            },
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Admin Dashboard Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Welcome to the Admin Dashboard!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                  'This dashboard allows you to manage all aspects of your app:'),
              SizedBox(height: 8),
              Text(
                  '• User Management: Manage user accounts, roles, and permissions'),
              Text(
                  '• Content Moderation: Review and moderate reported content'),
              Text('• Analytics: View app usage statistics and reports'),
              Text('• Announcements: Create and manage system announcements'),
              Text(
                  '• Game Management: Configure game settings and leaderboards'),
              SizedBox(height: 16),
              Text(
                'Need more help?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Contact the development team at support@example.com'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    // Show dialog to add a new user
    // This would be implemented in a real application
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New User'),
        content: const Text(
          'This feature would allow you to manually add a new user to the system. In a real application, this would include a form for user details.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  void _showCreateAnnouncementDialog() {
    // This is a helper method to show the announcement creation dialog
    // In a real implementation, we'd call a method in the AnnouncementsTab
    // or implement the dialog here
    Get.dialog(
      AlertDialog(
        title: const Text('Create Announcement'),
        content: const Text('Announcement creation form would go here'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              // Create announcement logic
              Get.back();
            },
            child: const Text('CREATE'),
          ),
        ],
      ),
    );
  }
}

```

---


### Pages\admin_setting_page.dart

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Pages/Admin/services/admin_service.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final AdminService _adminService = AdminService();
  bool _maintenance = false;
  bool _enableRealTimeReports = true;
  bool _enableBackupDaily = true;
  bool _notifyAdminsOnReport = true;
  int _autoDeleteReportsAfterDays = 30;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _adminService.getAdminSettings();
      setState(() {
        _maintenance = settings['maintenanceMode'] ?? false;
        _enableRealTimeReports = settings['enableRealTimeReports'] ?? true;
        _enableBackupDaily = settings['enableBackupDaily'] ?? true;
        _notifyAdminsOnReport = settings['notifyAdminsOnReport'] ?? true;
        _autoDeleteReportsAfterDays =
            settings['autoDeleteReportsAfterDays'] ?? 30;
      });
    } catch (e) {
      errorMessage('Không thể tải cài đặt: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      await _adminService.updateAdminSettings({
        'maintenanceMode': _maintenance,
        'enableRealTimeReports': _enableRealTimeReports,
        'enableBackupDaily': _enableBackupDaily,
        'notifyAdminsOnReport': _notifyAdminsOnReport,
        'autoDeleteReportsAfterDays': _autoDeleteReportsAfterDays,
      });

      successMessage('Cài đặt đã được lưu');
    } catch (e) {
      errorMessage('Lỗi khi lưu cài đặt: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài Đặt Quản Trị'),
        backgroundColor: Colors.deepPurpleAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Lưu cài đặt',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGeneralSettings(),
            const SizedBox(height: 24),
            _buildReportSettings(),
            const SizedBox(height: 24),
            _buildBackupSettings(),
            const SizedBox(height: 24),
            _buildDangerZone(),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cài đặt chung',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Chế độ bảo trì'),
              subtitle: const Text(
                'Khi bật, người dùng không thể truy cập ứng dụng ngoại trừ admin',
              ),
              value: _maintenance,
              onChanged: (value) {
                setState(() {
                  _maintenance = value;
                });
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Phiên bản ứng dụng'),
              subtitle: const Text('1.0.0'),
              trailing: ElevatedButton(
                onPressed: () => _showForceUpdateDialog(),
                child: const Text('Cập nhật'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportSettings() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cài đặt báo cáo & kiểm duyệt',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Báo cáo thời gian thực'),
              subtitle: const Text(
                'Nhận thông báo khi có báo cáo mới từ người dùng',
              ),
              value: _enableRealTimeReports,
              onChanged: (value) {
                setState(() {
                  _enableRealTimeReports = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Thông báo cho admin'),
              subtitle: const Text(
                'Gửi email cho tất cả admin khi có báo cáo mới',
              ),
              value: _notifyAdminsOnReport,
              onChanged: (value) {
                setState(() {
                  _notifyAdminsOnReport = value;
                });
              },
            ),
            ListTile(
              title: const Text('Tự động xóa báo cáo cũ sau'),
              subtitle: Slider(
                min: 7,
                max: 90,
                divisions: 11,
                value: _autoDeleteReportsAfterDays.toDouble(),
                label: '$_autoDeleteReportsAfterDays ngày',
                onChanged: (value) {
                  setState(() {
                    _autoDeleteReportsAfterDays = value.round();
                  });
                },
              ),
              trailing: Text(
                '$_autoDeleteReportsAfterDays ngày',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupSettings() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cài đặt sao lưu & khôi phục',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Tự động sao lưu hàng ngày'),
              subtitle: const Text(
                'Tạo bản sao lưu dữ liệu tự động mỗi ngày',
              ),
              value: _enableBackupDaily,
              onChanged: (value) {
                setState(() {
                  _enableBackupDaily = value;
                });
              },
            ),
            ListTile(
              title: const Text('Sao lưu thủ công'),
              subtitle: const Text('Tạo bản sao lưu ngay bây giờ'),
              trailing: ElevatedButton.icon(
                onPressed: () => _createBackup(),
                icon: const Icon(Icons.backup),
                label: const Text('Sao lưu'),
              ),
            ),
            ListTile(
              title: const Text('Khôi phục dữ liệu'),
              subtitle: const Text('Khôi phục từ bản sao lưu đã chọn'),
              trailing: ElevatedButton.icon(
                onPressed: () => _showRestoreDialog(),
                icon: const Icon(Icons.restore),
                label: const Text('Khôi phục'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZone() {
    return Card(
      elevation: 2,
      color: Colors.red.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.red, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vùng nguy hiểm',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Xóa tất cả báo cáo'),
              subtitle: const Text(
                'Xóa tất cả báo cáo nội dung từ người dùng',
              ),
              trailing: ElevatedButton(
                onPressed: () => _showDeleteAllReportsDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Xóa tất cả'),
              ),
            ),
            ListTile(
              title: const Text('Đặt lại cài đặt mặc định'),
              subtitle: const Text(
                'Khôi phục tất cả cài đặt quản trị về mặc định',
              ),
              trailing: ElevatedButton(
                onPressed: () => _showResetSettingsDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Đặt lại'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showForceUpdateDialog() {
    final versionController = TextEditingController(text: '1.0.1');
    final messageController = TextEditingController(
      text:
          'Chúng tôi đã cập nhật tính năng mới và sửa một số lỗi. Vui lòng cập nhật để có trải nghiệm tốt nhất.',
    );
    bool forceUpdate = true;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Thông báo cập nhật ứng dụng'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: versionController,
                  decoration: const InputDecoration(
                    labelText: 'Phiên bản mới',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: 'Thông báo cập nhật',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Bắt buộc cập nhật'),
                  subtitle: const Text(
                    'Người dùng phải cập nhật để tiếp tục sử dụng ứng dụng',
                  ),
                  value: forceUpdate,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setState(() {
                      forceUpdate = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('HỦY'),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement update notification logic
                Get.back();
                successMessage('Đã gửi thông báo cập nhật cho người dùng');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
              ),
              child: const Text('GỬI THÔNG BÁO'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createBackup() async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      // Simulate backup creation
      await Future.delayed(const Duration(seconds: 2));

      Get.back();
      successMessage('Đã tạo bản sao lưu thành công');
    } catch (e) {
      Get.back();
      errorMessage('Lỗi khi tạo bản sao lưu: $e');
    }
  }

  void _showRestoreDialog() {
    // Mock backup data
    final backups = [
      {'date': '23/03/2025', 'size': '124 MB', 'id': 'backup1'},
      {'date': '22/03/2025', 'size': '123 MB', 'id': 'backup2'},
      {'date': '21/03/2025', 'size': '122 MB', 'id': 'backup3'},
    ];

    String? selectedBackupId;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Khôi phục dữ liệu'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chọn bản sao lưu để khôi phục:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cảnh báo: Khôi phục sẽ ghi đè lên dữ liệu hiện tại. Quá trình này không thể hoàn tác.',
                  style: TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: backups.length,
                    itemBuilder: (context, index) {
                      final backup = backups[index];
                      final isSelected = backup['id'] == selectedBackupId;

                      return RadioListTile<String>(
                        title: Text('Sao lưu ngày ${backup['date']}'),
                        subtitle: Text('Kích thước: ${backup['size']}'),
                        value: backup['id'] as String,
                        groupValue: selectedBackupId,
                        onChanged: (value) {
                          setState(() {
                            selectedBackupId = value;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('HỦY'),
            ),
            ElevatedButton(
              onPressed: selectedBackupId != null
                  ? () {
                      Get.back();
                      _confirmRestore(selectedBackupId!);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
              ),
              child: const Text('KHÔI PHỤC'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRestore(String backupId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Xác nhận khôi phục'),
        content: const Text(
          'Bạn có chắc chắn muốn khôi phục dữ liệu từ bản sao lưu này? Dữ liệu hiện tại sẽ bị mất.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('HỦY'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();

              Get.dialog(
                const Center(
                  child: CircularProgressIndicator(),
                ),
                barrierDismissible: false,
              );

              // Simulate restore process
              await Future.delayed(const Duration(seconds: 3));

              Get.back();
              successMessage('Khôi phục dữ liệu thành công');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('XÁC NHẬN'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllReportsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Xóa tất cả báo cáo'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa tất cả báo cáo? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('HỦY'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();

              Get.dialog(
                const Center(
                  child: CircularProgressIndicator(),
                ),
                barrierDismissible: false,
              );

              // Simulate deletion process
              await Future.delayed(const Duration(seconds: 2));

              Get.back();
              successMessage('Đã xóa tất cả báo cáo thành công');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('XÓA TẤT CẢ'),
          ),
        ],
      ),
    );
  }

  void _showResetSettingsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Đặt lại cài đặt'),
        content: const Text(
          'Bạn có chắc chắn muốn đặt lại tất cả cài đặt quản trị về mặc định?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('HỦY'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();

              setState(() {
                _maintenance = false;
                _enableRealTimeReports = true;
                _enableBackupDaily = true;
                _notifyAdminsOnReport = true;
                _autoDeleteReportsAfterDays = 30;
              });

              await _saveSettings();
              successMessage('Đã đặt lại cài đặt thành công');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('ĐẶT LẠI'),
          ),
        ],
      ),
    );
  }
}

```

---


### Pages\dashboard_overview.dart

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:tictactoe_gameapp/Pages/Admin/controllers/admin_controller.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Pages/Admin/controllers/dashboard_overview_controller.dart';
import 'package:tictactoe_gameapp/Pages/Admin/models/user_model.dart';

class DashboardOverviewPage extends StatelessWidget {
  const DashboardOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Make sure controllers are injected
    Get.find<AdminController>();
    final dashboardController = Get.put(DashboardController());

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => dashboardController.refreshAllData(),
        child: Obx(() {
          if (dashboardController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBreadcrumbs(),
                const SizedBox(height: 16),
                _buildStatsSummary(dashboardController),
                const SizedBox(height: 24),
                _buildUserActivityChart(dashboardController),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildRecentReports(dashboardController),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: _buildActiveAnnouncements(dashboardController),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTopUsers(dashboardController),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTopGames(dashboardController),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSystemHealth(dashboardController),
              ],
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickActionsMenu(context, dashboardController),
        backgroundColor: Colors.deepPurpleAccent,
        child: const Icon(Icons.bolt),
        tooltip: 'Quick Actions',
      ),
    );
  }

  Widget _buildBreadcrumbs() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.dashboard, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          const Text(
            'Dashboard',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          const Text(
            'Overview',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 14,
                ),
                SizedBox(width: 4),
                Text(
                  'All Systems Operational',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(DashboardController controller) {
    final stats = controller.summaryStats.value;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Dashboard Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => controller.refreshAllData(),
              icon: const Icon(Icons.refresh),
              label: Text('Last updated: ${_getFormattedTime()}'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStatCard(
              title: 'Total Users',
              value: '${stats['totalUsers'] ?? 0}',
              change: '+${stats['newUsers'] ?? 0} today',
              isPositive: true,
              icon: Icons.people,
              color: Colors.blue,
              onTap: () => Get.find<AdminController>().tabController.animateTo(0),
            ),
            _buildStatCard(
              title: 'Pending Reports',
              value: '${stats['pendingReports'] ?? 0}',
              change: '${stats['criticalReports'] ?? 0} critical',
              isPositive: false,
              icon: Icons.report_problem,
              color: Colors.orange,
              onTap: () => Get.find<AdminController>().tabController.animateTo(1),
            ),
            _buildStatCard(
              title: 'Active Games',
              value: '${stats['activeGames'] ?? 0}',
              change: '+${stats['newGames'] ?? 0} today',
              isPositive: true,
              icon: Icons.sports_esports,
              color: Colors.purple,
              onTap: () => Get.find<AdminController>().tabController.animateTo(4),
            ),
            _buildStatCard(
              title: 'Revenue',
              value: '\$${stats['revenue'] ?? 0}',
              change: '${stats['revenueChange'] ?? 0}% vs last week',
              isPositive: (stats['revenueChange'] ?? 0) >= 0,
              icon: Icons.attach_money,
              color: Colors.green,
              onTap: () => _showRevenueDetails(controller),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isPositive ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  change,
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserActivityChart(DashboardController controller) {
    final userActivityData = controller.userActivityData;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'User Activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButton<String>(
                value: controller.activityTimeRange.value,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: 'day', child: Text('Today')),
                  DropdownMenuItem(value: 'week', child: Text('This Week')),
                  DropdownMenuItem(value: 'month', child: Text('This Month')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    controller.activityTimeRange.value = value;
                    controller.loadUserActivityData(timeRange: value);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < userActivityData.length) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              userActivityData[index]['label'] as String,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
                    left: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  ),
                ),
                minX: 0,
                maxX: userActivityData.length - 1.0,
                minY: 0,
                maxY: controller.maxUserActivity.value.toDouble(),
                lineBarsData: [
                  // Active Users
                  LineChartBarData(
                    spots: List.generate(userActivityData.length, (index) {
                      return FlSpot(
                        index.toDouble(),
                        (userActivityData[index]['activeUsers'] as int).toDouble(),
                      );
                    }),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.1),
                    ),
                  ),
                  // New Users
                  LineChartBarData(
                    spots: List.generate(userActivityData.length, (index) {
                      return FlSpot(
                        index.toDouble(),
                        (userActivityData[index]['newUsers'] as int).toDouble(),
                      );
                    }),
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.green.withOpacity(0.1),
                    ),
                  ),
                  // Game Sessions
                  LineChartBarData(
                    spots: List.generate(userActivityData.length, (index) {
                      return FlSpot(
                        index.toDouble(),
                        (userActivityData[index]['gameSessions'] as int).toDouble(),
                      );
                    }),
                    isCurved: true,
                    color: Colors.purple,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.purple.withOpacity(0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                  
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        final index = touchedSpot.x.toInt();
                        final dataPoint = userActivityData[index];
                        final String dataLabel = dataPoint['label'] as String;
                        
                        String title;
                        String value;
                        
                        if (touchedSpot.barIndex == 0) {
                          title = 'Active Users';
                          value = dataPoint['activeUsers'].toString();
                        } else if (touchedSpot.barIndex == 1) {
                          title = 'New Users';
                          value = dataPoint['newUsers'].toString();
                        } else {
                          title = 'Game Sessions';
                          value = dataPoint['gameSessions'].toString();
                        }
                        
                        return LineTooltipItem(
                          '$dataLabel\n$title: $value',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Active Users', Colors.blue),
              const SizedBox(width: 16),
              _buildLegendItem('New Registrations', Colors.green),
              const SizedBox(width: 16),
              _buildLegendItem('Game Sessions', Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentReports(DashboardController controller) {
    final reports = controller.recentReports;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Reports',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Get.find<AdminController>().tabController.animateTo(1),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reports.length > 5 ? 5 : reports.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final report = reports[index];
              final contentType = report['contentType'] as String? ?? '';
              final reportReason = report['reason'] as String? ?? 'Not specified';
              final reportedAt = report['reportedAt'] as DateTime? ?? DateTime.now();
              final reporterName = report['reporter']['name'] as String? ?? 'Unknown';
              
              IconData iconData;
              Color iconColor;
              
              switch (contentType) {
                case 'post':
                  iconData = Icons.article;
                  iconColor = Colors.blue;
                  break;
                case 'comment':
                  iconData = Icons.comment;
                  iconColor = Colors.green;
                  break;
                case 'user':
                  iconData = Icons.person;
                  iconColor = Colors.orange;
                  break;
                default:
                  iconData = Icons.report_problem;
                  iconColor = Colors.red;
              }
              
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    iconData,
                    color: iconColor,
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      'Reported ${contentType.capitalizeFirst}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'New',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reason: $reportReason',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'By $reporterName • ${_timeAgo(reportedAt)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _showReportDetails(report),
                ),
                onTap: () => _showReportDetails(report),
              );
            },
          ),
          if (reports.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No recent reports',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveAnnouncements(DashboardController controller) {
    final announcements = controller.activeAnnouncements;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Announcements',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Get.find<AdminController>().tabController.animateTo(3),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: announcements.length > 3 ? 3 : announcements.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              final title = announcement['title'] as String? ?? 'No title';
              final type = announcement['type'] as String? ?? 'system';
              final startDate = announcement['startDate'] as DateTime? ?? DateTime.now();
              final endDate = announcement['endDate'] as DateTime?;
              
              IconData iconData;
              Color iconColor;
              
              switch (type) {
                case 'system':
                  iconData = Icons.announcement;
                  iconColor = Colors.blue;
                  break;
                case 'maintenance':
                  iconData = Icons.build;
                  iconColor = Colors.orange;
                  break;
                case 'event':
                  iconData = Icons.event;
                  iconColor = Colors.green;
                  break;
                default:
                  iconData = Icons.info;
                  iconColor = Colors.grey;
              }
              
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    iconData,
                    color: iconColor,
                  ),
                ),
                title: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  endDate != null
                      ? 'Active until ${DateFormat('MMM dd').format(endDate)}'
                      : 'Started on ${DateFormat('MMM dd').format(startDate)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _showAnnouncementDetails(announcement),
                ),
                onTap: () => _showAnnouncementDetails(announcement),
              );
            },
          ),
          if (announcements.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No active announcements',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCreateAnnouncementDialog(),
              icon: const Icon(Icons.add),
              label: const Text('New Announcement'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopUsers(DashboardController controller) {
    final users = controller.topUsers;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Users',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButton<String>(
                value: controller.userSortCriteria.value,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: 'coins', child: Text('By Coins')),
                  DropdownMenuItem(value: 'wins', child: Text('By Wins')),
                  DropdownMenuItem(value: 'activity', child: Text('By Activity')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    controller.userSortCriteria.value = value;
                    controller.loadTopUsers(sortBy: value);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: users.length > 5 ? 5 : users.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: Stack(
                  children: [
                    AvatarUserWidget(
                      radius: 20,
                      imagePath: user.image ?? '',
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getRankColor(index),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                title: Text(
                  user.name ?? 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  controller.userSortCriteria.value == 'coins'
                      ? '${user.totalCoins ?? "0"} coins'
                      : controller.userSortCriteria.value == 'wins'
                          ? '${user.totalWins ?? "0"} wins'
                          : 'Last active: ${_timeAgo(user.lastActive?.toDate() ?? DateTime.now())}',
                ),
                trailing: Chip(
                  label: Text(user.role ?? 'user'),
                  backgroundColor: _getRoleColor(user.role),
                  labelStyle: const TextStyle(color: Colors.white, fontSize: 10),
                  padding: EdgeInsets.zero,
                ),
                onTap: () => _showUserDetails(user),
              );
            },
          ),
          if (users.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No user data available',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () => Get.find<AdminController>().tabController.animateTo(0),
              child: const Text('View All Users'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopGames(DashboardController controller) {
    final games = controller.topGames;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Games',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButton<String>(
                value: controller.gameSortCriteria.value,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: 'plays', child: Text('By Plays')),
                  DropdownMenuItem(value: 'active', child: Text('By Active Users')),
                  DropdownMenuItem(value: 'revenue', child: Text('By Revenue')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    controller.gameSortCriteria.value = value;
                    controller.loadTopGames(sortBy: value);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: games.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final game = games[index];
              final gameId = game['id'] as String;
              final gameName = game['name'] as String;
              final gameImage = game['image'] as String?;
              final value = game[controller.gameSortCriteria.value] as int? ?? 0;
              final growth = game['growth'] as int? ?? 0;
              final isPositive = growth >= 0;
              
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getGameColor(gameId).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: gameImage != null && gameImage.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            gameImage,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.sports_esports,
                          color: _getGameColor(gameId),
                        ),
                ),
                title: Text(
                  gameName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Row(
                  children: [
                    Text(
                      controller.gameSortCriteria.value == 'plays'
                          ? '$value plays'
                          : controller.gameSortCriteria.value == 'active'
                              ? '$value active users'
                              : '\$value revenue',
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isPositive ? Colors.green : Colors.red,
                      size: 12,
                    ),
                    Text(
                      '$growth%',
                      style: TextStyle(
                        color: isPositive ? Colors.green : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _showGameDetails(game),
                ),
                onTap: () => _showGameDetails(game),
              );
            },
          ),
          if (games.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No game data available',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () => Get.find<AdminController>().tabController.animateTo(4),
              child: const Text('View All Games'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemHealth(DashboardController controller) {
    final systemHealth = controller.systemHealth.value;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'System Health',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => controller.loadSystemHealth(),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildHealthCard(
                  title: 'API',
                  status: systemHealth['apiStatus'] ?? 'unknown',
                  value: '${systemHealth['apiResponseTime'] ?? 0} ms',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildHealthCard(
                  title: 'Database',
                  status: systemHealth['dbStatus'] ?? 'unknown',
                  value: '${systemHealth['dbConnections'] ?? 0} connections',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildHealthCard(
                  title: 'Storage',
                  status: systemHealth['storageStatus'] ?? 'unknown',
                  value: '${systemHealth['storageUsage'] ?? 0}% used',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildHealthCard(
                  title: 'Caching',
                  status: systemHealth['cacheStatus'] ?? 'unknown',
                  value: '${systemHealth['cacheHitRate'] ?? 0}% hit rate',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Recent System Logs',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 120,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: ListView.builder(
              itemCount: controller.systemLogs.length,
              itemBuilder: (context, index) {
                final log = controller.systemLogs[index];
                final level = log['level'] as String? ?? 'info';
                final message = log['message'] as String? ?? '';
                final timestamp = log['timestamp'] as DateTime? ?? DateTime.now();
                
                Color levelColor;
                switch (level.toLowerCase()) {
                  case 'error':
                    levelColor = Colors.red;
                    break;
                  case 'warning':
                    levelColor = Colors.orange;
                    break;
                  case 'info':
                    levelColor = Colors.blue;
                    break;
                  default:
                    levelColor = Colors.grey;
                }
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '[${level.toUpperCase()}]',
                        style: TextStyle(
                          color: levelColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('HH:mm:ss').format(timestamp),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          message,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showSystemLogs(),
                icon: const Icon(Icons.list_alt),
                label: const Text('View All Logs'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showMaintenanceDialog(),
                icon: const Icon(Icons.settings),
                label: const Text('Maintenance Settings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthCard({
    required String title,
    required String status,
    required String value,
  }) {
    Color statusColor;
    IconData statusIcon;
    
    switch (status.toLowerCase()) {
      case 'good':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'warning':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      case 'error':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                statusIcon,
                color: statusColor,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: statusColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getFormattedTime() {
    return DateFormat('MMM dd, HH:mm').format(DateTime.now());
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 0:
        return Colors.amber; // Gold
      case 1:
        return Colors.grey.shade400; // Silver
      case 2:
        return Colors.brown.shade300; // Bronze
      default:
        return Colors.grey.shade800; // Regular
    }
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'moderator':
        return Colors.green;
      case 'user':
      default:
        return Colors.blue;
    }
  }

  Color _getGameColor(String gameId) {
    switch (gameId.toLowerCase()) {
      case 'tictactoe':
        return Colors.blue;
      case 'sudoku':
        return Colors.green;
      case 'minesweeper':
        return Colors.red;
      case 'match3':
        return Colors.purple;
      case '2048':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Dialog and popup actions
  void _showRevenueDetails(DashboardController controller) {
    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Revenue Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Revenue details would go here
              const Text('Detailed revenue information will be displayed here.'),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('CLOSE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickActionsMenu(BuildContext context, DashboardController controller) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.add_circle, color: Colors.green),
            title: Text('Create Announcement'),
            dense: true,
          ),
          onTap: () {
            Future.delayed(
              const Duration(milliseconds: 100),
              () => _showCreateAnnouncementDialog(),
            );
          },
        ),
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.people, color: Colors.blue),
            title: Text('Manage Users'),
            dense: true,
          ),
          onTap: () {
            Future.delayed(
              const Duration(milliseconds: 100),
              () => Get.find<AdminController>().tabController.animateTo(0),
            );
          },
        ),
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.report_problem, color: Colors.orange),
            title: Text('Review Reports'),
            dense: true,
          ),
          onTap: () {
            Future.delayed(
              const Duration(milliseconds: 100),
              () => Get.find<AdminController>().tabController.animateTo(1),
            );
          },
        ),
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.settings, color: Colors.red),
            title: Text('System Settings'),
            dense: true,
          ),
          onTap: () {
            Future.delayed(
              const Duration(milliseconds: 100),
              () => Get.toNamed('/admin/settings'),
            );
          },
        ),
      ],
    );
  }

  void _showReportDetails(Map<String, dynamic> report) {
    // Show report details dialog
    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Report Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Report details would go here
              Text('Content Type: ${report['contentType']}'),
              Text('Reason: ${report['reason']}'),
              Text('Reported by: ${report['reporter']['name']}'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CLOSE'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.find<AdminController>().tabController.animateTo(1);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                    child: const Text('MODERATE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAnnouncementDetails(Map<String, dynamic> announcement) {
    // Show announcement details dialog
    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                announcement['title'] ?? 'Announcement',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Type: ${announcement['type']?.toString().capitalizeFirst}',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Text(announcement['message'] ?? 'No message'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CLOSE'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.find<AdminController>().tabController.animateTo(3);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                    child: const Text('EDIT'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserDetails(UserModel user) {
    // Show user details dialog
    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: AvatarUserWidget(
                  radius: 40,
                  imagePath: user.image ?? '',
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  user.name ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: Text(
                  user.email ?? '',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Chip(
                  label: Text(user.role ?? 'user'),
                  backgroundColor: _getRoleColor(user.role),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        user.totalCoins ?? '0',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('Coins'),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        user.totalWins ?? '0',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('Wins'),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        (user.friendsList?.length ?? 0).toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('Friends'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CLOSE'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      // Navigate to detailed user profile
                      // This would be implemented in a future update
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                    child: const Text('VIEW PROFILE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGameDetails(Map<String, dynamic> game) {
    // Show game details dialog
    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                game['name'] as String,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Game statistics would go here
              Text('Total Plays: ${game['plays']}'),
              Text('Active Users: ${game['active']}'),
              const Text('Revenue: \${game[revenue]}'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CLOSE'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.find<AdminController>().tabController.animateTo(4);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                    child: const Text('MANAGE GAME'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSystemLogs() {
    // Show system logs dialog
    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.8,
          height: Get.height * 0.6,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'System Logs',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: 20, // Placeholder
                  itemBuilder: (context, index) {
                    return const ListTile(
                      dense: true,
                      title: Text('Log entry would go here'),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('CLOSE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMaintenanceDialog() {
    bool maintenanceMode = false;
    
    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            child: Container(
              width: Get.width * 0.6,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Maintenance Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Maintenance Mode'),
                    subtitle: const Text(
                      'Enable to block user access during maintenance',
                    ),
                    value: maintenanceMode,
                    onChanged: (value) {
                      setState(() {
                        maintenanceMode = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Maintenance Message',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    initialValue: 'We are currently performing maintenance. Please check back later.',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Scheduled End Time:'),
                      OutlinedButton.icon(
                        onPressed: () {
                          // Show datetime picker
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Select Time'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('CANCEL'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Apply maintenance settings
                          Get.back();
                          if (maintenanceMode) {
                            successMessage('Maintenance mode enabled');
                          } else {
                            successMessage('Maintenance mode disabled');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                        ),
                        child: const Text('APPLY'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCreateAnnouncementDialog() {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String type = 'system';
    String targetAudience = 'all';
    DateTime? startDate;
    DateTime? endDate;

    Get.dialog(
      Dialog(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create Announcement',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a message';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Type',
                              border: OutlineInputBorder(),
                            ),
                            value: type,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  type = value;
                                });
                              }
                            },
                            items: const [
                              DropdownMenuItem(value: 'system', child: Text('System')),
                              DropdownMenuItem(
                                  value: 'maintenance', child: Text('Maintenance')),
                              DropdownMenuItem(value: 'update', child: Text('Update')),
                              DropdownMenuItem(value: 'event', child: Text('Event')),
                            ],
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Target Audience',
                              border: OutlineInputBorder(),
                            ),
                            value: targetAudience,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  targetAudience = value;
                                });
                              }
                            },
                            items: const [
                              DropdownMenuItem(value: 'all', child: Text('All Users')),
                              DropdownMenuItem(
                                  value: 'admin', child: Text('Admins Only')),
                              DropdownMenuItem(
                                  value: 'moderator', child: Text('Moderators & Admins')),
                              DropdownMenuItem(
                                  value: 'new', child: Text('New Users (< 7 days)')),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate:
                                          DateTime.now().add(const Duration(days: 365)),
                                    );
                                    if (date != null) {
                                      setState(() {
                                        startDate = date;
                                      });
                                    }
                                  },
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'Start Date',
                                      border: OutlineInputBorder(),
                                    ),
                                    child: Text(
                                      startDate != null
                                          ? DateFormat('MMM dd, yyyy').format(startDate!)
                                          : 'Select Date',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    if (startDate == null) {
                                      Get.snackbar(
                                        'Error',
                                        'Please select a start date first',
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                      return;
                                    }

                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate:
                                          startDate!.add(const Duration(days: 1)),
                                      firstDate: startDate!.add(const Duration(days: 1)),
                                      lastDate: startDate!.add(const Duration(days: 365)),
                                    );
                                    if (date != null) {
                                      setState(() {
                                        endDate = date;
                                      });
                                    }
                                  },
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'End Date (Optional)',
                                      border: OutlineInputBorder(),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          endDate != null
                                              ? DateFormat('MMM dd, yyyy')
                                                  .format(endDate!)
                                              : 'No End Date',
                                        ),
                                        if (endDate != null)
                                          IconButton(
                                            icon: const Icon(Icons.clear, size: 16),
                                            onPressed: () {
                                              setState(() => endDate = null);
                                            },
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('CANCEL'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            Get.find<AdminController>()
                                .createAnnouncement(
                              title: titleController.text,
                              message: messageController.text,
                              type: type,
                              targetAudience: targetAudience,
                              startDate: startDate,
                              endDate: endDate,
                            )
                                .then((success) {
                              if (success) {
                                Get.back();
                                successMessage('Announcement created successfully!');
                                Get.find<DashboardController>().loadActiveAnnouncements();
                              }
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                        ),
                        child: const Text('CREATE'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---


### Pages\tabs\analytics_tab.dart

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:tictactoe_gameapp/Pages/Admin/controllers/admin_controller.dart';

class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();
    return Scaffold(
      body: Obx(() {
        if (controller.isLoadingAnalytics.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.analytics.value.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.analytics_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No analytics data available',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: controller.fetchAnalytics,
                  child: const Text('Refresh Analytics'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchAnalytics(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateRangeSelector(controller),
                const SizedBox(height: 16),
                _buildOverviewCards(controller),
                const SizedBox(height: 24),
                _buildUserAnalytics(controller),
                const SizedBox(height: 24),
                _buildContentAnalytics(controller),
                const SizedBox(height: 24),
                _buildEngagementAnalytics(controller),
                const SizedBox(height: 24),
                _buildGameAnalytics(controller),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDateRangeSelector(AdminController controller) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Date Range',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Obx(() => OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          DateFormat('MMM dd, yyyy')
                              .format(controller.analyticsStartDate.value),
                        ),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: Get.context!,
                            initialDate: controller.analyticsStartDate.value,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            controller.analyticsStartDate.value = picked;
                          }
                        },
                      )),
                ),
                const SizedBox(width: 16),
                const Text('to'),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() => OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          DateFormat('MMM dd, yyyy')
                              .format(controller.analyticsEndDate.value),
                        ),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: Get.context!,
                            initialDate: controller.analyticsEndDate.value,
                            firstDate: controller.analyticsStartDate.value,
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            controller.analyticsEndDate.value = picked;
                          }
                        },
                      )),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _dateRangeButton('Last 7 Days', controller, 7),
                  _dateRangeButton('Last 30 Days', controller, 30),
                  _dateRangeButton('Last 90 Days', controller, 90),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.fetchCustomAnalytics(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                ),
                child: const Text('Apply Date Range'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateRangeButton(String text, AdminController controller, int days) {
    return ElevatedButton(
      onPressed: () {
        controller.analyticsEndDate.value = DateTime.now();
        controller.analyticsStartDate.value =
            DateTime.now().subtract(Duration(days: days));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black87,
      ),
      child: Text(text),
    );
  }

  Widget _buildOverviewCards(AdminController controller) {
    final analytics = controller.analytics.value;
    final totalUsers = analytics['totalUsers'] ?? 0;
    final totalPosts = analytics['totalPosts'] ?? 0;
    final reportedContent = analytics['reportedContent'] ?? 0;
    final activeGames = analytics['activeGames'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildOverviewCard(
              icon: Icons.people,
              title: 'Total Users',
              value: totalUsers.toString(),
              color: Colors.blue,
            ),
            _buildOverviewCard(
              icon: Icons.post_add,
              title: 'Total Posts',
              value: totalPosts.toString(),
              color: Colors.green,
            ),
            _buildOverviewCard(
              icon: Icons.report,
              title: 'Reported Content',
              value: reportedContent.toString(),
              color: Colors.orange,
            ),
            _buildOverviewCard(
              icon: Icons.games,
              title: 'Active Games',
              value: activeGames.toString(),
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAnalytics(AdminController controller) {
    final analytics = controller.analytics.value;
    final usersByRole = analytics['usersByRole'] as Map<String, dynamic>? ?? {};

    // Prepare data for pie chart
    final pieData = <PieChartSectionData>[];

    if (usersByRole.containsKey('admin')) {
      pieData.add(PieChartSectionData(
        value: (usersByRole['admin'] ?? 0).toDouble(),
        title: 'Admin',
        color: Colors.red,
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ));
    }

    if (usersByRole.containsKey('moderator')) {
      pieData.add(PieChartSectionData(
        value: (usersByRole['moderator'] ?? 0).toDouble(),
        title: 'Mod',
        color: Colors.green,
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ));
    }

    if (usersByRole.containsKey('user')) {
      pieData.add(PieChartSectionData(
        value: (usersByRole['user'] ?? 0).toDouble(),
        title: 'User',
        color: Colors.blue,
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'User Analytics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Users by Role',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: pieData.isEmpty
                      ? const Center(child: Text('No data available'))
                      : PieChart(
                          PieChartData(
                            sections: pieData,
                            centerSpaceRadius: 40,
                            sectionsSpace: 2,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLegendItem(
                        'Admin', Colors.red, usersByRole['admin'] ?? 0),
                    _buildLegendItem('Moderator', Colors.green,
                        usersByRole['moderator'] ?? 0),
                    _buildLegendItem(
                        'User', Colors.blue, usersByRole['user'] ?? 0),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, int value) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text('$label: $value'),
      ],
    );
  }

  Widget _buildContentAnalytics(AdminController controller) {
    final analytics = controller.analytics.value;
    final totalPosts = analytics['totalPosts'] ?? 0;
    final recentPosts = analytics['recentPosts'] ?? 0;

    // Mock data for bar chart
    final mockData = [
      {'day': 'Mon', 'posts': 25, 'comments': 120},
      {'day': 'Tue', 'posts': 40, 'comments': 200},
      {'day': 'Wed', 'posts': 35, 'comments': 180},
      {'day': 'Thu', 'posts': 50, 'comments': 250},
      {'day': 'Fri', 'posts': 65, 'comments': 300},
      {'day': 'Sat', 'posts': 80, 'comments': 400},
      {'day': 'Sun', 'posts': 60, 'comments': 320},
    ];

    final customRange = analytics['customRange'] as Map<String, dynamic>? ?? {};
    final customRangeNewPosts = customRange['newPosts'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Content Analytics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Total Posts',
                        value: '$totalPosts',
                        icon: Icons.post_add,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Recent Posts (7d)',
                        value: '$recentPosts',
                        icon: Icons.trending_up,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Content Creation Trend',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 500,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final day = mockData[group.x.toInt()]['day'];
                            final value = rodIndex == 0
                                ? mockData[group.x.toInt()]['posts']
                                : mockData[group.x.toInt()]['comments'];
                            final label = rodIndex == 0 ? 'Posts' : 'Comments';
                            return BarTooltipItem(
                              '$day\n$label: $value',
                              const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                    mockData[value.toInt()]['day'] as String),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(value.toInt().toString()),
                              );
                            },
                            interval: 100,
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(
                        show: true,
                        drawVerticalLine: false,
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: mockData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: (data['posts'] as int).toDouble(),
                              color: Colors.blue,
                              width: 12,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                            BarChartRodData(
                              toY: (data['comments'] as int).toDouble(),
                              color: Colors.orange,
                              width: 12,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem('Posts', Colors.blue, 0),
                    const SizedBox(width: 16),
                    _buildLegendItem('Comments', Colors.orange, 0),
                  ],
                ),
                if (customRange.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Custom Range: ${DateFormat('MMM dd').format(controller.analyticsStartDate.value)} - ${DateFormat('MMM dd').format(controller.analyticsEndDate.value)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('New Posts: $customRangeNewPosts'),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementAnalytics(AdminController controller) {
    // Mock data for line chart
    final mockEngagementData = [
      {'day': 'Week 1', 'likes': 1200, 'shares': 400, 'comments': 800},
      {'day': 'Week 2', 'likes': 1800, 'shares': 600, 'comments': 1200},
      {'day': 'Week 3', 'likes': 1400, 'shares': 500, 'comments': 900},
      {'day': 'Week 4', 'likes': 2000, 'shares': 700, 'comments': 1300},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Engagement Analytics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Monthly Engagement Trends',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final data = mockEngagementData[spot.x.toInt()];
                              String value = '';
                              String label = '';
                              Color color = Colors.white;

                              if (spot.barIndex == 0) {
                                value = data['likes'].toString();
                                label = 'Likes';
                                color = Colors.pink;
                              } else if (spot.barIndex == 1) {
                                value = data['shares'].toString();
                                label = 'Shares';
                                color = Colors.blue;
                              } else {
                                value = data['comments'].toString();
                                label = 'Comments';
                                color = Colors.orange;
                              }

                              return LineTooltipItem(
                                '$label: $value',
                                TextStyle(
                                    color: color, fontWeight: FontWeight.bold),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      gridData: const FlGridData(
                        show: true,
                        drawVerticalLine: false,
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(mockEngagementData[value.toInt()]
                                    ['day'] as String),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 500,
                            getTitlesWidget: (value, meta) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(value.toInt().toString()),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      minX: 0,
                      maxX: mockEngagementData.length - 1.0,
                      minY: 0,
                      maxY: 2200,
                      lineBarsData: [
                        // Likes line
                        LineChartBarData(
                          spots:
                              mockEngagementData.asMap().entries.map((entry) {
                            return FlSpot(
                              entry.key.toDouble(),
                              (entry.value['likes'] as int).toDouble(),
                            );
                          }).toList(),
                          isCurved: true,
                          color: Colors.pink,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.pink.withOpacity(0.1),
                          ),
                        ),
                        // Shares line
                        LineChartBarData(
                          spots:
                              mockEngagementData.asMap().entries.map((entry) {
                            return FlSpot(
                              entry.key.toDouble(),
                              (entry.value['shares'] as int).toDouble(),
                            );
                          }).toList(),
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blue.withOpacity(0.1),
                          ),
                        ),
                        // Comments line
                        LineChartBarData(
                          spots:
                              mockEngagementData.asMap().entries.map((entry) {
                            return FlSpot(
                              entry.key.toDouble(),
                              (entry.value['comments'] as int).toDouble(),
                            );
                          }).toList(),
                          isCurved: true,
                          color: Colors.orange,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.orange.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem('Likes', Colors.pink, 0),
                    const SizedBox(width: 16),
                    _buildLegendItem('Shares', Colors.blue, 0),
                    const SizedBox(width: 16),
                    _buildLegendItem('Comments', Colors.orange, 0),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameAnalytics(AdminController controller) {
    // Mock data for game analytics
    final mockGameData = {
      'tictactoe': {'plays': 12500, 'users': 2800, 'avgTimePerGame': '2m 15s'},
      'sudoku': {'plays': 8200, 'users': 1900, 'avgTimePerGame': '8m 30s'},
      'minesweeper': {'plays': 6400, 'users': 1500, 'avgTimePerGame': '5m 45s'},
      'match3': {'plays': 15800, 'users': 3200, 'avgTimePerGame': '6m 20s'},
      '2048': {'plays': 9300, 'users': 2100, 'avgTimePerGame': '4m 10s'},
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Game Analytics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Game Performance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  children: mockGameData.entries.map((entry) {
                    final gameName = entry.key;
                    final gameData = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              gameName.capitalize!,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LinearProgressIndicator(
                                  value: (gameData['plays'] as int) / 20000,
                                  backgroundColor: Colors.grey[200],
                                  color: _getGameColor(gameName),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${gameData['plays']} plays',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Game Distribution',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: mockGameData.entries.map((entry) {
                        final gameName = entry.key;
                        final gameData = entry.value;
                        return PieChartSectionData(
                          value: (gameData['plays'] as int).toDouble(),
                          title:
                              '${(gameData['plays'] as int) * 100 ~/ 52200}%',
                          radius: 60,
                          color: _getGameColor(gameName),
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        );
                      }).toList(),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: mockGameData.entries.map((entry) {
                    final gameName = entry.key;
                    return _buildLegendItem(
                      gameName.capitalize!,
                      _getGameColor(gameName),
                      entry.value['plays'] as int,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getGameColor(String gameName) {
    switch (gameName.toLowerCase()) {
      case 'tictactoe':
        return Colors.blue;
      case 'sudoku':
        return Colors.green;
      case 'minesweeper':
        return Colors.red;
      case 'match3':
        return Colors.purple;
      case '2048':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

```

---


### Pages\tabs\announcements_tab.dart

```dart
// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Models/Functions/time_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:tictactoe_gameapp/Pages/Admin/controllers/admin_controller.dart';

class AnnouncementsTab extends StatelessWidget {
  const AnnouncementsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();

    return Column(
      children: [
        _buildFilterBar(controller),
        Expanded(
          child: _buildAnnouncementsList(controller),
        ),
      ],
    );
  }

  Widget _buildFilterBar(AdminController controller) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const Text('Filter by: '),
          const SizedBox(width: 8),
          Obx(() => DropdownButton<String>(
                value: controller.announcementTypeFilter.value,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(value: 'system', child: Text('System')),
                  DropdownMenuItem(
                      value: 'maintenance', child: Text('Maintenance')),
                  DropdownMenuItem(value: 'update', child: Text('Update')),
                  DropdownMenuItem(value: 'event', child: Text('Event')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    controller.announcementTypeFilter.value = value;
                  }
                },
              )),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => _showCreateAnnouncementDialog(controller),
            icon: const Icon(Icons.add),
            label: const Text('New Announcement'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildAnnouncementsList(AdminController controller) {
  return Obx(() {
    if (controller.isLoadingAnnouncements.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.announcements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.announcement_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No announcements found',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showCreateAnnouncementDialog(controller),
              child: const Text('Create Announcement'),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          controller.fetchAnnouncements(); // Load more when reaching the end
        }
        return true;
      },
      child: ListView.builder(
        itemCount: controller.announcements.length,
        itemBuilder: (context, index) {
          final announcement = controller.announcements[index];
          return _buildAnnouncementItem(controller, announcement);
        },
      ),
    );
  });
}

Widget _buildAnnouncementItem(
    AdminController controller, Map<String, dynamic> announcement) {
  final String id = announcement['id'] ?? '';
  final String title = announcement['title'] ?? 'No Title';
  final String message = announcement['message'] ?? 'No message';
  final String type = announcement['type'] ?? 'system';
  final String targetAudience = announcement['targetAudience'] ?? 'all';
  final bool active = announcement['active'] ?? false;

  // Parse timestamps
  DateTime? createdAt;
  if (announcement['createdAt'] != null) {
    createdAt = (announcement['createdAt'] as Timestamp).toDate();
  }

  DateTime? startDate;
  if (announcement['startDate'] != null) {
    startDate = (announcement['startDate'] as Timestamp).toDate();
  }

  DateTime? endDate;
  if (announcement['endDate'] != null) {
    endDate = (announcement['endDate'] as Timestamp).toDate();
  }

  // Determine if announcement is current, upcoming, or expired
  final now = DateTime.now();
  String status = 'current';

  if (startDate != null && startDate.isAfter(now)) {
    status = 'upcoming';
  } else if (endDate != null && endDate.isBefore(now)) {
    status = 'expired';
  }

  return Card(
    margin: const EdgeInsets.all(8.0),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(
        color: _getBorderColor(status, active),
        width: 2,
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAnnouncementTypeChip(type),
              const SizedBox(width: 8),
              _buildStatusChip(status, active),
              const Spacer(),
              Text(
                createdAt != null
                    ? TimeFunctions.timeAgo(now: now, createdAt: createdAt)
                    : 'Unknown time',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(message),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.people, size: 16),
              const SizedBox(width: 4),
              Text(
                'Target: ${targetAudience.capitalize}',
                style: const TextStyle(fontSize: 12),
              ),
              const Spacer(),
              if (startDate != null && endDate != null)
                Text(
                  '${DateFormat('MMM dd').format(startDate)} - ${DateFormat('MMM dd').format(endDate)}',
                  style: const TextStyle(fontSize: 12),
                )
              else if (startDate != null)
                Text(
                  'From ${DateFormat('MMM dd').format(startDate)}',
                  style: const TextStyle(fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => _editAnnouncement(controller, announcement),
                icon: const Icon(Icons.edit),
                tooltip: 'Edit',
              ),
              if (active)
                IconButton(
                  onPressed: () => _deactivateAnnouncement(controller, id),
                  icon: const Icon(Icons.visibility_off),
                  tooltip: 'Deactivate',
                )
              else
                IconButton(
                  onPressed: () => _activateAnnouncement(controller, id),
                  icon: const Icon(Icons.visibility),
                  tooltip: 'Activate',
                ),
              IconButton(
                onPressed: () =>
                    _confirmDeleteAnnouncement(controller, id, title),
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Delete',
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildAnnouncementTypeChip(String type) {
  IconData icon;
  Color color;

  switch (type) {
    case 'system':
      icon = Icons.info;
      color = Colors.blue;
      break;
    case 'maintenance':
      icon = Icons.build;
      color = Colors.orange;
      break;
    case 'update':
      icon = Icons.system_update;
      color = Colors.green;
      break;
    case 'event':
      icon = Icons.event;
      color = Colors.purple;
      break;
    default:
      icon = Icons.announcement;
      color = Colors.grey;
  }

  return Chip(
    avatar: Icon(
      icon,
      size: 16,
      color: Colors.white,
    ),
    label: Text(
      type.capitalize!,
      style: const TextStyle(color: Colors.white, fontSize: 12),
    ),
    backgroundColor: color,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    padding: EdgeInsets.zero,
  );
}

Widget _buildStatusChip(String status, bool active) {
  IconData icon;
  Color color;
  String label;

  if (!active) {
    icon = Icons.visibility_off;
    color = Colors.grey;
    label = 'Inactive';
  } else {
    switch (status) {
      case 'upcoming':
        icon = Icons.access_time;
        color = Colors.amber;
        label = 'Upcoming';
        break;
      case 'expired':
        icon = Icons.timer_off;
        color = Colors.red;
        label = 'Expired';
        break;
      default:
        icon = Icons.check_circle;
        color = Colors.green;
        label = 'Active';
    }
  }

  return Chip(
    avatar: Icon(
      icon,
      size: 16,
      color: Colors.white,
    ),
    label: Text(
      label,
      style: const TextStyle(color: Colors.white, fontSize: 12),
    ),
    backgroundColor: color,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    padding: EdgeInsets.zero,
  );
}

Color _getBorderColor(String status, bool active) {
  if (!active) return Colors.grey;

  switch (status) {
    case 'upcoming':
      return Colors.amber;
    case 'expired':
      return Colors.red;
    default:
      return Colors.green;
  }
}

void _showCreateAnnouncementDialog(AdminController controller) {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final messageController = TextEditingController();
  String type = 'system';
  String targetAudience = 'all';
  DateTime? startDate;
  DateTime? endDate;

  Get.dialog(
    Dialog(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create Announcement',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a message';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  value: type,
                  onChanged: (value) {
                    if (value != null) {
                      type = value;
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'system', child: Text('System')),
                    DropdownMenuItem(
                        value: 'maintenance', child: Text('Maintenance')),
                    DropdownMenuItem(value: 'update', child: Text('Update')),
                    DropdownMenuItem(value: 'event', child: Text('Event')),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Target Audience',
                    border: OutlineInputBorder(),
                  ),
                  value: targetAudience,
                  onChanged: (value) {
                    if (value != null) {
                      targetAudience = value;
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Users')),
                    DropdownMenuItem(
                        value: 'admin', child: Text('Admins Only')),
                    DropdownMenuItem(
                        value: 'moderator', child: Text('Moderators & Admins')),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: Get.context!,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            startDate = date;
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Start Date',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            startDate != null
                                ? DateFormat('MMM dd, yyyy').format(startDate)
                                : 'Select Date',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          if (startDate == null) {
                            Get.snackbar(
                              'Error',
                              'Please select a start date first',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }

                          final date = await showDatePicker(
                            context: Get.context!,
                            initialDate:
                                startDate!.add(const Duration(days: 1)),
                            firstDate: startDate!.add(const Duration(days: 1)),
                            lastDate: startDate!.add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            endDate = date;
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'End Date (Optional)',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            endDate != null
                                ? DateFormat('MMM dd, yyyy').format(endDate)
                                : 'No End Date',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('CANCEL'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          controller
                              .createAnnouncement(
                            title: titleController.text,
                            message: messageController.text,
                            type: type,
                            targetAudience: targetAudience,
                            startDate: startDate,
                            endDate: endDate,
                          )
                              .then((success) {
                            if (success) {
                              Get.back();
                            }
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                      ),
                      child: const Text('CREATE'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

void _editAnnouncement(
    AdminController controller, Map<String, dynamic> announcement) {
  final formKey = GlobalKey<FormState>();
  final String id = announcement['id'] ?? '';
  final titleController =
      TextEditingController(text: announcement['title'] ?? '');
  final messageController =
      TextEditingController(text: announcement['message'] ?? '');
  String type = announcement['type'] ?? 'system';
  String targetAudience = announcement['targetAudience'] ?? 'all';

  DateTime? startDate;
  if (announcement['startDate'] != null) {
    startDate = (announcement['startDate'] as Timestamp).toDate();
  }

  DateTime? endDate;
  if (announcement['endDate'] != null) {
    endDate = (announcement['endDate'] as Timestamp).toDate();
  }

  Get.dialog(
    Dialog(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Announcement',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a message';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  value: type,
                  onChanged: (value) {
                    if (value != null) {
                      type = value;
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'system', child: Text('System')),
                    DropdownMenuItem(
                        value: 'maintenance', child: Text('Maintenance')),
                    DropdownMenuItem(value: 'update', child: Text('Update')),
                    DropdownMenuItem(value: 'event', child: Text('Event')),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Target Audience',
                    border: OutlineInputBorder(),
                  ),
                  value: targetAudience,
                  onChanged: (value) {
                    if (value != null) {
                      targetAudience = value;
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Users')),
                    DropdownMenuItem(
                        value: 'admin', child: Text('Admins Only')),
                    DropdownMenuItem(
                        value: 'moderator', child: Text('Moderators & Admins')),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: StatefulBuilder(
                        builder: (context, setState) => InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() => startDate = date);
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Start Date',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              startDate != null
                                  ? DateFormat('MMM dd, yyyy')
                                      .format(startDate!)
                                  : 'Select Date',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatefulBuilder(
                        builder: (context, setState) => InkWell(
                          onTap: () async {
                            if (startDate == null) {
                              Get.snackbar(
                                'Error',
                                'Please select a start date first',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            final date = await showDatePicker(
                              context: context,
                              initialDate: endDate ??
                                  startDate!.add(const Duration(days: 1)),
                              firstDate:
                                  startDate!.add(const Duration(days: 1)),
                              lastDate:
                                  startDate!.add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() => endDate = date);
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'End Date (Optional)',
                              border: OutlineInputBorder(),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  endDate != null
                                      ? DateFormat('MMM dd, yyyy')
                                          .format(endDate!)
                                      : 'No End Date',
                                ),
                                if (endDate != null)
                                  IconButton(
                                    icon: const Icon(Icons.clear, size: 16),
                                    onPressed: () {
                                      setState(() => endDate = null);
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('CANCEL'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final updateData = {
                            'title': titleController.text,
                            'message': messageController.text,
                            'type': type,
                            'targetAudience': targetAudience,
                            'startDate': startDate,
                            'endDate': endDate,
                          };

                          controller
                              .updateAnnouncement(id, updateData)
                              .then((success) {
                            if (success) {
                              Get.back();
                            }
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                      ),
                      child: const Text('SAVE'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

void _activateAnnouncement(AdminController controller, String id) {
  controller.updateAnnouncement(id, {'active': true});
}

void _deactivateAnnouncement(AdminController controller, String id) {
  controller.updateAnnouncement(id, {'active': false});
}

void _confirmDeleteAnnouncement(
    AdminController controller, String id, String title) {
  Get.dialog(Dialog(child: Text(title)));
}

```

---


### Pages\tabs\content_moderation_tab.dart

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';
import 'package:tictactoe_gameapp/Models/Functions/time_functions.dart';
import 'package:tictactoe_gameapp/Pages/Admin/controllers/admin_controller.dart';

class ContentModerationTab extends StatelessWidget {
  const ContentModerationTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();
    
    return Column(
      children: [
        _buildFilterBar(controller),
        Expanded(
          child: _buildReportedContentList(controller),
        ),
      ],
    );
  }
  
  Widget _buildFilterBar(AdminController controller) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const Text('Filter by: '),
          const SizedBox(width: 8),
          Obx(() => DropdownButton<String>(
            value: controller.contentTypeFilter.value,
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All')),
              DropdownMenuItem(value: 'post', child: Text('Posts')),
              DropdownMenuItem(value: 'comment', child: Text('Comments')),
              DropdownMenuItem(value: 'reel', child: Text('Reels')),
              DropdownMenuItem(value: 'user', child: Text('Users')),
            ],
            onChanged: (value) {
              if (value != null) {
                controller.contentTypeFilter.value = value;
              }
            },
          )),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => controller.fetchReportedContent(refresh: true),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReportedContentList(AdminController controller) {
    return Obx(() {
      if (controller.isLoadingReports.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (controller.reportedContent.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 64,
                color: Colors.green,
              ),
              SizedBox(height: 16),
              Text(
                'No reported content to review',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'All clear! Check back later for new reports.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }
      
      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            controller.fetchReportedContent(); // Load more when reaching the end
          }
          return true;
        },
        child: ListView.builder(
          itemCount: controller.reportedContent.length,
          itemBuilder: (context, index) {
            final report = controller.reportedContent[index];
            return _buildReportedContentItem(controller, report);
          },
        ),
      );
    });
  }
  
  Widget _buildReportedContentItem(AdminController controller, Map<String, dynamic> report) {
    String contentType = report['contentType'] ?? '';
    String contentId = report['contentId'] ?? '';
    int reportCount = report['reportCount'] ?? 1;
    String reason = report['reason'] ?? 'Not specified';
    DateTime reportedAt = report['reportedAt'] != null 
      ? (report['reportedAt'] as Timestamp).toDate()
      : DateTime.now();
    Map<String, dynamic>? reporterData = report['reporter'];
    Map<String, dynamic>? contentData = report['contentData'];
    
    // Prepare user data
    String reporterName = reporterData?['name'] ?? 'Unknown';
    String reporterImage = reporterData?['image'] ?? '';
    
    // Prepare content preview
    String contentPreview = '';
    if (contentData != null) {
      if (contentType == 'post') {
        contentPreview = contentData['content'] ?? '';
      } else if (contentType == 'comment') {
        contentPreview = contentData['content'] ?? '';
      } else if (contentType == 'reel') {
        contentPreview = contentData['description'] ?? '';
      } else if (contentType == 'user') {
        contentPreview = 'User profile reported';
      }
    }
    
    // Create a readable content identifier
    String contentIdentifier = contentType.capitalizeFirst ?? '';
    if (contentPreview.isNotEmpty) {
      contentIdentifier += ': "${contentPreview.length > 50 ? contentPreview.substring(0, 50) + '...' : contentPreview}"';
    }
    
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildReportTypeChip(contentType),
                const SizedBox(width: 8),
                Chip(
                  label: Text('$reportCount reports'),
                  backgroundColor: _getReportCountColor(reportCount),
                ),
                const Spacer(),
                Text(
                  TimeFunctions.timeAgo(now: DateTime.now(), createdAt: reportedAt),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reporter info
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reported by:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (reporterImage.isNotEmpty)
                            AvatarUserWidget(
                              radius: 20,
                              imagePath: reporterImage,
                            )
                          else
                            const CircleAvatar(
                              radius: 20,
                              child: Icon(Icons.person),
                            ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(reporterName),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Content info
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Content:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(contentIdentifier),
                      const SizedBox(height: 8),
                      const Text(
                        'Reason:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(reason),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _viewReportedContent(report, controller),
                  icon: const Icon(Icons.visibility),
                  label: const Text('View'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showModerationActionsDialog(report, controller),
                  icon: const Icon(Icons.gavel),
                  label: const Text('Moderate'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildReportTypeChip(String contentType) {
    IconData icon;
    Color color;
    
    switch (contentType) {
      case 'post':
        icon = Icons.post_add;
        color = Colors.blue;
        break;
      case 'comment':
        icon = Icons.comment;
        color = Colors.green;
        break;
      case 'reel':
        icon = Icons.video_collection;
        color = Colors.purple;
        break;
      case 'user':
        icon = Icons.person;
        color = Colors.orange;
        break;
      default:
        icon = Icons.warning;
        color = Colors.red;
    }
    
    return Chip(
      avatar: Icon(
        icon,
        size: 16,
        color: Colors.white,
      ),
      label: Text(
        contentType.capitalizeFirst ?? '',
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }
  
  Color _getReportCountColor(int count) {
    if (count >= 10) {
      return Colors.red;
    } else if (count >= 5) {
      return Colors.orange;
    } else {
      return Colors.amber;
    }
  }
  
  void _viewReportedContent(Map<String, dynamic> report, AdminController controller) {
    // Different actions based on content type
    String contentType = report['contentType'] ?? '';
    String contentId = report['contentId'] ?? '';
    Map<String, dynamic>? contentData = report['contentData'];
    
    if (contentData == null) {
      Get.snackbar(
        'Error',
        'Content data not available',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.8,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reported ${contentType.capitalizeFirst}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildContentPreview(contentType, contentData),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CLOSE'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      _showModerationActionsDialog(report, controller);
                    },
                    child: const Text('MODERATE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildContentPreview(String contentType, Map<String, dynamic> contentData) {
    switch (contentType) {
      case 'post':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (contentData['postUser'] != null)
              Row(
                children: [
                  AvatarUserWidget(
                    radius: 20,
                    imagePath: contentData['postUser']['image'] ?? '',
                  ),
                  const SizedBox(width: 8),
                  Text(
                    contentData['postUser']['name'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Text(contentData['content'] ?? 'No content'),
            if (contentData['imageUrls'] != null && (contentData['imageUrls'] as List).isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('[Post contains images]'),
              ),
          ],
        );
        
      case 'comment':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (contentData['commentUser'] != null)
              Row(
                children: [
                  AvatarUserWidget(
                    radius: 20,
                    imagePath: contentData['commentUser']['image'] ?? '',
                  ),
                  const SizedBox(width: 8),
                  Text(
                    contentData['commentUser']['name'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Text(contentData['content'] ?? 'No content'),
            const SizedBox(height: 8),
            Text(
              'On post: ${contentData['postId'] ?? 'Unknown post'}',
              style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        );
        
      case 'reel':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (contentData['reelUser'] != null)
              Row(
                children: [
                  AvatarUserWidget(
                    radius: 20,
                    imagePath: contentData['reelUser']['image'] ?? '',
                  ),
                  const SizedBox(width: 8),
                  Text(
                    contentData['reelUser']['name'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Text(contentData['description'] ?? 'No description'),
            const SizedBox(height: 8),
            const Text('[Reel video content]'),
          ],
        );
        
      case 'user':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AvatarUserWidget(
                  radius: 30,
                  imagePath: contentData['image'] ?? '',
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contentData['name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(contentData['email'] ?? ''),
                    Text('Role: ${contentData['role'] ?? 'user'}'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Bio: ${contentData['bio'] ?? 'No bio'}'),
          ],
        );
        
      default:
        return const Text('Unknown content type');
    }
  }
  
  void _showModerationActionsDialog(Map<String, dynamic> report, AdminController controller) {
    final contentType = report['contentType'] ?? '';
    final contentId = report['contentId'] ?? '';
    final formKey = GlobalKey<FormState>();
    final reasonController = TextEditingController();
    
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Moderation Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Moderation Reason',
                    hintText: 'Optional: Add a note for this action',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Action:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _actionButton(
                      icon: Icons.visibility_off,
                      label: 'Hide',
                      color: Colors.orange,
                      onTap: () {
                        _performModeration(
                          controller,
                          contentType,
                          contentId,
                          'hide',
                          reasonController.text,
                        );
                      },
                    ),
                    _actionButton(
                      icon: Icons.delete,
                      label: 'Delete',
                      color: Colors.red,
                      onTap: () {
                        _performModeration(
                          controller,
                          contentType,
                          contentId,
                          'delete',
                          reasonController.text,
                        );
                      },
                    ),
                    _actionButton(
                      icon: Icons.warning,
                      label: 'Warn User',
                      color: Colors.amber,
                      onTap: () {
                        _performModeration(
                          controller,
                          contentType,
                          contentId,
                          'warn',
                          reasonController.text,
                        );
                      },
                    ),
                    _actionButton(
                      icon: Icons.restore,
                      label: 'Restore',
                      color: Colors.green,
                      onTap: () {
                        _performModeration(
                          controller,
                          contentType,
                          contentId,
                          'restore',
                          reasonController.text,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CANCEL'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _performModeration(
    AdminController controller,
    String contentType,
    String contentId,
    String action,
    String reason,
  ) async {
    if (contentType.isEmpty || contentId.isEmpty) {
      Get.back();
      Get.snackbar(
        'Error',
        'Invalid content information',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    Get.back();
    
    final success = await controller.moderateContent(
      contentType,
      contentId,
      action,
      reason: reason,
    );
    
    if (success) {
      Get.snackbar(
        'Success',
        'Content has been moderated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }
}
```

---


### Pages\tabs\game_management_tab.dart

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Pages/Admin/controllers/admin_controller.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';

class GameManagementTab extends StatefulWidget {
  const GameManagementTab({super.key});

  @override
  State<GameManagementTab> createState() => _GameManagementTabState();
}

class _GameManagementTabState extends State<GameManagementTab>
    with SingleTickerProviderStateMixin {
  late TabController _gameTabController;

  @override
  void initState() {
    super.initState();
    _gameTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _gameTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGameSelector(controller),
          const SizedBox(height: 24),
          // Game tab selector
          TabBar(
            controller: _gameTabController,
            labelColor: Colors.deepPurpleAccent,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Configuration'),
              Tab(text: 'Leaderboard'),
              Tab(text: 'Statistics'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingLeaderboards.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return TabBarView(
                controller: _gameTabController,
                children: [
                  _buildGameConfigTab(controller),
                  _buildLeaderboardTab(controller),
                  _buildGameStatsTab(controller),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildGameSelector(AdminController controller) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Game',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildGameButton(
                    controller,
                    'tictactoe',
                    'Tic Tac Toe',
                    Icons.grid_3x3,
                  ),
                  _buildGameButton(
                    controller,
                    'sudoku',
                    'Sudoku',
                    Icons.grid_4x4,
                  ),
                  _buildGameButton(
                    controller,
                    'minesweeper',
                    'Minesweeper',
                    Icons.flag,
                  ),
                  _buildGameButton(
                    controller,
                    'match3',
                    'Match 3',
                    Icons.view_comfy,
                  ),
                  _buildGameButton(
                    controller,
                    '2048',
                    '2048',
                    Icons.view_module,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameButton(
    AdminController controller,
    String gameId,
    String name,
    IconData icon,
  ) {
    return Obx(() {
      final isSelected = controller.selectedGame.value == gameId;

      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ElevatedButton.icon(
          onPressed: () {
            controller.selectedGame.value = gameId;
            controller.fetchGameLeaderboard(gameId);
            controller.fetchGameConfig(gameId);
          },
          icon: Icon(icon),
          label: Text(name),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isSelected ? Colors.deepPurpleAccent : Colors.grey[200],
            foregroundColor: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      );
    });
  }

  Widget _buildGameConfigTab(AdminController controller) {
    return Obx(() {
      final gameId = controller.selectedGame.value;
      final gameConfig = controller.gameConfig.value;

      // Default configurations if none exists
      final defaultConfigs = _getDefaultGameConfig(gameId);

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Text(
                            '${gameId.capitalize} Configuration',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _saveGameConfig(controller),
                            icon: const Icon(Icons.save),
                            label: const Text('Save Changes'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurpleAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildConfigPanel(
                        controller, gameId, gameConfig, defaultConfigs),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildEmoteConfigCard(controller, gameId),
          ],
        ),
      );
    });
  }

  Widget _buildConfigPanel(
    AdminController controller,
    String gameId,
    Map<String, dynamic> gameConfig,
    Map<String, dynamic> defaultConfigs,
  ) {
    switch (gameId) {
      case 'tictactoe':
        return _buildTicTacToeConfig(controller, gameConfig, defaultConfigs);
      case 'sudoku':
        return _buildSudokuConfig(controller, gameConfig, defaultConfigs);
      case 'minesweeper':
        return _buildMinesweeperConfig(controller, gameConfig, defaultConfigs);
      case 'match3':
        return _buildMatch3Config(controller, gameConfig, defaultConfigs);
      case '2048':
        return _build2048Config(controller, gameConfig, defaultConfigs);
      default:
        return const Center(
            child: Text('No configuration available for this game'));
    }
  }

  Widget _buildTicTacToeConfig(
    AdminController controller,
    Map<String, dynamic> gameConfig,
    Map<String, dynamic> defaultConfigs,
  ) {
    final boardSizes = ['3x3', '4x4', '5x5'];

    // Get values with defaults
    final activeBoardSizes = List<String>.from(
        gameConfig['activeBoardSizes'] ?? defaultConfigs['activeBoardSizes']);
    final winReward = gameConfig['winReward'] ?? defaultConfigs['winReward'];
    final drawReward = gameConfig['drawReward'] ?? defaultConfigs['drawReward'];
    final timeLimit = gameConfig['timeLimit'] ?? defaultConfigs['timeLimit'];
    final aiDifficulty =
        gameConfig['aiDifficulty'] ?? defaultConfigs['aiDifficulty'];

    // Controllers for editable fields
    final winRewardController =
        TextEditingController(text: winReward.toString());
    final drawRewardController =
        TextEditingController(text: drawReward.toString());
    final timeLimitController =
        TextEditingController(text: timeLimit.toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Board Sizes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: boardSizes.map((size) {
            final isActive = activeBoardSizes.contains(size);
            return FilterChip(
              label: Text(size),
              selected: isActive,
              onSelected: (selected) {
                if (selected) {
                  activeBoardSizes.add(size);
                } else {
                  if (activeBoardSizes.length > 1) {
                    activeBoardSizes.remove(size);
                  } else {
                    Get.snackbar(
                      'Error',
                      'At least one board size must be active',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                }

                // Create a copy of the current config for immutability
                final updatedConfig =
                    Map<String, dynamic>.from(controller.gameConfig.value);
                updatedConfig['activeBoardSizes'] = activeBoardSizes;
                controller.gameConfig.value = updatedConfig;
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: winRewardController,
                decoration: const InputDecoration(
                  labelText: 'Win Reward (Coins)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final reward = int.tryParse(value) ?? winReward;
                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  updatedConfig['winReward'] = reward;
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: drawRewardController,
                decoration: const InputDecoration(
                  labelText: 'Draw Reward (Coins)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final reward = int.tryParse(value) ?? drawReward;
                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  updatedConfig['drawReward'] = reward;
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: timeLimitController,
                decoration: const InputDecoration(
                  labelText: 'Time Limit (seconds)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final limit = int.tryParse(value) ?? timeLimit;
                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  updatedConfig['timeLimit'] = limit;
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'AI Difficulty',
                  border: OutlineInputBorder(),
                ),
                value: aiDifficulty,
                onChanged: (value) {
                  if (value != null) {
                    final updatedConfig =
                        Map<String, dynamic>.from(controller.gameConfig.value);
                    updatedConfig['aiDifficulty'] = value;
                    controller.gameConfig.value = updatedConfig;
                  }
                },
                items: const [
                  DropdownMenuItem(value: 'easy', child: Text('Easy')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'hard', child: Text('Hard')),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSudokuConfig(
    AdminController controller,
    Map<String, dynamic> gameConfig,
    Map<String, dynamic> defaultConfigs,
  ) {
    final difficulties = ['easy', 'medium', 'hard', 'expert'];
    final gridSizes = ['4x4', '9x9', '16x16'];

    // Get values with defaults
    final activeDifficulties = List<String>.from(
        gameConfig['activeDifficulties'] ??
            defaultConfigs['activeDifficulties']);
    final activeGridSizes = List<String>.from(
        gameConfig['activeGridSizes'] ?? defaultConfigs['activeGridSizes']);
    final completionReward =
        gameConfig['completionReward'] ?? defaultConfigs['completionReward'];
    final enableHints =
        gameConfig['enableHints'] ?? defaultConfigs['enableHints'];
    final hintsLimit = gameConfig['hintsLimit'] ?? defaultConfigs['hintsLimit'];

    // Controllers for editable fields
    final completionRewardController =
        TextEditingController(text: completionReward.toString());
    final hintsLimitController =
        TextEditingController(text: hintsLimit.toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Difficulties',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: difficulties.map((diff) {
            final isActive = activeDifficulties.contains(diff);
            return FilterChip(
              label: Text(diff.capitalize!),
              selected: isActive,
              onSelected: (selected) {
                if (selected) {
                  activeDifficulties.add(diff);
                } else {
                  if (activeDifficulties.length > 1) {
                    activeDifficulties.remove(diff);
                  } else {
                    Get.snackbar(
                      'Error',
                      'At least one difficulty must be active',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                }

                final updatedConfig =
                    Map<String, dynamic>.from(controller.gameConfig.value);
                updatedConfig['activeDifficulties'] = activeDifficulties;
                controller.gameConfig.value = updatedConfig;
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text(
          'Active Grid Sizes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: gridSizes.map((size) {
            final isActive = activeGridSizes.contains(size);
            return FilterChip(
              label: Text(size),
              selected: isActive,
              onSelected: (selected) {
                if (selected) {
                  activeGridSizes.add(size);
                } else {
                  if (activeGridSizes.length > 1) {
                    activeGridSizes.remove(size);
                  } else {
                    Get.snackbar(
                      'Error',
                      'At least one grid size must be active',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                }

                final updatedConfig =
                    Map<String, dynamic>.from(controller.gameConfig.value);
                updatedConfig['activeGridSizes'] = activeGridSizes;
                controller.gameConfig.value = updatedConfig;
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: completionRewardController,
                decoration: const InputDecoration(
                  labelText: 'Completion Reward (Coins)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final reward = int.tryParse(value) ?? completionReward;
                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  updatedConfig['completionReward'] = reward;
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SwitchListTile(
                title: const Text('Enable Hints'),
                value: enableHints,
                onChanged: (value) {
                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  updatedConfig['enableHints'] = value;
                  controller.gameConfig.value = updatedConfig;
                },
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          final isHintsEnabled =
              controller.gameConfig.value['enableHints'] ?? enableHints;
          return TextField(
            controller: hintsLimitController,
            decoration: const InputDecoration(
              labelText: 'Hints Limit per Game',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            enabled: isHintsEnabled,
            onChanged: (value) {
              final limit = int.tryParse(value) ?? hintsLimit;
              final updatedConfig =
                  Map<String, dynamic>.from(controller.gameConfig.value);
              updatedConfig['hintsLimit'] = limit;
              controller.gameConfig.value = updatedConfig;
            },
          );
        }),
      ],
    );
  }

  Widget _buildMinesweeperConfig(
    AdminController controller,
    Map<String, dynamic> gameConfig,
    Map<String, dynamic> defaultConfigs,
  ) {
    final boardSizes = ['8x8', '16x16', '32x32'];

    // Get values with defaults
    final activeBoardSizes = List<String>.from(
        gameConfig['activeBoardSizes'] ?? defaultConfigs['activeBoardSizes']);
    final completionReward =
        gameConfig['completionReward'] ?? defaultConfigs['completionReward'];
    final minesPercentage =
        gameConfig['minesPercentage'] ?? defaultConfigs['minesPercentage'];
    final enableFirstClickSafety = gameConfig['enableFirstClickSafety'] ??
        defaultConfigs['enableFirstClickSafety'];

    // Controllers for editable fields
    final completionRewardController =
        TextEditingController(text: completionReward.toString());
    final minesPercentageController =
        TextEditingController(text: minesPercentage.toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Board Sizes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: boardSizes.map((size) {
            final isActive = activeBoardSizes.contains(size);
            return FilterChip(
              label: Text(size),
              selected: isActive,
              onSelected: (selected) {
                if (selected) {
                  activeBoardSizes.add(size);
                } else {
                  if (activeBoardSizes.length > 1) {
                    activeBoardSizes.remove(size);
                  } else {
                    Get.snackbar(
                      'Error',
                      'At least one board size must be active',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                }

                final updatedConfig =
                    Map<String, dynamic>.from(controller.gameConfig.value);
                updatedConfig['activeBoardSizes'] = activeBoardSizes;
                controller.gameConfig.value = updatedConfig;
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: completionRewardController,
                decoration: const InputDecoration(
                  labelText: 'Completion Reward (Coins)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final reward = int.tryParse(value) ?? completionReward;
                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  updatedConfig['completionReward'] = reward;
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: minesPercentageController,
                decoration: const InputDecoration(
                  labelText: 'Mines Percentage (1-40)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  var percentage = int.tryParse(value) ?? minesPercentage;
                  if (percentage < 1) percentage = 1;
                  if (percentage > 40) percentage = 40;

                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  updatedConfig['minesPercentage'] = percentage;
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Enable First Click Safety'),
          subtitle: const Text('First click will never be a mine'),
          value: enableFirstClickSafety,
          onChanged: (value) {
            final updatedConfig =
                Map<String, dynamic>.from(controller.gameConfig.value);
            updatedConfig['enableFirstClickSafety'] = value;
            controller.gameConfig.value = updatedConfig;
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildMatch3Config(
    AdminController controller,
    Map<String, dynamic> gameConfig,
    Map<String, dynamic> defaultConfigs,
  ) {
    // Get values with defaults
    final boardSizes = List<String>.from(
        gameConfig['boardSizes'] ?? defaultConfigs['boardSizes']);
    final maxMoves = gameConfig['maxMoves'] ?? defaultConfigs['maxMoves'];

    final Map<String, dynamic> defaultTargetScores = {
      'easy': 1000,
      'medium': 2000,
      'hard': 3000,
    };

    final targetScores = Map<String, int>.from(
        gameConfig['targetScores'] ?? defaultTargetScores);

    final List<int> defaultRewards = [5, 10, 15];
    final rewardsPerStar =
        List<int>.from(gameConfig['rewardsPerStar'] ?? defaultRewards);

    // Controllers for editable fields
    final maxMovesController = TextEditingController(text: maxMoves.toString());
    final easyScoreController =
        TextEditingController(text: targetScores['easy'].toString());
    final mediumScoreController =
        TextEditingController(text: targetScores['medium'].toString());
    final hardScoreController =
        TextEditingController(text: targetScores['hard'].toString());
    final star1RewardController =
        TextEditingController(text: rewardsPerStar[0].toString());
    final star2RewardController =
        TextEditingController(text: rewardsPerStar[1].toString());
    final star3RewardController =
        TextEditingController(text: rewardsPerStar[2].toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Game Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: maxMovesController,
          decoration: const InputDecoration(
            labelText: 'Max Moves per Game',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final moves = int.tryParse(value) ?? maxMoves;
            final updatedConfig =
                Map<String, dynamic>.from(controller.gameConfig.value);
            updatedConfig['maxMoves'] = moves;
            controller.gameConfig.value = updatedConfig;
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Target Scores by Difficulty',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: easyScoreController,
                decoration: const InputDecoration(
                  labelText: 'Easy Score',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final score = int.tryParse(value) ?? targetScores['easy'];

                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  if (updatedConfig['targetScores'] == null) {
                    updatedConfig['targetScores'] =
                        Map<String, int>.from(targetScores);
                  }
                  (updatedConfig['targetScores']
                      as Map<String, dynamic>)['easy'] = score;
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: mediumScoreController,
                decoration: const InputDecoration(
                  labelText: 'Medium Score',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final score = int.tryParse(value) ?? targetScores['medium'];

                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  if (updatedConfig['targetScores'] == null) {
                    updatedConfig['targetScores'] =
                        Map<String, int>.from(targetScores);
                  }
                  (updatedConfig['targetScores']
                      as Map<String, dynamic>)['medium'] = score;
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: hardScoreController,
                decoration: const InputDecoration(
                  labelText: 'Hard Score',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final score = int.tryParse(value) ?? targetScores['hard'];

                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  if (updatedConfig['targetScores'] == null) {
                    updatedConfig['targetScores'] =
                        Map<String, int>.from(targetScores);
                  }
                  (updatedConfig['targetScores']
                      as Map<String, dynamic>)['hard'] = score;
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Rewards per Star (Coins)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: star1RewardController,
                decoration: const InputDecoration(
                  labelText: '1 Star',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final reward = int.tryParse(value) ?? rewardsPerStar[0];

                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  if (updatedConfig['rewardsPerStar'] == null) {
                    updatedConfig['rewardsPerStar'] =
                        List<int>.from(rewardsPerStar);
                  }

                  final rewards = updatedConfig['rewardsPerStar'] as List;
                  if (rewards.isNotEmpty) {
                    rewards[0] = reward;
                  }
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: star2RewardController,
                decoration: const InputDecoration(
                  labelText: '2 Stars',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final reward = int.tryParse(value) ?? rewardsPerStar[1];

                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  if (updatedConfig['rewardsPerStar'] == null) {
                    updatedConfig['rewardsPerStar'] =
                        List<int>.from(rewardsPerStar);
                  }

                  final rewards = updatedConfig['rewardsPerStar'] as List;
                  if (rewards.length > 1) {
                    rewards[1] = reward;
                  }
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: star3RewardController,
                decoration: const InputDecoration(
                  labelText: '3 Stars',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final reward = int.tryParse(value) ?? rewardsPerStar[2];

                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  if (updatedConfig['rewardsPerStar'] == null) {
                    updatedConfig['rewardsPerStar'] =
                        List<int>.from(rewardsPerStar);
                  }

                  final rewards = updatedConfig['rewardsPerStar'] as List;
                  if (rewards.length > 2) {
                    rewards[2] = reward;
                  }
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _build2048Config(
    AdminController controller,
    Map<String, dynamic> gameConfig,
    Map<String, dynamic> defaultConfigs,
  ) {
    // Get values with defaults
    final gridSizes = List<String>.from(
        gameConfig['gridSizes'] ?? defaultConfigs['gridSizes']);
    final targetTiles = List<int>.from(
        gameConfig['targetTiles'] ?? defaultConfigs['targetTiles']);

    // Default rewards if not present
    final Map<String, int> defaultRewards = {
      '1024': 10,
      '2048': 25,
      '4096': 50,
      '8192': 100,
    };

    final rewardsPerTarget =
        Map<String, int>.from(gameConfig['rewardsPerTarget'] ?? defaultRewards);

    // Controllers for editable fields
    final r1024Controller =
        TextEditingController(text: rewardsPerTarget['1024'].toString());
    final r2048Controller =
        TextEditingController(text: rewardsPerTarget['2048'].toString());
    final r4096Controller =
        TextEditingController(text: rewardsPerTarget['4096'].toString());
    final r8192Controller =
        TextEditingController(text: rewardsPerTarget['8192'].toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Grid Sizes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ['4x4', '5x5', '6x6'].map((size) {
            final isActive = gridSizes.contains(size);
            return FilterChip(
              label: Text(size),
              selected: isActive,
              onSelected: (selected) {
                if (selected) {
                  gridSizes.add(size);
                } else {
                  if (gridSizes.length > 1) {
                    gridSizes.remove(size);
                  } else {
                    Get.snackbar(
                      'Error',
                      'At least one grid size must be active',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                }

                final updatedConfig =
                    Map<String, dynamic>.from(controller.gameConfig.value);
                updatedConfig['gridSizes'] = gridSizes;
                controller.gameConfig.value = updatedConfig;
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text(
          'Target Tiles',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [1024, 2048, 4096, 8192].map((tile) {
            final isActive = targetTiles.contains(tile);
            return FilterChip(
              label: Text(tile.toString()),
              selected: isActive,
              onSelected: (selected) {
                if (selected) {
                  targetTiles.add(tile);
                } else {
                  if (targetTiles.length > 1) {
                    targetTiles.remove(tile);
                  } else {
                    Get.snackbar(
                      'Error',
                      'At least one target tile must be active',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                }

                final updatedConfig =
                    Map<String, dynamic>.from(controller.gameConfig.value);
                updatedConfig['targetTiles'] = targetTiles;
                controller.gameConfig.value = updatedConfig;
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text(
          'Rewards per Target (Coins)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: r1024Controller,
                decoration: const InputDecoration(
                  labelText: '1024 Tile',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final reward =
                      int.tryParse(value) ?? rewardsPerTarget['1024'];

                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  if (updatedConfig['rewardsPerTarget'] == null) {
                    updatedConfig['rewardsPerTarget'] =
                        Map<String, int>.from(rewardsPerTarget);
                  }

                  (updatedConfig['rewardsPerTarget']
                      as Map<String, dynamic>)['1024'] = reward;
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: r2048Controller,
                decoration: const InputDecoration(
                  labelText: '2048 Tile',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final reward =
                      int.tryParse(value) ?? rewardsPerTarget['2048'];

                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  if (updatedConfig['rewardsPerTarget'] == null) {
                    updatedConfig['rewardsPerTarget'] =
                        Map<String, int>.from(rewardsPerTarget);
                  }

                  (updatedConfig['rewardsPerTarget']
                      as Map<String, dynamic>)['2048'] = reward;
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: r4096Controller,
                decoration: const InputDecoration(
                  labelText: '4096 Tile',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final reward =
                      int.tryParse(value) ?? rewardsPerTarget['4096'];

                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  if (updatedConfig['rewardsPerTarget'] == null) {
                    updatedConfig['rewardsPerTarget'] =
                        Map<String, int>.from(rewardsPerTarget);
                  }

                  (updatedConfig['rewardsPerTarget']
                      as Map<String, dynamic>)['4096'] = reward;
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: r8192Controller,
                decoration: const InputDecoration(
                  labelText: '8192 Tile',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final reward =
                      int.tryParse(value) ?? rewardsPerTarget['8192'];

                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  if (updatedConfig['rewardsPerTarget'] == null) {
                    updatedConfig['rewardsPerTarget'] =
                        Map<String, int>.from(rewardsPerTarget);
                  }

                  (updatedConfig['rewardsPerTarget']
                      as Map<String, dynamic>)['8192'] = reward;
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmoteConfigCard(AdminController controller, String gameId) {
    // Mock emote data
    final emotes = [
      {'id': 'emote1', 'name': 'Thumbs Up', 'free': true, 'price': 0},
      {'id': 'emote2', 'name': 'Good Game', 'free': true, 'price': 0},
      {'id': 'emote3', 'name': 'Happy', 'free': false, 'price': 50},
      {'id': 'emote4', 'name': 'Sad', 'free': false, 'price': 50},
      {'id': 'emote5', 'name': 'Angry', 'free': false, 'price': 100},
      {'id': 'emote6', 'name': 'Surprised', 'free': false, 'price': 100},
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Game Emotes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Configure available emotes and pricing',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: emotes.length,
              itemBuilder: (context, index) {
                final emote = emotes[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text((emote['name'] as String)[0]),
                  ),
                  title: Text(emote['name'] as String),
                  subtitle: Text(
                    emote['free'] as bool ? 'Free' : '${emote['price']} coins',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: true, // All emotes enabled by default
                        onChanged: (enabled) {
                          // Update emote availability
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // Show edit dialog
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Show add emote dialog
                },
                icon: const Icon(Icons.add),
                label: const Text('Add New Emote'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab(AdminController controller) {
    return Obx(() {
      final gameId = controller.selectedGame.value;
      final leaderboard = controller.gameLeaderboards[gameId] ?? [];

      if (leaderboard.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.leaderboard,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'No leaderboard data available',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => controller.fetchGameLeaderboard(gameId),
                child: const Text('Refresh Leaderboard'),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchGameLeaderboard(gameId),
        child: ListView.builder(
          itemCount: leaderboard.length + 1, // +1 for the header
          itemBuilder: (context, index) {
            if (index == 0) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    SizedBox(
                        width: 50,
                        child: Text('Rank',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 16),
                    Expanded(
                        child: Text('Player',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(
                        width: 80,
                        child: Text('Score',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(
                        width: 80,
                        child: Text('Games',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 40),
                  ],
                ),
              );
            }

            final entryIndex = index - 1;
            final entry = leaderboard[entryIndex];
            final userData = entry['user'] as Map<String, dynamic>?;

            return ListTile(
              leading: SizedBox(
                width: 50,
                child: Row(
                  children: [
                    Text(
                      '${entryIndex + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getRankColor(entryIndex),
                      ),
                    ),
                    if (entryIndex < 3)
                      Icon(
                        Icons.emoji_events,
                        color: _getRankColor(entryIndex),
                        size: 16,
                      ),
                  ],
                ),
              ),
              title: Row(
                children: [
                  AvatarUserWidget(
                    radius: 20,
                    imagePath: userData?['image'] ?? '',
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(userData?['name'] ?? 'Unknown')),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      '${entry['score']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text('${entry['gamesPlayed'] ?? 0}'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      // Show options menu
                      _showLeaderboardEntryOptions(entry, controller);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 0:
        return Colors.amber; // Gold
      case 1:
        return Colors.grey.shade400; // Silver
      case 2:
        return Colors.brown.shade300; // Bronze
      default:
        return Colors.black; // Regular
    }
  }

  void _showLeaderboardEntryOptions(
      Map<String, dynamic> entry, AdminController controller) {
    Get.dialog(
      SimpleDialog(
        title: Text('Manage ${entry['user']?['name'] ?? 'Player'}'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Get.back();
              _showUserDetailsDialog(entry['user'], controller);
            },
            child: const Text('View Player Details'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Get.back();
              _confirmResetScoreDialog(entry, controller);
            },
            child: const Text('Reset Score'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Get.back();
              _confirmRemoveEntryDialog(entry, controller);
            },
            child: const Text('Remove from Leaderboard'),
          ),
        ],
      ),
    );
  }

  void _showUserDetailsDialog(
      Map<String, dynamic>? userData, AdminController controller) {
    if (userData == null) return;

    // Here you would fetch detailed user data
    // For now, show what we have
    Get.dialog(
      AlertDialog(
        title: Text(userData['name'] ?? 'Unknown Player'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AvatarUserWidget(
              radius: 40,
              imagePath: userData['image'] ?? '',
            ),
            const SizedBox(height: 16),
            Text('ID: ${userData['id'] ?? 'Unknown'}'),
            Text('Role: ${userData['role'] ?? 'user'}'),
            // Additional details would be fetched and shown here
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  void _confirmResetScoreDialog(
      Map<String, dynamic> entry, AdminController controller) {
    final gameId = controller.selectedGame.value;
    final entryId = entry['id'];
    final userName = entry['user']?['name'] ?? 'this player';

    Get.dialog(
      AlertDialog(
        title: const Text('Reset Score'),
        content:
            Text('Are you sure you want to reset the score for $userName?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              // Implement reset score logic
              Get.back();

              // Mock implementation
              Get.snackbar(
                'Score Reset',
                'Score for $userName has been reset',
                snackPosition: SnackPosition.BOTTOM,
              );

              // Refresh leaderboard
              controller.fetchGameLeaderboard(gameId);
            },
            child: const Text('RESET'),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveEntryDialog(
      Map<String, dynamic> entry, AdminController controller) {
    final gameId = controller.selectedGame.value;
    final entryId = entry['id'];
    final userName = entry['user']?['name'] ?? 'this player';

    Get.dialog(
      AlertDialog(
        title: const Text('Remove from Leaderboard'),
        content: Text(
            'Are you sure you want to remove $userName from the leaderboard?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              // Implement remove entry logic
              Get.back();

              // Mock implementation
              Get.snackbar(
                'Entry Removed',
                '$userName has been removed from the leaderboard',
                snackPosition: SnackPosition.BOTTOM,
              );

              // Refresh leaderboard
              controller.fetchGameLeaderboard(gameId);
            },
            child: const Text('REMOVE'),
          ),
        ],
      ),
    );
  }

  Widget _buildGameStatsTab(AdminController controller) {
    // Mock data for game stats
    final stats = {
      'totalGamesPlayed': 12500,
      'activeUsers': 1850,
      'avgGameDuration': '4m 30s',
      'completionRate': 68.5,
    };

    // Mock data for daily game plays
    final dailyPlays = [
      {'day': 'Mon', 'plays': 1250},
      {'day': 'Tue', 'plays': 1450},
      {'day': 'Wed', 'plays': 1350},
      {'day': 'Thu', 'plays': 1650},
      {'day': 'Fri', 'plays': 1850},
      {'day': 'Sat', 'plays': 2250},
      {'day': 'Sun', 'plays': 1950},
    ];

    return Obx(() {
      final gameId = controller.selectedGame.value;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${gameId.capitalize} Statistics',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatsOverviewCard(stats),
            const SizedBox(height: 24),
            _buildDailyPlaysChart(dailyPlays),
            const SizedBox(height: 24),
            _buildDeviceStats(),
            const SizedBox(height: 24),
            _buildDifficultyStats(),
          ],
        ),
      );
    });
  }

  Widget _buildStatsOverviewCard(Map<String, dynamic> stats) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total Games',
                  stats['totalGamesPlayed'].toString(),
                  Icons.sports_esports,
                  Colors.blue,
                ),
                _buildStatItem(
                  'Active Users',
                  stats['activeUsers'].toString(),
                  Icons.people,
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Avg. Duration',
                  stats['avgGameDuration'],
                  Icons.timer,
                  Colors.orange,
                ),
                _buildStatItem(
                  'Completion Rate',
                  '${stats['completionRate']}%',
                  Icons.check_circle,
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDailyPlaysChart(List<Map<String, dynamic>> dailyPlays) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Game Plays',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: Placeholder(
                color: Colors.deepPurpleAccent.withOpacity(0.5),
                child: const Center(
                  child: Text(
                    'Daily Plays Chart\n(Bar Chart from fl_chart would be here)',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceStats() {
    // Mock device stats
    final deviceStats = [
      {'device': 'Android', 'percentage': 65},
      {'device': 'iOS', 'percentage': 35},
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Device Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 180,
                    child: Placeholder(
                      color: Colors.deepPurpleAccent.withOpacity(0.5),
                      child: const Center(
                        child: Text(
                          'Device Distribution Chart\n(Pie Chart would be here)',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: deviceStats.map((stat) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              color: stat['device'] == 'Android'
                                  ? Colors.green
                                  : Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Text(stat['device'] as String),
                            const Spacer(),
                            Text('${stat['percentage']}%'),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyStats() {
    // Mock difficulty stats
    final difficultyStats = [
      {'difficulty': 'Easy', 'percentage': 45},
      {'difficulty': 'Medium', 'percentage': 35},
      {'difficulty': 'Hard', 'percentage': 20},
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Difficulty Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: difficultyStats.map((stat) {
                final difficulty = stat['difficulty'] as String;
                final percentage = stat['percentage'] as int;

                Color color;
                switch (difficulty) {
                  case 'Easy':
                    color = Colors.green;
                    break;
                  case 'Medium':
                    color = Colors.orange;
                    break;
                  case 'Hard':
                    color = Colors.red;
                    break;
                  default:
                    color = Colors.grey;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(difficulty),
                          const Spacer(),
                          Text('$percentage%'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getDefaultGameConfig(String gameId) {
    switch (gameId) {
      case 'tictactoe':
        return {
          'activeBoardSizes': ['3x3', '4x4', '5x5'],
          'winReward': 10,
          'drawReward': 5,
          'timeLimit': 30,
          'aiDifficulty': 'medium',
        };
      case 'sudoku':
        return {
          'activeDifficulties': ['easy', 'medium', 'hard'],
          'activeGridSizes': ['9x9'],
          'completionReward': 20,
          'enableHints': true,
          'hintsLimit': 3,
        };
      case 'minesweeper':
        return {
          'activeBoardSizes': ['8x8', '16x16'],
          'completionReward': 15,
          'minesPercentage': 15,
          'enableFirstClickSafety': true,
        };
      case 'match3':
        return {
          'boardSizes': ['8x8'],
          'maxMoves': 30,
          'targetScores': {
            'easy': 1000,
            'medium': 2000,
            'hard': 3000,
          },
          'rewardsPerStar': [5, 10, 15],
        };
      case '2048':
        return {
          'gridSizes': ['4x4'],
          'targetTiles': [2048],
          'rewardsPerTarget': {
            '1024': 10,
            '2048': 25,
            '4096': 50,
            '8192': 100,
          },
        };
      default:
        return {};
    }
  }

  void _saveGameConfig(AdminController controller) {
    final gameId = controller.selectedGame.value;
    final config = controller.gameConfig.value;

    controller.updateGameConfig(gameId, config).then((success) {
      if (success) {
        Get.snackbar(
          'Success',
          'Game configuration saved successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to save game configuration',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    });
  }
}

```

---


### Pages\tabs\user_management_tab.dart

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';
import 'package:tictactoe_gameapp/Pages/Admin/controllers/admin_controller.dart';
import 'package:tictactoe_gameapp/Pages/Admin/models/user_model.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';

class UserManagementTab extends StatefulWidget {
  const UserManagementTab({super.key});

  @override
  State<UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends State<UserManagementTab> {
  final RxString searchQuery = ''.obs;
  final expandedIndex = (-1).obs;
  final TextEditingController searchEditingController = TextEditingController();

  @override
  void dispose() {
    searchQuery.close();
    expandedIndex.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();

    return Column(
      children: [
        _buildSearchBar(controller),
        _buildBatchOperationsBar(controller),
        Expanded(
          child: _buildUserList(controller),
        ),
      ],
    );
  }

  Widget _buildSearchBar(AdminController controller) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchEditingController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(() => searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchEditingController.clear();
                          FocusNode().unfocus();
                          searchQuery.value = '';
                          controller.userSearchQuery.value = '';
                        },
                      )
                    : const SizedBox()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                searchQuery.value = value.trim();
                controller.userSearchQuery.value = value.trim();
              },
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => DropdownButton<String>(
                value: controller.selectedRoleFilter.value,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(
                      value: 'moderator', child: Text('Moderator')),
                  DropdownMenuItem(value: 'user', child: Text('User')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedRoleFilter.value = value;
                  }
                },
              )),
        ],
      ),
    );
  }

  Widget _buildBatchOperationsBar(AdminController controller) {
    return Obx(() {
      if (controller.selectedUserIds.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.grey[200],
        child: Row(
          children: [
            Text(
              '${controller.selectedUserIds.length} users selected',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'clear') {
                  controller.clearUserSelection();
                } else {
                  _confirmBatchOperation(
                    controller,
                    value,
                    controller.selectedUserIds.length,
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'verify',
                  child: Text('Verify Selected'),
                ),
                const PopupMenuItem(
                  value: 'suspend',
                  child: Text('Suspend Selected'),
                ),
                const PopupMenuItem(
                  value: 'activate',
                  child: Text('Activate Selected'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete Selected'),
                ),
                const PopupMenuItem(
                  value: 'clear',
                  child: Text('Clear Selection'),
                ),
              ],
              child: Chip(
                label: const Text('Actions'),
                avatar: const Icon(Icons.more_vert),
                backgroundColor: Colors.deepPurpleAccent.withOpacity(0.2),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildUserList(AdminController controller) {
    return Obx(() {
      if (controller.isLoadingUsers.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.users.isEmpty) {
        return const Center(
          child: Text('No users found'),
        );
      }

      // Lọc danh sách người dùng theo từ khóa tìm kiếm
      var filteredUsers = controller.users.where((user) {
        if (searchQuery.value.isEmpty) {
          return true;
        }

        final query = searchQuery.value.toLowerCase();
        final name = user.name?.toLowerCase() ?? '';
        final email = user.email?.toLowerCase() ?? '';
        final id = user.id?.toLowerCase() ?? '';

        return name.contains(query) ||
            email.contains(query) ||
            id.contains(query);
      }).toList();

      // Áp dụng bộ lọc theo vai trò nếu được chọn
      if (controller.selectedRoleFilter.value != 'all') {
        filteredUsers = filteredUsers
            .where((user) => user.role == controller.selectedRoleFilter.value)
            .toList();
      }

      if (filteredUsers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No users found matching "${searchQuery.value}"',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  searchEditingController.clear();
                  FocusNode().unfocus();
                  searchQuery.value = '';
                  controller.userSearchQuery.value = '';
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear Search'),
              ),
            ],
          ),
        );
      }

      // Sắp xếp người dùng theo coins giảm dần
      filteredUsers.sort((a, b) {
        int totalCoinsA = int.tryParse(a.totalCoins ?? '0') ?? 0;
        int totalCoinsB = int.tryParse(b.totalCoins ?? '0') ?? 0;
        return totalCoinsB.compareTo(totalCoinsA);
      });

      return Scrollbar(
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            return _buildUserRankingItem(
                controller, filteredUsers[index], index);
          },
        ),
      );
    });
  }

  Widget _buildUserRankingItem(
      AdminController controller, UserModel user, int position) {
    final isSelected = controller.selectedUserIds.contains(user.id);

    return Obx(() => Column(
          children: [
            Container(
              margin:
                  const EdgeInsets.only(bottom: 10, left: 8, right: 8, top: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 2.0,
                    spreadRadius: 2.0,
                    color: Colors.white,
                  ),
                ],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ExpansionTile(
                onExpansionChanged: (bool expanded) {
                  if (expanded) {
                    expandedIndex.value = position;
                  } else if (expandedIndex.value == position) {
                    expandedIndex.value = -1;
                  }
                },
                iconColor: Colors.white,
                collapsedIconColor: Colors.pink,
                collapsedBackgroundColor: isSelected
                    ? Colors.purpleAccent.withOpacity(0.5)
                    : Colors.lightBlueAccent,
                backgroundColor: isSelected
                    ? Colors.purpleAccent.withOpacity(0.5)
                    : Colors.lightBlueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                leading: Badge(
                  label: Text("${position + 1}"),
                  textColor: position == 0
                      ? Colors.red
                      : position == 1
                          ? Colors.yellow
                          : position == 2
                              ? Colors.greenAccent
                              : Colors.white,
                  backgroundColor: Colors.black,
                  child: Column(
                    children: [
                      Image.asset(
                        position == 0
                            ? TrimRanking.challTrim
                            : position == 1
                                ? TrimRanking.masterTrim
                                : position == 2
                                    ? TrimRanking.diamondTrim
                                    : TrimRanking.goldTrim,
                        width: 45,
                      ),
                    ],
                  ),
                ),
                trailing: Column(
                  children: [
                    user.status == "online"
                        ? const Text(
                            "Online",
                            style: TextStyle(
                              color: Colors.lightGreenAccent,
                              fontSize: 15,
                            ),
                          )
                        : const Text(
                            "Offline",
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 15,
                            ),
                          ),
                    Icon(
                      expandedIndex.value == position
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                  ],
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showUserDetailsDialog(user);
                          },
                          onLongPress: () {
                            if (user.id != null) {
                              controller.toggleUserSelection(user.id!);
                            }
                          },
                          child: Stack(
                            children: [
                              user.image != null && user.image!.isNotEmpty
                                  ? CircleAvatar(
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                              user.image!),
                                      radius: 25,
                                    )
                                  : const CircleAvatar(
                                      radius: 25,
                                      child: Icon(Icons.person_2_outlined),
                                    ),
                              if (isSelected)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.deepPurpleAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name ?? 'Unknown',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: user.suspended == true
                                    ? Colors.grey
                                    : Colors.deepPurple,
                                fontSize: 15,
                                decoration: user.suspended == true
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                            ),
                            Row(
                              children: [
                                Text(
                                  user.totalCoins ?? "0",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.yellowAccent,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                SvgPicture.asset(
                                  IconsPath.coinIcon,
                                  width: 20,
                                  color: Colors.yellowAccent,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Chip(
                          label: Text(user.role ?? 'user'),
                          backgroundColor: _getRoleColor(user.role),
                          labelStyle: const TextStyle(
                              fontSize: 10, color: Colors.white),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        const SizedBox(width: 4),
                        if (user.verified == true)
                          const Icon(Icons.verified,
                              size: 16, color: Colors.blue),
                        if (user.suspended == true)
                          const Icon(Icons.block, size: 16, color: Colors.red),
                      ],
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Email: ${user.email ?? "${user.name}@gmail.com"}",
                          maxLines: 2,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        if (user.bio != null && user.bio!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Bio: ${user.bio}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit Role'),
                              onPressed: () {
                                _showEditRoleDialog(user, controller);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              icon: Icon(user.suspended == true
                                  ? Icons.check_circle
                                  : Icons.block),
                              label: Text(user.suspended == true
                                  ? 'Activate'
                                  : 'Suspend'),
                              onPressed: () {
                                if (user.suspended == true) {
                                  _confirmActivateUser(user, controller);
                                } else {
                                  _confirmSuspendUser(user, controller);
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: user.suspended == true
                                    ? Colors.green
                                    : Colors.red,
                                side: BorderSide(
                                    color: user.suspended == true
                                        ? Colors.green
                                        : Colors.red),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text('Delete'),
                              onPressed: () {
                                _confirmDeleteUser(user, controller);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'moderator':
        return Colors.green;
      case 'user':
      default:
        return Colors.blue;
    }
  }

  void _showUserDetailsDialog(UserModel user) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    AvatarUserWidget(
                      radius: 50,
                      imagePath: user.image ?? '',
                      gradientColors: user.avatarFrame,
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: user.status == "online"
                            ? Colors.green
                            : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      width: 20,
                      height: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  user.name ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              Center(
                child: Text(
                  user.email ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: Text(user.role ?? 'user'),
                      backgroundColor: _getRoleColor(user.role),
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    if (user.verified == true)
                      const Chip(
                        label: Text('Verified'),
                        avatar:
                            Icon(Icons.verified, color: Colors.blue, size: 18),
                        backgroundColor: Color(0xFFE3F2FD),
                      ),
                    if (user.suspended == true)
                      const Chip(
                        label: Text('Suspended'),
                        avatar: Icon(Icons.block, color: Colors.red, size: 18),
                        backgroundColor: Color(0xFFFFEBEE),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _userStatItem(
                      'Coins', user.totalCoins ?? '0', Icons.monetization_on),
                  _userStatItem(
                      'Wins', user.totalWins ?? '0', Icons.emoji_events),
                  _userStatItem('Friends', '${user.friendsList?.length ?? 0}',
                      Icons.people),
                ],
              ),
              const SizedBox(height: 16),
              if (user.bio != null && user.bio!.isNotEmpty) ...[
                const Text(
                  'Bio',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(user.bio!),
                const SizedBox(height: 16),
              ],
              const Divider(),
              const SizedBox(height: 8),
              _detailRow('User ID', user.id ?? ''),
              _detailRow('Status', user.status ?? 'Offline'),
              _detailRow(
                  'Joined',
                  user.createdAt?.toDate().toString().split(' ')[0] ??
                      'Unknown'),
              _detailRow('Last Active',
                  user.lastActive?.toDate().toString() ?? 'Unknown'),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('CLOSE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepPurpleAccent, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showEditRoleDialog(UserModel user, AdminController controller) {
    final currentRole = user.role ?? 'user';
    var selectedRole = currentRole;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AvatarUserWidget(
                    radius: 25,
                    imagePath: user.image ?? '',
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Edit User Role',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('User: ${user.name ?? "Unknown"}'),
                        Text('Current Role: $currentRole',
                            style:
                                TextStyle(color: _getRoleColor(currentRole))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      RadioListTile<String>(
                        title: const Text('User'),
                        value: 'user',
                        groupValue: selectedRole,
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value!;
                          });
                        },
                        activeColor: Colors.blue,
                      ),
                      RadioListTile<String>(
                        title: const Text('Moderator'),
                        value: 'moderator',
                        groupValue: selectedRole,
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value!;
                          });
                        },
                        activeColor: Colors.green,
                      ),
                      RadioListTile<String>(
                        title: const Text('Admin'),
                        value: 'admin',
                        groupValue: selectedRole,
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value!;
                          });
                        },
                        activeColor: Colors.red,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedRole != currentRole && user.id != null) {
                        controller
                            .updateUserRole(user.id!, selectedRole)
                            .then((success) {
                          if (success) {
                            Get.back();
                            successMessage('User role updated successfully!');
                          }
                        });
                      } else {
                        Get.back();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                    child: const Text('SAVE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmSuspendUser(UserModel user, AdminController controller) {
    if (user.id == null) return;

    Get.dialog(
      AlertDialog(
        title: const Text('Suspend User'),
        content: Text(
            'Are you sure you want to suspend ${user.name}? This will prevent them from accessing the app.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              // Add the user ID to selected list
              controller.selectedUserIds.clear();
              controller.selectedUserIds.add(user.id!);

              controller.performBatchOperation('suspend').then((success) {
                if (success) {
                  Get.back();
                  successMessage('User suspended successfully!');
                }
              });
            },
            child: const Text('SUSPEND'),
          ),
        ],
      ),
    );
  }

  void _confirmActivateUser(UserModel user, AdminController controller) {
    if (user.id == null) return;

    Get.dialog(
      AlertDialog(
        title: const Text('Activate User'),
        content: Text(
            'Are you sure you want to activate ${user.name}? This will restore their access to the app.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: () {
              // Add the user ID to selected list
              controller.selectedUserIds.clear();
              controller.selectedUserIds.add(user.id!);

              controller.performBatchOperation('activate').then((success) {
                if (success) {
                  Get.back();
                  successMessage('User activated successfully!');
                }
              });
            },
            child: const Text('ACTIVATE'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteUser(UserModel user, AdminController controller) {
    if (user.id == null) return;

    Get.dialog(
      AlertDialog(
        title: const Text('Delete User'),
        content: Text(
            'Are you sure you want to permanently delete ${user.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              // Add the user ID to selected list
              controller.selectedUserIds.clear();
              controller.selectedUserIds.add(user.id!);

              controller.performBatchOperation('delete').then((success) {
                if (success) {
                  Get.back();
                  successMessage('User deleted successfully!');
                }
              });
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  void _confirmBatchOperation(
      AdminController controller, String operation, int count) {
    String title;
    String content;
    String action;
    Color actionColor = Colors.blue;

    switch (operation) {
      case 'verify':
        title = 'Verify Users';
        content = 'Are you sure you want to verify $count users?';
        action = 'VERIFY';
        break;
      case 'suspend':
        title = 'Suspend Users';
        content =
            'Are you sure you want to suspend $count users? This will prevent them from accessing the app.';
        action = 'SUSPEND';
        actionColor = Colors.red;
        break;
      case 'activate':
        title = 'Activate Users';
        content =
            'Are you sure you want to activate $count users? This will restore their access to the app.';
        action = 'ACTIVATE';
        break;
      case 'delete':
        title = 'Delete Users';
        content =
            'Are you sure you want to permanently delete $count users? This action cannot be undone.';
        action = 'DELETE';
        actionColor = Colors.red;
        break;
      default:
        return;
    }

    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: actionColor,
            ),
            onPressed: () {
              controller.performBatchOperation(operation).then((success) {
                if (success) {
                  Get.back();
                  successMessage('Operation completed successfully!');
                }
              });
            },
            child: Text(action),
          ),
        ],
      ),
    );
  }
}

```

---


### Pages\tabs\user_support_system_tab.dart

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tictactoe_gameapp/Pages/Admin/controllers/support_system_controller.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';

class SupportSystemPage extends StatelessWidget {
  const SupportSystemPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SupportSystemController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Support System'),
        backgroundColor: Colors.deepPurpleAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => controller.refreshData(),
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            tooltip: 'Support Analytics',
            onPressed: () => _showSupportAnalytics(controller),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => _showSupportSettings(controller),
          ),
        ],
      ),
      body: Row(
        children: [
          // Left sidebar - Ticket list
          Container(
            width: 320,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(1, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSearchAndFilter(controller),
                Expanded(
                  child: _buildTicketList(controller),
                ),
              ],
            ),
          ),

          // Main content area
          Expanded(
            child: Obx(() {
              if (controller.selectedTicketId.isEmpty) {
                return _buildNoTicketSelectedView();
              } else {
                return _buildTicketDetailView(controller);
              }
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateKnowledgeBaseArticleDialog(controller),
        backgroundColor: Colors.deepPurpleAccent,
        child: const Icon(Icons.add),
        tooltip: 'Add Knowledge Base Article',
      ),
    );
  }

  Widget _buildSearchAndFilter(SupportSystemController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller.searchController,
            decoration: InputDecoration(
              hintText: 'Search tickets...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.searchController.clear();
                        controller.searchQuery.value = '';
                      },
                    )
                  : const SizedBox()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) {
              controller.searchQuery.value = value.trim();
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildFilterChip(
                label: 'All',
                selected: controller.selectedStatusFilter.value == 'all',
                onSelected: (selected) {
                  if (selected) controller.selectedStatusFilter.value = 'all';
                },
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Open',
                selected: controller.selectedStatusFilter.value == 'open',
                onSelected: (selected) {
                  if (selected) controller.selectedStatusFilter.value = 'open';
                },
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Resolved',
                selected: controller.selectedStatusFilter.value == 'resolved',
                onSelected: (selected) {
                  if (selected) {
                    controller.selectedStatusFilter.value = 'resolved';
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildFilterChip(
                label: 'High',
                selected: controller.selectedPriorityFilter.value == 'high',
                onSelected: (selected) {
                  if (selected) {
                    controller.selectedPriorityFilter.value = 'high';
                  }
                },
                color: Colors.red,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Medium',
                selected: controller.selectedPriorityFilter.value == 'medium',
                onSelected: (selected) {
                  if (selected) {
                    controller.selectedPriorityFilter.value = 'medium';
                  }
                },
                color: Colors.orange,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Low',
                selected: controller.selectedPriorityFilter.value == 'low',
                onSelected: (selected) {
                  if (selected) controller.selectedPriorityFilter.value = 'low';
                },
                color: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sort by:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: controller.sortCriteria.value,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: 'date', child: Text('Date')),
                  DropdownMenuItem(value: 'priority', child: Text('Priority')),
                  DropdownMenuItem(value: 'status', child: Text('Status')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    controller.sortCriteria.value = value;
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTicketList(SupportSystemController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final filteredTickets = controller.getFilteredTickets();

      if (filteredTickets.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                controller.searchQuery.value.isNotEmpty
                    ? 'No tickets match your search'
                    : 'No tickets found for the selected filters',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => controller.resetFilters(),
                icon: const Icon(Icons.refresh),
                label: const Text('Reset Filters'),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        itemCount: filteredTickets.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final ticket = filteredTickets[index];
          return _buildTicketListItem(ticket, controller);
        },
      );
    });
  }

  Widget _buildTicketListItem(
      Map<String, dynamic> ticket, SupportSystemController controller) {
    final ticketId = ticket['id'] as String;
    final subject = ticket['subject'] as String;
    final userId = ticket['userId'] as String;
    final userName = ticket['userName'] as String;
    final userImage = ticket['userImage'] as String?;
    final status = ticket['status'] as String;
    final priority = ticket['priority'] as String;
    final category = ticket['category'] as String;
    final createdAt = ticket['createdAt'] as DateTime;
    final lastUpdated = ticket['lastUpdated'] as DateTime;
    final hasNewMessage = ticket['hasNewMessage'] as bool? ?? false;

    final isSelected = controller.selectedTicketId.value == ticketId;

    Color priorityColor;
    switch (priority) {
      case 'high':
        priorityColor = Colors.red;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.blue;
    }

    Color statusColor;
    switch (status) {
      case 'open':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'resolved':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.grey;
    }

    return InkWell(
      onTap: () => controller.selectTicket(ticketId),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: isSelected ? Colors.deepPurpleAccent.withOpacity(0.1) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (hasNewMessage)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(
                      color: Colors.deepPurpleAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    priority.capitalize!,
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.capitalize!,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _timeAgo(lastUpdated),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subject,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Category: $category',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: AvatarUserWidget(
                    radius: 10,
                    imagePath: userImage ?? '',
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
                const Spacer(),
                Text(
                  '#${ticketId.substring(0, 8)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoTicketSelectedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.support_agent, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Select a ticket to view details',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Or search for a specific ticket using the sidebar filters',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketDetailView(SupportSystemController controller) {
    final ticket = controller.getSelectedTicket();

    if (ticket == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final ticketId = ticket['id'] as String;
    final subject = ticket['subject'] as String;
    final description = ticket['description'] as String;
    final userId = ticket['userId'] as String;
    final userName = ticket['userName'] as String;
    final userEmail = ticket['userEmail'] as String;
    final userImage = ticket['userImage'] as String?;
    final status = ticket['status'] as String;
    final priority = ticket['priority'] as String;
    final category = ticket['category'] as String;
    final assignedTo = ticket['assignedTo'] as String?;
    final createdAt = ticket['createdAt'] as DateTime;
    final messages = ticket['messages'] as List<dynamic>? ?? [];

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ticket #${ticketId.substring(0, 8)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subject,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildTicketPropertyPill(
                          label: status.capitalize!,
                          color: _getStatusColor(status),
                        ),
                        const SizedBox(width: 8),
                        _buildTicketPropertyPill(
                          label: priority.capitalize!,
                          color: _getPriorityColor(priority),
                        ),
                        const SizedBox(width: 8),
                        _buildTicketPropertyPill(
                          label: category,
                          color: Colors.deepPurpleAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildTicketActions(ticket, controller),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - User info and ticket details
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserCard(
                      userName: userName,
                      userEmail: userEmail,
                      userImage: userImage,
                      userId: userId,
                    ),
                    const SizedBox(height: 16),
                    _buildTicketInfoCard(
                      createdAt: createdAt,
                      assignedTo: assignedTo,
                      controller: controller,
                      ticket: ticket,
                    ),
                    const SizedBox(height: 16),
                    _buildRelatedArticlesCard(controller, category),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Right side - Conversation thread
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Conversation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // First message (description)
                    _buildMessageBubble(
                      sender: userName,
                      senderImage: userImage,
                      message: description,
                      timestamp: createdAt,
                      isUser: true,
                    ),
                    const SizedBox(height: 16),
                    // Other messages
                    Expanded(
                      child: messages.isEmpty
                          ? Center(
                              child: Text(
                                'No replies yet',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            )
                          : ListView.builder(
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message =
                                    messages[index] as Map<String, dynamic>;
                                final sender = message['sender'] as String;
                                final senderImage =
                                    message['senderImage'] as String?;
                                final content = message['content'] as String;
                                final timestamp =
                                    message['timestamp'] as DateTime;
                                final isUserMessage =
                                    message['isUser'] as bool? ?? false;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildMessageBubble(
                                    sender: sender,
                                    senderImage: senderImage,
                                    message: content,
                                    timestamp: timestamp,
                                    isUser: isUserMessage,
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 16),
                    // Reply form
                    if (status != 'resolved')
                      _buildReplyForm(controller, ticketId),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTicketPropertyPill(
      {required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTicketActions(
      Map<String, dynamic> ticket, SupportSystemController controller) {
    final status = ticket['status'] as String;
    final ticketId = ticket['id'] as String;

    return Row(
      children: [
        if (status == 'open' || status == 'pending')
          OutlinedButton.icon(
            onPressed: () => _showResolveTicketDialog(ticket, controller),
            icon: const Icon(Icons.check_circle),
            label: const Text('Resolve'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
            ),
          ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () => _showAssignTicketDialog(ticket, controller),
          icon: const Icon(Icons.person_add),
          label: const Text('Assign'),
        ),
        const SizedBox(width: 8),
        PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'changePriority',
              child: ListTile(
                leading: Icon(Icons.flag),
                title: Text('Change Priority'),
              ),
            ),
            const PopupMenuItem(
              value: 'changeCategory',
              child: ListTile(
                leading: Icon(Icons.category),
                title: Text('Change Category'),
              ),
            ),
            const PopupMenuItem(
              value: 'addNote',
              child: ListTile(
                leading: Icon(Icons.note_add),
                title: Text('Add Internal Note'),
              ),
            ),
            if (status == 'resolved')
              const PopupMenuItem(
                value: 'reopen',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Reopen Ticket'),
                ),
              ),
            const PopupMenuItem(
              value: 'merge',
              child: ListTile(
                leading: Icon(Icons.merge_type),
                title: Text('Merge with Another Ticket'),
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: ListTile(
                leading: Icon(Icons.download),
                title: Text('Export Ticket'),
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'changePriority':
                _showChangePriorityDialog(ticket, controller);
                break;
              case 'changeCategory':
                _showChangeCategoryDialog(ticket, controller);
                break;
              case 'addNote':
                _showAddNoteDialog(ticket, controller);
                break;
              case 'reopen':
                _showReopenTicketDialog(ticket, controller);
                break;
              case 'merge':
                _showMergeTicketDialog(ticket, controller);
                break;
              case 'export':
                _exportTicket(ticket);
                break;
            }
          },
        ),
      ],
    );
  }

  Widget _buildUserCard({
    required String userName,
    required String userEmail,
    required String? userImage,
    required String userId,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User Information',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              AvatarUserWidget(
                radius: 25,
                imagePath: userImage ?? '',
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      userEmail,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'User ID: ${userId.substring(0, 8)}...',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () => Get.toNamed('/admin/users/$userId'),
                icon: const Icon(Icons.person),
                label: const Text('View Profile'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  // Show user's previous tickets
                },
                icon: const Icon(Icons.history),
                label: const Text('View History'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTicketInfoCard({
    required DateTime createdAt,
    required String? assignedTo,
    required SupportSystemController controller,
    required Map<String, dynamic> ticket,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ticket Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            label: 'Created',
            value: DateFormat('MMM dd, yyyy - HH:mm').format(createdAt),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            label: 'Assigned To',
            value: assignedTo ?? 'Unassigned',
            valueColor:
                assignedTo != null ? Colors.deepPurpleAccent : Colors.grey,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            label: 'Device',
            value: ticket['deviceInfo'] as String? ?? 'Unknown',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            label: 'App Version',
            value: ticket['appVersion'] as String? ?? 'Unknown',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            label: 'Platform',
            value: ticket['platform'] as String? ?? 'Unknown',
          ),
          const SizedBox(height: 16),
          // Tags
          const Text(
            'Tags',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...(ticket['tags'] as List<dynamic>? ?? [])
                  .map((tag) => _buildTagChip(
                        tag: tag as String,
                        onDeleted: () {
                          // Remove tag
                          controller.removeTagFromTicket(
                              ticket['id'] as String, tag);
                        },
                      )),
              ActionChip(
                label: const Text('Add Tag'),
                avatar: const Icon(Icons.add, size: 16),
                onPressed: () => _showAddTagDialog(ticket, controller),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedArticlesCard(
      SupportSystemController controller, String category) {
    final articles = controller.getRelatedArticles(category);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Knowledge Base',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              TextButton(
                onPressed: () => _showKnowledgeBaseDialog(controller),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Related Articles',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          articles.isEmpty
              ? Text(
                  'No related articles found',
                  style: TextStyle(color: Colors.grey[600]),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: articles.length > 3 ? 3 : articles.length,
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.article),
                      title: Text(article['title'] as String),
                    );
                  },
                ),
          const SizedBox(height: 16),
          const Text(
            'Suggested Responses',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 2,
            itemBuilder: (context, index) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.quickreply),
                title: Text(
                  index == 0
                      ? 'Thank you for reporting this issue. We\'re looking into it.'
                      : 'This is a known issue and our team is working on a fix.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: OutlinedButton(
                  onPressed: () {
                    // Insert the template into the reply field
                    controller.replyController.text = index == 0
                        ? 'Thank you for reporting this issue. We\'re looking into it and will get back to you as soon as possible. In the meantime, please let us know if you have any other questions.'
                        : 'Thank you for bringing this to our attention. This is a known issue and our development team is actively working on a fix. We expect to release an update within the next few days that should resolve this problem. We appreciate your patience.';
                  },
                  child: const Text('Use'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String sender,
    required String? senderImage,
    required String message,
    required DateTime timestamp,
    required bool isUser,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isUser) ...[
          AvatarUserWidget(
            radius: 16,
            imagePath: senderImage ?? '',
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUser
                      ? Colors.grey[100]
                      : Colors.deepPurpleAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isUser
                        ? Colors.grey[300]!
                        : Colors.deepPurpleAccent.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sender,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isUser ? Colors.black : Colors.deepPurpleAccent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(message),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMM dd, yyyy - HH:mm').format(timestamp),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        if (isUser) ...[
          const SizedBox(width: 8),
          AvatarUserWidget(
            radius: 16,
            imagePath: senderImage ?? '',
          ),
        ],
      ],
    );
  }

  Widget _buildReplyForm(SupportSystemController controller, String ticketId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reply',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.replyController,
          decoration: const InputDecoration(
            hintText: 'Type your response here...',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                // Show template responses dialog
                _showTemplateResponsesDialog(controller);
              },
              icon: const Icon(Icons.format_quote),
              label: const Text('Templates'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () {
                // Show attachment dialog
                _showAttachmentDialog(controller);
              },
              icon: const Icon(Icons.attach_file),
              label: const Text('Add Attachment'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                if (controller.replyController.text.isEmpty) {
                  errorMessage('Please enter a response');
                  return;
                }

                controller
                    .sendReply(ticketId, controller.replyController.text)
                    .then((success) {
                  if (success) {
                    controller.replyController.clear();
                    successMessage('Reply sent successfully');
                  }
                });
              },
              icon: const Icon(Icons.send),
              label: const Text('Send Reply'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
    Color? color,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: (color ?? Colors.deepPurpleAccent).withOpacity(0.2),
      checkmarkColor: color ?? Colors.deepPurpleAccent,
      labelStyle: TextStyle(
        color: selected ? (color ?? Colors.deepPurpleAccent) : Colors.black,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTagChip({
    required String tag,
    required VoidCallback onDeleted,
  }) {
    return Chip(
      label: Text(tag),
      deleteIcon: const Icon(Icons.cancel, size: 16),
      onDeleted: onDeleted,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'resolved':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  void _showResolveTicketDialog(
      Map<String, dynamic> ticket, SupportSystemController controller) {
    final resolutionController = TextEditingController();
    final ticketId = ticket['id'] as String;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Resolve Ticket',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please provide a summary of the resolution for this ticket.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: resolutionController,
                decoration: const InputDecoration(
                  labelText: 'Resolution',
                  border: OutlineInputBorder(),
                  hintText: 'Explain how the issue was resolved...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Send resolution email to user'),
                value: true,
                onChanged: (_) {},
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (resolutionController.text.isEmpty) {
                        errorMessage('Please enter a resolution summary');
                        return;
                      }

                      controller
                          .resolveTicket(
                        ticketId,
                        resolutionController.text,
                      )
                          .then((success) {
                        if (success) {
                          Get.back();
                          successMessage('Ticket resolved successfully');
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('RESOLVE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAssignTicketDialog(
      Map<String, dynamic> ticket, SupportSystemController controller) {
    final ticketId = ticket['id'] as String;
    final RxString selectedAgentId = ''.obs;

    // Mock agent data
    final List<Map<String, dynamic>> agents = [
      {
        'id': 'agent1',
        'name': 'John Smith',
        'role': 'Support Agent',
        'image': '',
        'activeTickets': 5
      },
      {
        'id': 'agent2',
        'name': 'Jane Doe',
        'role': 'Senior Support',
        'image': '',
        'activeTickets': 3
      },
      {
        'id': 'agent3',
        'name': 'Mike Johnson',
        'role': 'Support Agent',
        'image': '',
        'activeTickets': 7
      },
      {
        'id': 'agent4',
        'name': 'Sarah Wilson',
        'role': 'Technical Support',
        'image': '',
        'activeTickets': 2
      },
    ];

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Assign Ticket',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select an agent to assign this ticket to:',
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: agents.length,
                  itemBuilder: (context, index) {
                    final agent = agents[index];
                    final agentId = agent['id'] as String;

                    return Obx(() => RadioListTile<String>(
                          title: Text(agent['name'] as String),
                          subtitle: Row(
                            children: [
                              Text(agent['role'] as String),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${agent['activeTickets']} active tickets',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          value: agentId,
                          groupValue: selectedAgentId.value,
                          onChanged: (value) {
                            selectedAgentId.value = value!;
                          },
                        ));
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      // Unassign ticket logic
                      controller.unassignTicket(ticketId).then((success) {
                        if (success) {
                          Get.back();
                          successMessage('Ticket unassigned successfully');
                        }
                      });
                    },
                    child: const Text('Unassign'),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('CANCEL'),
                      ),
                      const SizedBox(width: 8),
                      Obx(() => ElevatedButton(
                            onPressed: selectedAgentId.value.isEmpty
                                ? null
                                : () {
                                    controller
                                        .assignTicket(
                                      ticketId,
                                      selectedAgentId.value,
                                      agents.firstWhere((agent) =>
                                              agent['id'] ==
                                              selectedAgentId.value)['name']
                                          as String,
                                    )
                                        .then((success) {
                                      if (success) {
                                        Get.back();
                                        successMessage(
                                            'Ticket assigned successfully');
                                      }
                                    });
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurpleAccent,
                            ),
                            child: const Text('ASSIGN'),
                          )),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePriorityDialog(
      Map<String, dynamic> ticket, SupportSystemController controller) {
    final ticketId = ticket['id'] as String;
    final currentPriority = ticket['priority'] as String;
    RxString selectedPriority = currentPriority.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Change Priority',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select the new priority level for this ticket:',
              ),
              const SizedBox(height: 16),
              Obx(() => Column(
                    children: [
                      _buildPriorityOption(
                        label: 'High',
                        description: 'Critical issue affecting many users',
                        value: 'high',
                        groupValue: selectedPriority.value,
                        color: Colors.red,
                        onChanged: (value) {
                          selectedPriority.value = value!;
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildPriorityOption(
                        label: 'Medium',
                        description: 'Important issue with limited impact',
                        value: 'medium',
                        groupValue: selectedPriority.value,
                        color: Colors.orange,
                        onChanged: (value) {
                          selectedPriority.value = value!;
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildPriorityOption(
                        label: 'Low',
                        description: 'Minor issue or question',
                        value: 'low',
                        groupValue: selectedPriority.value,
                        color: Colors.blue,
                        onChanged: (value) {
                          selectedPriority.value = value!;
                        },
                      ),
                    ],
                  )),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => ElevatedButton(
                        onPressed: selectedPriority.value == currentPriority
                            ? null
                            : () {
                                controller
                                    .changeTicketPriority(
                                  ticketId,
                                  selectedPriority.value,
                                )
                                    .then((success) {
                                  if (success) {
                                    Get.back();
                                    successMessage(
                                        'Priority changed successfully');
                                  }
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                        ),
                        child: const Text('SAVE'),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityOption({
    required String label,
    required String description,
    required String value,
    required String groupValue,
    required Color color,
    required ValueChanged<String?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              value == groupValue ? color.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: value == groupValue ? color : Colors.grey.withOpacity(0.3),
            width: value == groupValue ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: value == groupValue ? color : Colors.black,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeCategoryDialog(
      Map<String, dynamic> ticket, SupportSystemController controller) {
    final ticketId = ticket['id'] as String;
    final currentCategory = ticket['category'] as String;
    RxString selectedCategory = currentCategory.obs;

    // Mock categories
    const List<String> categories = [
      'Account',
      'Billing',
      'Game Play',
      'Technical',
      'Feature Request',
      'Bug Report',
      'Other',
    ];

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Change Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select the new category for this ticket:',
              ),
              const SizedBox(height: 16),
              Obx(() => Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCategory.value,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down),
                        iconSize: 24,
                        elevation: 16,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        items: categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            selectedCategory.value = value;
                          }
                        },
                      ),
                    ),
                  )),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => ElevatedButton(
                        onPressed: selectedCategory.value == currentCategory
                            ? null
                            : () {
                                controller
                                    .changeTicketCategory(
                                  ticketId,
                                  selectedCategory.value,
                                )
                                    .then((success) {
                                  if (success) {
                                    Get.back();
                                    successMessage(
                                        'Category changed successfully');
                                  }
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                        ),
                        child: const Text('SAVE'),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTagDialog(
      Map<String, dynamic> ticket, SupportSystemController controller) {
    final tagController = TextEditingController();
    final ticketId = ticket['id'] as String;
    final currentTags = ticket['tags'] as List<dynamic>? ?? [];

    // Mock suggested tags
    final List<String> suggestedTags = [
      'login-issue',
      'payment-error',
      'game-crash',
      'feature-request',
      'account-recovery',
      'performance',
      'ui-bug',
    ];

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Tag',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tagController,
                decoration: const InputDecoration(
                  labelText: 'Tag',
                  border: OutlineInputBorder(),
                  hintText: 'Enter a new tag...',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Suggested Tags:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: suggestedTags
                    .where((tag) => !currentTags.contains(tag))
                    .map((tag) => ActionChip(
                          label: Text(tag),
                          onPressed: () {
                            tagController.text = tag;
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (tagController.text.isEmpty) {
                        errorMessage('Please enter a tag');
                        return;
                      }

                      if (currentTags.contains(tagController.text)) {
                        errorMessage('This tag already exists');
                        return;
                      }

                      controller
                          .addTagToTicket(
                        ticketId,
                        tagController.text,
                      )
                          .then((success) {
                        if (success) {
                          Get.back();
                          successMessage('Tag added successfully');
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                    child: const Text('ADD'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddNoteDialog(
      Map<String, dynamic> ticket, SupportSystemController controller) {
    final noteController = TextEditingController();
    final ticketId = ticket['id'] as String;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Internal Note',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'This note will only be visible to support staff.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  border: OutlineInputBorder(),
                  hintText: 'Enter your internal note here...',
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (noteController.text.isEmpty) {
                        errorMessage('Please enter a note');
                        return;
                      }

                      controller
                          .addInternalNote(
                        ticketId,
                        noteController.text,
                      )
                          .then((success) {
                        if (success) {
                          Get.back();
                          successMessage('Note added successfully');
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                    child: const Text('ADD NOTE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReopenTicketDialog(
      Map<String, dynamic> ticket, SupportSystemController controller) {
    final reasonController = TextEditingController();
    final ticketId = ticket['id'] as String;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reopen Ticket',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please provide a reason for reopening this ticket.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                  hintText: 'Explain why this ticket needs to be reopened...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (reasonController.text.isEmpty) {
                        errorMessage('Please enter a reason');
                        return;
                      }
                      controller
                          .reopenTicket(
                        ticketId,
                        reasonController.text,
                      )
                          .then((success) {
                        if (success) {
                          Get.back();
                          successMessage('Ticket reopened successfully');
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                    child: const Text('REOPEN'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMergeTicketDialog(
      Map<String, dynamic> ticket, SupportSystemController controller) {
    final ticketId = ticket['id'] as String;
    final RxString selectedTicketId = ''.obs;

    // Get other open tickets
    final otherTickets = controller
        .getAllTickets()
        .where((t) => t['id'] != ticketId && t['status'] == 'open')
        .toList();

    if (otherTickets.isEmpty) {
      errorMessage('No other open tickets available to merge with');
      return;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Merge Ticket',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select another ticket to merge this one with:',
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: otherTickets.length,
                  itemBuilder: (context, index) {
                    final otherTicket = otherTickets[index];
                    final otherTicketId = otherTicket['id'] as String;

                    return Obx(() => RadioListTile<String>(
                          title: Text(otherTicket['subject'] as String),
                          subtitle: Text('From: ${otherTicket['userName']}'),
                          value: otherTicketId,
                          groupValue: selectedTicketId.value,
                          onChanged: (value) {
                            selectedTicketId.value = value!;
                          },
                        ));
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => ElevatedButton(
                        onPressed: selectedTicketId.value.isEmpty
                            ? null
                            : () {
                                controller
                                    .mergeTickets(
                                  ticketId,
                                  selectedTicketId.value,
                                )
                                    .then((success) {
                                  if (success) {
                                    Get.back();
                                    successMessage(
                                        'Tickets merged successfully');
                                  }
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                        ),
                        child: const Text('MERGE'),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _exportTicket(Map<String, dynamic> ticket) {
    // This would be implemented to export ticket data to a file
    successMessage('Ticket exported successfully');
  }

  void _showTemplateResponsesDialog(SupportSystemController controller) {
    // Mock template responses
    final List<Map<String, String>> templates = [
      {
        'title': 'Thank you',
        'content':
            'Thank you for contacting us. We appreciate your patience while we work on resolving your issue.',
      },
      {
        'title': 'Additional information needed',
        'content':
            'To better assist you with this issue, could you please provide more information about the problem you\'re experiencing?',
      },
      {
        'title': 'Issue resolved',
        'content':
            'We\'re pleased to inform you that the issue you reported has been resolved. Please let us know if you encounter any further problems.',
      },
      {
        'title': 'Known issue',
        'content':
            'Thank you for your report. This is a known issue that our team is currently working on. We expect to have a fix available in our next update.',
      },
      {
        'title': 'User error',
        'content':
            'Based on our investigation, it appears this issue may be related to how the feature is being used. Here are the correct steps to follow:',
      },
    ];

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Template Responses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: templates.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final template = templates[index];
                    return ListTile(
                      title: Text(template['title']!),
                      trailing: TextButton(
                        onPressed: () {
                          controller.replyController.text =
                              template['content']!;
                          Get.back();
                        },
                        child: const Text('Use'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // Show create template dialog
                      Get.back();
                      _showCreateTemplateDialog(controller);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create New Template'),
                  ),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CLOSE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateTemplateDialog(SupportSystemController controller) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Response Template',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Template Title',
                  border: OutlineInputBorder(),
                  hintText: 'Enter a descriptive title...',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Response Content',
                  border: OutlineInputBorder(),
                  hintText: 'Enter the template content...',
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isEmpty ||
                          contentController.text.isEmpty) {
                        errorMessage('Please fill in all fields');
                        return;
                      }

                      // This would save the template in a real app
                      Get.back();
                      successMessage('Template saved successfully');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                    child: const Text('SAVE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAttachmentDialog(SupportSystemController controller) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Attachment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select file(s) to attach to your response:',
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload,
                          size: 40, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          // File selection would be implemented here
                        },
                        child: const Text('Click to select files'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Maximum file size: 10MB. Allowed formats: PNG, JPG, PDF, ZIP.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // This would upload the file in a real app
                      Get.back();
                      successMessage('Files would be attached here');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                    child: const Text('ATTACH'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showArticleDialog(Map<String, dynamic> article) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article['title'] as String,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Last updated: ${DateFormat('MMM dd, yyyy').format(article['updatedAt'] as DateTime)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(article['content'] as String),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      // Edit the article
                      Get.back();
                      _showEditArticleDialog(article);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Article'),
                  ),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                    child: const Text('CLOSE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditArticleDialog(Map<String, dynamic> article) {
    final titleController =
        TextEditingController(text: article['title'] as String);
    final contentController =
        TextEditingController(text: article['content'] as String);
    final summaryController =
        TextEditingController(text: article['summary'] as String);
    final List<String> categories = [
      'Account',
      'Billing',
      'Game Play',
      'Technical',
      'Feature Request',
      'Bug Report',
      'Other'
    ];
    final RxString selectedCategory = (article['category'] as String).obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Knowledge Base Article',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: summaryController,
                decoration: const InputDecoration(
                  labelText: 'Summary',
                  border: OutlineInputBorder(),
                  hintText: 'Brief description of the article',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => Container(
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.grey.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedCategory.value,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down),
                              iconSize: 24,
                              elevation: 16,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              items: categories.map((String category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  selectedCategory.value = value;
                                }
                              },
                            ),
                          ),
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Content',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Article content...',
                  ),
                  maxLines: null,
                  expands: true,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isEmpty ||
                          contentController.text.isEmpty ||
                          summaryController.text.isEmpty) {
                        errorMessage('Please fill in all fields');
                        return;
                      }

                      // This would update the article in a real app
                      Get.back();
                      successMessage('Article updated successfully');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                    child: const Text('SAVE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateKnowledgeBaseArticleDialog(
      SupportSystemController controller) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final summaryController = TextEditingController();
    final List<String> categories = [
      'Account',
      'Billing',
      'Game Play',
      'Technical',
      'Feature Request',
      'Bug Report',
      'Other'
    ];
    final RxString selectedCategory = categories[0].obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Knowledge Base Article',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  hintText: 'Enter article title',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: summaryController,
                decoration: const InputDecoration(
                  labelText: 'Summary',
                  border: OutlineInputBorder(),
                  hintText: 'Brief description of the article',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => Container(
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.grey.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedCategory.value,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down),
                              iconSize: 24,
                              elevation: 16,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              items: categories.map((String category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  selectedCategory.value = value;
                                }
                              },
                            ),
                          ),
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Content',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Article content...',
                  ),
                  maxLines: null,
                  expands: true,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isEmpty ||
                          contentController.text.isEmpty ||
                          summaryController.text.isEmpty) {
                        errorMessage('Please fill in all fields');
                        return;
                      }

                      // Create the article
                      controller
                          .createKnowledgeBaseArticle(
                        title: titleController.text,
                        content: contentController.text,
                        summary: summaryController.text,
                        category: selectedCategory.value,
                      )
                          .then((success) {
                        if (success) {
                          Get.back();
                          successMessage('Article created successfully');
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                    child: const Text('CREATE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showKnowledgeBaseDialog(SupportSystemController controller) {
    final searchController = TextEditingController();
    final RxString searchQuery = ''.obs;
    final RxString selectedCategory = 'All'.obs;

    final List<String> categories = [
      'All',
      'Account',
      'Billing',
      'Game Play',
      'Technical',
      'Feature Request',
      'Bug Report',
      'Other',
    ];

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Knowledge Base',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search articles...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: Obx(() => searchQuery.value.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  searchController.clear();
                                  searchQuery.value = '';
                                },
                              )
                            : const SizedBox()),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        searchQuery.value = value.trim();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCategory.value,
                            hint: const Text('Category'),
                            items: categories.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                selectedCategory.value = value;
                              }
                            },
                          ),
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  final articles = controller.getFilteredKnowledgeBaseArticles(
                    searchQuery.value,
                    selectedCategory.value == 'All'
                        ? null
                        : selectedCategory.value,
                  );

                  if (articles.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.article,
                              size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            searchQuery.value.isNotEmpty ||
                                    selectedCategory.value != 'All'
                                ? 'No articles match your search'
                                : 'No articles found',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: articles.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final article = articles[index];
                      return ListTile(
                        title: Text(
                          article['title'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'Edit',
                              onPressed: () {
                                Get.back();
                                _showEditArticleDialog(article);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.visibility),
                              tooltip: 'View',
                              onPressed: () {
                                Get.back();
                                _showArticleDialog(article);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                      _showCreateKnowledgeBaseArticleDialog(controller);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create New Article'),
                  ),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CLOSE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSupportAnalytics(SupportSystemController controller) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Support Analytics',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Analytics content would go here
                      Text(
                          'Support analytics and reporting would be displayed here.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('CLOSE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSupportSettings(SupportSystemController controller) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Support Settings',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Email Notifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('New ticket notifications'),
                subtitle:
                    const Text('Receive email when a new ticket is created'),
                value: true,
                onChanged: (_) {},
              ),
              CheckboxListTile(
                title: const Text('Ticket assignment notifications'),
                subtitle: const Text(
                    'Receive email when a ticket is assigned to you'),
                value: true,
                onChanged: (_) {},
              ),
              CheckboxListTile(
                title: const Text('Ticket update notifications'),
                subtitle: const Text('Receive email when a ticket is updated'),
                value: false,
                onChanged: (_) {},
              ),
              const SizedBox(height: 16),
              const Text(
                'Automation Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('Auto-assign tickets'),
                subtitle: const Text(
                    'Automatically assign tickets to available agents'),
                value: true,
                onChanged: (_) {},
              ),
              CheckboxListTile(
                title: const Text('Auto-tag tickets'),
                subtitle:
                    const Text('Automatically tag tickets based on content'),
                value: true,
                onChanged: (_) {},
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      successMessage('Settings saved successfully');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                    child: const Text('SAVE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildMessageBubble({
  required String sender,
  required String? senderImage,
  required String message,
  required DateTime timestamp,
  required bool isUser,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
    children: [
      if (!isUser) ...[
        AvatarUserWidget(
          radius: 16,
          imagePath: senderImage ?? '',
        ),
        const SizedBox(width: 8),
      ],
      Flexible(
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser
                    ? Colors.grey[100]
                    : Colors.deepPurpleAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isUser
                      ? Colors.grey[300]!
                      : Colors.deepPurpleAccent.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sender,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isUser ? Colors.black : Colors.deepPurpleAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(message),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM dd, yyyy - HH:mm').format(timestamp),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
      if (isUser) ...[
        const SizedBox(width: 8),
        AvatarUserWidget(
          radius: 16,
          imagePath: senderImage ?? '',
        ),
      ],
    ],
  );
}

Widget _buildReplyForm(SupportSystemController controller, String ticketId) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Reply',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: controller.replyController,
        decoration: const InputDecoration(
          hintText: 'Type your response here...',
          border: OutlineInputBorder(),
        ),
        maxLines: 5,
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            onPressed: () {
              // Show template responses dialog
              _showTemplateResponsesDialog(controller);
            },
            icon: const Icon(Icons.format_quote),
            label: const Text('Templates'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () {
              // Show attachment dialog
              _showAttachmentDialog(controller);
            },
            icon: const Icon(Icons.attach_file),
            label: const Text('Add Attachment'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {
              if (controller.replyController.text.isEmpty) {
                errorMessage('Please enter a response');
                return;
              }

              controller
                  .sendReply(ticketId, controller.replyController.text)
                  .then((success) {
                if (success) {
                  controller.replyController.clear();
                  successMessage('Reply sent successfully');
                }
              });
            },
            icon: const Icon(Icons.send),
            label: const Text('Send Reply'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
            ),
          ),
        ],
      ),
    ],
  );
}

void _showAttachmentDialog(SupportSystemController controller) {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Attachment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select file(s) to attach to your response:',
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload, size: 40, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        // File selection would be implemented here
                      },
                      child: const Text('Click to select files'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Maximum file size: 10MB. Allowed formats: PNG, JPG, PDF, ZIP.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('CANCEL'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // This would upload the file in a real app
                    Get.back();
                    successMessage('Files would be attached here');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                  ),
                  child: const Text('ATTACH'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void _showTemplateResponsesDialog(SupportSystemController controller) {
  // Mock template responses
  final List<Map<String, String>> templates = [
    {
      'title': 'Thank you',
      'content':
          'Thank you for contacting us. We appreciate your patience while we work on resolving your issue.',
    },
    {
      'title': 'Additional information needed',
      'content':
          'To better assist you with this issue, could you please provide more information about the problem you\'re experiencing?',
    },
    {
      'title': 'Issue resolved',
      'content':
          'We\'re pleased to inform you that the issue you reported has been resolved. Please let us know if you encounter any further problems.',
    },
    {
      'title': 'Known issue',
      'content':
          'Thank you for your report. This is a known issue that our team is currently working on. We expect to have a fix available in our next update.',
    },
    {
      'title': 'User error',
      'content':
          'Based on our investigation, it appears this issue may be related to how the feature is being used. Here are the correct steps to follow:',
    },
  ];

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Template Responses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: templates.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final template = templates[index];
                  return ListTile(
                    title: Text(template['title']!),
                    subtitle: Text(
                      template['content']!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: TextButton(
                      onPressed: () {
                        controller.replyController.text = template['content']!;
                        Get.back();
                      },
                      child: const Text('Use'),
                    ),
                    onTap: () {
                      controller.replyController.text = template['content']!;
                      Get.back();
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // Show create template dialog
                    Get.back();
                    _showCreateTemplateDialog(controller);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Template'),
                ),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('CLOSE'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void _showCreateTemplateDialog(SupportSystemController controller) {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Response Template',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Template Title',
                border: OutlineInputBorder(),
                hintText: 'Enter a descriptive title...',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: 'Response Content',
                border: OutlineInputBorder(),
                hintText: 'Enter the template content...',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('CANCEL'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isEmpty ||
                        contentController.text.isEmpty) {
                      errorMessage('Please fill in all fields');
                      return;
                    }

                    // This would save the template in a real app
                    Get.back();
                    successMessage('Template saved successfully');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                  ),
                  child: const Text('SAVE'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildFilterChip({
  required String label,
  required bool selected,
  required ValueChanged<bool> onSelected,
  Color? color,
}) {
  return FilterChip(
    label: Text(label),
    selected: selected,
    onSelected: onSelected,
    selectedColor: (color ?? Colors.deepPurpleAccent).withOpacity(0.2),
    checkmarkColor: color ?? Colors.deepPurpleAccent,
    labelStyle: TextStyle(
      color: selected ? (color ?? Colors.deepPurpleAccent) : Colors.black,
      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
    ),
  );
}

Widget _buildInfoRow({
  required String label,
  required String value,
  Color? valueColor,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          color: Colors.grey[700],
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: valueColor,
        ),
      ),
    ],
  );
}

Widget _buildTagChip({
  required String tag,
  required VoidCallback onDeleted,
}) {
  return Chip(
    label: Text(tag),
    deleteIcon: const Icon(Icons.cancel, size: 16),
    onDeleted: onDeleted,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
  );
}

Color _getStatusColor(String status) {
  switch (status) {
    case 'open':
      return Colors.green;
    case 'pending':
      return Colors.orange;
    case 'resolved':
      return Colors.grey;
    default:
      return Colors.grey;
  }
}

Color _getPriorityColor(String priority) {
  switch (priority) {
    case 'high':
      return Colors.red;
    case 'medium':
      return Colors.orange;
    case 'low':
      return Colors.blue;
    default:
      return Colors.grey;
  }
}

String _timeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays > 365) {
    return '${(difference.inDays / 365).floor()} years ago';
  } else if (difference.inDays > 30) {
    return '${(difference.inDays / 30).floor()} months ago';
  } else if (difference.inDays > 7) {
    return '${(difference.inDays / 7).floor()} weeks ago';
  } else if (difference.inDays > 0) {
    return '${difference.inDays} days ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} hours ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} minutes ago';
  } else {
    return 'Just now';
  }
}

void _showResolveTicketDialog(
    Map<String, dynamic> ticket, SupportSystemController controller) {
  final resolutionController = TextEditingController();
  final ticketId = ticket['id'] as String;

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resolve Ticket',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please provide a summary of the resolution for this ticket.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resolutionController,
              decoration: const InputDecoration(
                labelText: 'Resolution',
                border: OutlineInputBorder(),
                hintText: 'Explain how the issue was resolved...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Send resolution email to user'),
              value: true,
              onChanged: (_) {},
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('CANCEL'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (resolutionController.text.isEmpty) {
                      errorMessage('Please enter a resolution summary');
                      return;
                    }

                    controller
                        .resolveTicket(
                      ticketId,
                      resolutionController.text,
                    )
                        .then((success) {
                      if (success) {
                        Get.back();
                        successMessage('Ticket resolved successfully');
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('RESOLVE'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void _showAssignTicketDialog(
    Map<String, dynamic> ticket, SupportSystemController controller) {
  final ticketId = ticket['id'] as String;
  final RxString selectedAgentId = ''.obs;

  // Mock agent data
  final List<Map<String, dynamic>> agents = [
    {
      'id': 'agent1',
      'name': 'John Smith',
      'role': 'Support Agent',
      'image': '',
      'activeTickets': 5
    },
    {
      'id': 'agent2',
      'name': 'Jane Doe',
      'role': 'Senior Support',
      'image': '',
      'activeTickets': 3
    },
    {
      'id': 'agent3',
      'name': 'Mike Johnson',
      'role': 'Support Agent',
      'image': '',
      'activeTickets': 7
    },
    {
      'id': 'agent4',
      'name': 'Sarah Wilson',
      'role': 'Technical Support',
      'image': '',
      'activeTickets': 2
    },
  ];

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assign Ticket',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select an agent to assign this ticket to:',
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: agents.length,
                itemBuilder: (context, index) {
                  final agent = agents[index];
                  final agentId = agent['id'] as String;

                  return Obx(() => RadioListTile<String>(
                        title: Text(agent['name'] as String),
                        subtitle: Row(
                          children: [
                            Text(agent['role'] as String),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${agent['activeTickets']} active tickets',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        value: agentId,
                        groupValue: selectedAgentId.value,
                        onChanged: (value) {
                          selectedAgentId.value = value!;
                        },
                      ));
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () {
                    // Unassign ticket logic
                    controller.unassignTicket(ticketId).then((success) {
                      if (success) {
                        Get.back();
                        successMessage('Ticket unassigned successfully');
                      }
                    });
                  },
                  child: const Text('Unassign'),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('CANCEL'),
                    ),
                    const SizedBox(width: 8),
                    Obx(() => ElevatedButton(
                          onPressed: selectedAgentId.value.isEmpty
                              ? null
                              : () {
                                  controller
                                      .assignTicket(
                                    ticketId,
                                    selectedAgentId.value,
                                    agents.firstWhere((agent) =>
                                            agent['id'] ==
                                            selectedAgentId.value)['name']
                                        as String,
                                  )
                                      .then((success) {
                                    if (success) {
                                      Get.back();
                                      successMessage(
                                          'Ticket assigned successfully');
                                    }
                                  });
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                          ),
                          child: const Text('ASSIGN'),
                        )),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void _showChangePriorityDialog(
    Map<String, dynamic> ticket, SupportSystemController controller) {
  final ticketId = ticket['id'] as String;
  final currentPriority = ticket['priority'] as String;
  RxString selectedPriority = currentPriority.obs;

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change Priority',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select the new priority level for this ticket:',
            ),
            const SizedBox(height: 16),
            Obx(() => Column(
                  children: [
                    _buildPriorityOption(
                      label: 'High',
                      description: 'Critical issue affecting many users',
                      value: 'high',
                      groupValue: selectedPriority.value,
                      color: Colors.red,
                      onChanged: (value) {
                        selectedPriority.value = value!;
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildPriorityOption(
                      label: 'Medium',
                      description: 'Important issue with limited impact',
                      value: 'medium',
                      groupValue: selectedPriority.value,
                      color: Colors.orange,
                      onChanged: (value) {
                        selectedPriority.value = value!;
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildPriorityOption(
                      label: 'Low',
                      description: 'Minor issue or question',
                      value: 'low',
                      groupValue: selectedPriority.value,
                      color: Colors.blue,
                      onChanged: (value) {
                        selectedPriority.value = value!;
                      },
                    ),
                  ],
                )),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('CANCEL'),
                ),
                const SizedBox(width: 8),
                Obx(() => ElevatedButton(
                      onPressed: selectedPriority.value == currentPriority
                          ? null
                          : () {
                              controller
                                  .changeTicketPriority(
                                ticketId,
                                selectedPriority.value,
                              )
                                  .then((success) {
                                if (success) {
                                  Get.back();
                                  successMessage(
                                      'Priority changed successfully');
                                }
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                      ),
                      child: const Text('SAVE'),
                    )),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildPriorityOption({
  required String label,
  required String description,
  required String value,
  required String groupValue,
  required Color color,
  required ValueChanged<String?> onChanged,
}) {
  return InkWell(
    onTap: () => onChanged(value),
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            value == groupValue ? color.withOpacity(0.1) : Colors.transparent,
        border: Border.all(
          color: value == groupValue ? color : Colors.grey.withOpacity(0.3),
          width: value == groupValue ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
            activeColor: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: value == groupValue ? color : Colors.black,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

void _showChangeCategoryDialog(
    Map<String, dynamic> ticket, SupportSystemController controller) {
  final ticketId = ticket['id'] as String;
  final currentCategory = ticket['category'] as String;
  RxString selectedCategory = currentCategory.obs;

  // Mock categories
  const List<String> categories = [
    'Account',
    'Billing',
    'Game Play',
    'Technical',
    'Feature Request',
    'Bug Report',
    'Other',
  ];

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select the new category for this ticket:',
            ),
            const SizedBox(height: 16),
            Obx(() => Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCategory.value,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 24,
                      elevation: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      items: categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          selectedCategory.value = value;
                        }
                      },
                    ),
                  ),
                )),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('CANCEL'),
                ),
                const SizedBox(width: 8),
                Obx(() => ElevatedButton(
                      onPressed: selectedCategory.value == currentCategory
                          ? null
                          : () {
                              controller
                                  .changeTicketCategory(
                                ticketId,
                                selectedCategory.value,
                              )
                                  .then((success) {
                                if (success) {
                                  Get.back();
                                  successMessage(
                                      'Category changed successfully');
                                }
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                      ),
                      child: const Text('SAVE'),
                    )),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void _showAddTagDialog(
    Map<String, dynamic> ticket, SupportSystemController controller) {
  final tagController = TextEditingController();
  final ticketId = ticket['id'] as String;
  final currentTags = ticket['tags'] as List<dynamic>? ?? [];

  // Mock suggested tags
  final List<String> suggestedTags = [
    'login-issue',
    'payment-error',
    'game-crash',
    'feature-request',
    'account-recovery',
    'performance',
    'ui-bug',
  ];

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Tag',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: tagController,
              decoration: const InputDecoration(
                labelText: 'Tag',
                border: OutlineInputBorder(),
                hintText: 'Enter a new tag...',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Suggested Tags:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestedTags
                  .where((tag) => !currentTags.contains(tag))
                  .map((tag) => ActionChip(
                        label: Text(tag),
                        onPressed: () {
                          tagController.text = tag;
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('CANCEL'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (tagController.text.isEmpty) {
                      errorMessage('Please enter a tag');
                      return;
                    }

                    if (currentTags.contains(tagController.text)) {
                      errorMessage('This tag already exists');
                      return;
                    }

                    controller
                        .addTagToTicket(
                      ticketId,
                      tagController.text,
                    )
                        .then((success) {
                      if (success) {
                        Get.back();
                        successMessage('Tag added successfully');
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                  ),
                  child: const Text('ADD'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void _showAddNoteDialog(
    Map<String, dynamic> ticket, SupportSystemController controller) {
  final noteController = TextEditingController();
  final ticketId = ticket['id'] as String;

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Internal Note',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This note will only be visible to support staff.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
                hintText: 'Enter your internal note here...',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('CANCEL'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (noteController.text.isEmpty) {
                      errorMessage('Please enter a note');
                      return;
                    }

                    controller
                        .addInternalNote(
                      ticketId,
                      noteController.text,
                    )
                        .then((success) {
                      if (success) {
                        Get.back();
                        successMessage('Note added successfully');
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                  ),
                  child: const Text('ADD NOTE'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void _showReopenTicketDialog(
    Map<String, dynamic> ticket, SupportSystemController controller) {
  final reasonController = TextEditingController();
  final ticketId = ticket['id'] as String;

  Get.dialog(Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reopen Ticket',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please provide a reason for reopening this ticket.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                  hintText: 'Explain why this ticket needs to be reopened...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('CANCEL'),
                ),
                const SizedBox(width: 8),
              ])
            ])),
  ));
}

void _showArticleDialog(Map<String, dynamic> article) {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article['title'] as String,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateFormat('MMM dd, yyyy').format(article['updatedAt'] as DateTime)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(article['content'] as String),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // Edit the article
                    Get.back();
                    _showEditArticleDialog(article);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Article'),
                ),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                  ),
                  child: const Text('CLOSE'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void _showEditArticleDialog(Map<String, dynamic> article) {
  final titleController =
      TextEditingController(text: article['title'] as String);
  final contentController =
      TextEditingController(text: article['content'] as String);
  final summaryController =
      TextEditingController(text: article['summary'] as String);
  final List<String> categories = [
    'Account',
    'Billing',
    'Game Play',
    'Technical',
    'Feature Request',
    'Bug Report',
    'Other'
  ];
  final RxString selectedCategory = (article['category'] as String).obs;

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Knowledge Base Article',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: summaryController,
              decoration: const InputDecoration(
                labelText: 'Summary',
                border: OutlineInputBorder(),
                hintText: 'Brief description of the article',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Obx(() => Container(
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCategory.value,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down),
                            iconSize: 24,
                            elevation: 16,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            items: categories.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                selectedCategory.value = value;
                              }
                            },
                          ),
                        ),
                      )),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Content',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Article content...',
                ),
                maxLines: null,
                expands: true,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('CANCEL'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isEmpty ||
                        contentController.text.isEmpty ||
                        summaryController.text.isEmpty) {
                      errorMessage('Please fill in all fields');
                      return;
                    }

                    // This would update the article in a real app
                    Get.back();
                    successMessage('Article updated successfully');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                  ),
                  child: const Text('SAVE'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildTicketPropertyPill({required String label, required Color color}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    ),
  );
}

Widget _buildTicketActions(
    Map<String, dynamic> ticket, SupportSystemController controller) {
  final status = ticket['status'] as String;
  final ticketId = ticket['id'] as String;

  return Row(
    children: [
      if (status == 'open' || status == 'pending')
        OutlinedButton.icon(
          onPressed: () => _showResolveTicketDialog(ticket, controller),
          icon: const Icon(Icons.check_circle),
          label: const Text('Resolve'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.green,
          ),
        ),
      const SizedBox(width: 8),
      OutlinedButton.icon(
        onPressed: () => _showAssignTicketDialog(ticket, controller),
        icon: const Icon(Icons.person_add),
        label: const Text('Assign'),
      ),
      const SizedBox(width: 8),
      PopupMenuButton(
        icon: const Icon(Icons.more_vert),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'changePriority',
            child: ListTile(
              leading: Icon(Icons.flag),
              title: Text('Change Priority'),
              dense: true,
            ),
          ),
          const PopupMenuItem(
            value: 'changeCategory',
            child: ListTile(
              leading: Icon(Icons.category),
              title: Text('Change Category'),
              dense: true,
            ),
          ),
          const PopupMenuItem(
            value: 'addNote',
            child: ListTile(
              leading: Icon(Icons.note_add),
              title: Text('Add Internal Note'),
              dense: true,
            ),
          ),
          if (status == 'resolved')
            const PopupMenuItem(
              value: 'reopen',
              child: ListTile(
                leading: Icon(Icons.refresh),
                title: Text('Reopen Ticket'),
                dense: true,
              ),
            ),
          const PopupMenuItem(
            value: 'merge',
            child: ListTile(
              leading: Icon(Icons.merge_type),
              title: Text('Merge with Another Ticket'),
              dense: true,
            ),
          ),
          const PopupMenuItem(
            value: 'export',
            child: ListTile(
              leading: Icon(Icons.download),
              title: Text('Export Ticket'),
              dense: true,
            ),
          ),
        ],
        onSelected: (value) {
          switch (value) {
            case 'changePriority':
              _showChangePriorityDialog(ticket, controller);
              break;
            case 'changeCategory':
              _showChangeCategoryDialog(ticket, controller);
              break;
            case 'addNote':
              _showAddNoteDialog(ticket, controller);
              break;
            case 'reopen':
              _showReopenTicketDialog(ticket, controller);
              break;
            case 'merge':
              _showMergeTicketDialog(ticket, controller);
              break;
            case 'export':
              _exportTicket(ticket);
              break;
          }
        },
      ),
    ],
  );
}

void _showMergeTicketDialog(
    Map<String, dynamic> ticket, SupportSystemController controller) {
  final ticketId = ticket['id'] as String;
  final RxString selectedTicketId = ''.obs;

  // Get other open tickets
  final otherTickets = controller
      .getAllTickets()
      .where((t) => t['id'] != ticketId && t['status'] == 'open')
      .toList();

  if (otherTickets.isEmpty) {
    errorMessage('No other open tickets available to merge with');
    return;
  }

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Merge Ticket',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select another ticket to merge this one with:',
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: otherTickets.length,
                itemBuilder: (context, index) {
                  final otherTicket = otherTickets[index];
                  final otherTicketId = otherTicket['id'] as String;

                  return Obx(() => RadioListTile<String>(
                        title: Text(otherTicket['subject'] as String),
                        subtitle: Text('From: ${otherTicket['userName']}'),
                        value: otherTicketId,
                        groupValue: selectedTicketId.value,
                        onChanged: (value) {
                          selectedTicketId.value = value!;
                        },
                      ));
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('CANCEL'),
                ),
                const SizedBox(width: 8),
                Obx(() => ElevatedButton(
                      onPressed: selectedTicketId.value.isEmpty
                          ? null
                          : () {
                              controller
                                  .mergeTickets(
                                ticketId,
                                selectedTicketId.value,
                              )
                                  .then((success) {
                                if (success) {
                                  Get.back();
                                  successMessage('Tickets merged successfully');
                                }
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                      ),
                      child: const Text('MERGE'),
                    )),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void _exportTicket(Map<String, dynamic> ticket) {
  // This would be implemented to export ticket data to a file
  successMessage('Ticket exported successfully');
}

Widget _buildUserCard({
  required String userName,
  required String userEmail,
  required String? userImage,
  required String userId,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'User Information',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            AvatarUserWidget(
              radius: 25,
              imagePath: userImage ?? '',
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    userEmail,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'User ID: ${userId.substring(0, 8)}...',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: () => Get.toNamed('/admin/users/$userId'),
              icon: const Icon(Icons.person),
              label: const Text('View Profile'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () {
                // Show user's previous tickets
              },
              icon: const Icon(Icons.history),
              label: const Text('View History'),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildTicketInfoCard({
  required DateTime createdAt,
  required String? assignedTo,
  required SupportSystemController controller,
  required Map<String, dynamic> ticket,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ticket Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          label: 'Created',
          value: DateFormat('MMM dd, yyyy - HH:mm').format(createdAt),
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          label: 'Assigned To',
          value: assignedTo ?? 'Unassigned',
          valueColor:
              assignedTo != null ? Colors.deepPurpleAccent : Colors.grey,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          label: 'Device',
          value: ticket['deviceInfo'] as String? ?? 'Unknown',
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          label: 'App Version',
          value: ticket['appVersion'] as String? ?? 'Unknown',
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          label: 'Platform',
          value: ticket['platform'] as String? ?? 'Unknown',
        ),
        const SizedBox(height: 16),
        // Tags
        const Text(
          'Tags',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...(ticket['tags'] as List<dynamic>? ?? [])
                .map((tag) => _buildTagChip(
                      tag: tag as String,
                      onDeleted: () {
                        // Remove tag
                        controller.removeTagFromTicket(
                            ticket['id'] as String, tag);
                      },
                    )),
            ActionChip(
              label: const Text('Add Tag'),
              avatar: const Icon(Icons.add, size: 16),
              onPressed: () => _showAddTagDialog(ticket, controller),
            ),
          ],
        ),
      ],
    ),
  );
}

```

---


### Pages\widgets\admin_access_widget.dart

```dart
// Đoạn code này thêm vào trang MainHome.dart trong phần drawer hoặc menu profile

// Import các thư viện cần thiết
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Class để kiểm tra và hiển thị nút Admin
class AdminAccessWidget extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AdminAccessWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkIsAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        if (snapshot.hasData && snapshot.data == true) {
          return _buildAdminButton();
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAdminButton() {
    return Column(
      children: [
        const Divider(),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: Colors.deepPurpleAccent,
            ),
          ),
          title: const Text(
            'Quản Trị Viên',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: const Text('Truy cập bảng điều khiển admin'),
          onTap: () {
            Get.toNamed('/admin');
          },
        ),
      ],
    );
  }

  Future<bool> _checkIsAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return false;
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        return false;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      return userData['role'] == 'admin';
    } catch (e) {
      print('Error checking admin role: $e');
      return false;
    }
  }
}

// Thêm đoạn này vào Drawer hoặc menu profile của MainHome.dart
// ...
// Các menu item khác
// ...
// AdminAccessWidget(), // Thêm dòng này
// ...
```

---


### services\admin_service.dart

```dart
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

```

---
