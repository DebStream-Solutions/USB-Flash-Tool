#!/bin/bash

# Get the list of connected USB devices
usb_devices=$(dmesg | grep -i usb)

# Check if the list is empty
if [ -z "$usb_devices" ]
then
  echo "No USB devices are connected."
else
  echo "The following USB devices are connected:"
  echo "$usb_devices"
fi
