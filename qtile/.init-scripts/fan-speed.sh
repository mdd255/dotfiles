#!/bin/bash

fan_speed=$1

echo "level $fan_speed" > /proc/acpi/ibm/fan
cat /proc/acpi/ibm/fan
exit
