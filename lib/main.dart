// Author: Arsh
// Role: Lead Developer / Repository Manager
// Description: App entry point — initializes Firebase and launches the app
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AuctionHubApp());
}

class AuctionHubApp extends StatelessWidget {
  const AuctionHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'AuctionHub',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData(
            colorSchemeSeed: const Color(0xFFFF6B00),
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFFF6B00),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            cardColor: Colors.white,
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Color(0xFFFF6B00),
              unselectedItemColor: Colors.grey,
            ),
          ),
          darkTheme: ThemeData(
            colorSchemeSeed: const Color(0xFFFF6B00),
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0D1B3E),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFFF6B00),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            cardColor: const Color(0xFF1A2A5E),
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: const Color(0xFF0D1B3E),
              indicatorColor: const Color(0xFFFF6B00),
            ),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
