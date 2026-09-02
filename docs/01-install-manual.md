# Tutorial Instalasi SLiMS - Super Mudah

**Total waktu: 10 menit** | **Langkah: 3 saja**

## Prasyarat

- PC dengan RAM minimal 2GB
- USB flashdisk 8GB+ untuk installer
- Koneksi internet

---

## Langkah 1: Install Xubuntu

### Download Xubuntu 24.04

https://xubuntu.org/download/

### Buat USB Installer

**Windows:**
1. Download Rufus: https://rufus.ie
2. Insert USB → Buka Rufus → Pilih ISO → Start

**Linux:**
```bash
sudo dd if=xubuntu-24.04.iso of=/dev/sdX bs=4M status=progress
```

### Install Xubuntu

1. Boot dari USB
2. Pilih **"Install Xubuntu"**
3. Pilih bahasa → Indonesia
4. Keyboard → Indonesian
5. **Installation type**: "Erase disk and install Xubuntu"
6. Timezone → Jakarta
7. Buat user:
   - Name: `Admin`
   - Username: `admin`
   - Password: `[pilih password]`
8. Install → Restart

---

## Langkah 2: Jalankan Script SLiMS

Setelah login Xubuntu:

### Opsi A: One-Liner (Termudah)

```bash
wget -qO- https://raw.githubusercontent.com/muzub/slims-linux-production/main/scripts/install-slims.sh | sudo bash
```

### Opsi B: Download Manual

```bash
wget https://raw.githubusercontent.com/muzub/slims-linux-production/main/scripts/install-slims.sh
chmod +x install-slims.sh
sudo ./install-slims.sh
```

**Tunggu 5-10 menit** → Script akan:
- ✅ Install Apache, MariaDB, PHP
- ✅ Download & setup SLiMS
- ✅ Buat database
- ✅ Buat shortcut desktop
- ✅ Setup backup otomatis

---

## Langkah 3: Setup SLiMS

### 1. Hapus Installer (Keamanan)

```bash
sudo rm -rf /var/www/html/slims/installer
```

### 2. Buka SLiMS

- Klik icon **"Buka SLiMS"** di desktop
- Atau Firefox → `http://localhost/slims`

### 3. Setup Awal

1. Klik **Get Started** → **Install SLiMS**
2. Isi database:
   ```
   Database Name: slims
   Username: slims
   Password: slims2026
   ```
3. **Test Connection** → **Run Installation**
4. Buat admin:
   ```
   Username: admin
   Password: admin
   ```
5. Login → **Ganti password segera!**

---

## ✅ Selesai!

SLiMS siap digunakan.

### Akses SLiMS

- URL: `http://localhost/slims`
- Login: `admin` / `[password Anda]`

### Backup Otomatis

Backup harian ada di: `/backup/slims/`

---

## ❓ Troubleshooting

### SLiMS tidak muncul?

```bash
# Restart Apache
sudo systemctl restart apache2

# Cek status
sudo systemctl status apache2
```

### Database error?

```bash
# Restart MariaDB
sudo systemctl restart mariadb
```

### Butuh bantuan?

- Lihat: [docs/03-troubleshooting.md](03-troubleshooting.md)
- Issue: https://github.com/muzub/slims-linux-production/issues

---

**Tips:** Bookmark halaman ini untuk referensi!
