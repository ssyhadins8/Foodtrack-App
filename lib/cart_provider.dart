import 'package:flutter/material.dart';
import 'dart:math';
import 'package:foodtrack/services/firestore_service.dart';

class CartItem {
  final String nama, gambar, kantin;
  final int harga;
  int qty;

  CartItem({
    required this.nama,
    required this.gambar,
    required this.harga,
    required this.kantin,
    this.qty = 1,
  });
}

class NotifItem {
  final String pesan, waktu;
  final IconData icon;
  final Color color;

  NotifItem({
    required this.pesan,
    required this.waktu,
    required this.icon,
    required this.color,
  });
}

class PesananItem {
  final int noAntrian;
  final String kantin, metode;
  final List<CartItem> items;
  final int totalHarga;
  final DateTime waktuPesan;
  int statusIndex;

  PesananItem({
    required this.noAntrian,
    required this.kantin,
    required this.metode,
    required this.items,
    required this.totalHarga,
    required this.waktuPesan,
    this.statusIndex = 0,
  });

  String get statusLabel {
    switch (statusIndex) {
      case 0:
        return 'Pesanan Diterima';
      case 1:
        return 'Sedang Dimasak';
      case 2:
        return 'Siap Diambil!';
      case 3:
        return 'Selesai';
      default:
        return '';
    }
  }

  Color get statusColor {
    switch (statusIndex) {
      case 0:
        return const Color(0xFF0D1B2A);
      case 1:
        return const Color(0xFFF59E0B);
      case 2:
        return const Color(0xFF10B981);
      case 3:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (statusIndex) {
      case 0:
        return Icons.receipt_long_rounded;
      case 1:
        return Icons.restaurant_rounded;
      case 2:
        return Icons.check_circle_rounded;
      default:
        return Icons.done_all_rounded;
    }
  }
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  final List<NotifItem> _notifs = [];
  final List<PesananItem> _riwayat = [];

  List<CartItem> get items => List.unmodifiable(_items);
  List<NotifItem> get notifikasi => List.unmodifiable(_notifs);
  List<PesananItem> get riwayatPesanan => List.unmodifiable(_riwayat);

  int get totalItem => _items.fold(0, (s, i) => s + i.qty);
  int get totalHarga => _items.fold(0, (s, i) => s + i.harga * i.qty);
  int get unreadCount => _notifs.length;

  // ─── TAMBAH ITEM ───────────────────────────────────────────────────────────
  void tambah(CartItem item) {
    final idx = _items.indexWhere(
      (e) => e.nama == item.nama && e.kantin == item.kantin,
    );
    if (idx >= 0) {
      _items[idx].qty++;
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  // ─── KURANG ITEM ───────────────────────────────────────────────────────────
  void kurang(CartItem item) {
    final idx = _items.indexWhere(
      (e) => e.nama == item.nama && e.kantin == item.kantin,
    );
    if (idx >= 0) {
      if (_items[idx].qty > 1) {
        _items[idx].qty--;
      } else {
        _items.removeAt(idx);
      }
      notifyListeners();
    }
  }

  // ─── HAPUS ITEM ────────────────────────────────────────────────────────────
  void hapus(CartItem item) {
    _items.removeWhere((e) => e.nama == item.nama && e.kantin == item.kantin);
    notifyListeners();
  }

  // ─── PESAN ─────────────────────────────────────────────────────────────────
  // ✅ FIX 9: Simpan ke Firestore, ambil docId, return Map {noAntrian, docId}
  Future<Map<String, dynamic>> pesan(String metode, {String catatan = ''}) async {
    final noAntrian = Random().nextInt(50) + 1;
    final kantin = _items.isNotEmpty ? _items.first.kantin : '-';
    final namaItems = _items.map((e) => e.nama).join(', ');
    String docId = '';

    // 1️⃣ Simpan ke Firestore DULU sebelum clear _items, ambil docId-nya
    try {
      docId = await FirestoreService.simpanPesanan(
        items: _items,
        metode: metode,
        kantin: kantin,
        totalHarga: totalHarga,
        noAntrian: noAntrian,
        catatan: catatan,
      );

      await FirestoreService.simpanNotifikasi(
        judul: 'Pesanan Berhasil! 🎉',
        pesan: 'No. Antrian: $noAntrian dari $kantin. '
            'Pantau status pesananmu!',
        tipe: 'pesanan',
        icon: 'receipt',
        pesananId: docId, // ✅ Pass docId here
      );
    } catch (e) {
      debugPrint('Firestore error: $e');
    }

    // 2️⃣ Update local state
    _riwayat.insert(
      0,
      PesananItem(
        noAntrian: noAntrian,
        kantin: kantin,
        metode: metode,
        items: List<CartItem>.from(_items), // snapshot sebelum di-clear
        totalHarga: totalHarga,
        waktuPesan: DateTime.now(),
        statusIndex: 0,
      ),
    );

    // 3️⃣ Tambahkan notifikasi lokal
    _notifs.insert(
      0,
      NotifItem(
        pesan: 'Pesanan ($namaItems) berhasil! No. Antrian: $noAntrian',
        waktu: _now(),
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFF10B981),
      ),
    );

    // 4️⃣ Bersihkan keranjang
    _items.clear();
    notifyListeners();

    // 5️⃣ Return noAntrian + docId untuk navigasi ke StatusPesananPage
    return {
      'noAntrian': noAntrian,
      'docId': docId,
    };
  }

  // ─── UPDATE STATUS PESANAN ─────────────────────────────────────────────────
  // Dipanggil dari konfirmasi_page.dart / status_pesanan_page.dart saat timer
  void updateStatusPesanan(int noAntrian, int statusIndex) {
    final idx = _riwayat.indexWhere((e) => e.noAntrian == noAntrian);
    if (idx >= 0) {
      _riwayat[idx].statusIndex = statusIndex;
      notifyListeners();
    }

    // Sync ke Firestore (fire and forget)
    FirestoreService.updateStatusPesanan(
      noAntrian: noAntrian,
      statusIndex: statusIndex,
    ).catchError((e) => debugPrint('updateStatus error: $e'));
  }

  // ─── HELPER ────────────────────────────────────────────────────────────────
  int qtyOf(String nama, String kantin) {
    final idx = _items.indexWhere((e) => e.nama == nama && e.kantin == kantin);
    return idx >= 0 ? _items[idx].qty : 0;
  }

  String _now() {
    final n = DateTime.now();
    return '${n.hour.toString().padLeft(2, '0')}.'
        '${n.minute.toString().padLeft(2, '0')} WIB';
  }
}
