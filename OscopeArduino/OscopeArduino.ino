#include <SPI.h>

#define CS_ADC 10

volatile byte valD = 0;
volatile byte valB = 0;
volatile unsigned int val = 0;
volatile int temp1 = 0;
volatile int temp2 = 0;
ISR(TIMER2_COMPB_vect){  // Interrupt service routine to pulse the modulated pin 3

}

void setIrModOutput(){  // sets pin 3 at 250kHz
 pinMode(3, OUTPUT);
 TCCR2A = _BV(COM2B1) | _BV(WGM21) | _BV(WGM20); // Just enable output on Pin 3 and disable it on Pin 11
 TCCR2B = _BV(WGM22) | _BV(CS22);
 OCR2A = 85; // defines the frequency 51 = 38.4 KHz, 54 = 36.2 KHz, 58 = 34 KHz, 62 = 32 KHz, 7 = 250 kHz   !!!!!!!IT WAS AT 7!!!!!!!!!!!
 OCR2B = round(OCR2A/2);  // deines the duty cycle - Half the OCR2A value for 50%
 TCCR2B = TCCR2B & 0b00111000 | 0x2; // select a prescale value of 8:1 of the system clock
}

void setup() {
 setIrModOutput();
 TIMSK2 = _BV(OCIE2B); // Output Compare Match B Interrupt Enable
 noInterrupts();
 pinMode(CS_ADC, OUTPUT);
 DDRD = B00001010;  //Set pins 4-7 as inputs, leave pins 0-3 alone
 DDRB = B11110000;  //Set pins 8-11 as inputs, leave others alone
 Serial.begin(1000000); // start serial communication at 9600bps
 attachInterrupt(0, readADC, FALLING);  
  //SPI.setDataMode(SPI_MODE2);
  //SPI.begin();
  delay(100); //A little set up time, just to make sure everything's stable
  Serial.println("Setup Complete");
  interrupts();
}

void loop() {
  //readADC();
 delay(10);
}

void readADC(){
  //Serial.println("Interrupt");
  //temp1 = micros();
  //valD = PIND;
  //Serial.print("PIND: ");
  //Serial.println(valD, BIN);
  //valB = PINB;
  //Serial.print("PINB: ");
  //Serial.println(valB, BIN);
  
  //Serial.println(valA, BIN);
  //Serial.println(valB, BIN);
  
  val = ((((PINB << 8) & 0xff00 ) | (PIND & 0xff)) >> 4) & 0xff;
  //Serial.println(val, BIN);
  //Serial.println(val, BIN);
  //val = (val >> 4) & 0xff;
  //Serial.println(val, BIN);
  //Serial.write(0xff);
  Serial.write(val);
  //Serial.println(val, BIN);
  //Serial.println();
  //Serial.println();
    //delayMicroseconds(50);
   //temp2 = micros();
   //Serial.println(temp2-temp1);
}
