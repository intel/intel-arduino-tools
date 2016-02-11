#!/bin/sh

dbg_print() {
	if [ "x$verbosity" == "xverbose" ] ; then
		echo "$@"
	fi
}

# find_string $string $filename
# searches for string in a file,
# returns "found" on success and "not_found" on failure
find_string() {
	while read -r; do
		[[ $REPLY = *$1* ]] && echo "found" && return;
	done < "$2"
	echo "not_found"
}

error_out() {
	echo "$@"
	exit -1
}

main() {
	echo "Starting download script..."

	# ARG 1: Path to cygwin binaries
	# ARG 2: Elf File to download
	# ARG 3: TTY port to use.
	# ARG 4: quiet/verbose
	#
	# path may contain \ need to change all to /

	cyg_path="${1//\\/\/}"
	dfu="$cyg_path/dfu-util.exe"
	dfu_flags="-d,8087:0ABA"
	sleep="$cyg_path/sleep.exe"
	tmp_dfu_output="$cyg_path/../../.tmp_dfu_output"

	# We want to download .bin file instead of provided .elf
	host_file_name=${2//\\/\/}
	bin_file_name=${host_file_name/.elf/.bin}

	com_port="$3"
	verbosity="$4"

	dbg_print "Args to shell:" "$@"
	dbg_print "Serial Port:" "$com_port"
	dbg_print "BIN FILE" "$bin_file_name"
	dbg_print "Waiting for device..."

	COUNTER=0
	"$dfu" $dfu_flags -l  >"$tmp_dfu_output"
	f=$(find_string "sensor_core" "$tmp_dfu_output")
	while [ "x$f" == "xnot_found" ] && [ $COUNTER -lt 10 ]
	do
		let COUNTER=COUNTER+1
		"$sleep" 1
		"$dfu" $dfu_flags -l >"$tmp_dfu_output"
		f=$(find_string "sensor_core" "$tmp_dfu_output")
	done

	if [ "x$verbosity" == "xverbose" ] ; then
		dfu_download="\"$dfu\" $dfu_flags -D \"$bin_file_name\" -v --alt 7 -R"
	else
		dfu_download="\"$dfu\" $dfu_flags -D \"$bin_file_name\" --alt 7 -R >/dev/null 2>&1"
	fi

	if [ "x$f" == "xfound" ] ; then
		dbg_print "Using dfu-util to send " "$bin_file_name"
		dbg_print "$dfu_download"
		eval $dfu_download || error_out "ERROR: DFU transfer failed"
		echo "SUCCESS: Sketch will execute in about 5 seconds."
	else
		echo "ERROR: Device is not responding."
	fi
}

main "$@"
