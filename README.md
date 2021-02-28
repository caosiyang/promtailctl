# promtailctl

This script is used for promtail binary on Linux.

## Usage

Put promtail binary and configuration file with the following directory structure:

```Shell
$ tree
.
├── bin
│   └── promtail
├── conf
│   └── promtail.yaml
└── promtailctl.sh

2 directories, 3 files
```

Execute script to start/stop/status/restart promtail on any working directory:

```Shell
$ ./promtailctl.sh start
Starting promtail:      [ OK ] 

$ ./promtailctl.sh status
promtail (pid 6186) is running...

$ ./promtailctl.sh restart
Restarting promtail: 
Stopping promtail:      [ OK ] 
Starting promtail:      [ OK ] 

$ ./promtailctl.sh status
promtail (pid 7624) is running...

$ ./promtailctl.sh stop
Stopping promtail:      [ OK ] 

$ ./promtailctl.sh status
kromtail is stopped
```
