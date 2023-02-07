#include <SoftwareSerial.h>
SoftwareSerial BTserial(0, 1); // RX | TX

// referensi cara compare char string: https://forum.arduino.cc/t/read-and-compare-string-form-serial-port/100028/3

#define CMDBUFFER_SIZE 30
#define redLed 12
#define greenLed 8

#define toTurnRedLedOn "arduRedLedOn"
#define toTurnRedLedOff "arduRedLedOff"

#define toTurnGreenLedOn "arduGreenLedOn"
#define toTurnGreenLedOff "arduGreenLedOff"

bool isBTConnected = false;

// connect the STATE pin on HC05 to Arduino pin D4
const byte hc05Pin = 4;
 
void setup() 
{
    // INPUT PIN
    pinMode(hc05Pin, INPUT); 

    // OUTPUT PIN 
    pinMode(greenLed, OUTPUT); 
    pinMode(redLed, OUTPUT); 
 
    // wait until the HC-05 has made a connection
    while (!isBTConnected)
    {
      if ( digitalRead(hc05Pin) == HIGH)  
      {
        isBTConnected = true;
      }
    }
 
    BTserial.begin(9600);  
}
 
void loop()
{
    char c;
    static char btBuffer[CMDBUFFER_SIZE] = "";
 
    // Keep reading from the HC-05 and send to Arduino Serial Monitor
    while (BTserial.available())
    {  
        c = processCharInput(btBuffer, BTserial.read());
        
        if (c == '\n') {
          // green LED
          if (strcmp(toTurnGreenLedOn, btBuffer) == 0)
          {
            digitalWrite(greenLed, HIGH);
          } 
          else if (strcmp(toTurnGreenLedOff, btBuffer) == 0)
          {
            digitalWrite(greenLed, LOW);
          }

          // red LED
          else if (strcmp(toTurnRedLedOn, btBuffer) == 0)
          {
            digitalWrite(redLed, HIGH);
          }
          else if (strcmp(toTurnRedLedOff, btBuffer) == 0)
          {
            digitalWrite(redLed, LOW);
          }

          btBuffer[0] = 0;
        }   
    }
}

char processCharInput(char* cmdBuffer, const char c)
{
  //Store the character in the input buffer
  if (c >= 32 && c <= 126) //Ignore control characters and special ascii characters
  {
    if (strlen(cmdBuffer) < CMDBUFFER_SIZE) 
    { 
      strncat(cmdBuffer, &c, 1);   //Add it to the buffer
    }
    else  
    {   
      return '\n';
    }
  }
  else if ((c == 8 || c == 127) && cmdBuffer[0] != 0) //Backspace
  {
    cmdBuffer[strlen(cmdBuffer)-1] = 0;
  }

  return c;
}
