#!/bin/bash

# GLOBAL CONFIG
BOT_TOKEN=$BOT_TOKEN
CHAT_ID=$CHAT_ID

# === Ambil Data Server ===
# - Ambil data server
HOSTNAME=$(hostname)
DATE=$(date "+%Y-%m-%d %H:%M:%S")
UPTIME=$(uptime -p)
# - menggunakan perintah top, ambil baris CPU, ambil penggunakan CPU
CPU_LOAD=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8 "%"}')
# - menggunakan free -h yang menampilkan informasi terkait memory
MEM_USED=$(free -h | awk '/Mem:/ {print $3 "/" $2}')
# - cek penggunakan disk dengan perintah df -h
DISK_USED=$(df -h / | awk 'NR==2 {print $5}')

# --- Deteksi interface otomatis ---
# - iface untuk mendeteksi interface utama
IFACE=$(ip route get 1.1.1.1 | awk '{print $5; exit}')
# - total byte yang diterima. /proc/net/dev baca statistik network di linux
NET_RX=$(cat /proc/net/dev | awk -v iface="$IFACE" '$0 ~ iface":" {print $2}')
# - total byte yang dikirim
NET_TX=$(cat /proc/net/dev | awk -v iface="$IFACE" '$0 ~ iface":" {print $10}')

# === Buat Pesan ===
MESSAGE="📡 Server Report
🖥 Hostname: $HOSTNAME
🕒 Time: $DATE
🆙 Uptime: $UPTIME
⚙️ CPU Usage: $CPU_LOAD
💾 RAM Usage: $MEM_USED
📂 Disk Usage: $DISK_USED
🌐 Network ($IFACE): RX=${NET_RX}B / TX=${NET_TX}B"

# === Kirim ke Telegram ===
curl -s -X POST https://api.telegram.org/bot$BOT_TOKEN/sendMessage \
-d chat_id=$CHAT_ID \
-d parse_mode="Markdown" \
-d text="$MESSAGE"
