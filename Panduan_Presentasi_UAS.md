
## BAGIAN 1: PERTANYAAN ARSITEKTUR KODE & STRUKTUR FILE

### Pertanyaan 1: "Mengapa Anda menggunakan arsitektur folder seperti ini? Jelaskan pembagiannya!"
*   **Jawaban Cerdas:**  
    "Kami menerapkan arsitektur modular yang memisahkan tanggung jawab (*Separation of Concerns*) agar kode bersifat bersih, terukur (*scalable*), dan mudah dirawat:
    1.  **`lib/pages/` (Presentation Layer):** Khusus menyimpan file antarmuka (View) seperti form login, dashboard admin, pedagang, dan pembeli.
    2.  **`lib/services/` (Data/Backend Layer):** Menampung `firestore_service.dart` sebagai repositori backend tunggal yang berkomunikasi langsung dengan API Firebase dan cuaca.
    3.  **`lib/theme/` (Design System):** Menyimpan sistem pewarnaan premium (`app_colors.dart`) agar konsistensi warna visual tetap terjaga di semua halaman.
    4.  **`cart_provider.dart` (State Management):** Mengatur state global keranjang belanja yang terpisah dari widget UI."

### Pertanyaan 2: "Mengapa Anda memilih Provider sebagai State Management?"
*   **Jawaban Cerdas:**  
    "Kami memilih **Provider** karena merupakan state management resmi yang direkomendasikan oleh tim Flutter. Provider menggunakan mekanisme *InheritedWidget* secara efisien di belakang layar.
    Keunggulannya dibanding `setState` biasa:
    - Mencegah render ulang seluruh halaman (*re-rendering waste*) saat item keranjang bertambah. Hanya widget terkecil seperti badge keranjang saja yang merender ulang menggunakan `Consumer`.
    - Logika perhitungan belanja (subtotal, pajak, biaya layanan) terpisah secara bersih dari berkas UI halaman belanja."

---

## BAGIAN 2: PENJELASAN INTEGRASI DATABASE & REAL-TIME API

### 💬 Pertanyaan 3: "Bagaimana cara kerja sinkronisasi data real-time di aplikasi ini?"
*   **Jawaban Cerdas:**  
    "Kami memanfaatkan fitur **Streams** (`snapshots()`) yang disediakan oleh Cloud Firestore SDK di `firestore_service.dart`. 
    - Saat pedagang mengubah status pesanan (contoh: dari *Diproses* menjadi *Siap Diambil*), Firestore akan mengirimkan data perubahan tersebut melalui *websocket* secara langsung.
    - Halaman Pelacakan di sisi pembeli menggunakan widget `StreamBuilder` untuk menangkap aliran data (*stream*) tersebut dan memperbarui antarmuka dalam hitungan milidetik secara reaktif tanpa perlu reload aplikasi."

### 💬 Pertanyaan 4: "Jelaskan bagaimana sistem Auto-Seeding database Anda bekerja!"
*   **Jawaban Cerdas:**  
    "Saat aplikasi pertama kali diluncurkan (`main.dart`), fungsi `seedInitialData()` di `firestore_service.dart` akan berjalan secara otomatis.
    - Sistem akan mengecek apakah koleksi `'kantin'` di database Firestore sudah terisi.
    - Jika kosong, sistem otomatis membuat **8 data kantin mahasiswa** beserta puluhan menu makanan-minuman secara dinamis lengkap dengan harga, deskripsi, rating, dan asset gambarnya yang lezat.
    - Jika database sudah terisi, sistem akan langsung melewati proses ini agar menghemat kuota jaringan dan mempercepat loading aplikasi."

### 💬 Pertanyaan 5: "Bagaimana integrasi API Cuaca Kampus Anda bekerja?"
*   **Jawaban Cerdas:**  
    "Kami memanggil API Cuaca secara dinamis di `WeatherService` menggunakan paket `http`. Data cuaca terkini yang didapat kemudian kami olah untuk memberikan rekomendasi cerdas di beranda pembeli secara reaktif. Jika cuaca dingin atau hujan, aplikasi otomatis merekomendasikan menu berkuah hangat seperti Soto."

---

## 💻 BAGIAN 3: JIKA DOSEN MEMINTA LIVE CODING / DEMO KODE

Berikut adalah letak-letak kode penting di proyek Anda yang biasanya ingin dilihat oleh dosen saat presentasi:

1.  **Di mana letak pemicu scroll otomatis dan filter rating tertinggi di halaman beranda?**
    - Buka berkas [home.dart](file:///C:/FoodTrack/foodtruck/lib/pages/home.dart#L578-L617). Tunjukkan tombol `GestureDetector` pada "Lihat Semua" yang memicu fungsi `setState()` untuk mengaktifkan filter `_showOnlyTopCanteens = true` dan memanggil `_scrollToSemuaKantin()` menggunakan `ScrollController` dan `GlobalKey` secara halus.
2.  **Di mana logika validasi registrasi role user baru disimpan?**
    - Buka berkas [signup.dart](file:///C:/FoodTrack/foodtruck/lib/pages/signup.dart#L240-L290). Tunjukkan selektor dropdown role (Pembeli / Pedagang) yang jika dipilih sebagai pedagang akan meminta input nama kantin baru, kemudian menyimpannya ke koleksi `users` di Firestore.
3.  **Di mana logika CRUD Menu Pedagang dideklarasikan?**
    - Buka berkas [menu_pedagang_page.dart](file:///C:/FoodTrack/foodtruck/lib/pages/pedagang/menu_pedagang_page.dart#L22-L130). Tunjukkan fungsi `_showForm` yang membuka sheet bawah (*bottom sheet*) untuk menambah atau mengedit menu serta menyimpannya langsung ke koleksi `'menu'` di Firestore.
4.  **Di mana letak kode Auto-Seeder database Firestore?**
    - Buka berkas [firestore_service.dart](file:///C:/FoodTrack/foodtruck/lib/services/firestore_service.dart#L518-L720). Tunjukkan metode `seedInitialData()` yang mendeteksi data usang (`images/ayam_kremes.png` pada Bakso) dan otomatis melakukan pembersihan serta re-seed database secara bersih.

---

> 🎯 **Tips Sukses Presentasi:**  
> Jelaskan kode dengan tenang dan percaya diri. Tekankan kata-kata kunci seperti **"Real-time Websocket Streams"**, **"Responsive Multi-Role Dashboard"**, **"Clean Architecture"**, dan **"Reactive State Management"**. Selamat berjuang, nilai A sudah di tangan Anda!
