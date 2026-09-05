# Assignment1-Linux-Bash-Networking

A Linux diagnostic toolkit written in Bash. The scripts collect system information, check disk usage against a threshold, and perform basic network diagnostics.

## Requirements

- Linux or WSL
- Bash
- `df`, `free`, `lscpu`, and `ip`
- `ping`, `getent`, and `nc` for the network checks

Make the scripts executable before running them:

```bash
chmod +x system-info.sh disk-check.sh network-check.sh grade.sh
```

## Usage

### System information

```bash
./system-info.sh
```

Displays the current hostname, user, date and time, operating system, kernel version, uptime, CPU information, memory information, and working directory. Values are collected from the system when the script runs.

### Disk usage

```bash
./disk-check.sh <threshold> [path]
```

The threshold must be an integer from `1` to `100`. The path is optional and defaults to `/`.

Examples:

```bash
./disk-check.sh 80
./disk-check.sh 75 /home
```

The script displays the disk usage percentage and returns:

- `0` when usage is below the threshold
- `1` when usage reaches or exceeds the threshold
- `2` for invalid input or an invalid path

### Network checks

```bash
./network-check.sh <hostname-or-ip> [port]
```

The script resolves the host, displays the resolved address, performs a basic ping connectivity check, and displays network interface information. If a port is supplied, it also checks TCP connectivity. Valid ports are `1` through `65535`.

Examples:

```bash
./network-check.sh example.com
./network-check.sh example.com 443
```

Network results are written to `logs/network-check.log` with timestamps and descriptions. Invalid arguments return status `2`; failed resolution, connectivity, or dependency checks return a non-zero status.

### Grader

Run the included 100-point validation script from the project directory:

```bash
./grade.sh
```

The grader checks required files, Bash syntax, executable permissions, runtime output, disk and network validation, error handling, logging, Git history, and this README.

## Structure

```text
.
├── README.md
├── system-info.sh
├── disk-check.sh
├── network-check.sh
├── grade.sh
└── logs/
 └── .gitkeep
```

## Files

- `README.md` — Project documentation
- `system-info.sh` — Runtime system information
- `disk-check.sh` — Disk usage threshold check
- `network-check.sh` — Host, connectivity, interface, and TCP checks
- `grade.sh` — 100-point grading and validation script
- `logs/` — Runtime network-check logs
