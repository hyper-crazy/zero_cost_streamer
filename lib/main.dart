import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/content_provider.dart';
import 'screens/home_screen.dart';

// Global Key for managing SnackBars
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  // MUST BE FIRST: To bind the engine before any async calls
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: .env file missing");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ContentProvider()),
      ],
      // Zero-restart wrapper
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color tmdbDarkBlue = Color(0xFF0D253F);
  static const Color tmdbLightBlue = Color(0xFF01B4E4);
  static const Color tmdbLightGreen = Color(0xFF90CEA1);
  static const Color coffeeCream = Color(0xFFE6E0D4);

  @override
  Widget build(BuildContext context) {
    // Standardizing text themes once to prevent rebuild flicker
    final lightTextTheme = GoogleFonts.montserratTextTheme(ThemeData.light().textTheme);
    final darkTextTheme = GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme);

    return MaterialApp(
      // FIXED: Using a UniqueKey here can sometimes cause refresh,
      // but a ValueKey helps Flutter differentiate themes without losing state.
      key: const ValueKey('ZeroStreamMainApp'),
      title: 'Zero Stream',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,

      // --- DARK THEME ---
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: tmdbDarkBlue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: tmdbLightBlue,
          brightness: Brightness.dark,
          primary: tmdbLightBlue,
          surface: tmdbDarkBlue,
        ),
        textTheme: darkTextTheme,
        appBarTheme: const AppBarTheme(
          backgroundColor: tmdbDarkBlue,
          elevation: 0,
          centerTitle: true,
        ),
      ),

      // --- LIGHT THEME ---
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: coffeeCream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: tmdbLightBlue,
          brightness: Brightness.light,
          primary: tmdbLightGreen,
          surface: coffeeCream,
        ),
        textTheme: lightTextTheme,
        appBarTheme: const AppBarTheme(
          backgroundColor: coffeeCream,
          elevation: 0,
          centerTitle: true,
        ),
      ),

      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}