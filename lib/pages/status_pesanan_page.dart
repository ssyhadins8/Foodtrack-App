import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodtrack/theme/app_colors.dart';
import 'package:foodtrack/theme/premium_background.dart';
import 'package:foodtrack/services/firestore_service.dart';

class StatusPesananPage extends StatelessWidget {
  final String docId;
  const StatusPesananPage({super.key, required this.docId});

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
      'Des'
    ];
    return '${dt.day} ${b[dt.month]} ${dt.year} • '
        '${dt.hour.toString().padLeft(2, '0')}.'
        '${dt.minute.toString().padLeft(2, '0')} WIB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pesanan')
            .doc(docId)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (!snap.hasData || !snap.data!.exists) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: AppColors.premiumCardDeco(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.95),
                    borderRadius: 24,
                  ).copyWith(
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          color: Colors.red,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Pesanan Tidak Ditemukan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Maaf, detail pesanan ini tidak dapat ditemukan. Kemungkinan pesanan telah dihapus atau diarsipkan oleh sistem saat migrasi database.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Kembali',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final data = snap.data!.data() as Map<String, dynamic>;
          final statusIndex = data['statusIndex'] as int? ?? 0;
          final noAntrian = data['noAntrian'] ?? 0;
          final kantin = data['kantin'] ?? '-';
          final metode = data['metode'] ?? '-';
          final totalHarga = data['totalHarga'] as int? ?? 0;
          final items = (data['items'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map<String, dynamic>)).toList() ?? [];
          final waktu =
              (data['waktuPesan'] as Timestamp?)?.toDate() ?? DateTime.now();

          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                pinned: true,
                expandedHeight: 220,
                backgroundColor: AppColors.primary,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.secondary,
                          AppColors.tertiary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.cyan, width: 2.5),
                              ),
                              child: Center(
                                child: Text('$noAntrian',
                                    style: const TextStyle(
                                        color: AppColors.cyan,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('No. Antrian',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 2),
                            Text(kantin,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // STATUS TRACKER — Realtime
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: AppColors.premiumCardDeco(borderRadius: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Container(
                                width: 4,
                                height: 18,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.primary, AppColors.cyan],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text('Status Pesanan',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary)),
                            ]),
                            const SizedBox(height: 20),

                            // Step 1
                            _StatusStep(
                              step: 1,
                              title: 'Pesanan Diterima',
                              subtitle: 'Pesananmu sudah masuk ke sistem',
                              isActive: statusIndex >= 0,
                              isDone: statusIndex > 0,
                              isLast: false,
                              color: AppColors.primary,
                              time: statusIndex >= 0 ? _tgl(waktu) : null,
                            ),

                            // Step 2
                            _StatusStep(
                              step: 2,
                              title: 'Sedang Dimasak',
                              subtitle: items.isNotEmpty
                                  ? items.map((i) => '${i['nama']}').join(' + ')
                                  : 'Pesananmu sedang diproses',
                              isActive: statusIndex >= 1,
                              isDone: statusIndex > 1,
                              isLast: false,
                              color: AppColors.warning,
                              time: statusIndex >= 1 ? 'Dalam proses...' : null,
                            ),

                            // Step 3
                            _StatusStep(
                              step: 3,
                              title: 'Siap Diambil',
                              subtitle: 'Silakan ambil pesananmu di $kantin',
                              isActive: statusIndex >= 2,
                              isDone: statusIndex > 2,
                              isLast: false,
                              color: AppColors.success,
                              time: statusIndex >= 2 ? 'Segera ambil!' : null,
                            ),

                            // Step 4
                            _StatusStep(
                              step: 4,
                              title: 'Selesai',
                              subtitle: 'Makanan sudah diambil',
                              isActive: statusIndex >= 3,
                              isDone: statusIndex >= 3,
                              isLast: true,
                              color: Colors.grey,
                              time: statusIndex >= 3
                                  ? 'Selamat menikmati! 🎉'
                                  : null,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // INFO PESANAN
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: AppColors.premiumCardDeco(borderRadius: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Container(
                                width: 4,
                                height: 18,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.primary, AppColors.cyan],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text('Ringkasan Pesanan',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary)),
                            ]),
                            const SizedBox(height: 16),

                            // Items
                            ...items.map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        item['gambar'] ?? '',
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  AppColors.primary,
                                                  AppColors.secondary
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                                Icons.fastfood_rounded,
                                                color: Colors.white54,
                                                size: 22)),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(item['nama'] ?? '',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary)),
                                        Text('${item['qty']} porsi',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.textHint)),
                                      ],
                                    )),
                                    Text(
                                        _fmt((item['harga'] as int) *
                                            (item['qty'] as int)),
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary)),
                                  ]),
                                )),

                            const Divider(height: 20),

                            // Metode + Total
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Metode Bayar',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary)),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.cyanLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(metode,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Pembayaran',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary)),
                                Text(_fmt(totalHarga),
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary)),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Status badge
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: statusIndex < 3
                                      ? [AppColors.primary, AppColors.secondary]
                                      : [
                                          AppColors.success,
                                          const Color(0xFF059669)
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                statusIndex == 0
                                    ? 'Pesanan Diterima ✅'
                                    : statusIndex == 1
                                        ? 'Sedang Dimasak 🍳'
                                        : statusIndex == 2
                                            ? 'Siap Diambil! 🎉'
                                            : 'Selesai ✨',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (statusIndex == 3) ...[
                        const SizedBox(height: 16),
                        _buildUlasanSection(context, data),
                      ],
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/home', (route) => false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.08),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: AppColors.cyan.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.home_rounded, color: AppColors.cyan, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Kembali ke Beranda',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      ),
    );
  }

  Widget _buildUlasanSection(BuildContext context, Map<String, dynamic> data) {
    final ulasanDiberikan = data['ulasanDiberikan'] as bool? ?? false;
    final kantinNama = data['kantin'] ?? 'Kantin';

    if (ulasanDiberikan) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: AppColors.premiumCardDeco(
          borderRadius: 20,
          color: AppColors.success.withOpacity(0.08),
        ).copyWith(
          border: Border.all(
            color: AppColors.success.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: const Column(
          children: [
            Icon(Icons.stars_rounded, color: AppColors.success, size: 40),
            SizedBox(height: 10),
            Text(
              'Ulasan Dikirim!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Terima kasih telah memberikan ulasan untuk kantin ini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppColors.premiumCardDeco(borderRadius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rate_review_rounded, color: AppColors.cyan, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Bagaimana Rasa Makanan di $kantinNama?',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Ketuk bintang di bawah ini untuk memberikan penilaian Anda.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  _showKomentarBottomSheet(context, index + 1.0, kantinNama);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    Icons.star_outline_rounded,
                    size: 40,
                    color: Colors.amber.withOpacity(0.4),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showKomentarBottomSheet(
      BuildContext context, double initialRating, String kantinNama) {
    double selectedRating = initialRating;
    final TextEditingController komentarController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(
                  top: BorderSide(color: AppColors.cyan.withOpacity(0.2), width: 1.5),
                  left: BorderSide(color: AppColors.cyan.withOpacity(0.2), width: 1.5),
                  right: BorderSide(color: AppColors.cyan.withOpacity(0.2), width: 1.5),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Berikan Ulasan untuk $kantinNama',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starValue = index + 1.0;
                        final active = starValue <= selectedRating;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedRating = starValue;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              active ? Icons.star_rounded : Icons.star_outline_rounded,
                              size: 44,
                              color: active ? Colors.amber : Colors.grey.shade600,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Tulis Komentar Anda',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: komentarController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Tulis komentar Anda di sini (opsional)...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.cyan),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white70,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => const Center(
                                  child: CircularProgressIndicator(color: AppColors.primary),
                                ),
                              );

                              try {
                                await FirestoreService.tambahUlasan(
                                  pesananId: docId,
                                  kantinNama: kantinNama,
                                  rating: selectedRating,
                                  komentar: komentarController.text.trim(),
                                );
                                if (context.mounted) Navigator.pop(context);
                                if (context.mounted) Navigator.pop(context);
                                
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Ulasan berhasil dikirim! ⭐'),
                                      backgroundColor: AppColors.success,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) Navigator.pop(context);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Gagal mengirim ulasan: $e'),
                                      backgroundColor: AppColors.danger,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Kirim Ulasan',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
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
}

// ===== STATUS STEP WIDGET =====
class _StatusStep extends StatelessWidget {
  final int step;
  final String title, subtitle;
  final bool isActive, isDone, isLast;
  final Color color;
  final String? time;

  const _StatusStep({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.isDone,
    required this.isLast,
    required this.color,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indikator
        Column(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isActive ? color : Colors.grey.shade200,
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1)
                    ]
                  : [],
            ),
            child: Center(
              child: isActive
                  ? Icon(
                      isDone
                          ? Icons.check_rounded
                          : Icons.radio_button_on_rounded,
                      color: Colors.white,
                      size: isDone ? 20 : 14,
                    )
                  : Text('$step',
                      style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
            ),
          ),
          if (!isLast)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 2,
              height: 44,
              decoration: BoxDecoration(
                gradient: isActive
                    ? LinearGradient(
                        colors: [color, color.withOpacity(0.3)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : null,
                color: isActive ? null : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ]),
        const SizedBox(width: 14),

        // Konten
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(title,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isActive
                            ? AppColors.textPrimary
                            : Colors.grey.shade400)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12,
                        color: isActive
                            ? AppColors.textSecondary
                            : Colors.grey.shade400)),
                if (time != null && isActive) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Text(time!,
                        style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
