import 'package:cloud_firestore/cloud_firestore.dart';

class MenuService {
  static Future<void> toggleAvailability(String menuId, bool value) async {
    await FirebaseFirestore.instance.collection('menu').doc(menuId).update({
      'tersedia': value,
      'isAvailable': value,
    });
  }
}
