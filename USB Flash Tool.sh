#!/bin/bash

echo "+----------------------------------------+"
echo "|                                        |"
echo "|            USB Flash Tool              |"
echo "|                                        |"
echo "+----------------------------------------+"

# Check if run as root
if [ "$EUID" -ne 0 ]; then
	echo "Please run the script as root!"
  	exit 1
else

    BEFORE=$(ls /dev/ | grep -E "sd[a-z]$")
    echo "Please insert the USB device now..."
    read -p "Press enter when ready"
    AFTER=$(ls /dev/ | grep -E "sd[a-z]$")

    # Get difference between BEFORE and AFTER
    USB_DEVICE=$(comm -13 <(sort <<<"$BEFORE") <(sort <<<"$AFTER"))
    echo $USB_DEVICE

    # If there's no difference let user choose manually
    # While USB_DEVICE is empty... ask
    if [[ -z "$USB_DEVICE" ]]; then

        cycle=true
        while $cycle 
        do
            # Get a list of all connected USB disks
            USB_DISKS=$(lsblk -o NAME,MODEL | grep 'USB DISK')

            # Check if any USB disks are connected
            if [[ -z "$USB_DISKS" ]]; then
                echo "No USB disks detected. Please insert the USB and run the script again."
                exit 1
            fi

            # Print the list of USB disks and prompt the user to choose one
            echo "+----------------------------------------+"
            echo "|           Connected USB disks:         |"
            echo "|                                        |"
            echo "|          $USB_DISKS          |"
            echo "|                                        |"
            echo "+----------------------------------------+"
            echo ""
            read -p "Enter the name of the disk you want to choose: " CHOSEN_DISK

            # Validate if chosen disk exists
            if [[ -z $(fdisk -l | grep "$CHOSEN_DISK") ]]; then
                echo "Non existent USB disk selected..."
            else
                USB_DEVICE="$CHOSEN_DISK"
                cycle=false
            fi
        done

    fi

    # Set other device variables
    DEVICE_NAME=$(fdisk -l /dev/$USB_DEVICE | grep -oP 'Disk model: \K.*')
    DEVICE_SIZE=$(df -h /dev/$USB_DEVICE | awk 'NR==2{print $2}')

    echo "+----------------------------------------+"
    echo " Flash Device: $DEVICE_NAME - $DEVICE_SIZE"
    echo "+----------------------------------------+"

    echo ""

    read -p "Enter path to .iso image: " IMAGE_PATH

    echo "+----------------------------------------+"
    echo " ISO Image: $IMAGE_PATH       "
    echo "+----------------------------------------+"

    echo ""

    echo "+----------------------------------------+"
    echo " Burn | $IMAGE_PATH | >> | $DEVICE_NAME (/dev/$USB_DEVICE) - $DEVICE_SIZE |"
    echo "+----------------------------------------+"

    echo ""
    
    read -p " !!! This will erase all your data on $USB_DEVICE do you wish to continue? !!!"

    # Burn the .iso image onto the USB device
    dd bs=4M if=$IMAGE_PATH of=/dev/$USB_DEVICE status=progress oflag=sync

fi
