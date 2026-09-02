# Troubleshooting SLiMS di Linux

Kumpulan solusi untuk masalah umum instalasi dan penggunaan SLiMS di Linux.

## Masalah Instalasi

### Script Instalasi Gagal

**Gejala:** Script `install-slims.sh` berhenti di tengah atau error.

**Solusi:**

```bash
# 1. Cek koneksi internet
ping -c 3 google.com

# 2. Update manual dulu
sudo apt update
sudo apt upgrade -y

# 3. Install dependencies satu per satu
sudo apt install -y apache2
sudo apt install -y mariadb-server
sudo apt install -y php php-mysql php-gd php-mbstring php-xml php-curl php-zip

# 4. Cek error log
tail -f /var/log/apt/term.log
```

### Apache Tidak Start

**Gejala:** `http://localhost/slims` tidak bisa diakses.

**Solusi:**

```bash
# Cek status
sudo systemctl status apache2

# Restart Apache
sudo systemctl restart apache2

# Cek port 80
sudo netstat -tulpn | grep :80

# Cek error log
sudo tail -f /var/log/apache2/error.log

# Jika ada error modul, reinstall
sudo apt install --reinstall apache2 libapache2-mod-php -y
```

### MariaDB Tidak Start

**Gejala:** Error "Can't connect to MySQL server".

**Solusi:**

```bash
# Cek status
sudo systemctl status mariadb

# Restart MariaDB
sudo systemctl restart mariadb

# Cek error log
sudo tail -f /var/log/mysql/error.log

# Jika masih error, reset password root
sudo mysql -u root
```

```sql
-- Reset password root
ALTER USER 'root'@'localhost' IDENTIFIED BY '';
FLUSH PRIVILEGES;
EXIT;
```

```bash
# Test koneksi
mysql -u root -e "SHOW DATABASES;"
```

### Permission Denied di SLiMS

**Gejala:** Error "Permission denied" saat upload file atau akses fitur tertentu.

**Solusi:**

```bash
# Fix permission folder SLiMS
sudo chown -R www-data:www-data /var/www/html/slims
sudo chmod -R 755 /var/www/html/slims

# Khusus folder yang perlu write access
sudo chmod -R 775 /var/www/html/slims/files
sudo chmod -R 775 /var/www/html/slims/uploaded
```

## Masalah Database

### Database Corruption

**Gejala:** Error "Table 'slims.something' doesn't exist" atau "Got error 145".

**Solusi:**

```bash
# 1. Stop MariaDB
sudo systemctl stop mariadb

# 2. Backup database dulu
mysqldump -u slims -p'slims2026' slims > backup_before_repair.sql

# 3. Start MariaDB dengan recovery mode
sudo mysqld_safe --skip-grant-tables &

# 4. Repair database
mysql -u root slims <<EOF
REPAIR TABLE biblio;
REPAIR TABLE member;
REPAIR TABLE circulation;
-- Tambahkan tabel lain yang error
EOF

# 5. Restart normal
sudo systemctl restart mariadb
```

**Pencegahan:**
- Selalu shutdown proper: `sudo shutdown -h now`
- Gunakan UPS untuk hindari mati listrik mendadak
- Backup harian otomatis sudah diset di `/etc/cron.daily/slims-backup`

### Database Penuh

**Gejala:** Error "Got error 28 from storage engine" atau SLiMS lambat.

**Solusi:**

```bash
# Cek ukuran database
mysql -u slims -p'slims2026' -e "SELECT table_schema, 
ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)' 
FROM information_schema.tables WHERE table_schema='slims' GROUP BY table_schema;"

# Cek storage
df -h

# Hapus log lama
sudo rm -rf /var/log/mysql/*.log
sudo rm -rf /var/log/apache2/*.log.*

# Hapus backup lama (>30 hari)
find /backup/slims -name "*.sql" -mtime +30 -delete

# Optimasi tabel
mysql -u slims -p'slims2026' slims -e "OPTIMIZE TABLE biblio, member, circulation;"
```

### Koneksi Database Terlalu Lambat

**Solusi - Tune MariaDB:**

Edit `/etc/mysql/mariadb.conf.d/50-server.cnf`:

```ini
[mysqld]
# Memory settings (untuk RAM 4GB)
key_buffer_size = 32M
max_connections = 100
query_cache_size = 32M
query_cache_limit = 2M
innodb_buffer_pool_size = 128M
innodb_log_file_size = 32M

# Slow query log
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 2
```

Restart MariaDB:
```bash
sudo systemctl restart mariadb
```

## Masalah Desktop/GUI

### Desktop Terlalu Lambat

**Solusi:**

```bash
# 1. Matikan compositor (efek visual)
# Settings → Window Manager Tweaks → Compositor → Uncheck

# 2. Hapus aplikasi tidak perlu
sudo apt remove thunderbird rhythmbox libreoffice* -y

# 3. Matikan aplikasi startup
# Settings → Session and Startup → Application Autostart
# Uncheck yang tidak perlu

# 4. Cek RAM usage
htop

# 5. Tambah swap (jika RAM <4GB)
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Permanent swap
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### Icon "Buka SLiMS" Tidak Muncul

**Solusi:**

```bash
# Buat manual shortcut
cat > ~/Desktop/Buka-SLiMS.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Buka SLiMS
Exec=firefox-esr http://localhost/slims
Icon=firefox
Terminal=false
EOF

chmod +x ~/Desktop/Buka-SLiMS.desktop
```

### Firefox Tidak Bisa Akses localhost

**Solusi:**

```bash
# Install Firefox jika belum
sudo apt install -y firefox-esr

# Test akses
curl http://localhost/slims

# Jika masih error, cek Apache
sudo systemctl status apache2
```

## Masalah Network

### Tidak Bisa Akses dari Komputer Lain

**Solusi:**

```bash
# 1. Cek firewall
sudo ufw status
sudo ufw allow 80/tcp
sudo ufw allow 22/tcp

# 2. Cek IP address
ip addr show

# 3. Test dari komputer lain
# ping 192.168.1.100
# curl http://192.168.1.100/slims

# 4. Set IP static (opsional)
sudo nano /etc/netplan/01-network-manager-all.yaml
```

### SLiMS Tidak Bisa Akses Internet (Untuk Update)

**Solusi:**

```bash
# Test koneksi
ping -c 3 google.com

# Jika tidak bisa, cek DNS
cat /etc/resolv.conf

# Tambah DNS Google
echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf
echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf

# Test lagi
ping -c 3 google.com
```

## Masalah Build ISO

### Cubic Gagal Build

**Solusi:**

```bash
# 1. Pastikan storage cukup (minimal 20GB free)
df -h

# 2. Bersihkan build sebelumnya
cd ~/slims-iso-build
sudo rm -rf chroot/

# 3. Restart Cubic
cubic

# 4. Jika masih error, cek log
cat ~/slims-iso-build/build.log
```

### ISO Terlalu Besar

**Solusi - Hapus package tidak perlu di chroot:**

```bash
# Di dalam chroot Cubic:
apt remove thunderbird rhythmbox libreoffice* gnome-games -y
apt autoremove -y
apt clean

# Hapus cache
rm -rf /var/cache/apt/archives/*
```

### SLiMS Tidak Otomatis Setup di ISO Custom

**Solusi:**

```bash
# Pastikan script first-boot ada dan executable
ls -la /etc/init.d/setup-slims-db

# Cek isi script
cat /etc/init.d/setup-slims-db

# Enable script
update-rc.d setup-slims-db defaults

# Test manual
sudo /etc/init.d/setup-slims-db start
```

## Backup dan Restore

### Backup Manual Database

```bash
# Backup ke file
mysqldump -u slims -p'slims2026' slims > backup_slims_$(date +%Y%m%d_%H%M%S).sql

# Backup dengan compress
mysqldump -u slims -p'slims2026' slims | gzip > backup_slims_$(date +%Y%m%d).sql.gz
```

### Restore Database

```bash
# Restore dari SQL
mysql -u slims -p'slims2026' slims < backup_slims_20260902.sql

# Restore dari compressed
gunzip < backup_slims_20260902.sql.gz | mysql -u slims -p'slims2026' slims
```

### Backup Full System (Untuk ISO Custom)

```bash
# Install Clonezilla atau
# Gunakan rsync untuk backup folder penting
rsync -avz /var/www/html/slims /backup/slims_files/
rsync -avz /etc/mysql /backup/mysql_config/
```

## Log yang Berguna untuk Debugging

```bash
# Apache error log
sudo tail -f /var/log/apache2/error.log

# Apache access log
sudo tail -f /var/log/apache2/access.log

# MariaDB error log
sudo tail -f /var/log/mysql/error.log

# System log
sudo tail -f /var/log/syslog

# SLiMS specific (jika ada)
sudo tail -f /var/www/html/slims/logs/*.log
```

## Kontak Support

Jika masih ada masalah:

1. **Cek dokumentasi**: https://github.com/muzub/slims-linux-production
2. **Issue GitHub**: https://github.com/muzub/slims-linux-production/issues
3. **Komunitas SLiMS**: https://www.facebook.com/groups/slimscommunity
4. **SLiMS Official**: https://slims.web.id

---

**Tips:** Selalu backup database sebelum melakukan troubleshooting yang melibatkan database!
