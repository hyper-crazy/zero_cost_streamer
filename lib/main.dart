import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/content_provider.dart';
import 'screens/splash_screen.dart'; // Import Animated Splash

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: .env missing");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

        themeMode: ThemeMode.system,

        // Premium Dark Theme
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0D253F),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF01B4E4),
            brightness: Brightness.dark,
          ),
          textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme),
        ),

        // Premium Light Theme
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFE6E0D4),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF01B4E4),
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.montserratTextTheme(ThemeData.light().textTheme),
        ),

        // Ekhon shudhu Splash Screen-e start hobe
        home: const AnimatedSplashScreen(),
      ),
    );
  }
}