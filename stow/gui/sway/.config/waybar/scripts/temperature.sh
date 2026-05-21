#!/bin/sh
cpu=$(cat /sys/class/hwmon/hwmon5/temp1_input)
gpu=$(cat /sys/class/hwmon/hwmon2/temp1_input)
cpu_c=$((cpu / 1000))
gpu_c=$((gpu / 1000))
echo "CPU ${cpu_c}°C | GPU ${gpu_c}°C"
