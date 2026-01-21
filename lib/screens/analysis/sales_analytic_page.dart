import 'dart:async';
import 'dart:convert';

import 'package:api_integration/serrvices/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  bool isLoading = true;
  Timer? _refreshTimer;

  double dailySales = 0;
  double monthlySales = 0;
  int totalOrders = 0;
  String mostSoldItem = '-';

  double maxY = 1000;
  List<BarChartGroupData> barChartData = [];

  @override
  void initState() {
    super.initState();
    fetchAnalytics();

    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) fetchAnalytics();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // 🔹 Round maxY to clean thousands
  double _roundedMaxY(double value) {
    if (value <= 0) return 1000;
    return ((value / 1000).ceil() * 1000).toDouble();
  }

  Future<void> fetchAnalytics() async {
    final token = await AuthService.getToken();
    final uri = Uri.parse('http://localhost:3000/api/v1/food/dashboard');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch analytics');
      }

      final body = jsonDecode(response.body);
      final data = body['data'];
      final List chart = data['salesChart'];

      final totals = chart
          .map<double>((e) => (e['total'] ?? 0).toDouble())
          .toList();

      final highest = totals.isEmpty
          ? 0.0
          : totals.reduce((a, b) => a > b ? a : b);

      setState(() {
        dailySales = (data['dailySales'] ?? 0).toDouble();
        monthlySales = (data['monthlySales'] ?? 0).toDouble();
        totalOrders = data['totalOrders'] ?? 0;
        mostSoldItem = data['mostSoldItem']?['title'] ?? '-';

        maxY = _roundedMaxY(highest as double);

        barChartData = List.generate(chart.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: (chart[index]['total'] ?? 0).toDouble(),
                color: Colors.green,
                width: 26,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        });

        isLoading = false;
      });
    } catch (e) {
      debugPrint('Analytics error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Analytics Dashboard')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchAnalytics,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _metricCard(
                          'Daily Sales',
                          '₹${dailySales.toInt()}',
                          Icons.today,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _metricCard(
                          'Monthly Sales',
                          '₹${monthlySales.toInt()}',
                          Icons.calendar_month,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _metricCard(
                          'Total Orders',
                          totalOrders.toString(),
                          Icons.receipt_long,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _metricCard(
                          'Most Sold',
                          mostSoldItem,
                          Icons.star,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Sales Trend (Last 7 Days)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 360,
                        child: BarChart(
                          BarChartData(
                            maxY: maxY,
                            alignment: BarChartAlignment.center,
                            groupsSpace: 60,
                      
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: maxY / 2,
                            ),
                      
                            borderData: FlBorderData(show: false),
                      
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: maxY / 2,
                                  getTitlesWidget: (value, _) {
                                    if (value == 0) return const Text('₹0');
                                    return Text(
                                      '₹${(value / 1000).toInt()}K',
                                      style: const TextStyle(fontSize: 11),
                                    );
                                  },
                                ),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, _) => Text(
                                    'D${value.toInt() + 1}',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              ),
                            ),
                      
                            barGroups: barChartData,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _metricCard(String title, String value, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: Colors.green, size: 28),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
