#!/bin/bash
while [ ! -e /dev/ttyACM0 ]; do
  sleep 1
done
screen -m -d /dev/ttyACM0 9600 &
sleep 5
bash /boot/config/scripts/hdd_temp_send.sh
pkill -f -i screen
