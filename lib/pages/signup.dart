import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodtrack/theme/app_colors.dart';
import 'package:foodtrack/services/firestore_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:foodtrack/widgets/role_selector_dialog.dart';
import 'package:foodtrack/widgets/kantin_selector_dialog.dart';
import 'package:foodtrack/services/google_sign_in_config.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _konfCtrl = TextEditingController();
  final _kantinCtrl = TextEditingController();
  bool _loading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscure1 = true;
  bool _obscure2 = true;
  String _role = 'pembeli';

  List<Map<String, dynamic>> _dynamicCanteens = [];
  bool _loadingCanteens = true;
  String _selectedKantin = '';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _loadCanteens();
  }

  Future<void> _loadCanteens() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('kantin').get();
      setState(() {
        _dynamicCanteens = snap.docs.map((doc) => {
          'id': doc.id,
          'nama': doc.data()['nama'] ?? '',
        }).toList();
        
        if (_dynamicCanteens.isNotEmpty) {
          _selectedKantin = _dynamicCanteens.first['nama'];
        }
        _loadingCanteens = false;
      });
    } catch (e) {
      debugPrint('Gagal memuat kantin secara dinamis: $e');
      setState(() {
        _dynamicCanteens = [
          {'id': 'kantin_1', 'nama': 'Kantin Bu Sari'},
          {'id': 'kantin_2', 'nama': 'Kantin Pak Budi'},
          {'id': 'kantin_3', 'nama': 'Kantin Geprek'},
          {'id': 'kantin_4', 'nama': 'Kantin Bakso Mas Jo'},
          {'id': 'kantin_5', 'nama': 'Kantin Minuman Segar'},
          {'id': 'kantin_6', 'nama': 'Kantin Seafood Bu Tini'},
          {'id': 'kantin_7', 'nama': 'Kantin Snack Corner'},
          {'id': 'kantin_8', 'nama': 'Kantin Nasi Padang'},
        ];
        _selectedKantin = 'Kantin Bu Sari';
        _loadingCanteens = false;
      });
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _konfCtrl.dispose();
    _kantinCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool error = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(
          error ? Icons.error_rounded : Icons.check_circle_rounded,
          color: Colors.white,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(msg)),
      ]),
      backgroundColor: error ? AppColors.danger : AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final nama = _namaCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final konf = _konfCtrl.text;

    if (nama.isEmpty) {
      _snack('Nama harus diisi!');
      return;
    }
    if (email.isEmpty) {
      _snack('Email harus diisi!');
      return;
    }
    if (pass.length < 6) {
      _snack('Password minimal 6 karakter!');
      return;
    }
    if (pass != konf) {
      _snack('Password tidak cocok!');
      return;
    }
    if (_role == 'pedagang' && _selectedKantin.isEmpty) {
      _snack('Pilih kantin kamu!');
      return;
    }

    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);
      await cred.user?.updateDisplayName(nama);

      final selectedCanteen = _dynamicCanteens.firstWhere(
        (element) => element['nama'] == _selectedKantin,
        orElse: () => {'id': 'kantin_1', 'nama': 'Kantin Bu Sari'},
      );
      final kantinId = _role == 'pedagang' ? selectedCanteen['id'] : '';

      await FirestoreService.simpanUserBaru(
        email: email,
        nama: nama,
        role: _role,
        namaKantin: _role == 'pedagang' ? _selectedKantin : '',
        kantinId: kantinId,
      );

      if (!mounted) return;
      if (_role == 'pedagang') {
        Navigator.pushReplacementNamed(
          context,
          '/home_pedagang',
          arguments: {
            'namaKantin': _selectedKantin,
            'kantinId': kantinId,
          },
        );
      } else if (_role == 'admin') {
        Navigator.pushReplacementNamed(context, '/home_admin');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      final msgs = {
        'email-already-in-use': 'Email sudah digunakan',
        'invalid-email': 'Format email tidak valid',
        'weak-password': 'Password terlalu lemah',
      };
      _snack(msgs[e.code] ?? 'Daftar gagal');
    } catch (e) {
      _snack('Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _promptAdminPasscode() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Passcode Keamanan Admin', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Masukkan passcode khusus untuk mendaftar sebagai Admin:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                obscureText: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Passcode',
                  filled: true,
                  fillColor: AppColors.cyanLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.cyan.withValues(alpha: 0.3)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                if (controller.text == 'ADMIN2026') {
                  setState(() {
                    _role = 'admin';
                  });
                  Navigator.pop(context);
                  _snack('Akses Admin disetujui!', error: false);
                } else {
                  _snack('Passcode salah! Akses ditolak.');
                  Navigator.pop(context);
                }
              },
              child: const Text('Verifikasi', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Background ───────────────────────────────────────────────
          Positioned.fill(
            child: Stack(
              children: [
                Image.asset(
                  'images/onboard.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  semanticLabel: 'Background image',
                  errorBuilder: (_, __, ___) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF0D1B2A),
                          Color(0xFF1B3A5C),
                          Color(0xFF0D2137),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xEE0D1B2A),
                        Color(0xCC1B3A5C),
                        Color(0xAA0D1B2A),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Konten ───────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    // Logo
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cyan.withValues(alpha: 0.4), // ✅
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3), // ✅
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                          color: AppColors.cyan.withValues(alpha: 0.5), // ✅
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Image.asset(
                            'images/logo.png',
                            semanticLabel: 'App logo',
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.restaurant_rounded,
                              size: 40,
                              color: AppColors.primary,
                            ),
                          ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Buat Akun Baru',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Daftar dan mulai pesan makananmu',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6), // ✅
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Form Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2), // ✅
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: AppColors.cyan.withValues(alpha: 0.1), // ✅
                            blurRadius: 20,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(children: [
                            Container(
                              width: 4,
                              height: 22,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.primary, AppColors.cyan],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ]),
                          const SizedBox(height: 20),

                          // Pilihan Role
                          const Text(
                            'Daftar sebagai:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(children: [
                            _RoleChip(
                              label: '🛒 Pembeli',
                              active: _role == 'pembeli',
                              onTap: () => setState(() => _role = 'pembeli'),
                            ),
                            const SizedBox(width: 8),
                            _RoleChip(
                              label: '🏪 Pedagang',
                              active: _role == 'pedagang',
                              onTap: () => setState(() => _role = 'pedagang'),
                            ),
                            const SizedBox(width: 8),
                            _RoleChip(
                              label: '🔑 Admin',
                              active: _role == 'admin',
                              onTap: _promptAdminPasscode,
                            ),
                          ]),
                          const SizedBox(height: 16),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildField(
                          _namaCtrl,
                          'Nama Lengkap',
                          Icons.person_outline_rounded,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nama harus diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          _emailCtrl,
                          'Email',
                          Icons.email_outlined,
                          type: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email harus diisi';
                            }
                             final emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(value.trim())) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildFieldPass(
                          _passCtrl,
                          'Password',
                          _obscure1,
                          () => setState(() => _obscure1 = !_obscure1),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password harus diisi';
                            }
                            if (value.length < 6) {
                              return 'Password minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildFieldPass(
                          _konfCtrl,
                          'Konfirmasi Password',
                          _obscure2,
                          () => setState(() => _obscure2 = !_obscure2),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Konfirmasi password harus diisi';
                            }
                            if (value != _passCtrl.text) {
                              return 'Password tidak cocok';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                          // Dropdown Kantin (pedagang only)
                          if (_role == 'pedagang') ...[
                            const SizedBox(height: 16),
                            const Text(
                              'Pilih Kantinmu:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: AppColors.cyanLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.cyan.withValues(alpha: 0.3), // ✅
                                ),
                              ),
                              child: _loadingCanteens
                                  ? const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      child: Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    )
                                  : DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        dropdownColor: Colors.white,
                                        style: const TextStyle(color: AppColors.textPrimary),
                                        value: _selectedKantin.isNotEmpty ? _selectedKantin : null,
                                        isExpanded: true,
                                        icon: const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: AppColors.primary,
                                        ),
                                        items: _dynamicCanteens
                                            .map((k) => DropdownMenuItem<String>(
                                                  value: k['nama'] as String,
                                                  child: Text(
                                                    k['nama'] as String,
                                                    style: const TextStyle(fontSize: 14),
                                                  ),
                                                ))
                                            .toList(),
                                        onChanged: (v) => setState(() => _selectedKantin = v!),
                                      ),
                                    ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Tombol Daftar
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              onPressed: _loading ? null : _signup,
                              child: _loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: AppColors.cyan,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'DAFTAR',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        letterSpacing: 1,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Link Login
                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.pushReplacementNamed(
                                  context, '/login'),
                              child: RichText(
                                text: const TextSpan(
                                  text: 'Sudah punya akun? ',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Login',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType? type,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: AppColors.textPrimary),
      keyboardType: type,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.cyanLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.cyan.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.cyan.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _buildFieldPass(
    TextEditingController ctrl,
    String hint,
    bool obscure,
    VoidCallback toggle, {
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: AppColors.textPrimary),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          color: AppColors.primary,
          size: 20,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.grey.shade400,
            size: 20,
          ),
          onPressed: toggle,
        ),
        filled: true,
        fillColor: AppColors.cyanLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: AppColors.cyan.withValues(alpha: 0.3)), // ✅
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: AppColors.cyan.withValues(alpha: 0.3)), // ✅
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }


}

class _RoleChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _RoleChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? AppColors.primary : Colors.grey.shade200,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3), // ✅
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? Colors.white : AppColors.textSecondary,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
