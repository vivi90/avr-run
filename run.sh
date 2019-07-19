#!/bin/bash

read -r -d '' about <<- INFO
########################################################
#                                                      #
#                C/C++ microcontroller                 #
#         compile, dump and programming script         #
#                                                      #
#                   Version 3.0.1                      #
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

Usage: run.sh [-i] [-d] [-c] [-b] [-t]

Options:
    -v, --version         Shows the version number and terminates the script.
    -l, --license         Shows license information and terminates the script.
    -i                    Shows target device details.
    -d                    Creates dump files of all target device memories.
    -c                    Deletes all built binary files.
    -b                    Builds binary files from the source code.
    -t                    Transfers built binary files to the target device.
    -h, --help, -?        Shows this info text and terminates the script.
INFO

# Include configuration
source run-config.cfg

# Shows version number.
showVersion() {
    echo $(grep -oP -m 1 '(?<=Version)(\s+)?\K([^ ]*)' $0)
}

# Shows license information.
showLicense() {
    echo "This script is free software.
So you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation.

This script is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY.
Without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
Please see the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this script.
If not, please see: http://www.gnu.org/licenses"
}

# Shows info text.
showInfo() {
	echo "$about"
}

# Detects command line parameters.
if [ $# -gt 0 ]; then
    while [ "$1" != "" ]; do
		case $1 in
            -v | --version )
                showVersion
                exit 0
                ;;
            -l | --license )
                showLicense
                exit 0
                ;;
			-i )
				showTargetDeviceDetails=true
				;;
			-d )
				createDump=true
				;;
			-c )
				clean=true
				;;
			-b )
				build=true
				;;
			-t )
				transfer=true
				;;
			-h | --help | -? )
				showInfo
				exit 0
				;;
			* )
				showInfo
				exit 1
				;;
		esac
		shift
	done
else
    showInfo
	exit 1
fi

# Shows target device details.
if [ "$showTargetDeviceDetails" = true ]; then
	avrdude -p $targetDevice -c $programmingDevice -n -v 2>&1
fi

# Creates dump files.
if [ "$createDump" = true ]; then
	echo -e "\033[1mCreating dump files..\033[0m"
    # Preparing.
	currentDateTime=$(date "+%Y.%m.%d_%H:%M:%S")
	mkdir -v -p $dumpDirectory/$currentDateTime
    # Gets target device info and save it.
	targetInfo=$(avrdude -p $targetDevice -c $programmingDevice -n -v 2>&1)
	echo "$targetInfo" > $dumpDirectory/$currentDateTime/info.txt
    # Checks selected memory types.
	for memoryType in "${selectedMemoryTypes[@]}"; do
        # Checks, if the selected memory type is supported by the target device.
		if grep -q -w "$memoryType" <<< $targetInfo; then
            # Creates a dump.
            file=$dumpDirectory/$currentDateTime/$memoryType.hex
			avrdude -p $targetDevice -c $programmingDevice -n -U $memoryType:r:$file:i
		fi
	done
fi

# Deletes all built binary files.
if [ "$clean" = true ]; then
	echo -e "\033[1mCleaning..\033[0m"
	rm -r -f -v $binaryDirectory
fi

# Builds binary files from the source code.
if [ "$build" = true ]; then
	# Creates destination directory.
	mkdir -v -p $binaryDirectory
	# Compiling.
	echo -e "\033[1mCompiling..\033[0m"
    avr-gcc -v -Wall -Os -mmcu=$targetDevice -o $binaryDirectory/flash.elf $sourceDirectory/*.cpp
	# Creates HEX image.
	echo -e "\033[1mCreating HEX image..\033[0m"
	avr-objcopy -v -O ihex $binaryDirectory/flash.elf $binaryDirectory/flash.hex
fi

# Transfers compiled binary to the target device.
if [ "$transfer" = true ]; then
    # Erasing target device.
    echo -e "\033[1mErasing target device..\033[0m"
    avrdude -p $targetDevice -c $programmingDevice -e
    # Transferring.
	echo -e "\033[1mTransferring..\033[0m"
    # Gets target device info.
	targetInfo=$(avrdude -p $targetDevice -c $programmingDevice -n -v 2>&1)
    # Checks selected memory types.
	for memoryType in "${selectedMemoryTypes[@]}"; do
        # Checks, if the selected memory type is supported by the target device.
		if grep -q -w "$memoryType" <<< $targetInfo; then
            file=$binaryDirectory/$memoryType.hex
            # Checks, if the binary file for the selected memory type exists.
            if [ -f $file ]; then
                # Transferring..
			    avrdude -p $targetDevice -c $programmingDevice -U $memoryType:w:$file:i
            fi
		fi
	done
fi

# Exit.
echo -e "\033[1mDone.\033[0m"
exit 0
