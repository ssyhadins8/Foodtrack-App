# Logbook Mingguan Mahasiswa
* **Mata Kuliah:** Pemrograman Mobile
* **Skema Pengerjaan:** Skema A (1 Project Besar - Minggu 4 s/d 16)
* **Nama Project:** FoodTrack

---

## Minggu 4: Penentuan Ide dan Persetujuan Dosen
* **Kemajuan Pekerjaan:**
  * Melakukan survei awal terkait penumpukan antrean fisik pada kantin kampus.
  * Merumuskan konsep dasar aplikasi pemesanan makanan berbasis metode Self-Pickup.
  * Menyusun skema pembagian peran pengguna (Pembeli, Pedagang, dan Admin).
* **Kendala:** Menentukan batasan fungsionalitas agar proyek dapat diselesaikan tepat waktu namun tetap memenuhi standar akademis.
* **Solusi:** Membatasi fitur pada manajemen menu, pelacakan status transaksi real-time, dan dashboard administrasi global tanpa sistem kurir pengantaran.
* **Rencana Kerja Selanjutnya:** Menyusun dokumen proposal awal dan membuat rancangan kawat (wireframe) antarmuka.

---

## Minggu 5: Proposal dan Desain UI/UX
* **Kemajuan Pekerjaan:**
  * Menyusun dokumen proposal berisi latar belakang masalah, arsitektur sistem, dan target pengerjaan proyek.
  * Membuat desain mockup antarmuka pengguna dengan sistem pewarnaan terpadu agar tampilan konsisten.
  * Merancang diagram alir transaksi (sequence diagram) untuk integrasi data multi-role.
* **Kendala:** Menyelaraskan tata letak antarmuka agar tetap proporsional pada berbagai rasio layar perangkat Android.
* **Solusi:** Menggunakan tata letak responsif menggunakan persentase padding dinamis serta memanfaatkan widget SafeArea.
* **Rencana Kerja Selanjutnya:** Inisialisasi struktur direktori proyek Flutter, pembuatan repositori Git, dan konfigurasi awal Firebase SDK.

---

## Minggu 6: Inisialisasi Proyek dan Integrasi Firebase
* **Kemajuan Pekerjaan:**
  * Membuat repositori Git lokal dan melakukan inisialisasi proyek Flutter baru.
  * Mengatur struktur direktori proyek: pages, services, theme, dan models.
  * Mengintegrasikan pustaka Firebase Core dan Firebase Auth ke dalam file konfigurasi proyek.
* **Kendala:** Terjadi ketidaksesuaian versi pustaka Firebase dengan versi Gradle yang terpasang pada modul Android.
* **Solusi:** Menyesuaikan konfigurasi file build.gradle dan menyelaraskan versi dependensi pada berkas pubspec.yaml.
* **Rencana Kerja Selanjutnya:** Membangun modul autentikasi awal (Login dan Signup) lengkap dengan validasi form masukan.

---

## Minggu 7: Implementasi Autentikasi dan Sistem Rute Dinamis
* **Kemajuan Pekerjaan:**
  * Membangun halaman login dan registrasi dengan validasi input (pengecekan format email dan minimal panjang kata sandi).
  * Membuat modul splash screen yang mendeteksi session login aktif untuk memfasilitasi auto-login.
  * Mengimplementasikan named routes pada berkas main.dart untuk mempermudah navigasi.
* **Kendala:** Menghubungkan pembacaan role pengguna (Pembeli/Pedagang/Admin) sesaat setelah login berhasil dilakukan.
* **Solusi:** Menyimpan tipe role pengguna di dalam dokumen koleksi users di Cloud Firestore, lalu membacanya untuk menentukan rute halaman beranda yang sesuai.
* **Rencana Kerja Selanjutnya:** Membangun Dashboard Admin dan fungsi CRUD (Create, Read, Update, Delete) data kantin secara global.

---

## Minggu 8: Review Kemajuan Proyek (Evaluasi Tahap 1)
* **Kemajuan Pekerjaan:**
  * Menyelesaikan dashboard administrasi untuk melakukan CRUD data kantin global.
  * Menambahkan fitur filter pencarian real-time pada daftar kantin untuk sisi administrator.
  * Mempersiapkan berkas dan demonstrasi aplikasi untuk evaluasi tahap pertama oleh tim dosen pengampu.
* **Kendala:** Pembaruan data kantin yang dimodifikasi oleh admin tidak langsung tecermin di halaman pembeli tanpa memuat ulang aplikasi.
* **Solusi:** Mengubah metode pengambilan data sekali menggunakan Future menjadi langganan aliran data dinamis menggunakan StreamBuilder.
* **Rencana Kerja Selanjutnya:** Membangun beranda pembeli, bilah penyaringan kategori menu, dan integrasi API cuaca eksternal.

---

## Minggu 9: Integrasi API Cuaca dan Beranda Pembeli
* **Kemajuan Pekerjaan:**
  * Mendesain tata letak halaman beranda pembeli dengan banner promosi dan daftar kantin terpopuler.
  * Mengintegrasikan API cuaca eksternal (Open-Meteo) untuk menyajikan data temperatur terkini di lingkungan kampus.
  * Menyediakan fitur rekomendasi menu otomatis yang disesuaikan dengan kondisi suhu udara terkini.
* **Kendala:** Pemanggilan API cuaca dapat memakan waktu lama apabila koneksi internet lambat.
* **Solusi:** Menambahkan indikator pemuatan data dan menggunakan blok try-catch untuk mencegah crash ketika API tidak merespons.
* **Rencana Kerja Selanjutnya:** Mengimplementasikan State Management Provider untuk sistem pengelolaan keranjang belanja.

---

## Minggu 10: State Management Provider dan Keranjang Belanja
* **Kemajuan Pekerjaan:**
  * Membuat berkas cart_provider.dart menggunakan paket provider sebagai manajemen state terpusat.
  * Menyusun halaman detail kantin yang memuat daftar menu dinamis dari Firestore.
  * Menghubungkan tombol tambah dan kurang item menu dengan Provider agar kalkulasi harga total berjalan secara otomatis.
* **Kendala:** Pembaruan indikator jumlah item pada ikon keranjang belanja tidak berubah secara instan.
* **Solusi:** Membungkus widget keranjang belanja menggunakan Consumer dari Provider agar melakukan render ulang secara reaktif.
* **Rencana Kerja Selanjutnya:** Mendesain halaman checkout pesanan lengkap dengan rincian biaya transaksi.

---

## Minggu 11: Implementasi Checkout dan Perhitungan Antrean
* **Kemajuan Pekerjaan:**
  * Membangun halaman checkout yang menyajikan transparansi biaya (subtotal, biaya layanan, pajak, dan total akhir).
  * Menambahkan fitur input catatan pesanan untuk pedagang serta selektor metode pembayaran (Tunai atau QRIS).
  * Mengimplementasikan generator nomor antrean transaksi yang unik saat pesanan berhasil disimpan.
* **Kendala:** Membatasi panjang teks catatan pembeli agar tidak mengganggu tata letak dokumen pesanan.
* **Solusi:** Menambahkan batas maksimal karakter pada kolom input catatan sebelum data dikirim ke Firestore.
* **Rencana Kerja Selanjutnya:** Membangun dashboard pedagang untuk memproses transaksi masuk secara real-time.

---

## Minggu 12: Dashboard Pedagang dan Pelacakan Pesanan Real-time
* **Kemajuan Pekerjaan:**
  * Menyelesaikan dashboard pedagang yang memuat pesanan aktif berdasarkan urutan nomor antrean.
  * Menambahkan fungsi pembaruan status pengerjaan makanan oleh pedagang (Diproses -> Siap Diambil).
  * Membangun halaman pelacakan status pesanan real-time untuk sisi pembeli menggunakan Firestore Streams.
* **Kendala:** Pedagang dapat melihat pesanan yang masuk ke kantin lain apabila query tidak dibatasi.
* **Solusi:** Menerapkan filter query berdasarkan parameter kantinId yang terasosiasi dengan akun masuk pedagang.
* **Rencana Kerja Selanjutnya:** Menyusun fitur pengelolaan menu makanan secara mandiri untuk masing-masing pedagang.

---

## Minggu 13: Pengelolaan Menu Pedagang dan Sistem Ulasan
* **Kemajuan Pekerjaan:**
  * Membangun halaman manajemen menu bagi pedagang untuk menambah, mengubah harga/stok, dan menghapus menu makanan.
  * Mengimplementasikan fitur pemberian ulasan (rating bintang dan komentar tertulis) oleh pembeli setelah pesanan selesai.
  * Menyusun fungsi kalkulasi otomatis rating rata-rata kantin di Firestore saat ulasan baru tersimpan.
* **Kendala:** Perhitungan desimal rating rata-rata menghasilkan deret desimal yang terlalu panjang di Firestore.
* **Solusi:** Menerapkan pembulatan desimal menggunakan fungsi toStringAsFixed(1) sebelum memperbarui dokumen kantin.
* **Rencana Kerja Selanjutnya:** Mengaktifkan inisialisasi data otomatis (database seeder) dan merapikan komponen antarmuka.

---

## Minggu 14: Perbaikan Bug Antarmuka dan Optimasi Tata Letak
* **Kemajuan Pekerjaan:**
  * Menambahkan Collapsible Sidebar Navigation pada admin dashboard saat aplikasi dijalankan pada layar tablet/desktop.
  * Memperbaiki bug bottom overflow pada halaman detail pesanan dengan menyesuaikan batas tinggi SliverAppBar.
  * Menghapus beberapa berkas kode program cadangan yang sudah tidak digunakan untuk merapikan struktur file.
* **Kendala:** Pilihan tipe diskon pada form promo pedagang mengalami overflow horizontal pada perangkat mobile dengan layar sempit.
* **Solusi:** Mengubah struktur tata letak baris (Row) menjadi Wrap agar ChoiceChips tersusun secara responsif ke bawah.
* **Rencana Kerja Selanjutnya:** Melakukan pengujian widget terautomasi dan penyusunan berkas rilis aplikasi.

---

## Minggu 15: Widget Testing, Finalisasi Bug, dan Pembuatan APK
* **Kemajuan Pekerjaan:**
  * Menulis berkas pengujian unit/widget pada test/widget_test.dart untuk memverifikasi alur halaman onboarding.
  * Melakukan build versi produksi aplikasi ke dalam format APK Android menggunakan perintah flutter build apk --release.
  * Memperbaiki navigasi tombol lihat semua beranda pembeli agar menyaring kantin dengan rating terbaik secara interaktif.
* **Kendala:** Ukuran file APK terdeteksi terlalu besar karena aset gambar resolusi tinggi belum dikompresi.
* **Solusi:** Melakukan kompresi terhadap aset gambar pada direktori images/ sebelum proses kompilasi rilis dijalankan.
* **Rencana Kerja Selanjutnya:** Menyiapkan laporan akhir, materi presentasi, dan video demonstrasi sistem.

---

## Minggu 16: Evaluasi Akhir Proyek UAS
* **Kemajuan Pekerjaan:**
  * Menyusun laporan akhir proyek secara sistematis berisi diagram sistem, skema database, dan panduan pemasangan.
  * Mengunggah seluruh kode sumber terbaru ke repositori Git yang ditentukan.
  * Melakukan presentasi final dan demonstrasi integrasi transaksi multi-role di hadapan tim dosen pengampu.
* **Kendala:** Tidak ada kendala teknis yang dihadapi selama evaluasi akhir karena persiapan sudah dilakukan secara menyeluruh.
* **Solusi:** Proyek dinilai berjalan dengan stabil dan seluruh fungsionalitas utama terbukti terintegrasi secara real-time.
