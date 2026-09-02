# SLiMS Linux Production - Security Hardened

Solusi SLiMS stabil di Linux untuk PC spesifikasi minim dengan **security hardening production-ready**.

## 🚀 Quick Start (2 Fase)

### ⚠️ PENTING: 2 Fase Instalasi

**Fase 1: Install Linux** (sekali saja)  
**Fase 2: Install SLiMS** (1 command dengan security hardening)

---

## Fase 1: Install Linux (15 menit)

### 🎯 REKOMENDASI: Xubuntu 24.04 LTS

**Kenapa 24.04 LTS?**
- ✅ Support sampai **April 2029** (masih 2.5+ tahun dari sekarang)
- ✅ PHP 8.3 - kompatibel dengan SLiMS 9 Bulian
- ✅ Security patches terbaru
- ✅ Stabil untuk production (sudah 2+ tahun release)
- ✅ Kompatibel dengan hardware lama (RAM 2-4GB)

**Download:** https://xubuntu.org/download/

**Alternatif:**
- **Xubuntu 26.04 LTS** - Jika sudah tersedia (support sampai 2031)
- **Ubuntu 24.04 LTS** - Jika mau desktop GNOME (butuh RAM 4GB+)
- **Linux Mint 22 Xfce** - Jika mau yang lebih mirip Windows

**⚠️ JANGAN gunakan Ubuntu 22.04 LTS** - Support tinggal 7 bulan (April 2027)!

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
3. Pilih bahasa → Indonesia (opsional)
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

## Fase 2: Install SLiMS (5-10 menit)

**Setelah Linux terinstall, jalankan:**

```bash
wget -qO- https://raw.githubusercontent.com/muzub/slims-linux-production/main/scripts/install-slims.sh | sudo bash
```

**Tunggu 5-10 menit** → SLiMS siap di `http://localhost/slims`

### Yang Otomatis Terinstall:

- ✅ Apache + MariaDB + PHP (production configuration)
- ✅ SLiMS 9 Bulian (latest from GitHub)
- ✅ Database dengan **random password** (secure)
- ✅ **Security headers** (X-Frame-Options, CSP, dll)
- ✅ **Firewall UFW** (ports 22, 80, 443)
- ✅ **PHP hardening** (disable functions, expose_php off)
- ✅ **Directory indexing disabled**
- ✅ **Credentials** di `/etc/slims/credentials` (chmod 600)
- ✅ **Auto backup** harian (gzip compressed)
- ✅ **MariaDB secure** (anonymous & test DB removed)
- ✅ **VirtualHost Apache** terpisah untuk SLiMS
- ✅ **Verification** otomatis setelah install

---

## 📋 Setup SLiMS (Hanya Sekali)

1. **Buka SLiMS**:
   - Klik icon "Buka SLiMS" di desktop
   - Atau Firefox → `http://localhost/slims`

2. **Setup awal**:
   - Get Started → Install SLiMS
   - Database: `slims`
   - Username: `slims`
   - Password: Lihat di `/etc/slims/credentials`
   - Test Connection → Run Installation

3. **Login**:
   - Username: `admin`
   - Password: `admin`
   - **⚠️ GANTI PASSWORD SETELAH LOGIN!**

4. **Hapus installer** (keamanan):
   ```bash
   sudo rm -rf /var/www/html/slims/installer
   ```

---

## 🔒 Security Features

| Feature | Status |
|---------|--------|
| Random database password | ✅ Auto-generated |
| Credentials file (chmod 600) | ✅ `/etc/slims/credentials` |
| Security headers | ✅ X-Frame-Options, CSP, X-XSS-Protection |
| PHP hardening | ✅ disable_functions, expose_php off |
| Directory indexing | ✅ Disabled (-Indexes) |
| Firewall (UFW) | ✅ Ports 22, 80, 443 only |
| MariaDB secure | ✅ Anonymous & test DB removed |
| VirtualHost terpisah | ✅ SLiMS-specific config |
| Auto backup (gzip) | ✅ Daily, 7 days retention |
| Verification script | ✅ Post-install checks |

---

## 🛠️ Custom ISO (Untuk Banyak PC)

Jika mau distribusi ke banyak perpustakaan:

```bash
git clone https://github.com/muzub/slims-linux-production.git
cd slims-linux-production
chmod +x scripts/build-iso-cubic.sh
sudo ./scripts/build-iso-cubic.sh
```

ISO siap di `~/slims-iso-build/slims-os-24.04.iso`

📖 **Tutorial:** [docs/02-custom-iso.md](docs/02-custom-iso.md)

---

## 📚 Dokumentasi

- **Instalasi lengkap:** [docs/01-install-manual.md](docs/01-install-manual.md)
- **Troubleshooting:** [docs/03-troubleshooting.md](docs/03-troubleshooting.md)
- **Panduan user:** [docs-user/PANDUAN-USER.md](docs-user/PANDUAN-USER.md)
- **Security checklist:** [docs/04-security.md](docs/04-security.md)

---

## 💻 Spesifikasi Minimum

| Komponen | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 2GB | 4GB |
| CPU | Dual-core 1.5GHz | Quad-core 2GHz+ |
| Storage | 20GB HDD | 40GB SSD |

---

## ❓ Kenapa Linux?

- ✅ **Stabil** - Database tidak corrupt seperti XAMPP Windows
- ✅ **Ringan** - Jalan lancar di PC lama (RAM 2GB)
- ✅ **Production-ready** - MariaDB + Apache di Linux lebih reliable
- ✅ **Auto backup** - Database backup harian otomatis
- ✅ **Security-hardened** - Firewall, headers, permissions, credentials secure

---

## 📞 Support

- Issue: https://github.com/muzub/slims-linux-production/issues
- Komunitas SLiMS: https://www.facebook.com/groups/slimscommunity

---

**Dibuat untuk perpustakaan Indonesia** 🇮🇩

**Status:** Production-Ready ✅

**Recommended OS:** Xubuntu 24.04 LTS (support sampai April 2029)

**Last Updated:** September 2026
