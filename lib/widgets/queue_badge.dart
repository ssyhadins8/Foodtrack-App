import 'package:flutter/material.dart';
import 'package:foodtrack/services/queue_service.dart';

class QueueBadge extends StatelessWidget {
  final String kantinId;

  const QueueBadge({Key? key, required this.kantinId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: QueueService.getQueueStatus(kantinId),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();

        final crowdLevel = snap.data!['crowdLevel'] as String;

        Color bgColor;
        Color textColor;
        String label;
        IconData icon;

        switch (crowdLevel) {
          case 'penuh':
            bgColor = const Color(0xFFFFE0E0);
            textColor = const Color(0xFFB71C1C);
            label = 'Penuh';
            icon = Icons.people_rounded;
            break;
          case 'ramai':
            bgColor = const Color(0xFFFFF3E0);
            textColor = const Color(0xFFE65100);
            label = 'Ramai';
            icon = Icons.people_outline_rounded;
            break;
          default:
            bgColor = const Color(0xFFE8F5E9);
            textColor = const Color(0xFF2E7D32);
            label = 'Sepi';
            icon = Icons.person_rounded;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: bgColor.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 10, color: textColor),
              const SizedBox(width: 3),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
