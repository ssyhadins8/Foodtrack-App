// lib/widgets/promo_card.dart
import 'package:flutter/material.dart';
import '../models/promo_model.dart';

class PromoCard extends StatefulWidget {
  final PromoModel promo;
  final VoidCallback? onTap;
  const PromoCard({Key? key, required this.promo, this.onTap}) : super(key: key);

  @override
  State<PromoCard> createState() => _PromoCardState();
}

class _PromoCardState extends State<PromoCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _countdownText() {
    final now = DateTime.now();
    final diff = widget.promo.endDate.toDate().difference(now);
    if (diff.inDays < 1) return "Hari ini!";
    return "Berakhir dalam ${diff.inDays} hari";
  }

  Color _foodcourtColor() {
    return widget.promo.foodcourtId == 'lama'
        ? const Color(0xFF1D9E75) // teal accent
        : const Color(0xFFFF7F50); // coral for baru
  }

  @override
  Widget build(BuildContext context) {
    final promo = widget.promo;
    return FadeTransition(
      opacity: _fadeAnim,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Card(
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Stack(
            children: [
              // Background image
              Positioned.fill(
                child: Image.network(
                  promo.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black54],
                    ),
                  ),
                ),
              ),
              // Foodcourt badge (top‑left)
              Positioned(
                top: 8,
                left: 8,
                child: Chip(
                  label: Text(
                    promo.foodcourtLabel,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: _foodcourtColor(),
                ),
              ),
              // Countdown badge (top‑right)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _countdownText(),
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ),
              // Bottom info
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        promo.kantinName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        promo.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        promo.discountLabel,
                        style: const TextStyle(
                          color: Colors.yellowAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
