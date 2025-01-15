#include <SPI.h>
#include <LoRa.h>

int pump1 = 6;
int pump2 = 3;




void setup() {

  pinMode(pump1, OUTPUT);
  pinMode(pump2, OUTPUT);
  Serial.begin(115200);
  delay(100);


  Serial.println("LoRa Receiver");
  LoRa.setPins(10, 9);       // NSS and RST pins
  if (!LoRa.begin(435E6)) {  // Set frequency to 433 MHz
    Serial.println("Starting LoRa failed!");
    while (1)
      ;
  }
  Serial.println("ok");
  delay(50);

  digitalWrite(pump1, HIGH);
  delay(1000);
  digitalWrite(pump2, HIGH);
  delay(1000);
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

    String firstThree = receivedData.substring(0, 3);

    if (firstThree == "svn") {
      // Find the index of the hyphen
      int hyphenIndex = receivedData.indexOf('-');

      // Store everything from the fourth character up to the hyphen
      String middleSection = receivedData.substring(3, hyphenIndex);

      // Store everything after the hyphen
      String afterHyphen = receivedData.substring(hyphenIndex + 1);

      Serial.println("First three characters: " + firstThree);
      Serial.println("Middle section: " + middleSection);
      Serial.println("After hyphen: " + afterHyphen);

      int commaIndex = middleSection.indexOf(',');

      // Separate the values based on the comma position
      String firstValue = middleSection.substring(0, commaIndex);
      String secondValue = middleSection.substring(commaIndex + 1);

      int commaIndex1 = afterHyphen.indexOf(',');
      String thirdValue = afterHyphen.substring(0, commaIndex1);
      String fourthValue = afterHyphen.substring(commaIndex1 + 1);

      Serial.println(firstValue);
      Serial.println(secondValue);
      Serial.println(thirdValue);
      Serial.println(fourthValue);

      if (firstValue == "on") {
        digitalWrite(pump1, LOW);
        delay(1000);

      } else {
        digitalWrite(pump1, HIGH);
        delay(1000);
      }

      //delay(1000);

      if (thirdValue == "on") {
        digitalWrite(pump2, LOW);
        delay(1000);

      } else {
        digitalWrite(pump2, HIGH);
        delay(1000);
      }





      delay(4000);
    }
  }


  //delay(500);
}