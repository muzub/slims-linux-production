# Tutorial Instalasi Manual SLiMS di Linux

Panduan instalasi SLiMS di Linux dengan langkah seminim mungkin. Total waktu: **10-15 menit**.

## Prasyarat

- PC dengan RAM minimal 2GB (recommended 4GB)
- Storage minimal 20GB
- Koneksi internet untuk download
- USB flashdisk 8GB+ untuk installer

## Langkah 1: Download dan Install Linux

### 1.1 Download Xubuntu 24.04 LTS

Xubuntu dipilih karena:
- Desktop Xfce ringan (RAM 400-600MB)
- Familiar untuk user Windows
- Support long-term sampai 2029

**Download:** https://xubuntu.org/download/

### 1.2 Buat USB Installer

**Windows:**
1. Download Rufus: https://rufus.ie
2. Insert USB flashdisk
3. Buka Rufus → Pilih ISO Xubuntu → Start

**Linux:**
```bash
# Gunakan Etcher atau dd
sudo dd if=xubuntu-24.04.iso of=/dev/sdX bs=4M status=progress
```

### 1.3 Install Xubuntu

1. Boot dari USB
2. Pilih "Install Xubuntu"
3. Pilih bahasa → Indonesia
4. Layout keyboard → Indonesian
5. **Installation type**: "Erase disk and install Xubuntu" (untuk PC baru)
6. Timezone → Jakarta
7. Buat user:
   - Your name: `Admin Perpustakaan`
   - Computer name: `slims-server`
   - Username: `admin`
   - Password: `[pilih password kuat]`
8. Klik "Install Now" → tunggu hingga selesai
9. Restart dan lepaskan USB

## Langkah 2: Instalasi SLiMS Otomatis

### 2.1 Download Script

Setelah Xubuntu terinstall dan login:

1. Buka Terminal (`Ctrl+Alt+T`)
2. Jalankan perintah:

```bash
# Download script instalasi
cd ~/Downloads
wget https://raw.githubusercontent.com/muzub/slims-linux-production/main/scripts/install-slims.sh

# Beri permission execute
chmod +x install-slims.sh
```

### 2.2 Jalankan Script

```bash
# Jalankan dengan sudo
sudo ./install-slims.sh
```

Script akan otomatis:
- ✅ Update sistem
- ✅ Install Apache, MariaDB, PHP
- ✅ Download dan setup SLiMS
- ✅ Buat database `slims`
- ✅ Buat user database
- ✅ Buat shortcut desktop
- ✅ Setup backup otomatis

**Tunggu 5-10 menit** hingga muncul:
```
=== Instalasi Selesai! ===
Akses SLiMS di: http://localhost/slims
Username: admin | Password: admin
```

### 2.3 Finalisasi Setup SLiMS

1. **Hapus folder installer** (keamanan):
   ```bash
   sudo rm -rf /var/www/html/slims/installer
   ```

2. **Buka SLiMS**:
   - Klik icon "Buka SLiMS" di desktop
   - Atau buka Firefox → ketik: `http://localhost/slims`

3. **Setup awal SLiMS**:
   - Klik "Get Started" → "Install SLiMS"
   - Database Name: `slims`
   - Username: `slims`
   - Password: `slims2026`
   - Klik "Test Connection" → "Connection OK"
   - Buat akun admin (username: `admin`, password: `admin`)
   - Klik "Run The Installation"

4. **Login ke SLiMS**:
   - URL: `http://localhost/slims`
   - Username: `admin`
   - Password: `admin`
   - **Ganti password segera!** (Menu: Admin → Users)

## Langkah 3: Konfigurasi Tambahan (Opsional)

### 3.1 Set IP Static (Untuk Akses Jaringan)

Jika ingin SLiMS bisa diakses dari komputer lain:

```bash
# Edit network configuration
sudo nano /etc/netplan/01-network-manager-all.yaml
```

Isi dengan:
```yaml
network:
  version: 2
  renderer: network-manager
  ethernets:
    eth0:
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
```

Terapkan:
```bash
sudo netplan apply
```

### 3.2 Enable Remote Access (SSH)

```bash
sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
```

Akses dari komputer lain:
```bash
ssh admin@192.168.1.100
```

### 3.3 Backup Manual Database

```bash
# Backup ke file SQL
mysqldump -u slims -p'slims2026' slims > backup_slims_$(date +%Y%m%d).sql

# Restore dari backup
mysql -u slims -p'slims2026' slims < backup_slims_20260902.sql
```

## Troubleshooting

### SLiMS Tidak Muncul di Browser

```bash
# Cek status Apache
sudo systemctl status apache2

# Restart Apache
sudo systemctl restart apache2

# Cek error log
sudo tail -f /var/log/apache2/error.log
```

### Database Connection Failed

```bash
# Cek status MariaDB
sudo systemctl status mariadb

# Restart MariaDB
sudo systemctl restart mariadb

# Test koneksi database
mysql -u slims -p'slims2026' slims
```

### Permission Denied

```bash
# Fix permission
sudo chown -R www-data:www-data /var/www/html/slims
sudo chmod -R 755 /var/www/html/slims
```

### Desktop Terlalu Lambat

```bash
# Matikan efek compositor
# Settings → Window Manager Tweaks → Compositor → Uncheck "Enable display compositing"

# Hapus aplikasi tidak perlu
sudo apt remove thunderbird rhythmbox -y
```

## Langkah Selanjutnya

- [Panduan User](../docs-user/PANDUAN-USER.md)
- [Troubleshooting Lengkap](03-troubleshooting.md)
- [Build Custom ISO](02-custom-iso.md)

---

**Tips:** Bookmark halaman ini untuk referensi di masa mendatang!
