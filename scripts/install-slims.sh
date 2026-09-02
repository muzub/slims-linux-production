#!/bin/bash
#===============================================================================
# SLiMS Linux Production - Instalasi Otomatis (Production-Ready)
# Script instalasi SLiMS 9 Bulian di Ubuntu/Xubuntu dengan security hardening
# 
# Usage: sudo ./install-slims.sh
# Repository: https://github.com/muzub/slims-linux-production
#===============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SLIMS_VERSION="${SLIMS_VERSION:-9.8.0}"
SLIMS_DIR="${SLIMS_DIR:-/var/www/html/slims}"
DB_NAME="${DB_NAME:-slims}"
DB_USER="${DB_USER:-slims}"
DB_HOST="${DB_HOST:-localhost}"
BACKUP_DIR="${BACKUP_DIR:-/backup/slims}"

if [ -z "${DB_PASS:-}" ]; then
    DB_PASS=$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9' | head -c 16)
fi

CREDENTIALS_FILE="/etc/slims/credentials"

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

[ "$EUID" -ne 0 ] && log_error "Script harus dijalankan dengan sudo!"

get_php_version() { php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;'; }

install_dependencies() {
    log_info "Step 1/12: Update sistem dan install dependencies..."
    apt update -y && apt upgrade -y
    apt install -y apache2 mariadb-server mariadb-client
    apt install -y php php-mysql php-gd php-mbstring php-xml php-curl php-zip libapache2-mod-php
    apt install -y curl wget git htop net-tools openssl
    log_info "Dependencies terinstall."
}

configure_apache() {
    log_info "Step 2/12: Konfigurasi Apache..."
    a2enmod rewrite && a2enmod headers
    systemctl restart apache2 && systemctl enable apache2
    log_info "Apache configured."
}

create_php_config() {
    log_info "Step 3/12: Buat PHP configuration..."
    PHP_VER=$(get_php_version)
    PHP_CONF="/etc/php/${PHP_VER}/apache2/conf.d/99-slims.ini"
    
    cat > "$PHP_CONF" <<'EOF'
; SLiMS Production Configuration
expose_php = Off
memory_limit = 256M
max_execution_time = 300
post_max_size = 64M
upload_max_filesize = 64M
disable_functions = exec,shell_exec,system,passthru,proc_open,popen,show_source
allow_url_fopen = Off
allow_url_include = Off
display_errors = Off
log_errors = On
error_log = /var/log/php/error.log
session.cookie_httponly = 1
session.use_strict_mode = 1
session.use_only_cookies = 1
EOF
    
    mkdir -p /var/log/php && chown www-data:www-data /var/log/php
    log_info "PHP configuration created (${PHP_CONF})."
}

configure_mariadb() {
    log_info "Step 4/12: Konfigurasi MariaDB..."
    systemctl start mariadb && systemctl enable mariadb
    
    mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'${DB_HOST}' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'${DB_HOST}';
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
FLUSH PRIVILEGES;
EOF
    
    log_info "Database ${DB_NAME} dan user ${DB_USER} dibuat."
}

save_credentials() {
    log_info "Step 5/12: Save credentials securely..."
    mkdir -p /etc/slims
    
    cat > ${CREDENTIALS_FILE} <<EOF
# SLiMS Database Credentials
# Generated: $(date)
# SECURITY: chmod 600 - hanya root yang bisa baca

DB_HOST=${DB_HOST}
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASS=${DB_PASS}
EOF
    
    chmod 600 ${CREDENTIALS_FILE} && chown root:root ${CREDENTIALS_FILE}
    log_info "Credentials saved to ${CREDENTIALS_FILE} (chmod 600)"
}

download_slims() {
    log_info "Step 6/12: Download SLiMS ${SLIMS_VERSION}..."
    cd /tmp
    SLIMS_URL="https://github.com/slims/slims9_bulian/archive/refs/heads/master.zip"
    
    wget -q "$SLIMS_URL" -O slims9_bulian.zip || log_error "Failed to download SLiMS"
    
    [ -d "slims9_bulian-master" ] && rm -rf slims9_bulian-master
    unzip -q slims9_bulian.zip
    
    if [ -d "${SLIMS_DIR}" ]; then
        log_warn "Folder ${SLIMS_DIR} sudah ada, backup dulu..."
        mv ${SLIMS_DIR} ${SLIMS_DIR}_backup_$(date +%Y%m%d_%H%M%S)
    fi
    
    mv slims9_bulian-master ${SLIMS_DIR}
    log_info "SLiMS downloaded ke ${SLIMS_DIR}"
}

set_permissions() {
    log_info "Step 7/12: Set permissions..."
    chown -R www-data:www-data ${SLIMS_DIR}
    find ${SLIMS_DIR} -type d -exec chmod 755 {} \;
    find ${SLIMS_DIR} -type f -exec chmod 644 {} \;
    chmod -R 775 ${SLIMS_DIR}/files
    chmod -R 775 ${SLIMS_DIR}/uploaded
    chmod -R 775 ${SLIMS_DIR}/repository
    log_info "Permissions set."
}

create_apache_vhost() {
    log_info "Step 8/12: Create Apache VirtualHost dengan security..."
    
    cat > /etc/apache2/sites-available/slims.conf <<EOF
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot ${SLIMS_DIR}
    ErrorLog \${APACHE_LOG_DIR}/slims_error.log
    CustomLog \${APACHE_LOG_DIR}/slims_access.log combined
    
    <Directory ${SLIMS_DIR}>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    <IfModule mod_headers.c>
        Header always set X-Content-Type-Options "nosniff"
        Header always set X-Frame-Options "SAMEORIGIN"
        Header always set X-XSS-Protection "1; mode=block"
        Header always set Referrer-Policy "strict-origin-when-cross-origin"
        Header always set Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self'; frame-ancestors 'self';"
        Header always unset X-Powered-By
    </IfModule>
    
    ServerTokens Prod
    ServerSignature Off
</VirtualHost>
EOF
    
    a2dissite 000-default.conf 2>/dev/null || true
    a2ensite slims.conf && a2enmod headers
    apache2ctl configtest || log_error "Apache config test failed"
    systemctl reload apache2
    log_info "Apache VirtualHost created with security headers."
}

setup_backup() {
    log_info "Step 9/12: Setup backup otomatis..."
    mkdir -p ${BACKUP_DIR} && chmod 700 ${BACKUP_DIR}
    
    cat > /etc/cron.daily/slims-backup <<'SCRIPT'
#!/bin/bash
set -euo pipefail
if [ -f /etc/slims/credentials ]; then
    source /etc/slims/credentials
else
    echo "ERROR: Credentials file not found"; exit 1
fi
BACKUP_DIR="/backup/slims"
DATE=$(date +%Y%m%d_%H%M%S)
mysqldump -u "${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" > "${BACKUP_DIR}/slims_${DATE}.sql"
gzip "${BACKUP_DIR}/slims_${DATE}.sql"
find "${BACKUP_DIR}" -name "*.sql.gz" -mtime +7 -delete
echo "Backup SLiMS completed: $(date)"
SCRIPT
    
    chmod +x /etc/cron.daily/slims-backup
    log_info "Backup otomatis diset di ${BACKUP_DIR}"
}

post_install_hardening() {
    log_info "Step 10/12: Post-install security hardening..."
    
    if command -v ufw &> /dev/null; then
        ufw allow 22/tcp comment 'SSH' 2>/dev/null || true
        ufw allow 80/tcp comment 'HTTP' 2>/dev/null || true
        ufw allow 443/tcp comment 'HTTPS' 2>/dev/null || true
        ufw --force enable 2>/dev/null || log_warn "UFW tidak bisa dienable"
        log_info "Firewall configured"
    fi
    
    systemctl disable bluetooth 2>/dev/null || true
    systemctl disable cups 2>/dev/null || true
    log_info "Post-install hardening completed."
}

verify_installation() {
    log_info "Step 11/12: Verify installation..."
    
    systemctl is-active --quiet apache2 && log_info "Apache is running" || log_warn "Apache is not running"
    systemctl is-active --quiet mariadb && log_info "MariaDB is running" || log_warn "MariaDB is not running"
    [ -d "${SLIMS_DIR}" ] && log_info "SLiMS directory exists" || log_error "SLiMS directory not found"
    
    if [ -f "${CREDENTIALS_FILE}" ]; then
        PERMS=$(stat -c %a "${CREDENTIALS_FILE}")
        [ "$PERMS" = "600" ] && log_info "Credentials file secure (chmod 600)" || log_warn "Credentials permissions: ${PERMS}"
    else
        log_error "Credentials file not found"
    fi
    
    log_info "Verification completed."
}

create_desktop_shortcut() {
    log_info "Step 12/12: Creating desktop shortcut..."
    
    for user_home in /home/*; do
        [ -d "$user_home" ] || continue
        username=$(basename "$user_home")
        cat > "$user_home/Desktop/Buka-SLiMS.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Buka SLiMS
Exec=firefox-esr http://localhost/slims
Icon=firefox
Terminal=false
EOF
        chmod +x "$user_home/Desktop/Buka-SLiMS.desktop"
        chown "$username:$username" "$user_home/Desktop/Buka-SLiMS.desktop"
    done
    
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
    log_info "Desktop shortcut created."
}

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   SLiMS Linux Production - Security Hardened          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Konfigurasi:${NC}"
echo "  Database: ${DB_NAME}"
echo "  DB User: ${DB_USER}"
echo "  DB Pass: [HIDDEN - random generated]"
echo "  Credentials: ${CREDENTIALS_FILE}"
echo ""

read -p "Lanjutkan instalasi? (y/n): " -n 1 -r
echo
[[ ! $REPLY =~ ^[Yy]$ ]] && { log_warn "Instalasi dibatalkan."; exit 0; }

echo ""
install_dependencies
configure_apache
create_php_config
configure_mariadb
save_credentials
download_slims
set_permissions
create_apache_vhost
setup_backup
post_install_hardening
verify_installation
create_desktop_shortcut

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✓ Instalasi SLiMS Selesai!                          ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}URL: http://localhost/slims${NC}"
echo -e "${YELLOW}⚠️ SECURITY:${NC}"
echo "  1. Password DB: ${CREDENTIALS_FILE}"
echo "  2. Hapus installer SETELAH setup: sudo rm -rf /var/www/html/slims/installer"
echo "  3. Ganti password admin (admin/admin) setelah login!"
echo ""
echo -e "${GREEN}Selamat menggunakan SLiMS!${NC}"
