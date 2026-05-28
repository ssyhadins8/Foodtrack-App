import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodtrack/services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:foodtrack/cart_provider.dart';
import 'package:foodtrack/theme/app_colors.dart';
import 'package:foodtrack/pages/profil_page.dart';
import 'package:foodtrack/pages/notifikasi_page.dart';
import 'package:foodtrack/pages/cart_page.dart';
import 'package:foodtrack/pages/kantin_detail_page.dart';
import 'package:foodtrack/theme/premium_background.dart';
import 'package:foodtrack/services/weather_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _idx = 0;
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _semuaKantinKey = GlobalKey();
  String _searchQuery = '';
  String _kategori = 'Semua';
  bool _showOnlyTopCanteens = false;

  final List<String> _cats = [
    'Semua',
    'Soto',
    'Nasi',
    'Bakso',
    'Ayam',
    'Minuman',
    'Snack',
    'Seafood',
  ];

  List<Map<String, dynamic>> _kantinList = [];
  bool _isLoadingKantin = true;

  WeatherInfo? _weatherInfo;
  bool _isLoadingWeather = true;

  StreamSubscription<QuerySnapshot>? _notifSub;
  final DateTime _pageOpenTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _listenKantin();
    _loadWeather();
    _setupNotificationListener();
  }

  void _setupNotificationListener() {
    _notifSub = FirestoreService.streamNotifikasi().listen((snapshot) {
      if (!mounted) return;
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>?;
          if (data != null && data['dibaca'] == false) {
            final waktuTimestamp = data['waktu'] as Timestamp?;
            if (waktuTimestamp != null) {
              final waktuDt = waktuTimestamp.toDate();
              if (waktuDt.isBefore(_pageOpenTime)) {
                continue;
              }
            }
            final tipe = data['tipe'];
            if (tipe == 'pesanan') {
              final judul = data['judul'] ?? 'Update Pesanan';
              final pesan = data['pesan'] ?? '';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  content: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppColors.premiumCardDeco(
                      color: const Color(0xFF1B3A5C).withValues(alpha: 0.95),
                      borderRadius: 16,
                    ).copyWith(
                      border: Border.all(
                        color: AppColors.cyan.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_active_rounded, color: AppColors.cyan, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(judul, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(pesan, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  duration: const Duration(seconds: 4),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.only(bottom: 90, left: 16, right: 16),
                ),
              );
            }
          }
        }
      }
    });
  }

  Future<void> _loadWeather() async {
    if (!mounted) return;
    setState(() {
      _isLoadingWeather = true;
    });
    final info = await WeatherService.fetchCampusWeather();
    if (mounted) {
      setState(() {
        _weatherInfo = info;
        _isLoadingWeather = false;
      });
    }
  }

  void _listenKantin() {
    FirestoreService.streamKantin().listen((snapshot) {
      if (mounted) {
        setState(() {
          _kantinList = snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'nama': data['nama'] ?? '',
              'deskripsi': data['deskripsi'] ?? '',
              'kategori': data['kategori'] ?? '',
              'gambar': data['gambar'] ?? 'images/kantin1.jpg',
              'rating': (data['rating'] as num?)?.toDouble() ?? 4.5,
              'isTop': data['isTop'] ?? false,
              'waktu': data['waktu'] ?? '10-15 mnt',
              'totalMenu': data['totalMenu'] ?? 0,
            };
          }).toList();
          _isLoadingKantin = false;
        });
      }
    });
  }

  List<Map<String, dynamic>> get _topCanteens {
    final list = List<Map<String, dynamic>>.from(_kantinList);
    list.sort((a, b) => (b['rating'] as num).compareTo(a['rating'] as num));
    return list.take(3).toList();
  }

  List<Map<String, dynamic>> get _filtered {
    if (_showOnlyTopCanteens) {
      return _topCanteens;
    }
    return _kantinList.where((k) {
      final matchCat = _kategori == 'Semua' || k['kategori'] == _kategori;
      final matchQ = _searchQuery.isEmpty ||
          k['nama']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          k['deskripsi']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      return matchCat && matchQ;
    }).toList();
  }

  void _showPromoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 140,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D1B2A), Color(0xFF1B3A5C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: const Icon(Icons.local_offer_rounded, color: Colors.white, size: 60),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Syarat & Ketentuan Promo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  _promoStep('1', 'Berlaku hanya untuk menu Soto Ayam di Kantin Bu Sari.'),
                  _promoStep('2', 'Minimal pembelian Rp 20.000.'),
                  _promoStep('3', 'Promo berlaku hingga 31 Mei 2026.'),
                  _promoStep('4', 'Tidak dapat digabungkan dengan promo lain.'),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Mengerti', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _promoStep(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$num. ', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
        ],
      ),
    );
  }

  void _scrollToSemuaKantin() {
    // Wait for the frame to build after setState, then scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keyContext = _semuaKantinKey.currentContext;
      if (keyContext != null) {
        Scrollable.ensureVisible(
          keyContext,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
          alignment: 0.0,
        );
      }
    });
  }

  @override
  void dispose() {
    _notifSub?.cancel();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    final cart = context.watch<CartProvider>();
    final user = FirebaseAuth.instance.currentUser;
    final nama = user?.displayName ?? user?.email?.split('@')[0] ?? 'Pengguna';

    return Scaffold(
      extendBody: true,
      body: PremiumBackground(
        child: IndexedStack(
          index: _idx,
          children: [
            _buildHome(nama, cart),
            const NotifikasiPage(),
            const CartPage(),
            const ProfilPage(),
          ],
        ),
      ),
      bottomNavigationBar: _buildNav(cart),
    );
  }

  Widget _buildNav(CartProvider cart) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                active: _idx == 0,
                onTap: () => setState(() => _idx = 0),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirestoreService.streamNotifikasi(),
                builder: (context, snap) {
                  // ✅ FIX: Filter agar badge hanya menghitung tipe yang valid (pesanan, promo, aktivitas)
                  final validTypes = ['pesanan', 'promo', 'aktivitas'];
                  final unread = snap.data?.docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return data['dibaca'] == false && validTypes.contains(data['tipe']);
                  }).length ?? 0;

                  return _NavBadge(
                    icon: Icons.notifications_rounded,
                    label: 'Notifikasi',
                    active: _idx == 1,
                    badge: unread,
                    onTap: () => setState(() => _idx = 1),
                  );
                },
              ),
              _NavBadge(
                icon: Icons.shopping_cart_rounded,
                label: 'Keranjang',
                active: _idx == 2,
                badge: cart.totalItem,
                onTap: () => setState(() => _idx = 2),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profil',
                active: _idx == 3,
                onTap: () => setState(() => _idx = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHome(String nama, CartProvider cart) {
    final top = _topCanteens;

    return CustomScrollView(
      controller: _scrollCtrl,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ===== HEADER PREMIUM =====
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
              boxShadow: [
                BoxShadow(color: AppColors.primary, blurRadius: 20, offset: Offset(0, 10)),
              ],
            ),
            padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 10, 24, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Halo, $nama!',
                              style: TextStyle(color: AppColors.cyan.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          const Text('Mau makan apa hari ini?',
                              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                    _HeaderIcon(
                      icon: Icons.notifications_none_rounded,
                      onTap: () => setState(() => _idx = 1),
                      showBadge: true,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Search bar
                Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    onChanged: (v) => setState(() {
                      _searchQuery = v;
                      if (v.isNotEmpty) {
                        _showOnlyTopCanteens = false;
                      }
                    }),
                    decoration: InputDecoration(
                      hintText: 'Cari menu atau kantin...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.cyan, size: 22),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _searchQuery = '');
                              })
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ===== WEATHER STATUS WIDGET =====
        if (_searchQuery.isEmpty && _kategori == 'Semua')
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16),
                decoration: AppColors.premiumCardDeco(
                  borderRadius: 24,
                  color: Colors.white.withValues(alpha: 0.4),
                ).copyWith(
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                ),
                child: _isLoadingWeather
                    ? const SizedBox(
                        height: 60,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _weatherInfo?.icon ?? '☀️',
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Cuaca Kampus: ${_weatherInfo?.condition ?? 'Cerah'}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${_weatherInfo?.temperature ?? 30.0}°C',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _weatherInfo?.recommendation ?? '',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade700,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            onPressed: _loadWeather,
                            tooltip: 'Perbarui cuaca',
                          ),
                        ],
                      ),
              ),
            ),
          ),

        // ===== PROMO BANNER =====
        if (_searchQuery.isEmpty && _kategori == 'Semua')
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: GestureDetector(
                onTap: () => _showPromoDialog(context),
                child: Container(
                  height: 130,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B3A5C), Color(0xFF415A77)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B3A5C).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -10,
                        bottom: -10,
                        child: Icon(Icons.local_offer_rounded, size: 120, color: Colors.white.withOpacity(0.15)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                              child: const Text('PROMO TERBATAS', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 12),
                            const Text('Diskon Spesial 50%', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                            Text('Untuk menu tertentu di Kantin Bu Sari', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // ===== TERPOPULER =====
        if (top.isNotEmpty && _searchQuery.isEmpty && _kategori == 'Semua') ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
              child: Row(
                children: [
                  const Text('Terpopuler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _kategori = 'Semua';
                        _searchQuery = '';
                        _searchCtrl.clear();
                      });
                      _scrollToSemuaKantin();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Lihat Semua', style: TextStyle(fontSize: 13, color: AppColors.primary.withOpacity(0.8), fontWeight: FontWeight.w600)),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary.withOpacity(0.6)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 230,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemCount: top.length,
                itemBuilder: (_, i) => _TopKantinCardPremium(kantin: top[i]),
              ),
            ),
          ),
        ],

        // ===== KATEGORI =====
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kategori', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemCount: _cats.length,
                    itemBuilder: (_, i) {
                      final on = _cats[i] == _kategori;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _kategori = _cats[i];
                          _showOnlyTopCanteens = false;
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: AppColors.premiumCardDeco(
                            borderRadius: 14,
                            color: on ? AppColors.primary : Colors.white.withValues(alpha: 0.5),
                          ).copyWith(
                            border: Border.all(
                              color: on
                                  ? AppColors.cyan.withValues(alpha: 0.5)
                                  : Colors.white.withValues(alpha: 0.4),
                              width: 1.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _cats[i],
                            style: TextStyle(
                              color: on ? AppColors.cyan : Colors.grey.shade600,
                              fontSize: 13,
                              fontWeight: on ? FontWeight.bold : FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // ===== SEMUA KANTIN =====
        SliverToBoxAdapter(
          key: _semuaKantinKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
            child: Row(
              children: [
                Text(
                  _searchQuery.isNotEmpty
                      ? 'Hasil Pencarian'
                      : (_showOnlyTopCanteens ? 'Kantin Terpopuler' : 'Semua Kantin'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    if (_showOnlyTopCanteens) {
                      setState(() => _showOnlyTopCanteens = false);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _showOnlyTopCanteens
                          ? AppColors.primary.withOpacity(0.1)
                          : AppColors.cyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _showOnlyTopCanteens ? 'Tampilkan Semua' : '${_filtered.length} Kantin',
                      style: TextStyle(
                        color: _showOnlyTopCanteens ? AppColors.primary : AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        _isLoadingKantin
            ? const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(50),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              )
            : _filtered.isEmpty
                ? const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(50), child: Text('Kantin tidak ditemukan'))))
                : SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((_, i) => _KantinCardPremium(kantin: _filtered[i]), childCount: _filtered.length),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    childAspectRatio: 0.75,
                  ),
                ),
              ),
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool showBadge;
  const _HeaderIcon({required this.icon, required this.onTap, this.showBadge = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          if (showBadge)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: AppColors.cyan, shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 2)),
              ),
            ),
        ],
      ),
    );
  }
}

class _TopKantinCardPremium extends StatelessWidget {
  final Map<String, dynamic> kantin;
  const _TopKantinCardPremium({required this.kantin});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => KantinDetailPage(kantin: kantin))),
      child: Container(
        width: 280,
        decoration: AppColors.premiumCardDeco(borderRadius: 24),
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Hero(
                    tag: 'kantin_img_${kantin['id']}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: Image.asset(kantin['gambar'], width: double.infinity, height: double.infinity, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: AppColors.cyanLight, child: const Icon(Icons.restaurant_rounded, color: AppColors.secondary, size: 40))),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text('${kantin['rating']}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kantin['nama'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(kantin['waktu'], style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        const SizedBox(width: 12),
                        Icon(Icons.restaurant_menu_rounded, size: 14, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text('${kantin['totalMenu']} Menu', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KantinCardPremium extends StatelessWidget {
  final Map<String, dynamic> kantin;
  const _KantinCardPremium({required this.kantin});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => KantinDetailPage(kantin: kantin))),
      child: Container(
        decoration: AppColors.premiumCardDeco(borderRadius: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.asset(kantin['gambar'], width: double.infinity, height: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: AppColors.cyanLight, child: const Icon(Icons.restaurant_rounded, color: AppColors.secondary))),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                          Text('${kantin['rating']}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(kantin['nama'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(kantin['kategori'], style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 11, color: AppColors.cyan),
                      const SizedBox(width: 4),
                      Text(kantin['waktu'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary)),
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

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? AppColors.primary : Colors.grey.shade400, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: active ? AppColors.primary : Colors.grey.shade400, fontSize: 10, fontWeight: active ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

class _NavBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final int badge;
  final VoidCallback onTap;
  const _NavBadge({required this.icon, required this.label, required this.active, required this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: active ? AppColors.primary : Colors.grey.shade400, size: 24),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: active ? AppColors.primary : Colors.grey.shade400, fontSize: 10, fontWeight: active ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
          if (badge > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),
            ),
        ],
      ),
    );
  }
}
