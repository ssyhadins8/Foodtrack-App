# LOGBOOK MINGGUAN MAHASISWA
> **Mata Kuliah:** Pemrograman Mobile  
> **Skema Pengerjaan:** Skema A (1 Project Besar - Minggu 4 s/d 16)  
> **Nama Project:** FoodTrack (Aplikasi Smart Campus Canteen berbasis Flutter & Firebase)  

---

## MINGGU 4: Penentuan Ide & Approval Dosen
*   **Progress Minggu Ini:**
    *   Melakukan survei lapangan terhadap masalah antrean di kantin kampus.
    *   Merumuskan konsep aplikasi **FoodTrack** dengan model transaksi *Self-Pickup* (ambil sendiri) untuk memotong waktu antre.
    *   Menyusun pembagian 3 peran pengguna (*Multi-Role*): Pembeli (Mahasiswa), Pedagang (Kantin), dan Admin (Pusat).
*   **Kendala:** Menentukan cakupan fitur agar aplikasi realistis diselesaikan dalam satu semester namun tetap bernilai tinggi.
*   **Solusi:** Membatasi fitur pada manajemen menu, pemesanan langsung, status transaksi real-time, dan dashboard administrasi global tanpa sistem kurir pengantaran.
*   **Rencana Minggu Depan:** Menyusun dokumen proposal formal dan merancang sketsa/wireframe antarmuka UI.

---

## MINGGU 5: Proposal & Desain UI/UX
*   **Progress Minggu Ini:**
    *   Menyusun dokumen proposal awal berisi latar belakang, arsitektur sistem, dan target pengerjaan.
    *   Membuat desain mockup UI/UX menggunakan sistem pewarnaan premium (Gold, Deep Blue, dan Glassmorphism) agar aplikasi terlihat modern dan elegan.
    *   Merancang diagram alir (*sequence diagram*) untuk integrasi data multi-role.
*   **Kendala:** Menyelaraskan ukuran layar agar tampilan tetap konsisten di berbagai rasio layar handphone.
*   **Solusi:** Menggunakan layout responsif dengan persentase padding dinamis serta memanfaatkan widget `LayoutBuilder` dan `SafeArea`.
*   **Rencana Minggu Depan:** Inisialisasi struktur folder project Flutter, konfigurasi Version Control (Git), dan integrasi Firebase SDK.

---

## MINGGU 6: Inisialisasi Project & Integrasi Firebase
*   **Progress Minggu Ini:**
    *   Membuat repositori Git dan melakukan inisialisasi project Flutter baru.
    *   Mengatur struktur folder yang bersih (*Clean Architecture*): `pages/`, `services/`, `theme/`, dan `widgets/`.
    *   Mengintegrasikan Firebase Core dan Firebase Auth untuk sistem login/registrasi pengguna.
*   **Kendala:** Terjadi *dependency conflict* antara versi Firebase Core dengan SDK Flutter terinstal.
*   **Solusi:** Menyelesaikan konflik dependensi dengan menyesuaikan konfigurasi Gradle dan mengunci versi paket stabil di `pubspec.yaml`.
*   **Rencana Minggu Depan:** Membuat modul autentikasi (Login, Register, Splash Screen) lengkap dengan validasi form input.

---

## MINGGU 7: Implementasi Autentikasi & Dynamic Routing
*   **Progress Minggu Ini:**
    *   Membangun halaman Login dan Signup dengan form validation (validasi email kosong, password kurang dari 6 karakter).
    *   Membuat halaman Splash Screen yang mendeteksi session aktif: jika pengguna sudah login sebelumnya, aplikasi langsung mengarahkan ke halaman Beranda (*auto-login*).
    *   Mengimplementasikan dynamic routing dan named routes di berkas `main.dart`.
*   **Kendala:** Menghubungkan role user (Pembeli, Pedagang, Admin) dari Firestore saat proses registrasi.
*   **Solusi:** Membuat koleksi `users` di Cloud Firestore yang menyimpan detail akun termasuk string `role`, lalu menggunakannya sebagai rujukan rute beranda setelah login sukses.
*   **Rencana Minggu Depan:** Membangun Dashboard Admin dan fitur CRUD (Create, Read, Update, Delete) data Kantin global.

---

## MINGGU 8: Progress Review (Evaluasi Tahap 1)
*   **Progress Minggu Ini:**
    *   Membangun **Dashboard Admin Premium** lengkap dengan filter pencarian real-time.
    *   Mengimplementasikan fungsi CRUD Kantin secara penuh di database Firestore langsung dari layar Admin.
    *   Mempersiapkan demonstrasi kemajuan tahap 1 di hadapan dosen pengampu (menunjukkan login multi-role dan CRUD admin).
*   **Kendala:** Melakukan perubahan data kantin secara real-time pada beranda pembeli tanpa perlu memuat ulang aplikasi.
*   **Solusi:** Mengganti pembacaan data satu kali (*FutureGet*) menggunakan stream data dinamis (*StreamBuilder*) agar sinkronisasi terjadi dalam hitungan milidetik secara otomatis.
*   **Rencana Minggu Depan:** Membangun halaman utama Pembeli (Beranda), bilah kategori interaktif, dan integrasi API cuaca eksternal.

---

## MINGGU 9: Integrasi API Cuaca Kampus & Fitur Beranda Pembeli
*   **Progress Minggu Ini:**
    *   Mendesain halaman Beranda Pembeli yang mewah dengan banner promo dinamis.
    *   Mengintegrasikan API cuaca kampus menggunakan `http` request untuk mendeteksi cuaca terkini dan menampilkan rekomendasi pemesanan makanan.
    *   Membangun menu filter kategori horizontal (Soto, Nasi, Ayam, Minuman, Snack, Seafood).
*   **Kendala:** Data cuaca terkadang lambat dimuat jika koneksi internet tidak stabil.
*   **Solusi:** Menambahkan widget *shimmer/loading indicator* dan melengkapi penanganan error (*try-catch*) agar aplikasi tidak mengalami crash saat API down.
*   **Rencana Minggu Depan:** Mengimplementasikan State Management Provider untuk sistem keranjang belanja (*shopping cart*) real-time.

---

## MINGGU 10: State Management Provider & Keranjang Belanja
*   **Progress Minggu Ini:**
    *   Membuat berkas `cart_provider.dart` menggunakan paket `provider` untuk mengelola data keranjang belanja secara global.
    *   Membangun halaman Detail Kantin yang menampilkan daftar menu dinamis ditarik dari Firestore.
    *   Menghubungkan tombol tambah/kurang item menu dengan Provider sehingga jumlah barang dan harga terupdate otomatis di seluruh layar aplikasi.
*   **Kendala:** Mengatur agar badge notifikasi jumlah barang di bawah navigasi bar ikut terupdate secara instan.
*   **Solusi:** Membungkus widget Bottom Navigation Bar dengan `Consumer<CartProvider>` agar secara reaktif merender ulang badge saat ada perubahan item.
*   **Rencana Minggu Depan:** Merancang layar Checkout Premium lengkap dengan kalkulasi biaya dan pilihan metode pembayaran.

---

## MINGGU 11: Implementasi Checkout & Algoritma Antrean
*   **Progress Minggu Ini:**
    *   Membangun halaman Checkout yang menyajikan rincian biaya transparan (Subtotal, Pajak, Biaya Layanan, Total Akhir).
    *   Menambahkan input catatan kustom untuk pedagang dan selektor metode pembayaran interaktif (QRIS / Tunai).
    *   Membuat mekanisme pembuatan nomor antrean unik otomatis setiap kali transaksi berhasil dibuat.
*   **Kendala:** Mengunci input catatan agar tidak dikirim dalam kondisi kosong atau berkarakter tidak valid.
*   **Solusi:** Menerapkan validasi regex dasar pada kolom input catatan sebelum transaksi diproses ke Firestore.
*   **Rencana Minggu Depan:** Membangun Dashboard khusus untuk Pedagang (Merchant) guna memproses pesanan masuk secara real-time.

---

## MINGGU 12: Dashboard Pedagang & Pelacakan Transaksi Real-time
*   **Progress Minggu Ini:**
    *   Membangun **Dashboard Pedagang (Merchant)** yang menampilkan daftar pesanan masuk berdasarkan antrean real-time dari Firestore.
    *   Mengimplementasikan perubahan status pesanan dinamis oleh pedagang (Diproses -> Siap Diambil -> Selesai).
    *   Membangun halaman Pelacakan Status Pesanan bagi pembeli yang terhubung langsung secara real-time menggunakan Cloud Firestore Stream.
*   **Kendala:** Membedakan pesanan masuk berdasarkan kantin masing-masing pedagang agar pedagang tidak melihat pesanan dari kantin lain.
*   **Solusi:** Melakukan query penapisan (*filtering*) pesanan di Firestore menggunakan `kantinId` unik yang terikat pada akun profil pedagang.
*   **Rencana Minggu Depan:** Membangun fitur CRUD Menu Makanan secara mandiri bagi pedagang agar dapat memperbarui menu mereka sendiri.

---

## MINGGU 13: CRUD Menu Pedagang & Ulasan Rating
*   **Progress Minggu Ini:**
    *   Menyelesaikan fitur CRUD Menu Makanan bagi Pedagang (menambah menu baru, memperbarui harga/stok, mengubah status ketersediaan, serta menghapus menu).
    *   Membangun sistem pemberian ulasan (rating bintang dan komentar tertulis) oleh pembeli setelah pesanan selesai.
    *   Mekanisme pembaruan otomatis rating rata-rata kantin di Firestore saat ulasan baru masuk.
*   **Kendala:** Formula kalkulasi rating rata-rata dapat menghasilkan angka desimal yang terlalu panjang di database.
*   **Solusi:** Menerapkan fungsi pembulatan angka desimal (*double.parse(value.toStringAsFixed(1))*) sebelum menyimpannya kembali ke database.
*   **Rencana Minggu Depan:** Mengaktifkan sistem Auto-Seeding database untuk mempermudah demonstrasi aplikasi serta merapikan visual dan navigasi.

---

## MINGGU 14: Pembersihan Database, Perbaikan Bug, & Layout Sidebar
*   **Progress Minggu Ini:**
    *   Mengembangkan sistem **Collapsible Sidebar Widget** pada layar lebar agar aplikasi responsif dan konsisten saat diuji di layar desktop oleh dosen.
    *   Membuat fitur deteksi aset usang di `seedInitialData()` agar jika ada pembaruan gambar menu di masa mendatang, database akan terupdate otomatis secara bersih.
    *   Menghapus berkas duplikat yang tidak terpakai guna merapikan struktur file project.
*   **Kendala:** Ditemukan *bottom overflow error* pada layout sidebar saat dijalankan di layar berukuran sempit.
*   **Solusi:** Membungkus widget sidebar dalam `SingleChildScrollView` and menambahkan logika responsif untuk mengubah teks menu menjadi ikon saja saat lebar layar kurang dari 750 piksel.
*   **Rencana Minggu Depan:** Melakukan Widget Testing komprehensif dan uji kestabilan fungsional (*smoke testing*) aplikasi.

---

## MINGGU 15: Widget Testing, Bug Fixing, & Finalisasi Build (APK)
*   **Progress Minggu Ini:**
    *   Menulis uji terautomasi (*Widget Testing*) untuk memverifikasi alur halaman Onboarding dan login tanpa bug.
    *   Memperbaiki tombol "Lihat Semua" di bagian terpopuler beranda pembeli agar secara interaktif menyaring 3 kantin terbaik berdasarkan rating tertinggi dan melakukan *smooth scrolling* otomatis.
    *   Melakukan build file produksi Android (**APK**) menggunakan perintah `flutter build apk --release`.
*   **Kendala:** Ukuran file APK awal terlalu besar karena menyertakan aset gambar resolusi tinggi yang belum terkompresi.
*   **Solusi:** Melakukan kompresi aset gambar di folder `images/` dan menjalankan pembersihan build cache menggunakan `flutter clean` sebelum melakukan build ulang.
*   **Rencana Minggu Depan:** Mempersiapkan file presentasi, video demo berdurasi kurang dari 5 menit, dan melakukan latihan demo live coding.

---

## MINGGU 16: Evaluasi Akhir & Presentasi Proyek UAS
*   **Progress Minggu Ini:**
    *   Menyusun laporan akhir proyek secara sistematis berisi arsitektur sistem, skema database, dan panduan penggunaan.
    *   Mengunggah seluruh kode sumber terbaru ke repositori Git kampus.
    *   Menjalankan presentasi final di depan tim dosen pengampu, mendemonstrasikan integrasi multi-role real-time secara langsung (*live demo*), dan menjawab pertanyaan teknis seputar arsitektur kode dengan sukses.
*   **Kendala:** Tidak ada kendala berarti karena semua persiapan teknis, uji widget, dan dokumen pendukung sudah siap secara matang.
*   **Solusi:** Presentasi berjalan lancar dan seluruh fitur utama berfungsi dengan sempurna tanpa crash.
