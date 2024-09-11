////////////////////////////////////////////////////////////////////////////////
// Firmware for the variable air puff engine
//
// This code supports the presentation of air puffs of specified duration and
// intensity, using a device custom-built by Vincent Lau
//
//
//
// In operation, the firmware supports placing the device in three states:
//  RUN MODE (RM) -- Present a pre-specified sequence of stimuli
//  CONFIG MODE (CM) -- Define the parameters to be used in run mode
//  DIRECT MODE (DM) -- Directly set and activate air puff stimuli
//
// Global variables of note:
//
//

// configuring the MCP4728 4-Channel 12-bit I2C DAC
#include <Adafruit_MCP4728.h>
#include <Wire.h>


////////////////////////// SIMULATE AIR PUFF  //////////////////////////////////
// Set this variable to use the built-in LED to simulate
// the output of the air puff device
//
bool simulateAirPuff = false;
////////////////////////////////////////////////////////////////////////////////

// Fixed hardware values
Adafruit_MCP4728 mcp;
const int controlLineBlack = 7;  // pin that controls the black trigger line
const int controlLineBlue = 11;  // pin that controls the blue trigger line

// Fixed values that define the time required for physical movement of various
// aspects of the stimulus delivery system
const int pressureSetTimeMs = 1000;     // Time required for adjusting the pressure line
const int pistonTransitDurMs = 250;     // Time required for the piston to change position
const int interPistonIntervalMs = 100;  // Brief delay between addressing the control lines

// Fixed value that defines the conversion of desired PSI to device setting
// We will eventually create a calibration procedure to set this value
const float psiToSetting = 35.7143;

// Define the device states
enum { CONFIG,
       RUN,
       DIRECT } deviceState = RUN;

// Global and control variables
const uint8_t inputStringLen = 12;  // size of the command string buffer
char inputString[inputStringLen];   // a character vector to hold incoming data
uint8_t inputCharIndex = 0;         // index to count our accumulated characters
bool stringComplete = false;        // whether the input string is complete
bool modulationState = false;       // When we are running, are we modulating?

// Timing variables
unsigned long trialDurMicroSecs = 4.5 * 1e6;  // Initialize at 4.5 s per trial
unsigned long sequenceStartTime = micros();   // Initialize these with the clock
unsigned long lastTrialStartTime = micros();  // Initialize these with the clock
int trialIdx = 0;                             // We begin waiting for the zeroth trial

// Safety limit
int maxSetting = 1500;

// Stimulus variables
float stimPressuresPSI[] = { 0, 3, 7, 15, 30 };
int stimDursMs[] = { 250, 250, 250, 250, 250 };
int stimIdxSeq[] = {
  0, 3,
  4, 0, 2, 3, 0, 0, 0, 4, 2, 2, 2, 3, 3, 3, 1, 4, 0, 1, 2, 4, 1, 3, 4, 3, 1,
  2, 2, 1, 4, 3, 4, 1, 1, 4, 1, 0, 0, 3, 1, 3, 3, 0, 4, 1, 4, 4, 0, 0, 1, 4,
  2, 0, 2, 4, 0, 3, 4, 2, 3, 2, 1, 2, 0, 0, 2, 0, 4, 4, 1, 2, 3, 1, 1, 1, 2,
  1, 3, 1, 0, 2, 2, 0, 3, 2, 3, 4, 4, 3, 3, 2, 2, 4, 2, 1, 0, 3, 0, 2, 1, 1,
  0, 1, 3, 2, 0, 1, 1, 3, 0, 1, 0, 4, 0, 4, 3, 2, 4, 4, 4, 2, 4, 3, 0, 3, 3,
  0, 0
};
int nTrials = sizeof(stimIdxSeq) / sizeof(stimIdxSeq[0]);

// Puff delivery values in direct mode
float stimPressurePSIDirect = 0;
int stimDurMsDirect = 0;

// setup
void setup() {
  // Initialize serial port communication
  Serial.begin(115200);
  while (!Serial)
    delay(10);  // will pause Zero, Leonardo, etc until serial console opens
  Serial.println("Ready!");

  // Try to initialize!
  if (!mcp.begin()) {
    Serial.println("Failed to find MCP4728 chip");
    while (1) {
      delay(10);
    }
  }

  // initialize the pushbutton pin as an input:
  // (GKA: Note sure if this is still used)
  pinMode(controlLineBlack, OUTPUT);
  pinMode(controlLineBlue, OUTPUT);
  mcp.setChannelValue(MCP4728_CHANNEL_A, 0);
  mcp.setChannelValue(MCP4728_CHANNEL_B, 0);
  mcp.setChannelValue(MCP4728_CHANNEL_C, 0);
  mcp.setChannelValue(MCP4728_CHANNEL_D, 0);

  // Set the pressure to the value of the first trial
  setPressure(stimPressuresPSI[stimIdxSeq[0]]);

  // Show the console menu
  showModeMenu();
}

// loop
void loop() {
  // Handle inputs dependent upon the deviceState
  switch (deviceState) {
    case CONFIG:
      getConfig();
      break;
    case DIRECT:
      getDirect();
      break;
    case RUN:
      getRun();
      break;
  }
  // Check if it is time for the next trial
  if (modulationState) {
    unsigned long currentTime = micros();
    if ((currentTime - lastTrialStartTime) > trialDurMicroSecs) {
      // Update the lastTime
      lastTrialStartTime = currentTime;
      // Report the trial
      printLine("trial: ", trialIdx + 1, " / ", nTrials, ", PSI: ", stimPressuresPSI[stimIdxSeq[trialIdx]]);
      // Deliver a puff
      deliverPuff(stimDursMs[stimIdxSeq[trialIdx]]);
      // Advance the trial count
      trialIdx++;
      // Set the pressure for the next trial
      setPressure(stimPressuresPSI[stimIdxSeq[trialIdx]]);
    }
    // Check if we have finished the sequence
    if (trialIdx > (nTrials - 1)) {
      float elapsedTimeSecs = (currentTime - sequenceStartTime) / 1e6;
      modulationState = false;
      printLine("Finished sequence. Elapsed time: ", elapsedTimeSecs + 1, " seconds.");
      setPressure(0);
      trialIdx = 0;
    }
  }
}

// Had to comment out the menu details as these serial entries
// eat up dynamic memory space.
void showModeMenu() {
  switch (deviceState) {
    case CONFIG:
      Serial.println("CM");
      break;
    case DIRECT:
      Serial.println("DM");
      break;
    case RUN:
      Serial.println("RM");
      break;
  }
}

void getConfig() {
  // Operate in modal state waiting for input
  waitForNewString();
  if (strncmp(inputString, "RM", 2) == 0) {
    // Switch to run mode
    modulationState = false;
    deviceState = RUN;
    // Set the pressure to the value of the first trial
    setPressure(stimPressuresPSI[stimIdxSeq[0]]);
    showModeMenu();
  }
  if (strncmp(inputString, "DM", 2) == 0) {
    // Switch to direct control mode
    modulationState = false;
    deviceState = DIRECT;
    showModeMenu();
  }
  if (strncmp(inputString, "SI", 2) == 0) {
    // Pass an index sequence
    Serial.println("SI:");
    clearInputString();
    waitForNewString();
    nTrials = atoi(inputString);
    Serial.println(nTrials);
    clearInputString();
    int stimIdxSeq[nTrials];
    for (int ii = 0; ii < nTrials; ii++) {
      waitForNewString();
      stimIdxSeq[ii] = atoi(inputString);
      Serial.println(stimIdxSeq[ii]);
      clearInputString();
    }
  }
  if (strncmp(inputString, "SP", 2) == 0) {
    // Pass a set of PSI levels
    Serial.println("SP:");
    clearInputString();
    float stimPressuresPSI[nTypes()];
    for (int ii = 0; ii < nTypes(); ii++) {
      waitForNewString();
      stimPressuresPSI[ii] = atof(inputString);
      Serial.println(stimPressuresPSI[ii]);
      clearInputString();
    }
  }
  if (strncmp(inputString, "SD", 2) == 0) {
    // Pass a set of stimulus durations
    Serial.println("SD:");
    clearInputString();
    int stimDursMs[nTypes()];
    for (int ii = 0; ii < nTypes(); ii++) {
      waitForNewString();
      stimDursMs[ii] = atoi(inputString);
      Serial.println(stimDursMs[ii]);
      clearInputString();
    }
  }
  clearInputString();
}

void getDirect() {
  // Operate in modal state waiting for input
  waitForNewString();

  // Set the stimulus pressure level.
  if (strncmp(inputString, "SP", 2) == 0) {
    Serial.println("SP:");
    clearInputString();
    waitForNewString();
    stimPressurePSIDirect = atoi(inputString);
    Serial.println(stimPressurePSIDirect);
    clearInputString();
    setPressure(stimPressurePSIDirect);
  }

  // Set the stimulus duration in ms.
  if (strncmp(inputString, "SD", 2) == 0) {
    Serial.println("SD:");
    clearInputString();
    waitForNewString();
    stimDurMsDirect = atoi(inputString);
    Serial.println(stimDurMsDirect);
    clearInputString();
  }

  // Issue a puff at the currently set pressure
  if (strncmp(inputString, "PP", 2) == 0) {
    Serial.println("PP:");
    clearInputString();
    deliverPuff(stimDurMsDirect);
  }

  if (strncmp(inputString, "RM", 2) == 0) {
    modulationState = false;
    deviceState = RUN;
    // Set the pressure to the value of the first trial
    setPressure(stimPressuresPSI[stimIdxSeq[0]]);
    showModeMenu();
  }
  if (strncmp(inputString, "CM", 2) == 0) {
    modulationState = false;
    deviceState = CONFIG;
    showModeMenu();
  }
  clearInputString();
}

void getRun() {
  // Operate in amodal state; only act if we have
  // a complete string
  pollSerialPort();
  if (stringComplete) {
    stringComplete = false;
    if (strncmp(inputString, "GO", 2) == 0) {
      Serial.println("Start sequence");
      trialIdx = 0;
      // Set the pressure to the value of the first trial
      setPressure(stimPressuresPSI[stimIdxSeq[0]]);
      modulationState = true;
      lastTrialStartTime = micros() - trialDurMicroSecs;
      sequenceStartTime = micros();
    }
    if (strncmp(inputString, "SP", 2) == 0) {
      Serial.println("Stop sequence");
      modulationState = false;
      setPressure(0);
    }
    if (strncmp(inputString, "DM", 2) == 0) {
      modulationState = false;
      deviceState = DIRECT;
      showModeMenu();
    }
    if (strncmp(inputString, "CM", 2) == 0) {
      modulationState = false;
      deviceState = CONFIG;
      showModeMenu();
    }
    clearInputString();
  }
}

void pollSerialPort() {
  // Detect the case that we have received a complete string but
  // have not yet finished doing something with it. In this case,
  // do not accept anything further from the buffer
  if ((stringComplete) && (inputCharIndex == 0)) return;
  // See if there is something in the buffer
  while (Serial.available()) {
    // get the new byte:
    char inChar = (char)Serial.read();
    // add it to the inputString:
    inputString[inputCharIndex] = inChar;
    inputCharIndex++;
    if (inputCharIndex >= inputStringLen) {
      Serial.println("ERROR: Input overflow inputString buffer");
      clearInputString();
      return;
    }
    // if the incoming character is a newline,
    // set a flag so the main loop can
    // do something about it.
    if (inChar == '\n') {
      stringComplete = true;
      inputCharIndex = 0;
    }
  }
}

void waitForNewString() {
  bool stillWaiting = true;
  while (!stringComplete) {
    pollSerialPort();
  }
}

// Clean-up after receiving inputString
void clearInputString() {
  for (int ii = 0; ii < inputStringLen; ii++) {
    inputString[ii] = "";
  }
  inputCharIndex = 0;
  stringComplete = false;
}

void setPressure(int pressureValPSI) {
  int pressureValSetting = round(pressureValPSI * psiToSetting);
  mcp.setChannelValue(MCP4728_CHANNEL_B, pressureValSetting);
  delay(pressureSetTimeMs);
}

void deliverPuff(int puffDuration) {
  // To deliver a puff we open the valve on the "controlLineBlack"
  // trigger line. This pushes the piston to the open position
  digitalWrite(controlLineBlack, HIGH);
  // We now wait for the puffDuration
  delay(puffDuration);
  // We now move the piston to the closed position. To do so,
  // we close the "controlLineBlack" valve, and open the valve
  // on the "controlLineBlue" trigger line. There is a brief delay
  // (the interPistonInterval) to allow the black control line to
  // drop in pressure before we attempt to pressurize the blue
  // control line.
  digitalWrite(controlLineBlack, LOW);
  delay(interPistonIntervalMs);
  digitalWrite(controlLineBlue, HIGH);
  // We now allow some time to pass so that the piston can move
  // back to the off position.
  delay(pistonTransitDurMs);
  // Close the valve for controlLineBlue, and we are done.
  digitalWrite(controlLineBlue, LOW);
}

int nTypes()  {
  int maxVal = 0;
  for (int ii = 0; ii < nTrials; ii++) {
    maxVal = max(stimIdxSeq[ii], maxVal);
  }
  maxVal = maxVal + 1;
  return maxVal;
}

//For printLine
void printLine() {
  Serial.println();
}

template<typename T, typename... Types>
void printLine(T first, Types... other) {
  Serial.print(first);
  printLine(other...);
}
