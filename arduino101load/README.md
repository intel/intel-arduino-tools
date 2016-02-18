# arduino101load
multiplatform launcher for Arduino101 dfu-util flashing utility

## Compiling

* Download go package from [here](https://golang.org/dl/) or using your package manager
* `cd` into the root folder of this project
* execute
```bash
export GOPATH=$PWD
go get
go build
```
to produce a binary of `arduino101load` for your architecture.

To cross compile for different OS/architecture combinations, execute
```bash
GOOS=windows GOARCH=386 go build  #windows
GOOS=darwin GOARCH=amd64 go build #osx
GOOS=linux GOARCH=386 go build    #linux_x86
GOOS=linux GOARCH=amd64 go build  #linux_x86-64
```
