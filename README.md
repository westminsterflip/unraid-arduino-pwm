# unraid-arduino-pwm
Collection of scripts and files to make an Arduino generate pwm for fans under unRAID.  
Based on a post from [Kevin's Blog](https://kmwoley.com/blog/controlling-case-fans-based-on-hard-drive-temperature/) and implements a usb reset program [from here](https://marc.info/?l=linux-usb&m=121459435621262&w=2).  
This may work for non-unRAID systems or may not work on your unRAID installation.  It may break everything.  Just a warning.


## Installation
### unRAID
1. `usbreset.c` will not compile on unRAID.  Compile on an x64 Linux system.  (I used WSL, I assume others will work): `gcc usbreset.c -o usbreset`  
   (There is a usbreset binary in the repo, these are just instructions in case you don't trust the pre-compiled binary)
2. Edit `hdd_temp_send.sh` to reflect the number and dev name of your drives
3. If you want to check the drive temperature at an interval different than 5 minutes, edit `mycrontab.txt` accordingly
4. If you don't have one already. create scripts a folder in /boot/config/:    `mkdir /boot/config/scripts`
5. Copy `arduino.rules`, `hdd_temp_send.sh`, `mycrontab.txt`, `reset_arduino.sh`, `screen_start.sh`, and `usbreset` to `/boot/config/scripts`
6. Add the following to the end of `/boot/config/go`:
```
# Open serial connection
/boot/config/scripts/screen_start.sh

# Add udev rule
cp /boot/config/scripts/arduino.rules /etc/udev/rules.d

# setup crontab
crontab -l > /tmp/file
echo '#' >> /tmp/file
echo '# Start of Custom crontab entries' >> /tmp/file
cat /boot/config/scripts/mycrontab.txt >> /tmp/file
echo '# End of Custom crontab entries' >> /tmp/file
crontab /tmp/file
rm -f /tmp/file
```
7. If you are using the S3 sleep plugin add `/boot/config/scripts/reset_arduino.sh` to the "Custom commands after wake-up:" field.  
   **Note:** If you are not sleeping your server, you don't strictly need `reset_arduino.sh`, `usbreset`, or the `arduino.rules` or related lines
   
### Arduino
The program is set up to set pins 3, 5, 6, and 9 as pwm pins.  If you are using a different board than the Uno these may be different.  Any digital pin with ~ next to the number can be used.  
1. Edit `pwm_fan_control.ino`.  If you want to add more fan pins, just copy every line with fan_pinX in it (it's fairly obvious in the file where I've done this).  `fan_off_temp` is the temperature at and below which the fans will run at `fan_off_pwm`.  `fan_high_temp` is the temperature at and above which the fans will run at `fan_high_pwm`  (Both temperatures Celsius).  `fan_start_pwm` is a value used to make sure the motor spins from a stop, set to 255 just to be safe.  `fan_low_pwm` is the base pwm that the fans will run once temperature exceeds `fan_off_temp`.  
2. Upload to the Arduino.  



Plug the Arduino into the server's USB port, connect the fans, and reboot the server.
