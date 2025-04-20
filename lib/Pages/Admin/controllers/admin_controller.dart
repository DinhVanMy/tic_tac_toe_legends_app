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