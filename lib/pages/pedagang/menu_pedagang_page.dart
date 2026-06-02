import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodtrack/theme/app_colors.dart';
import 'package:foodtrack/theme/premium_background.dart';
import 'package:foodtrack/services/menu_service.dart';

class MenuPedagangPage extends StatefulWidget {
  final String namaKantin, kantinId;
  const MenuPedagangPage({
    super.key,
    required this.namaKantin,
    required this.kantinId,
  });

  @override
  State<MenuPedagangPage> createState() => _MenuPedagangPageState();
}

class _MenuPedagangPageState extends State<MenuPedagangPage> {
  String _fmt(int h) =>
      'Rp${h.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  final List<String> _kategoriPreset = [
    'Soto',
    'Nasi',
    'Bakso',
    'Ayam',
    'Minuman',
    'Snack',
    'Seafood',
  ];

  final List<String> _gambarPreset = [
    'images/soto_ayam.jpeg',
    'images/soto_daging.jpeg',
    'images/es_teh.jpeg',
    'images/nasi_putih.jpeg',
    'images/sup_bakso.jpeg',
    'images/nasi_campur.jpeg',
    'images/nasi_goreng.jpeg',
    'images/ayam_goreng.png',
    'images/es_jeruk.jpeg',
    'images/tempe_goreng.jpeg',
    'images/ayam_geprek.png',
    'images/ayam_penyet.png',
    'images/lalapan.jpg',
    'images/ayam_kremes.png',
    'images/sayur_capcay.png',
  ];

  void _showForm({String? docId, Map<String, dynamic>? existing}) {
    final namaCtrl = TextEditingController(text: existing?['nama'] ?? '');
    final hargaCtrl = TextEditingController(
      text: existing != null ? '${existing['harga']}' : '',
    );
    final stokCtrl = TextEditingController(
      text: existing != null ? '${existing['stok']}' : '',
    );
    final descCtrl = TextEditingController(text: existing?['desc'] ?? '');
    final isEdit = docId != null;

    String selectedKat = existing?['kategori'] != null && _kategoriPreset.contains(existing!['kategori'])
        ? existing['kategori']
        : _kategoriPreset.first;

    String selectedGambar = existing?['gambar'] != null && _gambarPreset.contains(existing!['gambar'])
        ? existing['gambar']
        : _gambarPreset.first;

    bool tersedia = existing?['tersedia'] ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setS) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
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
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.cyanLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.fastfood_rounded, color: AppColors.primary),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        isEdit ? 'Edit Menu' : 'Tambah Menu Baru',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _ff('Nama Menu', namaCtrl, Icons.restaurant_rounded),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _ff('Harga (Rp)', hargaCtrl, Icons.payments_rounded, type: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: _ff('Stok', stokCtrl, Icons.inventory_2_rounded, type: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _ff('Deskripsi Singkat', descCtrl, Icons.description_rounded),
                  const SizedBox(height: 16),
                  
                  // KATEGORI DROPDOWN
                  const Text(
                    'Pilih Kategori',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedKat,
                        isExpanded: true,
                        items: _kategoriPreset.map((k) {
                          return DropdownMenuItem<String>(
                            value: k,
                            child: Text(k),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setS(() => selectedKat = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // GAMBAR PREVIEW & SELECTOR
                  const Text(
                    'Gambar / Foto Menu',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cyan.withOpacity(0.4), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          selectedGambar,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.fastfood_rounded,
                            color: AppColors.primary,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Pilih Gambar:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _gambarPreset.length,
                      itemBuilder: (context, index) {
                        final imgPath = _gambarPreset[index];
                        final isSelected = selectedGambar == imgPath;
                        return GestureDetector(
                          onTap: () {
                            setS(() {
                              selectedGambar = imgPath;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : Colors.grey.shade300,
                                width: isSelected ? 3 : 1,
                              ),
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    imgPath,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                                  ),
                                ),
                                if (isSelected)
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: Container(
                                      padding: const EdgeInsets.all(1),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 10,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Ketersediaan',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setS(() => tersedia = true),
                        child: _StatusChip(label: 'Tersedia', color: AppColors.success, active: tersedia),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => setS(() => tersedia = false),
                        child: _StatusChip(label: 'Habis', color: AppColors.danger, active: !tersedia),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      if (isEdit)
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(
                                color: AppColors.danger.withValues(alpha: 0.5),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('menu')
                                  .doc(docId)
                                  .delete();
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Menu dihapus'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: const Text(
                              'Hapus',
                              style: TextStyle(color: AppColors.danger),
                            ),
                          ),
                        ),
                      if (isEdit) const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            if (namaCtrl.text.isEmpty || hargaCtrl.text.isEmpty)
                              return;
                            final stok = int.tryParse(stokCtrl.text) ?? 0;
                            final data = {
                              'nama': namaCtrl.text.trim(),
                              'harga': int.tryParse(hargaCtrl.text) ?? 0,
                              'stok': stok,
                              'desc': descCtrl.text.trim(),
                              'kantin': widget.namaKantin,
                              'kantinId': widget.kantinId,
                              'tersedia': tersedia && (stok > 0),
                              'kategori': selectedKat,
                              'gambar': selectedGambar,
                              'updatedAt': FieldValue.serverTimestamp(),
                            };

                            if (isEdit) {
                              await FirebaseFirestore.instance
                                  .collection('menu')
                                  .doc(docId)
                                  .update(data);
                            } else {
                              data['createdAt'] = FieldValue.serverTimestamp();
                              await FirebaseFirestore.instance
                                  .collection('menu')
                                  .add(data);
                            }

                            if (!context.mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isEdit ? 'Menu diperbarui!' : 'Menu ditambahkan!',
                                ),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Text(
                            isEdit ? 'Simpan' : 'Tambah',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ff(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType? type,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
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
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        ),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.namaKantin,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Kelola Menu',
              style: TextStyle(color: AppColors.cyan, fontSize: 12),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyan,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                elevation: 0,
              ),
              icon: const Icon(
                Icons.add_rounded,
                color: AppColors.primary,
                size: 16,
              ),
              label: const Text(
                'Tambah',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              onPressed: () => _showForm(),
            ),
          ),
        ],
      ),
      body: PremiumBackground(
        child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('menu')
            .where('kantinId', isEqualTo: widget.kantinId)
            .snapshots(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          final docs = snap.data?.docs ?? [];

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
                      Icons.restaurant_menu_outlined,
                      size: 40,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada menu',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    onPressed: () => _showForm(),
                    child: const Text(
                      '+ Tambah Menu',
                      style: TextStyle(color: Colors.white),
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
              final stok = data['stok'] as int? ?? 0;
              final habis = stok == 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: AppColors.premiumCardDeco(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: 16,
                  showBorder: !habis,
                ).copyWith(
                  border: habis
                      ? Border.all(color: AppColors.danger.withValues(alpha: 0.4), width: 1.5)
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Gambar
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              data['gambar'] ?? 'images/kantin1.jpg',
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 64,
                                height: 64,
                                color: AppColors.cyanLight,
                                child: const Icon(
                                  Icons.fastfood_rounded,
                                  color: AppColors.secondary,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                          if (habis)
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  color: Colors.black.withOpacity(0.5),
                                  child: const Center(
                                    child: Text(
                                      'HABIS',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
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
                            Text(
                              data['nama'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              _fmt(data['harga'] as int? ?? 0),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Stok controller
                      Column(
                        children: [
                          if (habis)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Habis',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.danger,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  if (stok > 0) {
                                    await FirebaseFirestore.instance
                                        .collection('menu')
                                        .doc(docId)
                                        .update({
                                          'stok': stok - 1,
                                          'tersedia': stok - 1 > 0,
                                        });
                                  }
                                },
                                child: Icon(
                                  Icons.remove_circle_rounded,
                                  color: stok > 0
                                      ? AppColors.danger
                                      : Colors.grey.shade300,
                                  size: 28,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: stok <= 3
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.warning,
                                            color: Colors.red,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            '$stok',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        '$stok',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  await FirebaseFirestore.instance
                                      .collection('menu')
                                      .doc(docId)
                                      .update({
                                        'stok': stok + 1,
                                        'tersedia': true,
                                      });
                                },
                                child: const Icon(
                                  Icons.add_circle_rounded,
                                  color: AppColors.success,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      Switch(
                        value: data['isAvailable'] as bool? ?? false,
                        onChanged: (val) async {
                          await FirebaseFirestore.instance
                              .collection('menu')
                              .doc(docId)
                              .update({'isAvailable': val});
                        },
                        activeColor: AppColors.cyan,
                        activeTrackColor: AppColors.primary,
                      ),

                      // Edit button
                      IconButton(
                        icon: const Icon(
                          Icons.edit_rounded,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                        onPressed: () =>
                            _showForm(docId: docId, existing: data),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool active;
  const _StatusChip({required this.label, required this.color, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? color.withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: active ? color.withOpacity(0.3) : Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: active ? color : Colors.grey.shade400,
        ),
      ),
    );
  }
}
