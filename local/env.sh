#!/usr/bin/env sh

# Export environment variables here
export WIFI_TEST_IP=${WIFI_TEST_IP:-1.1.1.1}
export REFRESH_SCHEDULE=${REFRESH_SCHEDULE:-"* 5-22 * * *"}
export TIMEZONE=${TIMEZONE:-"Europe/Amsterdam"}

# By default, partial screen updates are used to update the screen,
# to prevent the screen from flashing. After a few partial updates,
# the screen will start to look a bit distorted (due to e-ink ghosting).
# This number determines when a full refresh is triggered. By default it's
# triggered after 4 partial updates.
export FULL_DISPLAY_REFRESH_RATE=${FULL_DISPLAY_REFRESH_RATE:-4}

# When the time until the next wakeup is greater or equal to this number,
# the dashboard will not be refreshed anymore, but instead show a
# 'kindle is sleeping' screen. This can be useful if your schedule only runs
# during the day, for example.
export SLEEP_SCREEN_INTERVAL=100000000 # kindle never sleeps

export LOW_BATTERY_REPORTING=true
export LOW_BATTERY_THRESHOLD_PERCENT=10
