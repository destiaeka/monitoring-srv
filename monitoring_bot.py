# import module/ambil library yang sudah disediakan python
import sqlite3
import json
import logging
from telegram import Update
from telegram.ext import Updater, CommandHandler, CallbackContext

# variabel bot
BOT_TOKEN = "8439801166:AAEUGZWEaFtrMYVD9FD7-ldtdsCn9k-jIVI"
DB_FILE = "/root/monitoring/server_monitoring.db"

logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                    level=logging.INFO)

# ambil data dari db
def get_metric_data(metric: str, date_filter: str): #buat function namanya get_metric_data
    conn = sqlite3.connect(DB_FILE) #koneksi ke DB yang ada di variabel
    conn.row_factory = sqlite3.Row
    cur = conn.cursor()

    if metric not in ['cpu', 'ram', 'disk', 'network']: #daftar metric yang diperbolehkan
        conn.close() #misal user input metric yang ga ada maka menampilkan list kosong
        return []

    if metric == 'cpu': #ambil data dari database sesuai tanggal yang diinput user, lalu diurutkan dari yang paling awal
        cur.execute(
            "SELECT time, cpu FROM server_monitoring WHERE time LIKE ? ORDER BY time ASC",
            (f"{date_filter}%",)
        )
    elif metric == 'ram':
        cur.execute(
            "SELECT time, ram_used, ram_total FROM server_monitoring WHERE time LIKE ? ORDER BY time ASC",
            (f"{date_filter}%",)
        )
    elif metric == 'disk':
        cur.execute(
            "SELECT time, disk_used, disk_total FROM server_monitoring WHERE time LIKE ? ORDER BY time ASC",
            (f"{date_filter}%",)
        )
    elif metric == 'network':
        cur.execute(
            "SELECT time, net_rx, net_tx FROM server_monitoring WHERE time LIKE ? ORDER BY time ASC",
            (f"{date_filter}%",)
        )

    rows = cur.fetchall() #ambil seluruh hasil query
    conn.close()
    return rows

# HANDLER PER METRIK
def cpu(update: Update, context: CallbackContext): #bikin function bernama cpu
    if not context.args: #argumen yang diketik user setelah /cpu. kalo tidak sesuai format maka menampilkan pesan petunjuk dan keluar dari function
        update.message.reply_text("Gunakan format: /cpu DD-MM-YYYY")
        return

    date_filter = context.args[0] #ambil tanggal dari argumen yang user berikan
    rows = get_metric_data('cpu', date_filter) #mengambil semua data cpu di tanggal yang diinput user, hasilnya disimpan di variabel rows
    if not rows: #misalnya tidak ada data akan menampilkan pesan error dan keluar dari function
        update.message.reply_text("Data CPU tidak ditemukan.")
        return

    data = {row['time'].split()[1]: f"{row['cpu']}%" for row in rows} #buat data json
    update.message.reply_text(json.dumps(data, indent=2))

def ram(update: Update, context: CallbackContext):
    if not context.args:
        update.message.reply_text("Gunakan format: /ram DD-MM-YYYY")
        return

    date_filter = context.args[0]
    rows = get_metric_data('ram', date_filter)
    if not rows:
        update.message.reply_text("Data RAM tidak ditemukan.")
        return

    data = {row['time'].split()[1]: f"{row['ram_used']}/{row['ram_total']}Mi" for row in rows}
    update.message.reply_text(json.dumps(data, indent=2))

def disk(update: Update, context: CallbackContext):
    if not context.args:
        update.message.reply_text("Gunakan format: /disk DD-MM-YYYY")
        return

    date_filter = context.args[0]
    rows = get_metric_data('disk', date_filter)
    if not rows:
        update.message.reply_text("Data Disk tidak ditemukan.")
        return

    data = {row['time'].split()[1]: f"{row['disk_used']}/{row['disk_total']}" for row in rows}
    update.message.reply_text(json.dumps(data, indent=2))

def network(update: Update, context: CallbackContext):
    if not context.args:
        update.message.reply_text("Gunakan format: /network DD-MM-YYYY")
        return

    date_filter = context.args[0]
    rows = get_metric_data('network', date_filter)
    if not rows:
        update.message.reply_text("Data Network tidak ditemukan.")
        return

    data = {row['time'].split()[1]: f"RX={row['net_rx']}B / TX={row['net_tx']}B" for row in rows}
    update.message.reply_text(json.dumps(data, indent=2))

# /start
def start(update: Update, context: CallbackContext): #pesan pertama ketika user kirim /start
    update.message.reply_text(
        "Selamat datang!\nGunakan perintah:\n"
        "/cpu DD-MM-YYYY\n"
        "/ram DD-MM-YYYY\n"
        "/disk DD-MM-YYYY\n"
        "/network DD-MM-YYYY\n"
        "Contoh: /cpu 13-11-2025"
    )

# MAIN BOT
def main():
    updater = Updater(BOT_TOKEN) #menghubungkan dengan bot tele
    dp = updater.dispatcher

    dp.add_handler(CommandHandler("start", start)) #mendaftarkan perintah telegram ke function tertentu, jadi misal user masukin pesan /cpu maka db akan manggil function cpu
    dp.add_handler(CommandHandler("cpu", cpu))
    dp.add_handler(CommandHandler("ram", ram))
    dp.add_handler(CommandHandler("disk", disk))
    dp.add_handler(CommandHandler("network", network))

    updater.start_polling() #menjalankan bot
    updater.idle()

if __name__ == "__main__":
    main()
