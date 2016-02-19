#!/bin/sh

dbg_print() {
	if [ "x$verbosity" == "xverbose" ]; then
		echo "$@"
	fi
}

error_out() {
	echo "$@"
	exit -1
}

main() {
	echo "Starting download script..."

	# ARG 1: Path to additional executables.
	# ARG 2: Elf File to download
	# ARG 3: TTY port to use.
	# ARG 4: quiet/verbose

	fixed_path="$1"
	# Download .bin file instead of provided .elf
	bin_file_name=${2/.elf/.bin}
	com_port="$3"
	verbosity="$4"
	dfu="$fixed_path/dfu-util"
	dfu_cmd="$dfu -d,8087:0ABA"

	dbg_print "Args to shell:" "$@"
	dbg_print "Serial Port:" "$com_port"
	dbg_print "BIN FILE" "$bin_file_name"
	dbg_print "Wating for Arduino 101 device... "

	COUNTER=0
	f=$($dfu_cmd -l | grep sensor_core | cut -f 1 -d ' ')
	while [ "x$f" = "x" ] && [ $COUNTER -lt 10 ]
	do
		let COUNTER=COUNTER+1
		sleep 1
		f=$($dfu_cmd -l | grep sensor_core | cut -f 1 -d ' ')
	done

	if [ "x$verbosity" == "xverbose" ] ; then
		dfu_download="$dfu_cmd -D $bin_file_name -v --alt 7 -R"
	else
		dfu_download="$dfu_cmd -D $bin_file_name --alt 7 -R >/dev/null 2>&1"
	fi

	if [ "x$f" != "x" ] ; then
		dbg_print "Using dfu-util to send " "$bin_file_name"
		dbg_print "$dfu_download"
		eval $dfu_download || error_out "ERROR: DFU transfer failed"
		echo "SUCCESS: Sketch will execute in about 5 seconds."
	else
		error_out "ERROR: Device is not responding."
	fi
}

main "$@"
