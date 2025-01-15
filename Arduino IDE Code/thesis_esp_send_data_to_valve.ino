#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <LoRa.h>

const char* ssid = "BDU-Hostel";
const char* password = "";
const char* serverUrl = "http://172.17.115.117/get_status.php";

String auto_status_f1;
String auto_status_f2;
String manual_status_f1;
String manual_status_f2;
String soil_mois_f1;
String soil_mois_f2;


float soil_mois_f1_float;
float soil_mois_f2_float;
String valve_f1;
String valve_f2;

#define ss 5
#define rst 14
#define dio0 2


void setup() {
  Serial.begin(115200);

  // Connect to Wi-Fi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi.");


  Serial.println("LoRa Sender");

  LoRa.setPins(ss, rst, dio0);  //setup LoRa transceiver module

  while (!LoRa.begin(435E6))  //433E6 - Asia, 866E6 - Europe, 915E6 - North America
  {
    Serial.println(".");
    delay(500);
  }
  //LoRa.setSyncWord(0xA5);


  Serial.println("LoRa Initializing OK!");
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;

    http.begin(serverUrl);
    int httpCode = http.GET();  // Send the request

    if (httpCode > 0) {  // Check for successful request
      Serial.print("HTTP Response Code: ");
      Serial.println(httpCode);

      String payload = http.getString();
      Serial.println("Payload received: " + payload);

      // Parse JSON response
      DynamicJsonDocument doc(1024);
      DeserializationError error = deserializeJson(doc, payload);

      if (error) {
        Serial.print("JSON Deserialization failed: ");
        Serial.println(error.c_str());
      } else {
        // Extract values from JSON
        auto_status_f1 = doc["auto_status_f1"].as<String>();
        auto_status_f2 = doc["auto_status_f2"].as<String>();
        manual_status_f1 = doc["manual_status_f1"].as<String>();
        manual_status_f2 = doc["manual_status_f2"].as<String>();
        soil_mois_f1 = doc["soil_mois_f1"].as<String>();
        soil_mois_f2 = doc["soil_mois_f2"].as<String>();

        //Convert string to float value
        soil_mois_f1_float = soil_mois_f1.toFloat();
        soil_mois_f2_float = soil_mois_f2.toFloat();

        // Print values for debugging
        Serial.println("Automatic Status F1: " + auto_status_f1);
        Serial.println("Automatic Status F2: " + auto_status_f2);
        Serial.println("Manual Status F1: " + manual_status_f1);
        Serial.println("Manual Status F2: " + manual_status_f2);
        Serial.println("Soil Moisture F1: " + soil_mois_f1);
        Serial.println("Soil Moisture F2: " + soil_mois_f2);
      }

    } else {
      Serial.print("Error on HTTP request, code: ");
      Serial.println(httpCode);
    }

    http.end();  // Close connection
  } else {
    Serial.println("WiFi disconnected, attempting reconnect...");
    WiFi.begin(ssid, password);
  }

  if (auto_status_f1 == "on") {

    if (soil_mois_f1_float < 50) {
      if (valve_f1 != "on") {
        Serial.println("F1 pump is on");
        valve_f1 = "on";
      }
    } else if (soil_mois_f1_float >= 70) {
      if (valve_f1 != "off") {
        Serial.println("F1 pump is off");
        valve_f1 = "off";
      }
    }

  } else {
    if (manual_status_f1 == "off") {

      Serial.println("F1 is off");
      valve_f1 = "off";
    } else {

      Serial.println("F1 is on");
      valve_f1 = "on";
    }
  }

  //for 2nd valve
  if (auto_status_f2 == "on") {
    if (soil_mois_f2_float < 50) {
      if (valve_f2 != "on") {
        Serial.println("F2 pump is on");
        valve_f2 = "on";
      }
    } else if (soil_mois_f2_float >= 70) {
      if (valve_f2 != "off") {
        Serial.println("F2 pump is off");
        valve_f2 = "off";
      }
    }
  } else {

    if (manual_status_f2 == "off") {

      Serial.println("F2 is off");
      valve_f2 = "off";


    } else {

      Serial.println("F2 is on");
      valve_f2 = "on";
    }
  }

  String data1 = String("svn") + valve_f1 + ",f1" + "-" + valve_f2 + ",f2";

  Serial.println(data1);

  LoRa.beginPacket();
  LoRa.print(data1);
  LoRa.endPacket();
  Serial.println("1");







  delay(2000);  // Wait 1 seconds between requests
}
