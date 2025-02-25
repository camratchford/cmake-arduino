
#include <Arduino.h>

#define LED_PIN 13



void setup() {

    Serial.begin(UART_BAUD_RATE);
    pinMode(LED_PIN, INPUT);
    delay(500);

    for (;;) {
        digitalWrite(LED_PIN, HIGH);
        delay(1000);
        digitalWrite(LED_PIN, LOW);
        delay(1000);
    }
}

void loop() {

}
