import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodtrack/models/promo_model.dart';
import 'package:foodtrack/theme/app_colors.dart';
import 'package:foodtrack/theme/premium_background.dart';
import 'package:foodtrack/pages/kantin_detail_page.dart';
import 'package:intl/intl.dart';

class PromoDetailPage extends StatelessWidget {
  final PromoModel promo;

  const PromoDetailPage({Key? key, required this.promo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final endDateDt = promo.endDate.toDate();
    final formattedExpiry = DateFormat('dd MMMM yyyy').format(endDateDt);

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
          'Detail Promo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: PremiumBackground(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Promo Hero Image
              Stack(
                children: [
                  Hero(
                    tag: 'promo_img_${promo.id}',
                    child: Image.network(
                      promo.imageUrl,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: double.infinity,
                        height: 250,
                        color: AppColors.cyanLight,
                        child: const Icon(Icons.local_offer_rounded, size: 60, color: AppColors.primary),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black54, Colors.transparent, Colors.black.withOpacity(0.8)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: promo.foodcourtId == 'baru' ? const Color(0xFFFF7F50) : const Color(0xFF1D9E75),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            promo.foodcourtLabel,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.timer_outlined, color: Colors.yellowAccent, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                endDateDt.difference(DateTime.now()).inDays < 1 ? 'Hari Ini!' : '${endDateDt.difference(DateTime.now()).inDays} hari lagi',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. Title & Discount
                    Text(
                      promo.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_offer, color: AppColors.accentOrange, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Diskon ${promo.discountLabel}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 3. Kantin Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppColors.premiumCardDeco(
                        color: Colors.white,
                        borderRadius: 16,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.cyanLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.storefront_rounded, color: AppColors.primary),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  promo.kantinName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  promo.foodcourtLabel,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onPressed: () async {
                              final doc = await FirebaseFirestore.instance.collection('kantin').doc(promo.kantinId).get();
                              if (doc.exists && context.mounted) {
                                final data = doc.data() as Map<String, dynamic>;
                                final kMap = {
                                  'id': doc.id,
                                  'nama': data['nama'] ?? '',
                                  'gambar': data['gambar'] ?? 'images/kantin1.jpg',
                                  'rating': (data['rating'] as num?)?.toDouble() ?? 4.5,
                                  'isTop': data['isTop'] ?? false,
                                  'waktu': '5-10 mnt 🟢',
                                  'totalMenu': 0,
                                  'foodcourtId': data['foodcourtId'] ?? 'lama',
                                  'foodcourtLabel': data['foodcourtLabel'] ?? 'Foodcourt Lama',
                                };
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => KantinDetailPage(kantin: kMap)),
                                );
                              }
                            },
                            child: const Text('Kunjungi', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 4. Deskripsi
                    const Text(
                      'Deskripsi Promo',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      promo.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 5. Masa Berlaku & Min Purchase
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Min. Pembelian', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(
                                promo.minPurchase > 0 ? 'Rp${NumberFormat('#,###').format(promo.minPurchase)}' : 'Tidak Ada',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Berlaku Hingga', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(
                                formattedExpiry,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 6. Syarat & Ketentuan
                    const Text(
                      'Syarat & Ketentuan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        promo.terms.isNotEmpty ? promo.terms : 'Berlaku syarat & ketentuan standar FoodTrack.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade800,
                          height: 1.4,
                        ),
                      ),
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
