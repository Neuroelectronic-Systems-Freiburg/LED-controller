#include <SPI.h>
/* -------------------------------------------------------------------- */
/*                     Setup Function                         */
/* -------------------------------------------------------------------- */
String p;
String tt;
String myString;
float power_converted;
int port;
int power;
int led;
int state;
int pulse_width_off;
int pulse_width_on;
int on_switch;
// State of the LED, Digital Output LED, DAC output (VOUTB=)
int my_led[3][6] = {{0, 0, 0, 0, 0, 0}, {7, 6, 5, 4, 3, 2}, {0, 2, 4, 5, 3, 1}};
int rep_Times;
//starts in yy to enter loop
String xxValue = "yy";

void setup()
{
  Serial.begin(9600);
  // set SPI and a user LED to be outputs
  pinMode(SS, OUTPUT);
  pinMode(MOSI, OUTPUT);
  pinMode(SCK, OUTPUT);
  //pinMode(50, OUTPUT);
  //LED PWM
  pinMode(7, OUTPUT);
  pinMode(6, OUTPUT);
  pinMode(5, OUTPUT);
  pinMode(4, OUTPUT);
  pinMode(3, OUTPUT);
  pinMode(2, OUTPUT);
  //relay pin
  pinMode(12, OUTPUT);
  SPI.begin(); // starts the SPI library object
  SPI.setBitOrder(MSBFIRST); // during the transfer of data, send the most significant bit first
  SPI.setDataMode(SPI_MODE0); // Clock starts at a LOW value and transmits data on the falling edge of the clock signal
  delay(5);
  digitalWrite(SS, LOW); // selecting the DAC
  setUpDAC(); // user defined function
  digitalWrite(SS, HIGH); // deselecting the DAC

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

void turnLed() {
  for (int i = 0; i < rep_Times; i++) {
    //first turn ON-LOW
    for (int i = 0; i < 6; i++) {
      //if state is 1 it turns it on/LOW
      if (my_led[0][i] == 1) {
        digitalWrite(my_led[1][i], LOW);
      }
    }
    delay(pulse_width_on);
    for (int i = 0; i < 6; i++) {
      //HIGH means that is off
      //turns all the LEDs off
      digitalWrite(my_led[1][i], HIGH);
    }
    delay(pulse_width_off);
  }

}


void turnLedLoop() {
  //first turn ON-LOW
  for (int i = 0; i < 6; i++) {
    //if state is 1 it turns it on/LOW
    if (my_led[0][i] == 1) {
      digitalWrite(my_led[1][i], LOW);
    }
  }
  delay(pulse_width_on);
  for (int i = 0; i < 6; i++) {
    //HIGH means that is off
    //turns all the LEDs off
    digitalWrite(my_led[1][i], HIGH);
  }
  delay(pulse_width_off);

}

void read_parameters() {


  //-----------------turn-off-when reading--------------------
  for (int i = 0; i < 6; i++) {
    digitalWrite(my_led[1][i], HIGH);
  }
  //----------------------read for---------------------------
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
  power = stringValues[1].toInt();
  on_switch = stringValues[2].toInt();
  led = stringValues[3].toInt();
  state = stringValues[4].toInt();
  pulse_width_on = stringValues[5].toInt();
  pulse_width_off = stringValues[6].toInt();
  rep_Times = stringValues[7].toInt();

  if (xxValue == "reset") {
    resetFunc();
  }
  if (power >= 0 or power <= 100) {
    power_converted = 3380 - (power * 26.26);
  }
  else {
    power_converted = 3380;
  }


  //  Serial.println(" ");
  //  Serial.print("power (%): ");
  //  //    %below 601 the DAC gives 0V
  //  //    % it´s possible its because an external voltage is beain used
  //  //    % the highest we want is 2310
  //  //    %(2310-600)/100=17.1
  //  Serial.println(power_converted);
  //  Serial.print("led: ");
  //  Serial.println(led);
  //  Serial.print("state: ");
  //  Serial.println(state);
  //  Serial.print("Pulse Width On: ");
  //  Serial.println(pulse_width_on);
  //  Serial.print("Pulse Width Off: ");
  //  Serial.println(pulse_width_off);
  //  Serial.print("ON/OFF: ");
  //  Serial.println(on_switch);


  //led activation
  for (int i = 1; i <= 6; i++) {
    if (led == i) {
      if (state == 1) {
        my_led[0][i - 1] = 1;
      }
      else {
        my_led[0][i - 1] = 0;
      }
      //set power to each LED
      digitalWrite(SS, LOW);
      sendAddressAndValue(my_led[2][i - 1], power_converted);
      digitalWrite(SS, HIGH);
      delay(3);
    }

    //turn the system ON/OFF
    if (on_switch == 1) {
      digitalWrite(12, HIGH);
    } else {
      digitalWrite(12, LOW);
    }
  }
  if (led == 15) {
    digitalWrite(SS, LOW);
    //DAC 12 bit= 4095 levels
    sendAddressAndValue(led, power_converted);
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
    for (int i = 0; i < 8; i++) {
    }
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
