#include <WiFi.h>
#include <FirebaseESP32.h>

#define WIFI_SSID "POCO X5 PRO"
#define WIFI_PASSWORD "asdfghjkl"

#define FIREBASE_HOST "https://project-1-e893e-default-rtdb.firebaseio.com/"
#define FIREBASE_AUTH "O2O5lAgAKQOYelAkaQCeNTdFhxxuUBdMt9oum5ok"

// If using anonymous sign-in:
FirebaseData firebaseData;
FirebaseAuth firebaseAuth;
FirebaseConfig firebaseConfig;

#define POT_PIN 34

void setup() {
  Serial.begin(115200);
  Serial.println("Starting System...");

  firebaseConfig.host = FIREBASE_HOST;
    firebaseConfig.signer.tokens.legacy_token = FIREBASE_AUTH;
    
    Firebase.begin(&firebaseConfig, &firebaseAuth);
    Firebase.reconnectWiFi(true);
    
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    Serial.println("Connecting to WiFi...");
    while (WiFi.status() != WL_CONNECTED) {
        delay(1000);
        Serial.println("Still connecting...");
    }
    Serial.println("Connected to WiFi");
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
  }
  Serial.println(" connected!");
  Firebase.reconnectWiFi(true);
}

void loop() {
  int adcValue = analogRead(POT_PIN);
  Serial.print("ADC Value: ");
  Serial.println(adcValue);

  Firebase.setFloat(firebaseData, "/PWM", adcValue);


  delay(2000);
}
