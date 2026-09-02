#!/bin/bash
#===============================================================================
# SLiMS Custom ISO Builder - Cubic Automation
# Script otomatis untuk build ISO custom SLiMS menggunakan Cubic
# 
# Usage: sudo ./build-iso-cubic.sh
# Repository: https://github.com/muzub/slims-linux-production
#===============================================================================

set -e

# Warna output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Konfigurasi
WORK_DIR=~/slims-iso-build
ISO_NAME="slims-os-24.04.iso"
BASE_ISO_URL="https://mirror.xubuntu.org/releases/24.04/release/xubuntu-24.04-desktop-amd64.iso"

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   SLiMS Custom ISO Builder - Cubic Automation         ║${NC}"
echo -e "${BLUE}║   Build ISO dengan SLiMS pre-installed                ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Cek apakah dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then 
    log_error "Script harus dijalankan dengan sudo!"
    exit 1
fi

# Fungsi helper
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Cek Cubic installed
check_cubic() {
    log_info "Mengecek Cubic..."
    
    if ! command -v cubic &> /dev/null; then
        log_warn "Cubic tidak terinstall. Install sekarang?"
        read -p "Install Cubic? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            apt update
            apt install -y software-properties-common
            add-apt-repository ppa:cubic-wizard/release
            apt update
            apt install -y cubic
            log_info "Cubic terinstall."
        else
            log_error "Cubic diperlukan untuk build ISO."
            exit 1
        fi
    else
        log_info "Cubic sudah terinstall."
    fi
}

# Download base ISO
download_base_iso() {
    log_info "Download Xubuntu 24.04 base ISO..."
    
    mkdir -p ${WORK_DIR}
    cd ${WORK_DIR}
    
    if [ ! -f "xubuntu-24.04-desktop-amd64.iso" ]; then
        wget -c ${BASE_ISO_URL} -O xubuntu-24.04-desktop-amd64.iso
    else
        log_warn "Base ISO sudah ada, skip download."
    fi
    
    log_info "Base ISO siap."
}

# Buat script Cubic customization
create_cubic_script() {
    log_info "Membuat script customisasi Cubic..."
    
    cat > ${WORK_DIR}/cubic-customization.sh <<'CUBIC_SCRIPT'
#!/bin/bash
# Script customisasi yang akan dijalankan di dalam chroot Cubic

set -e

echo "=== SLiMS Custom ISO - Chroot Customization ==="

# Update package list
apt update

# Install Apache, MariaDB, PHP
echo "Installing LAMP stack..."
apt install -y apache2 mariadb-server php php-mysql php-gd php-mbstring php-xml php-curl php-zip libapache2-mod-php firefox-esr

# Install tools tambahan
apt install -y curl wget htop net-tools

# Enable Apache modules
a2enmod rewrite

# Download dan setup SLiMS
echo "Downloading SLiMS..."
cd /tmp
wget -q https://github.com/slims/slims9_bulian/archive/refs/heads/master.zip -O slims.zip
unzip -q slims.zip
mv slims9_bulian-master /var/www/html/slims

# Set permissions
chown -R www-data:www-data /var/www/html/slims
chmod -R 755 /var/www/html/slims
chmod -R 775 /var/www/html/slims/files
chmod -R 775 /var/www/html/slims/uploaded

# Enable services
systemctl enable apache2
systemctl enable mariadb

# Buat script first-boot setup
echo "Creating first-boot setup script..."
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
    sleep 15
    
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

# Buat folder backup
mkdir -p /backup/slims

# Buat script backup otomatis
cat > /etc/cron.daily/slims-backup <<'EOF'
#!/bin/bash
mysqldump -u slims -p'slims2026' slims > /backup/slims/slims_$(date +%Y%m%d).sql
find /backup/slims -name "*.sql" -mtime +7 -delete
EOF

chmod +x /etc/cron.daily/slims-backup

# Buat shortcut desktop template
mkdir -p /etc/skel/Desktop

cat > /etc/skel/Desktop/Buka-SLiMS.desktop <<'EOF'
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

# Cleanup
echo "Cleaning up..."
apt autoremove -y
apt clean
rm -rf /tmp/*
rm -rf /var/log/*.log
rm -rf /var/log/apache2/*.log
rm -rf ~/.bash_history

echo "=== Customization Complete ==="
CUBIC_SCRIPT

    chmod +x ${WORK_DIR}/cubic-customization.sh
    
    log_info "Script customisasi dibuat."
}

# Instruksi manual
show_manual_instructions() {
    echo ""
    echo -e "${YELLOW}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║   INSTRUKSI MANUAL - Cubic GUI                        ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Langkah-langkah:${NC}"
    echo ""
    echo "1. Launch Cubic dari menu Applications"
    echo ""
    echo "2. Working directory: ${WORK_DIR}"
    echo ""
    echo "3. Source ISO: ${WORK_DIR}/xubuntu-24.04-desktop-amd64.iso"
    echo ""
    echo "4. Configure distribution:"
    echo "   - Name: SLiMS OS"
    echo "   - Version: 24.04"
    echo "   - Description: SLiMS production-ready dengan Xfce"
    echo ""
    echo "5. Enter chroot environment → klik Next"
    echo ""
    echo "6. Jalankan script customisasi:"
    echo "   ${WORK_DIR}/cubic-customization.sh"
    echo ""
    echo "7. Exit chroot → klik Next"
    echo ""
    echo "8. ISO Settings:"
    echo "   - Boot menu: SLiMS OS 24.04 - Ready to Use"
    echo "   - Compression: gzip"
    echo "   - Generate checksum: Yes"
    echo ""
    echo "9. Generate ISO → tunggu 10-20 menit"
    echo ""
    echo "10. ISO siap di: ${WORK_DIR}/${ISO_NAME}"
    echo ""
    echo -e "${GREEN}Test ISO di VirtualBox sebelum distribusi!${NC}"
    echo ""
}

# Main
echo ""
echo -e "${YELLOW}Work directory: ${WORK_DIR}${NC}"
echo -e "${YELLOW}Output ISO: ${WORK_DIR}/${ISO_NAME}${NC}"
echo ""

read -p "Lanjutkan? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_warn "Build dibatalkan."
    exit 0
fi

echo ""

check_cubic
download_base_iso
create_cubic_script

echo ""
log_info "Preparasi selesai!"

show_manual_instructions

echo -e "${BLUE}Dokumentasi lengkap:${NC}"
echo "  https://github.com/muzub/slims-linux-production"
echo ""
echo -e "${GREEN}Selamat build!${NC}"
