import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodtrack/models/voucher_model.dart';
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
        'loyaltyPoints': 0,
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

      // ==== NOTIFIKASI ==== //
      if (_uid != null) {
        await simpanNotifikasi(
          judul: 'Pesanan Baru',
          pesan: 'Anda memiliki pesanan baru dengan no antrian $noAntrian',
          tipe: 'pesanan',
          icon: 'receipt',
          targetUid: _uid,
          pesananId: docRef.id,
        );
      }
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
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        final docRef = snap.docs.first.reference;
        await docRef.update({
          'statusIndex': statusIndex,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // ==== NOTIFIKASI STATUS ==== //
        final orderData = snap.docs.first.data();
        final buyerUid = orderData['uid'] as String? ?? '';
        final pesananId = snap.docs.first.id;
        String pesan;
        switch (statusIndex) {
          case 1:
            pesan = 'Pesanan sedang diproses.';
            break;
          case 2:
            pesan = 'Pesanan siap diambil.';
            break;
          case 3:
            pesan = 'Pesanan selesai.';
            break;
          default:
            pesan = 'Status pesanan berubah.';
        }
        await simpanNotifikasi(
          judul: 'Update Status Pesanan',
          pesan: pesan,
          tipe: 'pesanan',
          icon: 'info',
          targetUid: buyerUid,
          pesananId: pesananId,
        );
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
    String? targetUid,
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

      // Auto-duplicate pesanan notifications to aktivitas tab as well
      if (tipe == 'pesanan') {
        await _db.collection('notifikasi').add({
          'uid': uid,
          'judul': judul,
          'pesan': pesan,
          'tipe': 'aktivitas',
          'icon': icon,
          'pesananId': pesananId,
          'dibaca': false,
          'waktu': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('simpanNotifikasi error: $e');
      rethrow;
    }
  }

  // =========================================================
  // STREAM NOTIFIKASI USER
  // =========================================================
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamAllNotifikasi(String uid) {
    return _db
        .collection('notifikasi')
        .where('uid', isEqualTo: uid)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> streamNotifikasi() {
    return _db
        .collection('notifikasi')
        .where('uid', isEqualTo: _uid)
        .where('dibaca', isEqualTo: false)
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
    String foodcourtId = 'lama',
    String foodcourtLabel = 'Foodcourt Lama',
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
        'foodcourtId': foodcourtId,
        'foodcourtLabel': foodcourtLabel,
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
    String foodcourtId = 'lama',
    String foodcourtLabel = 'Foodcourt Lama',
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
        'foodcourtId': foodcourtId,
        'foodcourtLabel': foodcourtLabel,
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
  // PATCH: Add foodcourt labels & new kantins (run once)
  // =========================================================
  static Future<void> seedNewFoodcourtBaru() async {
    try {
      // Check if already patched to the new 6/6 division and specific images
      final checkMenu = await _db.collection('menu').where('nama', isEqualTo: 'Ketan Durian Keju Susu Fla').limit(1).get();
      if (checkMenu.docs.isNotEmpty && checkMenu.docs.first.data()['gambar'] == 'images/Ketan Durian Keju Susu Fla.png') {
        debugPrint('seedNewFoodcourtBaru: sudah dipatch dengan pembagian 6/6 dan gambar spesifik, skip.');
        return;
      }

      // Force remove Ala Linlan canteen and its menus if they exist in Firestore
      await _db.collection('kantin').doc('kantin_11').delete();
      final alaLinlanMenus = await _db.collection('menu').where('kantinId', isEqualTo: 'kantin_11').get();
      for (final doc in alaLinlanMenus.docs) {
        await doc.reference.delete();
      }

      // Force remove Sego Njamoer canteen and its menus if they exist in Firestore
      await _db.collection('kantin').doc('kantin_10').delete();
      final segoNjamoerMenus = await _db.collection('menu').where('kantinId', isEqualTo: 'kantin_10').get();
      for (final doc in segoNjamoerMenus.docs) {
        await doc.reference.delete();
      }

      // 1. Patch kantin 1 s/d 6 with foodcourtId = 'lama'
      final lamaIds = ['kantin_1','kantin_2','kantin_3','kantin_4','kantin_5','kantin_6'];
      for (final id in lamaIds) {
        await _db.collection('kantin').doc(id).update({
          'foodcourtId': 'lama',
          'foodcourtLabel': 'Foodcourt Lama',
        });
      }

      // 2. Patch kantin 7 & 8 with foodcourtId = 'baru' to split them evenly 6/6
      final baruIds = ['kantin_7','kantin_8'];
      for (final id in baruIds) {
        await _db.collection('kantin').doc(id).update({
          'foodcourtId': 'baru',
          'foodcourtLabel': 'Foodcourt Baru',
        });
      }

      // 3. Add new kantin baru (excluding Sego Njamoer & Ala Linlan)
      final newKantin = [
        {'id': 'kantin_9',  'nama': 'Dimsum Station',    'deskripsi': 'Dimsum & Aneka Dumpling',       'kategori': 'Snack',   'gambar': 'images/Dimsum Station.jpg',    'rating': 4.8, 'isTop': true,  'waktu': '10-15 mnt', 'foodcourtId': 'baru', 'foodcourtLabel': 'Foodcourt Baru', 'totalMenu': 6},
        {'id': 'kantin_12', 'nama': 'Pos Ketan Legenda', 'deskripsi': 'Ketan & Camilan Tradisional',   'kategori': 'Snack',   'gambar': 'images/Pos Ketan Legenda.jpg', 'rating': 4.5, 'isTop': false, 'waktu': '5-10 mnt',  'foodcourtId': 'baru', 'foodcourtLabel': 'Foodcourt Baru', 'totalMenu': 5},
        {'id': 'kantin_13', 'nama': 'Bingxue',           'deskripsi': 'Es Krim & Minuman Kekinian',    'kategori': 'Minuman', 'gambar': 'images/Bingxue.jpeg',          'rating': 4.9, 'isTop': true,  'waktu': '5-10 mnt',  'foodcourtId': 'baru', 'foodcourtLabel': 'Foodcourt Baru', 'totalMenu': 6},
      ];

      for (final k in newKantin) {
        await _db.collection('kantin').doc(k['id'] as String).set({
          'nama': k['nama'],
          'deskripsi': k['deskripsi'],
          'kategori': k['kategori'],
          'gambar': k['gambar'],
          'rating': k['rating'],
          'isTop': k['isTop'],
          'waktu': k['waktu'],
          'totalMenu': k['totalMenu'],
          'foodcourtId': k['foodcourtId'],
          'foodcourtLabel': k['foodcourtLabel'],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Delete old menus for these new canteens to prevent duplicates
      final oldMenus = await _db.collection('menu')
          .where('kantinId', whereIn: ['kantin_9', 'kantin_12', 'kantin_13'])
          .get();
      for (final doc in oldMenus.docs) {
        await doc.reference.delete();
      }

      // 4. Add menu for new kantins (Sego Njamoer & Ala Linlan excluded) with specific images
      final newMenus = {
        'kantin_9': [
          {'nama': 'Lava Spicy Mayo', 'harga': 40000, 'gambar': 'images/Lava Spicy Mayo.png', 'kat': 'Snack', 'desc': 'Dimsum dengan saus spicy mayo hangat'},
          {'nama': 'Kaicak Ayam Jamur', 'harga': 35000, 'gambar': 'images/Kaicak Ayam Jamur.png', 'kat': 'Snack', 'desc': 'Kaicak ayam jamur kukus'},
          {'nama': 'Siewmay Nori Crab Stick', 'harga': 35000, 'gambar': 'images/Siewmay Nori Crab Stick.png', 'kat': 'Snack', 'desc': 'Siomay nori topping kepiting'},
          {'nama': 'Pangsit Udang Goreng', 'harga': 35000, 'gambar': 'images/Pangsit Udang Goreng.png', 'kat': 'Snack', 'desc': 'Pangsit udang goreng renyah'},
          {'nama': 'Lumpia Udang Kulit Tahu', 'harga': 35000, 'gambar': 'images/Lumpia Udang Kulit Tahu.png', 'kat': 'Snack', 'desc': 'Lumpia udang bungkus kulit tahu'},
          {'nama': 'Lumpia Ayam Udang', 'harga': 35000, 'gambar': 'images/Lumpia Ayam Udang.png', 'kat': 'Snack', 'desc': 'Lumpia isi ayam dan udang'},
        ],
        'kantin_12': [
          {'nama': 'Ketan Durian Keju Susu Fla', 'harga': 18000, 'gambar': 'images/Ketan Durian Keju Susu Fla.png', 'kat': 'Snack', 'desc': 'Ketan dengan topping durian, keju, dan susu fla manis'},
          {'nama': 'Ketan Susu Vla Durian', 'harga': 16000, 'gambar': 'images/Ketan Susu Vla Durian.png', 'kat': 'Snack', 'desc': 'Ketan hangat dengan siraman vla durian dan susu kental manis'},
          {'nama': 'Ketan Susu Fla Nangka', 'harga': 15000, 'gambar': 'images/Ketan Susu Fla Nangka.png', 'kat': 'Snack', 'desc': 'Ketan gurih dengan potongan nangka wangi dan fla susu'},
          {'nama': 'Ketan Pisang + Keju Susu Fla', 'harga': 17000, 'gambar': 'images/Ketan Pisang + Keju Susu Fla.png', 'kat': 'Snack', 'desc': 'Ketan dipadukan dengan pisang manis, parutan keju, dan fla susu'},
          {'nama': 'Ketan Susu Keju Meses', 'harga': 14000, 'gambar': 'images/Ketan Susu Keju Meses.png', 'kat': 'Snack', 'desc': 'Ketan susu dengan taburan keju parut dan meses cokelat manis'},
        ],
        'kantin_13': [
          {'nama': 'Milk Tea Cloud Pudding Ice Cream', 'harga': 18000, 'gambar': 'images/Milk Tea Cloud Pudding Ice Cream.png', 'kat': 'Minuman', 'desc': 'Milk tea dengan pudding lembut dan ice cream vanilla'},
          {'nama': 'Pudding Cup (Strawberry, Mango, Peach)', 'harga': 12000, 'gambar': 'images/Pudding Cup (Strawberry, Mango, Peach).png', 'kat': 'Minuman', 'desc': 'Pudding cup dengan aneka rasa buah segar'},
          {'nama': 'Sanzha Apple', 'harga': 15000, 'gambar': 'images/Sanzha Apple.png', 'kat': 'Minuman', 'desc': 'Minuman teh apel sanzha menyegarkan'},
          {'nama': 'Egg Waffle Chocolate', 'harga': 16000, 'gambar': 'images/Egg Waffle Chocolate.png', 'kat': 'Snack', 'desc': 'Egg waffle hangat rasa cokelat manis'},
          {'nama': 'Chocolate Red Bean Sundae', 'harga': 15000, 'gambar': 'images/Chocolate Red Bean Sundae.png', 'kat': 'Minuman', 'desc': 'Es krim sundae cokelat dengan topping red bean'},
          {'nama': 'Mulberry Bing-Shake', 'harga': 17000, 'gambar': 'images/Mulberry Bing-Shake.png', 'kat': 'Minuman', 'desc': 'Bing-shake mulberry dingin dan segar'},
        ],
      };

      for (final entry in newMenus.entries) {
        final kId = entry.key;
        final kName = newKantin.firstWhere((k) => k['id'] == kId)['nama'] as String;
        for (final m in entry.value) {
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

      debugPrint('seedNewFoodcourtBaru: berhasil patch lama + tambah 4 kantin baru!');
    } catch (e) {
      debugPrint('seedNewFoodcourtBaru error: $e');
    }
  }

  // =========================================================
  // PATCH: Add Toby's Chicken (kantin_14)
  // =========================================================
  static Future<void> seedTobyChicken() async {
    try {
      final checkMenu = await _db.collection('menu').where('nama', isEqualTo: 'Mujur Combo 1').limit(1).get();
      if (checkMenu.docs.isNotEmpty && checkMenu.docs.first.data()['gambar'] != "images/Toby's Chicken.png") {
        debugPrint('seedTobyChicken: sudah ada menu Toby baru dengan gambar spesifik, skip.');
        return;
      }

      // Delete old Toby menus
      final oldTobyMenus = await _db.collection('menu').where('kantinId', isEqualTo: 'kantin_14').get();
      for (final doc in oldTobyMenus.docs) {
        await doc.reference.delete();
      }

      // Add Toby's Chicken kantin
      await _db.collection('kantin').doc('kantin_14').set({
        'nama': "Toby's Chicken",
        'deskripsi': 'Ayam Crispy & Korean Fried Chicken',
        'kategori': 'Ayam',
        'gambar': "images/Toby's Chicken.png",
        'rating': 4.8,
        'isTop': true,
        'waktu': '10-15 mnt',
        'totalMenu': 5,
        'foodcourtId': 'baru',
        'foodcourtLabel': 'Foodcourt Baru',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Add menus for Toby's Chicken
      final tobysMenus = [
        {'nama': 'Mujur Combo 1',        'harga': 25000, 'gambar': "images/Mujur Combo 1.png", 'kat': 'Ayam',    'desc': 'Paket hemat ayam goreng nasi dan minum'},
        {'nama': 'Mujur Cheese',         'harga': 22000, 'gambar': "images/Mujur Cheese.png", 'kat': 'Ayam',    'desc': 'Ayam goreng renyah siram saus keju gurih'},
        {'nama': 'Lava Cheese',          'harga': 23000, 'gambar': "images/Lava Cheese.png", 'kat': 'Ayam',    'desc': 'Ayam goreng pedas berpadu dengan saus keju meleleh'},
        {'nama': 'T-Wingz Hot Lava Bowl','harga': 20000, 'gambar': "images/T-Wingz Hot Lava Bowl.png", 'kat': 'Ayam',    'desc': 'Sayap ayam crispy bersaus lava pedas disajikan di mangkuk'},
        {'nama': 'Chicken Soup',         'harga': 12000, 'gambar': "images/Chicken Soup.png", 'kat': 'Ayam',    'desc': 'Sup ayam hangat dengan sayuran segar dan kaldu lezat'},
      ];

      for (final m in tobysMenus) {
        await _db.collection('menu').add({
          'nama': m['nama'],
          'harga': m['harga'],
          'stok': 20,
          'desc': m['desc'],
          'kantin': "Toby's Chicken",
          'kantinId': 'kantin_14',
          'tersedia': true,
          'kategori': m['kat'],
          'gambar': m['gambar'],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      debugPrint("seedTobyChicken: Toby's Chicken berhasil ditambahkan dengan gambar spesifik!");
    } catch (e) {
      debugPrint('seedTobyChicken error: $e');
    }
  }

  // =========================================================
  // DYNAMIC SEED INITIAL DATA
  // =========================================================
  static Future<void> seedInitialData() async {
    try {
      // Only seed if kantin collection is empty — do NOT overwrite admin data
      final existingKantin = await _db.collection('kantin').limit(1).get();
      if (existingKantin.docs.isNotEmpty) {
        debugPrint('seedInitialData: database sudah ada data, skip seed.');
        return;
      }

      final canteens = [
        // ── FOODCOURT LAMA ──────────────────────────────────
        {'id': 'kantin_1', 'nama': 'Kantin Bu Sari', 'deskripsi': 'Soto, Sup, & Aneka Gorengan', 'kategori': 'Soto', 'gambar': 'images/kantin1.jpg', 'rating': 4.8, 'isTop': true, 'waktu': '15-20 mnt', 'totalMenu': 5, 'foodcourtId': 'lama', 'foodcourtLabel': 'Foodcourt Lama'},
        {'id': 'kantin_2', 'nama': 'Kantin Pak Budi', 'deskripsi': 'Nasi Campur & Lauk Pauk', 'kategori': 'Nasi', 'gambar': 'images/kantin2.jpg', 'rating': 4.9, 'isTop': true, 'waktu': '10-15 mnt', 'totalMenu': 5, 'foodcourtId': 'lama', 'foodcourtLabel': 'Foodcourt Lama'},
        {'id': 'kantin_3', 'nama': 'Kantin Geprek', 'deskripsi': 'Ayam Geprek & Lalapan', 'kategori': 'Ayam', 'gambar': 'images/kantin3.jpeg', 'rating': 4.7, 'isTop': true, 'waktu': '15-20 mnt', 'totalMenu': 5, 'foodcourtId': 'lama', 'foodcourtLabel': 'Foodcourt Lama'},
        {'id': 'kantin_4', 'nama': 'Kantin Bakso Mas Jo', 'deskripsi': 'Bakso & Mie Ayam', 'kategori': 'Bakso', 'gambar': 'images/kantin4.jpeg', 'rating': 4.6, 'isTop': false, 'waktu': '10-15 mnt', 'totalMenu': 5, 'foodcourtId': 'lama', 'foodcourtLabel': 'Foodcourt Lama'},
        {'id': 'kantin_5', 'nama': 'Kantin Minuman Segar', 'deskripsi': 'Jus, Es, & Minuman', 'kategori': 'Minuman', 'gambar': 'images/kantin5.jpg', 'rating': 4.5, 'isTop': false, 'waktu': '5-10 mnt', 'totalMenu': 5, 'foodcourtId': 'lama', 'foodcourtLabel': 'Foodcourt Lama'},
        {'id': 'kantin_6', 'nama': 'Kantin Seafood Bu Tini', 'deskripsi': 'Seafood Segar & Nasi', 'kategori': 'Seafood', 'gambar': 'images/kantin6.png', 'rating': 4.7, 'isTop': true, 'waktu': '20-25 mnt', 'totalMenu': 5, 'foodcourtId': 'lama', 'foodcourtLabel': 'Foodcourt Lama'},
        // ── FOODCOURT BARU ──────────────────────────────────
        {'id': 'kantin_7', 'nama': 'Kantin Snack Corner', 'deskripsi': 'Gorengan & Camilan', 'kategori': 'Snack', 'gambar': 'images/kantin7.jpeg', 'rating': 4.4, 'isTop': false, 'waktu': '5-10 mnt', 'totalMenu': 5, 'foodcourtId': 'baru', 'foodcourtLabel': 'Foodcourt Baru'},
        {'id': 'kantin_8', 'nama': 'Kantin Nasi Padang', 'deskripsi': 'Masakan Padang Lezat', 'kategori': 'Nasi', 'gambar': 'images/kantin8.jpg', 'rating': 4.9, 'isTop': true, 'waktu': '10-15 mnt', 'totalMenu': 5, 'foodcourtId': 'baru', 'foodcourtLabel': 'Foodcourt Baru'},
        {'id': 'kantin_9', 'nama': 'Dimsum Station', 'deskripsi': 'Dimsum & Aneka Dumpling', 'kategori': 'Snack', 'gambar': 'images/Dimsum Station.jpg', 'rating': 4.8, 'isTop': true, 'waktu': '10-15 mnt', 'totalMenu': 6, 'foodcourtId': 'baru', 'foodcourtLabel': 'Foodcourt Baru'},
        {'id': 'kantin_12', 'nama': 'Pos Ketan Legenda', 'deskripsi': 'Ketan & Camilan Tradisional', 'kategori': 'Snack', 'gambar': 'images/Pos Ketan Legenda.jpg', 'rating': 4.5, 'isTop': false, 'waktu': '5-10 mnt', 'totalMenu': 5, 'foodcourtId': 'baru', 'foodcourtLabel': 'Foodcourt Baru'},
        {'id': 'kantin_13', 'nama': 'Bingxue', 'deskripsi': 'Es Krim & Minuman Kekinian', 'kategori': 'Minuman', 'gambar': 'images/Bingxue.jpeg', 'rating': 4.9, 'isTop': true, 'waktu': '5-10 mnt', 'totalMenu': 6, 'foodcourtId': 'baru', 'foodcourtLabel': 'Foodcourt Baru'},
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
          'foodcourtId': k['foodcourtId'],
          'foodcourtLabel': k['foodcourtLabel'],
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
        // ── FOODCOURT BARU ───────────────────────────────────
        'kantin_9': [
          {'nama': 'Lava Spicy Mayo', 'harga': 40000, 'gambar': 'images/Lava Spicy Mayo.png', 'kat': 'Snack', 'desc': 'Dimsum dengan saus spicy mayo hangat'},
          {'nama': 'Kaicak Ayam Jamur', 'harga': 35000, 'gambar': 'images/Kaicak Ayam Jamur.png', 'kat': 'Snack', 'desc': 'Kaicak ayam jamur kukus'},
          {'nama': 'Siewmay Nori Crab Stick', 'harga': 35000, 'gambar': 'images/Siewmay Nori Crab Stick.png', 'kat': 'Snack', 'desc': 'Siomay nori topping kepiting'},
          {'nama': 'Pangsit Udang Goreng', 'harga': 35000, 'gambar': 'images/Pangsit Udang Goreng.png', 'kat': 'Snack', 'desc': 'Pangsit udang goreng renyah'},
          {'nama': 'Lumpia Udang Kulit Tahu', 'harga': 35000, 'gambar': 'images/Lumpia Udang Kulit Tahu.png', 'kat': 'Snack', 'desc': 'Lumpia udang bungkus kulit tahu'},
          {'nama': 'Lumpia Ayam Udang', 'harga': 35000, 'gambar': 'images/Lumpia Ayam Udang.png', 'kat': 'Snack', 'desc': 'Lumpia isi ayam dan udang'},
        ],
        'kantin_12': [
          {'nama': 'Ketan Durian Keju Susu Fla', 'harga': 18000, 'gambar': 'images/Ketan Durian Keju Susu Fla.png', 'kat': 'Snack', 'desc': 'Ketan dengan topping durian, keju, dan susu fla manis'},
          {'nama': 'Ketan Susu Vla Durian', 'harga': 16000, 'gambar': 'images/Ketan Susu Vla Durian.png', 'kat': 'Snack', 'desc': 'Ketan hangat dengan siraman vla durian and susu kental manis'},
          {'nama': 'Ketan Susu Fla Nangka', 'harga': 15000, 'gambar': 'images/Ketan Susu Fla Nangka.png', 'kat': 'Snack', 'desc': 'Ketan gurih dengan potongan nangka wangi and fla susu'},
          {'nama': 'Ketan Pisang + Keju Susu Fla', 'harga': 17000, 'gambar': 'images/Ketan Pisang + Keju Susu Fla.png', 'kat': 'Snack', 'desc': 'Ketan dipadukan dengan pisang manis, parutan keju, and fla susu'},
          {'nama': 'Ketan Susu Keju Meses', 'harga': 14000, 'gambar': 'images/Ketan Susu Keju Meses.png', 'kat': 'Snack', 'desc': 'Ketan susu dengan taburan keju parut and meses cokelat manis'},
        ],
        'kantin_13': [
          {'nama': 'Milk Tea Cloud Pudding Ice Cream', 'harga': 18000, 'gambar': 'images/Milk Tea Cloud Pudding Ice Cream.png', 'kat': 'Minuman', 'desc': 'Milk tea dengan pudding lembut and ice cream vanilla'},
          {'nama': 'Pudding Cup (Strawberry, Mango, Peach)', 'harga': 12000, 'gambar': 'images/Pudding Cup (Strawberry, Mango, Peach).png', 'kat': 'Minuman', 'desc': 'Pudding cup dengan aneka rasa buah segar'},
          {'nama': 'Sanzha Apple', 'harga': 15000, 'gambar': 'images/Sanzha Apple.png', 'kat': 'Minuman', 'desc': 'Minuman teh apel sanzha menyegarkan'},
          {'nama': 'Egg Waffle Chocolate', 'harga': 16000, 'gambar': 'images/Egg Waffle Chocolate.png', 'kat': 'Snack', 'desc': 'Egg waffle hangat rasa cokelat manis'},
          {'nama': 'Chocolate Red Bean Sundae', 'harga': 15000, 'gambar': 'images/Chocolate Red Bean Sundae.png', 'kat': 'Minuman', 'desc': 'Es krim sundae cokelat dengan topping red bean'},
          {'nama': 'Mulberry Bing-Shake', 'harga': 17000, 'gambar': 'images/Mulberry Bing-Shake.png', 'kat': 'Minuman', 'desc': 'Bing-shake mulberry dingin dan segar'},
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

      // Seed mock active orders so canteens are not all quiet (Sepi) on startup
      final oldPesanan = await _db.collection('pesanan').get();
      for (var doc in oldPesanan.docs) {
        await doc.reference.delete();
      }

      // Also clean up old notifications and reviews to avoid orphaned references
      final oldNotif = await _db.collection('notifikasi').get();
      for (var doc in oldNotif.docs) {
        await doc.reference.delete();
      }

      final oldUlasan = await _db.collection('ulasan').get();
      for (var doc in oldUlasan.docs) {
        await doc.reference.delete();
      }

      // 3 active orders for Kantin Bu Sari (reaches threshold 3 -> Ramai)
      for (int i = 0; i < 3; i++) {
        await _db.collection('pesanan').add({
          'uid': 'mock_user_1',
          'pembeliNama': 'Budi Pekerti',
          'pembeliEmail': 'budi@demo.com',
          'kantin': 'Kantin Bu Sari',
          'kantinId': 'kantin_1',
          'metode': 'Cash',
          'catatan': 'Pedas sedang',
          'totalHarga': 12000,
          'noAntrian': 10 + i,
          'statusIndex': 1, // Sedang disiapkan (Cooking)
          'items': [
            {
              'nama': 'Soto Ayam',
              'gambar': 'images/soto_ayam.jpeg',
              'harga': 12000,
              'qty': 1,
              'kantin': 'Kantin Bu Sari',
            }
          ],
          'waktuPesan': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // 4 active orders for Kantin Pak Budi (reaches threshold 4 -> Ramai)
      for (int i = 0; i < 4; i++) {
        await _db.collection('pesanan').add({
          'uid': 'mock_user_2',
          'pembeliNama': 'Siti Rahma',
          'pembeliEmail': 'siti@demo.com',
          'kantin': 'Kantin Pak Budi',
          'kantinId': 'kantin_2',
          'metode': 'QRIS',
          'catatan': 'Nasi setengah',
          'totalHarga': 15000,
          'noAntrian': 20 + i,
          'statusIndex': 1, // Sedang disiapkan (Cooking)
          'items': [
            {
              'nama': 'Nasi Campur',
              'gambar': 'images/nasi_campur.jpeg',
              'harga': 15000,
              'qty': 1,
              'kantin': 'Kantin Pak Budi',
            }
          ],
          'waktuPesan': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      debugPrint('Successfully seeded canteens, menu items, and active orders.');
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

      final userDoc = await _db.collection('users').doc(_uid).get();
      final namaPembeli = userDoc.data()?['nama'] ?? 'Pembeli';

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

      await _db.collection('pesanan').doc(pesananId).update({
        'ulasanDiberikan': true,
      });

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

  // =========================================================
  // VOUCHER METHODS (Admin)
  // =========================================================
  static Stream<List<VoucherModel>> streamAllVouchers() {
    return _db.collection('vouchers').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => VoucherModel.fromJson(doc.id, doc.data())).toList());
  }

  static Future<void> toggleVoucherActive(String voucherId) async {
    final docRef = _db.collection('vouchers').doc(voucherId);
    final snap = await docRef.get();
    if (!snap.exists) return;
    final current = snap.get('active') as bool? ?? true;
    await docRef.update({'active': !current, 'updatedAt': FieldValue.serverTimestamp()});
  }

  static Future<void> createVoucher(VoucherModel voucher) async {
    await _db.collection('vouchers').doc(voucher.id).set(voucher.toJson());
  }
}
