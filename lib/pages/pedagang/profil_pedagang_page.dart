import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodtrack/theme/app_colors.dart';
import 'package:foodtrack/theme/premium_background.dart';

class ProfilPedagangPage extends StatefulWidget {
  final String namaKantin;
  final String kantinId;
  const ProfilPedagangPage({
    super.key,
    required this.namaKantin,
    required this.kantinId,
  });

  @override
  State<ProfilPedagangPage> createState() => _ProfilPedagangPageState();
}

class _ProfilPedagangPageState extends State<ProfilPedagangPage> {
  String _rekapFilter = 'Hari Ini';

  @override
  Widget build(BuildContext context) {
    final namaKantin = widget.namaKantin;
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '-';
    final nama = user?.displayName ?? email.split('@')[0];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: SingleChildScrollView(
          child: Column(
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.headerGradient,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + 20,
                20,
                28,
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.cyan, width: 2.5),
                    ),
                    child: Center(
                      child: Text(
                        nama[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    nama,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.cyan.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.store_rounded,
                          color: AppColors.cyan,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          namaKantin,
                          style: const TextStyle(
                            color: AppColors.cyan,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Rekap
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pesanan')
                  .where('kantin', isEqualTo: namaKantin)
                  .snapshots(),
              builder: (ctx, snap) {
                var docs = snap.data?.docs ?? [];

                final now = DateTime.now();
                final startOfToday = DateTime(now.year, now.month, now.day);
                final startOfMonth = DateTime(now.year, now.month, 1);

                docs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final bool matchesKantin = data['kantinId'] == widget.kantinId || data['kantin'] == widget.namaKantin;
                  if (!matchesKantin) return false;

                  final timestamp = data['waktuPesan'] as Timestamp? ?? data['createdAt'] as Timestamp?;
                  if (timestamp == null) return false;
                  final date = timestamp.toDate();

                  if (_rekapFilter == 'Hari Ini') {
                    return date.isAfter(startOfToday) || date.isAtSameMomentAs(startOfToday);
                  } else if (_rekapFilter == 'Bulan Ini') {
                    return date.isAfter(startOfMonth) || date.isAtSameMomentAs(startOfMonth);
                  }
                  return true; // 'Semua'
                }).toList();

                final total = docs.length;
                final pemasukan = docs.fold<int>(0, (s, d) {
                  final data = d.data() as Map<String, dynamic>;
                  return s + (data['totalHarga'] as int? ?? 0);
                });

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: AppColors.premiumCardDeco(borderRadius: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rekap Total',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['Hari Ini', 'Bulan Ini', 'Semua'].map((filter) {
                            final isSelected = _rekapFilter == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(
                                  filter,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: AppColors.primary,
                                backgroundColor: Colors.grey.shade100,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: isSelected ? AppColors.primary : Colors.grey.shade300,
                                  ),
                                ),
                                onSelected: (val) {
                                  if (val) {
                                    setState(() {
                                      _rekapFilter = filter;
                                    });
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _RekapItem(
                            label: 'Total Pesanan',
                            value: '$total',
                            icon: Icons.receipt_long_rounded,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          _RekapItem(
                            label: 'Total Pemasukan',
                            value:
                                'Rp${pemasukan.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                            icon: Icons.payments_rounded,
                            color: AppColors.success,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Menu
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: AppColors.premiumCardDeco(borderRadius: 16),
              child: Column(
                children: [
                  _PTile(
                    icon: Icons.lock_outline_rounded,
                    color: const Color(0xFF9C27B0),
                    label: 'Ubah Password',
                    onTap: () => _ubahPassword(context),
                  ),
                  _divider(),
                  _PTile(
                    icon: Icons.headset_mic_rounded,
                    color: AppColors.secondary,
                    label: 'Hubungi Admin',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Menghubungi admin...'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    ),
                  ),
                  _divider(),
                  _PTile(
                    icon: Icons.logout_rounded,
                    color: AppColors.danger,
                    label: 'Keluar',
                    isDestructive: true,
                    onTap: () => _logout(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      ),
    );
  }

  Widget _divider() => Divider(
    height: 1,
    thickness: 1,
    color: Colors.grey.shade100,
    indent: 56,
    endIndent: 16,
  );

  void _ubahPassword(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Ubah Password',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Password baru',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.currentUser?.updatePassword(
                  ctrl.text,
                );
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password berhasil diubah!'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Keluar Akun?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        content: const Text(
          'Kamu akan logout dari akun pedagang.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _RekapItem extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _RekapItem({
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
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _PTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  const _PTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDestructive
                        ? AppColors.danger
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade300,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
