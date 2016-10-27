package main

import (
    "io"
    "log"
    "os"
    "fmt"
)

func main() {
    args := os.Args[1:]

    // Make sure there are only two arguments
    if len(args) != 2 {
        log.Fatalf("%s <source> <destination>", os.Args[0])
    }
    
    source_path := args[0]
    destination_path := args[1]

    // Make sure the source file exists
    source_file, err := os.Open(source_path)
    exit_if_error(err)
    defer source_file.Close()
    
    // Make sure we can create the destination file
    destination_file, err := os.Create(destination_path)
    exit_if_error(err)
    defer destination_file.Close()
    
    // Copy
    _, err = io.Copy(destination_file, source_file)
    exit_if_error(err)

    // Report
    fmt.Printf("Copied %s to %s\n", source_path, destination_path)
}

func exit_if_error(err error) {
    if err != nil {
        log.Fatal("ERROR:", err)
    }
}

