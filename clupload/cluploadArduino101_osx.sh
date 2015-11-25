#!/bin/sh

setup() {
    # ARG 1: Path to directory which contains dfu-util executable
    dfu_util_dir=$1
    # ARG 2: Elf file to upload
    payload_elf=$2
    # ARG 3: TTY port to use
    tty_port_id=$3

    # Upload the .bin instead of .elf
    payload_bin=${payload_elf/elf/bin}
    echo "Payload:" $payload_bin

    export DYLD_LIBRARY_PATH=$dfu_util_dir:$DYLD_LIBRARY_PATH
    DFU="$dfu_util_dir/dfu-util -d,8087:0ABA"
}

trap_to_dfu() {
    dfu_lock=$TMPDIR/dfu_lock
    
    # If dfu_lock already exists, clean up before starting the loop
    [ -f $dfu_lock ] && rm -f $dfu_lock

    # Loop to read from 101 so that it stays on DFU mode afterwards.
    counter=0
    until $DFU -a 4 -U $dfu_lock > /dev/null 2>&1
    do
        sleep 0.1
    
        # Wait in loop only up to 50 times
        let counter=counter+1
        if [ "$counter" -gt "50" ]; then
            echo "ERROR: Timed out waiting for Arduino 101."
            exit 1
        fi
    done

    # Clean up
    [ -f $dfu_lock ] && rm -f $dfu_lock
}

upload() {
    $DFU -a 7 -R -D $payload_bin
    echo "Sketch will execute in about 5 seconds."
}

main() {
    echo "Starting upload script"
    setup "$@"

    echo "Waiting for device... "
    trap_to_dfu

    echo "Using dfu-util to send " $payload_bin
    upload

    exit 0
}

main "$@"
