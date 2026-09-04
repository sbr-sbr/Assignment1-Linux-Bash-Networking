#!/bin/bash

echo "System Information:"
current_hostname=$(hostname)
current_user=$(whoami)
current_date_time=$(date +"%F")
device_operating_system=$(uname -s)
device_kernel_version=$(uname -r)
device_uptime=$(uptime -p)
device_cpu_information=$(lscpu)
device_memory_information=$(free -h)
current_working_directory=$(pwd)

echo "Hostname: $current_hostname"
echo "User: $current_user"
echo "Date and Time: $current_date_time"
echo "Operating System: $device_operating_system"
echo "Kernel Version: $device_kernel_version"
echo "Uptime: $device_uptime"
echo "Memory Information: $device_memory_information"
echo "Working Directory: $current_working_directory"
echo "CPU Information: $device_cpu_information"