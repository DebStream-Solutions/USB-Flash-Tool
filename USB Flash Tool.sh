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

    echo ""

    # Get difference between BEFORE and AFTER
    USB_DEVICE=$(comm -13 <(sort <<<"$BEFORE") <(sort <<<"$AFTER"))

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
            echo "| Connected USB disks: "
            echo ""
            echo "$USB_DISKS"
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

    cycle=true
    while $cycle 
    do  
        # Get a list of all .iso files in the users Downloads directory
        files=( /home/$SUDO_USER/Downloads/*.iso )

        # Check if any iso files exist in Downloads
        if [ $(basename $files) = "*.iso" ]; then
            echo "No iso files in your Download directory detected. Please put your iso files in your Downloads directory and run the script again."
            exit 1
        fi

        # Print all files with their corresponding numbers
        # Print the list of USB disks and prompt the user to choose one
        echo "+----------------------------------------+"
        echo "| Files in  your Download directory:"
        echo ""
        for i in "${!files[@]}"; do
            echo "$((i+1)). ${files[$i]}"
        done
        echo "+----------------------------------------+"

        # Ask the user to choose a file
        read -p "Please enter the number of the file you want to choose: " number

        # Subtract 1 because bash arrays start at 0
        number=$((number-1))

        # Check if the number is valid
        if [[ number -lt 0 || number -ge ${#files[@]} ]]; then
        echo "Invalid number"
        else
        # Get the filename from the path
        FILE_PATH=${files[$number]}
        FILENAME=$(basename "${files[$number]}")
        cycle=false
        fi
    done


    echo "+----------------------------------------+"
    echo " ISO Image: $FILENAME       "
    echo "+----------------------------------------+"

    echo ""

    echo "+----------------------------------------+"
    echo " Burn | $FILENAME | >> | $DEVICE_NAME (/dev/$USB_DEVICE) - $DEVICE_SIZE |"
    echo "+----------------------------------------+"

    echo ""
    
    read -p " !!! This will erase all your data on $USB_DEVICE do you wish to continue? !!!"
    
    echo ""

    # Burn the .iso image onto the USB device
    dd bs=4M if=$FILE_PATH of=/dev/$USB_DEVICE status=progress oflag=sync

    : '
    echo ""
    
    spinner=( '⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏' )

    echo -n "Loading "
    while true; do
    for i in "${spinner[@]}"; do
        echo -ne "\b$i"
        sleep 0.1
    done
    done
    '

fi
