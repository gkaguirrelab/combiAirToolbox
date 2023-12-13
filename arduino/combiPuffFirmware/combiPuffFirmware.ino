// Basic demo for configuring the MCP4728 4-Channel 12-bit I2C DAC
#include <Adafruit_MCP4728.h>
#include <Wire.h>

Adafruit_MCP4728 mcp;
const int buttonPin = 3;  // the number of the pushbutton pin
const int relayPin = 7;  // the number of the pushbutton pin
const int closeValPin = 11;  // the number of the pushbutton pin


//For Serial Communication
String inputString = "";         // a String to hold incoming data
bool stringComplete = false;  // whether the string is complete

// variables will change:
int buttonState = 0;  // variable for reading the pushbutton status
int state = 0;
int multiplier = 500;
bool rdy = false;
int pressureVal[] = {
  0, 107, 250, 535, 1111
};  //0, 3, 7, 15, 30
int pressureValPSI[] = {0, 5, 10, 15, 30};


int pressureValFull[] = {
  0, 178, 357, 535, 738, 914, 1111, 1291, 1468
}; //0,5,10,15,20,25,30,35,40
// int pressureValFull[] = {
//   0, 178, 357, 535, 738, 914, 1111, 1291, 1468
// }; //0,5,10,15,20,25,30,35,40

// int pressureReleaseTime[] = {0, 700, 900, 1200, 2200};
int pressureSetupTime[] = {250, 250, 250, 250, 250};
int pressureReleaseTime[] = {200, 200, 200, 200, 200};

bool startFlag = false;
int releaseTime  = 200;

int val0 = 0;
int val1, val2, val3, val4, val5;
char dtm[100];
int pressureIdx = 0;
char inputChar[4];
void setup(void) {
  Serial.begin(115200);
  while (!Serial)
    delay(10); // will pause Zero, Leonardo, etc until serial console opens

  Serial.println("Ready!");

  // Try to initialize!
  if (!mcp.begin()) {
    Serial.println("Failed to find MCP4728 chip");
    while (1) {
      delay(10);
    }
  }

  // initialize the pushbutton pin as an input:
  pinMode(buttonPin, INPUT_PULLUP);
  pinMode(relayPin, OUTPUT);
  pinMode(closeValPin, OUTPUT);
  mcp.setChannelValue(MCP4728_CHANNEL_A, 0);
  mcp.setChannelValue(MCP4728_CHANNEL_B, 0);
  mcp.setChannelValue(MCP4728_CHANNEL_C, 0);
  mcp.setChannelValue(MCP4728_CHANNEL_D, 0);
}


void loop() { 
  buttonState = digitalRead(buttonPin);

  // check if the pushbutton is pressed. If it is, the buttonState is HIGH:
  if (buttonState == HIGH) {
    rdy = true;
  } else {
    delay(100);
    if(!digitalRead(buttonPin))
    {
      if(rdy)
      {
        startFlag = true;
        rdy = false;
      }
    }
  }
  //for serial event
  checkSerial();
  if(startFlag) {
    switch(val0)
    {
      case 0:
        sequenceTest();
      break;
      case 1:
        Serial.println("sequenceA Start");
        sequenceA();
        
      break;
      case 2:
      Serial.println("sequenceB Start");
        sequenceB();
      break;
      default:
        sequenceTest();
      break;  
    }
    startFlag = false;
  }
}

void checkSerial()
{
  if (stringComplete) {
      if(inputString.indexOf("start") >= 0) {
          Serial.println("starting");
          startFlag = true;
      }
      else if(inputString.indexOf("stop") >= 0) {
          startFlag = false;
      }
      else if(inputString.indexOf("setp") >= 0) {
          Serial.println("Set pressure");
          strcpy( dtm, inputString.c_str());
          sscanf( dtm, "%s %d", inputChar, &pressureIdx);
          mcp.setChannelValue(MCP4728_CHANNEL_B, pressureVal[pressureIdx]);
          delay(2000);
          Serial.println("......Done");
      }
       else if(inputString.indexOf("sseq") >= 0) {
          Serial.println("Set sequence");
          strcpy( dtm, inputString.c_str());
          sscanf( dtm, "%s %d", inputChar, &val0);
          switch(val0)
          {
            case 0:
              printLine("set to test mode");
            break;
            case 1:
              printLine("set to sequence A");
              
            break;
            case 2:
              printLine("set to sequence B");
            break;
            default:
              printLine("set to test mode");
            break;  
          }
          
      }
      else
      {
        strcpy( dtm, inputString.c_str());
        sscanf( dtm, "%d", &val0);
        printLine("received: ", val0);
      }
      // clear the string:
      inputString = "";
      stringComplete = false;
  }
}

const int pressureIdxA = 3; //40 psi
const int seqALoop = 1;
const int cycleA = 3000; //in ms
// int onTimeA = pressureReleaseTime[pressureIdx];
// int offTimeA = cycleA - onTimeA;
const int totalTimeA = 5*60; //in sec
const int onLoopA = 5;
const int offLoopA = 1;


void sequenceA()
{
  //set the pressure
  // mcp.setChannelValue(MCP4728_CHANNEL_B, pressureVal[pressureIdxA]);
  // delay(1000);
  int onTimeA = pressureReleaseTime[pressureIdx];
  int offTimeA = cycleA - onTimeA;
  for (int i=0; i<seqALoop; i++)
  {  
    printLine("sequenceA Loop ", i+1, "/", seqALoop);
    for(int j=0; j<onLoopA; j++)
    {
        digitalWrite(relayPin, HIGH);
        delay(onTimeA);
        digitalWrite(relayPin, LOW);
        delay(offTimeA);
        // serialEvent();
        // checkSerial();
    } 
    for(int k=0; k<offLoopA; k++)
    {
        delay(cycleA);
        // serialEvent();
        // checkSerial();
    } 
  }
  Serial.println("sequenceA Finished");
  
}

const int randSequence[] = {
0,0,0,
1,4,4,3,1,1,3,4,3,1,
3,0,4,3,4,2,0,0,2,1,
0,3,3,0,3,4,0,2,4,2,
1,3,3,1,2,4,1,3,3,1,
4,4,2,0,0,2,1,3,0,0,
4,2,0,4,2,1,2,2,4,0,
2,2,0,1,3,1,4,4,2,0,
3,3,1,0,2,2,1,4,1,0,
0,0,0
};

const int seqBLoop = 86; //5*60/4;
const int settleTime = 1000;
const int cycleB = 4250; //in ms
// const int onTimeB = 100; //in ms
// const int offTimeB = cycleB - settleTime - onTimeB;


void sequenceB()
{  
  for (int i=0; i<seqBLoop; i++)
  {
    //get pressure index 
    //randSequence[i]
    //set the pressure
    printLine("sequenceB Loop ", i+1, "/", seqBLoop);
    mcp.setChannelValue(MCP4728_CHANNEL_B, pressureVal[randSequence[i]]);
    delay(settleTime);
    int onTimeB = pressureSetupTime[randSequence[i]]; //in ms
    int offTimeB = cycleB - settleTime - onTimeB; 
    digitalWrite(relayPin, HIGH);
    delay(onTimeB);
    digitalWrite(relayPin, LOW);
    int shutOffTimeB = pressureReleaseTime[randSequence[i]]; //in ms
    int waitOffTieB = offTimeB - shutOffTimeB;
    digitalWrite(closeValPin, HIGH);
    delay(shutOffTimeB);
    digitalWrite(closeValPin, LOW);
    delay(waitOffTieB);
  }
  Serial.println("sequenceB Finished");
}

void sequenceTest()
{
  // mcp.setChannelValue(MCP4728_CHANNEL_B, pressureVal[state]);
  // state++;
  //Serial.println("new val");
  // printLine("new val: ", pressureVal[state]);
  //trun on relay
  // int onTimeA = 
  // int offTimeA = cycleA - onTimeA;
  digitalWrite(relayPin, HIGH);
  delay(pressureSetupTime[pressureIdx]);
  digitalWrite(relayPin, LOW);
//   delay(100);
  digitalWrite(closeValPin, HIGH);
  delay(pressureReleaseTime[pressureIdx]);
  digitalWrite(closeValPin, LOW);
  // if (state > 5)
  // {
  //   state = 0;
  // }
}


void releaseValve()
{
  digitalWrite(relayPin, HIGH);
  delay(releaseTime);
  digitalWrite(relayPin, LOW);
}

void processString(String str)
{
  strcpy( dtm, str.c_str());
  sscanf( dtm, "%d", &val0);
//  printLine(lane, P1, P2, P3, P4, M1, M2 );
}


//For Serial Function
/*
  SerialEvent occurs whenever a new data comes in the hardware serial RX. This
  routine is run between each time loop() runs, so using delay inside loop can
  delay response. Multiple bytes of data may be available.
*/
void serialEvent() {
  while (Serial.available()) {
    // get the new byte:
    char inChar = (char)Serial.read();
    // add it to the inputString:
    inputString += inChar;
    // if the incoming character is a newline, set a flag so the main loop can
    // do something about it:
    if (inChar == '\n') {
      stringComplete = true;
    }
  }
}

//For printLine
void printLine()
{
  Serial.println();
}

template <typename T, typename... Types>
void printLine(T first, Types... other)
{
  Serial.print(first);
  printLine(other...) ;
}
