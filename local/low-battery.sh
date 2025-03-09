#!/usr/bin/env sh
battery_level_percentage=$1

fbink -pmh -y -1 "Low battery: $battery_level_percentage%"
