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
tty_port_id=$3

#Download the file.
host_file_name=$2
bin_file_name=${host_file_name/elf/bin}
echo "BIN FILE" $bin_file_name

#DFU=DYNLD_LIBRARY_PATH=$fixed_path $fixed_path/dfu-util
DYLD_LIBRARY_PATH=$fixed_path
DFU="$fixed_path/dfu-util -d8087:0ABA"

echo "wating for device... "
COUNTER=0
f=`DYLD_LIBRARY_PATH=$fixed_path $DFU -l | grep sensor_core | cut -f 1 -d ' '`
while [ "x$f" = "x" ] && [ $COUNTER -lt 10 ]
do
    let COUNTER=COUNTER+1
    sleep 1
	echo $DFU
    f=`DYLD_LIBRARY_PATH=$fixed_path $DFU -l | grep sensor_core | cut -f 1 -d ' '`
done

if [ "x$f" != "x" ] ; then
    echo "Using dfu-util to send " $bin_file_name
    DYLD_LIBRARY_PATH=$fixed_path $DFU -D $bin_file_name -v --alt 7 -R
else
     echo "ERROR: Timed out waiting for Intel EDU."
fi
