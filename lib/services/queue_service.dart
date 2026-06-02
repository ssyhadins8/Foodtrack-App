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
          String expectedName = '';
          switch (kantinId) {
            case 'kantin_1': expectedName = 'Kantin Bu Sari'; break;
            case 'kantin_2': expectedName = 'Kantin Pak Budi'; break;
            case 'kantin_3': expectedName = 'Kantin Geprek'; break;
            case 'kantin_4': expectedName = 'Kantin Bakso Mas Jo'; break;
            case 'kantin_5': expectedName = 'Kantin Minuman Segar'; break;
            case 'kantin_6': expectedName = 'Kantin Seafood Bu Tini'; break;
            case 'kantin_7': expectedName = 'Kantin Snack Corner'; break;
            case 'kantin_8': expectedName = 'Kantin Nasi Padang'; break;
            case 'kantin_9': expectedName = 'Dimsum Station'; break;
            case 'kantin_12': expectedName = 'Pos Ketan Legenda'; break;
            case 'kantin_13': expectedName = 'Bingxue'; break;
            case 'kantin_14': expectedName = "Toby's Chicken"; break;
          }

          final activeCount = snapshot.docs.where((doc) {
            final data = doc.data();
            final dbKantinId = data['kantinId'] as String? ?? '';
            final dbKantinName = data['kantin'] as String? ?? '';
            return dbKantinId == kantinId || 
                   dbKantinName == kantinId || 
                   (expectedName.isNotEmpty && dbKantinName == expectedName);
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
