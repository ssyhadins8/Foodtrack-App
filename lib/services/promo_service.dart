import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodtrack/models/promo_model.dart';

class PromoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Stream of promos for a specific kantin.
  Stream<List<PromoModel>> getPromosForKantin(String kantinId) {
    return _db
        .collection('promos')
        .where('kantinId', isEqualTo: kantinId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => PromoModel.fromJson(doc.id, doc.data()))
            .toList());
  }

  /// Stream of all active promos (active == true and endDate after now).
  Stream<List<PromoModel>> getAllActivePromos() {
    return _db
        .collection('promos')
        .where('active', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => PromoModel.fromJson(doc.id, doc.data()))
            .where((p) => p.endDate.toDate().isAfter(DateTime.now()))
            .toList());
  }

  /// Get distinct kantinIds from promos collection.
  Future<List<String>> getDistinctKantinIds() async {
    final snap = await _db.collection('promos').get();
    final ids = <String>{};
    for (var doc in snap.docs) {
      final data = doc.data();
      final id = data['kantinId'] as String?;
      if (id != null) ids.add(id);
    }
    return ids.toList();
  }

  /// Toggle active flag of a promo.
  Future<void> togglePromoActive(String kantinId, String promoId, bool active) async {
    final ref = _db.collection('promos').doc(promoId);
    await ref.update({'active': active});
  }

  /// Create a new promo.
  Future<void> createPromo(String kantinId, PromoModel promo) async {
    final data = promo.toJson();
    // Ensure kantinId matches param
    data['kantinId'] = kantinId;
    await _db.collection('promos').add(data);
  }

  /// Update an existing promo.
  Future<void> updatePromo(String kantinId, PromoModel promo) async {
    final ref = _db.collection('promos').doc(promo.id);
    final data = promo.toJson();
    data['kantinId'] = kantinId;
    await ref.set(data, SetOptions(merge: true));
  }
}
