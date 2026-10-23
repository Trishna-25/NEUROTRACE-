/*
  ============================================================
  NeuroTrace — Full Component Test Sketch
  ============================================================
  Tests every component on the fixed pin map (no pins changed).

  LIBRARIES TO INSTALL FIRST (Arduino IDE > Tools > Manage Libraries):
    1. "BH1750" by Christopher Laws
    2. "RTClib" by Adafruit
    3. "Adafruit MPU6050"
    4. "Adafruit BMP280 Library"
    5. "Adafruit AHTX0"

  Everything else (MAX30100, MAX17048, TMP117, I2S mic, SD card,
  SIM800L, GSR, button, motor, LEDs) uses only built-in ESP32/Wire
  functions — no extra libraries needed.

  ============================================================
  PIN MAP (fixed — matches wiring already done)
  ============================================================

  I2C bus       : SDA = GPIO21   SCL = GPIO22
  GSR sensor    : GPIO34 (analog)
  Push button   : GPIO27 (INPUT_PULLUP)
  Motor driver  : GPIO14 (base resistor -> transistor)
  LEDs          : GPIO25, GPIO26, GPIO32

  SIM800L UART  : TX2 = GPIO17 -> SIM RXD (via 1k resistor)
                  RX2 = GPIO16 <- SIM TXD

  SD card SPI   : CS = GPIO5
                  SCK18 / MISO19 / MOSI23 default VSPI

  I2S mic       : SCK = GPIO13
                  WS  = GPIO33
                  SD  = GPIO36 (labeled "SVP")

  ============================================================
  I2C ADDRESSES
  ============================================================

  0x23  BH1750
  0x57  MAX30100
  0x68  DS3231
  0x69  MPU6050
  0x76  BMP280
  0x36  MAX17048
  0x48  TMP117
  0x38  AHT20
*/

#include <Wire.h>
#include <SPI.h>
#include <SD.h>
#include "driver/i2s.h"

#include <BH1750.h>
#include <RTClib.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_BMP280.h>
#include <Adafruit_AHTX0.h>


// ============================================================
// PIN DEFINITIONS
// ============================================================

#define I2C_SDA     21
#define I2C_SCL     22

#define GSR_PIN     34
#define BUTTON_PIN  27
#define MOTOR_PIN   14

#define LED1_PIN    25
#define LED2_PIN    26
#define LED3_PIN    32

#define SIM_RX      16
#define SIM_TX      17

#define SD_CS       5

// I2S microphone
#define I2S_SCK_PIN 13
#define I2S_WS_PIN  33
#define I2S_SD_PIN  36


// ============================================================
// I2C ADDRESSES
// ============================================================

#define ADDR_BH1750    0x23
#define ADDR_MAX30100  0x57
#define ADDR_DS3231    0x68
#define ADDR_MPU6050   0x69
#define ADDR_BMP280    0x76
#define ADDR_MAX17048  0x36
#define ADDR_TMP117    0x48
#define ADDR_AHT20     0x38


// ============================================================
// OBJECTS
// ============================================================

BH1750 lightMeter;
RTC_DS3231 rtc;
Adafruit_MPU6050 mpu;
Adafruit_BMP280 bmp;
Adafruit_AHTX0 aht;


// ============================================================
// STATUS FLAGS
// ============================================================

bool ok_bh1750 = false;
bool ok_max30100 = false;
bool ok_ds3231 = false;
bool ok_mpu6050 = false;
bool ok_bmp280 = false;
bool ok_max17048 = false;
bool ok_tmp117 = false;
bool ok_aht20 = false;
bool ok_sd = false;
bool ok_sim = false;


// ============================================================
// VARIABLES
// ============================================================

unsigned long lastPrint = 0;

bool motorOn = false;
unsigned long lastMotorToggle = 0;


// ============================================================
// SETUP
// ============================================================

void setup() {

  Serial.begin(115200);
  delay(1500);

  Serial.println();
  Serial.println("============================================");
  Serial.println(" NeuroTrace — Component Test Starting");
  Serial.println("============================================");
  Serial.println();


  // ----------------------------------------------------------
  // Digital I/O
  // ----------------------------------------------------------

  pinMode(BUTTON_PIN, INPUT_PULLUP);

  pinMode(MOTOR_PIN, OUTPUT);

  pinMode(LED1_PIN, OUTPUT);
  pinMode(LED2_PIN, OUTPUT);
  pinMode(LED3_PIN, OUTPUT);

  digitalWrite(MOTOR_PIN, LOW);

  digitalWrite(LED1_PIN, LOW);
  digitalWrite(LED2_PIN, LOW);
  digitalWrite(LED3_PIN, LOW);


  // ----------------------------------------------------------
  // I2C
  // ----------------------------------------------------------

  Wire.begin(I2C_SDA, I2C_SCL);
  Wire.setClock(100000);


  // ----------------------------------------------------------
  // UART for SIM800L
  // ----------------------------------------------------------

  Serial2.begin(9600, SERIAL_8N1, SIM_RX, SIM_TX);


  // ----------------------------------------------------------
  // I2C SCAN
  // ----------------------------------------------------------

  runI2CScan();


  // ----------------------------------------------------------
  // TEST COMPONENTS
  // ----------------------------------------------------------

  ok_bh1750   = testBH1750Init();
  ok_max30100 = testMAX30100Identity();
  ok_ds3231   = testDS3231Init();
  ok_mpu6050  = testMPU6050Init();
  ok_bmp280   = testBMP280Init();
  ok_max17048 = testMAX17048Identity();
  ok_tmp117   = testTMP117Identity();
  ok_aht20    = testAHT20Init();

  ok_sd       = testSDCard();
  ok_sim      = testSIM800L();


  // ----------------------------------------------------------
  // I2S MICROPHONE
  // ----------------------------------------------------------

  testI2SMicInit();


  // ----------------------------------------------------------
  // SUMMARY
  // ----------------------------------------------------------

  Serial.println();
  Serial.println("---------------- SUMMARY ----------------");

  printResult("BH1750  (light)         ", ok_bh1750);
  printResult("MAX30100 (HR/SpO2)      ", ok_max30100);
  printResult("DS3231  (RTC)           ", ok_ds3231);
  printResult("MPU6050 (motion)        ", ok_mpu6050);
  printResult("BMP280  (pressure/temp) ", ok_bmp280);
  printResult("MAX17048 (battery)      ", ok_max17048);
  printResult("TMP117  (skin temp)     ", ok_tmp117);
  printResult("AHT20   (env temp/hum)  ", ok_aht20);
  printResult("SD card                 ", ok_sd);
  printResult("SIM800L                 ", ok_sim);

  Serial.println("I2S mic, GSR, button, motor, LEDs: watch live values below.");
  Serial.println("------------------------------------------");
  Serial.println();
}


// ============================================================
// PRINT RESULT
// ============================================================

void printResult(const char* name, bool ok) {

  Serial.print(name);

  if (ok) {
    Serial.println(": OK");
  }
  else {
    Serial.println(": NOT FOUND / FAILED");
  }
}


// ============================================================
// LOOP
// ============================================================

void loop() {


  // ----------------------------------------------------------
  // Motor
  // Pulse on/off every 1.5 seconds
  // ----------------------------------------------------------

  if (millis() - lastMotorToggle > 1500) {

    motorOn = !motorOn;

    digitalWrite(MOTOR_PIN, motorOn ? HIGH : LOW);

    lastMotorToggle = millis();
  }


  // ----------------------------------------------------------
  // LEDs
  // Simple chase pattern
  // ----------------------------------------------------------

  int phase = (millis() / 400) % 3;

  digitalWrite(LED1_PIN, phase == 0);
  digitalWrite(LED2_PIN, phase == 1);
  digitalWrite(LED3_PIN, phase == 2);


  // ----------------------------------------------------------
  // Print live sensor values every 2 seconds
  // ----------------------------------------------------------

  if (millis() - lastPrint > 2000) {

    lastPrint = millis();

    Serial.println("---- live readings ----");


    // --------------------------------------------------------
    // BH1750
    // --------------------------------------------------------

    if (ok_bh1750) {

      float lux = lightMeter.readLightLevel();

      Serial.print("Light: ");
      Serial.print(lux);
      Serial.println(" lx");
    }


    // --------------------------------------------------------
    // MPU6050
    // --------------------------------------------------------

    if (ok_mpu6050) {

      sensors_event_t a;
      sensors_event_t g;
      sensors_event_t temp;

      mpu.getEvent(&a, &g, &temp);

      Serial.print("Accel (m/s^2) X:");
      Serial.print(a.acceleration.x);

      Serial.print(" Y:");
      Serial.print(a.acceleration.y);

      Serial.print(" Z:");
      Serial.println(a.acceleration.z);
    }


    // --------------------------------------------------------
    // BMP280
    // --------------------------------------------------------

    if (ok_bmp280) {

      Serial.print("Pressure: ");
      Serial.print(bmp.readPressure() / 100.0F);

      Serial.print(" hPa  Temp(chip): ");
      Serial.print(bmp.readTemperature());

      Serial.println(" C");
    }


    // --------------------------------------------------------
    // AHT20
    // --------------------------------------------------------

    if (ok_aht20) {

      sensors_event_t hum;
      sensors_event_t tempA;

      aht.getEvent(&hum, &tempA);

      Serial.print("Env Temp: ");
      Serial.print(tempA.temperature);

      Serial.print(" C  Humidity: ");
      Serial.print(hum.relative_humidity);

      Serial.println(" %");
    }


    // --------------------------------------------------------
    // TMP117
    // --------------------------------------------------------

    if (ok_tmp117) {

      float skinTemp = readTMP117();

      Serial.print("Skin Temp (TMP117): ");
      Serial.print(skinTemp);

      Serial.println(" C");
    }


    // --------------------------------------------------------
    // MAX17048
    // --------------------------------------------------------

    if (ok_max17048) {

      float pct = readMAX17048Percent();

      Serial.print("Battery: ");
      Serial.print(pct);

      Serial.println(" %");
    }


    // --------------------------------------------------------
    // RTC
    // --------------------------------------------------------

    if (ok_ds3231) {

      DateTime now = rtc.now();

      Serial.print("RTC time: ");

      Serial.print(now.year());
      Serial.print('-');

      Serial.print(now.month());
      Serial.print('-');

      Serial.print(now.day());

      Serial.print(' ');

      Serial.print(now.hour());
      Serial.print(':');

      Serial.print(now.minute());
      Serial.print(':');

      Serial.println(now.second());
    }


    // --------------------------------------------------------
    // GSR
    // --------------------------------------------------------

    int gsrVal = analogRead(GSR_PIN);

    Serial.print("GSR raw: ");
    Serial.println(gsrVal);


    // --------------------------------------------------------
    // I2S MICROPHONE
    // --------------------------------------------------------

    int micAmp = readMicPeakAmplitude();

    Serial.print("Mic peak amplitude: ");
    Serial.println(micAmp);


    // --------------------------------------------------------
    // BUTTON
    // --------------------------------------------------------

    int btn = digitalRead(BUTTON_PIN);

    Serial.print("Button: ");

    if (btn == LOW) {
      Serial.println("PRESSED");
    }
    else {
      Serial.println("released");
    }


    Serial.println();
  }
}


// ============================================================
// I2C SCANNER
// ============================================================

void runI2CScan() {

  Serial.println("Scanning I2C bus...");

  byte count = 0;

  for (byte addr = 1; addr < 127; addr++) {

    Wire.beginTransmission(addr);

    if (Wire.endTransmission() == 0) {

      Serial.print("  Found device at 0x");

      if (addr < 16) {
        Serial.print("0");
      }

      Serial.println(addr, HEX);

      count++;
    }
  }

  Serial.print(count);
  Serial.println(" device(s) found.");
  Serial.println();
}


// ============================================================
// BH1750
// ============================================================

bool testBH1750Init() {

  Serial.println("Testing BH1750...");

  return lightMeter.begin();
}


// ============================================================
// MAX30100
// ============================================================

bool testMAX30100Identity() {

  Serial.println("Testing MAX30100 (identity register)...");

  Wire.beginTransmission(ADDR_MAX30100);

  Wire.write(0xFF);

  if (Wire.endTransmission(false) != 0) {
    return false;
  }

  Wire.requestFrom(ADDR_MAX30100, 1);

  if (Wire.available()) {

    byte id = Wire.read();

    Serial.print("  MAX30100 Part ID: 0x");
    Serial.println(id, HEX);

    return (id == 0x11);
  }

  return false;
}


// ============================================================
// DS3231
// ============================================================

bool testDS3231Init() {

  Serial.println("Testing DS3231...");

  if (!rtc.begin()) {
    return false;
  }

  if (rtc.lostPower()) {

    Serial.println("  RTC lost power — setting to compile time.");

    rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
  }

  return true;
}


// ============================================================
// MPU6050
// ============================================================

bool testMPU6050Init() {

  Serial.println("Testing MPU6050...");

  return mpu.begin(ADDR_MPU6050);
}


// ============================================================
// BMP280
// ============================================================

bool testBMP280Init() {

  Serial.println("Testing BMP280...");

  return bmp.begin(ADDR_BMP280);
}


// ============================================================
// MAX17048
// ============================================================

bool testMAX17048Identity() {

  Serial.println("Testing MAX17048 (presence check)...");

  Wire.beginTransmission(ADDR_MAX17048);

  return (Wire.endTransmission() == 0);
}


// ============================================================
// MAX17048 BATTERY %
 // ============================================================

float readMAX17048Percent() {

  Wire.beginTransmission(ADDR_MAX17048);

  Wire.write(0x04);

  Wire.endTransmission(false);

  Wire.requestFrom(ADDR_MAX17048, 2);

  if (Wire.available() == 2) {

    byte msb = Wire.read();
    byte lsb = Wire.read();

    return msb + (lsb / 256.0);
  }

  return -1;
}


// ============================================================
// TMP117
// ============================================================

bool testTMP117Identity() {

  Serial.println("Testing TMP117 (presence check)...");

  Wire.beginTransmission(ADDR_TMP117);

  return (Wire.endTransmission() == 0);
}


float readTMP117() {

  Wire.beginTransmission(ADDR_TMP117);

  Wire.write(0x00);

  Wire.endTransmission(false);

  Wire.requestFrom(ADDR_TMP117, 2);

  if (Wire.available() == 2) {

    int16_t raw = (Wire.read() << 8) | Wire.read();

    return raw * 0.0078125;
  }

  return -999;
}


// ============================================================
// AHT20
// ============================================================

bool testAHT20Init() {

  Serial.println("Testing AHT20...");

  return aht.begin();
}


// ============================================================
// SD CARD
// ============================================================

bool testSDCard() {

  Serial.println("Testing SD card...");

  if (!SD.begin(SD_CS)) {
    return false;
  }

  File f = SD.open("/test.txt", FILE_WRITE);

  if (!f) {
    return false;
  }

  f.println("NeuroTrace SD test OK");

  f.close();


  f = SD.open("/test.txt");

  bool gotData = f && f.available();

  if (f) {
    f.close();
  }

  return gotData;
}


// ============================================================
// SIM800L
// ============================================================

bool testSIM800L() {

  Serial.println("Testing SIM800L (sending AT)...");

  Serial2.println("AT");

  delay(1000);

  String resp = "";

  while (Serial2.available()) {

    resp += (char)Serial2.read();
  }

  Serial.print("  SIM800L response: ");
  Serial.println(resp);

  return resp.indexOf("OK") >= 0;
}


// ============================================================
// I2S MICROPHONE INITIALIZATION
// ============================================================

void testI2SMicInit() {

  Serial.println("Testing I2S microphone init...");


  // ----------------------------------------------------------
  // I2S CONFIGURATION
  // ----------------------------------------------------------

  i2s_config_t i2s_config = {

    .mode = (i2s_mode_t)(I2S_MODE_MASTER | I2S_MODE_RX),

    .sample_rate = 16000,

    .bits_per_sample = I2S_BITS_PER_SAMPLE_32BIT,

    // IMPORTANT:
    // Use both I2S slots.
    // Our testing showed the INMP441 data is in the LEFT slot.
    .channel_format = I2S_CHANNEL_FMT_RIGHT_LEFT,

    // Standard Philips I2S
    .communication_format = I2S_COMM_FORMAT_I2S,

    .intr_alloc_flags = 0,

    .dma_buf_count = 8,

    .dma_buf_len = 64,

    .use_apll = false,

    .tx_desc_auto_clear = false,

    .fixed_mclk = 0
  };


  // ----------------------------------------------------------
  // I2S PIN CONFIGURATION
  // ----------------------------------------------------------

  i2s_pin_config_t pin_config = {

    .bck_io_num = I2S_SCK_PIN,

    .ws_io_num = I2S_WS_PIN,

    .data_out_num = I2S_PIN_NO_CHANGE,

    .data_in_num = I2S_SD_PIN
  };


  // ----------------------------------------------------------
  // INSTALL DRIVER
  // ----------------------------------------------------------

  esp_err_t result;

  result = i2s_driver_install(
    I2S_NUM_0,
    &i2s_config,
    0,
    NULL
  );

  Serial.print("  I2S driver install: ");
  Serial.println(result);


  // ----------------------------------------------------------
  // SET PINS
  // ----------------------------------------------------------

  result = i2s_set_pin(
    I2S_NUM_0,
    &pin_config
  );

  Serial.print("  I2S set pins: ");
  Serial.println(result);


  Serial.println("  I2S microphone ready.");
}


// ============================================================
// READ MICROPHONE PEAK AMPLITUDE
// ============================================================

int readMicPeakAmplitude() {

  const int SAMPLES = 256;

  int32_t buffer[SAMPLES];

  size_t bytesRead = 0;


  // ----------------------------------------------------------
  // READ I2S DATA
  // ----------------------------------------------------------

  i2s_read(
    I2S_NUM_0,
    (void*)buffer,
    sizeof(buffer),
    &bytesRead,
    portMAX_DELAY
  );


  int samplesRead = bytesRead / sizeof(int32_t);

  int32_t peak = 0;


  // ----------------------------------------------------------
  // PROCESS LEFT CHANNEL
  // ----------------------------------------------------------
  //
  // Buffer layout:
  //
  // buffer[0] = LEFT
  // buffer[1] = RIGHT
  // buffer[2] = LEFT
  // buffer[3] = RIGHT
  // ...
  //
  // Our INMP441 is producing the actual audio waveform
  // in the LEFT slot.
  // ----------------------------------------------------------

  for (int i = 0; i < samplesRead; i += 2) {

    // INMP441 data is left-aligned in the 32-bit I2S word.
    // Shift right by 8 to obtain the useful sample value.
    int32_t sample = buffer[i] >> 8;

    int32_t magnitude = abs(sample);


    if (magnitude > peak) {

      peak = magnitude;
    }
  }


  return peak;
}