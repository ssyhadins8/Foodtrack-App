// login.dart - Updated to ensure input text is visible (dark blue)
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:foodtrack/theme/app_colors.dart';
import 'package:foodtrack/widgets/role_selector_dialog.dart';
import 'package:foodtrack/widgets/kantin_selector_dialog.dart';
import 'package:foodtrack/services/google_sign_in_config.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});
  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool error = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              error ? Icons.error_rounded : Icons.check_circle_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: error ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ✅ FIX: simpanUserBaru langsung di sini, tidak perlu FirestoreService
  Future<void> _simpanUserBaru({
    required String uid,
    required String email,
    required String nama,
  }) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'nama': nama,
      'role': 'pembeli',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (email.isEmpty) {
      _snack('Email harus diisi!');
      return;
    }
    if (pass.isEmpty) {
      _snack('Password harus diisi!');
      return;
    }
    if (pass.length < 6) {
      _snack('Password minimal 6 karakter!');
      return;
    }

    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
      if (!mounted) return;

      final uid = cred.user?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!mounted) return;

      if (!doc.exists) {
        await _simpanUserBaru(
          uid: uid,
          email: email,
          nama: cred.user?.displayName ?? email.split('@')[0],
        );
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
        return;
      }

      final role = doc.data()?['role'] ?? 'pembeli';
      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/home_admin');
      } else if (role == 'pedagang') {
        Navigator.pushReplacementNamed(
          context,
          '/home_pedagang',
          arguments: {
            'namaKantin': doc.data()?['namaKantin'] ?? 'Kantin Saya',
            'kantinId': doc.data()?['kantinId'] ?? 'kantin_1',
          },
        );
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      final msgs = {
        'user-not-found': 'Akun tidak ditemukan. Silakan daftar.',
        'wrong-password': 'Password salah. Periksa kembali.',
        'invalid-credential':
            'Email atau password salah. Pastikan data benar.',
        'invalid-email': 'Format email tidak valid.',
        'user-disabled': 'Akun ini telah dinonaktifkan.',
        'too-many-requests':
            'Terlalu banyak percobaan. Coba lagi nanti.',
        'network-request-failed': 'Koneksi internet bermasalah.',
      };
      _snack(msgs[e.code] ?? 'Login gagal: ${e.message ?? e.code}');
    } catch (e) {
      _snack('Terjadi kesalahan sistem. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _forgotPassword() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D1B2A), Color(0xFF1B3A5C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: const Icon(Icons.lock_reset_rounded,
                  color: Colors.white, size: 50),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ganti Password',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Masukkan email akun Anda. Link untuk mengganti password akan dikirim ke email tersebut.',
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: ctrl,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Email / NIM',
                      prefixIcon:
                          const Icon(Icons.email_outlined, color: AppColors.primary),
                      filled: true,
                      fillColor: AppColors.cyanLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    obscureText: true,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Password Baru',
                      prefixIcon: const Icon(Icons.lock_outline_rounded,
                          color: AppColors.primary),
                      filled: true,
                      fillColor: AppColors.cyanLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    obscureText: true,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Konfirmasi Password',
                      prefixIcon: const Icon(Icons.lock_reset_rounded,
                          color: AppColors.primary),
                      filled: true,
                      fillColor: AppColors.cyanLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Batal',
                              style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              elevation: 0),
                          onPressed: () async {
                            final email = ctrl.text.trim();
                            if (email.isEmpty) {
                              _snack('Masukkan email terlebih dahulu!');
                              return;
                            }
                            try {
                              await FirebaseAuth.instance
                                  .sendPasswordResetEmail(email: email);
                              if (!mounted) return;
                              Navigator.pop(context);
                              _snack('Instruksi ganti password telah dikirim ke email Anda!',
                                  error: false);
                            } catch (e) {
                              _snack('Gagal mengirim email: $e');
                            }
                          },
                          child: const Text('Kirim',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Stack(
              children: [
                Image.asset('images/onboard.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) =>
                        Container(color: AppColors.primary)),
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
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cyan.withValues(alpha: 0.3),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                          border: Border.all(
                            color: AppColors.cyan.withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Image.asset('images/logo.png',
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.restaurant_rounded,
                                  size: 40,
                                  color: AppColors.primary)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Welcome Back',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('Masuk ke akun FoodTrack kamu',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 13)),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
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
                                const Text('Login',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary)),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildField(
                                controller: _emailCtrl,
                                hint: 'Email / NIM',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Email harus diisi!';
                                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                  if (!emailRegex.hasMatch(value))
                                    return 'Format email tidak valid';
                                  return null;
                                }),
                            const SizedBox(height: 14),
                            _buildField(
                                controller: _passCtrl,
                                hint: 'Password',
                                icon: Icons.lock_outline_rounded,
                                obscure: _obscure,
                                suffix: IconButton(
                                  icon: Icon(
                                      _obscure
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.grey.shade400,
                                      size: 20),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Password harus diisi!';
                                  if (value.length < 6)
                                    return 'Password minimal 6 karakter!';
                                  return null;
                                }),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _forgotPassword,
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                child: const Text('Lupa password?',
                                    style: TextStyle(
                                        color: AppColors.secondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14)),
                                        elevation: 0),
                                    onPressed: _loading
                                        ? null
                                        : () {
                                            if (_formKey.currentState?.validate() ??
                                                false) {
                                              _login();
                                            }
                                          },
                                    child: _loading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                                color: AppColors.cyan,
                                                strokeWidth: 2.5))
                                        : const Text('LOGIN',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                letterSpacing: 1)))),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: const StadiumBorder(),
                                  side: BorderSide(color: Colors.grey.shade300, width: 1.2),
                                  backgroundColor: Colors.white,
                                  elevation: 0,
                                ),
                                icon: Image.asset('images/google.png', height: 22),
                                label: const Text(
                                  'Lanjutkan dengan Google',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                onPressed: _loading ? null : _loginWithGoogle,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(children: [
                              Expanded(
                                  child: Divider(
                                      color: Colors.grey.shade200)),
                               const Padding(
                                   padding: EdgeInsets.symmetric(horizontal: 12),
                                   child: Text('atau',
                                       style: const TextStyle(
                                           color: Color(0xFFBDBDBD),
                                           fontSize: 12))),
                              Expanded(
                                  child: Divider(
                                      color: Colors.grey.shade200)),
                            ]),
                            const SizedBox(height: 16),
                            Center(
                              child: GestureDetector(
                                onTap: () => Navigator.pushReplacementNamed(context, '/signup'),
                                child: RichText(
                                  text: const TextSpan(
                                    text: 'Belum punya akun? ',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Sign Up',
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
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        suffixIcon: suffix,
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  // ---------- GOOGLE SIGN‑IN LOGIC ----------
  Future<void> _loginWithGoogle() async {
    setState(() => _loading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignInConfig.getGoogleSignIn().signIn();
      if (googleUser == null) return; // cancelled
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential cred = await FirebaseAuth.instance.signInWithCredential(credential);
      final uid = cred.user?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!doc.exists) {
        // New user: ask role
        final role = await showDialog<String>(
          context: context,
          builder: (_) => RoleSelectorDialog(),
        );
        if (role == null) return;
        Map<String, dynamic> newData = {
          'uid': uid,
          'email': cred.user?.email ?? '',
          'nama': cred.user?.displayName ?? cred.user?.email?.split('@')[0] ?? '',
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
        };
        if (role == 'pedagang') {
          final selectedKantin = await showDialog<String>(
            context: context,
            builder: (_) => KantinSelectorDialog(),
          );
          if (selectedKantin != null) {
            newData.addAll({
              'namaKantin': selectedKantin,
              'kantinId': selectedKantin.toLowerCase().replaceAll(' ', '_'),
            });
          }
        }
        await FirebaseFirestore.instance.collection('users').doc(uid).set(newData);
        _navigateByRole(role, newData);
        return;
      }
      final role = doc.data()?['role'] ?? 'pembeli';
      _navigateByRole(role, doc.data() ?? {});
    } on FirebaseAuthException catch (e) {
      _snack('Google login gagal: ${e.message ?? e.code}');
    } catch (e) {
      _snack('Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _navigateByRole(String role, Map<String, dynamic> data) {
    if (!mounted) return;
    if (role == 'admin') {
      Navigator.pushReplacementNamed(context, '/home_admin');
    } else if (role == 'pedagang') {
      Navigator.pushReplacementNamed(
        context,
        '/home_pedagang',
        arguments: {
          'namaKantin': data['namaKantin'] ?? 'Kantin Saya',
          'kantinId': data['kantinId'] ?? '',
        },
      );
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

}
