import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/promo_model.dart';
import '../../services/promo_service.dart';
import '../../widgets/promo_card.dart';
import 'promo_detail_page.dart';

class PromoPage extends StatefulWidget {
  const PromoPage({Key? key}) : super(key: key);

  @override
  State<PromoPage> createState() => _PromoPageState();
}

class _PromoPageState extends State<PromoPage> {
  String _selectedFoodcourt = 'all'; // 'all', 'lama', 'baru'
  String? _selectedKantinId; // null means all

  @override
  Widget build(BuildContext context) {
    final promoService = Provider.of<PromoService>(context, listen: false);
    return Scaffold(
      backgroundColor: const Color(0xFF1A202C), // dark navy
      appBar: AppBar(
        title: const Text(
          'Promo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF1A202C),
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _buildFoodcourtFilter(),
          const SizedBox(height: 8),
          _buildKantinFilter(promoService),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<PromoModel>>(
              stream: promoService.getAllActivePromos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _emptyState();
                }
                // Apply in‑memory filters
                var promos = snapshot.data!;
                if (_selectedFoodcourt != 'all') {
                  promos = promos.where((p) => p.foodcourtId == _selectedFoodcourt).toList();
                }
                if (_selectedKantinId != null) {
                  promos = promos.where((p) => p.kantinId == _selectedKantinId).toList();
                }
                if (promos.isEmpty) {
                  return _emptyState();
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: promos.length,
                  itemBuilder: (context, index) {
                    final promo = promos[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PromoDetailPage(promo: promo),
                        ),
                      ),
                      child: PromoCard(promo: promo),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodcourtFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _filterChip('Semua', 'all', isSelected: _selectedFoodcourt == 'all'),
        const SizedBox(width: 8),
        _filterChip('FC Lama', 'lama', bgColor: const Color(0xFF1D9E75), isSelected: _selectedFoodcourt == 'lama'),
        const SizedBox(width: 8),
        _filterChip('FC Baru', 'baru', bgColor: const Color(0xFFFF7F50), isSelected: _selectedFoodcourt == 'baru'),
      ],
    );
  }

  Widget _filterChip(String label, String value, {Color? bgColor, required bool isSelected}) {
    return ChoiceChip(
      label: Text(label, style: const TextStyle(color: Colors.white)),
      selected: isSelected,
      backgroundColor: bgColor ?? Colors.grey[700],
      selectedColor: const Color(0xFF1D9E75),
      onSelected: (_) {
        setState(() {
          _selectedFoodcourt = value;
          // Reset kantin filter when foodcourt changes
          _selectedKantinId = null;
        });
      },
    );
  }

  Widget _buildKantinFilter(PromoService promoService) {
    // Load kantin names from Firestore (simple approach: fetch distinct kantinIds from promos)
    return FutureBuilder<List<String>>(
      future: promoService.getDistinctKantinIds(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final kantinIds = snapshot.data!;
        return SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (context, index) {
              final kantinId = kantinIds[index];
              final isSelected = _selectedKantinId == kantinId;
              return ChoiceChip(
                label: Text(kantinId, style: const TextStyle(color: Colors.white)),
                selected: isSelected,
                backgroundColor: Colors.grey[800],
                selectedColor: const Color(0xFF1D9E75),
                onSelected: (_) {
                  setState(() {
                    _selectedKantinId = isSelected ? null : kantinId;
                  });
                },
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemCount: kantinIds.length,
          ),
        );
      },
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_offer, size: 80, color: Colors.grey.shade500),
          const SizedBox(height: 16),
          const Text('Belum ada promo aktif', style: TextStyle(color: Colors.white70, fontSize: 18)),
        ],
      ),
    );
  }
}
// Note: PromoDetailPage is defined in promo_detail_page.dart
