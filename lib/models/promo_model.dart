import 'package:cloud_firestore/cloud_firestore.dart';

class PromoModel {
  final String id;
  final String kantinId;
  final String kantinName;
  final String foodcourtId;
  final String foodcourtLabel;
  final String title;
  final String description;
  final String imageUrl;
  final String terms;
  final Timestamp startDate;
  final Timestamp endDate;
  final String discountType; // "percent" or "fixed"
  final double discountValue;
  final double minPurchase;
  final double maxDiscount;
  final bool active;
  final bool isRecurring;
  final int recurringDay; // 0=Sun .. 6=Sat
  final String scope; // "single" or "all"

  PromoModel({
    required this.id,
    required this.kantinId,
    required this.kantinName,
    required this.foodcourtId,
    required this.foodcourtLabel,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.terms,
    required this.startDate,
    required this.endDate,
    required this.discountType,
    required this.discountValue,
    required this.minPurchase,
    required this.maxDiscount,
    required this.active,
    required this.isRecurring,
    required this.recurringDay,
    required this.scope,
  });

  // ---------- Getters ----------
  bool get isActive {
    final now = DateTime.now();
    return active &&
        startDate.toDate().isBefore(now) &&
        endDate.toDate().isAfter(now);
  }

  String get discountLabel {
    if (discountType == 'percent') {
      return '${discountValue.toStringAsFixed(0)}%';
    } else {
      return 'Rp${discountValue.toStringAsFixed(0)}';
    }
  }

  // ---------- Serialization ----------
  factory PromoModel.fromJson(String id, Map<String, dynamic> json) {
    return PromoModel(
      id: id,
      kantinId: json['kantinId'] as String,
      kantinName: json['kantinName'] as String? ?? '',
      foodcourtId: json['foodcourtId'] as String,
      foodcourtLabel: json['foodcourtLabel'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      terms: json['terms'] as String,
      startDate: json['startDate'] as Timestamp,
      endDate: json['endDate'] as Timestamp,
      discountType: json['discountType'] as String,
      discountValue: (json['discountValue'] as num).toDouble(),
      minPurchase: (json['minPurchase'] as num).toDouble(),
      maxDiscount: (json['maxDiscount'] as num).toDouble(),
      active: json['active'] as bool,
      isRecurring: json['isRecurring'] as bool,
      recurringDay: json['recurringDay'] as int,
      scope: json['scope'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kantinId': kantinId,
      'kantinName': kantinName,
      'foodcourtId': foodcourtId,
      'foodcourtLabel': foodcourtLabel,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'terms': terms,
      'startDate': startDate,
      'endDate': endDate,
      'discountType': discountType,
      'discountValue': discountValue,
      'minPurchase': minPurchase,
      'maxDiscount': maxDiscount,
      'active': active,
      'isRecurring': isRecurring,
      'recurringDay': recurringDay,
      'scope': scope,
    };
  }

  PromoModel copyWith({
    String? id,
    String? kantinId,
    String? kantinName,
    String? foodcourtId,
    String? foodcourtLabel,
    String? title,
    String? description,
    String? imageUrl,
    String? terms,
    Timestamp? startDate,
    Timestamp? endDate,
    String? discountType,
    double? discountValue,
    double? minPurchase,
    double? maxDiscount,
    bool? active,
    bool? isRecurring,
    int? recurringDay,
    String? scope,
  }) {
    return PromoModel(
      id: id ?? this.id,
      kantinId: kantinId ?? this.kantinId,
      kantinName: kantinName ?? this.kantinName,
      foodcourtId: foodcourtId ?? this.foodcourtId,
      foodcourtLabel: foodcourtLabel ?? this.foodcourtLabel,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      terms: terms ?? this.terms,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minPurchase: minPurchase ?? this.minPurchase,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      active: active ?? this.active,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringDay: recurringDay ?? this.recurringDay,
      scope: scope ?? this.scope,
    );
  }
}
