#!/usr/bin/env sh
# Fetch a new dashboard image, make sure to output it to "$1".
# For example:
"$(dirname "$0")/../xh" -d -q -o "$1" get http://192.168.1.3:8080/image
