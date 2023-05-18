# A script that forwards logs to a Telegram bot

The following script is an init script for a Telegram Log Monitor. Its purpose is to monitor a log file and send log messages to a specified Telegram group chat using a Telegram bot API.

> Slate is the hostname of the travel router I use :)
## Script Breakdown

- The script is written in the Shell scripting language and begins with the shebang (`#!/bin/sh /etc/rc.common`), which specifies the interpreter to be used.

- The script sets two variables, `START` and `STOP`, which determine the start and stop priorities for the script.

- It defines two variables, `TELEGRAM_API_TOKEN` and `TELEGRAM_GROUP_ID`, used for authentication and specifying the target group chat for sending messages via the Telegram bot API.

- The `LOG_FILE` variable is set to specify the path of the log file to monitor.

- Several regular expression patterns (`LOG_PATTERN_NOTICE`, `LOG_PATTERN_INFO`, `LOG_PATTERN_HOSTAPD_CONNECTED`, `LOG_PATTERN_HOSTAPD_DISCONNECTED`) are defined to match specific log message patterns.

- An empty `tracked_devices` variable is initialized.

- The `send_telegram_message` function is defined to send a message to the Telegram group chat. It formats the message, replacing characters that may cause issues with HTML formatting. It then uses `curl` to make a request to the Telegram bot API, sending the formatted message to the specified chat ID. It also checks for errors in the API response and recursively calls itself if there is an error.

- The `track_device` function adds a device MAC address to the `tracked_devices` list and sends a notification to the Telegram group chat.

- The `remove_device` function removes a disconnected device from the `tracked_devices` list and sends a notification to the Telegram group chat.

Overall, this script sets up a Telegram Log Monitor that continuously monitors a log file, tracks device connections and disconnections, and sends log messages and notifications to a specified Telegram group chat using the Telegram bot API.


To enable the Telegram Log Monitor script on OpenWrt, you can follow these steps:

1. SSH into your OpenWrt router: Use an SSH client (e.g., PuTTY) to connect to your OpenWrt router using its IP address and login credentials.

2. Copy the script: Once connected to the router via SSH, create a new file and paste the entire script into it. You can use the `vi` or `nano` text editors to create and edit the file. For example, you can run `nano telegram-auth-log` to create a new file named `telegram-auth-log` and paste the script content into it.

3. Save the script: After pasting the script into the file, save it by pressing `Ctrl + O` (in `nano`) or `Esc` followed by `:wq` and Enter (in `vi`). Make sure the file is saved in a location accessible by the system, such as the `/etc/init.d/` directory.

4. Set permissions: Set the executable permissions for the script by running the following command:
   ```
   chmod +x /etc/init.d/telegram-auth-log
   ```

5. Configure the script: Open the script file using the text editor and modify the following variables according to your setup:
    - `TELEGRAM_API_TOKEN`: Replace it with your actual Telegram bot API token.
    - `TELEGRAM_GROUP_ID`: Replace it with the ID of your Telegram group chat.
    - `LOG_FILE`: If the log file to monitor is different from `/var/log/messages`, update this variable accordingly.
    - `LOG_PATTERN_NOTICE`, `LOG_PATTERN_INFO`, `LOG_PATTERN_HOSTAPD_CONNECTED`, `LOG_PATTERN_HOSTAPD_DISCONNECTED`: Modify these regular expression patterns if you need to match different log messages. In my case I am using `authpriv` and `hostapd` which match to logs ssh and wireless connections.

6. Enable the script: Run the following command to enable the script:
   ```
   /etc/init.d/telegram-auth-log enable
   ```

7. Start the script: Start the Telegram Log Monitor script by running the following command:
   ```
   /etc/init.d/telegram-auth-log start
   ```

The script should now be active and monitoring the specified log file. It will send log messages and notifications to the configured Telegram group chat. You can check the functionality and troubleshoot any potential issues by examining the log messages in the OpenWrt system logs or by monitoring the Telegram group chat.
