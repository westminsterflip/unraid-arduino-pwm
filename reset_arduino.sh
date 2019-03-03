BUS=`lsusb | grep 2341:0043 | awk '{print $2}'`
DEVICE=`lsusb | grep 2341:0043 | awk '{print $4}' | awk -F ':' '{print $1}'`
ADDR="/dev/bus/usb/"$BUS"/"$DEVICE
/boot/config/scripts/usbreset $ADDR
