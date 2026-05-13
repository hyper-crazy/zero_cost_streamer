import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'providers/content_provider.dart';
import 'screens/splash_screen.dart';
import 'widgets/offline_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Environment file error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TMDB Official Palette
    const tmdbTertiaryGreen = Color(0xFF90CEA1);
    const tmdbSecondaryBlue = Color(0xFF01B4E4);
    const tmdbDeepNavy = Color(0xFF0D253F);
    const tmdbBeige = Color(0xFFE6E0D4);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ContentProvider()),
      ],
      child: MaterialApp(
        title: 'Zero Stream',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system, // Auto-switch based on system settings

        // Premium Dark Theme (TMDB Navy Style)
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: tmdbDeepNavy,
          colorScheme: ColorScheme.fromSeed(
            seedColor: tmdbSecondaryBlue,
            brightness: Brightness.dark,
            primary: tmdbSecondaryBlue,
          ),
          textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme),
        ),

        // Elegant Light Theme
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: tmdbBeige,
          colorScheme: ColorScheme.fromSeed(
            seedColor: tmdbTertiaryGreen,
            brightness: Brightness.light,
            primary: tmdbTertiaryGreen,
          ),
          textTheme: GoogleFonts.montserratTextTheme(ThemeData.light().textTheme),
        ),

        home: const AnimatedSplashScreen(),

        // Global Builder to handle Offline Overlay
        builder: (context, child) {
          final provider = Provider.of<ContentProvider>(context);
          return Stack(
            children: [
              if (child != null) child,
              if (provider.isOffline) const OfflineOverlay(),
            ],
          );
        },
      ),
    );
  }
}