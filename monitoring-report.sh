#!/bin/bash

# glob_config
DB_FILE="/root/monitoring/server_monitoring.db"
SQLITE="/usr/bin/sqlite3"

# create database
$SQLITE $DB_FILE <<EOF
CREATE TABLE IF NOT EXISTS server_monitoring (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  host TEXT,
  time TEXT,
  uptime TEXT,
  cpu INTEGER,
  ram_used INTEGER,
  ram_total INTEGER,
  disk_used TEXT,
  disk_total TEXT,
  fs_used TEXT,
  fs_total TEXT,
  net_rx INTEGER,
  net_tx INTEGER
);
EOF

HOST=$(hostname)
TIME=$(date '+%d-%m-%Y %H:%M:%S')
UPTIME=$(uptime -p)

CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | awk '{printf "%.0f", $1}')
RAM_USED=$(free -m | awk '/Mem/ {printf "%d", $3}')
RAM_TOTAL=$(free -m | awk '/Mem/ {printf "%d", $2}')
DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
FS_USED=$DISK_USED
FS_TOTAL=$DISK_TOTAL
IFACE="eth0"
NET_RX=$(cat /sys/class/net/$IFACE/statistics/rx_bytes)
NET_TX=$(cat /sys/class/net/$IFACE/statistics/tx_bytes)

# insert data
$SQLITE $DB_FILE <<EOF
INSERT INTO server_monitoring (host, time, uptime, cpu, ram_used, ram_total, disk_used, disk_total, fs_used, fs_total, net_rx, net_tx)
VALUES ('$HOST', '$TIME', '$UPTIME', $CPU, $RAM_USED, $RAM_TOTAL, '$DISK_USED', '$DISK_TOTAL', '$FS_USED', '$FS_TOTAL', $NET_RX, $NET_TX);
EOF
