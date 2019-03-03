#!/bin/bash
# unraid_array_fan.sh v0.6
# v0.1: By xamindar: First try at it.
# v0.2: Made a small change so the fan speed on low doesn't fluctuate every time the script is run.
# v0.3: It will now enable fan speed change before trying to change it. I missed 
#        it at first because pwmconfig was doing it for me while I was testing the fan.
# v0.4: Corrected temp reading to "Temperature_Celsius" as my new Seagate drive
#        was returning two numbers with just "Temperature".
# v0.5: By Pauven:  Added linear PWM logic to slowly ramp speed when fan is between HIGH and OFF.
# v0.6: By kmwoley: Added fan start speed. Added logging, suppressed unless fan speed is changed.
# A simple script to check for the highest hard disk temperatures in an array
# or backplane and then set the fan to an apropriate speed. Fan needs to be connected
# to motherboard with pwm support, not array.
# DEPENDS ON:grep,awk,smartctl,hdparm

### VARIABLES FOR USER TO SET ###
# Amount of drives in the array. Make sure it matches the amount you filled out below.
NUM_OF_DRIVES=4

# unRAID drives that are in the array/backplane of the fan we need to control
HD[1]=/dev/sdb
HD[2]=/dev/sdc
HD[3]=/dev/sdd
HD[4]=/dev/sde
#HD[5]=/dev/sdf
#HD[6]=/dev/sdg
#HD[7]=/dev/sdh
#HD[8]=/dev/sdi
#HD[9]=/dev/sdj
#HD[10]=/dev/sdk
#HD[11]=/dev/sdl
#HD[12]=/dev/sdm
#HD[13]=/dev/sdn
#HD[14]=/dev/sdo
#HD[15]=/dev/sdp
#HD[16]=/dev/sdq
#HD[17]=/dev/sdr
#HD[18]=/dev/sds
#HD[19]=/dev/sdt
#HD[20]=/dev/sdu
#HD[21]=/dev/sdv
#HD[22]=/dev/sdw
#HD[23]=/dev/sdx
#HD[24]=/dev/sdy

### END USER SET VARIABLES ###

# Program variables - do not modify
HIGHEST_TEMP=0
CURRENT_DRIVE=1
CURRENT_TEMP=0

# while loop to get the highest temperature of active drives. 
# If all are spun down then high temp will be set to 0.
while [ "$CURRENT_DRIVE" -le "$NUM_OF_DRIVES" ]
do
  CURRENT_TEMP=`smartctl -d ata -A ${HD[$CURRENT_DRIVE]} | grep -m 1 -i Temperature_Celsius | awk '{print $10}'`
  if [ "$CURRENT_TEMP" == "" ]; then
    CURRENT_TEMP=`smartctl -a ${HD[$CURRENT_DRIVE]} | grep -m 1 -i Current\ Drive\ Temperature | awk '{print $4}'`
  fi
  if [ "$HIGHEST_TEMP" -le "$CURRENT_TEMP" ]; then
    HIGHEST_TEMP=$CURRENT_TEMP
  fi
  let "CURRENT_DRIVE+=1"
done
echo "Highest HDD temp is: "$HIGHEST_TEMP
while [ ! -e /dev/ttyACM0 ]; do
  sleep 1
done
echo $HIGHEST_TEMP > /dev/ttyACM0

