import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodtrack/theme/app_colors.dart';
import 'package:foodtrack/services/firestore_service.dart';
import 'package:foodtrack/pages/pedagang/menu_pedagang_page.dart';
import 'package:foodtrack/pages/pedagang/profil_pedagang_page.dart';
import 'package:foodtrack/theme/premium_background.dart';

class HomePedagangPage extends StatefulWidget {
  final String namaKantin, kantinId;
  const HomePedagangPage({
    super.key,
    required this.namaKantin,
    required this.kantinId,
  });

  @override
  State<HomePedagangPage> createState() => _HomePedagangPageState();
}

class _HomePedagangPageState extends State<HomePedagangPage>
    with SingleTickerProviderStateMixin {
  int _idx = 0;
  bool _isOpen = true;
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  String _fmt(int h) =>
      'Rp${h.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: IndexedStack(
          index: _idx,
          children: [
            _buildDashboard(),
            MenuPedagangPage(
              namaKantin: widget.namaKantin,
              kantinId: widget.kantinId,
            ),
            ProfilPedagangPage(namaKantin: widget.namaKantin),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.88),
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1.0,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _PNavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  active: _idx == 0,
                  onTap: () => setState(() => _idx = 0),
                ),
                _PNavItem(
                  icon: Icons.restaurant_menu_rounded,
                  label: 'Menu',
                  active: _idx == 1,
                  onTap: () => setState(() => _idx = 1),
                ),
                _PNavItem(
                  icon: Icons.person_rounded,
                  label: 'Profil',
                  active: _idx == 2,
                  onTap: () => setState(() => _idx = 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return Column(
      children: [
        // ===== HEADER =====
        Container(
          decoration: const BoxDecoration(
            gradient: AppColors.headerGradient,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.of(context).padding.top + 16,
            20,
            20,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dashboard Pedagang',
                          style: TextStyle(color: AppColors.cyan, fontSize: 12),
                        ),
                        Text(
                          widget.namaKantin,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          _formatTanggal(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Toggle buka/tutup
                  GestureDetector(
                    onTap: () => setState(() => _isOpen = !_isOpen),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _isOpen ? AppColors.danger : AppColors.success,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (_isOpen ? AppColors.danger : AppColors.success)
                                    .withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        _isOpen ? 'Tutup' : 'Buka',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Statistik hari ini
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('pesanan')
                    .where('kantin', isEqualTo: widget.namaKantin)
                    .snapshots(),
                builder: (ctx, snap) {
                  final docs = snap.data?.docs ?? [];
                  final total = docs.length;
                  final pemasukan = docs.fold<int>(0, (sum, d) {
                    final data = d.data() as Map<String, dynamic>;
                    return sum + (data['totalHarga'] as int? ?? 0);
                  });
                  final aktif = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return (data['statusIndex'] as int? ?? 0) < 3;
                  }).length;

                  return Row(
                    children: [
                      _StatBox(
                        label: 'Pesanan',
                        value: '$total',
                        icon: Icons.receipt_long_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      _StatBox(
                        label: 'Aktif',
                        value: '$aktif',
                        icon: Icons.pending_actions_rounded,
                        color: AppColors.cyan,
                      ),
                      const SizedBox(width: 10),
                      _StatBox(
                        label: 'Pemasukan',
                        value: _fmt(pemasukan),
                        icon: Icons.payments_rounded,
                        color: AppColors.success,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),

        // ===== TAB BAR =====
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.4),
                width: 1.0,
              ),
            ),
          ),
          child: TabBar(
            controller: _tab,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.cyan,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'Pesanan Aktif'),
              Tab(text: 'Selesai'),
            ],
          ),
        ),

        // ===== TAB CONTENT =====
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _PesananList(namaKantin: widget.namaKantin, selesai: false),
              _PesananList(namaKantin: widget.namaKantin, selesai: true),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTanggal() {
    final now = DateTime.now();
    const hari = ['', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const bln = [
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
    return '${hari[now.weekday]}, ${now.day} ${bln[now.month]} ${now.year}';
  }
}

// ===== DAFTAR PESANAN PEDAGANG (REALTIME) =====
// ✅ FIX 11: Query dipisah berdasarkan kondisi selesai/aktif
class _PesananList extends StatelessWidget {
  final String namaKantin;
  final bool selesai;
  const _PesananList({required this.namaKantin, required this.selesai});

  String _fmt(int h) =>
      'Rp${h.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  @override
  Widget build(BuildContext context) {
    // ✅ FIX 11: Query dipisah — selesai pakai isEqualTo(3), aktif pakai isLessThan(3)
    // ✅ FIX: Gunakan query sederhana untuk menghindari error "Missing Index" (Composite Index)
    final query = FirebaseFirestore.instance
        .collection('pesanan')
        .where('kantin', isEqualTo: namaKantin);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        // Handle error (misal: butuh composite index)
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.danger,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Gagal memuat data:\n${snap.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        var docs = snap.data?.docs ?? [];

        // ✅ FIX: Filter & Sort di sisi Client (Dart) agar tidak butuh index tambahan
        if (selesai) {
          docs = docs.where((d) => (d.data() as Map)['statusIndex'] == 3).toList();
        } else {
          docs = docs.where((d) => ((d.data() as Map)['statusIndex'] ?? 0) < 3).toList();
        }

        // Sort: Status dulu (aktif), lalu Waktu (terbaru)
        docs.sort((a, b) {
          final da = a.data() as Map;
          final db = b.data() as Map;
          if (!selesai) {
            int s = (da['statusIndex'] ?? 0).compareTo(db['statusIndex'] ?? 0);
            if (s != 0) return s;
          }
          final wa = da['waktuPesan'] as Timestamp?;
          final wb = db['waktuPesan'] as Timestamp?;
          return (wb?.seconds ?? 0).compareTo(wa?.seconds ?? 0);
        });

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.cyanLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    selesai
                        ? Icons.check_circle_outline_rounded
                        : Icons.receipt_long_outlined,
                    size: 32,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  selesai
                      ? 'Belum ada pesanan selesai'
                      : 'Belum ada pesanan aktif',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final docId = docs[i].id;
            final statusIdx = data['statusIndex'] as int? ?? 0;
            final noAntrian = data['noAntrian'] ?? 0;
            final items =
                (data['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];

            // Logika warna & label status
            final Color sc = statusIdx == 0
                ? AppColors.primary
                : statusIdx == 1
                    ? AppColors.warning
                    : AppColors.success;

            final String sl = statusIdx == 0
                ? 'Diterima'
                : statusIdx == 1
                    ? 'Dimasak'
                    : statusIdx == 2
                        ? 'Siap'
                        : 'Selesai';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: AppColors.premiumCardDeco(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: 16,
              ).copyWith(
                border: Border.all(
                  color: sc.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // No antrian
                    Stack(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: statusIdx == 0 ? AppColors.cyanLight : AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              '$noAntrian',
                              style: TextStyle(
                                color: statusIdx == 0 ? AppColors.primary : AppColors.cyan,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        if (statusIdx == 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: AppColors.danger,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Items
                          ...items.take(2).map(
                                (item) => Text(
                                  '${item['qty']}x ${item['nama']}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                          if (items.length > 2)
                            Text(
                              '+${items.length - 2} lagi',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textHint,
                              ),
                            ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                _fmt(data['totalHarga'] as int? ?? 0),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '• ${data['metode'] ?? '-'}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textHint,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: sc.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: sc.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              sl,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: sc,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Tombol aksi
                    if (!selesai)
                      Column(
                        children: [
                          if (statusIdx == 0)
                            _AksiBtn(
                              label: 'Masak',
                              color: AppColors.warning,
                              onTap: () => _updateStatus(
                                docId: docId,
                                status: 1,
                                buyerUid: data['uid'],
                                noAntrian: data['noAntrian'],
                                kantin: data['kantin'],
                              ),
                            ),
                          if (statusIdx == 1)
                            _AksiBtn(
                              label: 'Siap',
                              color: AppColors.success,
                              onTap: () => _updateStatus(
                                docId: docId,
                                status: 2,
                                buyerUid: data['uid'],
                                noAntrian: data['noAntrian'],
                                kantin: data['kantin'],
                              ),
                            ),
                          if (statusIdx == 2)
                            _AksiBtn(
                              label: 'Selesai',
                              color: Colors.grey,
                              onTap: () => _updateStatus(
                                docId: docId,
                                status: 3,
                                buyerUid: data['uid'],
                                noAntrian: data['noAntrian'],
                                kantin: data['kantin'],
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _updateStatus({
    required String docId,
    required int status,
    required String buyerUid,
    required int noAntrian,
    required String kantin,
  }) async {
    // 1️⃣ Update status pesanan
    await FirebaseFirestore.instance.collection('pesanan').doc(docId).update({
      'statusIndex': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 2️⃣ Kirim notifikasi ke pembeli
    String judul = '';
    String pesan = '';
    String icon = '';

    if (status == 1) {
      judul = 'Pesanan Sedang Dimasak 🍳';
      pesan = 'Pesanan antrian $noAntrian sedang diproses di $kantin.';
      icon = 'cook';
    } else if (status == 2) {
      judul = 'Pesanan Siap Diambil! 🎉';
      pesan = 'Antrian $noAntrian sudah siap. Yuk ambil di $kantin sekarang!';
      icon = 'ready';
    } else if (status == 3) {
      judul = 'Pesanan Selesai ✨';
      pesan = 'Terima kasih sudah belanja di $kantin! Selamat menikmati.';
      icon = 'done';
    }

    if (judul.isNotEmpty) {
      await FirestoreService.simpanNotifikasi(
        targetUid: buyerUid,
        judul: judul,
        pesan: pesan,
        tipe: 'pesanan',
        icon: icon,
        pesananId: docId,
      );
    }
  }
}

// ===== TOMBOL AKSI =====
class _AksiBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _AksiBtn({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 6),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ===== BOX STATISTIK =====
class _StatBox extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== NAVIGATION ITEM =====
class _PNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _PNavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? AppColors.cyan : Colors.white38, size: 24),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: active ? AppColors.cyan : Colors.white38,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 2),
          if (active)
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.cyan,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
