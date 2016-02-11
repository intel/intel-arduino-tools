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

setup() {
    # ARG 1: Path to directory which contains dfu-util executable
    dfu_util_dir=$1
    # ARG 2: Elf file to upload
    payload_elf=$2
    # ARG 3: TTY port to use
    tty_port_id=$3
    # ARG 4: quiet/verbose
    verbosity=$4

    # Upload the .bin instead of .elf
    payload_bin=${payload_elf/.elf/.bin}
    dbg_print "Payload:" $payload_bin

    export DYLD_LIBRARY_PATH=$dfu_util_dir:$DYLD_LIBRARY_PATH
    dfu_cmd="$dfu_util_dir/dfu-util -d,8087:0ABA"

    if [ "x$verbosity" == "xverbose" ] ; then
        dfu_download="$dfu_cmd -D $payload_bin -v --alt 7 -R"
    else
        dfu_download="$dfu_cmd -D $payload_bin --alt 7 -R >/dev/null 2>&1"
    fi
}

trap_to_dfu() {
    dfu_lock=$TMPDIR/dfu_lock
    
    # If dfu_lock already exists, clean up before starting the loop
    [ -f $dfu_lock ] && rm -f $dfu_lock

    # Loop to read from 101 so that it stays on DFU mode afterwards.
    counter=0
    until $dfu_cmd -a 4 -U $dfu_lock > /dev/null 2>&1
    do
        sleep 0.1
    
        # Wait in loop only up to 50 times
        let counter=counter+1
        if [ "$counter" -gt "50" ]; then
            echo "ERROR: Device is not responding."
            exit -1
        fi
    done

    # Clean up
    [ -f $dfu_lock ] && rm -f $dfu_lock
}

upload() {
    eval $dfu_download || error_out "ERROR: DFU transfer failed"
    echo "SUCCESS: Sketch will execute in about 5 seconds."
}

main() {
    echo "Starting upload script"
    setup "$@"

    dbg_print "Waiting for device... "
    trap_to_dfu

    dbg_print "Using dfu-util to send " $payload_bin
    upload

    exit 0
}

main "$@"
