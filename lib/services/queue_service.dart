import 'package:cloud_firestore/cloud_firestore.dart';

class QueueService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> onOrderPlaced() async {
    // Mock method for dynamic wait time queue estimation
    print("QueueService.onOrderPlaced: order placed, queue recalculated.");
  }

  static Stream<Map<String, dynamic>> getQueueStatus(String kantinId) {
    // We listen to active orders (statusIndex < 3) in the 'pesanan' collection
    return _db
        .collection('pesanan')
        .where('statusIndex', isLessThan: 3)
        .snapshots()
        .map((snapshot) {
          // Filter orders for this specific kantin (checking either kantinId or using id)
          final activeCount = snapshot.docs.where((doc) {
            final data = doc.data();
            return data['kantinId'] == kantinId || data['kantin'] == kantinId;
          }).length;

          String crowdLevel = 'sepi';
          if (activeCount >= 7) {
            crowdLevel = 'penuh';
          } else if (activeCount >= 3) {
            crowdLevel = 'ramai';
          }

          return {
            'activeCount': activeCount,
            'crowdLevel': crowdLevel,
          };
        });
  }

  static Future<void> onOrderCompleted(String? kantinId) async {
    print("QueueService.onOrderCompleted: order completed/rejected for $kantinId, queue recalculated.");
  }
}
