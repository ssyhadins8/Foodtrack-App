import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:foodtrack/theme/app_colors.dart';
import 'package:foodtrack/services/firestore_service.dart';
import 'package:foodtrack/pages/status_pesanan_page.dart';
import 'package:foodtrack/theme/premium_background.dart';
import 'package:foodtrack/services/voucher_service.dart';
import 'package:foodtrack/models/voucher_model.dart';
import 'package:intl/intl.dart';
import 'dart:async';
class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        ),
        elevation: 0,
        title: const Text(
          'Notifikasi',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tab,
          labelColor: AppColors.cyan,
          unselectedLabelColor: Colors.white54,
          indicatorColor: AppColors.cyan,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Pesanan'),
            Tab(text: 'Promo & Voucher'),
            Tab(text: 'Aktivitas'),
          ],
        ),
      ),
      body: PremiumBackground(
        child: uid == null
            ? const Center(child: Text('Silakan login'))
            : TabBarView(
                controller: _tab,
                children: [
                  _NotifTab(uid: uid, tipe: 'pesanan'),
                  _PromoTab(uid: uid),
                  _NotifTab(uid: uid, tipe: 'aktivitas'),
                ],
              ),
      ),
    );
  }
}

class _NotifTab extends StatefulWidget {
  final String uid;
  final String tipe;
  const _NotifTab({required this.uid, required this.tipe});

  @override
  State<_NotifTab> createState() => _NotifTabState();
}

class _NotifTabState extends State<_NotifTab> {
  bool _timeout = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _timeout = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildEmptyState() {
    return Center(
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 600),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, double val, child) => Opacity(
          opacity: val,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - val)),
            child: child,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F0FE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 70,
                color: Color(0xFF3D5A80),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Belum ada notifikasi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a202c),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                widget.tipe == 'pesanan'
                    ? 'Update pesananmu akan muncul di sini'
                    : 'Info terbaru akan muncul di sini',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService.streamAllNotifikasi(widget.uid),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(child: Text('Terjadi kesalahan: ${snap.error}', style: const TextStyle(color: Colors.white)));
        }
        if (!snap.hasData) {
          if (_timeout) {
            return _buildEmptyState();
          }
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        _timer?.cancel();
        final allDocs = snap.data!.docs;
        final filtered = allDocs.where((doc) => (doc.data() as Map<String, dynamic>)['tipe'] == widget.tipe).toList();
        filtered.sort((a, b) {
          final aTime = (a.data() as Map<String, dynamic>)['waktu'];
          final bTime = (b.data() as Map<String, dynamic>)['waktu'];
          if (aTime is Timestamp && bTime is Timestamp) {
            return bTime.compareTo(aTime);
          }
          return 0;
        });
        if (filtered.isEmpty) {
          return _buildEmptyState();
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final doc = filtered[i];
            final data = doc.data() as Map<String, dynamic>;
            return _NotifCard(data: data, docId: doc.id);
          },
        );
      },
    );
  }
}

class _NotifCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  const _NotifCard({required this.data, required this.docId});

  String _fmtWaktu(dynamic waktu) {
    if (waktu == null) return '';
    if (waktu is String) return waktu;
    if (waktu is Timestamp) {
      final dt = waktu.toDate();
      return '${dt.hour.toString().padLeft(2, "0")}.${dt.minute.toString().padLeft(2, "0")} WIB';
    }
    return '';
  }

  IconData get _icon {
    switch (data['icon']) {
      case 'ready':
        return Icons.check_circle_rounded;
      case 'cook':
        return Icons.restaurant_rounded;
      case 'receipt':
        return Icons.receipt_long_rounded;
      case 'done':
        return Icons.done_all_rounded;
      case 'promo':
        return Icons.local_offer_rounded;
      case 'profile':
        return Icons.person_rounded;
      case 'welcome':
        return Icons.waving_hand_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  Color get _iconColor {
    switch (data['icon']) {
      case 'ready':
        return AppColors.success;
      case 'cook':
        return AppColors.warning;
      case 'receipt':
        return AppColors.primary;
      case 'done':
        return AppColors.textSecondary;
      case 'promo':
        return const Color(0xFFF97316);
      case 'profile':
        return AppColors.secondary;
      case 'welcome':
        return AppColors.cyan;
      default:
        return AppColors.textHint;
    }
  }

  Color get _iconBg {
    switch (data['icon']) {
      case 'ready':
        return const Color(0xFFD1FAE5);
      case 'cook':
        return const Color(0xFFFEF3C7);
      case 'receipt':
        return AppColors.cyanLight;
      case 'done':
        return Colors.grey.shade100;
      case 'promo':
        return const Color(0xFFFFF7ED);
      case 'profile':
        return const Color(0xFFE8F4FD);
      case 'welcome':
        return AppColors.cyanLight;
      default:
        return Colors.grey.shade100;
    }
  }

  void _showPromoDetails(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF7ED),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.local_offer_rounded, color: Color(0xFFF97316), size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Detail Promo', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text(data['judul'] ?? 'Promo Menarik', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32, thickness: 1),
              const Text('Deskripsi Promo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text(
                data['pesan'] ?? '',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 16),
              const Text('Syarat & Ketentuan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              _skItem('Hanya berlaku untuk pesanan melalui aplikasi FoodTrack.'),
              _skItem('Promo berlaku selama persediaan masih ada di kantin terkait.'),
              _skItem('Dapat digunakan tanpa kode tambahan (potongan harga otomatis di kasir).'),
              _skItem('Tidak dapat diuangkan atau digabungkan dengan voucher diskon lain.'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Mengerti', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _skItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: AppColors.cyan, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dibaca = data['dibaca'] as bool? ?? true;
    final tag = data['tag'] as String?;
    final tagColorInt = data['tagColor'] as int?;
    final tagColor = tagColorInt != null ? Color(tagColorInt) : null;
    final pesananId = data['pesananId'] as String?;
    return GestureDetector(
      onTap: () {
        FirestoreService.tandaiDibaca(docId);
        if (data['tipe'] == 'promo') {
          _showPromoDetails(context, data);
        } else if (pesananId != null && pesananId.isNotEmpty) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => StatusPesananPage(docId: pesananId)));
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(
              left: BorderSide(color: Color(0xFF3D5A80), width: 4),
              top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              right: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: _iconBg, shape: BoxShape.circle),
                child: Icon(_icon, color: _iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            data['judul'] ?? '',
                            style: TextStyle(fontSize: 13, fontWeight: dibaca ? FontWeight.w500 : FontWeight.bold, color: const Color(0xFF1a202c)),
                          ),
                        ),
                        if (tag != null && tagColor != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(color: tagColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6), border: Border.all(color: tagColor.withOpacity(0.3))),
                            child: Text(tag, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: tagColor)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(data['pesan'] ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFF1a202c), height: 1.4)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 11, color: Color(0xFF4A5568)),
                        const SizedBox(width: 4),
                        Text(_fmtWaktu(data['waktu']), style: const TextStyle(fontSize: 11, color: Color(0xFF4A5568))),
                        const Spacer(),
                        if (!dibaca)
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF3D5A80), shape: BoxShape.circle)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoTab extends StatefulWidget {
  final String uid;
  const _PromoTab({Key? key, required this.uid}) : super(key: key);

  @override
  State<_PromoTab> createState() => _PromoTabState();
}

class _PromoTabState extends State<_PromoTab> with SingleTickerProviderStateMixin {
  late TabController _innerTab;

  @override
  void initState() {
    super.initState();
    _innerTab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _innerTab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _innerTab,
            labelColor: const Color(0xFF3D5A80),
            unselectedLabelColor: const Color(0xFF4A5568),
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(text: 'Promo Terbaru'),
              Tab(text: 'Voucher Saya'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _innerTab,
            children: [
              _NotifTab(uid: widget.uid, tipe: 'promo'),
              _VoucherSayaTab(uid: widget.uid),
            ],
          ),
        ),
      ],
    );
  }
}

class _VoucherSayaTab extends StatefulWidget {
  final String uid;
  const _VoucherSayaTab({Key? key, required this.uid}) : super(key: key);

  @override
  State<_VoucherSayaTab> createState() => _VoucherSayaTabState();
}

class _VoucherSayaTabState extends State<_VoucherSayaTab> {
  bool _timeout = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _seedData();
    _timer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _timeout = true;
        });
      }
    });
  }

  Future<void> _seedData() async {
    try {
      await VoucherService.seedUserVouchers(widget.uid);
      await _seedPromos();
    } catch (e) {
      debugPrint('Error seeding user vouchers/promos: $e');
    }
  }

  Future<void> _seedPromos() async {
    final snap = await FirebaseFirestore.instance
        .collection('notifikasi')
        .where('uid', isEqualTo: widget.uid)
        .where('tipe', isEqualTo: 'promo')
        .limit(1)
        .get();

    if (snap.docs.isEmpty) {
      final batch = FirebaseFirestore.instance.batch();
      
      final promos = [
        {
          'judul': 'Diskon 20% Soto Ayam Bu Sari 🍲',
          'pesan': 'Nikmati Soto Ayam hangat dari Kantin Bu Sari dengan potongan 20%! S&K Berlaku.',
          'icon': 'promo',
        },
        {
          'judul': 'Promo Jumat Berkah: Gratis Es Teh! 🥤',
          'pesan': 'Setiap pembelian menu utama minimal Rp 15.000 di kantin mana saja, dapatkan Es Teh gratis!',
          'icon': 'welcome',
        },
        {
          'judul': 'Cashback 50% Pembayaran QRIS 📱',
          'pesan': 'Bayar pesananmu menggunakan QRIS Dinamis dan dapatkan cashback poin s.d. 50 poin!',
          'icon': 'promo',
        },
        {
          'judul': 'Hejo-Hejo Snack Day! 🍪',
          'pesan': 'Beli snack mix di Snack Corner diskon Rp 3.000 khusus hari ini.',
          'icon': 'promo',
        },
        {
          'judul': 'Seafood Fiesta: Hemat Rp 10.000 🐟',
          'pesan': 'Beli Ikan Bakar atau Udang Bakar di Seafood Bu Tini dengan minimum pembelian Rp 25.000.',
          'icon': 'promo',
        },
      ];

      for (var promo in promos) {
        final docRef = FirebaseFirestore.instance.collection('notifikasi').doc();
        batch.set(docRef, {
          'uid': widget.uid,
          'judul': promo['judul'],
          'pesan': promo['pesan'],
          'tipe': 'promo',
          'icon': promo['icon'],
          'dibaca': false,
          'waktu': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF1a202c).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.confirmation_num_outlined, size: 40, color: Color(0xFF1a202c)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada voucher',
            style: TextStyle(fontSize: 16, color: Color(0xFF1a202c), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Voucher khusus untukmu akan muncul di sini',
            style: TextStyle(fontSize: 13, color: Color(0xFF4A5568)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<VoucherModel>>(
      stream: VoucherService.getUserVouchers(widget.uid),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(child: Text('Terjadi kesalahan: ${snap.error}', style: const TextStyle(color: Colors.white)));
        }
        if (!snap.hasData) {
          if (_timeout) {
            return _buildEmptyState();
          }
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        _timer?.cancel();

        final vouchers = snap.data!;
        
        final activeVouchers = vouchers.where((v) => v.status == 'active').toList();
        final usedVouchers = vouchers.where((v) => v.status == 'used').toList();
        final expiredVouchers = vouchers.where((v) => v.status == 'expired').toList();

        if (vouchers.isEmpty) {
          return _buildEmptyState();
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (activeVouchers.isNotEmpty) ...[
              _buildSectionHeader('Aktif', AppColors.success),
              const SizedBox(height: 8),
              ...activeVouchers.map((v) => _VoucherCard(voucher: v)),
              const SizedBox(height: 16),
            ],
            if (usedVouchers.isNotEmpty) ...[
              _buildSectionHeader('Terpakai', Colors.grey),
              const SizedBox(height: 8),
              ...usedVouchers.map((v) => _VoucherCard(voucher: v)),
              const SizedBox(height: 16),
            ],
            if (expiredVouchers.isNotEmpty) ...[
              _buildSectionHeader('Kadaluarsa', AppColors.danger),
              const SizedBox(height: 8),
              ...expiredVouchers.map((v) => _VoucherCard(voucher: v)),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1a202c),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _VoucherCard extends StatelessWidget {
  final VoucherModel voucher;
  const _VoucherCard({Key? key, required this.voucher}) : super(key: key);

  void _showVoucherDetails(BuildContext context, VoucherModel voucher) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.confirmation_num_rounded, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Detail Voucher', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text(voucher.code, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontFamily: 'monospace', letterSpacing: 1.2)),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32, thickness: 1),
              const Text('Keuntungan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text(
                'Potongan harga sebesar ${voucher.discountLabel}',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              const Text('Syarat & Ketentuan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              _skItem('Berlaku untuk semua metode pembayaran yang tersedia di FoodTrack.'),
              if (voucher.minPurchase > 0)
                _skItem('Minimum pembelian transaksi Rp ${voucher.minPurchase.toInt()}.')
              else
                _skItem('Tanpa minimum transaksi.'),
              _skItem('Voucher hanya berlaku hingga ${DateFormat('dd MMMM yyyy').format(voucher.expiry.toDate())}.'),
              _skItem('Penggunaan voucher tidak dapat digabungkan dengan promo lainnya.'),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: AppColors.primary),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tutup', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: voucher.code));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Kode voucher "${voucher.code}" berhasil disalin!'),
                            backgroundColor: AppColors.success,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: const Text('Salin Kode', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _skItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: AppColors.cyan, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = voucher.status;
    Color statusColor;
    String statusLabel;
    
    if (status == 'active') {
      statusColor = AppColors.success;
      statusLabel = 'Aktif';
    } else if (status == 'used') {
      statusColor = Colors.grey;
      statusLabel = 'Terpakai';
    } else {
      statusColor = AppColors.danger;
      statusLabel = 'Kadaluarsa';
    }

    final isExpired = voucher.isExpired;
    final isUsed = voucher.used;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Banner(
          message: statusLabel,
          location: BannerLocation.topEnd,
          color: statusColor,
          child: InkWell(
            onTap: () => _showVoucherDetails(context, voucher),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.confirmation_num_rounded,
                      color: statusColor,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          voucher.code,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1a202c),
                            letterSpacing: 1.2,
                            decoration: (isUsed || isExpired) ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Diskon ${voucher.discountLabel}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF3D5A80),
                          ),
                        ),
                        if (voucher.minPurchase > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Min. Belanja Rp${voucher.minPurchase.toInt()}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF4A5568),
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF718096)),
                            const SizedBox(width: 4),
                            Text(
                              'S/d ${DateFormat('dd MMM yyyy').format(voucher.expiry.toDate())}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF718096),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
