package main

import (
	"bufio"
	"fmt"
	"github.com/codeskyblue/go-sh"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
	"time"
)

var verbose bool

func PrintlnVerbose(a ...interface{}) {
	if verbose {
		fmt.Println(a...)
	}
}

func main() {
	fmt.Println("Starting download script...")

	// ARG 1: Path to binaries
	// ARG 2: BIN File to download
	// ARG 3: TTY port to use.
	// ARG 4: quiet/verbose
	// path may contain \ need to change all to /

	args := os.Args[1:]

	bin_path := args[0]
	dfu := bin_path + "/dfu-util"
	dfu = filepath.ToSlash(dfu)
	dfu_flags := "-d,8087:0ABA"

	bin_file_name := args[1]

	com_port := args[2]
	verbosity := args[3]

	if verbosity == "quiet" {
		verbose = false
	} else {
		verbose = true
	}

	PrintlnVerbose("Args to shell:", args)
	PrintlnVerbose("Serial Port: " + com_port)
	PrintlnVerbose("BIN FILE " + bin_file_name)

	counter := 0
	board_found := false

	if runtime.GOOS == "darwin" {
		library_path := os.Getenv("DYLD_LIBRARY_PATH")
		if !strings.Contains(library_path, bin_path) {
			os.Setenv("DYLD_LIBRARY_PATH", bin_path+":"+library_path)
		}
	}

	for counter < 10 && board_found == false {
		PrintlnVerbose("Waiting for device...")
		out, err := sh.Command(dfu, dfu_flags, "-l").Output()
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}
		if counter == 4 {
			fmt.Println("Flashing is taking longer than expected")
			fmt.Println("Try pressing MASTER_RESET button")
		}
		if strings.Contains(string(out), "sensor_core") {
			board_found = true
			PrintlnVerbose("Device found!")
			break
		}
		time.Sleep(1000 * time.Millisecond)
		counter++
	}

	if board_found == false {
		fmt.Println("ERROR: Timed out waiting for Arduino 101 on " + com_port)
		os.Exit(1)
	}

	dfu_download := []string{dfu, dfu_flags, "-D", bin_file_name, "-v", "--alt", "7", "-R"}

	oscmd := exec.Command(dfu_download[0], dfu_download[1:]...)

	tellCommandNotToSpawnShell(oscmd)

	stdout, _ := oscmd.StdoutPipe()

	stderr, _ := oscmd.StderrPipe()

	multi := io.MultiReader(stderr, stdout)

	err := oscmd.Start()

	in := bufio.NewScanner(multi)

	in.Split(bufio.ScanLines)

	for in.Scan() {
		PrintlnVerbose(in.Text())
	}

	err = oscmd.Wait()

	if err == nil {
		fmt.Println("SUCCESS: Sketch will execute in about 5 seconds.")
		os.Exit(0)
	} else {
		fmt.Println("ERROR: Upload failed on " + com_port)
		os.Exit(1)
	}
}
