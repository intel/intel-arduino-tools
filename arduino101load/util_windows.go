package main

import (
	"os/exec"
	"syscall"
)

func tellCommandNotToSpawnShell(oscmd *exec.Cmd) {
	oscmd.SysProcAttr = &syscall.SysProcAttr{HideWindow: true}
}
