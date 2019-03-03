# unraid-arduino-pwm
Collection of scripts and files to make an Arduino generate pwm for fans under unRAID.  
Based on a post from [Kevin's Blog](https://kmwoley.com/blog/controlling-case-fans-based-on-hard-drive-temperature/) and implements a usb reset program [from here](https://marc.info/?l=linux-usb&m=121459435621262&w=2).  
This may work for non-unRAID systems or may not work on your unRAID installation.  It may break everything.  Just a warning.


## Installation
### unRAID
1. `usbreset.c` will not compile on unRAID.  Compile on an x64 Linux system.  (I used WSL, I assume others will work): `gcc usbreset.c -o usbreset`
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
