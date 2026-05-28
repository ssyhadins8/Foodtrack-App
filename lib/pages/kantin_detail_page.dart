import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodtrack/cart_provider.dart';
import 'package:foodtrack/theme/app_colors.dart';
import 'package:foodtrack/pages/cart_page.dart';
import 'package:foodtrack/services/firestore_service.dart';

class KantinDetailPage extends StatefulWidget {
  final Map<String, dynamic> kantin;
  const KantinDetailPage({super.key, required this.kantin});

  @override
  State<KantinDetailPage> createState() => _KantinDetailPageState();
}

class _KantinDetailPageState extends State<KantinDetailPage> {
  String _selectedKat = 'Semua';
  String _currentTab = 'Menu'; // 'Menu' atau 'Ulasan'

  List<Map<String, dynamic>> _menuFromFirestore = [];
  bool _isLoadingMenu = true;

  @override
  void initState() {
    super.initState();
    _loadMenus();
  }

  void _loadMenus() {
    final kantinId = widget.kantin['id'] as String;
    FirebaseFirestore.instance
        .collection('menu')
        .where('kantinId', isEqualTo: kantinId)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _menuFromFirestore = snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'nama': data['nama'] ?? '',
              'harga': data['harga'] ?? 0,
              'gambar': data['gambar'] ?? 'images/soto_ayam.jpeg',
              'kat': data['kategori'] ?? data['kat'] ?? 'Makanan',
              'desc': data['desc'] ?? '',
              'stok': data['stok'] ?? 0,
              'tersedia': data['tersedia'] ?? true,
            };
          }).toList();
          _isLoadingMenu = false;
        });
      }
    });
  }

  List<Map<String, dynamic>> get _menus {
    final all = _menuFromFirestore;
    if (_selectedKat == 'Semua') return all;
    return all.where((m) => m['kat'] == _selectedKat).toList();
  }

  List<String> get _kategoriList {
    final all = _menuFromFirestore;
    final cats = [
      'Semua',
      ...all.map((m) => m['kat'] as String).toSet().toList(),
    ];
    return cats;
  }

  String _formatHarga(int h) =>
      'Rp${h.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  @override
  Widget build(BuildContext context) {
    final kantin = widget.kantin;
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D1B2A),
              Color(0xFF1B3A5C),
              Color(0xFFD6E8F5),
              Colors.white,
            ],
            stops: [0.0, 0.25, 0.65, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: AppColors.primary,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      kantin['gambar'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.headerGradient,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.restaurant_rounded,
                            color: Colors.white54,
                            size: 60,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.primary.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (kantin['isTop'] == true)
                            Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    color: AppColors.cyan,
                                    size: 10,
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    'TOP KANTIN',
                                    style: TextStyle(
                                      color: AppColors.cyan,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Text(
                            kantin['nama'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFFFD700),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${kantin['rating']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.access_time_rounded,
                                color: Colors.white70,
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                kantin['waktu'],
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.restaurant_menu_rounded,
                                color: Colors.white70,
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${kantin['totalMenu']} menu',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
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

            // TAB SELECTOR (Menu vs Ulasan)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: const Color(0xFF1B3A5C).withOpacity(0.12),
                        width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _currentTab = 'Menu'),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: _currentTab == 'Menu'
                                  ? AppColors.primary
                                  : Colors.transparent,
                              boxShadow: _currentTab == 'Menu'
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Text(
                                'Daftar Menu',
                                style: TextStyle(
                                  color: _currentTab == 'Menu'
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _currentTab = 'Ulasan'),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: _currentTab == 'Ulasan'
                                  ? AppColors.primary
                                  : Colors.transparent,
                              boxShadow: _currentTab == 'Ulasan'
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Text(
                                'Ulasan & Rating',
                                style: TextStyle(
                                  color: _currentTab == 'Ulasan'
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (_currentTab == 'Menu') ...[
              // KATEGORI FILTER
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemCount: _kategoriList.length,
                      itemBuilder: (_, i) {
                        final on = _kategoriList[i] == _selectedKat;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedKat = _kategoriList[i]),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: on
                                  ? AppColors.cyan.withValues(alpha: 0.2)
                                  : const Color(0xFF0D2237),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: on
                                    ? AppColors.cyan.withValues(alpha: 0.6)
                                    : AppColors.cyan.withValues(alpha: 0.15),
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              _kategoriList[i],
                              style: TextStyle(
                                color: on ? AppColors.cyan : Colors.white60,
                                fontSize: 12,
                                fontWeight:
                                    on ? FontWeight.bold : FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // DAFTAR MENU
              _isLoadingMenu
                  ? const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 80),
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        ),
                      ),
                    )
                  : _menus.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 80),
                              child: Text('Menu tidak tersedia',
                                  style: TextStyle(color: Colors.grey)),
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((_, i) {
                              final menu = _menus[i];
                              final qty =
                                  cart.qtyOf(menu['nama'], kantin['nama']);
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF1B3A5C)
                                        .withOpacity(0.15),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0D1B2A)
                                          .withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                          const BorderRadius.horizontal(
                                        left: Radius.circular(16),
                                      ),
                                      child: Image.asset(
                                        menu['gambar'],
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 90,
                                          height: 90,
                                          color: AppColors.cyanLight,
                                          child: const Icon(
                                            Icons.fastfood_rounded,
                                            color: AppColors.secondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    menu['nama'],
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          AppColors.textPrimary,
                                                    ),
                                                  ),
                                                ),
                                                StreamBuilder<QuerySnapshot>(
                                                  stream: FirestoreService
                                                      .streamFavorites(),
                                                  builder: (context, snap) {
                                                    final isFav = snap
                                                            .data?.docs
                                                            .any((d) =>
                                                                d['nama'] ==
                                                                    menu[
                                                                        'nama'] &&
                                                                d['kantin'] ==
                                                                    kantin[
                                                                        'nama']) ??
                                                        false;
                                                    return GestureDetector(
                                                      onTap: () =>
                                                          FirestoreService
                                                              .toggleFavorite(
                                                        nama: menu['nama'],
                                                        kantin: kantin['nama'],
                                                        gambar: menu['gambar'],
                                                        harga: menu['harga'],
                                                      ),
                                                      child: AnimatedContainer(
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    300),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(6),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: isFav
                                                              ? AppColors.danger
                                                                  .withOpacity(
                                                                      0.1)
                                                              : Colors
                                                                  .transparent,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Icon(
                                                          isFav
                                                              ? Icons
                                                                  .favorite_rounded
                                                              : Icons
                                                                  .favorite_outline_rounded,
                                                          size: 18,
                                                          color: isFav
                                                              ? AppColors.danger
                                                              : Colors.grey,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              menu['desc'],
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppColors.textSecondary,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Text(
                                                  _formatHarga(menu['harga']),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.tertiary,
                                                  ),
                                                ),
                                                const Spacer(),
                                                if (qty > 0) ...[
                                                  GestureDetector(
                                                    onTap: () => context
                                                        .read<CartProvider>()
                                                        .kurang(
                                                          CartItem(
                                                            nama: menu['nama'],
                                                            gambar:
                                                                menu['gambar'],
                                                            harga:
                                                                menu['harga'],
                                                            kantin:
                                                                kantin['nama'],
                                                          ),
                                                        ),
                                                    child: Container(
                                                      width: 28,
                                                      height: 28,
                                                      decoration: BoxDecoration(
                                                        color: AppColors.primary
                                                            .withOpacity(0.08),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                          color: AppColors
                                                              .primary
                                                              .withOpacity(0.2),
                                                        ),
                                                      ),
                                                      child: const Icon(
                                                        Icons.remove_rounded,
                                                        size: 16,
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 8,
                                                    ),
                                                    child: Text(
                                                      '$qty',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                GestureDetector(
                                                  onTap: () {
                                                    context
                                                        .read<CartProvider>()
                                                        .tambah(
                                                          CartItem(
                                                            nama: menu['nama'],
                                                            gambar:
                                                                menu['gambar'],
                                                            harga:
                                                                menu['harga'],
                                                            kantin:
                                                                kantin['nama'],
                                                          ),
                                                        );
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          '${menu['nama']} ditambahkan!',
                                                        ),
                                                        backgroundColor:
                                                            AppColors.success,
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                        duration:
                                                            const Duration(
                                                                seconds: 1),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            12,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    width: 28,
                                                    height: 28,
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: const Icon(
                                                      Icons.add_rounded,
                                                      size: 16,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }, childCount: _menus.length),
                          ),
                        ),
            ] else ...[
              // STATS HEADER
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D1B2A), Color(0xFF1B3A5C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0D1B2A).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '${kantin['rating']}',
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '/ 5.0',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white60,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: List.generate(5, (index) {
                                final starVal = index + 1;
                                final rating =
                                    (kantin['rating'] as num?)?.toDouble() ??
                                        4.5;
                                return Icon(
                                  starVal <= rating
                                      ? Icons.star_rounded
                                      : (starVal - rating < 1.0
                                          ? Icons.star_half_rounded
                                          : Icons.star_outline_rounded),
                                  color: Colors.amber,
                                  size: 18,
                                );
                              }),
                            ),
                            const SizedBox(height: 8),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirestoreService.streamUlasanKantin(
                                  kantin['id']),
                              builder: (context, snap) {
                                final count = snap.data?.docs.length ?? 0;
                                return Text(
                                  '$count Ulasan Terverifikasi',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white60,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.stars_rounded,
                            color: Colors.white54,
                            size: 48,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // STREAM LIST ULASAN
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirestoreService.streamUlasanKantin(kantin['id']),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        ),
                      ),
                    );
                  }

                  if (!snap.hasData || snap.data!.docs.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 60),
                          child: Column(
                            children: [
                              Icon(Icons.rate_review_rounded,
                                  color: Colors.white30, size: 40),
                              SizedBox(height: 12),
                              Text(
                                'Belum ada ulasan untuk kantin ini',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  final docs = snap.data!.docs.toList();
                  // Urutkan di memori untuk mencegah error composite index
                  docs.sort((a, b) {
                    final tA = a.data()['timestamp'] as Timestamp?;
                    final tB = b.data()['timestamp'] as Timestamp?;
                    if (tA == null) return 1;
                    if (tB == null) return -1;
                    return tB.compareTo(tA);
                  });

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final ulasan = docs[index].data();
                          final rating =
                              (ulasan['rating'] as num?)?.toDouble() ?? 5.0;
                          final nama = ulasan['namaPembeli'] ?? 'Pembeli';
                          final komentar = ulasan['komentar'] ?? '';
                          final waktu =
                              (ulasan['timestamp'] as Timestamp?)?.toDate();

                          String formattedDate = '-';
                          if (waktu != null) {
                            formattedDate =
                                '${waktu.day}/${waktu.month}/${waktu.year}';
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B3A5C),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.cyan.withValues(alpha: 0.15),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: const BoxDecoration(
                                        color: AppColors.cyan,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          nama.isNotEmpty
                                              ? nama[0].toUpperCase()
                                              : 'P',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            nama,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Row(
                                                children:
                                                    List.generate(5, (starIdx) {
                                                  return Icon(
                                                    starIdx < rating
                                                        ? Icons.star_rounded
                                                        : Icons
                                                            .star_outline_rounded,
                                                    color: Colors.amber,
                                                    size: 12,
                                                  );
                                                }),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                formattedDate,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white
                                                      .withOpacity(0.4),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (komentar.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    komentar,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                        childCount: docs.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),

      // FAB Keranjang
      floatingActionButton: cart.totalItem > 0
          ? GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shopping_cart_rounded,
                      color: AppColors.cyan,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${cart.totalItem} item • ${_formatHarga(cart.totalHarga)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
