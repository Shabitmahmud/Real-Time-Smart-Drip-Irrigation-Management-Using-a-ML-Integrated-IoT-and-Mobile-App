import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

class TemperatureScreen extends StatefulWidget {
  @override
  _TemperatureScreenState createState() => _TemperatureScreenState();
}

class _TemperatureScreenState extends State<TemperatureScreen> {
  List<double> temperatureData = [];
  List<String> timestamps = [];
  String selectedCondition = "Last 15 Values"; // Default selection

  @override
  void initState() {
    super.initState();
    fetchData('http://127.0.0.1:8000/last_15_values/?field_id=f1'); // Fetch default data
  }

  Future<void> fetchData(String apiUrl) async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);

        if (dataList.isNotEmpty) {
          setState(() {
            temperatureData = dataList.map<double>((data) => data['temp']?.toDouble() ?? 0.0).toList();
            timestamps = dataList.map<String>((data) => data['timestamp']?.toString() ?? '').toList();
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
        title: Text('Temperature Graph'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              if (selectedCondition == "Last 15 Values") {
                fetchData('http://127.0.0.1:8000/last_15_values/?field_id=f1');
              } else if (selectedCondition == "Last 7 Days Avg") {
                fetchData('http://127.0.0.1:8000/last_7_days_avg/?field_id=f1');
              } else if (selectedCondition == "Last 15 Days Avg") {
                fetchData('http://127.0.0.1:8000/last_15_days_avg/?field_id=f1');
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
                    fetchData('http://127.0.0.1:8000/last_15_values/?field_id=f1');
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
                    fetchData('http://127.0.0.1:8000/last_7_days_avg/?field_id=f1');
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
                    fetchData('http://127.0.0.1:8000/last_15_days_avg/?field_id=f1');
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
                  maxX: temperatureData.length.toDouble() - 1,
                  minY: 0,
                  maxY: (temperatureData.isNotEmpty ? temperatureData.reduce((a, b) => a > b ? a : b) : 100) + 10,
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
                          // Show 4 evenly spaced labels
                          int totalLabels = 4;
                          int interval = (timestamps.length / (totalLabels - 1)).ceil();
                          if (value.toInt() % interval == 0 && value.toInt() < timestamps.length) {
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
                    if (temperatureData.isNotEmpty)
                      LineChartBarData(
                        spots: List.generate(
                          temperatureData.length,
                              (index) => FlSpot(index.toDouble(), temperatureData[index]),
                        ),
                        isCurved: true,
                        colors: [Colors.red],
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
                              'Timestamp: ${timestamps[xIndex]}, Temp: ${touchedSpot.y.toStringAsFixed(2)}',
                              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
