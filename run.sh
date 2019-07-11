#!/bin/bash

read -r -d '' about <<- INFO
########################################################
#                                                      #
#                C/C++ microcontroller                 #
#         compile, dump and programming script         #
#                                                      #
#                     Version 2.0                      #
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
    -i                    Shows target device details.
    -d                    Creates dump files of all target device memories.
    -c                    Deletes all built binary files.
    -b                    Builds binary files from the source code.
    -t                    Transfers built binary files to the target device.
    -h, --help, -?        Shows this info text.
INFO

# Configuration
sourceDirectory="./src"
binaryDirectory="./bin"
dumpDirectory="./dmp"
targetDevice="atmega8"
programmingDevice="usbasp"
supportedMemoryTypes=(calibration eeprom efuse flash fuse hfuse lfuse lock signature application apptable boot prodsig usersig);

# Shows info text.
showInfo() {
	echo "$about"
}

# Detects command line parameters.
if [ $# -gt 0 ]; then
    while [ "$1" != "" ]; do
		case $1 in
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
	currentDateTime=$(date "+%Y.%m.%d_%H:%M:%S")
	mkdir -v -p $dumpDirectory/$currentDateTime
	targetInfo=$(avrdude -p $targetDevice -c $programmingDevice -n -v 2>&1)
	echo "$targetInfo" > $dumpDirectory/$currentDateTime/info.txt
	for memoryType in "${supportedMemoryTypes[@]}"; do
		if grep -q -w "$memoryType" <<< $targetInfo; then
			avrdude -p $targetDevice -c $programmingDevice -n -U $memoryType:r:$dumpDirectory/$currentDateTime/$memoryType.hex:i
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
	echo -e "\033[1mTransferring..\033[0m"
	avrdude -p $targetDevice -c $programmingDevice -e -U $binaryDirectory/flash.hex
fi

# Exit.
echo -e "\033[1mDone.\033[0m"
exit 0
