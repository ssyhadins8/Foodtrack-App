import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodtrack/cart_provider.dart';
import 'package:foodtrack/theme/app_colors.dart';
import 'package:foodtrack/theme/premium_background.dart';
import 'package:foodtrack/models/voucher_model.dart';
import 'package:foodtrack/services/voucher_service.dart';
import 'package:foodtrack/services/queue_service.dart';
import 'package:foodtrack/services/loyalty_service.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _catatanCtrl = TextEditingController();
  String _metodePembayaran = 'Cash';
  bool _isLoading = false;

  VoucherModel? _appliedVoucher;
  final _voucherCodeCtrl = TextEditingController();
  bool _isValidatingVoucher = false;

  @override
  void dispose() {
    _catatanCtrl.dispose();
    _voucherCodeCtrl.dispose();
    super.dispose();
  }

  String _fmt(int h) =>
      'Rp${h.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    
    // Fallback if cart is empty (e.g. after order is placed)
    if (cart.items.isEmpty && !_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(gradient: AppColors.headerGradient),
          ),
          elevation: 0,
          title: const Text('Checkout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.textHint),
              const SizedBox(height: 16),
              const Text('Keranjang Anda kosong', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                child: const Text('Kembali ke Menu', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final kantin = cart.items.isNotEmpty ? cart.items.first.kantin : 'Kantin';
    const int biayaLayanan = 1000;
    int discount = 0;
    if (_appliedVoucher != null) {
      if (_appliedVoucher!.discountType == 'percent') {
        discount = ((cart.totalHarga * _appliedVoucher!.discountValue) / 100).toInt();
        if (_appliedVoucher!.maxDiscount > 0 && discount > _appliedVoucher!.maxDiscount) {
          discount = _appliedVoucher!.maxDiscount.toInt();
        }
      } else {
        discount = _appliedVoucher!.discountValue.toInt();
      }
      if (discount > cart.totalHarga) {
        discount = cart.totalHarga;
      }
    }
    final int totalBayar = cart.totalHarga + biayaLayanan - discount;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        ),
        elevation: 0,
        title: const Text(
          'Konfirmasi Checkout',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: PremiumBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. METODE PENGAMBILAN BANNER
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.12),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ]
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.storefront_rounded, color: AppColors.cyan, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Metode: Ambil Sendiri (Self-Pickup)',
                            style: TextStyle(
                              color: AppColors.cyan,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            kantin,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Silakan ambil pesanan di stan kantin di atas setelah status berubah menjadi "Siap Diambil". Tidak ada pengantaran/kurir.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. CATATAN UNTUK PENJUAL (ORDER NOTES)
              const Text(
                'Catatan Tambahan',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Form(
                key: _formKey,
                child: Container(
                  decoration: AppColors.premiumCardDeco(
                    borderRadius: 16,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                  child: TextFormField(
                    controller: _catatanCtrl,
                    maxLines: 2,
                    validator: (value) {
                      if (value != null && value.trim().length > 100) {
                        return 'Catatan tidak boleh melebihi 100 karakter';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Tulis instruksi khusus (contoh: "Kuah dipisah", "Tidak pedas", "Sedikit nasi")',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      prefixIcon: const Icon(Icons.note_alt_outlined, color: AppColors.secondary),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.cyan, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 3. METODE PEMBAYARAN SELECTOR
              const Text(
                'Metode Pembayaran',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _PaymentChip(
                    label: 'Bayar Cash / Tunai',
                    icon: Icons.payments_rounded,
                    active: _metodePembayaran == 'Cash',
                    onTap: () => setState(() => _metodePembayaran = 'Cash'),
                  ),
                  const SizedBox(width: 12),
                  _PaymentChip(
                    label: 'QRIS Dinamis',
                    icon: Icons.qr_code_scanner_rounded,
                    active: _metodePembayaran == 'QRIS',
                    onTap: () => setState(() => _metodePembayaran = 'QRIS'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 4. RINGKASAN PESANAN
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppColors.premiumCardDeco(borderRadius: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Ringkasan Pesanan (${cart.totalItem} Item)',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cart.items.length,
                      itemBuilder: (context, idx) {
                        final item = cart.items[idx];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.cyanLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${item.qty}x',
                                    style: const TextStyle(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.nama,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                _fmt(item.harga * item.qty),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildVoucherSection(context, cart),
              const SizedBox(height: 20),

              // 5. RINCIAN PEMBAYARAN
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppColors.premiumCardDeco(borderRadius: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rincian Pembayaran',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal Makanan', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        Text(_fmt(cart.totalHarga), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Biaya Layanan Aplikasi', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        Text(_fmt(biayaLayanan), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                      ],
                    ),
                    if (_appliedVoucher != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Diskon Voucher', style: TextStyle(color: AppColors.success, fontSize: 13, fontWeight: FontWeight.bold)),
                          Text('-${_fmt(discount)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.success)),
                        ],
                      ),
                    ],
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.textPrimary)),
                        Text(
                          _fmt(totalBayar),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100), // Spacing for bottom button
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: AppColors.premiumCardDeco(borderRadius: 0, showBorder: false).copyWith(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: AppColors.primary.withOpacity(0.3),
            ),
            onPressed: _isLoading ? null : _prosesPembayaran,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Konfirmasi & Bayar (${_fmt(totalBayar)})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _prosesPembayaran() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Jika metode QRIS, tampilkan dialog simulasi QRIS terlebih dahulu
    if (_metodePembayaran == 'QRIS') {
      final cart = context.read<CartProvider>();
      const int biayaLayanan = 1000;
      int discount = 0;
      if (_appliedVoucher != null) {
        if (_appliedVoucher!.discountType == 'percent') {
          discount = ((cart.totalHarga * _appliedVoucher!.discountValue) / 100).toInt();
          if (_appliedVoucher!.maxDiscount > 0 && discount > _appliedVoucher!.maxDiscount) {
            discount = _appliedVoucher!.maxDiscount.toInt();
          }
        } else {
          discount = _appliedVoucher!.discountValue.toInt();
        }
        if (discount > cart.totalHarga) {
          discount = cart.totalHarga;
        }
      }
      final int totalBayarWithDiscount = cart.totalHarga + biayaLayanan - discount;
      
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _QrisSimulationDialog(
          totalBayar: totalBayarWithDiscount,
          formatHarga: _fmt,
        ),
      );

      if (confirmed != true || !mounted) return;
    }

    setState(() => _isLoading = true);

    try {
      final cart = context.read<CartProvider>();
      final result = await cart.pesan(_metodePembayaran, catatan: _catatanCtrl.text.trim());

      // Mark voucher as used if applied
      if (_appliedVoucher != null) {
        await VoucherService.markVoucherUsed(_appliedVoucher!.id);
      }

      // Dynamic wait time recalculated
      await QueueService.onOrderPlaced();

      // Add loyalty points
      await LoyaltyService.addPoints();
      
      if (!mounted) return;

      // Show beautiful Custom Success Dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 56,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _metodePembayaran == 'QRIS'
                      ? 'Pembayaran QRIS Berhasil!'
                      : 'Pesanan Terkirim!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pesanan Anda sedang dipersiapkan. Nomor antrian Anda adalah:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cyanLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '${result['noAntrian']}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx); // Close dialog
                      Navigator.pushReplacementNamed(
                        context,
                        '/status_pesanan',
                        arguments: result['docId'],
                      );
                    },
                    child: const Text(
                      'Pantau Status Pesanan',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildVoucherSection(BuildContext context, CartProvider cart) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppColors.premiumCardDeco(borderRadius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.confirmation_num_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Voucher Belanja',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
              ),
              const Spacer(),
              if (_appliedVoucher != null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _appliedVoucher = null;
                      _voucherCodeCtrl.clear();
                    });
                  },
                  child: const Text('Hapus', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
            ],
          ),
          const Divider(height: 24),
          if (_appliedVoucher == null) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.primary, width: 1.2),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.list_alt_rounded, size: 18),
                    label: const Text('Pilih Voucher Saya', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: () => _showVoucherBottomSheet(context, uid, cart),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _voucherCodeCtrl,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'Masukkan kode voucher manual',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _isValidatingVoucher
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onPressed: () => _applyManualVoucher(uid, cart),
                        child: const Text('Terapkan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withOpacity(0.3), width: 1.2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _appliedVoucher!.code,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Diskon ${_appliedVoucher!.discountLabel} berhasil digunakan',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _applyManualVoucher(String uid, CartProvider cart) async {
    final code = _voucherCodeCtrl.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan masukkan kode voucher'), backgroundColor: AppColors.danger),
      );
      return;
    }

    setState(() => _isValidatingVoucher = true);

    try {
      final voucher = await VoucherService.validateVoucher(
        code: code,
        userId: uid,
        totalHarga: cart.totalHarga.toDouble(),
      );

      setState(() {
        _appliedVoucher = voucher;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voucher "${voucher.code}" berhasil diterapkan!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isValidatingVoucher = false);
    }
  }

  void _showVoucherBottomSheet(BuildContext context, String uid, CartProvider cart) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Voucher Anda',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<List<VoucherModel>>(
                  stream: VoucherService.getUserVouchers(uid),
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return Center(child: Text('Gagal memuat voucher: ${snap.error}'));
                    }
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    }

                    final activeVouchers = snap.data!
                        .where((v) => v.status == 'active' && cart.totalHarga >= v.minPurchase)
                        .toList();

                    if (activeVouchers.isEmpty) {
                      return const Center(
                        child: Text(
                          'Tidak ada voucher aktif yang memenuhi syarat minimum belanja',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: activeVouchers.length,
                      itemBuilder: (context, index) {
                        final v = activeVouchers[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: const Icon(Icons.confirmation_num_rounded, color: AppColors.primary, size: 28),
                            title: Text(
                              v.code,
                              style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text('Diskon: ${v.discountLabel} • Min. Belanja Rp${v.minPurchase.toInt()}'),
                            onTap: () {
                              setState(() {
                                _appliedVoucher = v;
                              });
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Voucher "${v.code}" berhasil diterapkan!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// DIALOG SIMULASI QRIS - Menampilkan QR Code simulasi dengan total pembayaran
// ============================================================================
class _QrisSimulationDialog extends StatefulWidget {
  final int totalBayar;
  final String Function(int) formatHarga;

  const _QrisSimulationDialog({
    required this.totalBayar,
    required this.formatHarga,
  });

  @override
  State<_QrisSimulationDialog> createState() => _QrisSimulationDialogState();
}

class _QrisSimulationDialogState extends State<_QrisSimulationDialog>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _countdown = 300; // 5 menit dalam detik
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _startCountdown();
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _countdown--);
      return _countdown > 0 && mounted;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String get _countdownText {
    final m = (_countdown ~/ 60).toString().padLeft(2, '0');
    final s = (_countdown % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D1B2A), Color(0xFF1B3A5C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.qr_code_scanner_rounded,
                      color: Colors.white, size: 36),
                  const SizedBox(height: 8),
                  const Text(
                    'Pembayaran QRIS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Simulasi Payment Gateway',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                children: [
                  // Total Pembayaran
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cyanLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.cyan.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Total Pembayaran',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.formatHarga(widget.totalBayar),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // QR Code Area (Simulasi)
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 200,
                      height: 200,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: CustomPaint(
                        painter: _QrCodePainter(),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.restaurant_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Countdown Timer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timer_outlined,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        'Berlaku selama $_countdownText',
                        style: TextStyle(
                          fontSize: 13,
                          color: _countdown < 60
                              ? AppColors.danger
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Instruksi
                  Text(
                    'Scan kode QR di atas menggunakan\naplikasi e-Wallet atau Mobile Banking Anda',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Daftar e-Wallet
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _eWalletChip('GoPay'),
                      const SizedBox(width: 8),
                      _eWalletChip('OVO'),
                      const SizedBox(width: 8),
                      _eWalletChip('DANA'),
                      const SizedBox(width: 8),
                      _eWalletChip('ShopeePay'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Tombol Konfirmasi
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: _isProcessing
                          ? null
                          : () {
                              setState(() => _isProcessing = true);
                              // Simulasi delay verifikasi pembayaran
                              Future.delayed(const Duration(milliseconds: 800),
                                  () {
                                if (mounted) Navigator.pop(context, true);
                              });
                            },
                      child: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline_rounded,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Saya Sudah Bayar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Tombol Batal
                  TextButton(
                    onPressed:
                        _isProcessing ? null : () => Navigator.pop(context, false),
                    child: Text(
                      'Batalkan Pembayaran',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _eWalletChip(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        name,
        style: TextStyle(fontSize: 10, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ============================================================================
// Custom Painter - Menggambar pola QR Code simulasi (tanpa library tambahan)
// ============================================================================
class _QrCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF0D1B2A);
    final cellSize = size.width / 21;

    // Pola QR Code sederhana (simulasi visual)
    final pattern = [
      [1,1,1,1,1,1,1,0,1,0,1,0,1,0,1,1,1,1,1,1,1],
      [1,0,0,0,0,0,1,0,0,1,0,1,0,0,1,0,0,0,0,0,1],
      [1,0,1,1,1,0,1,0,1,0,1,0,1,0,1,0,1,1,1,0,1],
      [1,0,1,1,1,0,1,0,0,1,1,1,0,0,1,0,1,1,1,0,1],
      [1,0,1,1,1,0,1,0,1,0,0,0,1,0,1,0,1,1,1,0,1],
      [1,0,0,0,0,0,1,0,0,1,0,1,0,0,1,0,0,0,0,0,1],
      [1,1,1,1,1,1,1,0,1,0,1,0,1,0,1,1,1,1,1,1,1],
      [0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0],
      [1,0,1,0,1,0,1,0,1,1,0,1,0,1,1,0,1,0,1,0,1],
      [0,1,0,1,0,1,0,1,0,0,1,0,1,0,0,1,0,1,0,1,0],
      [1,0,1,1,0,0,1,0,1,0,0,0,1,0,1,0,1,1,0,0,1],
      [0,1,0,0,1,1,0,1,0,1,1,1,0,1,0,1,0,0,1,1,0],
      [1,0,1,0,1,0,1,0,0,0,1,0,0,0,1,0,1,0,1,0,1],
      [0,0,0,0,0,0,0,0,1,0,0,1,0,1,0,0,0,0,0,0,0],
      [1,1,1,1,1,1,1,0,0,1,1,0,1,0,1,1,1,0,1,0,1],
      [1,0,0,0,0,0,1,0,1,0,0,1,0,0,0,1,0,1,0,1,0],
      [1,0,1,1,1,0,1,0,0,1,0,0,1,1,1,0,1,1,0,0,1],
      [1,0,1,1,1,0,1,0,1,0,1,1,0,0,0,1,0,0,1,1,0],
      [1,0,1,1,1,0,1,0,0,0,0,0,1,0,1,0,1,0,1,0,1],
      [1,0,0,0,0,0,1,0,1,1,0,1,0,1,0,0,0,1,0,1,0],
      [1,1,1,1,1,1,1,0,0,0,1,0,1,0,1,1,1,0,0,0,1],
    ];

    // Beri jarak dari tepi
    final offsetX = (size.width - cellSize * 21) / 2;
    final offsetY = (size.height - cellSize * 21) / 2;

    for (int row = 0; row < 21; row++) {
      for (int col = 0; col < 21; col++) {
        if (pattern[row][col] == 1) {
          // Skip tengah untuk logo
          final centerDist = ((row - 10).abs() + (col - 10).abs());
          if (centerDist < 4) continue;

          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                offsetX + col * cellSize,
                offsetY + row * cellSize,
                cellSize * 0.9,
                cellSize * 0.9,
              ),
              Radius.circular(cellSize * 0.15),
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PaymentChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _PaymentChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: AppColors.premiumCardDeco(
            borderRadius: 16,
            color: active
                ? AppColors.cyanLight.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.5),
          ).copyWith(
            border: Border.all(
              color: active
                  ? AppColors.cyan.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.4),
              width: active ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: active ? AppColors.secondary : Colors.grey.shade600,
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: active ? AppColors.secondary : AppColors.textPrimary,
                  fontWeight: active ? FontWeight.bold : FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
