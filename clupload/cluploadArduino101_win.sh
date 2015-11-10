#!/bin/sh

echo "starting download script"
echo "Args to shell:" $*
#
# ARG 1: Path to lsz executable.
# ARG 2: Elf File to download
# ARG 3: TTY port to use.
#
#path may contain \ need to change all to /
dfu=${1}\\dfu-util.exe
dfu=${dfu//\\/\/}
dfu_cmd="$dfu -d,8087:0ABA"
sleep=${1}\\sleep.exe
sleep=${sleep//\\/\/}
path_to_exe=$1
fixed_path=${path_to_exe//\\/\/}
tmp_dfu_output=${1}\\..\\..\\.tmp_dfu_output

tty_port_id=$3
echo "Serial Port PORT" $com_port_id 
#echo "Using tty Port" $tty_port_id 
#
#echo "Sending Command String to move to download if not already in download mode"
#echo "~sketch downloadArduino101" > $tty_port_id
#Give the host time to stop the process and wait for download
#sleep 1

#Download the file.
host_file_name=$2
bin_file_name=${host_file_name/elf/bin}
echo "BIN FILE" $bin_file_name

echo "Waiting for device... "
COUNTER=0
$dfu_cmd -l  >$tmp_dfu_output
f=`findstr sensor_core $tmp_dfu_output`
while [ "x$f" = "x" ] && [ $COUNTER -lt 10 ]
do
    let COUNTER=COUNTER+1
    $sleep 1
    $dfu_cmd -l >$tmp_dfu_output
    f=`findstr sensor_core $tmp_dfu_output`
done

if [ "x$f" != "x" ] ; then
	echo "Using dfu-util to send " $bin_file_name
	echo $dfu_cmd -D $bin_file_name -v --alt 7 -R
	$dfu_cmd  -D $bin_file_name -v --alt 7 -R
else
	echo "ERROR: Timed out waiting for Arduino 101."
fi
