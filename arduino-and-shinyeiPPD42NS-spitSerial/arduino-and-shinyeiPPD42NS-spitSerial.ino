/*
 * Shinyei PPD42NS:
 *      JST Pin 1  => Arduino GND
 *      JST Pin 3  => Arduino 5VDC
 *      JST Pin 4  => Arduino Digital Pin 3

Dylos Air Quality Chart (1 micron)+
1000+ = VERY POOR
350 - 1000 = POOR
100 - 350 = FAIR
50 - 100 = GOOD
25 - 50 = VERY GOOD
0 - 25 = TOTALLY EXCELLENT, DUDE!
 */

#include <SoftwareSerial.h>

// settings for dust sensor
const byte particlePin1um = 2; // P1 pin, second from left on board
const byte particlePinP2 = 3; // P2 pin, particle size is variable
unsigned long duration1um;
unsigned long durationP2;
unsigned long startTime_ms_1um;
unsigned long startTime_ms_P2;
unsigned long sampleTime_ms_1um = 5000;
unsigned long sampleTime_ms_P2 = 5000;
unsigned long lowPulseOccupancy1um = 0;
unsigned long lowPulseOccupancyP2 = 0;
float ratio1um = 0;
float concentration1um = 0;
int particles1um; // for converting the average to an integer, fractions of a particle don't make sense
float ratioP2 = 0;
float concentrationP2 = 0;
int particlesP2;

void setup() {
  Serial.begin(9600);
    
  pinMode(particlePin1um, INPUT);
  pinMode(particlePinP2, INPUT);
  
  startTime_ms_1um = millis(); // get the current time in milliseconds
}

void loop() {
  duration1um = pulseIn(particlePin1um, LOW);
  lowPulseOccupancy1um = lowPulseOccupancy1um + duration1um;

  if ((millis()-startTime_ms_1um) >= sampleTime_ms_1um) // if the sample time has been exceeded
  {
    ratio1um = lowPulseOccupancy1um/(sampleTime_ms_1um*10.0);  // Integer percentage 0=>100; divide by 1000 to convert us to ms, multiply by 100 for %, end up dividing by 10
    concentration1um = 1.1*pow(ratio1um, 3) - 3.8*pow(ratio1um, 2) + 520*ratio1um; // using spec sheet curve for shinyei PPD42ns
    
    Serial.print("1um: ");
    Serial.println(concentration1um);
    lowPulseOccupancy1um = 0;
    startTime_ms_1um = millis(); // reset the timer for sampling at the end so it is as accurate as possible
  }
}
