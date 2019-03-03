int fan_pin1 = 3;
int fan_pin2 = 5;
int fan_pin3 = 6;
int fan_pin4 = 9;
int fan_off_temp = 35;
int fan_high_temp = 55;
int fan_off_pwm = 0;
int fan_low_pwm = 100;
int fan_start_pwm = 255;
int fan_high_pwm = 255;
int num_steps = fan_high_temp - fan_off_temp - 1;
int pwm_increment = (fan_high_pwm - fan_low_pwm) / num_steps;
int previous_speed = 0;
String inString = "";    // string to hold input

void setup() {
  pinMode(fan_pin1, OUTPUT);
  pinMode(fan_pin2, OUTPUT);
  pinMode(fan_pin3, OUTPUT);
  pinMode(fan_pin4, OUTPUT);
  // Open serial communications and wait for port to open:
  Serial.begin(9600);
  while (!Serial) {
    delay 1; // wait for serial port to connect. Needed for native USB port only
  }

  // send an intro:
  Serial.println("\n\nString toInt():");
  Serial.println();
}

void loop() {
  // Read serial input:
  while (Serial.available() > 0) {
    int inChar = Serial.read();
    if (isDigit(inChar)) {
      // convert the incoming byte to a char and add it to the string:
      inString += (char)inChar;
    }
    // if you get a newline, print the string, then the string's value:
    if (inChar == '\n') {
      int temp = inString.toInt();
      if (temp <= fan_off_temp) {
        analogWrite(fan_pin1, fan_off_pwm);
        analogWrite(fan_pin2, fan_off_pwm);
        analogWrite(fan_pin3, fan_off_pwm);
        analogWrite(fan_pin4, fan_off_pwm);

      } else if (temp >= fan_high_temp) {
        analogWrite(fan_pin1, fan_high_pwm);
        analogWrite(fan_pin2, fan_high_pwm);
        analogWrite(fan_pin3, fan_high_pwm);
        analogWrite(fan_pin4, fan_high_pwm);
      } else {
        if (previous_speed < fan_start_pwm) {
          analogWrite(fan_pin1, fan_start_pwm);
          analogWrite(fan_pin2, fan_start_pwm);
          analogWrite(fan_pin3, fan_start_pwm);
          analogWrite(fan_pin4, fan_start_pwm);
          delay(4);
        }
        int fan_linear_pwm = (temp - fan_off_temp - 1) * pwm_increment + fan_low_pwm;
        analogWrite(fan_pin1, fan_linear_pwm);
        analogWrite(fan_pin2, fan_linear_pwm);
        analogWrite(fan_pin3, fan_linear_pwm);
        analogWrite(fan_pin4, fan_linear_pwm);
      }
      Serial.print("temp:");
      Serial.println(temp, DEC);
      // clear the string for new input:
      inString = "";
    }
  }
}
