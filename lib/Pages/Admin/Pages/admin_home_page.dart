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
        backgroundColor: Colors.deepPurple.withOpacity(0.5),
        bottom: TabBar(
          controller: controller.tabController,
          isScrollable: true,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.blueGrey,
          indicatorSize: TabBarIndicatorSize.tab,
          splashBorderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          indicatorWeight: 5,
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
