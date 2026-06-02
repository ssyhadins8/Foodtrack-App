import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodtrack/theme/app_colors.dart';
import 'package:foodtrack/theme/premium_background.dart';
import 'package:foodtrack/services/firestore_service.dart';
import 'package:foodtrack/pages/admin/admin_vouchers_page.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeAdminPage extends StatefulWidget {
  const HomeAdminPage({super.key});

  @override
  State<HomeAdminPage> createState() => _HomeAdminPageState();
}

class _HomeAdminPageState extends State<HomeAdminPage> {
  int _tabIdx = 0;
  final GlobalKey<CanteenManagementState> _canteenKey = GlobalKey<CanteenManagementState>();
  final GlobalKey<UserManagementState> _userKey = GlobalKey<UserManagementState>();
  final GlobalKey<MenuManagementState> _menuKey = GlobalKey<MenuManagementState>();

  Widget _buildSidebar(bool isCompact) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'administrator1@gmail.com';
    final name = email.split('@')[0];

    return Container(
      width: isCompact ? 76 : 260,
      decoration: const BoxDecoration(
        color: AppColors.secondary, // Premium deeper navy sidebar background
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(4, 0),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sidebar Header / Brand
                    Padding(
                      padding: isCompact
                          ? const EdgeInsets.fromLTRB(0, 40, 0, 20)
                          : const EdgeInsets.fromLTRB(24, 40, 24, 20),
                      child: Row(
                        mainAxisAlignment: isCompact ? MainAxisAlignment.center : MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.cyan.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings_rounded,
                              color: AppColors.cyan,
                              size: 28,
                            ),
                          ),
                          if (!isCompact) ...[
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'FoodTrack',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  'ADMIN DASHBOARD',
                                  style: TextStyle(
                                    color: AppColors.cyan.withValues(alpha: 0.8),
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Divider(color: Colors.white12, height: 1),

                    // Admin Profile Card
                    Padding(
                      padding: isCompact
                          ? const EdgeInsets.symmetric(horizontal: 0, vertical: 20)
                          : const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: isCompact
                          ? Column(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.cyan.withValues(alpha: 0.2),
                                  child: Text(
                                    name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'A',
                                    style: const TextStyle(
                                      color: AppColors.cyan,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                IconButton(
                                  onPressed: () async {
                                    await FirebaseAuth.instance.signOut();
                                    if (mounted) Navigator.pushReplacementNamed(context, '/login');
                                  },
                                  icon: const Icon(Icons.logout_rounded, color: Colors.white38, size: 18),
                                  tooltip: 'Keluar',
                                ),
                              ],
                            )
                          : Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppColors.cyan.withValues(alpha: 0.2),
                                    child: Text(
                                      name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'A',
                                      style: const TextStyle(
                                        color: AppColors.cyan,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          email,
                                          style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 10,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      await FirebaseAuth.instance.signOut();
                                      if (mounted) Navigator.pushReplacementNamed(context, '/login');
                                    },
                                    icon: const Icon(Icons.logout_rounded, color: Colors.white38, size: 18),
                                    tooltip: 'Keluar',
                                  ),
                                ],
                              ),
                            ),
                    ),

                    if (!isCompact)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Text(
                          'MENU UTAMA',
                          style: TextStyle(
                            color: Colors.white30,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),

                    // Navigation Links
                    _buildSidebarNavItem(
                      icon: Icons.dashboard_rounded,
                      label: 'Stats Overview',
                      active: _tabIdx == 0,
                      onTap: () => setState(() => _tabIdx = 0),
                      isCompact: isCompact,
                    ),
                    _buildSidebarNavItem(
                      icon: Icons.people_rounded,
                      label: 'Kelola Pengguna',
                      active: _tabIdx == 1,
                      onTap: () => setState(() => _tabIdx = 1),
                      isCompact: isCompact,
                    ),
                    _buildSidebarNavItem(
                      icon: Icons.store_rounded,
                      label: 'Kelola Stan Kantin',
                      active: _tabIdx == 2,
                      onTap: () => setState(() => _tabIdx = 2),
                      isCompact: isCompact,
                    ),
                    _buildSidebarNavItem(
                      icon: Icons.restaurant_menu_rounded,
                      label: 'Kelola Menu Makanan',
                      active: _tabIdx == 3,
                      onTap: () => setState(() => _tabIdx = 3),
                      isCompact: isCompact,
                    ),
                    // New Voucher Management Nav Item
                    _buildSidebarNavItem(
                      icon: Icons.local_offer_rounded,
                      label: 'Kelola Voucher',
                      active: _tabIdx == 4,
                      onTap: () => setState(() => _tabIdx = 4),
                      isCompact: isCompact,
                    ),
                    // ... existing compact handling continues


                    if (!isCompact) ...[
                      const SizedBox(height: 15),
                      const Divider(color: Colors.white12, height: 1),
                      const SizedBox(height: 15),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Text(
                          'QUICK ACTIONS',
                          style: TextStyle(
                            color: Colors.white30,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 10),
                      const Divider(color: Colors.white12, height: 1),
                      const SizedBox(height: 10),
                    ],

                    // Quick Action buttons directly on Sidebar
                    _buildSidebarActionBtn(
                      icon: Icons.add_business_rounded,
                      label: 'Tambah Stan Baru',
                      color: AppColors.cyan,
                      onTap: () {
                        setState(() => _tabIdx = 2);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _canteenKey.currentState?.showForm();
                        });
                      },
                      isCompact: isCompact,
                    ),
                    _buildSidebarActionBtn(
                      icon: Icons.manage_accounts_rounded,
                      label: 'Kelola User',
                      color: Colors.purple.shade300,
                      onTap: () {
                        setState(() => _tabIdx = 1);
                      },
                      isCompact: isCompact,
                    ),
                    _buildSidebarActionBtn(
                      icon: Icons.store_rounded,
                      label: 'Kelola Stan',
                      color: Colors.teal.shade300,
                      onTap: () {
                        setState(() => _tabIdx = 2);
                      },
                      isCompact: isCompact,
                    ),
                    _buildSidebarActionBtn(
                      icon: Icons.done_all_rounded,
                      label: 'Transaksi Selesai',
                      color: Colors.green.shade300,
                      onTap: () {
                        setState(() => _tabIdx = 0);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          FirebaseFirestore.instance
                              .collection('pesanan')
                              .where('statusIndex', isEqualTo: 3)
                              .get()
                              .then((snap) {
                            if (snap.docs.isNotEmpty && mounted) {
                              _AdminDashboard.showOrderDetail(context, snap.docs.first.data());
                            }
                          });
                        });
                      },
                      isCompact: isCompact,
                    ),

                    const Spacer(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isCompact ? 0 : 24,
                        vertical: 30,
                      ),
                      child: Center(
                        child: Text(
                          isCompact ? 'v1.0' : 'FoodTrack v1.0.0',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.15),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSidebarNavItem({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
    bool isCompact = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 16,
        vertical: 4,
      ),
      child: Tooltip(
        message: isCompact ? label : '',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 0 : 16,
              vertical: 12,
            ),
            width: isCompact ? 56 : double.infinity,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? AppColors.cyan.withValues(alpha: 0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: active
                  ? Border(
                      left: BorderSide(
                        color: AppColors.cyan,
                        width: isCompact ? 4 : 3,
                      ),
                    )
                  : null,
            ),
            child: Row(
              mainAxisAlignment: isCompact ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: active ? AppColors.cyan : Colors.white54,
                  size: 20,
                ),
                if (!isCompact) ...[
                  const SizedBox(width: 14),
                  Text(
                    label,
                    style: TextStyle(
                      color: active ? Colors.white : Colors.white70,
                      fontSize: 13,
                      fontWeight: active ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarActionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isCompact = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 16,
        vertical: 3,
      ),
      child: Tooltip(
        message: isCompact ? label : '',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 0 : 14,
              vertical: 10,
            ),
            width: isCompact ? 56 : double.infinity,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B3A5C), Color(0xFF2C5282)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Row(
              mainAxisAlignment: isCompact ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 16,
                ),
                if (!isCompact) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildContentHeader(bool isCompact) {
    String tabTitle = '';
    switch (_tabIdx) {
      case 0:
        tabTitle = 'Ringkasan Statistik';
        break;
      case 1:
        tabTitle = 'Kelola Pengguna';
        break;
      case 2:
        tabTitle = 'Kelola Stan Kantin';
        break;
      case 3:
        tabTitle = 'Kelola Menu Makanan';
        break;
      case 4:
        tabTitle = 'Kelola Voucher';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 16 : 24,
        vertical: isCompact ? 14 : 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              tabTitle,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: isCompact ? 16 : 20,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!isCompact)
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: Colors.grey, size: 16),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd MMMM yyyy').format(DateTime.now()),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 750;

            return Row(
              children: [
                _buildSidebar(isCompact),
                Expanded(
                  child: Column(
                    children: [
                      _buildContentHeader(isCompact),
                      Expanded(
                        child: IndexedStack(
                          index: _tabIdx,
                          children: [
                            _AdminDashboard(
                              isCompact: isCompact,
                              onTabChange: (idx) => setState(() => _tabIdx = idx),
                              canteenKey: _canteenKey,
                              onSelectUser: (userDoc) {
                                setState(() => _tabIdx = 1);
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _userKey.currentState?.selectUser(userDoc);
                                });
                              },
                            ),
                            UserManagement(key: _userKey),
                            CanteenManagement(key: _canteenKey),
                            MenuManagement(key: _menuKey),
                            const AdminVouchersPage(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white24,
            child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  FirebaseAuth.instance.currentUser?.email ?? 'Master Admin',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
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
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.dashboard_rounded,
                label: 'Stats',
                active: _tabIdx == 0,
                onTap: () => setState(() => _tabIdx = 0),
              ),
              _NavItem(
                icon: Icons.people_rounded,
                label: 'Users',
                active: _tabIdx == 1,
                onTap: () => setState(() => _tabIdx = 1),
              ),
              _NavItem(
                icon: Icons.store_rounded,
                label: 'Kantin',
                active: _tabIdx == 2,
                onTap: () => setState(() => _tabIdx = 2),
              ),
              _NavItem(
                icon: Icons.restaurant_menu_rounded,
                label: 'Menu',
                active: _tabIdx == 3,
                onTap: () => setState(() => _tabIdx = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Global helper for status badges on Admin Screens
Widget _statusBadge(int idx) {
  Color bg;
  Color fg;
  String text;
  switch (idx) {
    case 0:
      bg = Colors.orange.shade50;
      fg = Colors.orange.shade800;
      text = 'Baru';
      break;
    case 1:
      bg = Colors.blue.shade50;
      fg = Colors.blue.shade800;
      text = 'Dimasak';
      break;
    case 2:
      bg = Colors.cyan.shade50;
      fg = Colors.cyan.shade800;
      text = 'Siap';
      break;
    case 3:
      bg = Colors.green.shade50;
      fg = Colors.green.shade800;
      text = 'Selesai';
      break;
    default:
      bg = Colors.grey.shade50;
      fg = Colors.grey.shade800;
      text = '-';
  }
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: fg.withValues(alpha: 0.2)),
    ),
    child: Text(
      text,
      style: TextStyle(color: fg, fontSize: 9, fontWeight: FontWeight.bold),
    ),
  );
}

class _AdminDashboard extends StatelessWidget {
  final bool isCompact;
  final Function(int) onTabChange;
  final GlobalKey<CanteenManagementState> canteenKey;
  final Function(DocumentSnapshot) onSelectUser;

  const _AdminDashboard({
    required this.isCompact,
    required this.onTabChange,
    required this.canteenKey,
    required this.onSelectUser,
  });

  static void showOrderDetail(BuildContext context, Map<String, dynamic> data) {
    final items = (data['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -4),
            ),
          ],
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
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rincian Pesanan #${data['noAntrian'] ?? 0}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        Text(
                          'Kantin: ${data['kantin'] ?? ''}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              const Text(
                'Item yang Dipesan:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.cyanLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${item['qty']}x',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 11),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item['nama'] ?? '',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                    ),
                    Text(
                      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                          .format((item['harga'] as num).toInt() * (item['qty'] as num).toInt()),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              )),
              const Divider(height: 24),
              if (data['catatan'] != null && (data['catatan'] as String).trim().isNotEmpty) ...[
                const Text(
                  'Catatan Pembeli:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Text(
                    data['catatan'],
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.amber.shade900),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Pembayaran',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                  ),
                  Text(
                    NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                        .format(data['totalHarga'] ?? 0),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showTransaksiDetails(BuildContext context, List<QueryDocumentSnapshot> orders) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.account_balance_wallet_rounded, color: Colors.orange, size: 28),
                const SizedBox(width: 10),
                const Text(
                  'Rincian Transaksi Pendapatan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: orders.isEmpty
                  ? const Center(child: Text('Belum ada transaksi pendapatan', style: TextStyle(color: AppColors.textPrimary)))
                  : ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, idx) {
                        final doc = orders[idx];
                        final data = doc.data() as Map<String, dynamic>;
                        final statusIndex = data['statusIndex'] as int? ?? 0;
                        final total = data['totalHarga'] ?? 0;
                        final tgl = data['waktuPesan'] != null 
                            ? DateFormat('dd MMM yyyy, HH:mm').format((data['waktuPesan'] as Timestamp).toDate())
                            : '-';
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: AppColors.premiumCardDeco(borderRadius: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            title: Text(
                              data['kantin'] ?? 'Kantin',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  'Pembeli: ${data['pembeliNama'] ?? 'No Name'} (${data['pembeliEmail'] ?? ''})', 
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700)
                                ),
                                const SizedBox(height: 2),
                                Text('Waktu: $tgl', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(total),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                _statusBadge(statusIndex),
                              ],
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                              showOrderDetail(context, data);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPesananDetails(BuildContext context, List<QueryDocumentSnapshot> orders, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.shopping_bag_rounded, color: Colors.blue, size: 28),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: orders.isEmpty
                  ? const Center(child: Text('Belum ada pesanan untuk kategori ini', style: TextStyle(color: AppColors.textPrimary)))
                  : ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, idx) {
                        final doc = orders[idx];
                        final data = doc.data() as Map<String, dynamic>;
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(ctx);
                            showOrderDetail(context, data);
                          },
                          child: _OrderTile(data: data),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCanteenDetails(BuildContext context, List<QueryDocumentSnapshot> canteens) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 28),
                const SizedBox(width: 10),
                const Text(
                  'Daftar Stan Kantin',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: canteens.isEmpty
                  ? const Center(child: Text('Belum ada stan kantin', style: TextStyle(color: AppColors.textPrimary)))
                  : ListView.builder(
                      itemCount: canteens.length,
                      itemBuilder: (context, idx) {
                        final doc = canteens[idx];
                        final id = doc.id;
                        final data = doc.data() as Map<String, dynamic>;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: AppColors.premiumCardDeco(borderRadius: 16),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  data['gambar'] ?? 'images/kantin1.jpg',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 50,
                                    height: 50,
                                    color: AppColors.cyanLight,
                                    child: const Icon(Icons.storefront_rounded, color: AppColors.primary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['nama'] ?? '',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.star_rounded, color: Colors.amber.shade700, size: 12),
                                        const SizedBox(width: 2),
                                        Text('${data['rating'] ?? 4.5}', style: const TextStyle(fontSize: 11, color: AppColors.textPrimary)),
                                        const SizedBox(width: 8),
                                        Text(data['kategori'] ?? '', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                                onPressed: () {
                                  Navigator.pop(ctx); // Close sheet
                                  onTabChange(2); // Switch to Canteen tab
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    canteenKey.currentState?.showForm(docId: id, existing: data); // Open Canteen form
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx); // Close sheet
                  onTabChange(2); // Switch to Canteen tab
                },
                icon: const Icon(Icons.settings_rounded, color: Colors.white),
                label: const Text('Kelola Semua Stan Kantin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDetailsSheet(BuildContext context, List<QueryDocumentSnapshot> users) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.people_rounded, color: AppColors.cyan, size: 28),
                const SizedBox(width: 10),
                const Text(
                  'Daftar Pengguna Platform',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: users.isEmpty
                  ? const Center(child: Text('Belum ada pengguna', style: TextStyle(color: AppColors.textPrimary)))
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, idx) {
                        final doc = users[idx];
                        final data = doc.data() as Map<String, dynamic>;
                        final role = data['role'] ?? 'pembeli';
                        Color badgeColor = role == 'admin' ? Colors.amber.shade700 : (role == 'pedagang' ? Colors.purple : Colors.blue);
                        
                        return InkWell(
                          onTap: () {
                            Navigator.pop(ctx); // Close sheet
                            onSelectUser(doc); // Switch tab & open detail view!
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: AppColors.premiumCardDeco(borderRadius: 16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: badgeColor.withOpacity(0.1),
                                  child: Text(
                                    (data['nama'] ?? 'U').toString().substring(0, 1).toUpperCase(),
                                    style: TextStyle(fontWeight: FontWeight.bold, color: badgeColor, fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['nama'] ?? 'No Name',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                                      ),
                                      Text(
                                        data['email'] ?? '',
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: badgeColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    role.toString().toUpperCase(),
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: badgeColor),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 16),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx); // Close sheet
                  onTabChange(1); // Switch to Users tab
                },
                icon: const Icon(Icons.settings_rounded, color: Colors.white),
                label: const Text('Kelola Semua Pengguna', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _runCanteenMigration(BuildContext context) async {
    try {
      final snap = await FirebaseFirestore.instance.collection('kantin').get();
      int updatedCount = 0;
      for (var doc in snap.docs) {
        final data = doc.data();
        if (data['foodcourtId'] == null || data['foodcourtId'].toString().trim().isEmpty) {
          await doc.reference.update({
            'foodcourtId': 'lama',
            'foodcourtLabel': 'Foodcourt Lama',
          });
          updatedCount++;
        }
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Migrasi selesai. $updatedCount kantin telah diperbarui.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Migrasi gagal: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0D1B2A), // Dark blue
              Color(0xFF1B3A5C), // Lighter dark blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainChartsRow(List<QueryDocumentSnapshot> orders) {
    // 1. Calculate values for Line Chart (Sales & Visits)
    List<double> dailyRevenue = List.filled(7, 0.0);
    List<double> dailyOrders = List.filled(7, 0.0);
    
    for (var doc in orders) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = data['waktuPesan'] as Timestamp?;
      if (timestamp != null) {
        final date = timestamp.toDate();
        final index = (date.weekday - 1) % 7;
        final total = (data['totalHarga'] as num?)?.toDouble() ?? 0.0;
        dailyRevenue[index] += total;
        dailyOrders[index] += 1.0;
      }
    }

    final baseVisits = [5.0, 20.0, 14.0, 11.0, 17.0, 8.0, 10.0];
    final baseSales = [6.0, 29.0, 18.0, 22.0, 12.0, 16.0, 11.0];
    for (int i = 0; i < 7; i++) {
      baseVisits[i] = (baseVisits[i] + dailyOrders[i] * 2.0).clamp(0.0, 30.0);
      baseSales[i] = (baseSales[i] + dailyRevenue[i] / 25000.0).clamp(0.0, 30.0);
    }

    // June real-time count
    double juneCount = orders.length.toDouble();
    List<double> monthlyOrders = [9.0, 7.0, 14.0, 10.0, 12.0, juneCount > 0 ? (juneCount > 14 ? 14.0 : juneCount) : 8.0];

    // Determine layout: responsive
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 750;
        
        final lineChartCard = _buildLineChartCard(baseSales, baseVisits, 30.0);
        final barChartCard = _buildBarChartCard(monthlyOrders);
        
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: lineChartCard),
              const SizedBox(width: 20),
              Expanded(child: barChartCard),
            ],
          );
        } else {
          return Column(
            children: [
              lineChartCard,
              const SizedBox(height: 20),
              barChartCard,
            ],
          );
        }
      },
    );
  }

  Widget _buildMiddleStatsRow(
    BuildContext context,
    List<QueryDocumentSnapshot> orders,
    List<QueryDocumentSnapshot> userDocs,
    List<QueryDocumentSnapshot> canteenDocs,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 750;
        
        final donutCard = _DonutShareCard(orders: orders);
        final metricsGrid = _buildMetricsGrid(orders, userDocs, canteenDocs);
        
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: donutCard),
              const SizedBox(width: 20),
              Expanded(flex: 7, child: metricsGrid),
            ],
          );
        } else {
          return Column(
            children: [
              donutCard,
              const SizedBox(height: 20),
              metricsGrid,
            ],
          );
        }
      },
    );
  }

  Widget _buildMetricsGrid(
    List<QueryDocumentSnapshot> orders,
    List<QueryDocumentSnapshot> userDocs,
    List<QueryDocumentSnapshot> canteenDocs,
  ) {
    // Calculate values
    final totalOrders = orders.length;
    double revenue = 0.0;
    int soldItems = 0;
    for (var doc in orders) {
      final data = doc.data() as Map<String, dynamic>;
      revenue += (data['totalHarga'] as num?)?.toDouble() ?? 0.0;
      final items = (data['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      for (var item in items) {
        soldItems += (item['qty'] as num?)?.toInt() ?? 0;
      }
    }

    final String orderVal = '$totalOrders';
    final String revVal = _formatRevenue(revenue);
    final String userVal = '${userDocs.length}';
    final String soldVal = '$soldItems';
    final String visitsVal = '${totalOrders * 8 + 120}';
    
    final totalCancelled = orders.where((doc) => (doc.data() as Map)['statusIndex'] == 4).length;
    final String cancelledVal = '$totalCancelled';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Total Orders',
                value: orderVal,
                icon: Icons.shopping_cart_rounded,
                iconColor: const Color(0xFF00D4FF),
                trend: '+25%',
                isTrendPositive: true,
                sparklineColor: const Color(0xFF00D4FF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Total Revenue',
                value: revVal,
                icon: Icons.monetization_on_rounded,
                iconColor: const Color(0xFFEF4444),
                trend: '+15%',
                isTrendPositive: true,
                sparklineColor: const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'New Users',
                value: userVal,
                icon: Icons.people_rounded,
                iconColor: const Color(0xFF10B981),
                trend: '-10%',
                isTrendPositive: false,
                sparklineColor: const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Sold Items',
                value: soldVal,
                icon: Icons.inventory_2_rounded,
                iconColor: const Color(0xFFF59E0B),
                trend: '-14%',
                isTrendPositive: false,
                sparklineColor: const Color(0xFFF59E0B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Total Visits',
                value: visitsVal,
                icon: Icons.remove_red_eye_rounded,
                iconColor: const Color(0xFF00D4FF),
                trend: '+22%',
                isTrendPositive: true,
                sparklineColor: const Color(0xFF00D4FF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Total Returns',
                value: cancelledVal,
                icon: Icons.assignment_return_rounded,
                iconColor: const Color(0xFFF97316),
                trend: '-14%',
                isTrendPositive: false,
                sparklineColor: const Color(0xFFF97316),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatRevenue(double rev) {
    if (rev >= 1000000000) {
      return 'Rp ${(rev / 1000000000).toStringAsFixed(1)}M';
    } else if (rev >= 1000000) {
      return 'Rp ${(rev / 1000000).toStringAsFixed(1)}Jt';
    } else if (rev >= 1000) {
      return 'Rp ${(rev / 1000).toStringAsFixed(0)}Rb';
    }
    return 'Rp ${rev.toInt()}';
  }

  Widget _buildLineChartCard(List<double> dailyRevenue, List<double> dailyOrders, double maxY) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Premium slate-900 background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sales Overview',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Mingguan (Senin - Minggu)',
                      style: TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _chartLegend('Visits', const Color(0xFFEAB308)),
                  const SizedBox(height: 4),
                  _chartLegend('Sales', const Color(0xFF3B82F6)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withOpacity(0.05),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 5,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(color: Colors.white30, fontSize: 9),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
                        final idx = value.toInt();
                        if (idx >= 0 && idx < 7) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(days[idx], style: const TextStyle(color: Colors.white54, fontSize: 9)),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  // Visits / Orders (Orange Line)
                  LineChartBarData(
                    spots: List.generate(7, (i) => FlSpot(i.toDouble(), dailyOrders[i])),
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: const Color(0xFFEAB308),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFEAB308).withOpacity(0.15),
                          const Color(0xFFEAB308).withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Sales (Blue Line)
                  LineChartBarData(
                    spots: List.generate(7, (i) => FlSpot(i.toDouble(), dailyRevenue[i])),
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: const Color(0xFF3B82F6),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF3B82F6).withOpacity(0.25),
                          const Color(0xFF3B82F6).withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 10,
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBarChartCard(List<double> monthlyOrders) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Premium slate-900 background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Status',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Volume Pesanan (Januari - Juni)',
                    style: TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz, color: Colors.white38, size: 18),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Expanded(
            child: BarChart(
              BarChartData(
                barGroups: List.generate(6, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: monthlyOrders[i],
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF8C00), // Dark Orange
                            Color(0xFFFF007F), // Neon Pink
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 14,
                        borderRadius: const BorderRadius.all(Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 14,
                          color: Colors.white.withOpacity(0.03),
                        ),
                      ),
                    ],
                  );
                }),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withOpacity(0.05),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(color: Colors.white30, fontSize: 9),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                        final idx = value.toInt();
                        if (idx >= 0 && idx < 6) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(months[idx], style: const TextStyle(color: Colors.white54, fontSize: 9)),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanteenSalesList(BuildContext context, List<QueryDocumentSnapshot> orders) {
    Map<String, int> canteenRevenue = {};
    Map<String, int> canteenOrderCount = {};
    for (var doc in orders) {
      final data = doc.data() as Map<String, dynamic>;
      final cName = data['kantin'] as String? ?? 'Kantin';
      final total = (data['totalHarga'] as num?)?.toInt() ?? 0;
      canteenRevenue[cName] = (canteenRevenue[cName] ?? 0) + total;
      canteenOrderCount[cName] = (canteenOrderCount[cName] ?? 0) + 1;
    }

    final sortedCanteens = canteenRevenue.keys.toList()
      ..sort((a, b) => canteenRevenue[b]!.compareTo(canteenRevenue[a]!));

    int maxRevenue = 0;
    for (var rev in canteenRevenue.values) {
      if (rev > maxRevenue) maxRevenue = rev;
    }
    if (maxRevenue == 0) maxRevenue = 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bar_chart_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Statistik Penjualan per Stan Kantin',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (sortedCanteens.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('Belum ada transaksi penjualan.', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
            )
          else
            ...sortedCanteens.map((cName) {
              final revenue = canteenRevenue[cName] ?? 0;
              final orderCount = canteenOrderCount[cName] ?? 0;
              final percentage = revenue / maxRevenue;
              
              final rpFormat = NumberFormat.currency(
                locale: 'id',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(revenue);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            cName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '$orderCount Pesanan • $rpFormat',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final maxWidth = constraints.maxWidth;
                        return Stack(
                          children: [
                            Container(
                              height: 14,
                              width: maxWidth,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              height: 14,
                              width: maxWidth * percentage,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.cyan,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(7),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildTransaksiTerbaru(BuildContext context, List<QueryDocumentSnapshot> orders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Transaksi Terbaru',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            GestureDetector(
              onTap: () => _showPesananDetails(context, orders, 'Semua Transaksi'),
              child: const Text(
                'Lihat Semua',
                style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (orders.isEmpty)
          Container(
            height: 150,
            alignment: Alignment.center,
            decoration: AppColors.premiumCardDeco(borderRadius: 12),
            child: const Text('Belum ada transaksi', style: TextStyle(color: Colors.grey, fontSize: 11)),
          )
        else
          ...orders.take(5).map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final canteen = data['kantin'] ?? 'Kantin';
            final total = data['totalHarga'] ?? 0;
            final statusIndex = data['statusIndex'] as int? ?? 0;
            
            return GestureDetector(
              onTap: () => showOrderDetail(context, data),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: AppColors.premiumCardDeco(borderRadius: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            canteen,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _statusBadge(statusIndex),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(total),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 11),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildKantinTerpopuler(BuildContext context, List<Map<String, dynamic>> popularCanteens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kantin Terpopuler',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 10),
        if (popularCanteens.isEmpty)
          Container(
            height: 150,
            alignment: Alignment.center,
            decoration: AppColors.premiumCardDeco(borderRadius: 12),
            child: const Text('Belum ada kantin', style: TextStyle(color: Colors.grey, fontSize: 11)),
          )
        else
          ...popularCanteens.take(5).toList().asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final item = entry.value;
            
            Color rankColor;
            if (rank == 1) {
              rankColor = Colors.amber.shade700;
            } else if (rank == 2) {
              rankColor = Colors.grey.shade600;
            } else if (rank == 3) {
              rankColor = Colors.orange.shade700;
            } else {
              rankColor = Colors.grey.shade400;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: AppColors.premiumCardDeco(borderRadius: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: rankColor,
                    child: Text('$rank', style: const TextStyle(color: AppColors.textPrimary, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['nama'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Icon(Icons.star_rounded, color: Colors.amber.shade700, size: 10),
                            const SizedBox(width: 2),
                            Text('${item['rating']}', style: const TextStyle(fontSize: 9)),
                            const SizedBox(width: 6),
                            Text('${item['count']} pesanan', style: TextStyle(color: Colors.grey.shade600, fontSize: 9)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF090D16),
        border: Border(
          top: BorderSide(color: Colors.white12, width: 0.5),
        ),
      ),
      child: const Center(
        child: Text(
          'Copyright © 2026 FoodTrack. All rights reserved.',
          style: TextStyle(
            color: Colors.white24,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
        const Text(
          'Ringkasan Platform',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 15),
        StreamBuilder<QuerySnapshot>(
          stream: FirestoreService.streamSemuaPesanan(),
          builder: (context, orderSnapshot) {
            if (!orderSnapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            
            final orders = orderSnapshot.data!.docs;
            int totalRevenue = 0;
            for (var doc in orders) {
              totalRevenue += (doc['totalHarga'] as num).toInt();
            }

            return StreamBuilder<QuerySnapshot>(
              stream: FirestoreService.streamKantin(),
              builder: (context, canteenSnapshot) {
                if (!canteenSnapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                final canteenCount = canteenSnapshot.data!.docs.length;
                final canteenDocs = canteenSnapshot.data!.docs;
                
                return StreamBuilder<QuerySnapshot>(
                  stream: FirestoreService.streamSemuaUser(),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    final userCount = userSnapshot.data!.docs.length;
                    final userDocs = userSnapshot.data!.docs;
                    
                    Map<String, int> canteenCounts = {};
                    for (var doc in orders) {
                      final cName = doc['kantin'] as String? ?? 'Kantin';
                      canteenCounts[cName] = (canteenCounts[cName] ?? 0) + 1;
                    }

                    final List<Map<String, dynamic>> popularCanteens = [];
                    for (var doc in canteenDocs) {
                      final cData = doc.data() as Map<String, dynamic>;
                      final name = cData['nama'] ?? '';
                      final count = canteenCounts[name] ?? 0;
                      popularCanteens.add({
                        'doc': doc,
                        'nama': name,
                        'rating': cData['rating'] ?? 4.5,
                        'count': count,
                      });
                    }
                    popularCanteens.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

                    return Column(
                      children: [
                        _buildMainChartsRow(orders),
                        const SizedBox(height: 20),
                        _buildMiddleStatsRow(context, orders, userDocs, canteenDocs),
                        const SizedBox(height: 25),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Status Pesanan Saat Ini',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _StatusCard(
                                count: orders.where((d) => (d.data() as Map)['statusIndex'] == 0).length,
                                label: 'Pesanan Baru',
                                color: Colors.orange,
                                onTap: () {
                                  final filtered = orders.where((d) => (d.data() as Map)['statusIndex'] == 0).toList();
                                  _showPesananDetails(context, filtered, 'Pesanan Baru (Belum Konfirmasi)');
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _StatusCard(
                                count: orders.where((d) => (d.data() as Map)['statusIndex'] == 1 || (d.data() as Map)['statusIndex'] == 2).length,
                                label: 'Sedang Diproses',
                                color: Colors.blue,
                                onTap: () {
                                  final filtered = orders.where((d) => (d.data() as Map)['statusIndex'] == 1 || (d.data() as Map)['statusIndex'] == 2).toList();
                                  _showPesananDetails(context, filtered, 'Pesanan Sedang Diproses / Siap');
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _StatusCard(
                                count: orders.where((d) => (d.data() as Map)['statusIndex'] == 3).length,
                                label: 'Selesai',
                                color: Colors.green,
                                onTap: () {
                                  final filtered = orders.where((d) => (d.data() as Map)['statusIndex'] == 3).toList();
                                  _showPesananDetails(context, filtered, 'Pesanan Selesai');
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),
                        isCompact
                            ? Column(
                                children: [
                                  _buildTransaksiTerbaru(context, orders),
                                  const SizedBox(height: 20),
                                  _buildKantinTerpopuler(context, popularCanteens),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildTransaksiTerbaru(context, orders)),
                                  const SizedBox(width: 15),
                                  Expanded(child: _buildKantinTerpopuler(context, popularCanteens)),
                                ],
                              ),
                        
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'Quick Actions',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: TextButton.icon(
                                onPressed: () => _runCanteenMigration(context),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                icon: const Icon(Icons.sync_rounded, size: 16, color: AppColors.primary),
                                label: const Text(
                                  'Migrasi Database',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildQuickActionCard(
                              icon: Icons.add_business_rounded,
                              label: 'Tambah Stan',
                              onTap: () {
                                onTabChange(2);
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  canteenKey.currentState?.showForm();
                                });
                              },
                            ),
                            const SizedBox(width: 10),
                            _buildQuickActionCard(
                              icon: Icons.manage_accounts_rounded,
                              label: 'Kelola User',
                              onTap: () => onTabChange(1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildQuickActionCard(
                              icon: Icons.store_rounded,
                              label: 'Kelola Stan',
                              onTap: () => onTabChange(2),
                            ),
                            const SizedBox(width: 10),
                            _buildQuickActionCard(
                              icon: Icons.done_all_rounded,
                              label: 'Pesanan Selesai',
                              onTap: () {
                                final completedOrders = orders.where((d) => (d.data() as Map)['statusIndex'] == 3).toList();
                                _showPesananDetails(context, completedOrders, 'Transaksi Selesai');
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }
                );
              }
            );
          },
        ),
      ],
     ),
    ),
    _buildFooter(),
   ],
  );
 }
}

class _StatusCard extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _StatusCard({
    required this.count,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color.withValues(alpha: 0.9),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  State<UserManagement> createState() => UserManagementState();
}

class UserManagementState extends State<UserManagement> {
  DocumentSnapshot? _selectedUser;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  void selectUser(DocumentSnapshot userDoc) {
    setState(() {
      _selectedUser = userDoc;
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedUser != null) {
      return _UserDetailView(
        user: _selectedUser!,
        onBack: () => setState(() => _selectedUser = null),
      );
    }

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: AppColors.premiumCardDeco(borderRadius: 16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari pengguna (Nama atau Email)...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirestoreService.streamSemuaUser(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              
              final docs = snapshot.data!.docs;
              final filtered = docs.where((doc) {
                final user = doc.data() as Map<String, dynamic>;
                final nama = (user['nama'] ?? '').toString().toLowerCase();
                final email = (user['email'] ?? '').toString().toLowerCase();
                return nama.contains(_searchQuery) || email.contains(_searchQuery);
              }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people_rounded, size: 60, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isNotEmpty ? 'Pengguna tidak ditemukan' : 'Belum ada pengguna terdaftar',
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final userDoc = filtered[index];
                  final user = userDoc.data() as Map<String, dynamic>;
                  final role = user['role'] ?? 'pembeli';
                  final isAdmin = role == 'admin';
                  final isPedagang = role == 'pedagang';
                  
                  Color avatarBg;
                  IconData avatarIcon;
                  Color badgeColor;

                  if (isAdmin) {
                    avatarBg = Colors.amber.shade700;
                    avatarIcon = Icons.admin_panel_settings_rounded;
                    badgeColor = Colors.amber.shade700;
                  } else if (isPedagang) {
                    avatarBg = AppColors.secondary;
                    avatarIcon = Icons.storefront_rounded;
                    badgeColor = Colors.purple;
                  } else {
                    avatarBg = AppColors.cyan;
                    avatarIcon = Icons.person_rounded;
                    badgeColor = Colors.blue;
                  }
                  
                  return InkWell(
                    onTap: () => setState(() => _selectedUser = userDoc),
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(15),
                      decoration: AppColors.premiumCardDeco(borderRadius: 15),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: avatarBg,
                            child: Icon(
                              avatarIcon,
                              color: AppColors.textPrimary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user['nama'] ?? 'No Name',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  user['email'] ?? '',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              role.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: badgeColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _UserDetailView extends StatelessWidget {
  final DocumentSnapshot user;
  final VoidCallback onBack;

  const _UserDetailView({
    required this.user,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final userData = user.data() as Map<String, dynamic>;
    final name = userData['nama'] ?? 'No Name';
    final email = userData['email'] ?? '';
    final role = userData['role'] ?? 'pembeli';
    final userUid = user.id;
    
    String joinDateStr = 'Bergabung sejak -';
    if (userData['createdAt'] != null) {
      final timestamp = userData['createdAt'] as Timestamp;
      joinDateStr = 'Bergabung ${DateFormat('dd MMM yyyy').format(timestamp.toDate())}';
    }

    Color badgeColor = role == 'admin' ? Colors.amber.shade700 : (role == 'pedagang' ? Colors.purple : Colors.blue);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('pesanan')
          .where('uid', isEqualTo: userUid)
          .snapshots(),
      builder: (context, snapshot) {
        final orders = snapshot.data?.docs ?? [];
        
        // Urutkan riwayat transaksi secara waktuPesan menurun
        orders.sort((a, b) {
          final tA = a.data()['waktuPesan'] as Timestamp?;
          final tB = b.data()['waktuPesan'] as Timestamp?;
          if (tA == null) return 1;
          if (tB == null) return -1;
          return tB.compareTo(tA);
        });

        int totalOrders = orders.length;
        int successfulTransactions = 0;
        int totalSpent = 0;

        for (var doc in orders) {
          final oData = doc.data();
          final statusIdx = oData['statusIndex'] as int? ?? 0;
          if (statusIdx == 3) {
            successfulTransactions++;
            totalSpent += (oData['totalHarga'] as num).toInt();
          }
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Back button
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
                label: const Text(
                  'Kembali ke Daftar User',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
            
            const Text(
              'Detail Pengguna',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 15),

            // Profile info card (Dewi Lestari style)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppColors.premiumCardDeco(borderRadius: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: badgeColor.withValues(alpha: 0.1),
                    child: Text(
                      name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: badgeColor),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: badgeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                role.toUpperCase(),
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: badgeColor),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                joinDateStr,
                                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
            const SizedBox(height: 15),

            // Tiga kartu stat side-by-side
            Row(
              children: [
                Expanded(
                  child: _DetailStatCard(
                    title: 'Total Booking',
                    value: '$totalOrders',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DetailStatCard(
                    title: 'Transaksi Sukses',
                    value: '$successfulTransactions',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DetailStatCard(
                    title: 'Total Belanja',
                    value: NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(totalSpent),
                    color: AppColors.cyan,
                    isSmallValueText: totalSpent >= 100000,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Riwayat Transaksi section
            const Text(
              'Riwayat Transaksi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            if (orders.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_rounded, size: 40, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada transaksi',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final oData = order.data();
                  final statusIdx = oData['statusIndex'] as int? ?? 0;
                  final total = oData['totalHarga'] ?? 0;
                  final canteenName = oData['kantin'] ?? 'Kantin';
                  final itemsCount = (oData['items'] as List?)?.length ?? 0;
                  
                  final tgl = oData['waktuPesan'] != null
                      ? DateFormat('dd MMM yyyy, HH:mm').format((oData['waktuPesan'] as Timestamp).toDate())
                      : '-';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: AppColors.premiumCardDeco(borderRadius: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      title: Text(
                        canteenName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      subtitle: Text(
                        '$itemsCount item • $tgl',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(total),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          _statusBadge(statusIdx),
                        ],
                      ),
                      onTap: () {
                        // Buka rincian item pesanan
                        _AdminDashboard.showOrderDetail(context, oData);
                      },
                    ),
                  );
                },
              ),
            
            // Bottom Back Button
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: onBack,
                child: const Text(
                  '← Kembali ke Daftar User',
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        );
      },
    );
  }
}



class _DetailStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final bool isSmallValueText;

  const _DetailStatCard({
    required this.title,
    required this.value,
    required this.color,
    this.isSmallValueText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isSmallValueText ? 12 : 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class CanteenManagement extends StatefulWidget {
  const CanteenManagement({super.key});

  @override
  State<CanteenManagement> createState() => CanteenManagementState();
}

class CanteenManagementState extends State<CanteenManagement> {
  String _searchQ = '';
  final _searchCtrl = TextEditingController();

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
    'images/kantin1.jpg',
    'images/kantin2.jpg',
    'images/kantin3.jpeg',
    'images/kantin4.jpeg',
    'images/kantin5.jpg',
    'images/kantin6.png',
    'images/kantin7.jpeg',
    'images/kantin8.jpg',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showSetFoodcourtDialog(String docId, String kantinNama) {
    showDialog(
      context: context,
      builder: (ctx) {
        String selectedId = 'lama';
        return StatefulBuilder(
          builder: (context, setS) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Set Foodcourt - $kantinNama',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text('Foodcourt Lama'),
                  value: 'lama',
                  groupValue: selectedId,
                  onChanged: (val) {
                    if (val != null) setS(() => selectedId = val);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Foodcourt Baru'),
                  value: 'baru',
                  groupValue: selectedId,
                  onChanged: (val) {
                    if (val != null) setS(() => selectedId = val);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  final label = selectedId == 'lama' ? 'Foodcourt Lama' : 'Foodcourt Baru';
                  await FirebaseFirestore.instance.collection('kantin').doc(docId).update({
                    'foodcourtId': selectedId,
                    'foodcourtLabel': label,
                  });
                  if (mounted) {
                    Navigator.pop(ctx);
                    _msg('Lokasi Foodcourt berhasil diperbarui!');
                  }
                },
                child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  void showForm({String? docId, Map<String, dynamic>? existing}) {
    final isEdit = docId != null;
    final namaCtrl = TextEditingController(text: existing?['nama'] ?? '');
    final descCtrl = TextEditingController(text: existing?['deskripsi'] ?? '');
    final waktuCtrl = TextEditingController(text: existing?['waktu'] ?? '10-15 mnt');
    final menuCountCtrl = TextEditingController(text: existing != null ? '${existing['totalMenu']}' : '0');
    final ratingCtrl = TextEditingController(text: existing != null ? '${existing['rating']}' : '4.5');
    
    String selectedKat = existing?['kategori'] != null && _kategoriPreset.contains(existing!['kategori']) 
        ? existing['kategori'] 
        : _kategoriPreset.first;
        
    String selectedGambar = existing?['gambar'] != null && _gambarPreset.contains(existing!['gambar']) 
        ? existing['gambar'] 
        : _gambarPreset.first;
        
    bool isTop = existing?['isTop'] ?? false;
    String selectedFoodcourt = existing?['foodcourtId'] ?? 'lama';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setS) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.96),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -4),
                ),
              ],
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
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(isEdit ? Icons.edit_note_rounded : Icons.add_business_rounded, color: AppColors.primary, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        isEdit ? 'Edit Stan Kantin' : 'Tambah Stan Kantin Baru',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  
                  // NAMA
                  _ff('Nama Kantin', namaCtrl, Icons.storefront_rounded),
                  const SizedBox(height: 14),
                  
                  // DESKRIPSI
                  _ff('Deskripsi', descCtrl, Icons.description_rounded),
                  const SizedBox(height: 14),

                  // KATEGORI & GAMBAR DROPDOWN ROW
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Kategori', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
                                  items: _kategoriPreset.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                                  onChanged: (val) {
                                    if (val != null) setS(() => selectedKat = val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Gambar Stan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedGambar,
                                  isExpanded: true,
                                  items: _gambarPreset.map((g) {
                                    final label = g.split('/').last.split('.').first;
                                    return DropdownMenuItem(value: g, child: Text(label));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setS(() => selectedGambar = val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  const Text('Lokasi Foodcourt', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedFoodcourt,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'lama', child: Text('Foodcourt Lama')),
                          DropdownMenuItem(value: 'baru', child: Text('Foodcourt Baru')),
                        ],
                        onChanged: (val) {
                          if (val != null) setS(() => selectedFoodcourt = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // WAKTU & TOTAL MENU & RATING ROW
                  Row(
                    children: [
                      Expanded(child: _ff('Waktu Ambil (e.g. 10-15 mnt)', waktuCtrl, Icons.timer_rounded)),
                      const SizedBox(width: 12),
                      Expanded(child: _ff('Total Menu', menuCountCtrl, Icons.restaurant_menu_rounded, type: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _ff('Rating (e.g. 4.8)', ratingCtrl, Icons.star_rounded, type: TextInputType.number)),
                      const SizedBox(width: 24),
                      Row(
                        children: [
                          const Text('Rekomendasi Top?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          Switch(
                            value: isTop,
                            activeTrackColor: AppColors.primary.withOpacity(0.5),
                            activeThumbColor: AppColors.primary,
                            onChanged: (val) => setS(() => isTop = val),
                          ),
                        ],
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
                              side: const BorderSide(color: AppColors.danger),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () async {
                              final confirm = await _showConfirmDelete(ctx);
                              if (confirm == true) {
                                await FirestoreService.hapusKantin(docId);
                                if (!context.mounted) return;
                                Navigator.pop(ctx);
                                _msg('Stan Kantin berhasil dihapus');
                              }
                            },
                            child: const Text('Hapus', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      if (isEdit) const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            if (namaCtrl.text.trim().isEmpty || descCtrl.text.trim().isEmpty) {
                              _msg('Nama dan Deskripsi wajib diisi!', isErr: true);
                              return;
                            }
                            final rating = double.tryParse(ratingCtrl.text) ?? 4.5;
                            final totalMenu = int.tryParse(menuCountCtrl.text) ?? 0;
                            
                            if (isEdit) {
                              await FirestoreService.updateKantin(
                                id: docId,
                                nama: namaCtrl.text.trim(),
                                deskripsi: descCtrl.text.trim(),
                                kategori: selectedKat,
                                gambar: selectedGambar,
                                rating: rating,
                                isTop: isTop,
                                waktu: waktuCtrl.text.trim(),
                                totalMenu: totalMenu,
                                foodcourtId: selectedFoodcourt,
                                foodcourtLabel: selectedFoodcourt == 'lama' ? 'Foodcourt Lama' : 'Foodcourt Baru',
                              );
                              _msg('Stan Kantin diperbarui!');
                            } else {
                              await FirestoreService.tambahKantin(
                                nama: namaCtrl.text.trim(),
                                deskripsi: descCtrl.text.trim(),
                                kategori: selectedKat,
                                gambar: selectedGambar,
                                rating: rating,
                                isTop: isTop,
                                waktu: waktuCtrl.text.trim(),
                                totalMenu: totalMenu,
                                foodcourtId: selectedFoodcourt,
                                foodcourtLabel: selectedFoodcourt == 'lama' ? 'Foodcourt Lama' : 'Foodcourt Baru',
                              );
                              _msg('Stan Kantin ditambahkan!');
                            }
                            if (!context.mounted) return;
                            Navigator.pop(ctx);
                          },
                          child: Text(
                            isEdit ? 'Simpan Perubahan' : 'Tambah Stan',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showConfirmDelete(BuildContext ctx) {
    return showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Stan Kantin?',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus stan kantin ini secara permanen dari database? Seluruh pembeli tidak akan dapat mengakses stan ini lagi.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Hapus Permanen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _msg(String txt, {bool isErr = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(txt),
        backgroundColor: isErr ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _ff(String label, TextEditingController ctrl, IconData icon, {TextInputType? type}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: type,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.secondary, size: 20),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.cyan)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Search & Info Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: AppColors.premiumCardDeco(borderRadius: 16),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (val) => setState(() => _searchQ = val.trim().toLowerCase()),
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Cari stan kantin...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirestoreService.streamKantin(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Terjadi kesalahan: ${snapshot.error}', style: const TextStyle(color: AppColors.danger)));
                }
                
                final docs = snapshot.data?.docs ?? [];
                
                final filtered = docs.where((doc) {
                  final nama = (doc.data()['nama'] ?? '').toString().toLowerCase();
                  final deskripsi = (doc.data()['deskripsi'] ?? '').toString().toLowerCase();
                  return nama.contains(_searchQ) || deskripsi.contains(_searchQ);
                }).toList();
                
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.storefront_rounded, size: 60, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          _searchQ.isNotEmpty ? 'Stan Kantin tidak ditemukan' : 'Belum ada Stan Kantin terdaftar',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final doc = filtered[index];
                    final id = doc.id;
                    final data = doc.data();
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: AppColors.premiumCardDeco(borderRadius: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            data['gambar'] ?? 'images/kantin1.jpg',
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(width: 56, height: 56, color: AppColors.cyanLight, child: const Icon(Icons.storefront_rounded, color: AppColors.primary)),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                data['nama'] ?? '',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                              ),
                            ),
                            if (data['foodcourtId'] == null || data['foodcourtId'].toString().trim().isEmpty)
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(6)),
                                child: const Text(
                                  'Set Lokasi',
                                  style: TextStyle(color: Colors.red, fontSize: 8, fontWeight: FontWeight.bold),
                                ),
                              ),
                            if (data['isTop'] == true) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(6)),
                                child: Row(
                                  children: [
                                    Icon(Icons.star_rounded, color: Colors.amber.shade800, size: 10),
                                    const SizedBox(width: 2),
                                    Text('Top', style: TextStyle(color: Colors.amber.shade900, fontSize: 8, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              data['deskripsi'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.local_offer_outlined, size: 12, color: Colors.grey.shade400),
                                    const SizedBox(width: 4),
                                    Text(data['kategori'] ?? '', style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.timer_outlined, size: 12, color: Colors.grey.shade400),
                                    const SizedBox(width: 4),
                                    Text(data['waktu'] ?? '', style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (data['foodcourtId'] == null || data['foodcourtId'].toString().trim().isEmpty)
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () => _showSetFoodcourtDialog(id, data['nama'] ?? 'Kantin'),
                                child: const Text(
                                  'Set Foodcourt',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                              onPressed: () => showForm(docId: id, existing: data),
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => showForm(),
        child: const Icon(Icons.add, color: AppColors.textPrimary),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final Map<String, dynamic> data;
  const _OrderTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: AppColors.premiumCardDeco(borderRadius: 15),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['kantin'] ?? 'Kantin',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  '${data['items']?.length ?? 0} item • ${data['pembeliNama']}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                .format(data['totalHarga'] ?? 0),
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: active ? AppColors.primary : Colors.grey.shade400,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: active ? AppColors.primary : Colors.grey.shade400,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class MenuManagement extends StatefulWidget {
  const MenuManagement({super.key});

  @override
  State<MenuManagement> createState() => MenuManagementState();
}

class MenuManagementState extends State<MenuManagement> {
  String _searchQ = '';
  final _searchCtrl = TextEditingController();
  String _filterKantin = 'Semua';

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

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void showForm({String? docId, Map<String, dynamic>? existing, List<QueryDocumentSnapshot> canteens = const []}) {
    final isEdit = docId != null;
    final namaCtrl = TextEditingController(text: existing?['nama'] ?? '');
    final hargaCtrl = TextEditingController(text: existing != null ? '${existing['harga']}' : '15000');
    final stokCtrl = TextEditingController(text: existing != null ? '${existing['stok']}' : '20');
    final descCtrl = TextEditingController(text: existing?['desc'] ?? '');
    
    String selectedKantinId = existing?['kantinId'] ?? (canteens.isNotEmpty ? canteens.first.id : '');
    String selectedKantinNama = existing?['kantin'] ?? (canteens.isNotEmpty ? (canteens.first.data() as Map<String, dynamic>)['nama'] : '');
    
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
      builder: (ctx) => StatefulBuilder(
        builder: (context, setS) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.96),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -4),
                ),
              ],
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
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(isEdit ? Icons.edit_note_rounded : Icons.restaurant_menu_rounded, color: AppColors.primary, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        isEdit ? 'Edit Menu Makanan' : 'Tambah Menu Baru',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  
                  // NAMA
                  _ff('Nama Menu', namaCtrl, Icons.restaurant_rounded),
                  const SizedBox(height: 14),
                  
                  // DESKRIPSI
                  _ff('Deskripsi / Detail Menu', descCtrl, Icons.description_rounded),
                  const SizedBox(height: 14),

                  // KANTIN SELECTION DROPDOWN
                  const Text('Pilih Stan Kantin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedKantinId.isNotEmpty ? selectedKantinId : null,
                        isExpanded: true,
                        hint: const Text('Pilih Kantin'),
                        items: canteens.map((c) {
                          final cData = c.data() as Map<String, dynamic>;
                          return DropdownMenuItem<String>(
                            value: c.id,
                            child: Text(cData['nama'] ?? 'Kantin'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            final selectedC = canteens.firstWhere((element) => element.id == val);
                            final selectedCData = selectedC.data() as Map<String, dynamic>;
                            setS(() {
                              selectedKantinId = val;
                              selectedKantinNama = selectedCData['nama'] ?? '';
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // KATEGORI DROPDOWN
                  const Text('Kategori', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
                        items: _kategoriPreset.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                        onChanged: (val) {
                          if (val != null) setS(() => selectedKat = val);
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
                  const SizedBox(height: 14),

                  // HARGA & STOK & TERSEDIA ROW
                  Row(
                    children: [
                      Expanded(child: _ff('Harga (Rp)', hargaCtrl, Icons.money_rounded, type: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: _ff('Stok Menu', stokCtrl, Icons.inventory_2_rounded, type: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Text('Tersedia / Aktif?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      Switch(
                        value: tersedia,
                        activeTrackColor: AppColors.primary.withOpacity(0.5),
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) => setS(() => tersedia = val),
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
                              side: const BorderSide(color: AppColors.danger),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () async {
                              final confirm = await _showConfirmDelete(ctx);
                              if (confirm == true) {
                                await FirestoreService.hapusMenu(docId);
                                if (!context.mounted) return;
                                Navigator.pop(ctx);
                                _msg('Menu berhasil dihapus');
                              }
                            },
                            child: const Text('Hapus', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      if (isEdit) const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            if (namaCtrl.text.trim().isEmpty) {
                              _msg('Nama menu wajib diisi!', isErr: true);
                              return;
                            }
                            if (selectedKantinId.isEmpty) {
                              _msg('Silakan pilih stan kantin terlebih dahulu!', isErr: true);
                              return;
                            }
                            final harga = int.tryParse(hargaCtrl.text) ?? 15000;
                            final stok = int.tryParse(stokCtrl.text) ?? 20;
                            
                            if (isEdit) {
                              await FirestoreService.updateMenu(
                                id: docId,
                                nama: namaCtrl.text.trim(),
                                harga: harga,
                                stok: stok,
                                desc: descCtrl.text.trim(),
                                kantin: selectedKantinNama,
                                kantinId: selectedKantinId,
                                tersedia: tersedia,
                                kategori: selectedKat,
                                gambar: selectedGambar,
                              );
                              _msg('Menu berhasil diperbarui!');
                            } else {
                              await FirestoreService.tambahMenu(
                                nama: namaCtrl.text.trim(),
                                harga: harga,
                                stok: stok,
                                desc: descCtrl.text.trim(),
                                kantin: selectedKantinNama,
                                kantinId: selectedKantinId,
                                tersedia: tersedia,
                                kategori: selectedKat,
                                gambar: selectedGambar,
                              );
                              _msg('Menu berhasil ditambahkan!');
                            }
                            if (!context.mounted) return;
                            Navigator.pop(ctx);
                          },
                          child: Text(
                            isEdit ? 'Simpan Perubahan' : 'Tambah Menu',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showConfirmDelete(BuildContext ctx) {
    return showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Menu?',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus menu ini dari database? Menu ini tidak akan dapat dipesan oleh pembeli.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Hapus Permanen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _msg(String txt, {bool isErr = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(txt),
        backgroundColor: isErr ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _ff(String label, TextEditingController ctrl, IconData icon, {TextInputType? type}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: type,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.secondary, size: 20),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.cyan)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService.streamKantin(),
      builder: (context, canteenSnap) {
        final canteens = canteenSnap.data?.docs ?? [];
        
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              // Search & Filter Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: AppColors.premiumCardDeco(borderRadius: 16),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (val) => setState(() => _searchQ = val.trim().toLowerCase()),
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Cari menu makanan...',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                            prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Kantin filter dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: AppColors.premiumCardDeco(borderRadius: 16),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _filterKantin,
                          hint: const Text('Filter Stan'),
                          items: [
                            const DropdownMenuItem(value: 'Semua', child: Text('Semua Stan')),
                            ...canteens.map((c) {
                              final name = (c.data() as Map<String, dynamic>)['nama'] ?? '';
                              return DropdownMenuItem(value: name, child: Text(name));
                            }),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _filterKantin = val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirestoreService.streamSemuaMenu(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    }
                    
                    if (snapshot.hasError) {
                      return Center(child: Text('Terjadi kesalahan: ${snapshot.error}', style: const TextStyle(color: AppColors.danger)));
                    }
                    
                    final docs = snapshot.data?.docs ?? [];
                    
                    final filtered = docs.where((doc) {
                      final data = doc.data();
                      final nama = (data['nama'] ?? '').toString().toLowerCase();
                      final desc = (data['desc'] ?? '').toString().toLowerCase();
                      final kantin = (data['kantin'] ?? '').toString();
                      
                      final matchesSearch = nama.contains(_searchQ) || desc.contains(_searchQ);
                      final matchesKantin = _filterKantin == 'Semua' || kantin == _filterKantin;
                      
                      return matchesSearch && matchesKantin;
                    }).toList();
                    
                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.restaurant_menu_rounded, size: 60, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text(
                              _searchQ.isNotEmpty ? 'Menu tidak ditemukan' : 'Belum ada Menu makanan terdaftar',
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final doc = filtered[index];
                        final id = doc.id;
                        final data = doc.data();
                        final isAvailable = data['tersedia'] ?? true;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: AppColors.premiumCardDeco(borderRadius: 16).copyWith(
                            color: isAvailable ? Colors.white.withOpacity(0.92) : Colors.grey.shade100.withOpacity(0.8),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                data['gambar'] ?? 'images/kantin1.jpg',
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(width: 56, height: 56, color: AppColors.cyanLight, child: const Icon(Icons.restaurant_rounded, color: AppColors.primary)),
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    data['nama'] ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold, 
                                      fontSize: 14, 
                                      color: isAvailable ? AppColors.textPrimary : Colors.grey,
                                      decoration: isAvailable ? TextDecoration.none : TextDecoration.lineThrough,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isAvailable ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isAvailable ? 'Tersedia' : 'Habis',
                                    style: TextStyle(
                                      color: isAvailable ? const Color(0xFF15803D) : const Color(0xFFB91C1C), 
                                      fontSize: 9, 
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  'Rp ${data['harga'] ?? 0} • Stok: ${data['stok'] ?? 0}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary, fontSize: 11),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Stan: ${data['kantin'] ?? ''}',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                              onPressed: () => showForm(docId: id, existing: data, canteens: canteens),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primary,
            onPressed: () => showForm(canteens: canteens),
            child: const Icon(Icons.add, color: AppColors.textPrimary),
          ),
        );
      },
    );
  }
}

// ============================================================================
// NEW PREMIUM DASHBOARD WIDGETS
// ============================================================================

class _MiniSparkline extends StatelessWidget {
  final Color color;
  const _MiniSparkline({required this.color});

  @override
  Widget build(BuildContext context) {
    final List<double> heights = [4, 6, 3, 7, 5, 8, 4, 9, 6, 11, 7, 10, 5, 8];
    return SizedBox(
      height: 24,
      width: double.infinity,
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(heights.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: heights[i],
                  color: color,
                  width: 2.5,
                  borderRadius: BorderRadius.circular(1),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String trend;
  final bool isTrendPositive;
  final Color sparklineColor;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.trend,
    required this.isTrendPositive,
    required this.sparklineColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: iconColor, size: 16),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                trend,
                style: TextStyle(
                  color: isTrendPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MiniSparkline(color: sparklineColor),
        ],
      ),
    );
  }
}

class _DonutShareCard extends StatelessWidget {
  final List<QueryDocumentSnapshot> orders;

  const _DonutShareCard({required this.orders});

  @override
  Widget build(BuildContext context) {
    Map<String, int> canteenOrderCounts = {};
    for (var doc in orders) {
      final data = doc.data() as Map<String, dynamic>;
      final cName = data['kantin'] as String? ?? 'Kantin';
      canteenOrderCounts[cName] = (canteenOrderCounts[cName] ?? 0) + 1;
    }

    final sortedCanteens = canteenOrderCounts.keys.toList()
      ..sort((a, b) => canteenOrderCounts[b]!.compareTo(canteenOrderCounts[a]!));

    final String top1Name = sortedCanteens.isNotEmpty ? sortedCanteens[0] : 'Stan A';
    final int top1Count = sortedCanteens.isNotEmpty ? canteenOrderCounts[top1Name]! : 0;

    final String top2Name = sortedCanteens.length > 1 ? sortedCanteens[1] : 'Stan B';
    final int top2Count = sortedCanteens.length > 1 ? canteenOrderCounts[top2Name]! : 0;

    int othersCount = 0;
    for (int i = 2; i < sortedCanteens.length; i++) {
      othersCount += canteenOrderCounts[sortedCanteens[i]]!;
    }

    final List<PieChartSectionData> sections = [
      PieChartSectionData(
        value: top1Count == 0 ? 1.0 : top1Count.toDouble(),
        color: const Color(0xFF10B981),
        radius: 18,
        showTitle: false,
      ),
      PieChartSectionData(
        value: top2Count == 0 ? 0.5 : top2Count.toDouble(),
        color: const Color(0xFF00D4FF),
        radius: 18,
        showTitle: false,
      ),
      PieChartSectionData(
        value: othersCount == 0 ? 0.3 : othersCount.toDouble(),
        color: const Color(0xFFEF4444),
        radius: 18,
        showTitle: false,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Porsi Penjualan Stan',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz, color: Colors.white38, size: 18),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Center(
            child: SizedBox(
              height: 130,
              width: 130,
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 46,
                      sections: sections,
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            top1Name.length > 8 ? '${top1Name.substring(0, 7)}..' : top1Name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '$top1Count',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildDonutLegendRow(top1Name, top1Count, const Color(0xFF10B981)),
          const SizedBox(height: 8),
          _buildDonutLegendRow(top2Name, top2Count, const Color(0xFF00D4FF)),
          const SizedBox(height: 8),
          _buildDonutLegendRow(sortedCanteens.length > 2 ? 'Lainnya' : 'Stan Lain', othersCount, const Color(0xFFEF4444)),
        ],
      ),
    );
  }

  Widget _buildDonutLegendRow(String label, int value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3), width: 0.5),
          ),
          child: Text(
            '$value',
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
