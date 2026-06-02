import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodtrack/models/voucher_model.dart';

class VoucherService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream user's vouchers
  static Stream<List<VoucherModel>> getUserVouchers(String userId) {
    return _db
        .collection('vouchers')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => VoucherModel.fromJson(doc.id, doc.data())).toList());
  }

  // Mark voucher as used
  static Future<void> markVoucherUsed(String voucherId) async {
    await _db.collection('vouchers').doc(voucherId).update({
      'used': true,
      'usedAt': FieldValue.serverTimestamp(),
    });
  }

  // Validate a voucher code
  static Future<VoucherModel> validateVoucher({
    required String code,
    required String userId,
    required double totalHarga,
    String? kantinId,
  }) async {
    final query = await _db
        .collection('vouchers')
        .where('code', isEqualTo: code.trim())
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw 'Kode voucher tidak ditemukan';
    }

    final doc = query.docs.first;
    final voucher = VoucherModel.fromJson(doc.id, doc.data());

    if (!voucher.active) {
      throw 'Voucher tidak aktif';
    }
    if (voucher.used) {
      throw 'Voucher sudah pernah digunakan';
    }
    if (voucher.isExpired) {
      throw 'Voucher sudah kadaluarsa';
    }
    if (voucher.userId != userId) {
      throw 'Voucher ini bukan milik Anda';
    }
    if (voucher.kantinId != null && voucher.kantinId != kantinId) {
      throw 'Voucher hanya berlaku untuk kantin ${voucher.kantinName ?? "tertentu"}';
    }
    if (totalHarga < voucher.minPurchase) {
      throw 'Minimal pembelian adalah Rp${voucher.minPurchase.toInt()}';
    }

    return voucher;
  }

  // Seed default vouchers for a new or unseeded user
  static Future<void> seedUserVouchers(String userId) async {
    final snap = await _db
        .collection('vouchers')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
        
    if (snap.docs.isNotEmpty) {
      return; // already seeded
    }

    final batch = _db.batch();
    
    // Seed 9 diverse vouchers
    final vouchersData = [
      {
        'code': 'DISKON5K',
        'discountType': 'fixed',
        'discountValue': 5000.0,
        'minPurchase': 15000.0,
        'maxDiscount': 5000.0,
        'expiryDays': 30,
      },
      {
        'code': 'DISKON10K',
        'discountType': 'fixed',
        'discountValue': 10000.0,
        'minPurchase': 30000.0,
        'maxDiscount': 10000.0,
        'expiryDays': 30,
      },
      {
        'code': 'MAKANHEMAT',
        'discountType': 'percent',
        'discountValue': 15.0,
        'minPurchase': 20000.0,
        'maxDiscount': 8000.0,
        'expiryDays': 15,
      },
      {
        'code': 'KENYANGPOLL',
        'discountType': 'percent',
        'discountValue': 20.0,
        'minPurchase': 40000.0,
        'maxDiscount': 12000.0,
        'expiryDays': 15,
      },
      {
        'code': 'GRATISONGKIR',
        'discountType': 'fixed',
        'discountValue': 2000.0,
        'minPurchase': 10000.0,
        'maxDiscount': 2000.0,
        'expiryDays': 30,
      },
      {
        'code': 'PROMOBUNDA',
        'discountType': 'fixed',
        'discountValue': 6000.0,
        'minPurchase': 15000.0,
        'maxDiscount': 6000.0,
        'expiryDays': 30,
      },
      {
        'code': 'BANYAKDISKON',
        'discountType': 'percent',
        'discountValue': 25.0,
        'minPurchase': 50000.0,
        'maxDiscount': 15000.0,
        'expiryDays': 15,
      },
      {
        'code': 'KANTINSARI',
        'discountType': 'fixed',
        'discountValue': 5000.0,
        'minPurchase': 15000.0,
        'maxDiscount': 5000.0,
        'expiryDays': 30,
        'kantinId': 'kantin_1',
        'kantinName': 'Kantin Bu Sari',
      },
      {
        'code': 'GEPREKHEMAT',
        'discountType': 'fixed',
        'discountValue': 3000.0,
        'minPurchase': 12000.0,
        'maxDiscount': 3000.0,
        'expiryDays': 30,
        'kantinId': 'kantin_3',
        'kantinName': 'Kantin Geprek',
      },
    ];

    for (var data in vouchersData) {
      final docRef = _db.collection('vouchers').doc();
      final expiryDays = data['expiryDays'] as int;
      final expiryDate = DateTime.now().add(Duration(days: expiryDays));
      
      batch.set(docRef, {
        'code': data['code'],
        'userId': userId,
        'discountType': data['discountType'],
        'discountValue': data['discountValue'],
        'minPurchase': data['minPurchase'],
        'maxDiscount': data['maxDiscount'],
        'expiry': Timestamp.fromDate(expiryDate),
        'used': false,
        'active': true,
        'kantinId': data['kantinId'],
        'kantinName': data['kantinName'],
      });
    }

    await batch.commit();
  }
}
