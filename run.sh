#!/bin/bash

########################################################
#                                                      #
#                C/C++ microcontroller                 #
#             compile and transfer script              #
#                                                      #
#                     Version 1.0                      #
#                                                      #
#  2019 by Vivien Richter <vivien-richter@outlook.de>  #
#                                                      #
#  License:                                            #
#  GPL v3 (see: http://www.gnu.org/licenses)           #
#                                                      #
#  Requires:                                           #
#  gcc-avr, avr-libc, binutils-avr, avrdude            #
#                                                      #
#  Note:                                               #
#  All console outputs are verbose                     #
#  to be aware of possible issues very quickly!        #
#                                                      #
########################################################

# Configuration
sourceFile="main.cpp"
targetDevice="atmega8"
programmingDevice="avrispmkII"

# Enable shell option 'extglob'
shopt -s extglob

# Cleaning
echo -e "\033[1mCleaning..\033[0m"
rm -v -f -r ./bin/!(.gitkeep|.|..)

# Compiling
echo -e "\033[1mCompiling..\033[0m"
avr-gcc -v -Wall -Os -mmcu=$targetDevice -o ./bin/main.elf ./src/$sourceFile

# Creating HEX image
echo -e "\033[1mCreating HEX image..\033[0m"
avr-objcopy -v -O ihex ./bin/main.elf ./bin/main.hex

# Transfer
echo -e "\033[1mTransfer..\033[0m"
avrdude -p $targetDevice -c $programmingDevice -e -U ./bin/main.hex

# Exit.
exit 0
