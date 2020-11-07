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
NUM_OF_DRIVES=11

# unRAID drives that are in the array/backplane of the fan we need to control
HD[1]=/dev/nvme0n1
HD[2]=/dev/sdb
HD[3]=/dev/sdc
HD[4]=/dev/sdd
HD[5]=/dev/sde
HD[6]=/dev/sdf
HD[7]=/dev/sdg
HD[8]=/dev/sdh
HD[9]=/dev/sdi
HD[10]=/dev/sdj
HD[11]=/dev/sdk
#HD[12]=/dev/sdm
#HD[13]=/dev/sdo
#HD[14]=/dev/sdp
#HD[15]=/dev/sdq
#HD[16]=/dev/sdr
#HD[17]=/dev/sds
#HD[18]=/dev/sdt
#HD[19]=/dev/sdu
#HD[20]=/dev/sdv
#HD[21]=/dev/sdw
#HD[22]=/dev/sdx
#HD[23]=/dev/sdy
#HD[24]=/dev/sdz

### END USER SET VARIABLES ###

# Program variables - do not modify
# HIGHEST_TEMP was set to 40 to protect an NVMe drive on my system
# Set to 0 for normal operation or set a higher temperature if you experience intermittent overheating.
HIGHEST_TEMP=40
CURRENT_DRIVE=1
CURRENT_TEMP=0
OUTPUT=""

# while loop to get the highest temperature of active drives. 
# If all are spun down then high temp will be set to 0.
while [ "$CURRENT_DRIVE" -le "$NUM_OF_DRIVES" ]
do
  CURRENT_TEMP=`smartctl -d ata -A ${HD[$CURRENT_DRIVE]} | grep -m 1 -i Temperature_Celsius | awk '{print $10}'`
  if [ "$CURRENT_TEMP" == "" ]; then
    CURRENT_TEMP=`smartctl -a ${HD[$CURRENT_DRIVE]} | grep -m 1 -i Current\ Drive\ Temperature | awk '{print $4}'`
  fi
  if [ "$CURRENT_TEMP" == "" ]; then
    CURRENT_TEMP=`smartctl -x ${HD[$CURRENT_DRIVE]} | grep '^Current Temperature' | awk '{print $3}'`
  fi
  if [ "$CURRENT_TEMP" == "" ]; then
    CURRENT_TEMP=`smartctl -x ${HD[$CURRENT_DRIVE]} | grep Temperature | awk '{print $2}'`
  fi
  if [ "$HIGHEST_TEMP" -le "$CURRENT_TEMP" ]; then
    HIGHEST_TEMP=$CURRENT_TEMP
  fi
  let "CURRENT_DRIVE+=1"
done
OUTPUT="Highest HDD temp is: "$HIGHEST_TEMP
CPU_TEMP=`/usr/bin/sensors | grep CPU\ Temp | awk -F '+' '{print $2}' | awk -F '.' '{print $1}'`
CPU_TEMPA=$((CPU_TEMP/2+15))
CPU_TEMP1=`/usr/bin/sensors | grep Package\ id\ 1 | awk -F '+' '{print $2}' | awk -F '.' '{print $1}'`
CPU_TEMPA1=$((CPU_TEMP/2+15))
if [ "$CPU_TEMPA" -gt "$HIGHEST_TEMP" ]; then
  HIGHEST_TEMP=$CPU_TEMPA
  OUTPUT="CPU temp highest: "$CPU_TEMP
fi
if [ "$CPU_TEMPA1" -gt "$HIGHEST_TEMP" ]; then
  HIGHEST_TEMP=$CPU_TEMPA1
  OUTPUT="CPU temp highest: "$CPU_TEMP1
fi
echo $OUTPUT
while [ ! -e /dev/ttyACM0 ]; do
  sleep 1
done
HIGHEST_TEMP=$((HIGHEST_TEMP+5))
echo $HIGHEST_TEMP > /dev/ttyACM0
