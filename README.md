# SLiMS Linux Production - Instalasi Mudah

Solusi SLiMS stabil di Linux untuk PC spesifikasi minim. **Lupakan database corruption di XAMPP Windows!**

## 🚀 Quick Start

### ⚠️ PENTING: 2 Fase Instalasi

**Fase 1: Install Linux** (sekali saja)  
**Fase 2: Install SLiMS** (1 command)

---

## Fase 1: Install Xubuntu (15 menit)

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

**Setelah restart, login ke Xubuntu.**

---

## Fase 2: Install SLiMS (5 menit)

**Setelah Xubuntu terinstall, jalankan 1 command ini:**

```bash
wget -qO- https://raw.githubusercontent.com/muzub/slims-linux-production/main/scripts/install-slims.sh | sudo bash
```

**Tunggu 5-10 menit** → SLiMS siap di `http://localhost/slims`

Script akan otomatis:
- ✅ Install Apache, MariaDB, PHP
- ✅ Download & setup SLiMS
- ✅ Buat database `slims`
- ✅ Buat shortcut desktop
- ✅ Setup backup harian

---

## 📋 Setup SLiMS (Hanya Sekali)

1. **Hapus installer** (keamanan):
   ```bash
   sudo rm -rf /var/www/html/slims/installer
   ```

2. **Buka SLiMS**:
   - Klik icon **"Buka SLiMS"** di desktop
   - Atau Firefox → `http://localhost/slims`

3. **Setup awal**:
   - Klik **Get Started** → **Install SLiMS**
   - Database: `slims`
   - Username: `slims`
   - Password: `slims2026`
   - Test Connection → Run Installation

4. **Login**:
   - Username: `admin`
   - Password: `admin`
   - **GANTI PASSWORD!**

---

## 🛠️ Custom ISO (Untuk Banyak PC)

Jika mau distribusi ke banyak perpustakaan, buat ISO custom yang sudah include SLiMS:

```bash
# Clone repo
git clone https://github.com/muzub/slims-linux-production.git
cd slims-linux-production

# Build ISO
chmod +x scripts/build-iso-cubic.sh
sudo ./scripts/build-iso-cubic.sh
```

ISO siap di `~/slims-iso-build/slims-os-24.04.iso`

📖 **Tutorial lengkap:** [docs/02-custom-iso.md](docs/02-custom-iso.md)

---

## 📚 Dokumentasi Lengkap

- **Tutorial instalasi:** [docs/01-install-manual.md](docs/01-install-manual.md)
- **Troubleshooting:** [docs/03-troubleshooting.md](docs/03-troubleshooting.md)
- **Panduan user:** [docs-user/PANDUAN-USER.md](docs-user/PANDUAN-USER.md)

---

## 💻 Spesifikasi Minimum

| Komponen | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 2GB | 4GB |
| CPU | Dual-core 1.5GHz | Quad-core 2GHz+ |
| Storage | 20GB | 40GB SSD |

---

## ❓ Kenapa Linux?

- ✅ **Stabil** - Database tidak mudah corrupt seperti di XAMPP Windows
- ✅ **Ringan** - Jalan lancar di PC lama
- ✅ **Production-ready** - MariaDB + Apache di Linux lebih reliable
- ✅ **Auto backup** - Database backup harian otomatis

---

## 📞 Support

- Issue: https://github.com/muzub/slims-linux-production/issues
- Komunitas SLiMS: https://www.facebook.com/groups/slimscommunity

---

**Dibuat untuk perpustakaan Indonesia** 🇮🇩
