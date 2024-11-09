#!/bin/bash

CONFIG_FILE="/opt/server_monitoring/config.conf"
source "$CONFIG_FILE"

send_alert() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" -d text="$message"
}

check_disk() {
    if [[ "$ROOT_MONITOR" == "y" ]]; then
        USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
        if [ "$USAGE" -ge "$THRESHOLD" ]; then
            send_alert "Peringatan: Penggunaan disk mencapai ${USAGE}%!"
        fi
    fi
}

check_ram() {
    if [[ "$RAM_MONITOR" == "y" ]]; then
        USAGE=$(free | awk '/Mem/ {printf("%.0f"), $3/$2 * 100.0}')
        if [ "$USAGE" -ge "$THRESHOLD" ]; then
            send_alert "Peringatan: Penggunaan RAM mencapai ${USAGE}%!"
        fi
    fi
}

check_cpu() {
    if [[ "$CPU_MONITOR" == "y" ]]; then
        USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
        if [ "${USAGE%.*}" -ge "$THRESHOLD" ]; then
            send_alert "Peringatan: Penggunaan CPU mencapai ${USAGE}%!"
        fi
    fi
}

# Menjalankan cek monitoring
if [[ "$1" == "--test" ]]; then
    echo "Testing disk, RAM, and CPU monitoring..."
    check_disk
    check_ram
    check_cpu
else
    while true; do
        check_disk
        check_ram
        check_cpu
        sleep "$((INTERVAL * 60))"
    done
fi

