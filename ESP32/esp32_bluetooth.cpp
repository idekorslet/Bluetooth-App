#include "BluetoothSerial.h" 

BluetoothSerial ESP_BT; //Object for Bluetooth

char incoming;
int LED_BUILTIN = 2;

void setup() {
  // Serial.begin(115200); //Start Serial monitor in 115200
  ESP_BT.begin("ESP32_LED_Control"); //Name of your Bluetooth Signal
  // Serial.println("Bluetooth Device is Ready to Pair");

  pinMode (LED_BUILTIN, OUTPUT);//Specify that LED pin is output
}

void loop() {
  
  if (ESP_BT.available()) //Check if we receive anything from Bluetooth
  {
    incoming = ESP_BT.read(); //Read what we recevive 
    // Serial.print("Received:"); Serial.println(incoming);

    if (incoming == '1')
        {
        digitalWrite(LED_BUILTIN, HIGH);
        ESP_BT.println("LED turned ON");
        }
        
    if (incoming == '0')
        {
        digitalWrite(LED_BUILTIN, LOW);
        ESP_BT.println("LED turned OFF");
        }     
  }
  delay(20);
}