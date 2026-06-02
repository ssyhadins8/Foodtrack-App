import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodtrack/theme/app_colors.dart';
import 'package:foodtrack/theme/premium_background.dart';
import 'package:foodtrack/pages/kantin_detail_page.dart';
import 'package:foodtrack/widgets/queue_badge.dart';

class CompareFoodcourtPage extends StatelessWidget {
  const CompareFoodcourtPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        title: const Text(
          'Status Antrean Foodcourt',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: PremiumBackground(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('kantin').snapshots(),
          builder: (context, kantinSnap) {
            if (kantinSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (!kantinSnap.hasData || kantinSnap.data!.docs.isEmpty) {
              return const Center(child: Text('Kantin tidak ditemukan', style: TextStyle(color: Colors.white)));
            }

            final kantins = kantinSnap.data!.docs;

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pesanan')
                  .where('statusIndex', isLessThan: 3)
                  .snapshots(),
              builder: (context, pesananSnap) {
                if (pesananSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                // Map of active orders by canteen ID / name
                final Map<String, int> activeCountMap = {};
                if (pesananSnap.hasData) {
                  for (var doc in pesananSnap.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final kId = data['kantinId'] as String? ?? '';
                    final kName = data['kantin'] as String? ?? '';
                    if (kId.isNotEmpty) {
                      activeCountMap[kId] = (activeCountMap[kId] ?? 0) + 1;
                    } else if (kName.isNotEmpty) {
                      activeCountMap[kName] = (activeCountMap[kName] ?? 0) + 1;
                    }
                  }
                }

                // Group canteens and orders by foodcourt
                final lamaKantins = <Map<String, dynamic>>[];
                final baruKantins = <Map<String, dynamic>>[];
                int lamaOrders = 0;
                int baruOrders = 0;

                for (var doc in kantins) {
                  final data = doc.data() as Map<String, dynamic>;
                  final id = doc.id;
                  final foodcourtId = data['foodcourtId'] ?? 'lama';
                  final count = activeCountMap[id] ?? activeCountMap[data['nama']] ?? 0;

                  final kMap = {
                    'id': id,
                    'nama': data['nama'] ?? '',
                    'gambar': data['gambar'] ?? 'images/kantin1.jpg',
                    'rating': (data['rating'] as num?)?.toDouble() ?? 4.5,
                    'foodcourtId': foodcourtId,
                    'foodcourtLabel': data['foodcourtLabel'] ?? 'Foodcourt Lama',
                    'waktu': count >= 7 ? '20-25 mnt 🔴' : (count >= 3 ? '10-15 mnt 🟡' : '5-10 mnt 🟢'),
                    'totalMenu': 0, // dynamic menu count is not strictly necessary for comparison, but we can set 0 or fetch
                    'activeCount': count,
                  };

                  if (foodcourtId == 'baru') {
                    baruKantins.add(kMap);
                    baruOrders += count;
                  } else {
                    lamaKantins.add(kMap);
                    lamaOrders += count;
                  }
                }

                // Calculate crowd status text for each foodcourt
                String getCrowdLevel(int totalOrders, int canteenCount) {
                  if (canteenCount == 0) return 'Sepi';
                  final avg = totalOrders / canteenCount;
                  if (avg >= 3) return 'Penuh';
                  if (avg >= 1) return 'Ramai';
                  return 'Sepi';
                }

                final lamaStatus = getCrowdLevel(lamaOrders, lamaKantins.length);
                final baruStatus = getCrowdLevel(baruOrders, baruKantins.length);

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        height: 140,
                        decoration: const BoxDecoration(
                          gradient: AppColors.headerGradient,
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Introduction text
                          const Text(
                            'Mana Foodcourt yang Lebih Sepi?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Pilih foodcourt dengan antrean lebih sedikit untuk menghemat waktu makan siangmu.',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 20),

                          // SIDE-BY-SIDE SUMMARY CARDS
                          Row(
                            children: [
                              // Foodcourt Lama Card
                              Expanded(
                                child: _buildFoodcourtSummaryCard(
                                  title: 'Foodcourt Lama',
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF1A365D), Colors.white],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  totalOrders: lamaOrders,
                                  statusLabel: lamaStatus,
                                  kantinCount: lamaKantins.length,
                                ),
                              ),
                              const SizedBox(width: 14),
                              // Foodcourt Baru Card
                              Expanded(
                                child: _buildFoodcourtSummaryCard(
                                  title: 'Foodcourt Baru',
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF3D5A80), Colors.white],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  totalOrders: baruOrders,
                                  statusLabel: baruStatus,
                                  kantinCount: baruKantins.length,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // RECOMMENDATION BANNER
                          _buildRecommendationBanner(
                            lamaOrders: lamaOrders,
                            lamaCount: lamaKantins.length,
                            baruOrders: baruOrders,
                            baruCount: baruKantins.length,
                          ),
                          const SizedBox(height: 28),

                          // FOODCOURT DETAIL LISTS
                          const Text(
                            'Daftar Kantin & Antrean',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),

                          _buildFoodcourtSectionHeader('Foodcourt Lama', const Color(0xFF3D5A80)),
                          const SizedBox(height: 8),
                          if (lamaKantins.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text('Tidak ada kantin', style: TextStyle(color: Colors.grey, fontSize: 13)),
                            )
                          else
                            ...lamaKantins.map((k) => _CompareKantinRow(kantin: k)),

                          const SizedBox(height: 24),

                          _buildFoodcourtSectionHeader('Foodcourt Baru', const Color(0xFF3D5A80)),
                          const SizedBox(height: 8),
                          if (baruKantins.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text('Tidak ada kantin', style: TextStyle(color: Colors.grey, fontSize: 13)),
                            )
                          else
                            ...baruKantins.map((k) => _CompareKantinRow(kantin: k)),

                          const SizedBox(height: 40),
                        ]),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFoodcourtSummaryCard({
    required String title,
    required Gradient gradient,
    required int totalOrders,
    required String statusLabel,
    required int kantinCount,
  }) {
    Color statusBgColor;
    Color statusTextColor;
    IconData statusIcon;

    switch (statusLabel) {
      case 'Penuh':
        statusBgColor = const Color(0xFF1A365D); // Deep Navy
        statusTextColor = Colors.white;
        statusIcon = Icons.people_rounded;
        break;
      case 'Ramai':
        statusBgColor = const Color(0xFF3D5A80); // Slate Blue
        statusTextColor = Colors.white;
        statusIcon = Icons.people_outline_rounded;
        break;
      default: // Sepi
        statusBgColor = const Color(0xFFE2E8F0); // Light Grayish Blue
        statusTextColor = const Color(0xFF1A365D); // Deep Navy Text
        statusIcon = Icons.check_circle_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                '$totalOrders',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'antrean',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: statusTextColor, size: 12),
                const SizedBox(width: 4),
                Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Dari $kantinCount kantin aktif',
            style: const TextStyle(
              color: Color(0xFF1A365D),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationBanner({
    required int lamaOrders,
    required int lamaCount,
    required int baruOrders,
    required int baruCount,
  }) {
    if (lamaCount == 0 || baruCount == 0) return const SizedBox.shrink();

    final avgLama = lamaOrders / lamaCount;
    final avgBaru = baruOrders / baruCount;

    String target = '';
    String recText = '';
    final recColor = const Color(0xFF3D5A80);

    if (avgLama < avgBaru) {
      target = 'Foodcourt Lama';
      recText = 'antrean rata-rata lebih sedikit di sini!';
    } else if (avgBaru < avgLama) {
      target = 'Foodcourt Baru';
      recText = 'antrean rata-rata lebih sedikit di sini!';
    } else {
      target = 'Keduanya Setara';
      recText = 'tingkat antrean rata-rata di kedua foodcourt sama.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppColors.premiumCardDeco(
        color: recColor.withValues(alpha: 0.08),
        borderRadius: 16,
      ).copyWith(
        border: Border.all(color: recColor.withValues(alpha: 0.2), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: recColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.tips_and_updates_rounded, color: recColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rekomendasi FoodTrack',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                    children: [
                      TextSpan(
                        text: '$target: ',
                        style: TextStyle(fontWeight: FontWeight.bold, color: recColor),
                      ),
                      TextSpan(text: recText),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodcourtSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _CompareKantinRow extends StatelessWidget {
  final Map<String, dynamic> kantin;
  const _CompareKantinRow({Key? key, required this.kantin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: AppColors.premiumCardDeco(
        color: Colors.white,
        borderRadius: 14,
        showBorder: true,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => KantinDetailPage(kantin: kantin)),
          );
        },
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            kantin['gambar'],
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 50,
              height: 50,
              color: AppColors.cyanLight,
              child: const Icon(Icons.restaurant, color: AppColors.primary, size: 20),
            ),
          ),
        ),
        title: Text(
          kantin['nama'],
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Row(
          children: [
            const Icon(Icons.access_time_rounded, size: 12, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              kantin['waktu'],
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        trailing: QueueBadge(kantinId: kantin['id']),
      ),
    );
  }
}
