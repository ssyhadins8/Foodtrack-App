import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodtrack/models/voucher_model.dart';
import 'package:foodtrack/services/firestore_service.dart';
import 'package:intl/intl.dart';

class AdminVouchersPage extends StatefulWidget {
  const AdminVouchersPage({Key? key}) : super(key: key);

  @override
  State<AdminVouchersPage> createState() => _AdminVouchersPageState();
}

class _AdminVouchersPageState extends State<AdminVouchersPage> {
  // Form fields
  bool _allUsers = true;
  bool _allCanteens = true;
  String? _selectedUserId;
  String? _selectedKantinId;
  String _discountType = 'percent'; // 'percent' or 'fixed'
  final TextEditingController _discountValueController = TextEditingController();
  final TextEditingController _minPurchaseController = TextEditingController();
  final TextEditingController _maxDiscountController = TextEditingController();
  DateTime? _expiryDate;

  @override
  void dispose() {
    _discountValueController.dispose();
    _minPurchaseController.dispose();
    _maxDiscountController.dispose();
    super.dispose();
  }

  void _showGenerateVoucherSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Buat Voucher Baru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                // Target User
                Row(
                  children: [
                    const Text('Target User:'),
                    Switch(value: _allUsers, onChanged: (v) => setState(() => _allUsers = v)),
                    const Text('Semua Pengguna'),
                  ],
                ),
                if (!_allUsers)
                  StreamBuilder<QuerySnapshot>(
                    stream: FirestoreService.streamSemuaUser(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const CircularProgressIndicator();
                      final users = snapshot.data!.docs.where((d) => d.get('role') == 'pembeli').toList();
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Pilih Pengguna'),
                        items: users
                            .map((doc) => DropdownMenuItem(
                                  value: doc.id,
                                  child: Text(doc.get('nama') ?? 'User'),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedUserId = v),
                      );
                    },
                  ),
                const SizedBox(height: 12),
                // Target Canteen
                Row(
                  children: [
                    const Text('Target Kantin:'),
                    Switch(value: _allCanteens, onChanged: (v) => setState(() => _allCanteens = v)),
                    const Text('Semua Kantin'),
                  ],
                ),
                if (!_allCanteens)
                  StreamBuilder<QuerySnapshot>(
                    stream: FirestoreService.streamKantin(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const CircularProgressIndicator();
                      final kantins = snapshot.data!.docs;
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Pilih Kantin'),
                        items: kantins
                            .map((doc) => DropdownMenuItem(
                                  value: doc.id,
                                  child: Text(doc.get('nama') ?? 'Kantin'),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedKantinId = v),
                      );
                    },
                  ),
                const SizedBox(height: 12),
                // Discount Type
                ToggleButtons(
                  isSelected: [_discountType == 'percent', _discountType == 'fixed'],
                  onPressed: (index) {
                    setState(() {
                      _discountType = index == 0 ? 'percent' : 'fixed';
                    });
                  },
                  children: const [
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Persen %')),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Nominal Rp')),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _discountValueController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: _discountType == 'percent' ? 'Diskon (%)' : 'Diskon (Rp)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _minPurchaseController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Min Pembelian (Rp)'),
                ),
                const SizedBox(height: 12),
                if (_discountType == 'percent')
                  TextFormField(
                    controller: _maxDiscountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Max Diskon (Rp)'),
                  ),
                const SizedBox(height: 12),
                // Expiry Date
                Row(
                  children: [
                    const Text('Tanggal Kadaluarsa:'),
                    TextButton(
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: now.add(const Duration(days: 1)),
                          firstDate: now,
                          lastDate: now.add(const Duration(days: 365 * 5)),
                        );
                        if (picked != null) setState(() => _expiryDate = picked);
                      },
                      child: Text(_expiryDate == null ? 'Pilih tanggal' : DateFormat('yyyy-MM-dd').format(_expiryDate!)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _generateVoucher,
                  child: const Text('Buat Voucher'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _generateVoucher() async {
    if (_expiryDate == null) return;
    final discountValue = double.tryParse(_discountValueController.text) ?? 0.0;
    final minPurchase = double.tryParse(_minPurchaseController.text) ?? 0.0;
    final maxDiscount = _discountType == 'percent' ? (double.tryParse(_maxDiscountController.text) ?? 0.0) : 0.0;

    // Helper to create a VoucherModel and store it
    Future<void> createFor({required String userId, String? kantinId, String? kantinName}) async {
      final docRef = FirebaseFirestore.instance.collection('vouchers').doc();
      final voucher = VoucherModel(
        id: docRef.id,
        code: 'V${DateTime.now().millisecondsSinceEpoch}${userId.substring(0, 4)}',
        userId: userId,
        kantinId: kantinId,
        kantinName: kantinName,
        foodcourtId: null,
        discountType: _discountType,
        discountValue: discountValue,
        minPurchase: minPurchase,
        maxDiscount: maxDiscount,
        expiry: Timestamp.fromDate(_expiryDate!),
        used: false,
        usedAt: null,
        active: true,
      );
      await FirestoreService.createVoucher(voucher);
    }

    if (_allUsers) {
      // generate for all pembeli users
      final usersSnap = await FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'pembeli').get();
      for (var userDoc in usersSnap.docs) {
        String? kantinId;
        String? kantinName;
        if (!_allCanteens && _selectedKantinId != null) {
          final kantinDoc = await FirebaseFirestore.instance.collection('kantin').doc(_selectedKantinId).get();
          kantinId = kantinDoc.id;
          kantinName = kantinDoc.get('nama');
        }
        await createFor(userId: userDoc.id, kantinId: kantinId, kantinName: kantinName);
      }
    } else if (_selectedUserId != null) {
      String? kantinId;
      String? kantinName;
      if (!_allCanteens && _selectedKantinId != null) {
        final kantinDoc = await FirebaseFirestore.instance.collection('kantin').doc(_selectedKantinId).get();
        kantinId = kantinDoc.id;
        kantinName = kantinDoc.get('nama');
      }
      await createFor(userId: _selectedUserId!, kantinId: kantinId, kantinName: kantinName);
    }
    if (mounted) Navigator.of(context).pop();
  }

  Color _statusColor(VoucherModel voucher) {
    if (voucher.used) return Colors.grey;
    if (voucher.isExpired) return Colors.red;
    return Colors.green;
  }

  String _statusText(VoucherModel voucher) {
    if (voucher.used) return 'Terpakai';
    if (voucher.isExpired) return 'Kadaluarsa';
    return 'Aktif';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voucher Admin')),
      body: StreamBuilder<List<VoucherModel>>(
        stream: FirestoreService.streamAllVouchers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final vouchers = snapshot.data!;
          return ListView.separated(
            itemCount: vouchers.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final v = vouchers[index];
              return ListTile(
                title: Text(v.code, style: const TextStyle(fontFamily: 'monospace')),
                subtitle: Text('Diskon: ${v.discountLabel} • Kadaluarsa: ${DateFormat('yyyy-MM-dd').format(v.expiry.toDate())}'),
                trailing: Chip(
                  label: Text(_statusText(v), style: const TextStyle(color: Colors.white)),
                  backgroundColor: _statusColor(v),
                ),
                onTap: () async {
                  await FirestoreService.toggleVoucherActive(v.id);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showGenerateVoucherSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
