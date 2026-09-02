# SLiMS Linux Production

Panduan instalasi **SLiMS (Senayan Library Management System)** di Linux production-ready dengan GUI untuk PC spesifikasi minim. Solusi untuk mengatasi masalah database corruption di XAMPP Windows.

## 🎯 Kenapa Linux?

- ✅ **Stabil** - MariaDB di Linux jauh lebih stabil daripada MySQL di XAMPP Windows
- ✅ **Ringan** - Bisa jalan di PC dengan RAM 2-4GB
- ✅ **Production-ready** - Stack LAMP di Linux dirancang untuk lingkungan produksi
- ✅ **Minimal corruption** - File locking Linux mencegah database rusak

## 📋 Pilihan Instalasi

### Opsi 1: Install Manual (Untuk 1-5 PC)

Install Linux dari ISO resmi, lalu jalankan script instalasi otomatis.

**Cocok untuk:**
- Admin IT yang familiar dengan Linux dasar
- Instalasi di beberapa PC saja
- Mau kontrol penuh atas instalasi

👉 [Lihat tutorial instalasi manual](docs/01-install-manual.md)

### Opsi 2: Custom ISO (Untuk Distribusi Massal)

Download ISO custom yang sudah include SLiMS + GUI, tinggal install seperti Windows.

**Cocok untuk:**
- Distribusi ke banyak perpustakaan
- User awam yang tidak mau ribet
- Instalasi massal dengan konfigurasi seragam

👉 [Lihat tutorial custom ISO](docs/02-custom-iso.md)

## 🖥️ Spesifikasi Minimum

| Komponen | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 2GB | 4GB |
| CPU | Dual-core 1.5GHz | Quad-core 2GHz+ |
| Storage | 20GB HDD | 40GB SSD |
| OS | Ubuntu 24.04 LTS / Xubuntu | Xubuntu 24.04 LTS |

## 📁 Struktur Repository

```
slims-linux-production/
├── README.md                 # Dokumentasi utama
├── docs/
│   ├── 01-install-manual.md  # Tutorial instalasi manual
│   ├── 02-custom-iso.md      # Tutorial custom ISO
│   └── 03-troubleshooting.md # Troubleshooting
├── scripts/
│   ├── install-slims.sh      # Script instalasi otomatis
│   ├── build-iso-cubic.sh    # Script build ISO dengan Cubic
│   └── build-iso-livebuild.sh # Script build ISO dengan live-build
├── config/
│   ├── apache.conf           # Konfigurasi Apache
│   └── mariadb.conf          # Konfigurasi MariaDB
└── docs-user/
    └── PANDUAN-USER.md       # Panduan untuk end-user
```

## 🚀 Quick Start

### Instalasi Manual (5 Menit)

```bash
# 1. Install Xubuntu 24.04 LTS dari https://xubuntu.org/download/

# 2. Download script instalasi
wget https://raw.githubusercontent.com/muzub/slims-linux-production/main/scripts/install-slims.sh

# 3. Jalankan script
chmod +x install-slims.sh
sudo ./install-slims.sh

# 4. Buka browser → http://localhost/slims
```

### Build Custom ISO (30 Menit)

```bash
# 1. Clone repository ini
git clone https://github.com/muzub/slims-linux-production.git
cd slims-linux-production

# 2. Jalankan script build ISO
chmod +x scripts/build-iso-cubic.sh
sudo ./scripts/build-iso-cubic.sh

# 3. ISO siap di ~/slims-iso/*.iso
```

## 📚 Dokumentasi Lengkap

- [Instalasi Manual Step-by-Step](docs/01-install-manual.md)
- [Build Custom ISO dengan Cubic](docs/02-custom-iso.md)
- [Troubleshooting](docs/03-troubleshooting.md)
- [Panduan User](docs-user/PANDUAN-USER.md)

## 🛠️ Fitur

- ✅ **Desktop Environment Xfce** - Ringan dan familiar untuk user Windows
- ✅ **Auto-install SLiMS** - Script otomatis setup Apache, MariaDB, PHP, SLiMS
- ✅ **Auto-backup Database** - Backup harian otomatis di `/backup/slims/`
- ✅ **Desktop Shortcut** - Icon "Buka SLiMS" di desktop
- ✅ **Production Configuration** - MariaDB dan Apache sudah di-tune untuk PC minim
- ✅ **First-boot Setup** - Database dibuat otomatis saat first boot (untuk ISO custom)

## 📞 Support

- Issue: https://github.com/muzub/slims-linux-production/issues
- SLiMS Official: https://slims.web.id
- Komunitas SLiMS: https://www.facebook.com/groups/slimscommunity

## 📄 License

- SLiMS: GPL v3
- Script dan dokumentasi ini: MIT License

---

**Dibuat untuk komunitas perpustakaan Indonesia** 🇮🇩
