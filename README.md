_**AVR-Run**_
=============

About
-----
This bash script replaces a C/C++ Makefile to build, dump and flash a AVR microcontroller.

Requirements
------------
* gcc-avr
* avr-libc
* binutils-avr
* avrdude

Usage
-----
1. Set the the target device and programming device type, you want to use it with at the `Configuration` section of the script and doublecheck the specified directory paths.[^1]
2. Check the available options with `run.sh -h` or `run.sh --help`.
3. Have fun!

How to include it into another project
--------------------------------------
I recommend to create for example a executable script called `do.sh` with the following content:
```bash
#!/bin/bash
curl -f -s -S https://raw.githubusercontent.com/vivi90/avr-run/master/run.sh | bash -s -- "$@"
```

License
-------
This script is free software under the terms of the GNU General Public License v3 as published by the Free Software Foundation.
It is distributed WITHOUT ANY WARRANTY (without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE).
For more details please see the LICENSE file or: http://www.gnu.org/licenses

Credits
-------
* 2019 by Vivien Richter <vivien-richter@outlook.de>
* Git repository: https://github.com/vivi90/avr-run.git

[^1]: Please see: https://www.nongnu.org/avrdude/user-manual/avrdude_4.html
