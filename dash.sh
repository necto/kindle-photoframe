#!/usr/bin/env sh
DEBUG=${DEBUG:-false}
[ "$DEBUG" = true ] && set -x

DIR="$(dirname "$0")"
DASH_PNG="$DIR/dash.png"
FETCH_DASHBOARD_CMD="$DIR/local/fetch-dashboard.sh"
LOW_BATTERY_CMD="$DIR/local/low-battery.sh"

WIFI_TEST_IP=${WIFI_TEST_IP:-1.1.1.1}
TIMEZONE=${TIMEZONE:-"Europe/Zurich"}
REFRESH_SCHEDULE=${REFRESH_SCHEDULE:-"0 8,12,16,19 * * *"}
FULL_DISPLAY_REFRESH_RATE=${FULL_DISPLAY_REFRESH_RATE:-2}
SLEEP_SCREEN_INTERVAL=${SLEEP_SCREEN_INTERVAL:-3600}
RTC_WAKE=/sys/class/rtc/rtc0/wakealarm
RTC_TIME=/sys/class/rtc/rtc0/since_epoch

LOW_BATTERY_REPORTING=${LOW_BATTERY_REPORTING:-false}
LOW_BATTERY_THRESHOLD_PERCENT=${LOW_BATTERY_THRESHOLD_PERCENT:-10}

num_refresh=0

init() {
  if [ -z "$TIMEZONE" ] || [ -z "$REFRESH_SCHEDULE" ]; then
    echo "Missing required configuration."
    echo "Timezone: ${TIMEZONE:-(not set)}."
    echo "Schedule: ${REFRESH_SCHEDULE:-(not set)}."
    exit 1
  fi

  echo "Starting dashboard with $REFRESH_SCHEDULE refresh..."

  # This does nothing on PW3 (kindle paper white 3) if DEBUG is set,
  # and it hangs if DEBUG is not set.
  # Alternative command could be "stop framework", which disables most of the UI,
  # but it is not useful either:
  # - it does not disable the clock, wifi, and battery indicators which pierce through pictures
  # - the rest of the UI does not interefere anyway
  # - it starts "crash report" dialog
  # - I don't know how to revive kindle after that without restarting (start framework is not enough)
  # So commenting out:
  # /etc/init/framework stop
  initctl stop webreader >/dev/null 2>&1
  echo powersave >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  lipc-set-prop com.lab126.powerd preventScreenSaver 1

  # Disable frontlight completely
  # This sets it to minimum but not 0: `lipc-set-prop com.lab126.powerd flIntensity 0`
  # This disables it completely:
  echo -n 0 >/sys/class/backlight/max77696-bl/brightness
}

prepare_sleep() {
  echo "Preparing sleep"

  /usr/sbin/eips -f -g "$DIR/sleeping.png"

  # Give screen time to refresh
  sleep 2

  # Ensure a full screen refresh is triggered after wake from sleep
  num_refresh=$FULL_DISPLAY_REFRESH_RATE
}

refresh_dashboard() {
  echo "Refreshing dashboard"
  "$DIR/wait-for-wifi.sh" "$WIFI_TEST_IP"

  "$FETCH_DASHBOARD_CMD" "$DASH_PNG"
  fetch_status=$?

  if [ "$fetch_status" -ne 0 ]; then
    echo "Not updating screen, fetch-dashboard returned $fetch_status"
    fbink -pmh -y 0 "Fetch failed: $fetch_status"
    return 1
  fi

  if [ "$num_refresh" -eq "$FULL_DISPLAY_REFRESH_RATE" ]; then
    num_refresh=0

    # trigger a full refresh once in every 4 refreshes, to keep the screen clean
    echo "Full screen refresh"
    /usr/sbin/eips -f -g "$DASH_PNG"
  else
    echo "Partial screen refresh"
    /usr/sbin/eips -g "$DASH_PNG"
  fi

  num_refresh=$((num_refresh + 1))
}

log_battery_stats() {
  battery_level=$(gasgauge-info -c)
  echo "$(date) Battery level: $battery_level."

  if [ "$LOW_BATTERY_REPORTING" = true ]; then
    battery_level_numeric=${battery_level%?}
    if [ "$battery_level_numeric" -le "$LOW_BATTERY_THRESHOLD_PERCENT" ]; then
      "$LOW_BATTERY_CMD" "$battery_level_numeric"
    fi
  fi
}

rtc_sleep() {
  duration=$1

  if [ "$DEBUG" = true ]; then
    sleep "$duration"
  else
    # shellcheck disable=SC2039
    [ -z "$(cat "$RTC_WAKE")" ] && echo $(($(cat "$RTC_TIME") + $duration)) >"$RTC_WAKE"
    echo "mem" >/sys/power/state
  fi
}

main_loop() {
  while true; do

    next_wakeup_secs=$("$DIR/next-wakeup" --schedule="$REFRESH_SCHEDULE" --timezone="$TIMEZONE")

    # take a bit of time before going to sleep, so this process can be aborted
    # Doing this before the refresh to minimize the chance of some UI update breaking through the picture
    # as it happens with the clock, wifi, and battery indicators
    sleep 10

    if [ "$next_wakeup_secs" -gt "$SLEEP_SCREEN_INTERVAL" ]; then
      action="sleep"
      prepare_sleep
    else
      action="suspend"
      refresh_dashboard
    fi
    # Invoke after the refresh, to show battery level on top of the picture
    log_battery_stats

    echo "Going to $action, next wakeup in ${next_wakeup_secs}s"

    rtc_sleep "$next_wakeup_secs"
  done
}

init
main_loop
