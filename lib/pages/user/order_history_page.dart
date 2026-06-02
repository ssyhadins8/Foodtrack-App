import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodtrack/cart_provider.dart';
import 'package:foodtrack/theme/app_colors.dart';
import 'package:foodtrack/pages/status_pesanan_page.dart';
import 'package:foodtrack/pages/cart_page.dart';

// ===== RIWAYAT PESANAN (dari Firestore) =====
class RiwayatPesananPage extends StatelessWidget {
  final CartProvider cart;
  const RiwayatPesananPage({super.key, required this.cart});

  String _fmt(int h) =>
      'Rp${h.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  String _tgl(DateTime dt) {
    const b = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${dt.day} ${b[dt.month]} ${dt.year}, '
        '${dt.hour.toString().padLeft(2, '0')}.'
        '${dt.minute.toString().padLeft(2, '0')} WIB';
  }

  Color _sc(int i) {
    switch (i) {
      case 0:
        return AppColors.primary;
      case 1:
        return AppColors.warning;
      case 2:
        return AppColors.success;
      default:
        return Colors.grey;
    }
  }

  String _sl(int i) {
    switch (i) {
      case 0:
        return 'Pesanan Diterima';
      case 1:
        return 'Sedang Dimasak';
      case 2:
        return 'Siap Diambil!';
      case 3:
        return 'Selesai';
      default:
        return 'Ditolak';
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Riwayat Pesanan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: uid == null
          ? const Center(child: Text('Silakan login'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pesanan')
                  .where('uid', isEqualTo: uid)
                  .snapshots(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                final docs = (snap.data?.docs ?? []).toList();
                docs.sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;
                  final timeA = dataA['waktuPesan'] as Timestamp?;
                  final timeB = dataB['waktuPesan'] as Timestamp?;
                  if (timeA == null && timeB == null) return 0;
                  if (timeA == null) return 1;
                  if (timeB == null) return -1;
                  return timeB.compareTo(timeA);
                });
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.cyanLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.receipt_long_outlined,
                            size: 40,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Belum ada riwayat pesanan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Yuk pesan makanan dari kantin!',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final d = docs[i].data() as Map<String, dynamic>;
                    final status = d['statusIndex'] as int? ?? 0;
                    final isAktif = status < 3;
                    final waktu = (d['waktuPesan'] as Timestamp?)?.toDate() ??
                        DateTime.now();
                    final items =
                        (d['items'] as List?)?.cast<Map<String, dynamic>>() ??
                            [];
                    final docId = docs[i].id;

                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StatusPesananPage(docId: docId),
                        ),
                      ),
                      child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: isAktif
                            ? Border.all(
                                color: _sc(status).withOpacity(0.3),
                                width: 1.5,
                              )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: _sc(status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    status == 0
                                        ? Icons.receipt_long_rounded
                                        : status == 1
                                            ? Icons.restaurant_rounded
                                            : status == 2
                                                ? Icons.check_circle_rounded
                                                : Icons.done_all_rounded,
                                    color: _sc(status),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        d['kantin'] ?? '-',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        _tgl(waktu),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textHint,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _sc(status).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                          8,
                                        ),
                                      ),
                                      child: Text(
                                        _sl(status),
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: _sc(status),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'No. ${d['noAntrian']}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(16),
                              ),
                            ),
                            child: Column(
                              children: [
                                ...items.take(2).map(
                                      (item) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 4,
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              '${item['qty']}x',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textHint,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                item['nama'] ?? '',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              _fmt(
                                                (item['harga'] as int) *
                                                    (item['qty'] as int),
                                              ),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                if (items.length > 2)
                                  Text(
                                    '+${items.length - 2} item lainnya',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textHint,
                                    ),
                                  ),
                                const Divider(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      d['metode'] ?? '-',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textHint,
                                      ),
                                    ),
                                    Text(
                                      _fmt(d['totalHarga'] as int? ?? 0),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                if (status == 3) ...[
                                  const Divider(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () => _pesanLagi(context, items, d['kantin'] ?? ''),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF1a202c),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          elevation: 0,
                                        ),
                                        child: const Text('Pesan Lagi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                );
              },
            ),
    );
  }

  Future<void> _pesanLagi(BuildContext context, List<dynamic> items, String kantinName) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      final List<String> skippedList = [];
      final menuColl = FirebaseFirestore.instance.collection('menu');

      for (var item in items) {
        final Map<String, dynamic> itemMap = Map<String, dynamic>.from(item);
        final String name = itemMap['nama'] ?? '';
        final int qty = itemMap['qty'] as int? ?? 1;

        // Fetch menu doc
        final menuQuery = await menuColl
            .where('kantin', isEqualTo: kantinName)
            .where('nama', isEqualTo: name)
            .limit(1)
            .get();

        if (menuQuery.docs.isNotEmpty) {
          final menuDoc = menuQuery.docs.first;
          final menuData = menuDoc.data();
          final bool isAvailable = menuData['isAvailable'] as bool? ?? false;
          final int stock = menuData['stok'] as int? ?? menuData['stock'] as int? ?? 0;

          if (isAvailable && stock > 0) {
            final String img = menuData['gambar'] as String? ?? itemMap['gambar'] as String? ?? '';
            final int price = menuData['harga'] as int? ?? itemMap['harga'] as int? ?? 0;

            for (int i = 0; i < qty; i++) {
              cart.tambah(CartItem(
                nama: name,
                gambar: img,
                harga: price,
                kantin: kantinName,
                qty: 1,
              ));
            }
          } else {
            skippedList.add(name);
          }
        } else {
          skippedList.add(name);
        }
      }

      if (context.mounted) Navigator.pop(context); // Dismiss loading dialog

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartPage()),
        );

        if (skippedList.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Item tidak tersedia: ${skippedList.join(', ')}'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context); // Dismiss loading dialog
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }
}
