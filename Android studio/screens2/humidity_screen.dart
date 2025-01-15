import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

class HumidityScreen extends StatefulWidget {
  @override
  _HumidityScreenState createState() => _HumidityScreenState();
}

class _HumidityScreenState extends State<HumidityScreen> {
  List<double> humidityData = [];
  List<String> timestamps = [];
  String selectedCondition = "Last 15 Values"; // Default selection

  @override
  void initState() {
    super.initState();
    fetchData('http://127.0.0.1:8000/humidity_last_15_values/?field_id=f2'); // Fetch default data for field_id = 'f2'
  }

  Future<void> fetchData(String apiUrl) async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);

        if (dataList.isNotEmpty) {
          setState(() {
            humidityData = dataList
                .map<double>((data) => data['humidity']?.toDouble() ?? 0.0)
                .toList();
            timestamps = dataList
                .map<String>((data) => data['timestamp']?.toString() ?? '')
                .toList();
          });
        } else {
          print('No data available');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2FFF2), // Light greenish background color
      appBar: AppBar(
        backgroundColor: Color(0xFF4CAF50), // Set AppBar color to green
        title: Text('Humidity Graph (Field 2)'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              if (selectedCondition == "Last 15 Values") {
                fetchData(
                    'http://127.0.0.1:8000/humidity_last_15_values/?field_id=f2');
              } else if (selectedCondition == "Last 7 Days Avg") {
                fetchData(
                    'http://127.0.0.1:8000/humidity_last_7_days_avg/?field_id=f2');
              } else if (selectedCondition == "Last 15 Days Avg") {
                fetchData(
                    'http://127.0.0.1:8000/humidity_last_15_days_avg/?field_id=f2');
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF4CAF50), // Green button
                    onPrimary: Colors.white,
                  ),
                  onPressed: () {
                    setState(() => selectedCondition = "Last 15 Values");
                    fetchData(
                        'http://127.0.0.1:8000/humidity_last_15_values/?field_id=f2');
                  },
                  child: Text("Last 15 Values"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF2196F3), // Blue button
                    onPrimary: Colors.white,
                  ),
                  onPressed: () {
                    setState(() => selectedCondition = "Last 7 Days Avg");
                    fetchData(
                        'http://127.0.0.1:8000/humidity_last_7_days_avg/?field_id=f2');
                  },
                  child: Text("Last 7 Days Avg"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFFFFC107), // Yellow button
                    onPrimary: Colors.black,
                  ),
                  onPressed: () {
                    setState(() => selectedCondition = "Last 15 Days Avg");
                    fetchData(
                        'http://127.0.0.1:8000/humidity_last_15_days_avg/?field_id=f2');
                  },
                  child: Text("Last 15 Days Avg"),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: humidityData.length.toDouble() - 1,
                  minY: 0,
                  maxY: (humidityData.isNotEmpty
                      ? humidityData.reduce((a, b) => a > b ? a : b)
                      : 100) +
                      10,
                  titlesData: FlTitlesData(
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTextStyles: (context, value) => const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                      margin: 10,
                      reservedSize: 30,
                      getTitles: (value) {
                        if (timestamps.isNotEmpty) {
                          int totalLabels = 4;
                          int interval =
                          (timestamps.length / (totalLabels - 1)).ceil();
                          if (value.toInt() % interval == 0 &&
                              value.toInt() < timestamps.length) {
                            return timestamps[value.toInt()];
                          }
                        }
                        return '';
                      },
                    ),
                    leftTitles: SideTitles(
                      showTitles: true,
                      getTextStyles: (context, value) => const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      margin: 10,
                      reservedSize: 70,
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  lineBarsData: [
                    if (humidityData.isNotEmpty)
                      LineChartBarData(
                        spots: List.generate(
                          humidityData.length,
                              (index) =>
                              FlSpot(index.toDouble(), humidityData[index]),
                        ),
                        isCurved: true,
                        colors: [Colors.orange],
                        barWidth: 2,
                        belowBarData: BarAreaData(show: false),
                      ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.blueAccent.withOpacity(0.8),
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((LineBarSpot touchedSpot) {
                          final xIndex = touchedSpot.x.toInt();
                          if (xIndex >= 0 && xIndex < timestamps.length) {
                            return LineTooltipItem(
                              'Timestamp: ${timestamps[xIndex]}, Humidity: ${touchedSpot.y.toStringAsFixed(2)}',
                              TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            );
                          }
                          return null;
                        }).toList();
                      },
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
}
