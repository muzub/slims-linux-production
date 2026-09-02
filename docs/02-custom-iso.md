# Tutorial Custom ISO SLiMS

Panduan membuat ISO Linux custom yang sudah include SLiMS + GUI, siap pakai tanpa instalasi manual.

## Prasyarat

- PC dengan RAM minimal 4GB (untuk build ISO)
- Storage minimal 30GB free space
- Koneksi internet stabil
- Ubuntu 24.04 LTS atau Xubuntu 24.04 LTS (sebagai host build)

## Metode 1: Menggunakan Cubic (GUI - Paling Mudah)

### 1. Install Cubic

```bash
# Tambahkan repository Cubic
sudo add-apt-repository ppa:cubic-wizard/release
sudo apt update

# Install Cubic
sudo apt install -y cubic
```

### 2. Download ISO Base

Download Xubuntu 24.04 LTS:
- URL: https://xubuntu.org/download/
- File: `xubuntu-24.04-desktop-amd64.iso`
- Simpan di folder yang mudah diakses, misal: `~/Downloads/`

### 3. Persiapan Folder Kerja

```bash
# Buat folder untuk build
mkdir -p ~/slims-iso-build
cd ~/slims-iso-build
```

### 4. Launch Cubic

1. Buka Cubic dari menu Applications
2. **Working directory**: Pilih `~/slims-iso-build`
3. **Source ISO**: Pilih file `xubuntu-24.04-desktop-amd64.iso`
4. Klik "Next"

### 5. Configure Distribution

Isi informasi custom ISO:
- **Distribution name**: `SLiMS OS`
- **Release number**: `24.04`
- **Version**: `1.0`
- **Code name**: `Noble`
- **Architecture**: `amd64`
- **Description**: `SLiMS production-ready dengan Xfce desktop`

Klik "Next"

### 6. Enter Chroot Environment

Klik "Next" → akan masuk ke terminal virtual (chroot environment)

### 7. Install Dependencies SLiMS

Di dalam chroot terminal, jalankan:

```bash
# Update package list
apt update

# Install Apache, MariaDB, PHP
apt install -y apache2 mariadb-server php php-mysql php-gd php-mbstring php-xml php-curl php-zip libapache2-mod-php firefox-esr

# Aktifkan modul Apache
a2enmod rewrite

# Install tools tambahan
apt install -y curl wget htop
```

### 8. Download dan Setup SLiMS

```bash
# Download SLiMS
cd /tmp
wget https://github.com/slims/slims9_bulian/archive/refs/heads/master.zip
unzip master.zip
mv slims9_bulian-master /var/www/html/slims

# Set permission
chown -R www-data:www-data /var/www/html/slims
chmod -R 755 /var/www/html/slims

# Enable service
systemctl enable apache2
systemctl enable mariadb
```

### 9. Buat Script First-Boot Setup

Script ini akan membuat database otomatis saat ISO pertama kali boot:

```bash
cat > /etc/init.d/setup-slims-db <<'EOF'
#!/bin/bash
### BEGIN INIT INFO
# Provides:          setup-slims-db
# Required-Start:    $remote_fs mariadb
# Required-Stop:     $remote_fs mariadb
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Setup SLiMS database on first boot
### END INIT INFO

case "$1" in
  start)
    echo "Setting up SLiMS database..."
    
    # Tunggu MariaDB siap
    sleep 10
    
    # Buat database
    mysql -u root <<MYSQL
CREATE DATABASE IF NOT EXISTS slims;
CREATE USER IF NOT EXISTS 'slims'@'localhost' IDENTIFIED BY 'slims2026';
GRANT ALL PRIVILEGES ON slims.* TO 'slims'@'localhost';
FLUSH PRIVILEGES;
MYSQL
    
    # Buat shortcut desktop untuk semua user
    for user_home in /home/*; do
      if [ -d "$user_home" ]; then
        username=$(basename "$user_home")
        cat > "$user_home/Desktop/Buka-SLiMS.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=Buka SLiMS
Exec=firefox-esr http://localhost/slims
Icon=firefox
Terminal=false
DESKTOP
        chmod +x "$user_home/Desktop/Buka-SLiMS.desktop"
        chown "$username:$username" "$user_home/Desktop/Buka-SLiMS.desktop"
      fi
    done
    
    # Disable script setelah run
    update-rc.d setup-slims-db disable
    ;;
esac
exit 0
EOF

chmod +x /etc/init.d/setup-slims-db
update-rc.d setup-slims-db defaults
```

### 10. Buat Shortcut Desktop Template

```bash
# Buat shortcut untuk user baru
mkdir -p /etc/skel/Desktop

cat > /etc/skel/Desktop/Buka-SLiMS.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Buka SLiMS
Exec=firefox-esr http://localhost/slims
Icon=firefox
Terminal=false
EOF

chmod +x /etc/skel/Desktop/Buka-SLiMS.desktop

# Buat panduan user
cat > /etc/skel/Desktop/PANDUAN-README.txt <<'EOF'
=== SLiMS OS - Panduan Cepat ===

1. Login dengan username/password yang Anda buat saat instalasi

2. Buka SLiMS:
   - Klik icon "Buka SLiMS" di desktop
   - Atau buka Firefox → http://localhost/slims

3. Setup pertama kali:
   - Klik "Get Started" → "Install SLiMS"
   - Database: slims
   - Username: slims
   - Password: slims2026
   - Test Connection → Run Installation

4. Login default:
   - Username: admin
   - Password: admin
   - GANTI PASSWORD SETELAH LOGIN!

5. Backup otomatis ada di: /backup/slims/

Support: https://github.com/muzub/slims-linux-production
EOF
```

### 11. Buat Script Backup Otomatis

```bash
sudo mkdir -p /backup/slims

cat > /etc/cron.daily/slims-backup <<'EOF'
#!/bin/bash
mysqldump -u slims -p'slims2026' slims > /backup/slims/slims_$(date +%Y%m%d).sql
find /backup/slims -name "*.sql" -mtime +7 -delete
EOF

chmod +x /etc/cron.daily/slims-backup
```

### 12. Cleanup dan Optimasi

```bash
# Hapus cache dan file temporary
apt autoremove -y
apt clean
rm -rf /tmp/*
rm -rf /var/log/*.log
rm -rf /var/log/apache2/*.log

# Hapus history
history -c
rm -rf ~/.bash_history
```

### 13. Exit Chroot

Ketik `exit` atau klik "Next" untuk keluar dari chroot environment.

### 14. ISO Settings

- **Update boot menu text**: `SLiMS OS 24.04 - Ready to Use`
- **Compression**: Pilih `gzip` (lebih kompatibel) atau `zstd` (lebih cepat)
- **Generate ISO checksum**: Centang

Klik "Next"

### 15. Generate ISO

- Klik "Generate ISO"
- Tunggu proses build (10-20 menit tergantung spesifikasi PC)
- ISO akan tersimpan di: `~/slims-iso-build/slims-os-24.04.iso`

### 16. Test ISO

**PENTING**: Test ISO di VirtualBox/VMware sebelum distribusi!

```bash
# Install VirtualBox (jika belum)
sudo apt install -y virtualbox

# Buat VM baru:
# - RAM: 4GB
# - Storage: 40GB
# - Load ISO: slims-os-24.04.iso
# - Install dan test semua fitur
```

## Metode 2: Menggunakan Live-Build (Script - Untuk Automation)

### 1. Install Dependencies

```bash
sudo apt update
sudo apt install -y live-build debootstrap
```

### 2. Clone Repository

```bash
git clone https://github.com/muzub/slims-linux-production.git
cd slims-linux-production
```

### 3. Jalankan Script Build

```bash
chmod +x scripts/build-iso-livebuild.sh
sudo ./scripts/build-iso-livebuild.sh
```

Script akan otomatis:
- Download base system
- Install Xfce + SLiMS dependencies
- Setup konfigurasi
- Build ISO

ISO akan tersimpan di: `~/slims-iso/*.iso`

## Distribusi ISO

### 1. Buat USB Installer

**Windows (Rufus):**
1. Download Rufus: https://rufus.ie
2. Insert USB 8GB+
3. Pilih ISO `slims-os-24.04.iso`
4. Start

**Linux (Etcher/dd):**
```bash
# Download Etcher: https://www.balena.io/etcher/
# ATAU gunakan dd:
sudo dd if=slims-os-24.04.iso of=/dev/sdX bs=4M status=progress
```

### 2. Berikan Dokumentasi

Sertakan file `PANDUAN-USER.md` bersama USB:

```markdown
# Panduan Instalasi SLiMS OS

1. Boot dari USB
2. Pilih "Install SLiMS OS"
3. Ikuti wizard instalasi (seperti Windows)
4. Buat username dan password
5. Setelah install, login dan klik "Buka SLiMS"
6. Setup database otomatis (sudah ada script)
7. Akses SLiMS di Firefox: http://localhost/slims
```

### 3. Verifikasi ISO

Berikan checksum untuk verifikasi file tidak korup:

```bash
# Generate checksum
md5sum slims-os-24.04.iso
sha256sum slims-os-24.04.iso

# Contoh output:
# a1b2c3d4e5f6... slims-os-24.04.iso
```

User bisa verifikasi:
```bash
md5sum -c slims-os-24.04.iso.md5
```

## Troubleshooting Build ISO

### Build Gagal di Chroot

```bash
# Bersihkan build sebelumnya
cd ~/slims-iso-build
sudo rm -rf chroot/

# Restart Cubic dan coba lagi
```

### ISO Terlalu Besar (>4GB)

```bash
# Hapus package tidak perlu di chroot:
apt remove thunderbird rhythmbox libreoffice* -y
apt autoremove -y
apt clean
```

### SLiMS Tidak Muncul Setelah Install

```bash
# Cek Apache
sudo systemctl status apache2

# Cek database
mysql -u slims -p'slims2026' -e "SHOW DATABASES;"

# Fix permission
sudo chown -R www-data:www-data /var/www/html/slims
```

## Langkah Selanjutnya

- [Panduan User](../docs-user/PANDUAN-USER.md)
- [Troubleshooting](03-troubleshooting.md)
- [Instalasi Manual](01-install-manual.md)

---

**Tips:** Simpan script build di repository Git untuk version control!
