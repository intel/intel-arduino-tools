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
echo "Using tty Port" $tty_port_id 
#
#echo "Sending Command String to move to download if not already in download mode"
#echo "~sketch downloadEDU" > $tty_port_id
#Give the host time to stop the process and wait for download
sleep 1

#Download the file.
host_file_name=$2
bin_file_name=${host_file_name/elf/bin}
echo "BIN FILE" $bin_file_name

#~/.arduino15/packages/Intel-Test/tools/sketchUploader/1.6.2+1.0/clupload/jtag_arc.expect $bin_file_name

/usr/local/bin/dfu-util -d8087:0a99 -D $bin_file_name -v --alt 7
