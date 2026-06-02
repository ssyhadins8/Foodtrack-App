import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInConfig {
  /// TODO: Silakan ganti dengan Web Client ID milik Anda dari Firebase Console / Google Cloud Console.
  ///
  /// Cara mendapatkan Web Client ID:
  /// 1. Buka Firebase Console (https://console.firebase.google.com/)
  /// 2. Masuk ke menu Build -> Authentication -> tab Sign-in method
  /// 3. Klik edit pada provider Google.
  /// 4. Buka bagian "Web SDK configuration" (Konfigurasi SDK Web).
  /// 5. Salin nilai dari "Web client ID" dan paste di variabel di bawah ini.
  // lib/services/google_sign_in_config.dart

  static const String webClientId =
      '210926790058-4lqgg0jlo8sfiroj1ga8ldh6t5iqp0j0.apps.googleusercontent.com';

  static GoogleSignIn getGoogleSignIn() {
    return GoogleSignIn(
      clientId: kIsWeb ? webClientId : null,
    );
  }
}
