#!/bin/bash
#===============================================================================
# SLiMS Linux Production - Instalasi Otomatis
# Script instalasi SLiMS 9 Bulian di Ubuntu/Xubuntu production-ready
# 
# Usage: sudo ./install-slims.sh
# Repository: https://github.com/muzub/slims-linux-production
#===============================================================================

set -e

# Warna output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Konfigurasi
SLIMS_VERSION="9.8.0"
SLIMS_DIR="/var/www/html/slims"
DB_NAME="slims"
DB_USER="slims"
DB_PASS="slims2026"
BACKUP_DIR="/backup/slims"

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   SLiMS Linux Production - Instalasi Otomatis         ║${NC}"
echo -e "${BLUE}║   SLiMS 9 Bulian di Ubuntu/Xubuntu                    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

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

# Cek apakah dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then 
    log_error "Script harus dijalankan dengan sudo!"
    echo "Usage: sudo ./install-slims.sh"
    exit 1
fi

# Fungsi instalasi
install_dependencies() {
    log_info "Step 1/8: Update sistem dan install dependencies..."
    
    apt update -y
    apt upgrade -y
    
    # Install Apache, MariaDB, PHP
    apt install -y apache2 mariadb-server mariadb-client
    apt install -y php php-mysql php-gd php-mbstring php-xml php-curl php-zip libapache2-mod-php
    
    # Install tools tambahan
    apt install -y curl wget git htop net-tools
    
    log_info "Dependencies terinstall."
}

configure_apache() {
    log_info "Step 2/8: Konfigurasi Apache..."
    
    # Enable modul rewrite
    a2enmod rewrite
    
    # Restart Apache
    systemctl restart apache2
    systemctl enable apache2
    
    log_info "Apache configured."
}

configure_mariadb() {
    log_info "Step 3/8: Konfigurasi MariaDB..."
    
    # Start dan enable MariaDB
    systemctl start mariadb
    systemctl enable mariadb
    
    # Buat database dan user SLiMS
    mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF
    
    log_info "Database ${DB_NAME} dan user ${DB_USER} dibuat."
}

download_slims() {
    log_info "Step 4/8: Download SLiMS ${SLIMS_VERSION}..."
    
    cd /tmp
    
    # Download SLiMS dari GitHub
    if [ -f "slims9_bulian.zip" ]; then
        rm -f slims9_bulian.zip
    fi
    
    wget -q https://github.com/slims/slims9_bulian/archive/refs/heads/master.zip -O slims9_bulian.zip
    
    # Extract
    if [ -d "slims9_bulian-master" ]; then
        rm -rf slims9_bulian-master
    fi
    
    unzip -q slims9_bulian.zip
    
    # Pindahkan ke web root
    if [ -d "${SLIMS_DIR}" ]; then
        log_warn "Folder ${SLIMS_DIR} sudah ada, backup dulu..."
        mv ${SLIMS_DIR} ${SLIMS_DIR}_backup_$(date +%Y%m%d_%H%M%S)
    fi
    
    mv slims9_bulian-master ${SLIMS_DIR}
    
    log_info "SLiMS downloaded ke ${SLIMS_DIR}"
}

set_permissions() {
    log_info "Step 5/8: Set permissions..."
    
    # Set ownership
    chown -R www-data:www-data ${SLIMS_DIR}
    
    # Set permissions
    chmod -R 755 ${SLIMS_DIR}
    
    # Folder yang perlu write access
    chmod -R 775 ${SLIMS_DIR}/files
    chmod -R 775 ${SLIMS_DIR}/uploaded
    chmod -R 775 ${SLIMS_DIR}/repository
    
    log_info "Permissions set."
}

setup_backup() {
    log_info "Step 6/8: Setup backup otomatis..."
    
    # Buat folder backup
    mkdir -p ${BACKUP_DIR}
    
    # Buat script backup harian
    cat > /etc/cron.daily/slims-backup <<'EOF'
#!/bin/bash
# SLiMS Daily Backup
# Backup database SLiMS setiap hari

DB_NAME="slims"
DB_USER="slims"
DB_PASS="slims2026"
BACKUP_DIR="/backup/slims"

# Buat backup
mysqldump -u ${DB_USER} -p'${DB_PASS}' ${DB_NAME} > ${BACKUP_DIR}/slims_$(date +%Y%m%d).sql

# Hapus backup lama (>7 hari)
find ${BACKUP_DIR} -name "*.sql" -mtime +7 -delete

echo "Backup SLiMS completed: $(date)"
EOF
    
    chmod +x /etc/cron.daily/slims-backup
    
    log_info "Backup otomatis diset di ${BACKUP_DIR}"
}

create_desktop_shortcut() {
    log_info "Step 7/8: Buat desktop shortcut..."
    
    # Buat shortcut untuk user yang sudah ada
    for user_home in /home/*; do
        if [ -d "$user_home" ]; then
            username=$(basename "$user_home")
            
            cat > "$user_home/Desktop/Buka-SLiMS.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Buka SLiMS
Comment=Akses SLiMS Library System
Exec=firefox-esr http://localhost/slims
Icon=firefox
Terminal=false
EOF
            
            chmod +x "$user_home/Desktop/Buka-SLiMS.desktop"
            chown "$username:$username" "$user_home/Desktop/Buka-SLiMS.desktop"
            
            log_info "Shortcut dibuat untuk user: $username"
        fi
    done
    
    # Buat shortcut untuk user baru (template)
    mkdir -p /etc/skel/Desktop
    
    cat > /etc/skel/Desktop/Buka-SLiMS.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Buka SLiMS
Comment=Akses SLiMS Library System
Exec=firefox-esr http://localhost/slims
Icon=firefox
Terminal=false
EOF
    
    chmod +x /etc/skel/Desktop/Buka-SLiMS.desktop
    
    # Buat panduan README
    cat > /etc/skel/Desktop/PANDUAN-SLiMS.txt <<'EOF'
=== SLiMS Production - Panduan Cepat ===

1. Buka SLiMS:
   - Klik icon "Buka SLiMS" di desktop
   - Atau buka Firefox → http://localhost/slims

2. Setup pertama kali:
   - Klik "Get Started" → "Install SLiMS"
   - Database Name: slims
   - Username: slims
   - Password: slims2026
   - Test Connection → Run Installation

3. Login default:
   - Username: admin
   - Password: admin
   - GANTI PASSWORD SETELAH LOGIN!

4. Backup otomatis ada di: /backup/slims/

5. Dokumentasi lengkap:
   https://github.com/muzub/slims-linux-production

Support: Issue di GitHub atau komunitas SLiMS Indonesia
EOF
    
    # Copy ke user yang sudah ada juga
    for user_home in /home/*; do
        if [ -d "$user_home" ]; then
            username=$(basename "$user_home")
            cp /etc/skel/Desktop/PANDUAN-SLiMS.txt "$user_home/Desktop/"
            chown "$username:$username" "$user_home/Desktop/PANDUAN-SLiMS.txt"
        fi
    done
    
    log_info "Desktop shortcut dan panduan dibuat."
}

final_cleanup() {
    log_info "Step 8/8: Cleanup dan finalisasi..."
    
    # Hapus file temporary
    rm -rf /tmp/slims9_bulian.zip
    rm -rf /tmp/slims9_bulian-master
    
    # Restart service
    systemctl restart apache2
    systemctl restart mariadb
    
    log_info "Cleanup selesai."
}

# Tampilkan informasi
echo ""
echo -e "${YELLOW}Konfigurasi:${NC}"
echo "  SLiMS Version: ${SLIMS_VERSION}"
echo "  Install Dir: ${SLIMS_DIR}"
echo "  Database: ${DB_NAME}"
echo "  DB User: ${DB_USER}"
echo "  DB Pass: ${DB_PASS}"
echo "  Backup Dir: ${BACKUP_DIR}"
echo ""

read -p "Lanjutkan instalasi? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_warn "Instalasi dibatalkan."
    exit 0
fi

echo ""

# Jalankan instalasi
install_dependencies
configure_apache
configure_mariadb
download_slims
set_permissions
setup_backup
create_desktop_shortcut
final_cleanup

# Tampilkan hasil
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✓ Instalasi SLiMS Selesai!                          ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Akses SLiMS:${NC}"
echo "  URL: http://localhost/slims"
echo "  atau klik icon 'Buka SLiMS' di desktop"
echo ""
echo -e "${BLUE}Database:${NC}"
echo "  Database Name: ${DB_NAME}"
echo "  Username: ${DB_USER}"
echo "  Password: ${DB_PASS}"
echo ""
echo -e "${YELLOW}LANGKAH SELANJUTNYA:${NC}"
echo "1. Buka Firefox → http://localhost/slims"
echo "2. Klik 'Get Started' → 'Install SLiMS'"
echo "3. Masukkan kredensial database di atas"
echo "4. Test Connection → Run Installation"
echo "5. Buat akun admin (default: admin / admin)"
echo "6. PENTING: Hapus folder installer setelah selesai!"
echo "   sudo rm -rf /var/www/html/slims/installer"
echo ""
echo -e "${YELLOW}BACKUP:${NC}"
echo "  Backup otomatis setiap hari di: ${BACKUP_DIR}"
echo ""
echo -e "${BLUE}Dokumentasi:${NC}"
echo "  https://github.com/muzub/slims-linux-production"
echo ""
echo -e "${GREEN}Selamat menggunakan SLiMS!${NC}"
echo ""
