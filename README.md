# SLiMS Linux Production - Instalasi Mudah

Solusi SLiMS stabil di Linux untuk PC spesifikasi minim. **Lupakan database corruption di XAMPP Windows!**

## 🚀 Quick Start (3 Langkah)

### Cara TERMUDAH - 1 Command

```bash
# Download dan jalankan script instalasi
wget -qO- https://raw.githubusercontent.com/muzub/slims-linux-production/main/scripts/install-slims.sh | sudo bash
```

**Tunggu 5-10 menit** → SLiMS siap di `http://localhost/slims`

### Cara Manual (Jika Gagal)

1. **Install Xubuntu 24.04** dari https://xubuntu.org/download/
2. **Buka Terminal** (`Ctrl+Alt+T`)
3. **Jalankan script**:
   ```bash
   wget https://raw.githubusercontent.com/muzub/slims-linux-production/main/scripts/install-slims.sh
   chmod +x install-slims.sh
   sudo ./install-slims.sh
   ```

## ✅ Yang Sudah Otomatis

- ✅ Apache + MariaDB + PHP terinstall
- ✅ SLiMS 9 Bulian terdownload & tersetup
- ✅ Database `slims` dibuat otomatis
- ✅ Backup harian otomatis
- ✅ Icon "Buka SLiMS" di desktop
- ✅ Production-ready untuk PC minim

## 📋 Setup SLiMS (Hanya Sekali)

1. Buka Firefox → `http://localhost/slims`
2. Klik **Get Started** → **Install SLiMS**
3. Isi database:
   - Database: `slims`
   - Username: `slims`
   - Password: `slims2026`
4. Test Connection → Run Installation
5. Login: `admin` / `admin` → **GANTI PASSWORD!**

## 🛠️ Custom ISO (Untuk Banyak PC)

Jika mau distribusi ke banyak perpustakaan, buat ISO custom:

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

## 📚 Dokumentasi

- **Panduan instalasi lengkap:** [docs/01-install-manual.md](docs/01-install-manual.md)
- **Troubleshooting:** [docs/03-troubleshooting.md](docs/03-troubleshooting.md)
- **Panduan user:** [docs-user/PANDUAN-USER.md](docs-user/PANDUAN-USER.md)

## 💻 Spesifikasi Minimum

| Komponen | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 2GB | 4GB |
| CPU | Dual-core 1.5GHz | Quad-core 2GHz+ |
| Storage | 20GB | 40GB SSD |

## ❓ Kenapa Linux?

- ✅ **Stabil** - Database tidak mudah corrupt seperti di XAMPP Windows
- ✅ **Ringan** - Jalan lancar di PC lama
- ✅ **Production-ready** - MariaDB + Apache di Linux lebih reliable
- ✅ **Auto backup** - Database backup harian otomatis

## 📞 Support

- Issue: https://github.com/muzub/slims-linux-production/issues
- Komunitas SLiMS: https://www.facebook.com/groups/slimscommunity

---

**Dibuat untuk perpustakaan Indonesia** 🇮🇩
