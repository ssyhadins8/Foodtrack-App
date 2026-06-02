import 'package:flutter/material.dart';

class FoodcourtBadge extends StatelessWidget {
  final String foodcourtId;
  final String foodcourtLabel;

  const FoodcourtBadge({
    Key? key,
    required this.foodcourtId,
    required this.foodcourtLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color dotColor;

    if (foodcourtId == 'lama') {
      dotColor = const Color(0xFF085041);
    } else if (foodcourtId == 'baru') {
      dotColor = const Color(0xFF712B13);
    } else {
      dotColor = Colors.grey.shade700;
    }

    return SizedBox(
      width: 80,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              foodcourtLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: dotColor,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
