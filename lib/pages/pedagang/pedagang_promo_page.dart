import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodtrack/services/promo_service.dart';
import 'package:foodtrack/models/promo_model.dart';
import 'package:foodtrack/theme/app_colors.dart';

class PedagangPromoPage extends StatefulWidget {
  final String namaKantin;
  final String kantinId;
  const PedagangPromoPage({
    Key? key,
    required this.namaKantin,
    required this.kantinId,
  }) : super(key: key);

  @override
  State<PedagangPromoPage> createState() => _PedagangPromoPageState();
}

class _PedagangPromoPageState extends State<PedagangPromoPage> {
  final _service = PromoService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Promo'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: StreamBuilder<List<PromoModel>>(
        stream: _service.getPromosForKantin(widget.kantinId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.isEmpty) {
            return const Center(child: Text('Belum ada promo'));
          }
          final promos = snap.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: promos.length,
            itemBuilder: (_, i) {
              final p = promos[i];
              final now = DateTime.now();
              final isExpired = p.endDate.toDate().isBefore(now);
              final status = p.active && !isExpired
                  ? 'Aktif'
                  : isExpired
                      ? 'Kadaluarsa'
                      : 'Nonaktif';
              final statusColor = status == 'Aktif'
                  ? Colors.green
                  : status == 'Kadaluarsa'
                      ? Colors.red
                      : Colors.grey;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.discountLabel),
                      Text('${p.startDate.toDate().toLocal().toString().split(' ')[0]} – ${p.endDate.toDate().toLocal().toString().split(' ')[0]}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(status, style: TextStyle(color: statusColor, fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: p.active,
                        onChanged: (val) async {
                          await _service.togglePromoActive(widget.kantinId, p.id, val);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.secondary),
                        onPressed: () => _showForm(promo: p),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Promo'),
        onPressed: () => _showForm(),
      ),
    );
  }

  Widget _dateCard({
    required BuildContext context,
    required String title,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date != null ? '${date.day}/${date.month}/${date.year}' : '-',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.calendar_month_rounded, color: AppColors.secondary, size: 20),
          ],
        ),
      ),
    );
  }

  void _showForm({PromoModel? promo}) {
    final isEdit = promo != null;
    final titleCtrl = TextEditingController(text: promo?.title ?? '');
    final descCtrl = TextEditingController(text: promo?.description ?? '');
    final termsCtrl = TextEditingController(text: promo?.terms ?? '');
    final discountCtrl = TextEditingController(text: isEdit ? promo!.discountValue.toString() : '');
    final minPurchaseCtrl = TextEditingController(text: isEdit ? promo!.minPurchase.toString() : '');
    final maxDiscountCtrl = TextEditingController(text: isEdit ? promo!.maxDiscount.toString() : '');
    String discountType = isEdit ? promo!.discountType : 'percent';
    DateTime? startDate = isEdit ? promo!.startDate.toDate() : null;
    DateTime? endDate = isEdit ? promo!.endDate.toDate() : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.local_offer_rounded, color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isEdit ? 'Edit Promo Kantin' : 'Tambah Promo Baru',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.grey),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _field('Judul Promo *', titleCtrl, icon: Icons.title_rounded),
                      const SizedBox(height: 12),
                      _field('Deskripsi *', descCtrl, maxLines: 2, icon: Icons.description_rounded),
                      const SizedBox(height: 12),
                      _field('Syarat & Ketentuan', termsCtrl, maxLines: 2, icon: Icons.rule_rounded),
                      const SizedBox(height: 16),
                      
                      // Tipe Diskon (Wrap layout to prevent right overflow)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'Tipe Diskon:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              fontSize: 13,
                            ),
                          ),
                          ChoiceChip(
                            label: Text(
                              'Persen %',
                              style: TextStyle(
                                color: discountType == 'percent' ? Colors.white : AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            selected: discountType == 'percent',
                            selectedColor: AppColors.primary,
                            backgroundColor: Colors.grey.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: discountType == 'percent' ? AppColors.primary : Colors.grey.shade300,
                              ),
                            ),
                            onSelected: (_) => setModalState(() => discountType = 'percent'),
                          ),
                          ChoiceChip(
                            label: Text(
                              'Nominal Rp',
                              style: TextStyle(
                                color: discountType == 'fixed' ? Colors.white : AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            selected: discountType == 'fixed',
                            selectedColor: AppColors.primary,
                            backgroundColor: Colors.grey.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: discountType == 'fixed' ? AppColors.primary : Colors.grey.shade300,
                              ),
                            ),
                            onSelected: (_) => setModalState(() => discountType = 'fixed'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _field('Nilai Diskon *', discountCtrl, type: TextInputType.number, icon: Icons.discount_rounded),
                      const SizedBox(height: 16),
                      
                      // Periode Tanggal
                      Row(
                        children: [
                          Expanded(
                            child: _dateCard(
                              context: context,
                              title: 'Mulai *',
                              date: startDate,
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                                  initialDate: startDate ?? DateTime.now(),
                                );
                                if (picked != null) {
                                  setModalState(() => startDate = picked);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _dateCard(
                              context: context,
                              title: 'Berakhir *',
                              date: endDate,
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                                  initialDate: endDate ?? DateTime.now().add(const Duration(days: 30)),
                                );
                                if (picked != null) {
                                  setModalState(() => endDate = picked);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _field('Min Pembelian (Rp)', minPurchaseCtrl, type: TextInputType.number, icon: Icons.shopping_bag_rounded),
                      const SizedBox(height: 12),
                      _field('Maks Diskon (Rp)', maxDiscountCtrl, type: TextInputType.number, icon: Icons.price_check_rounded),
                      const SizedBox(height: 24),
                      
                      // Action Button
                      SizedBox(
                        width: double.infinity,
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
                            if (titleCtrl.text.isEmpty ||
                                descCtrl.text.isEmpty ||
                                discountCtrl.text.isEmpty ||
                                startDate == null ||
                                endDate == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Harap lengkapi semua field bertanda * !'),
                                  backgroundColor: AppColors.danger,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                              return;
                            }
                            final model = PromoModel(
                              id: isEdit ? promo!.id : '',
                              kantinId: widget.kantinId,
                              kantinName: widget.namaKantin,
                              foodcourtId: promo?.foodcourtId ?? '',
                              foodcourtLabel: promo?.foodcourtLabel ?? '',
                              title: titleCtrl.text.trim(),
                              description: descCtrl.text.trim(),
                              imageUrl: promo?.imageUrl ?? '',
                              terms: termsCtrl.text.trim(),
                              startDate: Timestamp.fromDate(startDate!),
                              endDate: Timestamp.fromDate(endDate!),
                              discountType: discountType,
                              discountValue: double.tryParse(discountCtrl.text) ?? 0,
                              minPurchase: double.tryParse(minPurchaseCtrl.text) ?? 0,
                              maxDiscount: double.tryParse(maxDiscountCtrl.text) ?? 0,
                              active: isEdit ? promo!.active : true,
                              isRecurring: false,
                              recurringDay: 0,
                              scope: 'single',
                            );
                            if (isEdit) {
                              await _service.updatePromo(widget.kantinId, model);
                            } else {
                              await _service.createPromo(widget.kantinId, model);
                            }
                            if (!context.mounted) return;
                            Navigator.pop(context); // Close bottom sheet
                            
                            // Success Dialog Popup
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                backgroundColor: const Color(0xFF0F172A),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      isEdit ? 'Promo Diperbarui! ✨' : 'Promo Berhasil Dibuat! 🎉',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      isEdit
                                          ? 'Perubahan pada promo Anda telah berhasil disimpan.'
                                          : 'Promo baru Anda telah aktif dan dapat langsung dinikmati pelanggan.',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
                                    ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Mengerti', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Text(
                            isEdit ? 'Simpan Perubahan' : 'Buat Promo',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _field(String label, TextEditingController ctrl, {int maxLines = 1, TextInputType? type, IconData? icon}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        prefixIcon: icon != null ? Icon(icon, color: AppColors.secondary, size: 20) : null,
        filled: true,
        fillColor: Colors.grey.shade50,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cyan, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
