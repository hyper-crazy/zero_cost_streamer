import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Windows build error fixed by removing explicit controller calls here
import 'providers/content_provider.dart';
import 'screens/splash_screen.dart';
import 'widgets/offline_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialization logic removed from main to avoid "Undefined name" errors
  // The plugin handles this automatically when the first WebView is created.

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Env error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
        themeMode: ThemeMode.system,

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