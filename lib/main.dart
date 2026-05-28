import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';

import 'package:foodtrack/cart_provider.dart';
import 'package:foodtrack/firebase_options.dart';

import 'package:foodtrack/pages/splash_page.dart';
import 'package:foodtrack/pages/onboarding.dart';
import 'package:foodtrack/pages/login.dart';
import 'package:foodtrack/pages/signup.dart';
import 'package:foodtrack/pages/home.dart';
import 'package:foodtrack/pages/pedagang/home_pedagang_page.dart';
import 'package:foodtrack/pages/admin/home_admin_page.dart';
import 'package:foodtrack/pages/status_pesanan_page.dart'; // ✅ Fix 12: tambah import
import 'package:foodtrack/pages/checkout_page.dart'; // ✅ Add checkout page import
import 'package:foodtrack/services/firestore_service.dart'; // ✅ Add firestore service import

import 'package:foodtrack/theme/app_colors.dart';
import 'package:foodtrack/theme/app_typography.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  // ✅ Seed canteens & menus if database is empty
  await FirestoreService.seedInitialData();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CartProvider())],
      child: const FoodTrackApp(),
    ),
  );
}

class FoodTrackApp extends StatelessWidget {
  const FoodTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Use Google Fonts Inter via AppTypography
        textTheme: TextTheme(
          displayLarge: AppTypography.headline1,
          displayMedium: AppTypography.headline2,
          displaySmall: AppTypography.headline3,
          headlineLarge: AppTypography.headline4,
          headlineMedium: AppTypography.headline5,
          headlineSmall: AppTypography.headline6,
          titleMedium: AppTypography.subtitle1,
          titleSmall: AppTypography.subtitle2,
          bodyLarge: AppTypography.bodyText1,
          bodyMedium: AppTypography.bodyText2,
          labelLarge: AppTypography.button,
          bodySmall: AppTypography.caption,
          labelSmall: AppTypography.overline,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashPage(),
        '/onboarding': (_) => const OnboardingPage(),
        '/login': (_) => const LogIn(),
        '/signup': (_) => const SignUp(),
        '/home': (_) => const HomePage(),
        '/home_admin': (_) => const HomeAdminPage(),
        '/checkout': (_) => const CheckoutPage(), // ✅ Add checkout page route
      },
      onGenerateRoute: (settings) {
        // ── Route: home_pedagang ──────────────────────────────────────────
        if (settings.name == '/home_pedagang') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (_) => HomePedagangPage(
              namaKantin: args?['namaKantin'] ?? 'Kantin Saya',
              kantinId: args?['kantinId'] ?? 'kantin_1',
            ),
          );
        }

        // ── Route: status_pesanan ─────────────────────────────────────────
        if (settings.name == '/status_pesanan') {
          // ✅ Fix 12
          final docId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => StatusPesananPage(docId: docId),
          );
        }

        return null;
      },
    );
  }
}
