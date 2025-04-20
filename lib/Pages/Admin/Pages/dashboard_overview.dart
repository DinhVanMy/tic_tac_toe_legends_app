import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
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
            return Container(
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
            );
          }

          return LayoutBuilder(builder: (context, constraints) {
            // Determine if we're on a small screen
            final isSmallScreen = constraints.maxWidth < 600;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBreadcrumbs(constraints),
                  const SizedBox(height: 16),
                  _buildStatsSummary(dashboardController, constraints),
                  const SizedBox(height: 24),
                  _buildUserActivityChart(dashboardController),
                  const SizedBox(height: 24),

                  // Responsive layout for reports and announcements
                  if (isSmallScreen)
                    Column(
                      children: [
                        _buildRecentReports(dashboardController),
                        const SizedBox(height: 16),
                        _buildActiveAnnouncements(dashboardController),
                      ],
                    )
                  else
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

                  // Responsive layout for users and games
                  if (isSmallScreen)
                    Column(
                      children: [
                        _buildTopUsers(dashboardController),
                        const SizedBox(height: 16),
                        _buildTopGames(dashboardController),
                      ],
                    )
                  else
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
          });
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

  Widget _buildBreadcrumbs(BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 600;

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
          // Wrap in Flexible to handle potential overflow
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  // Limit text size on small screens
                  Flexible(
                    child: Text(
                      'All Systems Operational',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 10 : 12,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(
      DashboardController controller, BoxConstraints constraints) {
    final stats = controller.summaryStats.value;
    final isSmallScreen = constraints.maxWidth < 600;
    final isMediumScreen =
        constraints.maxWidth < 1000 && constraints.maxWidth >= 600;

    // Determine grid columns based on screen width
    int crossAxisCount = 4;
    if (isSmallScreen) {
      crossAxisCount = 1;
    } else if (isMediumScreen) {
      crossAxisCount = 2;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(
              child: Text(
                'Dashboard Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Flexible(
              child: OutlinedButton.icon(
                onPressed: () => controller.refreshAllData(),
                icon: const Icon(Icons.refresh, size: 16),
                label: Text(
                  'Last updated: ${_getFormattedTime()}',
                  style: TextStyle(fontSize: isSmallScreen ? 10 : 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          childAspectRatio:
              isSmallScreen ? 2.5 : 1.5, // Adjust card aspect ratio
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStatCard(
              title: 'Total Users',
              value: '${stats['totalUsers'] ?? 0}',
              change: '+${stats['newUsers'] ?? 0} today',
              isPositive: true,
              icon: Icons.people,
              color: Colors.blue,
              onTap: () =>
                  Get.find<AdminController>().tabController.animateTo(0),
            ),
            _buildStatCard(
              title: 'Pending Reports',
              value: '${stats['pendingReports'] ?? 0}',
              change: '${stats['criticalReports'] ?? 0} critical',
              isPositive: false,
              icon: Icons.report_problem,
              color: Colors.orange,
              onTap: () =>
                  Get.find<AdminController>().tabController.animateTo(1),
            ),
            _buildStatCard(
              title: 'Active Games',
              value: '${stats['activeGames'] ?? 0}',
              change: '+${stats['newGames'] ?? 0} today',
              isPositive: true,
              icon: Icons.sports_esports,
              color: Colors.purple,
              onTap: () =>
                  Get.find<AdminController>().tabController.animateTo(4),
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
          mainAxisSize: MainAxisSize.min, // Prevent vertical expansion
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
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
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
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
                Flexible(
                  child: Text(
                    change,
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
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
              const Flexible(
                child: Text(
                  'User Activity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
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
          // Wrap chart in a LimitedBox to prevent height issues when data is loading
          LimitedBox(
            maxHeight: 250,
            child: userActivityData.isEmpty
                ? const Center(child: Text('No activity data available'))
                : _buildActivityChart(
                    userActivityData, controller.maxUserActivity.value),
          ),
          const SizedBox(height: 16),
          // Use Wrap instead of Row for better handling of small screens
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildLegendItem('Active Users', Colors.blue),
              _buildLegendItem('New Registrations', Colors.green),
              _buildLegendItem('Game Sessions', Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  // Extracted chart building logic to separate method for clarity
  Widget _buildActivityChart(
      List<Map<String, dynamic>> userActivityData, int maxValue) {
    return LineChart(
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
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
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
        maxY: maxValue.toDouble(),
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
                if (index < 0 || index >= userActivityData.length) {
                  return null;
                }

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
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize:
          MainAxisSize.min, // Important to prevent Row from taking full width
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
              const Flexible(
                child: Text(
                  'Recent Reports',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () =>
                    Get.find<AdminController>().tabController.animateTo(1),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          LayoutBuilder(builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 400;

            return reports.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No recent reports',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reports.length > 5 ? 5 : reports.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      final contentType =
                          report['contentType'] as String? ?? '';
                      final reportReason =
                          report['reason'] as String? ?? 'Not specified';
                      final reportedAt =
                          report['reportedAt'] as DateTime? ?? DateTime.now();
                      final reporterName =
                          report['reporter']['name'] as String? ?? 'Unknown';

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
                        contentPadding: isNarrow
                            ? const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0)
                            : null,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            iconData,
                            color: iconColor,
                            size: isNarrow ? 16 : 24,
                          ),
                        ),
                        title: Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Reported ${contentType.capitalizeFirst}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
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
                              style: TextStyle(fontSize: isNarrow ? 11 : 12),
                            ),
                            Text(
                              'By $reporterName • ${_timeAgo(reportedAt)}',
                              style: TextStyle(
                                fontSize: isNarrow ? 10 : 12,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.chevron_right),
                          iconSize: isNarrow ? 16 : 24,
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          onPressed: () => _showReportDetails(report),
                        ),
                        onTap: () => _showReportDetails(report),
                      );
                    },
                  );
          }),

          // Gap added to ensure consistent spacing
          const SizedBox(height: 8),
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
                onPressed: () =>
                    Get.find<AdminController>().tabController.animateTo(3),
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
              final startDate =
                  announcement['startDate'] as DateTime? ?? DateTime.now();
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
              const Flexible(
                child: Text(
                  'Top Users',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Dropdown with overflow protection
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.userSortCriteria.value,
                  isDense: true, // Make dropdown more compact
                  items: const [
                    DropdownMenuItem(value: 'coins', child: Text('By Coins')),
                    DropdownMenuItem(value: 'wins', child: Text('By Wins')),
                    DropdownMenuItem(
                        value: 'activity', child: Text('By Activity')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.userSortCriteria.value = value;
                      controller.loadTopUsers(sortBy: value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          LayoutBuilder(builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 400;

            return users.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No user data available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: users.length > 5 ? 5 : users.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        contentPadding: isNarrow
                            ? const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0)
                            : null,
                        leading: Stack(
                          children: [
                            AvatarUserWidget(
                              radius: isNarrow ? 16 : 20,
                              imagePath: user.image ?? '',
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isNarrow ? 13 : 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          controller.userSortCriteria.value == 'coins'
                              ? '${user.totalCoins ?? "0"} coins'
                              : controller.userSortCriteria.value == 'wins'
                                  ? '${user.totalWins ?? "0"} wins'
                                  : 'Last: ${_timeAgo(user.lastActive?.toDate() ?? DateTime.now())}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: isNarrow ? 11 : 12),
                        ),
                        trailing: Chip(
                          label: Text(
                            user.role ?? 'user',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: isNarrow ? 9 : 10),
                          ),
                          backgroundColor: _getRoleColor(user.role),
                          labelStyle: const TextStyle(color: Colors.white),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        onTap: () => _showUserDetails(user),
                      );
                    },
                  );
          }),

          const SizedBox(height: 8),

          // View all button
          Center(
            child: TextButton(
              onPressed: () =>
                  Get.find<AdminController>().tabController.animateTo(0),
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
              const Flexible(
                child: Text(
                  'Top Games',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.gameSortCriteria.value,
                  isDense: true,
                  items: const [
                    DropdownMenuItem(value: 'plays', child: Text('By Plays')),
                    DropdownMenuItem(
                        value: 'active', child: Text('By Active Users')),
                    DropdownMenuItem(
                        value: 'revenue', child: Text('By Revenue')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.gameSortCriteria.value = value;
                      controller.loadTopGames(sortBy: value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 400;

            return games.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No game data available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: games.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final game = games[index];
                      final gameId = game['id'] as String;
                      final gameName = game['name'] as String;
                      final gameImage = game['image'] as String?;
                      final value =
                          game[controller.gameSortCriteria.value] as int? ?? 0;
                      final growth = game['growth'] as int? ?? 0;
                      final isPositive = growth >= 0;

                      return ListTile(
                        contentPadding: isNarrow
                            ? const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0)
                            : null,
                        leading: Container(
                          width: isNarrow ? 30 : 40,
                          height: isNarrow ? 30 : 40,
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
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.sports_esports,
                                        color: _getGameColor(gameId),
                                        size: isNarrow ? 16 : 24,
                                      );
                                    },
                                  ),
                                )
                              : Icon(
                                  Icons.sports_esports,
                                  color: _getGameColor(gameId),
                                  size: isNarrow ? 16 : 24,
                                ),
                        ),
                        title: Text(
                          gameName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isNarrow ? 13 : 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Row(
                          children: [
                            Flexible(
                              child: Text(
                                controller.gameSortCriteria.value == 'plays'
                                    ? '$value plays'
                                    : controller.gameSortCriteria.value ==
                                            'active'
                                        ? '$value active users'
                                        : '\$$value revenue',
                                style: TextStyle(fontSize: isNarrow ? 11 : 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isPositive
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: isPositive ? Colors.green : Colors.red,
                              size: isNarrow ? 10 : 12,
                            ),
                            Text(
                              '$growth%',
                              style: TextStyle(
                                color: isPositive ? Colors.green : Colors.red,
                                fontSize: isNarrow ? 10 : 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.chevron_right),
                          iconSize: isNarrow ? 16 : 24,
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          onPressed: () => _showGameDetails(game),
                        ),
                        onTap: () => _showGameDetails(game),
                      );
                    },
                  );
          }),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () =>
                  Get.find<AdminController>().tabController.animateTo(4),
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
                final timestamp =
                    log['timestamp'] as DateTime? ?? DateTime.now();

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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
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
              const Text(
                  'Detailed revenue information will be displayed here.'),
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

  void _showQuickActionsMenu(
      BuildContext context, DashboardController controller) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
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
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Turn back'),
            dense: true,
          ),
          onTap: () {
            Future.delayed(
              const Duration(milliseconds: 100),
              () => Get.back(),
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
                    initialValue:
                        'We are currently performing maintenance. Please check back later.',
                  ),
                  const SizedBox(height: 16),
                  Column(
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
                              DropdownMenuItem(
                                  value: 'system', child: Text('System')),
                              DropdownMenuItem(
                                  value: 'maintenance',
                                  child: Text('Maintenance')),
                              DropdownMenuItem(
                                  value: 'update', child: Text('Update')),
                              DropdownMenuItem(
                                  value: 'event', child: Text('Event')),
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
                              DropdownMenuItem(
                                  value: 'all', child: Text('All Users')),
                              DropdownMenuItem(
                                  value: 'admin', child: Text('Admins Only')),
                              DropdownMenuItem(
                                  value: 'moderator',
                                  child: Text('Moderators & Admins')),
                              DropdownMenuItem(
                                  value: 'new',
                                  child: Text('New Users (< 7 days)')),
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
                                      lastDate: DateTime.now()
                                          .add(const Duration(days: 365)),
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
                                          ? DateFormat('MMM dd, yyyy')
                                              .format(startDate!)
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
                                      initialDate: startDate!
                                          .add(const Duration(days: 1)),
                                      firstDate: startDate!
                                          .add(const Duration(days: 1)),
                                      lastDate: startDate!
                                          .add(const Duration(days: 365)),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          endDate != null
                                              ? DateFormat('MMM dd, yyyy')
                                                  .format(endDate!)
                                              : 'No End Date',
                                        ),
                                        if (endDate != null)
                                          IconButton(
                                            icon: const Icon(Icons.clear,
                                                size: 16),
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
                                successMessage(
                                    'Announcement created successfully!');
                                Get.find<DashboardController>()
                                    .loadActiveAnnouncements();
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
