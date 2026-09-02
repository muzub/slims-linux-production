# Panduan User SLiMS OS

Panduan lengkap untuk pengguna SLiMS di Linux production environment.

## 📋 Daftar Isi

1. [Spesifikasi Minimum](#spesifikasi-minimum)
2. [Login Pertama Kali](#login-pertama-kali)
3. [Membuka SLiMS](#membuka-slims)
4. [Setup Awal SLiMS](#setup-awal-slims)
5. [Login ke SLiMS](#login-ke-slims)
6. [Backup Database](#backup-database)
7. [Troubleshooting](#troubleshooting)

---

## Spesifikasi Minimum

| Komponen | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 2GB | 4GB |
| Processor | Dual-core 1.5GHz | Quad-core 2GHz+ |
| Storage | 20GB HDD | 40GB SSD |
| Monitor | 1024x768 | 1366x768 |

---

## Login Pertama Kali

### Jika Install Manual

1. **Boot komputer** hingga muncul layar login Xubuntu
2. **Masukkan username** yang dibuat saat instalasi (misal: `admin`)
3. **Masukkan password** yang dibuat saat instalasi
4. Klik **Login** atau tekan Enter

### Jika Pakai ISO Custom

1. **Boot dari USB installer**
2. Pilih **"Install SLiMS OS"**
3. Ikuti wizard instalasi:
   - Pilih bahasa: Indonesia
   - Layout keyboard: Indonesian
   - Pilih "Erase disk and install" (untuk PC baru)
   - Timezone: Jakarta
   - Buat username dan password
4. Tunggu instalasi selesai (~15-20 menit)
5. Restart dan login

---

## Membuka SLiMS

### Cara 1: Klik Icon Desktop (Paling Mudah)

1. Lihat desktop, cari icon **"Buka SLiMS"**
2. **Double-click** icon tersebut
3. Firefox akan terbuka dengan SLiMS

### Cara 2: Buka Manual di Firefox

1. Klik icon **Firefox** di taskbar
2. Ketik di address bar: `http://localhost/slims`
3. Tekan Enter

### Cara 3: Akses dari Komputer Lain (Jaringan)

Jika SLiMS server sudah diset untuk akses jaringan:

1. Buka Firefox di komputer client
2. Ketik: `http://[IP_SERVER]/slims`
   - Contoh: `http://192.168.1.100/slims`
3. Tekan Enter

---

## Setup Awal SLiMS

**PENTING:** Lakukan ini hanya sekali saat pertama kali instalasi!

### Langkah 1: Halaman Instalasi

1. Setelah SLiMS terbuka, klik tombol **"Get Started"**
2. Klik **"Install SLiMS"**

### Langkah 2: Konfigurasi Database

Isi informasi database:

```
Database Name: slims
Username: slims
Password: slims2026
Host: localhost
```

3. Klik **"Test Connection"**
4. Jika muncul **"Connection OK"**, klik **"Run The Installation"**

### Langkah 3: Buat Akun Admin

Isi data admin:

```
Username: admin
Password: admin
Email: admin@perpustakaan.sch.id
Nama Lengkap: Administrator
```

5. Klik **"Create Admin Account"**

### Langkah 4: Selesai!

6. SLiMS akan redirect ke halaman login
7. **PENTING:** Hapus folder installer untuk keamanan:
   - Buka Terminal (`Ctrl+Alt+T`)
   - Ketik: `sudo rm -rf /var/www/html/slims/installer`
   - Enter, masukkan password

---

## Login ke SLiMS

### Login Pertama

1. Buka SLiMS (klik icon desktop atau `http://localhost/slims`)
2. Masukkan kredensial:
   ```
   Username: admin
   Password: admin
   ```
3. Klik **"Login"**

### ⚠️ GANTI PASSWORD DEFAULT!

**Sangat penting untuk keamanan!**

1. Setelah login, klik menu **"Admin"** (pojok kanan atas)
2. Pilih **"Users"**
3. Klik username **"admin"**
4. Klik tab **"Change Password"**
5. Masukkan:
   ```
   Old Password: admin
   New Password: [password kuat minimal 8 karakter]
   Confirm: [ulangi password]
   ```
6. Klik **"Save"**

**Tips password kuat:**
- Minimal 8 karakter
- Kombinasi huruf besar, kecil, angka, simbol
- Contoh: `P3rpustak@an2026!`

---

## Backup Database

### Backup Otomatis

SLiMS OS sudah setup **backup otomatis setiap hari**:

- **Lokasi backup:** `/backup/slims/`
- **Format file:** `slims_YYYYMMDD.sql`
- **Retensi:** 7 hari terakhir (file lama otomatis dihapus)

### Cara Cek Backup

1. Buka **File Manager**
2. Navigate ke folder: `/backup/slims/`
3. Lihat file `.sql` yang ada

### Backup Manual

Jika ingin backup sebelum operasi penting:

1. Buka Terminal (`Ctrl+Alt+T`)
2. Ketik:
   ```bash
   mysqldump -u slims -p'slims2026' slims > backup_manual_$(date +%Y%m%d).sql
   ```
3. File backup akan tersimpan di folder home Anda

### Restore Database

Jika database rusak dan perlu restore:

1. Buka Terminal
2. Ketik:
   ```bash
   mysql -u slims -p'slims2026' slims < /backup/slims/slims_20260902.sql
   ```
   (ganti tanggal sesuai file backup yang ingin direstore)

---

## Troubleshooting

### SLiMS Tidak Bisa Dibuka

**Gejala:** Klik icon "Buka SLiMS" tidak ada reaksi.

**Solusi:**

1. Buka Firefox manual
2. Ketik: `http://localhost/slims`
3. Jika masih error, restart komputer

### Error "Database Connection Failed"

**Solusi:**

1. Buka Terminal
2. Restart MariaDB:
   ```bash
   sudo systemctl restart mariadb
   ```
3. Coba buka SLiMS lagi

### SLiMS Lambat

**Solusi:**

1. Tutup aplikasi lain yang tidak perlu
2. Restart komputer
3. Jika masih lambat, cek RAM:
   - Buka Terminal
   - Ketik: `htop`
   - Lihat usage RAM dan CPU

### Lupa Password Admin

**Solusi:**

1. Buka Terminal
2. Reset password via database:
   ```bash
   mysql -u slims -p'slims2026' slims
   ```
3. Di MySQL prompt:
   ```sql
   UPDATE user SET passwd=MD5('admin') WHERE username='admin';
   EXIT;
   ```
4. Login dengan password: `admin`
5. Ganti password segera!

### Komputer Tidak Bisa Boot

**Solusi:**

1. Restart komputer
2. Tekan `Shift` atau `F12` saat boot untuk masuk boot menu
3. Pilih harddisk yang benar
4. Jika masih tidak bisa, mungkin perlu reinstall

---

## Tips Penggunaan

### 1. Shutdown Proper

**JANGAN** langsung cabut listrik atau tekan tombol power!

**Cara shutdown yang benar:**

1. Klik menu (pojok kiri bawah)
2. Pilih **"Shut Down..."**
3. Klik **"Shut Down"**
4. Tunggu hingga komputer mati sendiri

### 2. Update Rutin

Update sistem minimal sebulan sekali:

1. Buka Terminal
2. Ketik:
   ```bash
   sudo apt update
   sudo apt upgrade -y
   ```

### 3. Jaga Storage

Jangan biarkan storage penuh (>90%):

1. Buka File Manager
2. Cek folder `/backup/slims/`
3. Hapus backup lama jika perlu (tapi minimal simpan 1 backup)

### 4. Catat Perubahan

Jika ada customisasi SLiMS (tambah plugin, dll):

- Catat di buku/log
- Backup sebelum dan sesudah perubahan
- Test fitur yang diubah

---

## Kontak Support

Jika masih ada masalah:

1. **Admin IT perpustakaan** - kontak pertama
2. **Dokumentasi:** https://github.com/muzub/slims-linux-production
3. **Issue GitHub:** https://github.com/muzub/slims-linux-production/issues
4. **Komunitas SLiMS:** https://www.facebook.com/groups/slimscommunity

---

## FAQ

**Q: Apakah SLiMS bisa diakses dari HP?**
A: Ya, asalkan HP terhubung ke jaringan WiFi yang sama dengan server SLiMS. Buka browser di HP → `http://[IP_SERVER]/slims`

**Q: Berapa maksimal user yang bisa akses bersamaan?**
A: Tergantung spesifikasi server. Untuk PC dengan RAM 4GB, bisa handle 10-20 user bersamaan dengan lancar.

**Q: Apakah data aman?**
A: Ya, asalkan:
- Password admin diganti dari default
- Backup rutin dicek
- Komputer shutdown proper
- Gunakan UPS untuk hindari mati listrik mendadak

**Q: Bisa upgrade SLiMS ke versi lebih baru?**
A: Ya, tapi backup database dulu! Download versi baru dari GitHub SLiMS, extract, copy file (kecuali folder `config` dan `uploaded`), migrate database.

---

**Selamat menggunakan SLiMS!** 📚

*Dibuat untuk perpustakaan Indonesia* 🇮🇩
