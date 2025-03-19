import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: const Drawer(),
      body: Column(
        children: [
          LineChart(
            LineChartData(
              gridData: const FlGridData(show: true),
              titlesData: const FlTitlesData(show: true),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    const FlSpot(0, 3),
                    const FlSpot(1, 1),
                    const FlSpot(2, 4),
                  ],
                  isCurved: true, // Đường cong
                  color: Colors.blue,
                  dotData: const FlDotData(show: false), // Ẩn điểm
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
