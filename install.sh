#!/bin/bash

# 1. Unduh file monitoring dari GitHub
REPO_URL="https://github.com/username/repo-name"  # Ganti dengan URL GitHub Anda
INSTALL_DIR="/opt/server_monitoring"  # Ganti direktori jika diinginkan
mkdir -p "$INSTALL_DIR"
curl -L "$REPO_URL/monitor_script.sh" -o "$INSTALL_DIR/monitor_script.sh"
chmod +x "$INSTALL_DIR/monitor_script.sh"

# 2. Meminta konfigurasi dari user
echo "=== Konfigurasi Monitoring Server ==="
read -p "Masukkan Telegram BOT Token: " BOT_TOKEN
read -p "Masukkan Telegram Chat ID: " CHAT_ID

# Memilih fitur yang akan digunakan
echo "Pilih fitur monitoring yang ingin dijalankan (y/n):"
read -p "Root Disk Monitoring (y/n): " ROOT_MONITOR
read -p "RAM Monitoring (y/n): " RAM_MONITOR
read -p "Processor Monitoring (y/n): " CPU_MONITOR

# Meminta nilai threshold
read -p "Masukkan threshold untuk monitoring (default 80%): " THRESHOLD
THRESHOLD=${THRESHOLD:-80}

# Meminta interval pengecekan
read -p "Masukkan interval pengecekan dalam menit (default 5): " INTERVAL
INTERVAL=${INTERVAL:-5}

# Simpan konfigurasi ke file konfigurasi
CONFIG_FILE="$INSTALL_DIR/config.conf"
cat <<EOF > "$CONFIG_FILE"
BOT_TOKEN=$BOT_TOKEN
CHAT_ID=$CHAT_ID
ROOT_MONITOR=$ROOT_MONITOR
RAM_MONITOR=$RAM_MONITOR
CPU_MONITOR=$CPU_MONITOR
THRESHOLD=$THRESHOLD
INTERVAL=$INTERVAL
EOF

echo "Konfigurasi telah disimpan di $CONFIG_FILE"

# 3. Jalankan skrip monitoring untuk pengetesan awal
echo "Menjalankan tes monitoring pertama kali..."
bash "$INSTALL_DIR/monitor_script.sh" --test

# Konfirmasi hasil tes
read -p "Apakah hasil tes sudah sesuai? (y/n): " TEST_OK
if [ "$TEST_OK" == "y" ]; then
    echo "Instalasi selesai. Monitoring aktif dan berjalan."
else
    echo "Silakan cek konfigurasi atau coba instalasi ulang."
fi

