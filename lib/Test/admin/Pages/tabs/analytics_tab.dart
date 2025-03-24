import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:tictactoe_gameapp/Test/admin/controllers/admin_controller.dart';

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
          Row(
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
