byte fan_pin1 = 3;
byte fan_pin2 = 5;
byte fan_pin3 = 6;
byte fan_pin4 = 9;
byte fan_off_temp = 35;
byte fan_high_temp = 55;
byte fan_off_pwm = 0;
byte fan_low_pwm = 100;
byte fan_start_pwm = 255;
byte fan_high_pwm = 255;
byte num_steps = fan_high_temp - fan_off_temp - 1; //19
byte pwm_increment = (fan_high_pwm - fan_low_pwm) / num_steps; //8
byte previous_speed = 255;
long timeout = 2*60; //time in seconds until going full speed w/o update
long last_read;

void setup() {
  pinMode(fan_pin1, OUTPUT);  //The noctuas don't seem to start until 45 deg which is about 172 pwm
  pinMode(fan_pin2, OUTPUT);
  pinMode(fan_pin3, OUTPUT);
  pinMode(fan_pin4, OUTPUT);
  setPWM(255);
  // Open serial communications and wait for port to open:
  Serial.begin(9600);
  while (!Serial) {
    delay (1); // wait for serial port to connect. Needed for native USB port only
  }

  // send an intro:
  Serial.println("Starting");
  Serial.println();
  timeout = timeout *1000;
  last_read = millis();
}

void loop() {
  if(previous_speed != 255 && millis() - last_read >= timeout){ //hasn't received data in timeout
    setPWM(255);
    Serial.print("No response in ");
    Serial.print(timeout/1000, DEC);
    Serial.println(" seconds, failover to full speed");
  }
  while (Serial.available() > 0) {
    int temp = Serial.parseInt();
    if (temp != 0) {
      last_read = millis();
      if (temp <= fan_off_temp) {
        setPWM(fan_off_pwm);

      } else if (temp >= fan_high_temp) {
        setPWM(fan_high_pwm);
      } else {
        if (previous_speed < fan_start_pwm) {
          setPWM(fan_start_pwm);
          delay(4);
        }
        int fan_linear_pwm = (temp - fan_off_temp - 1) * pwm_increment + fan_low_pwm;
        setPWM(fan_linear_pwm);
      }
      Serial.print("temp:");
      Serial.println(temp, DEC);
    }
  }
}

void setPWM(byte pwm){
  analogWrite(fan_pin1, pwm);
  analogWrite(fan_pin2, pwm);
  analogWrite(fan_pin3, pwm);
  analogWrite(fan_pin4, pwm);
  previous_speed = pwm;
}
