#!/bin/bash

# Get a list of all .iso files in the specified directory
files=( /home/filip/Downloads/*.iso )

# Print all files with their corresponding numbers
for i in "${!files[@]}"; do
  echo "$((i+1)). ${files[$i]}"
done

# Ask the user to choose a file
echo "Please enter the number of the file you want to choose:"
read -r number

# Subtract 1 because bash arrays start at 0
number=$((number-1))

# Check if the number is valid
if [[ number -lt 0 || number -ge ${#files[@]} ]]; then
  echo "Invalid number"
else
  # Get the filename from the path
  filename=$(basename "${files[$number]}")
  echo "You chose the file: $filename"
fi
