# Panduan Presentasi UAS Pemrograman Mobile

Dokumen ini disusun sebagai panduan persiapan tanya jawab dan demonstrasi kode program saat presentasi evaluasi akhir proyek UAS Pemrograman Mobile untuk aplikasi FoodTrack.

---

## Bagian 1: Konsep Arsitektur dan Manajemen State

### Pertanyaan 1: Mengapa menggunakan struktur direktori proyek seperti ini? Jelaskan pembagiannya!
* **Jawaban:**  
  "Kami membagi struktur kode program berdasarkan prinsip pemisahan tanggung jawab (Separation of Concerns) untuk memudahkan pemeliharaan dan pengembangan skala besar:
  1. **`lib/pages/` (Presentation Layer):** Menyimpan seluruh komponen antarmuka pengguna (Views) seperti form masuk, dashboard admin, panel pedagang, dan panel pembeli.
  2. **`lib/services/` (Data/Backend Layer):** Berisi berkas integrasi Firebase (`firestore_service.dart`) untuk komunikasi database dan otentikasi, serta logika estimasi antrean (`queue_service.dart`).
  3. **`lib/theme/` (Design System):** Menampung konfigurasi visual global (`app_colors.dart`) guna memastikan konsistensi warna antarmuka di seluruh modul halaman.
  4. **`cart_provider.dart` (State Management):** Mengatur kondisi state global dari keranjang belanja secara independen dari kode program antarmuka."

### Pertanyaan 2: Mengapa memilih Provider sebagai pustaka State Management?
* **Jawaban:**  
  "Kami memilih Provider karena merupakan pustaka resmi yang direkomendasikan oleh Flutter untuk manajemen state. Provider menyederhanakan penggunaan InheritedWidget untuk meneruskan data ke bawah pohon widget secara reaktif.
  Keunggulannya dibanding setState konvensional:
  - Mengurangi konsumsi daya render ulang (re-rendering) pada widget induk yang tidak mengalami perubahan data.
  - Logika kalkulasi matematis seperti perhitungan pajak, subtotal, dan biaya aplikasi terpisah secara eksplisit dari kode widget visual."

---

## Bagian 2: Integrasi Database dan API Real-Time

### Pertanyaan 3: Bagaimana mekanisme sinkronisasi data real-time bekerja pada aplikasi ini?
* **Jawaban:**  
  "Aplikasi memanfaatkan fitur Streams (`snapshots()`) yang disediakan oleh Cloud Firestore SDK pada kelas `FirestoreService`.
  - Ketika status pesanan diperbarui oleh pedagang di panel kontrol dapur (misalnya status dari 'Diproses' berubah menjadi 'Siap Diambil'), Firestore akan mendistribusikan data perubahan tersebut secara langsung melalui koneksi WebSocket.
  - Halaman pelacakan pembeli menggunakan widget `StreamBuilder` untuk memantau aliran data tersebut dan secara otomatis memperbarui antarmuka pengguna dalam hitungan milidetik secara reaktif tanpa membutuhkan tindakan muat ulang halaman."

### Pertanyaan 4: Jelaskan cara kerja pengisian data otomatis (database seeder)!
* **Jawaban:**  
  "Pada saat aplikasi pertama kali dijalankan (`main.dart`), fungsi `seedInitialData()` pada `FirestoreService` akan dieksekusi secara otomatis.
  - Sistem akan melakukan verifikasi apakah koleksi database `'kantin'` di Firestore kosong.
  - Jika kosong, sistem otomatis menyuntikkan data awal berupa 8 kantin default beserta daftar menunya masing-masing (harga, deskripsi, rating, jam operasional, dan gambar terkait).
  - Jika terdeteksi database sudah terisi, sistem melewati fungsi ini untuk mempercepat waktu pemuatan aplikasi dan menghemat lalu lintas data."

### Pertanyaan 5: Bagaimana integrasi API cuaca eksternal dilakukan?
* **Jawaban:**  
  "Aplikasi memanggil API cuaca eksternal (Open-Meteo) dengan mengirimkan parameter koordinat geografis. Data suhu udara yang diperoleh kemudian diolah untuk memberikan rekomendasi menu makanan di beranda pembeli secara otomatis (misalnya merekomendasikan soto hangat jika suhu terdeteksi dingin, atau es krim segar jika suhu terdeteksi panas terik)."

---

## Bagian 3: Panduan Lokasi Kode untuk Demonstrasi

Berikut merupakan lokasi berkas kode sumber utama yang penting untuk ditunjukkan saat sesi demonstrasi program:

1. **Logika Filter Beranda dan Transisi Gulir Otomatis:**
   * Berkas: [home.dart](file:///C:/FoodTrack/foodtruck/lib/pages/home.dart)
   * Tunjukkan tombol "Lihat Semua" yang memicu fungsi penapisan rating tertinggi (`_showOnlyTopCanteens`) serta fungsi gulir otomatis ke bagian daftar kantin menggunakan ScrollController.
2. **Validasi Input Registrasi Role Pengguna:**
   * Berkas: [signup.dart](file:///C:/FoodTrack/foodtruck/lib/pages/signup.dart)
   * Tunjukkan input pilihan peran (Pembeli / Pedagang) yang dilengkapi validasi format email, sandi minimal 6 karakter, dan pencatatan nama kantin baru untuk peran pedagang.
3. **Logika Pengelolaan Menu oleh Pedagang (CRUD Menu):**
   * Berkas: [menu_pedagang_page.dart](file:///C:/FoodTrack/foodtruck/lib/pages/pedagang/menu_pedagang_page.dart)
   * Tunjukkan form tambah/edit menu yang langsung melakukan sinkronisasi pembaruan data ke koleksi `'menu'` di Firestore.
4. **Metode Inisialisasi Otomatis Database (Seeder):**
   * Berkas: [firestore_service.dart](file:///C:/FoodTrack/foodtruck/lib/services/firestore_service.dart)
   * Tunjukkan metode `seedInitialData()`, `seedNewFoodcourtBaru()`, dan `seedTobyChicken()` yang bertugas mengisi data default ke koleksi database Firestore.
