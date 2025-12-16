/*
 * ========================================
 *       MINI DRYER ESP32 + FIREBASE
 *       (Using HTTPClient REST API)
 * ========================================
 * 
 * Hardware:
 * - ESP32
 * - DHT11 Temperature & Humidity Sensor
 * - 1 Channel Relay Module
 * - Buzzer
 */

#include <Arduino.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <DHT.h>

// ================= WIFI =================
#define WIFI_SSID     "Second Cup"
#define WIFI_PASSWORD "secondcup"

// ================= FIREBASE =================
// Firebase Realtime Database URL (tanpa trailing slash)
#define FIREBASE_HOST "https://drys-2711e-default-rtdb.asia-southeast1.firebasedatabase.app"

// ================= PIN =================
#define PIN_DHT     4    // D4
#define PIN_RELAY   27   // D27
#define PIN_BUZZER  15   // D15

// ================= SENSOR =================
#define DHTTYPE DHT11
DHT dht(PIN_DHT, DHTTYPE);

// ================= PARAMETER =================
#define MAX_TEMP        50.0   // °C - Overheat threshold
#define TARGET_HUM      60.0   // % - Target humidity (dry)
#define READ_INTERVAL   2500   // ms - Sensor read interval
#define FIREBASE_INTERVAL 3000 // ms - Firebase update interval

// ================= RELAY & BUZZER LOGIC =================
#define RELAY_ON   LOW
#define RELAY_OFF  HIGH
#define BUZZ_ON    HIGH
#define BUZZ_OFF   LOW

// ================= STATE =================
unsigned long lastRead = 0;
unsigned long lastFirebaseUpdate = 0;
bool finishBeeped = false;

// Control states from Firebase
bool powerOn = false;
bool autoMode = true;

// Current sensor values
float currentTemp = 0;
float currentHum = 0;
String currentState = "IDLE";
String currentMessage = "Menunggu...";
bool relayState = false;
bool buzzerState = false;

// ================= FUNCTIONS =================

void beep(int times) {
  for (int i = 0; i < times; i++) {
    digitalWrite(PIN_BUZZER, BUZZ_ON);
    delay(300);
    digitalWrite(PIN_BUZZER, BUZZ_OFF);
    delay(200);
  }
}

void connectWiFi() {
  Serial.print("Connecting to WiFi");
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 30) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println();
    Serial.println("WiFi Connected!");
    Serial.print("IP Address: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println();
    Serial.println("WiFi Connection Failed!");
  }
}

// Read control values from Firebase
void readControlFromFirebase() {
  if (WiFi.status() != WL_CONNECTED) return;
  
  HTTPClient http;
  String url = String(FIREBASE_HOST) + "/dryer/control.json";
  
  http.begin(url);
  int httpCode = http.GET();
  
  if (httpCode == HTTP_CODE_OK) {
    String payload = http.getString();
    
    // Parse JSON
    JsonDocument doc;
    DeserializationError error = deserializeJson(doc, payload);
    
    if (!error) {
      if (doc.containsKey("power")) {
        powerOn = doc["power"].as<bool>();
      }
      if (doc.containsKey("auto_mode")) {
        autoMode = doc["auto_mode"].as<bool>();
      }
      Serial.println("Control read: power=" + String(powerOn) + ", auto=" + String(autoMode));
    }
  } else {
    Serial.println("Firebase GET failed: " + String(httpCode));
  }
  
  http.end();
}

// Send sensor data to Firebase
void sendDataToFirebase() {
  if (WiFi.status() != WL_CONNECTED) return;
  
  HTTPClient http;
  
  // Create JSON payload
  JsonDocument doc;
  
  // Sensor data
  doc["sensor"]["temperature"] = currentTemp;
  doc["sensor"]["humidity"] = currentHum;
  doc["sensor"]["timestamp"] = millis();
  
  // Status data
  doc["status"]["relay"] = relayState;
  doc["status"]["buzzer"] = buzzerState;
  doc["status"]["state"] = currentState;
  doc["status"]["message"] = currentMessage;
  
  // Control data (preserve current state)
  doc["control"]["power"] = powerOn;
  doc["control"]["auto_mode"] = autoMode;
  
  String jsonString;
  serializeJson(doc, jsonString);
  
  // PATCH to update data
  String url = String(FIREBASE_HOST) + "/dryer.json";
  http.begin(url);
  http.addHeader("Content-Type", "application/json");
  
  int httpCode = http.PATCH(jsonString);
  
  if (httpCode == HTTP_CODE_OK) {
    Serial.println("Firebase update OK");
  } else {
    Serial.println("Firebase PATCH failed: " + String(httpCode));
  }
  
  http.end();
}

// Initialize Firebase with default values
void initFirebaseData() {
  if (WiFi.status() != WL_CONNECTED) return;
  
  HTTPClient http;
  String url = String(FIREBASE_HOST) + "/dryer/control.json";
  
  http.begin(url);
  int httpCode = http.GET();
  
  // If no data exists, create initial structure
  if (httpCode == HTTP_CODE_OK) {
    String payload = http.getString();
    if (payload == "null") {
      http.end();
      
      // Create initial data
      JsonDocument doc;
      doc["power"] = false;
      doc["auto_mode"] = true;
      
      String jsonString;
      serializeJson(doc, jsonString);
      
      http.begin(url);
      http.addHeader("Content-Type", "application/json");
      http.PUT(jsonString);
      Serial.println("Firebase initialized with default values");
    }
  }
  
  http.end();
}

void printStatus() {
  Serial.println("==============================");
  Serial.println(" MINI DRYER STATUS");
  Serial.println("==============================");
  Serial.print("WiFi      : ");
  Serial.println(WiFi.status() == WL_CONNECTED ? "Connected" : "Disconnected");
  Serial.print("Suhu      : ");
  Serial.print(currentTemp);
  Serial.println(" °C");
  Serial.print("Kelembapan: ");
  Serial.print(currentHum);
  Serial.println(" %");
  Serial.print("Power     : ");
  Serial.println(powerOn ? "ON" : "OFF");
  Serial.print("Auto Mode : ");
  Serial.println(autoMode ? "ON" : "OFF");
  Serial.print("Status    : ");
  Serial.println(currentState);
  Serial.print("Message   : ");
  Serial.println(currentMessage);
  Serial.print("Relay     : ");
  Serial.println(relayState ? "ON" : "OFF");
  Serial.print("Buzzer    : ");
  Serial.println(buzzerState ? "ON" : "OFF");
  Serial.println("==============================");
}

void setup() {
  Serial.begin(115200);
  
  // Initialize pins
  pinMode(PIN_RELAY, OUTPUT);
  pinMode(PIN_BUZZER, OUTPUT);
  digitalWrite(PIN_RELAY, RELAY_OFF);
  digitalWrite(PIN_BUZZER, BUZZ_OFF);
  
  // Initialize sensor
  dht.begin();
  
  Serial.println("=== MINI DRYER ESP32 + FIREBASE ===");
  Serial.println("Using HTTPClient REST API");
  
  // Connect to WiFi
  connectWiFi();
  
  // Initialize Firebase data
  if (WiFi.status() == WL_CONNECTED) {
    initFirebaseData();
  }
  
  // Start beep
  beep(1);
}

void loop() {
  // Reconnect WiFi if disconnected
  if (WiFi.status() != WL_CONNECTED) {
    connectWiFi();
  }
  
  // Read sensor at interval
  if (millis() - lastRead >= READ_INTERVAL) {
    lastRead = millis();
    
    // Read sensor
    float hum = dht.readHumidity();
    float temp = dht.readTemperature();
    
    // Handle sensor error
    if (isnan(hum) || isnan(temp)) {
      currentState = "ERROR";
      currentMessage = "Sensor tidak terbaca";
      currentTemp = 0;
      currentHum = 0;
      
      digitalWrite(PIN_RELAY, RELAY_OFF);
      digitalWrite(PIN_BUZZER, BUZZ_OFF);
      relayState = false;
      buzzerState = false;
      finishBeeped = false;
      
      printStatus();
      return;
    }
    
    currentTemp = temp;
    currentHum = hum;
    
    // Read control from Firebase
    readControlFromFirebase();
    
    // ===== POWER OFF (Manual) =====
    if (!powerOn) {
      digitalWrite(PIN_RELAY, RELAY_OFF);
      digitalWrite(PIN_BUZZER, BUZZ_OFF);
      relayState = false;
      buzzerState = false;
      
      currentState = "OFF";
      currentMessage = "Perangkat dimatikan";
      finishBeeped = false;
      
      printStatus();
      return;
    }
    
    // ===== OVERHEAT PROTECTION =====
    if (temp > MAX_TEMP) {
      digitalWrite(PIN_RELAY, RELAY_OFF);
      digitalWrite(PIN_BUZZER, BUZZ_ON);
      relayState = false;
      buzzerState = true;
      
      currentState = "OVERHEAT";
      currentMessage = "Suhu terlalu tinggi! Proteksi aktif";
      finishBeeped = false;
      
      printStatus();
      return;
    }
    
    // ===== AUTO MODE - CHECK IF DRY =====
    if (autoMode && hum <= TARGET_HUM) {
      digitalWrite(PIN_RELAY, RELAY_OFF);
      relayState = false;
      
      if (!finishBeeped) {
        beep(2);
        finishBeeped = true;
        buzzerState = true;
      } else {
        digitalWrite(PIN_BUZZER, BUZZ_OFF);
        buzzerState = false;
      }
      
      currentState = "DONE";
      currentMessage = "Pengeringan selesai!";
      
      printStatus();
      return;
    }
    
    // ===== DRYING =====
    digitalWrite(PIN_RELAY, RELAY_ON);
    digitalWrite(PIN_BUZZER, BUZZ_OFF);
    relayState = true;
    buzzerState = false;
    finishBeeped = false;
    
    currentState = "DRYING";
    currentMessage = "Pengeringan berjalan...";
    
    printStatus();
  }
  
  // Send data to Firebase at interval
  if (millis() - lastFirebaseUpdate >= FIREBASE_INTERVAL) {
    lastFirebaseUpdate = millis();
    sendDataToFirebase();
  }
}
