#!/bin/sh

echo "starting download script"
echo "Args to shell:" $*
#
# ARG 1: Path to lsz executable.
# ARG 2: Elf File to download
# ARG 3: TTY port to use.
#
#path may contain \ need to change all to /
path_to_exe=$1
fixed_path=${path_to_exe//\\/\/}

#
tty_port_id=$3
echo "Serial Port PORT" $com_port_id 

#Download the file.
host_file_name=$2
bin_file_name=${host_file_name/elf/bin}
echo "BIN FILE" $bin_file_name


DFU=$fixed_path/dfu-util
echo "wating for Arduino 101 device... "
COUNTER=0
f=`$DFU -l -d ,8087:0ABA | grep sensor_core | cut -f 1 -d ' '`
while [ "x$f" = "x" ] && [ $COUNTER -lt 10 ]
do
    let COUNTER=COUNTER+1
    sleep 1
    f=`$DFU -l -d ,8087:0ABA | grep sensor_core | cut -f 1 -d ' '`
done

if [ "x$f" != "x" ] ; then
	echo "Using dfu-util to send " $bin_file_name
	$DFU -d,8087:0ABA -D $bin_file_name -v --alt 7 -R
	echo "Sketch will execute in about 5 seconds."
else
	echo "ERROR: Timed out waiting for Arduino 101."
fi
