#!/bin/sh /etc/rc.common
# Init script for Telegram Log Monitor

START=99
STOP=10

# Telegram bot API token and group chat ID
TELEGRAM_API_TOKEN=""
TELEGRAM_GROUP_ID=""

# Log file to monitor
LOG_FILE="/var/log/messages"

# Regular expression patterns to match log messages
LOG_PATTERN_NOTICE="authpriv.notice"
LOG_PATTERN_INFO="authpriv.info"
LOG_PATTERN_HOSTAPD_CONNECTED="hostapd:.*AP-STA-CONNECTED"
LOG_PATTERN_HOSTAPD_DISCONNECTED="hostapd:.*AP-STA-DISCONNECTED"

# Tracked devices list
tracked_devices=""

# Function to send a message to Telegram
send_telegram_message() {
  local message="$1"
  formatted_message=$(echo "$message" | sed 's/"/\"/g' | sed "s/'/\'/g" | sed 's/^/<pre>/g' | sed 's/$/<\/pre>/g')
  # Send message using curl
  curl_output=$(curl -s "https://api.telegram.org/bot${TELEGRAM_API_TOKEN}/sendMessage" \
    -d "chat_id=${TELEGRAM_GROUP_ID}" \
    -d "parse_mode=HTML" \
    -d "text=${formatted_message}" 2>&1)

  # Check for Telegram API errors
  if echo "$curl_output" | grep -q 'false,'; then
    error_message=$(echo "$curl_output" | sed -n 's/.*"description":"\([^"]*\)".*/\1/p')
    echo "Telegram API error: $error_message"
    send_telegram_message "A log message failed to send, please check server logs."
  fi
}

track_device() {
  local device_mac="$1"
  tracked_devices="${tracked_devices}${device_mac} "
  send_telegram_message "Device connected: $device_mac"
}

# Function to remove a disconnected device from the tracked list
remove_device() {
  local device_mac="$1"
  tracked_devices=$(echo "${tracked_devices}" | sed "s/${device_mac} //g")
  send_telegram_message "Device disconnected: $device_mac"
}

start() {
 send_telegram_message "Telegram Log Monitor started."

  # Tail the log file and monitor for new log messages in the background
  tail -Fn0 "$LOG_FILE" | while read -r line; do
    if echo "$line" | grep -qE "$LOG_PATTERN_NOTICE | $LOG_PATTERN_INFO | $LOG_PATTERN_HOSTAPD_CONNECTED | $LOG_PATTERN_HOSTAPD_DISCONNECTED"; then
      send_telegram_message "$line"
    fi

    if echo "${line}" | grep -q "$LOG_PATTERN_HOSTAPD_CONNECTED"; then
      local device_mac=$(echo "${line}" | awk '{print $10}')
      if ! echo "${tracked_devices}" | grep -q "${device_mac}"; then
        track_device "${device_mac}"
      fi
    fi

    if echo "${line}" | grep -q "$LOG_PATTERN_HOSTAPD_DISCONNECTED"; then
      local device_mac=$(echo "${line}" | awk '{print $10}')
      if echo "${tracked_devices}" | grep -q "${device_mac}"; then
        remove_device "${device_mac}"
	      tracked_devices=$(echo "${tracked_devices}" | sed "s/ ${device_mac}//g")
      fi
    fi

  done &
}

stop() {
  send_telegram_message "Slate stopped."
  # Stop the script by killing the tail process
  killall tail
}

reload() {
 send_telegram_message "Slate reloading..."
 restart
}

restart() {
  send_telegram_message "Slate restarted."

  stop
  sleep 1
  start
}

boot() {
  send_telegram_message "Slate is coming online."
  start
}

shutdown() {
  send_telegram_message "Slate is shutting down."
  stop
}
