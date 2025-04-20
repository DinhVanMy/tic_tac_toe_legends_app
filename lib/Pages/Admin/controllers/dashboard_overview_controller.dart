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