# Security Checklist - SLiMS Production

Checklist security hardening untuk deployment SLiMS di production.

## ✅ Implemented Security Features

### 1. Credentials Management
- [x] Random password generation untuk database (openssl)
- [x] Credentials file terpisah (`/etc/slims/credentials`)
- [x] File permissions: `chmod 600` (root only)
- [x] Environment variables override support

### 2. Script Hardening
- [x] `set -euo pipefail` di semua script bash
- [x] Error handling yang proper
- [x] Verification otomatis setelah instalasi

### 3. Apache Security
- [x] Disable directory indexing (`Options -Indexes`)
- [x] Security headers:
  - X-Content-Type-Options: nosniff
  - X-Frame-Options: SAMEORIGIN
  - X-XSS-Protection: 1; mode=block
  - Referrer-Policy: strict-origin-when-cross-origin
  - Content-Security-Policy: default-src 'self'
- [x] Hide server version (ServerTokens Prod)
- [x] VirtualHost terpisah untuk SLiMS

### 4. PHP Security
- [x] Config file terpisah (`99-slims.ini`)
- [x] `expose_php = Off`
- [x] `display_errors = Off`
- [x] `disable_functions = exec,shell_exec,system,passthru,...`
- [x] `allow_url_fopen = Off`
- [x] `allow_url_include = Off`
- [x] Session security (cookie_httponly, strict_mode)

### 5. MariaDB Security
- [x] Remove anonymous users
- [x] Remove remote root access
- [x] Remove test database
- [x] Database user dengan least privilege

### 6. File Permissions
- [x] SLiMS directory: `755` (directories), `644` (files)
- [x] Write folders: `775` (files, uploaded, repository)
- [x] Credentials file: `600` (root only)
- [x] Owned by `www-data:www-data`

### 7. System Hardening
- [x] Firewall enabled (UFW)
  - Port 22 (SSH)
  - Port 80 (HTTP)
  - Port 443 (HTTPS)
- [x] Disable unnecessary services (bluetooth, cups)

### 8. Backup Security
- [x] Daily automated backup
- [x] Backup compression (gzip)
- [x] Retention policy (7 days)
- [x] Backup directory permissions: `700`

## 🔍 Pre-Production Testing

### 9. Validation (WAJIB!)
- [ ] **Test di VM isolated** sebelum production
- [ ] Run `shellcheck` pada semua script bash
- [ ] Verify Apache config: `apache2ctl configtest`
- [ ] Test security headers: `curl -I http://localhost/slims`
- [ ] Verify file permissions: `find /var/www/html/slims -ls`
- [ ] Check credentials file: `ls -la /etc/slims/credentials`
- [ ] Backup & restore test
- [ ] Load testing (minimal 10 concurrent users)

### 10. Manual Steps (Setelah Install)
- [ ] Ganti password admin default (admin/admin)
- [ ] Hapus folder `installer` SETELAH setup selesai
- [ ] Set timezone yang benar di SLiMS
- [ ] Catat semua credentials di tempat aman
- [ ] Dokumentasi backup & restore procedure

## 🚨 Critical Notes

### ⚠️ JANGAN lakukan ini:

1. **JANGAN hapus folder `installer` sebelum setup SLiMS selesai!**
   - Folder ini diperlukan untuk instalasi web pertama kali
   - Hapus SETELAH database dan admin berhasil dibuat

2. **JANGAN paksa `session.cookie_secure = 1` jika masih HTTP**
   - Aktifkan hanya setelah HTTPS/SSL dikonfigurasi

3. **JANGAN disable `curl_exec` jika plugin SLiMS membutuhkannya**
   - Test dulu sebelum disable di production

4. **WAJIB test di VM isolated sebelum production**
   - Test backup & restore
   - Test security headers
   - Test concurrent users

## 📋 Quick Security Check

```bash
# Check security headers
curl -I http://localhost/slims | grep -E "X-|Server"

# Check file permissions
ls -la /etc/slims/credentials
find /var/www/html/slims -type d -exec ls -ld {} \; | head -10

# Check firewall status
sudo ufw status

# Check backup
ls -la /backup/slims/

# Check Apache config
sudo apache2ctl configtest
```

## 🔄 Ongoing Maintenance

- [ ] Update sistem rutin (`apt update && apt upgrade`)
- [ ] Monitor log file untuk suspicious activity
- [ ] Review backup rutin (apakah berhasil?)
- [ ] Audit user access berkala
- [ ] Test restore backup minimal 3 bulan sekali

---

**Status:** Production-Ready ✅

**Last Updated:** September 2026
