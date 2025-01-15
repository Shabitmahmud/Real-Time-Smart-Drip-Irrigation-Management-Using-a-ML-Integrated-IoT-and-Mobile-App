import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HelpScreen extends StatefulWidget {
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final cropIdController = TextEditingController();
  final soilTypeController = TextEditingController();
  final seedlingStageController = TextEditingController();

  String predictionResult = '';
  String? selectedCropId;
  String? selectedSoilType;
  String? selectedSeedlingStage;

  // Function to call the API and get the prediction
  Future<void> getPrediction() async {
    final url = 'http://127.0.0.1:8000/predict'; // FastAPI URL

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'crop_id': selectedCropId,
          'soil_type': selectedSoilType,
          'seedling_stage': selectedSeedlingStage,
          'field_id': 'f1', // Pass the field_id value for field1
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          predictionResult = responseData['prediction'];
        });
        // Show the result in a pop-up dialog
        showPredictionDialog(context);
      } else {
        setState(() {
          predictionResult = 'Error: Unable to make prediction';
        });
        showPredictionDialog(context);
      }
    } catch (e) {
      setState(() {
        predictionResult = 'Error: $e';
      });
      showPredictionDialog(context);
    }
  }

  // Function to show the dialog with prediction result
  void showPredictionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.green.shade50, // Set the background color for the dialog
          title: Text('Prediction Result', style: TextStyle(color: Colors.green.shade800)),
          content: Text(
            predictionResult.isNotEmpty ? predictionResult : 'No prediction available.',
            style: TextStyle(fontSize: 16, color: Colors.green.shade800), // Text color
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close', style: TextStyle(color: Colors.green.shade800)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Irrigation Prediction'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        color: Colors.green.shade50, // Apply green.shade50 to the body background
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Dropdown for crop_id
            Theme(
              data: ThemeData(
                canvasColor: Colors.green.shade50, // Dropdown menu background color
              ),
              child: DropdownButtonFormField<String>(
                value: selectedCropId, // Bind to selectedCropId
                isDense: false, // This makes the dropdown larger
                decoration: InputDecoration(
                  labelText: 'Crop ID',
                  filled: true,
                  fillColor: Colors.green.shade50, // Background color for the dropdown
                  contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 12), // Increased padding to make the dropdown taller
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green.shade200), // Border for the dropdown button
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: ['Wheat', 'Potato', 'Carrot', 'Tomato', 'Chilli']
                    .map((crop) => DropdownMenuItem<String>(
                  value: crop,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      crop,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green.shade800),
                    ),
                  ),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCropId = value; // Update the selected value
                  });
                },
                iconEnabledColor: Colors.green.shade800, // Color for the dropdown arrow
                iconSize: 30, // Size of the dropdown arrow
              ),
            ),
            SizedBox(height: 16),
            // Dropdown for soil_type
            Theme(
              data: ThemeData(
                canvasColor: Colors.green.shade50, // Dropdown menu background color
              ),
              child: DropdownButtonFormField<String>(
                value: selectedSoilType, // Bind to selectedSoilType
                isDense: false, // This makes the dropdown larger
                decoration: InputDecoration(
                  labelText: 'Soil Type',
                  filled: true,
                  fillColor: Colors.green.shade50, // Background color for the dropdown
                  contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 12), // Increased padding to make the dropdown taller
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green.shade200), // Border for the dropdown button
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: [
                  'Black Soil',
                  'Alluvial Soil',
                  'Sandy Soil',
                  'Red Soil',
                  'Clay Soil',
                  'Loam Soil',
                  'Chalky Soil'
                ]
                    .map((soil) => DropdownMenuItem<String>(
                  value: soil,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      soil,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green.shade800),
                    ),
                  ),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSoilType = value; // Update the selected value
                  });
                },
                iconEnabledColor: Colors.green.shade800, // Color for the dropdown arrow
                iconSize: 30, // Size of the dropdown arrow
              ),
            ),
            SizedBox(height: 16),
            // Dropdown for seedling stage
            Theme(
              data: ThemeData(
                canvasColor: Colors.green.shade50, // Dropdown menu background color
              ),
              child: DropdownButtonFormField<String>(
                value: selectedSeedlingStage, // Bind to selectedSeedlingStage
                isDense: false, // This makes the dropdown larger
                decoration: InputDecoration(
                  labelText: 'Seedling Stage',
                  filled: true,
                  fillColor: Colors.green.shade50, // Background color for the dropdown
                  contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 12), // Increased padding to make the dropdown taller
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green.shade200), // Border for the dropdown button
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: [
                  'Germination',
                  'Seedling Stage',
                  'Vegetative Growth / Root or Tuber Development',
                  'Flowering',
                  'Pollination',
                  'Fruit/Grain/Bulb Formation',
                  'Maturation',
                  'Harvest'
                ]
                    .map((stage) => DropdownMenuItem<String>(
                  value: stage,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      stage,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green.shade800),
                    ),
                  ),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSeedlingStage = value; // Update the selected value
                  });
                },
                iconEnabledColor: Colors.green.shade800, // Color for the dropdown arrow
                iconSize: 30, // Size of the dropdown arrow
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: getPrediction,
              style: ElevatedButton.styleFrom(
                primary: Colors.green, // Set the background color to green
                onPrimary: Colors.white, // Set the text color to white
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24), // Padding for the button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
              ),
              child: Text(
                'Predict',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
