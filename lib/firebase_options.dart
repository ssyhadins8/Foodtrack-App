import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Firebase configuration generated from the provided `google-services.json`.
/// Only Android configuration is filled; other platforms return an empty
/// placeholder or throw an error.
class DefaultFirebaseOptions {

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDKcukj2a22dqINETCBLLIhxVsUJSwlRlg',
    appId: '1:210926790058:android:e8abbb460fa0e60ae4f7d3',
    messagingSenderId: '210926790058',
    projectId: 'foodtrack-c14b2',
    storageBucket: 'foodtrack-c14b2.firebasestorage.app',
  );

  // Android configuration extracted from the user's google-services.json.

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAMCQ8W1_fAq_3Gybu_o_nm61XXH1p_sKI',
    appId: '1:210926790058:web:fc409739770742fce4f7d3',
    messagingSenderId: '210926790058',
    projectId: 'foodtrack-c14b2',
    authDomain: 'foodtrack-c14b2.firebaseapp.com',
    storageBucket: 'foodtrack-c14b2.firebasestorage.app',
    measurementId: 'G-HY547JB788',
  );

  // Placeholder for the web platform – you can fill this with your web config.

  /// Returns the appropriate [FirebaseOptions] for the current platform.
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      // Add other platforms here if needed.
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}