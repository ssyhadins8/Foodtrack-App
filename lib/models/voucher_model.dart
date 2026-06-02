import 'package:cloud_firestore/cloud_firestore.dart';

class VoucherModel {
  final String id;
  final String code;
  final String userId;
  final String? kantinId;
  final String? kantinName;
  final String? foodcourtId;
  final String discountType; // "percent" or "fixed"
  final double discountValue;
  final double minPurchase;
  final double maxDiscount;
  final Timestamp expiry;
  final bool used;
  final Timestamp? usedAt;
  final bool active; // indicates if voucher is active/enabled

  VoucherModel({
    required this.id,
    required this.code,
    required this.userId,
    this.kantinId,
    this.kantinName,
    this.foodcourtId,
    required this.discountType,
    required this.discountValue,
    required this.minPurchase,
    required this.maxDiscount,
    required this.expiry,
    required this.used,
    this.usedAt,
    required this.active,
  });

  // ---------- Getters ----------
  bool get isExpired => expiry.toDate().isBefore(DateTime.now());

  String get status {
    if (used) return 'used';
    if (isExpired) return 'expired';
    return 'active';
  }

  String get discountLabel {
    if (discountType == 'percent') {
      return '${discountValue.toStringAsFixed(0)}%';
    } else {
      return 'Rp${discountValue.toStringAsFixed(0)}';
    }
  }

  // ---------- Serialization ----------
  factory VoucherModel.fromJson(String id, Map<String, dynamic> json) {
    return VoucherModel(
      id: id,
      code: json['code'] as String,
      userId: json['userId'] as String,
      kantinId: json['kantinId'] as String?,
      kantinName: json['kantinName'] as String?,
      foodcourtId: json['foodcourtId'] as String?,
      discountType: json['discountType'] as String,
      discountValue: (json['discountValue'] as num).toDouble(),
      minPurchase: (json['minPurchase'] as num).toDouble(),
      maxDiscount: (json['maxDiscount'] as num).toDouble(),
      expiry: json['expiry'] as Timestamp,
      used: json['used'] as bool,
      usedAt: json['usedAt'] as Timestamp?,
      active: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'userId': userId,
      'kantinId': kantinId,
      'kantinName': kantinName,
      'foodcourtId': foodcourtId,
      'discountType': discountType,
      'discountValue': discountValue,
      'minPurchase': minPurchase,
      'maxDiscount': maxDiscount,
      'expiry': expiry,
      'used': used,
      'usedAt': usedAt,
      'active': active,
    };
  }

  VoucherModel copyWith({
    String? id,
    String? code,
    String? userId,
    String? kantinId,
    String? kantinName,
    String? foodcourtId,
    String? discountType,
    double? discountValue,
    double? minPurchase,
    double? maxDiscount,
    Timestamp? expiry,
    bool? used,
    Timestamp? usedAt,
    bool? active,
  }) {
    return VoucherModel(
      id: id ?? this.id,
      code: code ?? this.code,
      userId: userId ?? this.userId,
      kantinId: kantinId ?? this.kantinId,
      kantinName: kantinName ?? this.kantinName,
      foodcourtId: foodcourtId ?? this.foodcourtId,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minPurchase: minPurchase ?? this.minPurchase,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      expiry: expiry ?? this.expiry,
      used: used ?? this.used,
      usedAt: usedAt ?? this.usedAt,
      active: active ?? this.active,
    );
  }
}
