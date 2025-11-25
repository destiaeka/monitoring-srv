# Server Monitoring Bot

## Deskripsi Singkat:
Bot monitoring server sederhana menggunakan Bash script yang mengirimkan laporan CPU, RAM, Disk, File System, dan Network ke Telegram secara otomatis.

## Fitur
- Menampilkan CPU usage, RAM usage, Disk usage (root filesystem)
- Memantau network traffic per interface utama
- Mengambil data langsung dari sistem Linux (top, free, df, /proc/net/dev)
- Mengirim laporan ke Telegram setiap interval (cron atau GitHub Actions)
- Environment variable dan GitHub Secrets untuk keamanan token bot

## Stack / Teknologi
- Bash Script → mengambil data server
- Telegram Bot API → mengirim laporan
- Linux CLI Tools → top, free, df, uptime, /proc/net/dev
