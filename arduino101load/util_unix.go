// +build linux darwin

package main

import (
	"os/exec"
)

func tellCommandNotToSpawnShell(_ *exec.Cmd) {
}
