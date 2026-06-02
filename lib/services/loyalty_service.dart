import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoyaltyService {
  static Future<void> redeemPoints(String uid, int cost, int voucherValue, String? kantinId) async {
    // Deduct points for voucher redemption and record transaction
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snap = await transaction.get(userRef);
      if (!snap.exists) return;
      final currentPoints = snap.data()?['loyaltyPoints'] as int? ?? 0;
      if (currentPoints < cost) return; // insufficient points guard
      transaction.update(userRef, {'loyaltyPoints': currentPoints - cost});
    });

    // Record the redemption transaction
    await FirebaseFirestore.instance.collection('loyaltyTransactions').add({
      'userId': uid,
      'type': 'Penukaran',
      'points': -cost,
      'voucherValue': voucherValue,
      'kantinId': kantinId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Create the actual voucher in Firestore so it can be used in checkout!
    final docId = FirebaseFirestore.instance.collection('vouchers').doc().id;
    final code = 'VCH-${voucherValue ~/ 1000}K-${docId.substring(0, 4).toUpperCase()}';
    await FirebaseFirestore.instance.collection('vouchers').doc(docId).set({
      'code': code,
      'userId': uid,
      'discountType': 'fixed',
      'discountValue': voucherValue.toDouble(),
      'minPurchase': 0.0,
      'maxDiscount': voucherValue.toDouble(),
      'expiry': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
      'used': false,
      'active': true,
      'kantinId': kantinId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Log the point redemption activity in Notifikasi
    await FirebaseFirestore.instance.collection('notifikasi').add({
      'uid': uid,
      'judul': 'Penukaran Poin Berhasil 🎁',
      'pesan': 'Anda menukarkan $cost poin dengan voucher senilai Rp ${voucherValue.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}.',
      'tipe': 'aktivitas',
      'icon': 'promo',
      'dibaca': false,
      'waktu': FieldValue.serverTimestamp(),
    });

    print('LoyaltyService.redeemPoints: $cost points redeemed for voucher $voucherValue for user $uid');
  }

  static Future<void> addPoints() async {
    // Loyalty program: add 10 points per order
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snap = await transaction.get(userRef);
      if (snap.exists) {
        final currentPoints = snap.data()?['loyaltyPoints'] as int? ?? 0;
        transaction.update(userRef, {'loyaltyPoints': currentPoints + 10});
      }
    });
    print("LoyaltyService.addPoints: 10 loyalty points added for user $uid");
  }
}
