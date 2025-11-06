#!/bin/bash

# CONFIG
CHAT_ID="8355773223"
BOT_TOKEN="8524070723:AAEdHd5sDikSBFIpsHsZOtI5J_q5NNdX28A"

# HOST INFO
# - Ambil Data Server
HOST=$(hostname)
TIME=$(date '+%d-%m-%Y %H:%M:%S')
UPTIME=$(uptime -p)

# CPU
# - menggunakan perintah top, ambil baris CPU, ambil penggunakan CPU. Dibulatkan ke angka bulat
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | awk '{printf "%.0f", $1}')

# RAM (used/total)
# - menampilkan penggunakan ram dengan perintah free -m. $3 --> ram terpakai $2 --> ram total.
RAM_USED=$(free -m | awk '/Mem/ {printf "%d", $3}')
RAM_TOTAL=$(free -m | awk '/Mem/ {printf "%d", $2}')
RAM="${RAM_USED}Mi/${RAM_TOTAL}Mi"

# DISK root / (used/total)
# - menampilkan penggunakan disk partisi root /. NR --> ambil baris ke2 (data partisi)
DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
DISK="${DISK_USED}/${DISK_TOTAL}"

# FILE SYSTEM root / (used/total)
FS_USED=$(df -h / | awk 'NR==2 {print $3}')
FS_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
FS="/:${FS_USED}/${FS_TOTAL}"

# NETWORK (main interface)
# - NET_RX: jumlah byte diterima
# - NET_TX: jumlah byte dikirim
IFACE="enp0s3"
NET_RX=$(cat /sys/class/net/$IFACE/statistics/rx_bytes)
NET_TX=$(cat /sys/class/net/$IFACE/statistics/tx_bytes)
NET="Network ($IFACE): RX=${NET_RX}B / TX=${NET_TX}B"

# FORMAT MESSAGE
MESSAGE="🖥 Server: $HOST
⏱ Time: $TIME | Uptime: $UPTIME
⚡ CPU: ${CPU}%
💾 RAM: $RAM
💽 DISK: $DISK
🌐 NET: $NET"

# SEND TO TELEGRAM
curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
     -d chat_id="$CHAT_ID" \
     -d parse_mode="Markdown" \
     -d text="$MESSAGE"
