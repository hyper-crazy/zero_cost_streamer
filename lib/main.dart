import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/content_provider.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // High-performance font loading: Pre-configures fonts to prevent black-screen flicker
  GoogleFonts.config.allowRuntimeFetching = true;

  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

        // Stabilized Dark Theme
        darkTheme: ThemeData(
          useMaterial3: true, // Forces modern rendering engine
          brightness: Brightness.dark,
          scaffoldBackgroundColor: tmdbDarkBlue,
          colorScheme: ColorScheme.fromSeed(
            seedColor: tmdbLightBlue,
            brightness: Brightness.dark,
            surface: tmdbDarkBlue,
          ),
          textTheme: GoogleFonts.montserratTextTheme(
            Theme.of(context).brightness == Brightness.dark
                ? ThemeData.dark().textTheme
                : ThemeData.light().textTheme,
          ),
        ),

        // Stabilized Light Theme
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: coffeeCream,
          colorScheme: ColorScheme.fromSeed(
            seedColor: tmdbLightBlue,
            brightness: Brightness.light,
            surface: coffeeCream,
          ),
          textTheme: GoogleFonts.montserratTextTheme(ThemeData.light().textTheme),
          appBarTheme: const AppBarTheme(
            backgroundColor: coffeeCream,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),

        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}