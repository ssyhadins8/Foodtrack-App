# DEPLOYMENT_GUIDE.md

## Prasyarat
1. **Firebase CLI** sudah terpasang (`firebase --version` menunjukkan versi 15.16.0) dan Anda sudah login (`firebase login:list` menampilkan email Anda).
2. **Flutter SDK** 3.x atau lebih tinggi terinstal.
3. **Google Cloud OAuth‑client** sudah dikonfigurasi (lihat langkah 1 pada rencana implementasi).

## Langkah‑langkah Deploy
### 1. Konfigurasi Firebase (jika belum)
```bash
# Jalankan di folder proyek
flutterfire configure
```
Perintah ini akan menghasilkan atau memperbarui `lib/firebase_options.dart` dengan kredensial proyek Anda.

### 2. Tambahkan **JavaScript origins** di Google Cloud Console
- Buka **Google Cloud Console → APIs & Services → Credentials**.
- Pilih **OAuth 2.0 Client ID** yang berlabel *FoodTrack Web*.
- Tambahkan origin berikut (ganti `<PORT>` dengan port yang Anda gunakan saat menjalankan aplikasi Flutter Web, biasanya `http://localhost:8080` atau `http://127.0.0.1:5000`):
  - `http://localhost:<PORT>`
  - `http://127.0.0.1:<PORT>`
- Jika ada domain produksi, tambahkan `https://yourdomain.com`.

### 3. Tambahkan **Authorized domains** di Firebase Console
1. Buka **Firebase Console → Authentication → Sign‑in method**.
2. Di bagian **Authorized domains**, klik **Add domain** dan masukkan domain yang sama dengan langkah 2 (misalnya `localhost`).

### 4. Deploy Aturan Keamanan Firestore
```bash
firebase deploy --only firestore:rules
```
Pastikan file `firestore.rules` berada di root proyek (saat ini sudah dibuat).  
Jika muncul konfirmasi, pilih **Yes**.

### 5. Jalankan Aplikasi Secara Lokal (untuk verifikasi)
```bash
flutter run -d chrome
```
- Buka browser pada URL yang muncul (contoh `http://localhost:5173`).
- Coba login dengan Google; error `origin_mismatch` seharusnya sudah tidak muncul.

### 6. Deploy ke Firebase Hosting (opsional)
Jika ingin meng‑publish ke web:
```bash
firebase init hosting   # pilih proyek yang sama dan folder build/web
flutter build web        # menghasilkan /build/web
firebase deploy --only hosting
```

## Checklist akhir
- [ ] OAuth 2.0 JavaScript origins sudah ditambahkan.
- [ ] Authorized domains di Firebase Auth sudah ditambahkan.
- [ ] `firestore.rules` sudah dideploy.
- [ ] Aplikasi dapat login tanpa error.
- [ ] (Opsional) Hosting berhasil di‑deploy.

---
**Catatan:** UI desain tidak diubah; perubahan hanya pada backend, aturan keamanan, dan penanganan error UI.
