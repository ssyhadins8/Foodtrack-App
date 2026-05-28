import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodtrack/cart_provider.dart';
import 'package:foodtrack/pages/keranjang_page.dart';

class MenuKantin extends StatelessWidget {
  final String namaKantin;
  final List<dynamic> menuList;

  const MenuKantin({
    super.key,
    required this.namaKantin,
    required this.menuList,
  });

  String _formatHarga(int harga) {
    return 'Rp${harga.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      extendBody: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/onboard.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xFF1A3C2A),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        namaKantin,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A3C2A),
                        ),
                      ),
                    ),
                    // Keranjang icon di header
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const KeranjangPage(),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.shopping_cart_rounded,
                              color: Color(0xFF2E7D52),
                              size: 24,
                            ),
                          ),
                          if (cart.totalItem > 0)
                            Positioned(
                              right: 4,
                              top: 4,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE87722),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${cart.totalItem > 9 ? '9+' : cart.totalItem}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // GRID MENU
              Expanded(
                child: menuList.isEmpty
                    ? const Center(
                        child: Text(
                          'Menu belum tersedia',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.82,
                            ),
                        itemCount: menuList.length,
                        itemBuilder: (context, index) {
                          final menu = menuList[index];
                          final qty = cart.qtyOf(menu['nama'], namaKantin);
                          return _MenuCard(
                            menu: menu,
                            qty: qty,
                            onTambah: () => cart.tambah(
                              CartItem(
                                nama: menu['nama'],
                                gambar: menu['gambar'],
                                harga: menu['harga'],
                                kantin: namaKantin,
                              ),
                            ),
                            onKurang: () => cart.kurang(
                              CartItem(
                                nama: menu['nama'],
                                gambar: menu['gambar'],
                                harga: menu['harga'],
                                kantin: namaKantin,
                              ),
                            ),
                            formatHarga: _formatHarga,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),

      // TOMBOL LIHAT KERANJANG
      bottomNavigationBar: cart.totalItem > 0
          ? Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D52),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const KeranjangPage()),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_cart_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Lihat Keranjang • ${_formatHarga(cart.totalHarga)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final Map<String, dynamic> menu;
  final int qty;
  final VoidCallback onTambah;
  final VoidCallback onKurang;
  final String Function(int) formatHarga;

  const _MenuCard({
    required this.menu,
    required this.qty,
    required this.onTambah,
    required this.onKurang,
    required this.formatHarga,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.asset(
                menu['gambar'],
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFD4F5E2),
                  child: const Center(
                    child: Icon(
                      Icons.fastfood,
                      color: Color(0xFF2E9E75),
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menu['nama'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A3C2A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatHarga(menu['harga']),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2E9E75),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                qty == 0
                    ? GestureDetector(
                        onTap: onTambah,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E9E75),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Tambah',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: onKurang,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE74C3C),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          Text(
                            '$qty',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A3C2A),
                            ),
                          ),
                          GestureDetector(
                            onTap: onTambah,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2E9E75),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
