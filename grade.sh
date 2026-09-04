#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
cd "$SCRIPT_DIR" || exit 1

TOTAL=0
MAXIMUM=100
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

pass() {
	printf 'PASS: %s (+%s points)\n' "$1" "$2"
	TOTAL=$((TOTAL + $2))
}

fail() {
	printf 'FAIL: %s (0 points)\n' "$1"
}

check_file() {
	local file=$1
	local points=$2

	if [ -f "$file" ]; then
		pass "$file exists" "$points"
	else
		fail "$file exists"
	fi
}

check_syntax() {
	local file=$1
	local points=$2

	if bash -n "$file" 2>/dev/null; then
		pass "$file has valid Bash syntax" "$points"
	else
		fail "$file has valid Bash syntax"
	fi
}

printf 'Assignment 1 Grader\n====================\n'

printf '\nLinux commands (20 points)\n'
COMMAND_COUNT=0
for command_name in bash date hostname uname uptime lscpu free df ip ping getent nc; do
	if command -v "$command_name" >/dev/null 2>&1; then
		COMMAND_COUNT=$((COMMAND_COUNT + 1))
	else
		printf 'Missing command: %s\n' "$command_name"
	fi
done
if [ "$COMMAND_COUNT" -eq 12 ]; then
	pass 'required Linux commands are available' 20
else
	fail 'required Linux commands are available'
fi

printf '\nBash scripting (25 points)\n'
for file in system-info.sh disk-check.sh network-check.sh grade.sh; do
	check_file "$file" 1
done
check_syntax system-info.sh 3
check_syntax disk-check.sh 3
check_syntax network-check.sh 3
if grep -q '^#!/bin/bash' system-info.sh && grep -q '^#!/bin/bash' disk-check.sh && grep -q '^#!/bin/bash' network-check.sh; then
	pass 'scripts use a Bash shebang' 2
else
	fail 'scripts use a Bash shebang'
fi
if [ -x system-info.sh ] && [ -x disk-check.sh ] && [ -x network-check.sh ] && [ -x grade.sh ]; then
	pass 'scripts are executable' 5
else
	fail 'scripts are executable'
fi

printf '\nSystem information (included in Bash scripting)\n'
if ./system-info.sh >"$TMP_DIR/system-info.out" 2>"$TMP_DIR/system-info.err" && \
   grep -q 'Hostname:' "$TMP_DIR/system-info.out" && \
   grep -q 'User:' "$TMP_DIR/system-info.out" && \
   grep -q 'Date and Time:' "$TMP_DIR/system-info.out" && \
   grep -q 'Operating System:' "$TMP_DIR/system-info.out" && \
   grep -q 'Kernel Version:' "$TMP_DIR/system-info.out" && \
   grep -q 'Uptime:' "$TMP_DIR/system-info.out" && \
   grep -q 'CPU Information:' "$TMP_DIR/system-info.out" && \
   grep -q 'Memory Information:' "$TMP_DIR/system-info.out" && \
   grep -q 'Working Directory:' "$TMP_DIR/system-info.out"; then
	pass 'system-info.sh displays required runtime information' 5
else
	fail 'system-info.sh displays required runtime information'
fi

printf '\nDisk validation (included in Error handling)\n'
if ./disk-check.sh 100 / >"$TMP_DIR/disk.out" 2>/dev/null && grep -Eq 'Disk usage for /: [0-9]+%' "$TMP_DIR/disk.out"; then
	pass 'disk-check.sh displays disk usage and handles a valid threshold' 0
else
	fail 'disk-check.sh displays disk usage and handles a valid threshold'
fi
if ./disk-check.sh invalid >/dev/null 2>&1; then
	fail 'disk-check.sh rejects invalid input'
else
	disk_status=$?
	if [ "$disk_status" -eq 2 ]; then
		pass 'disk-check.sh rejects invalid input with status 2' 5
	else
		fail 'disk-check.sh rejects invalid input with status 2'
	fi
fi

printf '\nNetworking (20 points)\n'
if ./network-check.sh localhost >"$TMP_DIR/network.out" 2>"$TMP_DIR/network.err" && \
   grep -q 'Resolved address' "$TMP_DIR/network.out" && \
   grep -q 'Connectivity check' "$TMP_DIR/network.out" && \
   grep -q 'Network interfaces:' "$TMP_DIR/network.out"; then
	pass 'network-check.sh resolves, connects, and displays interfaces' 10
else
	fail 'network-check.sh resolves, connects, and displays interfaces'
fi
if ./network-check.sh localhost 0 >/dev/null 2>&1; then
	fail 'network-check.sh rejects an invalid port'
else
	network_status=$?
	if [ "$network_status" -eq 2 ]; then
		pass 'network-check.sh rejects an invalid port with status 2' 5
	else
		fail 'network-check.sh rejects an invalid port with status 2'
	fi
fi
if ./network-check.sh localhost 22 >"$TMP_DIR/port.out" 2>/dev/null; then
	pass 'network-check.sh performs an optional TCP check' 5
else
	fail 'network-check.sh performs an optional TCP check'
fi

printf '\nError handling (10 points)\n'
if ./disk-check.sh 50 /path/that/does/not/exist >/dev/null 2>&1; then
	fail 'disk-check.sh handles an invalid path'
else
	fail_status=$?
	if [ "$fail_status" -eq 2 ]; then
		pass 'disk-check.sh handles an invalid path without crashing' 0
	else
		fail 'disk-check.sh handles an invalid path without crashing'
	fi
fi
if ./network-check.sh invalid.invalid >/dev/null 2>&1; then
	fail 'network-check.sh handles an unresolvable host'
else
	pass 'network-check.sh handles an unresolvable host without crashing' 5
fi

printf '\nLogging (10 points)\n'
if [ -f logs/network-check.log ] && grep -Eq '^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\] .+' logs/network-check.log; then
	pass 'logs contain timestamps and descriptions' 10
else
	fail 'logs contain timestamps and descriptions'
fi

printf '\nGit workflow (10 points)\n'
if git rev-parse --is-inside-work-tree >/dev/null 2>&1 && [ "$(git rev-list --count HEAD 2>/dev/null)" -ge 2 ]; then
	pass 'repository has Git history' 10
else
	fail 'repository has Git history'
fi

printf '\nREADME (5 points)\n'
if [ -s README.md ] && grep -qi 'network\|disk\|system' README.md; then
	pass 'README documents the toolkit' 5
else
	fail 'README documents the toolkit'
fi

printf '\nScore: %s/%s\n' "$TOTAL" "$MAXIMUM"
if [ "$TOTAL" -eq "$MAXIMUM" ]; then
	exit 0
fi
exit 1
