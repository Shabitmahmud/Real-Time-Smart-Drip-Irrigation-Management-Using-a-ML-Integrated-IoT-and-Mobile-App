#include <LoRa.h>
#include <SPI.h>

#include <WiFi.h>
#include <HTTPClient.h>



#define HOST "172.17.115.117"
#define WIFI_SSID "BDU-Hostel"
#define WIFI_PASSWORD ""



#define ss 5
#define rst 14
#define dio0 2

void setup() {
  Serial.begin(115200);
  // while (!Serial);
  Serial.println("LoRa Receiver");

  LoRa.setPins(ss, rst, dio0);  //setup LoRa transceiver module

  while (!LoRa.begin(433E6))  //433E6 - Asia, 866E6 - Europe, 915E6 - North America
  {
    Serial.println(".");
    delay(500);
  }
 // LoRa.setSyncWord(0xA5);
  Serial.println("LoRa Initializing OK!");


  // Database
  Serial.println("Communication Started\n\n");


  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to ");
  Serial.println(WIFI_SSID);

  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
  }

  Serial.println();
  Serial.print("Connected to ");
  Serial.println(WIFI_SSID);
  Serial.print("IP Address is: ");
  Serial.println(WiFi.localIP());


  delay(700);
}

void loop() {
  int packetSize = LoRa.parsePacket();

  if (packetSize) {

    // received a packet
    String receivedData = "";
    Serial.println("Received packet :");


    // read packet

    while (LoRa.available()) {

      receivedData += (char)LoRa.read();
    }

    Serial.println(receivedData);

    // Store the first three characters
    String firstThree = receivedData.substring(0, 3);

    // Find the index of the hyphen
    int hyphenIndex = receivedData.indexOf('-');

    // Store everything from the fourth character up to the hyphen
    String middleSection = receivedData.substring(3, hyphenIndex);

    // Store everything after the hyphen
    String afterHyphen = receivedData.substring(hyphenIndex + 1);

    Serial.println("First three characters: " + firstThree);
    Serial.println("Middle section: " + middleSection);
    Serial.println("After hyphen: " + afterHyphen);

    if (firstThree == "sen") {



      //extract value
      // Find the indexes of the commas
      int i1 = middleSection.indexOf(',');
      int i2 = middleSection.indexOf(',', i1 + 1);
      int i3 = middleSection.indexOf(',', i2 + 1);
      int i4 = middleSection.indexOf(',', i3 + 1);
      int i5 = middleSection.indexOf(',', i4 + 1);
      int i6 = middleSection.indexOf(',', i5 + 1);

      // Extract each value based on the comma positions
      String firstValue = middleSection.substring(0, i1);
      String secondValue = middleSection.substring(i1 + 1, i2);
      String thirdValue = middleSection.substring(i2 + 1, i3);
      String fourthValue = middleSection.substring(i3 + 1, i4);
      String fifthValue = middleSection.substring(i4 + 1, i5);
      String sixthValue = middleSection.substring(i5 + 1, i6);
      String seventhValue = middleSection.substring(i6 + 5);

      // Print each extracted value
      Serial.println(firstValue);
      Serial.println(secondValue);
      Serial.println(thirdValue);
      Serial.println(fourthValue);
      Serial.println(fifthValue);
      Serial.println(sixthValue);
      Serial.println(seventhValue);

      // Convert each value to a float if it has a numeric part
      int colonIndex1 = firstValue.indexOf(':');
      String numericPart1 = firstValue.substring(colonIndex1 + 1);
      float firstValue1 = numericPart1.toFloat();
      Serial.println(firstValue1);

      int colonIndex2 = secondValue.indexOf(':');
      String numericPart2 = secondValue.substring(colonIndex2 + 1);
      float secondValue1 = numericPart2.toFloat();
      Serial.println(secondValue1);

      int colonIndex3 = thirdValue.indexOf(':');
      String numericPart3 = thirdValue.substring(colonIndex3 + 1);
      float thirdValue1 = numericPart3.toFloat();
      Serial.println(thirdValue1);

      int colonIndex4 = fourthValue.indexOf(':');
      String numericPart4 = fourthValue.substring(colonIndex4 + 1);
      float fourthValue1 = numericPart4.toFloat();
      Serial.println(fourthValue1);

      int colonIndex5 = fifthValue.indexOf(':');
      String numericPart5 = fifthValue.substring(colonIndex5 + 1);
      float fifthValue1 = numericPart5.toFloat();
      Serial.println(fifthValue1);

      int colonIndex6 = sixthValue.indexOf(':');
      String numericPart6 = sixthValue.substring(colonIndex6 + 1);
      float sixthValue1 = numericPart6.toFloat();
      Serial.println(sixthValue1);

      // For the seventh value, if it's a string identifier like "id:f1", you can print it directly or parse as needed
      Serial.println("Seventh Value: " + seventhValue);

      //After hyphen section
      // Find the indexes of the commas
      int j1 = afterHyphen.indexOf(',');
      int j2 = afterHyphen.indexOf(',', j1 + 1);
      int j3 = afterHyphen.indexOf(',', j2 + 1);
      int j4 = afterHyphen.indexOf(',', j3 + 1);
      int j5 = afterHyphen.indexOf(',', j4 + 1);
      int j6 = afterHyphen.indexOf(',', j5 + 1);

      // Extract each value based on the comma positions
      String firstValueAfter = afterHyphen.substring(0, j1);
      String secondValueAfter = afterHyphen.substring(j1 + 1, j2);
      String thirdValueAfter = afterHyphen.substring(j2 + 1, j3);
      String fourthValueAfter = afterHyphen.substring(j3 + 1, j4);
      String fifthValueAfter = afterHyphen.substring(j4 + 1, j5);
      String sixthValueAfter = afterHyphen.substring(j5 + 1, j6);
      String seventhValueAfter = afterHyphen.substring(j6 + 5);

      // Print each extracted value
      Serial.println(firstValueAfter);
      Serial.println(secondValueAfter);
      Serial.println(thirdValueAfter);
      Serial.println(fourthValueAfter);
      Serial.println(fifthValueAfter);
      Serial.println(sixthValueAfter);
      Serial.println(seventhValueAfter);

      // Convert each value to a float if it has a numeric part
      int colonIndex1After = firstValueAfter.indexOf(':');
      String numericPart1After = firstValueAfter.substring(colonIndex1After + 1);
      float firstValueFloatAfter = numericPart1After.toFloat();
      Serial.println(firstValueFloatAfter);

      int colonIndex2After = secondValueAfter.indexOf(':');
      String numericPart2After = secondValueAfter.substring(colonIndex2After + 1);
      float secondValueFloatAfter = numericPart2After.toFloat();
      Serial.println(secondValueFloatAfter);

      int colonIndex3After = thirdValueAfter.indexOf(':');
      String numericPart3After = thirdValueAfter.substring(colonIndex3After + 1);
      float thirdValueFloatAfter = numericPart3After.toFloat();
      Serial.println(thirdValueFloatAfter);

      int colonIndex4After = fourthValueAfter.indexOf(':');
      String numericPart4After = fourthValueAfter.substring(colonIndex4After + 1);
      float fourthValueFloatAfter = numericPart4After.toFloat();
      Serial.println(fourthValueFloatAfter);

      int colonIndex5After = fifthValueAfter.indexOf(':');
      String numericPart5After = fifthValueAfter.substring(colonIndex5After + 1);
      float fifthValueFloatAfter = numericPart5After.toFloat();
      Serial.println(fifthValueFloatAfter);

      int colonIndex6After = sixthValueAfter.indexOf(':');
      String numericPart6After = sixthValueAfter.substring(colonIndex6After + 1);
      float sixthValueFloatAfter = numericPart6After.toFloat();
      Serial.println(sixthValueFloatAfter);

      // For the seventh value, if it's a string identifier like "id:f2", you can print it directly or parse as needed
      Serial.println("Seventh Value After: " + seventhValueAfter);





      // int i1 = receivedData.indexOf(',');
      // int i2 = receivedData.indexOf(',', i1 + 1);
      // int i3 = receivedData.indexOf(',', i2 + 1);





      // String firstValue = receivedData.substring(0, i1);
      // String secondValue = receivedData.substring(i1 + 1, i2);
      // String thirdValue = receivedData.substring(i2 + 1, i3);
      // String fourthValue = receivedData.substring(i3 + 1);


      // Serial.println(firstValue);
      // Serial.println(secondValue);
      // Serial.println(thirdValue);
      // Serial.println(fourthValue);


      // int colonIndex1 = firstValue.indexOf(':');
      // String numericPart1 = firstValue.substring(colonIndex1 + 1);
      // float firstValue1 = numericPart1.toFloat();
      // Serial.println(firstValue1);

      // int colonIndex2 = secondValue.indexOf(':');
      // String numericPart2 = secondValue.substring(colonIndex2 + 1);
      // float secondValue1 = numericPart2.toFloat();
      // Serial.println(secondValue1);




      // int colonIndex = thirdValue.indexOf(':');
      // String numericPart = thirdValue.substring(colonIndex + 1);
      // float thirdValue1 = numericPart.toFloat();
      // Serial.println(thirdValue1);

      // int colonIndex3 = fourthValue.indexOf(':');
      // String numericPart3 = fourthValue.substring(colonIndex3 + 1);
      // float fourthValue1 = numericPart3.toFloat();
      // Serial.println(fourthValue1);

      // // Database

      WiFiClient client;
      HTTPClient http;


      // Convert float variables to strings for middleSection values
      String sendval1 = String(firstValue1);
      String sendval2 = String(secondValue1);
      String sendval3 = String(thirdValue1);
      String sendval4 = String(fourthValue1);
      String sendval5 = String(fifthValue1);
      String sendval6 = String(sixthValue1);
      String sendval7 = seventhValue;  // If it's an ID string like "id:f1"

      // Convert float variables to strings for afterHyphen values
      String sendval8 = String(firstValueFloatAfter);
      String sendval9 = String(secondValueFloatAfter);
      String sendval10 = String(thirdValueFloatAfter);
      String sendval11 = String(fourthValueFloatAfter);
      String sendval12 = String(fifthValueFloatAfter);
      String sendval13 = String(sixthValueFloatAfter);
      String sendval14 = seventhValueAfter;  // If it's an ID string like "id:f2"

      // Prepare the POST data
      String postData = "sendval1=" + sendval1 + "&sendval2=" + sendval2 + "&sendval3=" + sendval3 + "&sendval4=" + sendval4 + "&sendval5=" + sendval5 + "&sendval6=" + sendval6 + "&sendval7=" + sendval7 + "&sendval8=" + sendval8 + "&sendval9=" + sendval9 + "&sendval10=" + sendval10 + "&sendval11=" + sendval11 + "&sendval12=" + sendval12 + "&sendval13=" + sendval13 + "&sendval14=" + sendval14;

      http.begin(client, "http://" + String(HOST) + "/nodemcu/dbwrite.php");
      http.addHeader("Content-Type", "application/x-www-form-urlencoded");

      int httpCode = http.POST(postData);

      Serial.println("Values are: " + postData);

      if (httpCode > 0) {
        Serial.println("HTTP Code: " + String(httpCode));
        String response = http.getString();
        Serial.println("Server Response: " + response);
      } else {
        Serial.println("HTTP request failed");
      }

      http.end();
      Serial.println("ok");
      delay(20000);
    }
  }
}