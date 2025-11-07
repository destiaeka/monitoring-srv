#!/bin/bash

# ========================
# CONFIG
# ==========================
PROM_URL="http://localhost:9090"
BOT_TOKEN="8216407572:AAEgmoFbOBLcGzy_WTpL7nDWgrpuvA7KmFE"
CHAT_ID="8355773223"

# ==========================
# FUNCTION UNTUK PROMQL
# ==========================
get_metric() {
  local query="$1"
  curl -sG "${PROM_URL}/api/v1/query" --data-urlencode "query=${query}" \
    | jq -r '.data.result[0].value[1]'
}

# ==========================
# AMBIL DATA METRIK
# ==========================
CPU=$(get_metric '100 - (avg by(instance)(rate(node_cpu_seconds_total{mode="idle"}[1m])) * 100)')
RAM=$(get_metric '(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100')
DISK=$(get_metric '(1 - (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"})) * 100')
NET=$(get_metric '(rate(node_network_receive_bytes_total[1m]) + rate(node_network_transmit_bytes_total[1m]))')

# Handle nilai kosong (NA/null)
CPU=${CPU:-0}
RAM=${RAM:-0}
DISK=${DISK:-0}
NET=${NET:-0}

# ==========================
# PEMBULATAN (2 desimal)
# ==========================
CPU=$(printf "%.2f" "$CPU")
RAM=$(printf "%.2f" "$RAM")
DISK=$(printf "%.2f" "$DISK")
NET=$(printf "%.2f" "$NET")

# ==========================
# FORMAT LAPORAN
# ==========================
HOST=$(hostname)
TIME=$(date '+%Y-%m-%d %H:%M:%S')

MESSAGE="📊 *Laporan Monitoring Server*
🖥️ *Host:* ${HOST}
🕒 *Waktu:* ${TIME}

⚙️ *CPU:* ${CPU}%
💾 *RAM:* ${RAM}%
📀 *Disk:* ${DISK}%
🌐 *Network:* ${NET} B/s
"

# ==========================
# KIRIM KE TELEGRAM
# ==========================
curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
  -d chat_id="${CHAT_ID}" \
  -d parse_mode="Markdown" \
  -d text="$MESSAGE" > /dev/null
