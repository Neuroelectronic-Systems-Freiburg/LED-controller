#include <SPI.h>
#include <avr/wdt.h>
/* -------------------------------------------------------------------- */
/*                     Setup Function                         */
/* -------------------------------------------------------------------- */
String p;
String tt;
String myString;
float power_converted = 3380;
int port;
int power;
int led;
int state;
int pulse_width_on;
int pulse_width_off;
int on_switch;
int rep_Times;
String xxValue = "yy";
// State of the LED, Digital Output LED, DAC output (VOUTB=)
int my_led[3] = {0, 2, 1};
int BNC = 3;

void setup()
{
  // set SPI and a user LED to be outputs
  Serial.begin(9600);
  // set SPI and a user LED to be outputs
  pinMode(SS, OUTPUT);
  pinMode(MOSI, OUTPUT);
  pinMode(SCK, OUTPUT);
  //was previously 50
  pinMode(5, OUTPUT);
  //output pins
  pinMode(2, OUTPUT);
  pinMode(3, OUTPUT);
  pinMode(4, OUTPUT);
  pinMode(A5, OUTPUT);
  pinMode(LED_BUILTIN, OUTPUT);

  digitalWrite(my_led[1], HIGH);//turn off LED
  delay(5);
  SPI.begin(); // starts the SPI library object
  SPI.setBitOrder(MSBFIRST); // during the transfer of data, send the most significant bit first
  SPI.setDataMode(SPI_MODE0); // Clock starts at a LOW value and transmits data on the falling edge of the clock signal
  delay(5);
  digitalWrite(SS, LOW); // selecting the DAC
  setUpDAC(); // user defined function
  digitalWrite(SS, HIGH); // deselecting the DAC


  //  Serial.write("Enter: Turn_on,led,state,pulse_width_on,pulse_width_off,power");
  ////      //execute
  //  digitalWrite(SS, LOW);
  //  //DAC 12 bit= 4095 levels
  //  sendAddressAndValue(my_led[2], 2500); // full analog signal
  //  digitalWrite(SS, HIGH);
  //  delay(3);
  //  digitalWrite(A5, HIGH);
}

/* -------------------------------------------------------------------- */
/*                       Loop Function                          */
/* -------------------------------------------------------------------- */
void loop()
{
  while (Serial.available()) {
    read_parameters();
    if (xxValue == "xx") {
      turnLed();
    }
    //routine
    if (xxValue == "rr") {
      turnLedRoutine();
    }
  }
  if (xxValue == "yy") {
    turnLedLoop();
  }

}//end of loop


/* -------------------------------------------------------------------- */
/*                 User Defined Functions                         */
/* -------------------------------------------------------------------- */
void resetFunc() {

  digitalWrite(LED_BUILTIN, HIGH);//turn off LED
  delay(10);
  SPI.begin(); // starts the SPI library object
  SPI.setBitOrder(MSBFIRST); // during the transfer of data, send the most significant bit first
  SPI.setDataMode(SPI_MODE0); // Clock starts at a LOW value and transmits data on the falling edge of the clock signal
  delay(5);
  digitalWrite(SS, LOW); // selecting the DAC
  setUpDAC(); // user defined function
  digitalWrite(SS, HIGH); // deselecting the DAC
}

//just works for led 1
void turnLedRoutine() {
  //for para las diferentes intensidades
  //for para la longitud del pulso
  //hacerlo un total de 15 veces
  int rep_long = 5;
  int rep_short = 10;
  
  int pulse_off_long = 1500;
  int pulse_off_short = 500;
  
  int pulse_on[7] = {2000, 1000, 50, 20, 10, 5, 1};
  int inten[4] = {10, 25, 50, 100};
  int pulse_off_routine;
  int rep_routine;
  int inten_rep = 4;
  int pulse_rep = 7;
  int rest_period = 2000;

  if (my_led[0] == 1) {
    for (int puw = 0 ; puw < 7; puw++) {
      //BNC signal to generate new file
      //The MEA detects TTL pulse and generates file, but it has to be switched off again
      digitalWrite(BNC, HIGH);
      delay(10);
      digitalWrite(BNC, LOW);
      //intensies loop
      for (int in = 0; in < inten_rep; in++) {
        if (inten[in] >= 0 or inten[in] <= 100) {
          power_converted = 3380 - (inten[in] * 26.26);
        }
        digitalWrite(SS, LOW);
        sendAddressAndValue(my_led[2], power_converted);
        digitalWrite(SS, HIGH);
        delay(3);
        //pulse width loop
        if(pulse_on[puw]<=50){
          pulse_off_routine= pulse_off_short;
          rep_routine=rep_short;
        }
        else{
          pulse_off_routine= pulse_off_long;
          rep_routine=rep_long;
        }
        for (int i = 1; i <= rep_routine; i++) {
          //first turn ON-LOW
          //if state is 1 it turns it on/LOW
          digitalWrite(my_led[1], LOW);
          delay(pulse_on[puw]);
          //delay(pulse_width_on);
          //HIGH means that is off
          //turns all the LEDs off
          digitalWrite(my_led[1], HIGH);
          delay(pulse_off_routine);
          //delay(pulse_width_off);
        }
        delay(rest_period);
      }
    }  
  }
}


void turnLed() {
  for (int i = 0; i < rep_Times; i++) {
    if (my_led[0] == 1) {
      //if state is 1 it turns it on/LOW
      digitalWrite(my_led[1], LOW);
      digitalWrite(BNC, HIGH);
      //delayMicroseconds(pulse_width_on);
      delay(pulse_width_on);
      //HIGH means that is off
      digitalWrite(my_led[1], HIGH);
      //delayMicroseconds(pulse_width_off);
      delay(pulse_width_off);
    }
  }
  digitalWrite(BNC, LOW);
}

void turnLedLoop() {
  if (my_led[0] == 1) {
    //if state is 1 it turns it on/LOW
    digitalWrite(my_led[1], LOW);
    digitalWrite(BNC, HIGH);
    //delayMicroseconds(pulse_width_on);
    delay(pulse_width_on);
    //HIGH means that is off
    digitalWrite(my_led[1], HIGH);
    //delayMicroseconds(pulse_width_off);
    delay(pulse_width_off);
  }
  else {
    digitalWrite(BNC, LOW);
  }
}

void read_parameters() {

  //-----------------turn-off-LEDS--------------------
  //execute
  digitalWrite(SS, LOW);
  //DAC 12 bit= 4095 levels
  sendAddressAndValue(my_led[2], 3380); // full analog signal
  digitalWrite(SS, HIGH);
  delay(3);


  //---------------------------------read loop-----------------------------------------
  myString = Serial.readString(); // read the incoming data as string
  int commaIndexArray[] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
  String stringValues[] = {"0", "0", "0", "0", "0", "0", "0", "0"};

  commaIndexArray[0] = myString.indexOf(',');
  xxValue = myString.substring(0, commaIndexArray[0]);
  for (int i = 1; i <= 7; i++) {
    commaIndexArray[i] = myString.indexOf(',', commaIndexArray[i - 1] + 1);
    stringValues[i] = myString.substring(commaIndexArray[i - 1] + 1, commaIndexArray[i]);
    if (stringValues[i] == "end") {
      break;
    }
  }

  on_switch = stringValues[1].toInt();
  power = stringValues[2].toInt();
  led = stringValues[3].toInt();
  state = stringValues[4].toInt();
  pulse_width_on = stringValues[5].toInt();
  pulse_width_off = stringValues[6].toInt();
  rep_Times = stringValues[7].toInt();

  if (xxValue == "reset") {
    resetFunc();
  }

  //power_converted= 3000;
  if (power >= 0 and power <= 100) {
    power_converted = 3380 - (power * 26.26);
  }
  else {
    power_converted = 3380;
  }

  //      Serial.println(" ");
  //      Serial.print("String: ");
  //      Serial.println(myString);
  //      Serial.print("xxValue: ");
  //      Serial.println(xxValue);
  //      Serial.print("comma index array: ");
  //      Serial.print(commaIndexArray[0]);
  //      Serial.print(commaIndexArray[1]);
  //      Serial.print(commaIndexArray[2]);
  //      Serial.print(commaIndexArray[3]);
  //      Serial.print(commaIndexArray[4]);
  //      Serial.print(commaIndexArray[5]);
  //      Serial.println(commaIndexArray[6]);
  //      Serial.println("String Value ");
  //      Serial.println(stringValues[0]);
  //      Serial.println(stringValues[1]);
  //      Serial.println(stringValues[2]);
  //      Serial.println(stringValues[3]);
  //      Serial.println(stringValues[4]);
  //      Serial.println(stringValues[5]);
  //      Serial.println(stringValues[6]);
  //      Serial.println();
  //      Serial.print("power (%): ");
  //      Serial.println(power_converted);
  //      Serial.print("led: ");
  //      Serial.println(led);
  //      Serial.print("state: ");
  //      Serial.println(state);
  //      Serial.print("Pulse Width: ");
  //      Serial.println(pulse_width_on);
  //      Serial.print("Pulse Width off: ");
  //      Serial.println(pulse_width_off);
  //      Serial.print("ON/OFF: ");
  //      Serial.println(on_switch);
  //      Serial.print("repetition times: ");
  //      Serial.println(rep_Times);


  //led activation

  if (state == 1) {
    my_led[0] = 1;
  }
  else if (state == 0) {
    my_led[0] = 0;
  }
  //  Serial.print("pin");
  //  Serial.print(my_led[0]);
  //  Serial.print(" ");
  //  Serial.println(my_led[1]);

  //execute
  digitalWrite(SS, LOW);
  //DAC 12 bit= 4095 levels
  sendAddressAndValue(my_led[2], power_converted); // full analog signal
  digitalWrite(SS, HIGH);
  delay(3);

  //turn on or off the device
  if (on_switch == 1) {
    digitalWrite(A5, HIGH);
  } else if (on_switch == 0) {
    //   SPI.endTransaction();
    digitalWrite(A5, LOW);
  }

  if (led == 15) {
    digitalWrite(SS, LOW);
    //DAC 12 bit= 4095 levels
    sendAddressAndValue(led, power_converted); // full analog signal
    digitalWrite(SS, HIGH);
    delay(3);
  }
}

void sendAddressAndValue(int address, int value) {
  //valid address values are between 0 and 7; 0 for A, 1 for B, and so on.
  //An address value of 15 will provide power to all of the outputs simultaneously
  // 690 is set as the low limit for value since is equivlent to 1A
  if (((address >= 0 && address <= 7) || address == 15) && (value > 750 && value <= 4095)) {
    SPI.transfer(0b00000011); // 4 bits of junk and a command to update DAC register
    delay(1); // small time delay to ensure the DAC processes the data
    int value1 = highByte(value); // collecting the upper half of the value
    int value2 = lowByte(value); // collecting the lower half of the value
    int addressAndValue1 = (address << 4) + value1; // combining the address and value into one piece
    SPI.transfer(addressAndValue1); // the 4 bits of address and the upper half of the value
    delay(1); // small time delay to ensure the DAC processes the data
    SPI.transfer(value2); // the lower half of the value
    delay(1); // small time delay to ensure the DAC processes the data
    SPI.transfer(0);//junk data
    delay(1); // small time delay to ensure the DAC processes the data
  }

  else {
    SPI.transfer(0b00000011); // 4 bits of junk and a command to update DAC register
    delay(1); // small time delay to ensure the DAC processes the data
    SPI.transfer(0b11110000); // all addresses and a value of zero
    delay(1); // small time delay to ensure the DAC processes the data
    SPI.transfer(0); // a value of zero
    delay(1); // small time delay to ensure the DAC processes the data
    SPI.transfer(0);//junk data
    delay(1); // small time delay to ensure the DAC processes the data
    //    for (int i = 0; i < 8; i++) {
    ////      digitalWrite(50, HIGH);
    ////      delay(25);
    ////      digitalWrite(50, LOW);
    ////      delay(25);
    //    }
  }
} //end of sendAddressAndValue


void setUpDAC() {
  SPI.transfer(0b00001000);//4 bits of junk and a command to change reference voltage
  delay(3); // small time delay to ensure DAC processes the data
  SPI.transfer(0);//sending more values since it doesn't care about these (thanks to the Command) and we need 32 bits total
  delay(3);
  SPI.transfer(0);//same reason
  delay(3);
  SPI.transfer(0b00000001);//7 bits of ignored data and a final "1" to indicate to use the internal reference
  delay(3);
  digitalWrite(SS, HIGH);
  delay(1);
  digitalWrite(SS, LOW);
  //turning all the outputs off to begin with
  SPI.transfer(0b00000011); // 4 bits of junk and a command to update DAC register
  delay(1); // small time delay to ensure the DAC processes the data
  SPI.transfer(0b11110000); // all addresses and a value of zero
  delay(1); // small time delay to ensure the DAC processes the data
  SPI.transfer(0); // a value of zero
  delay(1); // small time delay to ensure the DAC processes the data
  SPI.transfer(0);//junk data
  delay(1); // small time delay to ensure the DAC processes the data
}
