#include <DHT.h>
#include <LoRa.h>


volatile int flowFrequency1;  // Measures flow sensor pulses
float volume1 = 0.0, litersPerMinute1;

const unsigned char flowSensorPin1 = 2;  // Sensor input
unsigned long currentTime1;
unsigned long previousTime1;
  


volatile int flowFrequency2;  // Measures flow sensor pulses
float volume2 = 0.0, litersPerMinute2;

const unsigned char flowSensorPin2 = 3;  // Sensor input
unsigned long currentTime2;
unsigned long previousTime2;


void flow() {  // Interrupt function
  flowFrequency1++;
}

void flow_1() {  // Interrupt function
  flowFrequency2++;
}

#define DHTPIN1 4
#define DHTTYPE1 DHT11
DHT dht(DHTPIN1, DHTTYPE1);

#define rain_sensor A2
int rain_value;

int j;

void setup() {
  j = 0;
  Serial.begin(9600);
  dht.begin();


  LoRa.setPins(10, 9);  // NSS and RST pins
  if (!LoRa.begin(433E6)) {
    Serial.println("LoRa initialization failed. Check your connections.");
    while (true);
  }
 // LoRa.setSyncWord(0xA5);

  pinMode(flowSensorPin1, INPUT);
  digitalWrite(flowSensorPin1, HIGH);  // Optional internal pull-up


  attachInterrupt(digitalPinToInterrupt(flowSensorPin1), flow, RISING);  // Setup interrupt on rising edge
  Serial.println("Water Flow Meter");

  currentTime1 = millis();
  previousTime1 = currentTime1;

  //for 2nd flow meter
  pinMode(flowSensorPin2, INPUT);
  digitalWrite(flowSensorPin2, HIGH);  // Optional internal pull-up


  attachInterrupt(digitalPinToInterrupt(flowSensorPin2), flow_1, RISING);  // Setup interrupt on rising edge
  Serial.println("Water Flow Meter");

  currentTime2 = millis();
  previousTime2 = currentTime2;
}

void loop() {

  float humidity1 = dht.readHumidity();
  float temperature1 = dht.readTemperature();

  float soilMoisture1;
  int sensor_analog_1 = analogRead(A3);
  soilMoisture1 = (100 - ((sensor_analog_1 / 1023.00) * 100));

  float soilMoisture2;
  int sensor_analog_2 = analogRead(A4);
  soilMoisture2 = (100 - ((sensor_analog_2 / 1023.00) * 100));

  rain_value = analogRead(rain_sensor);
  if (rain_value < 140) {
    rain_value = 1;

  } else {
    rain_value = 0;
  }

  currentTime1 = millis();
  currentTime2 = millis();

  if (currentTime1 >= (previousTime1 + 1000)) {
    previousTime1 = currentTime1;  // Update previous time

    if (flowFrequency1 != 0) {
      

      // Pulse frequency (Hz) = 7.5Q, Q is flow rate in L/min
      litersPerMinute1 = flowFrequency1 / 7.5;

      // Convert L/min to L/sec for the current second
      float litersPerSecond1 = litersPerMinute1 / 60;

      // Calculate total volume
      volume1 += litersPerSecond1;

      // Display results
      Serial.print("Flow Rate_1: ");
      Serial.print(litersPerMinute1);
      Serial.println(" L/min");

      Serial.print("Volume_1: ");
      Serial.print(volume1);
      Serial.println(" L");

      Serial.print("Liters per second1: ");
      Serial.println(litersPerSecond1);

      // Reset the flow frequency counter for the next second
      flowFrequency1 = 0;
    } else {
      litersPerMinute1=0;
      Serial.println(" flow rate1 = 0 ");
    }
  }

  //2nd flow meter
  if (currentTime2 >= (previousTime2 + 1000)) {
    previousTime2 = currentTime2;  // Update previous time

    if (flowFrequency2 != 0) {
      // Reset zero flow counter if there is flow
      

      // Pulse frequency (Hz) = 7.5Q, Q is flow rate in L/min
      litersPerMinute2 = flowFrequency2 / 7.5;

      // Convert L/min to L/sec for the current second
      float litersPerSecond2 = litersPerMinute2 / 60;

      // Calculate total volume
      volume2 += litersPerSecond2;

      // Display results
      Serial.print("Flow Rate_2: ");
      Serial.print(litersPerMinute2);
      Serial.println(" L/min");

      Serial.print("Volume_2: ");
      Serial.print(volume2);
      Serial.println(" L");

      Serial.print("Liters per second_2: ");
      Serial.println(litersPerSecond2);

      // Reset the flow frequency counter for the next second
      flowFrequency2 = 0;
    } else {

      litersPerMinute2=0;
      Serial.println(" flow rate2 = 0 ");
    }
  }
  
  String data1 = String("sen") + "T:" + String(temperature1) + ", h:" + String(humidity1) + ", m:" + String(soilMoisture1) + ", r:" + String(rain_value) + ", f:" + String(litersPerMinute1) + ", v:" + String(volume1) + ", id:" + "f1" + "-" + "T:" + String(temperature1) + ", h:" + String(humidity1) + ", m:" + String(soilMoisture2) + ", r:" + String(rain_value) + ", f:" + String(litersPerMinute2) + ", v:" + String(volume2) + ", id:" + "f2";

  Serial.println(data1);

  LoRa.beginPacket();
  LoRa.print(data1);
  LoRa.endPacket();




 

delay(30000);

}  //loop close



//  This function returns the analog data to calling function
