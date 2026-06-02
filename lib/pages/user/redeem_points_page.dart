import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodtrack/services/loyalty_service.dart';
import 'package:foodtrack/theme/app_colors.dart';

class RedeemPointsPage extends StatefulWidget {
  const RedeemPointsPage({super.key});

  @override
  State<RedeemPointsPage> createState() => _RedeemPointsPageState();
}

class _RedeemPointsPageState extends State<RedeemPointsPage> {
  late final String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> _confirmRedeem(BuildContext context, int pointsCost, int voucherValue) async {
    if (currentUserId == null) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Konfirmasi Tukar Poin',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        content: Text(
          "Apakah Anda yakin ingin menukarkan $pointsCost poin dengan voucher senilai Rp ${voucherValue.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}?",
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Tukar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await LoyaltyService.redeemPoints(currentUserId!, pointsCost, voucherValue, null);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Voucher berhasil dibuat! Cek tab Voucher di Notifikasi.',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tukar Poin'),
          backgroundColor: AppColors.primary,
        ),
        body: const Center(
          child: Text('Pengguna tidak terdeteksi. Silakan login kembali.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tukar Poin',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.bgGradient,
        ),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.hasError) {
              return Center(child: Text('Terjadi kesalahan: ${userSnapshot.error}'));
            }
            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const Center(child: CircularProgressIndicator(color: Colors.teal));
            }

            final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
            final userPoints = userData?['loyaltyPoints'] as int? ?? 0;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header card with teal background
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1a202c),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Poin Anda Saat Ini',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '$userPoints',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'pts',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFF1a202c),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // INFORMATIONAL CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.teal.withOpacity(0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: Colors.teal,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Bagaimana Sistem Poin Bekerja?',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20, thickness: 1),
                        const Text(
                          '• Anda otomatis mengumpulkan 10 poin setiap kali menyelesaikan transaksi pembelian makanan atau minuman melalui aplikasi FoodTrack.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '• Poin yang terkumpul dapat ditukarkan dengan berbagai voucher potongan belanja belanja (Rp 5.000, Rp 12.000, atau Rp 25.000).',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '• Voucher hasil penukaran poin akan langsung masuk ke tab "Voucher Saya" di menu Notifikasi Anda dan otomatis dapat digunakan saat checkout berikutnya.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section 'Tukar Poin'
                  const Text(
                    'Tukar Poin',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 3 Option Cards in a Grid
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                    children: [
                      _buildOptionCard(context, 50, 5000, userPoints),
                      _buildOptionCard(context, 100, 12000, userPoints),
                      _buildOptionCard(context, 200, 25000, userPoints),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // Section 'Riwayat Poin'
                  const Text(
                    'Riwayat Poin',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Builder(
                    builder: (context) {
                      Stream<QuerySnapshot>? stream;
                      try {
                        stream = FirebaseFirestore.instance
                            .collection('loyaltyTransactions')
                            .where('userId', isEqualTo: currentUserId)
                            .orderBy('createdAt', descending: true)
                            .snapshots();
                      } catch (e) {
                        return const Center(
                          child: Text(
                            'Riwayat poin akan segera tersedia.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        );
                      }

                      return StreamBuilder<QuerySnapshot>(
                        stream: stream,
                        builder: (context, transSnapshot) {
                          if (transSnapshot.hasError) {
                            return const Center(
                              child: Text(
                                'Riwayat poin akan segera tersedia.',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            );
                          }
                          if (!transSnapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(color: Colors.teal),
                            );
                          }

                      final docs = transSnapshot.data!.docs;
                      if (docs.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          decoration: AppColors.premiumCardDeco(
                            borderRadius: 16,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history_rounded,
                                color: Colors.grey.shade400,
                                size: 40,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Belum ada riwayat transaksi poin.',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          final type = data['type'] as String? ?? 'Pembelian';
                          final points = data['points'] as int? ?? 0;
                          final createdAt = data['createdAt'] as Timestamp?;
                          
                          // Format Date
                          String dateStr = '-';
                          if (createdAt != null) {
                            final date = createdAt.toDate();
                            dateStr = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
                          }

                          final isAdd = type == 'Pembelian';
                          final label = isAdd ? 'Pembelian' : 'Penukaran';
                          final color = isAdd ? AppColors.success : AppColors.danger;
                          final sign = isAdd ? '+' : '';

                          return Container(
                            decoration: AppColors.premiumCardDeco(
                              borderRadius: 16,
                              color: Colors.white,
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isAdd ? Icons.add_rounded : Icons.remove_rounded,
                                  color: color,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  dateStr,
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              trailing: Text(
                                '$sign$points pts',
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, int pointsCost, int voucherValue, int userPoints) {
    final bool canRedeem = userPoints >= pointsCost;
    
    // Formatting currency to string like Rp 5.000
    final String valStr = "Rp ${voucherValue.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";

    return Container(
      decoration: AppColors.premiumCardDeco(
        borderRadius: 16,
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text(
                '$pointsCost Pts',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                valStr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D9E75),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFF1a202c),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star_rounded,
              color: Colors.amber,
              size: 18,
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              onPressed: canRedeem ? () => _confirmRedeem(context, pointsCost, voucherValue) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1a202c),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade200,
                disabledForegroundColor: Colors.grey.shade400,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'Tukar',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
