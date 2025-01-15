import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Import the new screens
import 'screens2/temperature_screen.dart';
import 'screens2/humidity_screen.dart';
import 'screens2/soil_moisture_screen.dart';
import 'screens2/flow_rate_screen.dart';
import 'screens2/volume_screen.dart';
import 'help_screen2.dart';  // Import the new HelpScreen

class Field2Screen extends StatefulWidget {
  @override
  _Field2ScreenState createState() => _Field2ScreenState();
}

class _Field2ScreenState extends State<Field2Screen> {
  double? temperature;
  double? humidity;
  double? soilMoisture;
  double? flowRate;
  double? volume;
  int? lastRainDaysAgo;

  bool isAutomaticControlOn = false;
  bool isManualControlOn = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://localhost:8000/field_info/latest?field_id=f2'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        temperature = data['temp'];
        humidity = data['hum'];
        soilMoisture = data['soil_mois'];
        flowRate = data['flow_rate'];
        volume = data['volume'];
        lastRainDaysAgo = data['last_rain_days_ago'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> updateAutomaticControl(String status) async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/control/automatic'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'field_id': 'f2', 'status': status}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update automatic control');
    }
  }

  Future<void> updateManualControl(String status) async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/control/manual'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'field_id': 'f2', 'status': status}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update manual control');
    }
  }

  void toggleAutomaticControl() async {
    if (isManualControlOn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please turn off Manual Control before enabling Automatic Control')),
      );
      return;
    }

    setState(() {
      isAutomaticControlOn = !isAutomaticControlOn;
    });

    await updateAutomaticControl(isAutomaticControlOn ? 'on' : 'off');
  }

  void toggleManualControl() async {
    if (isAutomaticControlOn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please turn off Automatic Control before enabling Manual Control')),
      );
      return;
    }

    setState(() {
      isManualControlOn = !isManualControlOn;
    });

    await updateManualControl(isManualControlOn ? 'on' : 'off');
  }

  void navigateToScreen(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monitoring Status'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Row(
              children: [
                Icon(Icons.refresh),
                SizedBox(width: 4),
                Text('Refresh')
              ],
            ),
            onPressed: fetchData,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      'Pump Control',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: toggleAutomaticControl,
                        style: ElevatedButton.styleFrom(
                          primary: isAutomaticControlOn ? Colors.green : Colors.grey,
                        ),
                        child: Text(isAutomaticControlOn ? 'Automatic ON' : 'Automatic OFF'),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: flowRate != null && flowRate! > 0.1 ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          flowRate != null && flowRate! > 0.1 ? 'Pump ON' : 'Pump OFF',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: toggleManualControl,
                        style: ElevatedButton.styleFrom(
                          primary: isManualControlOn ? Colors.blue : Colors.grey,
                        ),
                        child: Text(isManualControlOn ? 'Manual ON' : 'Manual OFF'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  InkWell(
                    onTap: () => navigateToScreen(TemperatureScreen()),
                    child: _buildDataBox(
                      icon: Icons.thermostat_outlined,
                      label: 'Temperature',
                      value: temperature != null ? '$temperature°C' : 'Loading...',
                    ),
                  ),
                  InkWell(
                    onTap: () => navigateToScreen(HumidityScreen()),
                    child: _buildDataBox(
                      icon: Icons.water_damage_outlined,
                      label: 'Humidity',
                      value: humidity != null ? '$humidity%' : 'Loading...',
                    ),
                  ),
                  InkWell(
                    onTap: () => navigateToScreen(SoilMoistureScreen()),
                    child: _buildDataBox(
                      icon: Icons.grass,
                      label: 'Soil Moisture',
                      value: soilMoisture != null ? '$soilMoisture%' : 'Loading...',
                    ),
                  ),
                  _buildDataBox(
                    icon: Icons.calendar_today,
                    label: 'Last Rain',
                    value: lastRainDaysAgo != null
                        ? (lastRainDaysAgo == -1
                        ? 'Long ago'
                        : lastRainDaysAgo! > 0
                        ? '$lastRainDaysAgo days ago'
                        : 'Today')
                        : 'Loading...',
                  ),
                  InkWell(
                    onTap: () => navigateToScreen(FlowRateScreen()),
                    child: _buildDataBox(
                      icon: Icons.water,
                      label: 'Flow Rate',
                      value: flowRate != null ? '$flowRate L/min' : 'Loading...',
                    ),
                  ),
                  InkWell(
                    onTap: () => navigateToScreen(VolumeScreen()),
                    child: _buildDataBox(
                      icon: Icons.opacity,
                      label: 'Total Volume',
                      value: volume != null ? '$volume L' : 'Loading...',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Floating Action Button for Help
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the HelpScreen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HelpScreen2()),
          );
        },
        child: Icon(Icons.help_outline_rounded),
        backgroundColor: Colors.green,
      ),
      
    );
  }

  Widget _buildDataBox({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
