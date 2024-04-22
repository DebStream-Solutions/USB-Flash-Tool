#!/bin/bash

# Check if run as root
if [ "$EUID" -ne 0 ]; then
	echo "Please run the script as root!"
  	exit 1
else
    BEFORE=$(ls /dev/sd*)
    echo "Please insert the USB device now..."
    read -p "Press enter when ready"
    AFTER=$(ls /dev/sd*)

    # Get difference between BEFORE and AFTER
    USB_DEVICE=$(comm -13 <(sort <<<"$BEFORE") <(sort <<<"$AFTER"))


    # If there's no difference let user choose manually
    # While USB_DEVICE is empty... ask
    if [[ -z "$USB_DEVICE" ]]; then

        # Get a list of all connected USB disks
        USB_DISKS=$(lsblk -o NAME,MODEL | grep 'USB DISK')

        # Check if any USB disks are connected
        if [[ -z "$USB_DISKS" ]]; then
            echo "No USB disks detected. Please insert the USB and run the script again."
            exit 1
        fi

        # Print the list of USB disks and prompt the user to choose one
        echo "Connected USB disks:"
        echo "$USB_DISKS"
        read -p "Enter the name of the disk you want to choose: " CHOSEN_DISK

        # Validate if chosen disk exists
        if [[ -z $(fdisk -l | grep "$CHOSEN_DISK") ]]; then
            echo "Non existent USB disk selected..."
            exit 1
        else
            USB_DEVICE="/dev/$CHOSEN_DISK"
        fi
    fi

    # Set other device variables
    DEVICE_NAME=$(fdisk -l $USB_DEVICE | grep -oP 'Disk model: \K.*')
    DEVICE_SIZE=$(df -h $USB_DEVICE | awk 'NR==2{print $2}')

    echo "Your FLASH device has been set to: $DEVICE_NAME - $DEVICE_SIZE"

    echo "Enter path to .iso image:"
    read IMAGE_PATH

    echo "Your path image has been set to: $IMAGE_PATH"

    echo "Burn | $IMAGE_PATH | >> | /dev/$DEVICE_NAME (/dev/$USB_DEVICE) - $DEVICE_SIZE |"
    read -p "This will erase all your data on $USB_DEVICE do you wish to continue?"

    # Burn the .iso image onto the USB device
    #dd bs=4M if=$IMAGE_PATH of=/dev/$USB_DEVICE status=progress oflag=sync

fi

