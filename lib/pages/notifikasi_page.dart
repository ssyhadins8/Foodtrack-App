import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodtrack/theme/app_colors.dart';
import 'package:foodtrack/services/firestore_service.dart';
import 'package:foodtrack/pages/status_pesanan_page.dart';
import 'package:foodtrack/theme/premium_background.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage>
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
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tab,
          labelColor: AppColors.cyan,
          unselectedLabelColor: Colors.white54,
          indicatorColor: AppColors.cyan,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'Pesanan'),
            Tab(text: 'Promo'),
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
                  _NotifTab(uid: uid, tipe: 'promo'),
                  _NotifTab(uid: uid, tipe: 'aktivitas'),
                ],
              ),
      ),
    );
  }
}

class _NotifTab extends StatelessWidget {
  final String uid, tipe;
  const _NotifTab({required this.uid, required this.tipe});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifikasi')
          .where('uid', isEqualTo: uid)
          .where('tipe', isEqualTo: tipe)
          .snapshots(includeMetadataChanges: true),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        // ✅ Urutkan secara lokal (Client-side) untuk menghindari error 'Missing Index'
        final docs = snap.data?.docs ?? [];
        final sortedDocs = List.from(docs);
        sortedDocs.sort((a, b) {
          final ta = a['waktu'] as Timestamp?;
          final tb = b['waktu'] as Timestamp?;
          if (ta == null || tb == null) return 0;
          return tb.compareTo(ta);
        });

        if (sortedDocs.isEmpty) {
          return Center(
            child: TweenAnimationBuilder(
              duration: const Duration(milliseconds: 600),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double val, child) => Opacity(
                opacity: val,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - val)),
                  child: child,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.cyanLight.withOpacity(0.5),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyan.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      size: 50,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Belum ada notifikasi',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tipe == 'pesanan'
                        ? 'Update pesananmu akan muncul di sini'
                        : 'Info terbaru akan muncul di sini',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          itemCount: sortedDocs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final doc = sortedDocs[i];
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
      return '${dt.hour.toString().padLeft(2, '0')}.${dt.minute.toString().padLeft(2, '0')} WIB';
    }
    return '';
  }

  IconData get _icon {
    switch (data['icon']) {
      case 'ready': return Icons.check_circle_rounded;
      case 'cook': return Icons.restaurant_rounded;
      case 'receipt': return Icons.receipt_long_rounded;
      case 'done': return Icons.done_all_rounded;
      case 'promo': return Icons.local_offer_rounded;
      case 'profile': return Icons.person_rounded;
      case 'welcome': return Icons.waving_hand_rounded;
      default: return Icons.info_rounded;
    }
  }

  Color get _iconColor {
    switch (data['icon']) {
      case 'ready': return AppColors.success;
      case 'cook': return AppColors.warning;
      case 'receipt': return AppColors.primary;
      case 'done': return AppColors.textSecondary;
      case 'promo': return const Color(0xFFF97316);
      case 'profile': return AppColors.secondary;
      case 'welcome': return AppColors.cyan;
      default: return AppColors.textHint;
    }
  }

  Color get _iconBg {
    switch (data['icon']) {
      case 'ready': return const Color(0xFFD1FAE5);
      case 'cook': return const Color(0xFFFEF3C7);
      case 'receipt': return AppColors.cyanLight;
      case 'done': return Colors.grey.shade100;
      case 'promo': return const Color(0xFFFFF7ED);
      case 'profile': return const Color(0xFFE8F4FD);
      case 'welcome': return AppColors.cyanLight;
      default: return Colors.grey.shade100;
    }
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
        if (pesananId != null && pesananId.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StatusPesananPage(docId: pesananId),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppColors.premiumCardDeco(
          color: dibaca ? Colors.white.withValues(alpha: 0.85) : const Color(0xEBF0F9FF),
          borderRadius: 16,
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
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: dibaca ? FontWeight.w500 : FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (tag != null && tagColor != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: tagColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: tagColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: tagColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['pesan'] ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 11, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        _fmtWaktu(data['waktu']),
                        style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                      ),
                      const Spacer(),
                      if (!dibaca)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: AppColors.cyan, shape: BoxShape.circle),
                        ),
                    ],
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
