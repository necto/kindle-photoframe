#!/usr/bin/env sh
# Fetch a new dashboard image, make sure to output it to "$1".
# For example:

# Also report battery level to the image server
# (since it is not displayed on the kindle itself)
battery_level=$(gasgauge-info -c)
"$(dirname "$0")/../xh" -d -q -o "$1" get http://192.168.1.3:8080/image?battery="$battery_level"
