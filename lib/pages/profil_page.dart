import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:foodtrack/cart_provider.dart';
import 'package:foodtrack/theme/app_colors.dart';
import 'package:foodtrack/services/firestore_service.dart';
import 'package:foodtrack/pages/status_pesanan_page.dart';
import 'package:foodtrack/theme/premium_background.dart';
import 'package:foodtrack/pages/cart_page.dart';
import 'package:foodtrack/pages/user/order_history_page.dart';

Widget buildAvatarImage(String? photoUrl, String nama, {double size = 84, double fontSize = 36}) {
  Widget initialAvatar = Container(
    color: AppColors.primary,
    child: Center(
      child: Text(
        nama.isNotEmpty ? nama[0].toUpperCase() : '?',
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );

  if (photoUrl == null || photoUrl.isEmpty) {
    return initialAvatar;
  }

  if (photoUrl.startsWith('data:image/') && photoUrl.contains('base64,')) {
    try {
      final base64String = photoUrl.split('base64,')[1];
      final bytes = base64.decode(base64String);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (_, __, ___) => initialAvatar,
      );
    } catch (e) {
      return initialAvatar;
    }
  } else if (photoUrl.startsWith('http')) {
    return Image.network(
      photoUrl,
      fit: BoxFit.cover,
      width: size,
      height: size,
      errorBuilder: (_, __, ___) => initialAvatar,
    );
  } else {
    try {
      final bytes = base64.decode(photoUrl);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (_, __, ___) => initialAvatar,
      );
    } catch (e) {
      return initialAvatar;
    }
  }
}

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName =
        user?.displayName ?? user?.email?.split('@')[0] ?? 'Pengguna';
    final email = user?.email ?? '-';
    final cart = context.watch<CartProvider>();

    return Scaffold(
      body: PremiumBackground(
        child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .snapshots(),
        builder: (context, snap) {
          final userData = snap.data?.data() as Map<String, dynamic>? ?? {};
          final nama = userData['nama'] as String? ?? displayName;
          final prodi = userData['prodi'] as String? ?? '';
          final nim = userData['nim'] as String? ?? '';

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // HEADER GRADIENT
                Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.headerGradient,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(28),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    20,
                    MediaQuery.of(context).padding.top + 16,
                    20,
                    28,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Profil',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditProfilPage(
                                  displayName: nama,
                                  email: email,
                                  userData: userData,
                                ),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.cyan.withOpacity(0.5),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.edit_rounded,
                                    color: AppColors.cyan,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Edit',
                                    style: TextStyle(
                                      color: AppColors.cyan,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Avatar
                      Stack(
                        children: [
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.cyan,
                                width: 2.5,
                              ),
                            ),
                            child: ClipOval(
                              child: buildAvatarImage(userData['photoUrl'] as String?, nama, size: 84, fontSize: 36),
                            ),
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditProfilPage(
                                    displayName: nama,
                                    email: email,
                                    userData: userData,
                                  ),
                                ),
                              ),
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: AppColors.cyan,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: AppColors.primary,
                                  size: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
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
                      if (prodi.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cyan.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.cyan.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            nim.isNotEmpty ? '$prodi • $nim' : prodi,
                            style: const TextStyle(
                              color: AppColors.cyan,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // STATISTIK
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: AppColors.premiumCardDeco(borderRadius: 20),
                  child: Row(
                    children: [
                      _StatItem(
                        icon: Icons.shopping_bag_rounded,
                        value: '${cart.totalItem}',
                        label: 'Keranjang',
                        color: AppColors.warning,
                      ),
                      _vDivider(),
                      // Riwayat Pesanan Count
                      StreamBuilder<QuerySnapshot>(
                        stream: FirestoreService.streamRiwayatPesanan(),
                        builder: (context, s) => _StatItem(
                          icon: Icons.receipt_long_rounded,
                          value: '${s.data?.docs.length ?? 0}',
                          label: 'Pesanan',
                          color: AppColors.primary,
                        ),
                      ),
                      _vDivider(),
                      // Notifikasi Unread Count
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('notifikasi')
                            .where('uid', isEqualTo: user?.uid)
                            .where('dibaca', isEqualTo: false)
                            .snapshots(),
                        builder: (context, s) => _StatItem(
                          icon: Icons.notifications_rounded,
                          value: '${s.data?.docs.length ?? 0}',
                          label: 'Notifikasi',
                          color: const Color(0xFF9C27B0),
                        ),
                      ),
                      _vDivider(),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirestoreService.streamFavorites(),
                        builder: (context, snap) {
                          final count = snap.data?.docs.length ?? 0;
                          return _StatItem(
                            icon: Icons.favorite_rounded,
                            value: '$count',
                            label: 'Favorit',
                            color: AppColors.danger,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MenuFavoritPage(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // PESANAN AKTIF REALTIME
                _PesananAktifSection(),

                const SizedBox(height: 16),

                // MENU LIST
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: AppColors.premiumCardDeco(borderRadius: 20),
                  child: Column(
                    children: [
                      _MenuTile(
                        icon: Icons.receipt_long_rounded,
                        iconColor: AppColors.primary,
                        label: 'Riwayat Pesanan',
                        subtitle: 'Lihat semua pesanan kamu',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RiwayatPesananPage(cart: cart),
                          ),
                        ),
                      ),
                      _div(),
                      _MenuTile(
                        icon: Icons.favorite_rounded,
                        iconColor: AppColors.danger,
                        label: 'Menu Favorit',
                        subtitle: 'Menu yang sering kamu pesan',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MenuFavoritPage(),
                          ),
                        ),
                      ),
                      _div(),
                      _MenuTile(
                        icon: Icons.notifications_rounded,
                        iconColor: const Color(0xFF9C27B0),
                        label: 'Pengaturan Notifikasi',
                        subtitle: 'Kelola preferensi notifikasi',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PengaturanNotifPage(),
                          ),
                        ),
                      ),
                      _div(),
                      _MenuTile(
                        icon: Icons.help_rounded,
                        iconColor: AppColors.secondary,
                        label: 'Bantuan & FAQ',
                        subtitle: 'Pertanyaan umum & kontak kami',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BantuanPage(),
                          ),
                        ),
                      ),
                      _div(),
                      _MenuTile(
                        icon: Icons.logout_rounded,
                        iconColor: AppColors.danger,
                        label: 'Keluar',
                        subtitle: 'Logout dari akun ini',
                        isDestructive: true,
                        onTap: () => _logout(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'FoodTrack v1.0.0',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    ),
  );
}

  Widget _vDivider() =>
      Container(width: 1, height: 40, color: Colors.grey.shade100);

  Widget _div() => Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey.shade100,
        indent: 56,
        endIndent: 16,
      );

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
          'Kamu akan logout dari FoodTrack.',
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

// ===== PESANAN AKTIF REALTIME =====
class _PesananAktifSection extends StatelessWidget {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  _PesananAktifSection();

  Color _statusColor(int idx) {
    switch (idx) {
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

  String _statusLabel(int idx) {
    switch (idx) {
      case 0:
        return 'Pesanan diterima';
      case 1:
        return 'Sedang disiapkan';
      case 2:
        return 'Siap diambil! 🎉';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pesanan')
          .where('uid', isEqualTo: uid)
          .snapshots(),
      builder: (context, snap) {
        final rawDocs = snap.data?.docs ?? [];
        final docs = rawDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final statusIndex = data['statusIndex'] as int? ?? 0;
          return statusIndex < 3;
        }).toList();

        docs.sort((a, b) {
          final dataA = a.data() as Map<String, dynamic>;
          final dataB = b.data() as Map<String, dynamic>;
          final statusA = dataA['statusIndex'] as int? ?? 0;
          final statusB = dataB['statusIndex'] as int? ?? 0;
          if (statusA != statusB) {
            return statusA.compareTo(statusB);
          }
          final timeA = dataA['waktuPesan'] as Timestamp?;
          final timeB = dataB['waktuPesan'] as Timestamp?;
          if (timeA == null && timeB == null) return 0;
          if (timeA == null) return 1;
          if (timeB == null) return -1;
          return timeB.compareTo(timeA);
        });

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: AppColors.premiumCardDeco(borderRadius: 20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.receipt_long_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Pesanan Aktif',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    if (docs.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cyanLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.cyan.withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          '${docs.length} aktif',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (snap.connectionState == ConnectionState.waiting)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                )
              else if (docs.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.receipt_long_outlined,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Tidak ada pesanan aktif',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    final noAntrian = data['noAntrian'] ?? 0;
                    final kantin = data['kantin'] ?? '-';
                    final statusIndex = data['statusIndex'] ?? 0;
                    final docId = docs[i].id; // ← ID dokumen pesanan

                    return GestureDetector(
                      // ✅ FIX 5: onTap langsung navigate ke StatusPesananPage
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StatusPesananPage(docId: docId),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(statusIndex).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _statusColor(statusIndex).withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Nomor antrian
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: _statusColor(
                                  statusIndex,
                                ).withOpacity(0.12),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _statusColor(
                                    statusIndex,
                                  ).withOpacity(0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '$noAntrian',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: _statusColor(statusIndex),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'No. Antrian $noAntrian · $kantin',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _statusLabel(statusIndex),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _statusColor(statusIndex),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.grey.shade400,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  final VoidCallback? onTap;
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== MENU TILE =====
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label, subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  const _MenuTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDestructive
                            ? AppColors.danger
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
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

// ===== EDIT PROFIL =====
class EditProfilPage extends StatefulWidget {
  final String displayName, email;
  final Map<String, dynamic> userData;
  const EditProfilPage({
    super.key,
    required this.displayName,
    required this.email,
    required this.userData,
  });

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  late TextEditingController _namaCtrl, _prodiCtrl, _nimCtrl, _noHpCtrl;
  String _role = 'Pembeli';
  bool _loading = false;
  Uint8List? _imageBytes;
  String? _photoUrl;

  final _roles = ['Mahasiswa', 'Alumni', 'Umum'];

  @override
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController(text: widget.displayName);
    _prodiCtrl = TextEditingController(text: widget.userData['prodi'] ?? '');
    _nimCtrl = TextEditingController(text: widget.userData['nim'] ?? '');
    _noHpCtrl = TextEditingController(text: widget.userData['noHp'] ?? '');
    _photoUrl = widget.userData['photoUrl'] as String?;
    final rawRole = widget.userData['role'] ?? 'Mahasiswa';
    final mappedRole = (rawRole == 'Pembeli') ? 'Mahasiswa' : rawRole;
    _role = _roles.contains(mappedRole) ? mappedRole : 'Mahasiswa';
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  Future<void> _hapusFoto() async {
    setState(() {
      _imageBytes = null;
      _photoUrl = null;
    });
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _prodiCtrl.dispose();
    _nimCtrl.dispose();
    _noHpCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (_namaCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama tidak boleh kosong!')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      String? uploadedUrl = _photoUrl;

      // Convert photo to base64 if new one was picked
      if (_imageBytes != null) {
        final base64Str = base64Encode(_imageBytes!);
        uploadedUrl = 'data:image/jpeg;base64,$base64Str';
      }

      await FirebaseAuth.instance.currentUser?.updateDisplayName(_namaCtrl.text.trim());
      
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        if (uploadedUrl != null) {
          // Set to null to avoid FirebaseAuth URL length limits for Base64 strings
          await FirebaseAuth.instance.currentUser?.updatePhotoURL(null);
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .update({'photoUrl': uploadedUrl});
        } else if (_photoUrl == null) {
          // Photo was deleted
          await FirebaseAuth.instance.currentUser?.updatePhotoURL(null);
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .update({'photoUrl': FieldValue.delete()});
        }
      }

      await FirestoreService.updateProfil(
        nama: _namaCtrl.text.trim(),
        prodi: _prodiCtrl.text.trim(),
        nim: _nimCtrl.text.trim(),
        noHp: _noHpCtrl.text.trim(),
        role: _role,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
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
          'Edit Profil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar with photo upload
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickPhoto,
                    child: Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.cyan, width: 2.5),
                          ),
                          child: ClipOval(
                            child: _imageBytes != null
                                ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                                : buildAvatarImage(_photoUrl, widget.displayName, size: 90, fontSize: 38),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1a202c),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if ((_photoUrl != null && _photoUrl!.isNotEmpty) || _imageBytes != null) ...[
                    const SizedBox(height: 6),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: _hapusFoto,
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 14),
                      label: const Text(
                        'Hapus Foto',
                        style: TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.email,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),

            // Form
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.06),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _section('Informasi Dasar'),
                  const SizedBox(height: 12),
                  _field(
                    'Nama Lengkap',
                    _namaCtrl,
                    Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 14),
                  _dropdown(),
                  const SizedBox(height: 20),
                  _section('Info Akademik'),
                  const SizedBox(height: 12),
                  _field(
                    'Program Studi',
                    _prodiCtrl,
                    Icons.school_outlined,
                    hint: 'Contoh: Teknik Informatika',
                  ),
                  const SizedBox(height: 14),
                  _field(
                    'NIM / NIP',
                    _nimCtrl,
                    Icons.badge_outlined,
                    type: TextInputType.number,
                    hint: 'Nomor induk',
                  ),
                  const SizedBox(height: 20),
                  _section('Kontak'),
                  const SizedBox(height: 12),
                  _field(
                    'No. WhatsApp',
                    _noHpCtrl,
                    Icons.phone_outlined,
                    type: TextInputType.phone,
                    hint: 'Contoh: 08123456789',
                  ),
                  const SizedBox(height: 14),
                  _fieldDisabled('Email', widget.email, Icons.email_outlined),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: _loading ? null : _simpan,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.cyan,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialAvatar() {
    return Container(
      color: AppColors.primary,
      child: Center(
        child: Text(
          widget.displayName.isNotEmpty ? widget.displayName[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 38,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _section(String label) => Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.cyan],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      );

  Widget _field(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType? type,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: type,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: AppColors.cyanLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.cyan.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.cyan.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _fieldDisabled(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: TextEditingController(text: value),
          enabled: false,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdown() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Peran / Role',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.cyanLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cyan.withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _role,
                isExpanded: true,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primary,
                ),
                items: _roles
                    .map(
                      (r) => DropdownMenuItem(
                        value: r,
                        child: Text(r, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _role = v!),
              ),
            ),
          ),
        ],
      );
}



// ===== MENU FAVORIT =====
class MenuFavoritPage extends StatefulWidget {
  const MenuFavoritPage({super.key});
  @override
  State<MenuFavoritPage> createState() => _MenuFavoritPageState();
}

class _MenuFavoritPageState extends State<MenuFavoritPage> {
  final List<Map<String, dynamic>> _fav = []; // ✅ Removed dummy data

  String _fmt(int h) =>
      'Rp${h.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  @override
  Widget build(BuildContext context) {
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
          'Menu Favorit',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService.streamFavorites(),
        builder: (context, snap) {
          final docs = snap.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.cyanLight.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      size: 50,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Belum ada menu favorit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sukai menu makanan untuk menyimpannya di sini',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textHint,
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
              final m = docs[i].data() as Map<String, dynamic>;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.06),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Hero(
                      tag: 'fav_${m['nama']}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          m['gambar'],
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 70,
                            height: 70,
                            color: AppColors.cyanLight,
                            child: const Icon(
                              Icons.fastfood,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m['nama'],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            m['kantin'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textHint,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _fmt(m['harga'] as int? ?? 0),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.favorite_rounded,
                        color: AppColors.danger,
                        size: 28,
                      ),
                      onPressed: () {
                        FirestoreService.toggleFavorite(
                          nama: m['nama'],
                          kantin: m['kantin'],
                          gambar: m['gambar'],
                          harga: m['harga'],
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Dihapus dari favorit'),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ===== PENGATURAN NOTIFIKASI =====
class PengaturanNotifPage extends StatefulWidget {
  const PengaturanNotifPage({super.key});
  @override
  State<PengaturanNotifPage> createState() => _PengaturanNotifPageState();
}

class _PengaturanNotifPageState extends State<PengaturanNotifPage> {
  bool _pesanan = true,
      _promo = false,
      _pengingat = true,
      _suara = true,
      _getar = true;
  bool _loadingSettings = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _loadingSettings = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final settings = doc.data()?['notificationSettings'] as Map<String, dynamic>?;
      if (settings != null && mounted) {
        setState(() {
          _pesanan = settings['pesanan'] as bool? ?? true;
          _promo = settings['promo'] as bool? ?? false;
          _pengingat = settings['pengingat'] as bool? ?? true;
          _suara = settings['suara'] as bool? ?? true;
          _getar = settings['getar'] as bool? ?? true;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingSettings = false);
  }

  Future<void> _saveSettings() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'notificationSettings': {
          'pesanan': _pesanan,
          'promo': _promo,
          'pengingat': _pengingat,
          'suara': _suara,
          'getar': _getar,
        }
      }, SetOptions(merge: true));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengaturan berhasil disimpan'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingSettings) {
      return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.headerGradient)),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Pengaturan Notifikasi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    return _buildContent();
  }

  Widget _buildContent() {
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
          'Pengaturan Notifikasi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.06),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              children: [
                _NotifSwitch(
                  icon: Icons.receipt_long_rounded,
                  color: AppColors.primary,
                  label: 'Notifikasi Pesanan',
                  subtitle: 'Status dan update pesanan',
                  value: _pesanan,
                  onChanged: (v) => setState(() => _pesanan = v),
                ),
                _ndiv(),
                _NotifSwitch(
                  icon: Icons.local_offer_rounded,
                  color: const Color(0xFFF97316),
                  label: 'Promo & Diskon',
                  subtitle: 'Penawaran spesial dari kantin',
                  value: _promo,
                  onChanged: (v) => setState(() => _promo = v),
                ),
                _ndiv(),
                _NotifSwitch(
                  icon: Icons.access_time_rounded,
                  color: const Color(0xFF9C27B0),
                  label: 'Pengingat Makan',
                  subtitle: 'Pengingat waktu makan siang',
                  value: _pengingat,
                  onChanged: (v) => setState(() => _pengingat = v),
                ),
                _ndiv(),
                _NotifSwitch(
                  icon: Icons.volume_up_rounded,
                  color: AppColors.secondary,
                  label: 'Suara Notifikasi',
                  subtitle: 'Bunyi saat ada notifikasi',
                  value: _suara,
                  onChanged: (v) => setState(() => _suara = v),
                ),
                _ndiv(),
                _NotifSwitch(
                  icon: Icons.vibration_rounded,
                  color: Colors.grey.shade700,
                  label: 'Getar',
                  subtitle: 'Getar saat ada notifikasi',
                  value: _getar,
                  onChanged: (v) => setState(() => _getar = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1a202c),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: _saving ? null : _saveSettings,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'Simpan Pengaturan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _ndiv() => Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey.shade100,
        indent: 56,
        endIndent: 16,
      );
}

class _NotifSwitch extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _NotifSwitch({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.cyan.withOpacity(0.4),
          ),
        ],
      ),
    );
  }
}

// ===== BANTUAN =====
class BantuanPage extends StatelessWidget {
  const BantuanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'q': 'Bagaimana cara memesan?',
        'a':
            'Pilih kantin → pilih menu → tambah ke keranjang → checkout → pilih metode bayar → konfirmasi.',
      },
      {
        'q': 'Apa itu nomor antrian?',
        'a':
            'Nomor unik saat pesan. Kamu dipanggil sesuai nomor ketika makanan siap.',
      },
      {
        'q': 'Metode pembayaran apa saja?',
        'a': 'Cash (bayar di kantin) dan QRIS (scan QR).',
      },
      {
        'q': 'Berapa estimasi waktu?',
        'a': 'Sekitar 10-30 menit tergantung antrian.',
      },
      {
        'q': 'Bisakah pesanan dibatalkan?',
        'a': 'Pesanan yang sudah dikonfirmasi tidak bisa dibatalkan.',
      },
    ];

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
          'Bantuan & FAQ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Kontak card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.headset_mic_rounded,
                    color: AppColors.cyan,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hubungi Kami',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Sen–Jum, 07.00–16.00 WIB',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyan,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Chat',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Pertanyaan Umum',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.06),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              children: faqs.asMap().entries.map((e) {
                return Column(
                  children: [
                    ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.cyanLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.help_outline_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        e.value['q']!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.cyanLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            e.value['a']!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (e.key < faqs.length - 1)
                      Divider(
                        height: 1,
                        color: Colors.grey.shade100,
                        indent: 16,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
