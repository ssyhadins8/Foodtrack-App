import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodtrack/cart_provider.dart';

class KonfirmasiPage extends StatefulWidget {
  final int noAntrian;
  final String kantin;
  final String metode;
  final List<CartItem> items;
  final int totalHarga;

  const KonfirmasiPage({
    super.key,
    required this.noAntrian,
    required this.kantin,
    required this.metode,
    required this.items,
    required this.totalHarga,
  });

  @override
  State<KonfirmasiPage> createState() => _KonfirmasiPageState();
}

class _KonfirmasiPageState extends State<KonfirmasiPage>
    with TickerProviderStateMixin {
  static const int _totalDetik = 1800;
  int _sisaDetik = _totalDetik;
  Timer? _timer;
  int _statusIndex = 0;
  late String _waktuPesan;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _waktuPesan = _formatWaktu(DateTime.now());

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_sisaDetik > 0) {
          _sisaDetik--;
          final elapsed = _totalDetik - _sisaDetik;
          int newStatus = 0;
          if (elapsed >= 1500) {
            newStatus = 3;
          } else if (elapsed >= 900) {
            newStatus = 2;
          } else if (elapsed >= 60) {
            newStatus = 1;
          }

          if (newStatus != _statusIndex) {
            _statusIndex = newStatus;
            Provider.of<CartProvider>(
              context,
              listen: false,
            ).updateStatusPesanan(widget.noAntrian, newStatus);
          }
        } else {
          _statusIndex = 3;
          t.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatWaktu(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}.${dt.minute.toString().padLeft(2, '0')} WIB';

  String _formatCountdown() {
    final menit = _sisaDetik ~/ 60;
    final detik = _sisaDetik % 60;
    return '${menit.toString().padLeft(2, '0')}:${detik.toString().padLeft(2, '0')}';
  }

  String _formatHarga(int harga) =>
      'Rp${harga.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  Color get _timerColor {
    if (_sisaDetik > 900) return const Color(0xFF2E7D52);
    if (_sisaDetik > 300) return const Color(0xFFE87722);
    return Colors.red;
  }

  String get _statusLabel {
    switch (_statusIndex) {
      case 0:
        return 'Pesanan Diterima';
      case 1:
        return 'Sedang Dimasak 🍳';
      case 2:
        return 'Siap Diambil! 🎉';
      case 3:
        return 'Selesai ✅';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final namaItems = widget.items.map((e) => e.nama).join(' + ');
    final sudahSelesai = _statusIndex == 3;
    final siapDiambil = _statusIndex == 2;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/onboard.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF1A6B3A).withOpacity(0.75),
                const Color(0xFF0D4A28).withOpacity(0.6),
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                children: [
                  // ===== NO ANTRIAN =====
                  const SizedBox(height: 12),
                  const Text(
                    'No Antrian',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ScaleTransition(
                    scale: _pulseAnim,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: siapDiambil
                                ? const Color(0xFF2E7D52).withOpacity(0.8)
                                : const Color(0xFF2E7D52).withOpacity(0.4),
                            blurRadius: siapDiambil ? 32 : 24,
                            spreadRadius: siapDiambil ? 6 : 4,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${widget.noAntrian}',
                          style: const TextStyle(
                            fontSize: 46,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1A3C2A),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.kantin,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Status badge animasi
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: siapDiambil
                          ? const Color(0xFF2E7D52)
                          : sudahSelesai
                          ? Colors.grey
                          : const Color(0xFFE87722),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: siapDiambil
                          ? [
                              BoxShadow(
                                color: const Color(0xFF2E7D52).withOpacity(0.5),
                                blurRadius: 12,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!sudahSelesai)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Text(
                          _statusLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ===== COUNTDOWN TIMER =====
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.97),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              sudahSelesai
                                  ? Icons.check_circle_rounded
                                  : siapDiambil
                                  ? Icons.shopping_bag_rounded
                                  : Icons.timer_rounded,
                              color: _timerColor,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              sudahSelesai
                                  ? 'Pesanan Selesai'
                                  : siapDiambil
                                  ? 'Makanan Siap!'
                                  : 'Estimasi Waktu',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: _timerColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (sudahSelesai) ...[
                          const Icon(
                            Icons.sentiment_very_satisfied_rounded,
                            color: Color(0xFF2E7D52),
                            size: 56,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Selamat menikmati! 😊',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D52),
                            ),
                          ),
                        ] else if (siapDiambil) ...[
                          const Icon(
                            Icons.shopping_bag_rounded,
                            color: Color(0xFF2E7D52),
                            size: 56,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Silakan ambil pesananmu!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D52),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tunjukkan No. Antrian ${widget.noAntrian} ke pedagang',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ] else ...[
                          Text(
                            _formatCountdown(),
                            style: TextStyle(
                              fontSize: 54,
                              fontWeight: FontWeight.w900,
                              color: _timerColor,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'menit : detik',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: (_totalDetik - _sisaDetik) / _totalDetik,
                              minHeight: 12,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _timerColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${((_totalDetik - _sisaDetik) / _totalDetik * 100).toStringAsFixed(0)}% selesai',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ===== STATUS PESANAN =====
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7DD9A3).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Status Pesanan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A3C2A),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _StatusStep(
                          dotColor: const Color(0xFF2196F3),
                          isActive: _statusIndex >= 0,
                          isCurrentStep: _statusIndex == 0,
                          title: 'Pesanan Diterima',
                          subtitle: '$_waktuPesan · ${widget.metode}',
                          showLine: true,
                          isDone: _statusIndex > 0,
                        ),
                        _StatusStep(
                          dotColor: const Color(0xFFE87722),
                          isActive: _statusIndex >= 1,
                          isCurrentStep: _statusIndex == 1,
                          title: 'Sedang Dimasak',
                          subtitle: namaItems,
                          showLine: true,
                          isDone: _statusIndex > 1,
                        ),
                        _StatusStep(
                          dotColor: const Color(0xFF2E7D52),
                          isActive: _statusIndex >= 2,
                          isCurrentStep: _statusIndex == 2,
                          title: 'Siap Diambil',
                          subtitle: 'Tunjukkan No. Antrian ke pedagang',
                          showLine: true,
                          isDone: _statusIndex > 2,
                        ),
                        _StatusStep(
                          dotColor: Colors.grey.shade600,
                          isActive: _statusIndex >= 3,
                          isCurrentStep: _statusIndex == 3,
                          title: 'Selesai',
                          subtitle: 'Selamat menikmati! 😊',
                          showLine: false,
                          isDone: _statusIndex >= 3,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ===== RINGKASAN PESANAN =====
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7DD9A3).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ringkasan Pesanan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A3C2A),
                          ),
                        ),
                        const SizedBox(height: 14),
                        ...widget.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.nama} x${item.qty}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF1A3C2A),
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatHarga(item.harga * item.qty),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF1A3C2A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          color: const Color(0xFF1A3C2A).withOpacity(0.3),
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A3C2A),
                              ),
                            ),
                            Text(
                              _formatHarga(widget.totalHarga),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A3C2A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF2E7D52),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Lunas · ${widget.metode}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A3C2A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ===== TOMBOL KEMBALI =====
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A3C2A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                      ),
                      icon: const Icon(Icons.home_rounded, color: Colors.white),
                      label: const Text(
                        'Kembali ke Home',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (route) => false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===== STATUS STEP =====
class _StatusStep extends StatelessWidget {
  final Color dotColor;
  final bool isActive;
  final bool isCurrentStep;
  final bool isDone;
  final String title;
  final String subtitle;
  final bool showLine;

  const _StatusStep({
    required this.dotColor,
    required this.isActive,
    required this.isCurrentStep,
    required this.isDone,
    required this.title,
    required this.subtitle,
    required this.showLine,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isActive ? dotColor : Colors.grey.shade300,
                shape: BoxShape.circle,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: dotColor.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: isActive
                  ? Center(
                      child: (isDone && !isCurrentStep)
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 15,
                            )
                          : isCurrentStep
                          ? const _SpinningIcon()
                          : null,
                    )
                  : null,
            ),
            if (showLine)
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 2.5,
                height: 40,
                decoration: BoxDecoration(
                  color: isActive
                      ? dotColor.withOpacity(0.5)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isActive
                        ? const Color(0xFF1A3C2A)
                        : Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isActive
                        ? const Color(0xFF2A5A3A)
                        : Colors.grey.shade400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (showLine) const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ===== SPINNING ICON =====
class _SpinningIcon extends StatefulWidget {
  const _SpinningIcon();

  @override
  State<_SpinningIcon> createState() => _SpinningIconState();
}

class _SpinningIconState extends State<_SpinningIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _ctrl,
      child: const Icon(Icons.autorenew_rounded, color: Colors.white, size: 15),
    );
  }
}
