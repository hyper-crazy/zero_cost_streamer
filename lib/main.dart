import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/content_provider.dart';
import 'screens/home_screen.dart';

// Global Key for managing SnackBars across the app context
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Optimizing font loading for smoother UI rendering
  GoogleFonts.config.allowRuntimeFetching = true;

  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Zero Stream Brand Color Palette
  static const Color tmdbDarkBlue = Color(0xFF0D253F);
  static const Color tmdbLightBlue = Color(0xFF01B4E4);
  static const Color tmdbLightGreen = Color(0xFF90CEA1);
  static const Color coffeeCream = Color(0xFFE6E0D4);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ContentProvider()),
      ],
      child: MaterialApp(
        title: 'Zero Stream',
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: scaffoldMessengerKey,

        // Premium Dark Theme (TMDB Inspired)
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
          textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme),
          appBarTheme: const AppBarTheme(
            backgroundColor: tmdbDarkBlue,
            elevation: 0,
            centerTitle: true,
          ),
        ),

        // Premium Light Theme (Coffee Cream)
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
          textTheme: GoogleFonts.montserratTextTheme(ThemeData.light().textTheme),
          appBarTheme: const AppBarTheme(
            backgroundColor: coffeeCream,
            elevation: 0,
            centerTitle: true,
          ),
        ),

        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}