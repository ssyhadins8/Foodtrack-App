import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodtrack/cart_provider.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? get _uid => _auth.currentUser?.uid;

  // =========================================================
  // SIMPAN USER BARU
  // =========================================================
  static Future<void> simpanUserBaru({
    required String email,
    required String nama,
    required String role,
    String namaKantin = '', // ✅ Fix: tambah parameter
    String kantinId = '', // ✅ Fix: tambah parameter
  }) async {
    try {
      if (_uid == null) {
        throw Exception('User belum login');
      }

      await _db.collection('users').doc(_uid).set({
        'uid': _uid,
        'email': email,
        'nama': nama,
        'role': role,
        'namaKantin': namaKantin, // ✅ Fix: simpan ke Firestore
        'kantinId': kantinId, // ✅ Fix: simpan ke Firestore
        'fotoProfil': '',
        'prodi': '',
        'nim': '',
        'noHp': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('simpanUserBaru error: $e');
      rethrow;
    }
  }

  // =========================================================
  // UPDATE PROFIL USER
  // =========================================================
  static Future<void> updateProfil({
    required String nama,
    required String prodi,
    required String nim,
    required String noHp,
    required String role,
  }) async {
    try {
      if (_uid == null) {
        throw Exception('User belum login');
      }

      await _db.collection('users').doc(_uid).update({
        'nama': nama,
        'prodi': prodi,
        'nim': nim,
        'noHp': noHp,
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('updateProfil error: $e');
      rethrow;
    }
  }

  // =========================================================
  // AMBIL DATA USER
  // =========================================================
  static Stream<DocumentSnapshot<Map<String, dynamic>>> streamUser() {
    if (_uid == null) {
      throw Exception('User belum login');
    }

    return _db.collection('users').doc(_uid).snapshots();
  }

  // =========================================================
  // SIMPAN PESANAN
  // ✅ return String (docId Firestore) untuk navigasi ke StatusPesananPage
  // =========================================================
  static Future<String> simpanPesanan({
    required List<CartItem> items,
    required String metode,
    required String kantin,
    required int totalHarga,
    required int noAntrian,
    String catatan = '',
  }) async {
    try {
      String pembeliNama = 'Pembeli';
      String pembeliEmail = '';
      if (_uid != null) {
        final userDoc = await _db.collection('users').doc(_uid).get();
        if (userDoc.exists) {
          pembeliNama = userDoc.data()?['nama'] ?? 'Pembeli';
          pembeliEmail = userDoc.data()?['email'] ?? '';
        }
      }

      final docRef = await _db.collection('pesanan').add({
        'uid': _uid,
        'pembeliNama': pembeliNama,
        'pembeliEmail': pembeliEmail,
        'kantin': kantin,
        'metode': metode,
        'catatan': catatan,
        'totalHarga': totalHarga,
        'noAntrian': noAntrian,
        'statusIndex': 0,
        'items': items
            .map(
              (e) => {
                'nama': e.nama,
                'gambar': e.gambar,
                'harga': e.harga,
                'qty': e.qty,
                'kantin': e.kantin,
              },
            )
            .toList(),
        'waktuPesan': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      debugPrint('simpanPesanan error: $e');
      rethrow;
    }
  }

  // =========================================================
  // UPDATE STATUS PESANAN
  // =========================================================
  static Future<void> updateStatusPesanan({
    required int noAntrian,
    required int statusIndex,
  }) async {
    try {
      final snap = await _db
          .collection('pesanan')
          .where('noAntrian', isEqualTo: noAntrian)
          .where('uid', isEqualTo: _uid)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.update({
          'statusIndex': statusIndex,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('updateStatusPesanan error: $e');
      rethrow;
    }
  }

  // =========================================================
  // STREAM RIWAYAT PESANAN USER
  // =========================================================
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamRiwayatPesanan() {
    return _db
        .collection('pesanan')
        .where('uid', isEqualTo: _uid)
        .orderBy('waktuPesan', descending: true)
        .snapshots();
  }

  // =========================================================
  // STREAM PESANAN PEDAGANG
  // =========================================================
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamPesananPedagang(
    String namaKantin,
  ) {
    return _db
        .collection('pesanan')
        .where('kantin', isEqualTo: namaKantin)
        .orderBy('waktuPesan', descending: true)
        .snapshots();
  }

  // =========================================================
  // [ADMIN] STREAM SEMUA PESANAN
  // =========================================================
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamSemuaPesanan() {
    return _db
        .collection('pesanan')
        .orderBy('waktuPesan', descending: true)
        .snapshots();
  }

  // =========================================================
  // [ADMIN] STREAM SEMUA USER
  // =========================================================
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamSemuaUser() {
    return _db.collection('users').snapshots();
  }

  // =========================================================
  // SIMPAN NOTIFIKASI
  // =========================================================
  static Future<void> simpanNotifikasi({
    required String judul,
    required String pesan,
    required String tipe,
    required String icon,
    String? targetUid, // ✅ Tambahkan targetUid agar pedagang bisa kirim notif ke user
    String? pesananId,
  }) async {
    try {
      final uid = targetUid ?? _uid;
      if (uid == null) return;

      await _db.collection('notifikasi').add({
        'uid': uid,
        'judul': judul,
        'pesan': pesan,
        'tipe': tipe,
        'icon': icon,
        'pesananId': pesananId,
        'dibaca': false,
        'waktu': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('simpanNotifikasi error: $e');
      rethrow;
    }
  }

  // =========================================================
  // STREAM NOTIFIKASI USER
  // =========================================================
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamNotifikasi() {
    return _db
        .collection('notifikasi')
        .where('uid', isEqualTo: _uid)
        .orderBy('waktu', descending: true)
        .snapshots();
  }

  // =========================================================
  // TANDAI NOTIFIKASI SUDAH DIBACA
  // =========================================================
  static Future<void> tandaiDibaca(String docId) async {
    try {
      await _db.collection('notifikasi').doc(docId).update({
        'dibaca': true,
      });
    } catch (e) {
      debugPrint('tandaiDibaca error: $e');
    }
  }

  // =========================================================
  // HAPUS NOTIFIKASI
  // =========================================================
  static Future<void> hapusNotifikasi(String docId) async {
    try {
      await _db.collection('notifikasi').doc(docId).delete();
    } catch (e) {
      debugPrint('hapusNotifikasi error: $e');
    }
  }

  // =========================================================
  // GET DATA USER
  // =========================================================
  static Future<DocumentSnapshot<Map<String, dynamic>>> getUserData() async {
    if (_uid == null) {
      throw Exception('User belum login');
    }

    return await _db.collection('users').doc(_uid).get();
  }

  // =========================================================
  // CEK ROLE USER
  // =========================================================
  static Future<String> getRoleUser() async {
    try {
      final doc = await _db.collection('users').doc(_uid).get();

      if (doc.exists) {
        return doc.data()?['role'] ?? 'pembeli';
      }

      return 'pembeli';
    } catch (e) {
      debugPrint('getRoleUser error: $e');
      return 'pembeli';
    }
  }

  // =========================================================
  // UPDATE FOTO PROFIL
  // =========================================================
  // =========================================================
  // TOGGLE FAVORITE MENU
  // =========================================================
  static Future<void> toggleFavorite({
    required String nama,
    required String kantin,
    required String gambar,
    required int harga,
  }) async {
    try {
      if (_uid == null) return;

      final favId = '${_uid}_${kantin}_$nama'.replaceAll(' ', '_');
      final doc = _db.collection('favorites').doc(favId);
      final snap = await doc.get();

      if (snap.exists) {
        await doc.delete();
      } else {
        await doc.set({
          'uid': _uid,
          'nama': nama,
          'kantin': kantin,
          'gambar': gambar,
          'harga': harga,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('toggleFavorite error: $e');
    }
  }

  // =========================================================
  // STREAM FAVORITES
  // =========================================================
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamFavorites() {
    return _db
        .collection('favorites')
        .where('uid', isEqualTo: _uid)
        .snapshots();
  }

  // =========================================================
  // LOGOUT
  // =========================================================
  static Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('logout error: $e');
    }
  }

  // =========================================================
  // STREAM SEMUA KANTIN
  // =========================================================
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamKantin() {
    return _db.collection('kantin').snapshots();
  }

  // =========================================================
  // CRUD KANTIN (ADMIN)
  // =========================================================
  static Future<void> tambahKantin({
    required String nama,
    required String deskripsi,
    required String kategori,
    required String gambar,
    double rating = 4.5,
    bool isTop = false,
    String waktu = '10-15 mnt',
    int totalMenu = 0,
  }) async {
    try {
      await _db.collection('kantin').add({
        'nama': nama,
        'deskripsi': deskripsi,
        'kategori': kategori,
        'gambar': gambar,
        'rating': rating,
        'isTop': isTop,
        'waktu': waktu,
        'totalMenu': totalMenu,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('tambahKantin error: $e');
      rethrow;
    }
  }

  static Future<void> updateKantin({
    required String id,
    required String nama,
    required String deskripsi,
    required String kategori,
    required String gambar,
    required double rating,
    required bool isTop,
    required String waktu,
    required int totalMenu,
  }) async {
    try {
      await _db.collection('kantin').doc(id).update({
        'nama': nama,
        'deskripsi': deskripsi,
        'kategori': kategori,
        'gambar': gambar,
        'rating': rating,
        'isTop': isTop,
        'waktu': waktu,
        'totalMenu': totalMenu,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('updateKantin error: $e');
      rethrow;
    }
  }

  static Future<void> hapusKantin(String id) async {
    try {
      await _db.collection('kantin').doc(id).delete();
    } catch (e) {
      debugPrint('hapusKantin error: $e');
      rethrow;
    }
  }

  // =========================================================
  // CRUD MENU (ADMIN)
  // =========================================================
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamSemuaMenu() {
    return _db.collection('menu').snapshots();
  }

  static Future<void> tambahMenu({
    required String nama,
    required int harga,
    required int stok,
    required String desc,
    required String kantin,
    required String kantinId,
    required bool tersedia,
    required String kategori,
    required String gambar,
  }) async {
    try {
      await _db.collection('menu').add({
        'nama': nama,
        'harga': harga,
        'stok': stok,
        'desc': desc,
        'kantin': kantin,
        'kantinId': kantinId,
        'tersedia': tersedia,
        'kategori': kategori,
        'gambar': gambar,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('tambahMenu error: $e');
      rethrow;
    }
  }

  static Future<void> updateMenu({
    required String id,
    required String nama,
    required int harga,
    required int stok,
    required String desc,
    required String kantin,
    required String kantinId,
    required bool tersedia,
    required String kategori,
    required String gambar,
  }) async {
    try {
      await _db.collection('menu').doc(id).update({
        'nama': nama,
        'harga': harga,
        'stok': stok,
        'desc': desc,
        'kantin': kantin,
        'kantinId': kantinId,
        'tersedia': tersedia,
        'kategori': kategori,
        'gambar': gambar,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('updateMenu error: $e');
      rethrow;
    }
  }

  static Future<void> hapusMenu(String id) async {
    try {
      await _db.collection('menu').doc(id).delete();
    } catch (e) {
      debugPrint('hapusMenu error: $e');
      rethrow;
    }
  }

  // =========================================================
  // DYNAMIC SEED INITIAL DATA
  // =========================================================
  static Future<void> seedInitialData() async {
    try {
      final snap = await _db.collection('kantin').limit(1).get();
      
      // Auto-cleanup detection: check if the existing database uses outdated placeholder images
      bool needReseed = false;
      if (snap.docs.isNotEmpty) {
        final testMenuSnap = await _db.collection('menu').where('nama', isEqualTo: 'Bakso Biasa').limit(1).get();
        if (testMenuSnap.docs.isNotEmpty) {
          final data = testMenuSnap.docs.first.data();
          if (data['gambar'] == 'images/ayam_kremes.png') {
            needReseed = true;
          }
        } else {
          needReseed = true;
        }
      } else {
        needReseed = true;
      }

      if (!needReseed) {
        debugPrint('Kantin and menu data already up-to-date. Skipping seed.');
        return;
      }

      debugPrint('Detected outdated menu assets. Clearing old canteen and menu data for clean re-seed...');
      
      // Delete old canteens
      final oldKantin = await _db.collection('kantin').get();
      for (var doc in oldKantin.docs) {
        await doc.reference.delete();
      }
      
      // Delete old menus
      final oldMenu = await _db.collection('menu').get();
      for (var doc in oldMenu.docs) {
        await doc.reference.delete();
      }

      debugPrint('Seeding updated canteens and menu items to Firestore...');
      
      final canteens = [
        {
          'id': 'kantin_1',
          'nama': 'Kantin Bu Sari',
          'deskripsi': 'Soto, Sup, & Aneka Gorengan',
          'kategori': 'Soto',
          'gambar': 'images/kantin1.jpg',
          'rating': 4.8,
          'isTop': true,
          'waktu': '15-20 mnt',
          'totalMenu': 5,
        },
        {
          'id': 'kantin_2',
          'nama': 'Kantin Pak Budi',
          'deskripsi': 'Nasi Campur & Lauk Pauk',
          'kategori': 'Nasi',
          'gambar': 'images/kantin2.jpg',
          'rating': 4.9,
          'isTop': true,
          'waktu': '10-15 mnt',
          'totalMenu': 5,
        },
        {
          'id': 'kantin_3',
          'nama': 'Kantin Geprek',
          'deskripsi': 'Ayam Geprek & Lalapan',
          'kategori': 'Ayam',
          'gambar': 'images/kantin3.jpeg',
          'rating': 4.7,
          'isTop': true,
          'waktu': '15-20 mnt',
          'totalMenu': 5,
        },
        {
          'id': 'kantin_4',
          'nama': 'Kantin Bakso Mas Jo',
          'deskripsi': 'Bakso & Mie Ayam',
          'kategori': 'Bakso',
          'gambar': 'images/kantin4.jpeg',
          'rating': 4.6,
          'isTop': false,
          'waktu': '10-15 mnt',
          'totalMenu': 5,
        },
        {
          'id': 'kantin_5',
          'nama': 'Kantin Minuman Segar',
          'deskripsi': 'Jus, Es, & Minuman',
          'kategori': 'Minuman',
          'gambar': 'images/kantin5.jpg',
          'rating': 4.5,
          'isTop': false,
          'waktu': '5-10 mnt',
          'totalMenu': 5,
        },
        {
          'id': 'kantin_6',
          'nama': 'Kantin Seafood Bu Tini',
          'deskripsi': 'Seafood Segar & Nasi',
          'kategori': 'Seafood',
          'gambar': 'images/kantin6.png',
          'rating': 4.7,
          'isTop': true,
          'waktu': '20-25 mnt',
          'totalMenu': 5,
        },
        {
          'id': 'kantin_7',
          'nama': 'Kantin Snack Corner',
          'deskripsi': 'Gorengan & Camilan',
          'kategori': 'Snack',
          'gambar': 'images/kantin7.jpeg',
          'rating': 4.4,
          'isTop': false,
          'waktu': '5-10 mnt',
          'totalMenu': 5,
        },
        {
          'id': 'kantin_8',
          'nama': 'Kantin Nasi Padang',
          'deskripsi': 'Masakan Padang Lezat',
          'kategori': 'Nasi',
          'gambar': 'images/kantin8.jpg',
          'rating': 4.9,
          'isTop': true,
          'waktu': '10-15 mnt',
          'totalMenu': 5,
        },
      ];

      for (var k in canteens) {
        final id = k['id'] as String;
        await _db.collection('kantin').doc(id).set({
          'nama': k['nama'],
          'deskripsi': k['deskripsi'],
          'kategori': k['kategori'],
          'gambar': k['gambar'],
          'rating': k['rating'],
          'isTop': k['isTop'],
          'waktu': k['waktu'],
          'totalMenu': k['totalMenu'],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      final menus = {
        'kantin_1': [
          {'nama': 'Soto Ayam', 'harga': 12000, 'gambar': 'images/soto_ayam.jpeg', 'kat': 'Soto', 'desc': 'Soto ayam hangat dengan kuah bening'},
          {'nama': 'Soto Daging', 'harga': 15000, 'gambar': 'images/soto_daging.jpeg', 'kat': 'Soto', 'desc': 'Soto daging sapi empuk'},
          {'nama': 'Es Teh', 'harga': 5000, 'gambar': 'images/es_teh.jpeg', 'kat': 'Minuman', 'desc': 'Es teh manis segar'},
          {'nama': 'Nasi Putih', 'harga': 4000, 'gambar': 'images/nasi_putih.jpeg', 'kat': 'Nasi', 'desc': 'Nasi putih hangat'},
          {'nama': 'Sup Bakso', 'harga': 13000, 'gambar': 'images/sup_bakso.jpeg', 'kat': 'Soto', 'desc': 'Sup bakso segar'},
        ],
        'kantin_2': [
          {'nama': 'Nasi Campur', 'harga': 15000, 'gambar': 'images/nasi_campur.jpeg', 'kat': 'Nasi', 'desc': 'Nasi campur lengkap'},
          {'nama': 'Nasi Goreng', 'harga': 13000, 'gambar': 'images/nasi_goreng.jpeg', 'kat': 'Nasi', 'desc': 'Nasi goreng spesial'},
          {'nama': 'Ayam Goreng', 'harga': 12000, 'gambar': 'images/ayam_goreng.png', 'kat': 'Ayam', 'desc': 'Ayam goreng renyah'},
          {'nama': 'Es Jeruk', 'harga': 6000, 'gambar': 'images/es_jeruk.jpeg', 'kat': 'Minuman', 'desc': 'Es jeruk segar'},
          {'nama': 'Tempe Goreng', 'harga': 3000, 'gambar': 'images/tempe_goreng.jpeg', 'kat': 'Snack', 'desc': 'Tempe goreng crispy'},
        ],
        'kantin_3': [
          {'nama': 'Ayam Geprek', 'harga': 15000, 'gambar': 'images/ayam_geprek.png', 'kat': 'Ayam', 'desc': 'Ayam geprek pedas'},
          {'nama': 'Ayam Penyet', 'harga': 14000, 'gambar': 'images/ayam_penyet.png', 'kat': 'Ayam', 'desc': 'Ayam penyet sambal'},
          {'nama': 'Nasi Putih', 'harga': 4000, 'gambar': 'images/nasi_putih.jpeg', 'kat': 'Nasi', 'desc': 'Nasi putih hangat'},
          {'nama': 'Es Teh', 'harga': 5000, 'gambar': 'images/es_teh.jpeg', 'kat': 'Minuman', 'desc': 'Es teh manis'},
          {'nama': 'Lalapan', 'harga': 3000, 'gambar': 'images/lalapan.jpg', 'kat': 'Snack', 'desc': 'Lalapan segar'},
        ],
        'kantin_4': [
          {'nama': 'Bakso Biasa', 'harga': 12000, 'gambar': 'images/Bakso Biasa.jpg', 'kat': 'Bakso', 'desc': 'Bakso kenyal lezat'},
          {'nama': 'Bakso Spesial', 'harga': 16000, 'gambar': 'images/Bakso Spesial.png', 'kat': 'Bakso', 'desc': 'Bakso urat + telur'},
          {'nama': 'Mie Ayam', 'harga': 13000, 'gambar': 'images/Mie Ayam.png', 'kat': 'Bakso', 'desc': 'Mie ayam topping lengkap'},
          {'nama': 'Es Campur', 'harga': 8000, 'gambar': 'images/Es Campur.jpg', 'kat': 'Minuman', 'desc': 'Es campur segar'},
          {'nama': 'Tahu Goreng', 'harga': 3000, 'gambar': 'images/Tahu Goreng.png', 'kat': 'Snack', 'desc': 'Tahu goreng crispy'},
        ],
        'kantin_5': [
          {'nama': 'Jus Alpukat', 'harga': 12000, 'gambar': 'images/Jus Alpukat.jpeg', 'kat': 'Minuman', 'desc': 'Jus alpukat creamy'},
          {'nama': 'Jus Mangga', 'harga': 10000, 'gambar': 'images/Jus Mangga.jpeg', 'kat': 'Minuman', 'desc': 'Jus mangga segar'},
          {'nama': 'Es Campur', 'harga': 8000, 'gambar': 'images/Es Campur.jpg', 'kat': 'Minuman', 'desc': 'Es campur komplit'},
          {'nama': 'Thai Tea', 'harga': 10000, 'gambar': 'images/Thai Tea.jpg', 'kat': 'Minuman', 'desc': 'Thai tea original'},
          {'nama': 'Kopi Susu', 'harga': 8000, 'gambar': 'images/Kopi Susu.jpg', 'kat': 'Minuman', 'desc': 'Kopi susu kekinian'},
        ],
        'kantin_6': [
          {'nama': 'Nasi Goreng Seafood', 'harga': 20000, 'gambar': 'images/Nasi Goreng Seafood.jpg', 'kat': 'Nasi', 'desc': 'Nasi goreng seafood komplit'},
          {'nama': 'Cumi Goreng', 'harga': 18000, 'gambar': 'images/Cumi Goreng.jpg', 'kat': 'Seafood', 'desc': 'Cumi goreng tepung'},
          {'nama': 'Udang Bakar', 'harga': 25000, 'gambar': 'images/Udang Bakar.jpeg', 'kat': 'Seafood', 'desc': 'Udang bakar bumbu'},
          {'nama': 'Ikan Bakar', 'harga': 22000, 'gambar': 'images/Ikan Bakar.JPG', 'kat': 'Seafood', 'desc': 'Ikan bakar kecap'},
          {'nama': 'Es Teh', 'harga': 5000, 'gambar': 'images/es_teh.jpeg', 'kat': 'Minuman', 'desc': 'Es teh manis'},
        ],
        'kantin_7': [
          {'nama': 'Gorengan Mix', 'harga': 5000, 'gambar': 'images/Gorengan Mix.jpg', 'kat': 'Snack', 'desc': 'Gorengan campur 5pcs'},
          {'nama': 'Pisang Goreng', 'harga': 8000, 'gambar': 'images/Pisang Goreng.jpg', 'kat': 'Snack', 'desc': 'Pisang goreng keju'},
          {'nama': 'Cireng', 'harga': 6000, 'gambar': 'images/Cireng.jpg', 'kat': 'Snack', 'desc': 'Cireng isi pedas'},
          {'nama': 'Martabak Mini', 'harga': 10000, 'gambar': 'images/Martabak Mini.jpeg', 'kat': 'Snack', 'desc': 'Martabak mini cokelat'},
          {'nama': 'Es Teh', 'harga': 5000, 'gambar': 'images/es_teh.jpeg', 'kat': 'Minuman', 'desc': 'Es teh manis'},
        ],
        'kantin_8': [
          {'nama': 'Nasi Padang', 'harga': 18000, 'gambar': 'images/Nasi Padang.jpg', 'kat': 'Nasi', 'desc': 'Nasi padang lengkap'},
          {'nama': 'Rendang', 'harga': 20000, 'gambar': 'images/Rendang.jpg', 'kat': 'Nasi', 'desc': 'Rendang daging empuk'},
          {'nama': 'Gulai Ayam', 'harga': 17000, 'gambar': 'images/Gulai Ayam.jpg', 'kat': 'Ayam', 'desc': 'Gulai ayam santan'},
          {'nama': 'Es Jeruk', 'harga': 6000, 'gambar': 'images/es_jeruk.jpeg', 'kat': 'Minuman', 'desc': 'Es jeruk segar'},
          {'nama': 'Kerupuk', 'harga': 2000, 'gambar': 'images/Kerupuk.jpg', 'kat': 'Snack', 'desc': 'Kerupuk renyah'},
        ],
      };

      for (var entry in menus.entries) {
        final kId = entry.key;
        final kName = canteens.firstWhere((element) => element['id'] == kId)['nama'] as String;
        for (var m in entry.value) {
          await _db.collection('menu').add({
            'nama': m['nama'],
            'harga': m['harga'],
            'stok': 20,
            'desc': m['desc'],
            'kantin': kName,
            'kantinId': kId,
            'tersedia': true,
            'kategori': m['kat'],
            'gambar': m['gambar'],
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
      
      debugPrint('Successfully seeded canteens and menu items.');
    } catch (e) {
      debugPrint('seedInitialData error: $e');
    }
  }

  // =========================================================
  // TAMBAH ULASAN & UPDATE RATING KANTIN
  // =========================================================
  static Future<void> tambahUlasan({
    required String pesananId,
    required String kantinNama,
    required double rating,
    required String komentar,
  }) async {
    try {
      if (_uid == null) throw Exception('User belum login');

      // 1. Ambil data pembeli
      final userDoc = await _db.collection('users').doc(_uid).get();
      final namaPembeli = userDoc.data()?['nama'] ?? 'Pembeli';

      // 2. Cari kantinId berdasarkan nama kantin
      final kantinSnap = await _db
          .collection('kantin')
          .where('nama', isEqualTo: kantinNama)
          .limit(1)
          .get();

      if (kantinSnap.docs.isEmpty) {
        throw Exception('Kantin dengan nama $kantinNama tidak ditemukan');
      }
      final kantinDoc = kantinSnap.docs.first;
      final kantinId = kantinDoc.id;

      // 3. Simpan ulasan ke koleksi 'ulasan'
      await _db.collection('ulasan').add({
        'uid': _uid,
        'namaPembeli': namaPembeli,
        'kantinId': kantinId,
        'kantinNama': kantinNama,
        'pesananId': pesananId,
        'rating': rating,
        'komentar': komentar,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 4. Update status pesanan: ulasanDiberikan = true
      await _db.collection('pesanan').doc(pesananId).update({
        'ulasanDiberikan': true,
      });

      // 5. Hitung ulang rating rata-rata kantin
      final ulasanSnap = await _db
          .collection('ulasan')
          .where('kantinId', isEqualTo: kantinId)
          .get();

      double totalRating = 0;
      int count = ulasanSnap.docs.length;
      for (var doc in ulasanSnap.docs) {
        totalRating += (doc.data()['rating'] as num?)?.toDouble() ?? 0.0;
      }
      double avgRating = count > 0 ? (totalRating / count) : rating;
      
      // Bulatkan ke 1 desimal
      avgRating = double.parse(avgRating.toStringAsFixed(1));

      // 6. Update rating dan totalUlasan di dokumen kantin
      await _db.collection('kantin').doc(kantinId).update({
        'rating': avgRating,
        'totalUlasan': count,
      });
    } catch (e) {
      debugPrint('tambahUlasan error: $e');
      rethrow;
    }
  }

  // =========================================================
  // STREAM ULASAN KANTIN (Urutkan di memori untuk mencegah composite index error)
  // =========================================================
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamUlasanKantin(
    String kantinId,
  ) {
    return _db
        .collection('ulasan')
        .where('kantinId', isEqualTo: kantinId)
        .snapshots();
  }
}
