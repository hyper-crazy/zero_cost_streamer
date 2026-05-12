import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen> {
  double _progressValue = 0.0;

  @override
  void initState() {
    super.initState();
    _animateLoading();
  }

  void _animateLoading() {
    // 3 second loading logic
    const duration = Duration(milliseconds: 3000);
    const interval = Duration(milliseconds: 30);
    int steps = duration.inMilliseconds ~/ interval.inMilliseconds;
    double increment = 1.0 / steps;

    Timer.periodic(interval, (timer) {
      if (mounted) {
        setState(() {
          if (_progressValue >= 1.0) {
            timer.cancel();
            _navigateToHome();
          } else {
            _progressValue += increment;
          }
        });
      }
    });
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : const Color(0xFF0D253F);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        alignment: Alignment.center, // FIXED: Corrected alignment logic
        children: [
          // Middle: Branding & Loading
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/zs_logo_transparent bg.png',
                  width: 130,
                ),
                const SizedBox(height: 24),
                Text(
                  'Zero Stream',
                  style: GoogleFonts.montserrat(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 40),
                // Premium Slim Progress Bar
                Container(
                  width: 220,
                  height: 4,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: textColor.withOpacity(0.1),
                  ),
                  child: LinearProgressIndicator(
                    value: _progressValue,
                    backgroundColor: Colors.transparent,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          // Bottom: TMDB Credit
          Positioned(
            bottom: 50,
            child: Column(
              children: [
                Text(
                  'Database provided by',
                  style: GoogleFonts.montserrat(
                    color: textColor.withOpacity(0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                SvgPicture.asset(
                  'assets/images/TMDB_attribution.svg',
                  width: 90,
                  // ignore: deprecated_member_use
                  color: textColor.withOpacity(0.7),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}