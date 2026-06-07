#include <WiFi.h>
#include <FirebaseESP32.h>

#define WIFI_SSID "POCO X5 PRO"
#define WIFI_PASSWORD "asdfghjkl"

#define FIREBASE_HOST "https://project-1-e893e-default-rtdb.firebaseio.com/"
#define FIREBASE_AUTH "O2O5lAgAKQOYelAkaQCeNTdFhxxuUBdMt9oum5ok"

FirebaseData firebaseData;
FirebaseAuth firebaseAuth;
FirebaseConfig firebaseConfig;

#define ZC 27    // Zero Cross detection pin
#define TRIAC 26 // Triac pulse pin

volatile int dimTime = 7500;  // Default delay (Lamp OFF)

void IRAM_ATTR zeroCrossInterrupt() {
  if (dimTime >= 9500) return;  // No firing at ADC=0
  delayMicroseconds(dimTime);
  digitalWrite(TRIAC, HIGH);
  delayMicroseconds(100);  // More reliable pulse
  digitalWrite(TRIAC, LOW);
}



void setup() {
  pinMode(ZC, INPUT_PULLUP);
  pinMode(TRIAC, OUTPUT);
  digitalWrite(TRIAC, LOW);

  Serial.begin(115200);

  firebaseConfig.host = FIREBASE_HOST;
  firebaseConfig.signer.tokens.legacy_token = FIREBASE_AUTH;

  Firebase.begin(&firebaseConfig, &firebaseAuth);
  Firebase.reconnectWiFi(true);

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");

  attachInterrupt(digitalPinToInterrupt(ZC), zeroCrossInterrupt, RISING);
}

void loop() {
  if (Firebase.getInt(firebaseData, "/PWM")) {
    int adcValue = firebaseData.intData();  // 0 - 4095
    Serial.print("Retrieved ADC Value: ");
    Serial.println(adcValue);

    dimTime = map(adcValue, 0, 4095, 9500, 400);
    Serial.print("Calculated dimTime: ");
    Serial.println(dimTime);
  } else {
    Serial.print("Failed to get data: ");
    Serial.println(firebaseData.errorReason());
  }
}

