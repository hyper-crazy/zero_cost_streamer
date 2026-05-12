import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/content_provider.dart';

class OfflineOverlay extends StatefulWidget {
  const OfflineOverlay({super.key});

  @override
  State<OfflineOverlay> createState() => _OfflineOverlayState();
}

class _OfflineOverlayState extends State<OfflineOverlay> {
  bool _isChecking = false;

  Future<void> _handleRetry() async {
    setState(() => _isChecking = true);
    await Future.delayed(const Duration(seconds: 1));

    final results = await Connectivity().checkConnectivity();
    final hasNet = !results.contains(ConnectivityResult.none);

    if (hasNet) {
      if (mounted) {
        Provider.of<ContentProvider>(context, listen: false).refreshHome();
      }
    } else {
      if (mounted) {
        setState(() => _isChecking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Internet connection still not found."),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic styling based on main.dart themes
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : const Color(0xFF0D253F);
    final primaryColor = Theme.of(context).colorScheme.primary; // Automatic Blue or Green

    return Material(
      color: bgColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                  Icons.wifi_off_rounded,
                  size: 100,
                  color: textColor.withOpacity(0.2)
              ),
              const SizedBox(height: 24),
              Text(
                'No Connection',
                style: GoogleFonts.montserrat(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please check your internet. Then try again to reconnect.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor.withOpacity(0.6),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              _isChecking
                  ? Column(
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  const SizedBox(height: 16),
                  Text(
                      "Checking connection...",
                      style: TextStyle(color: textColor.withOpacity(0.4), fontSize: 13)
                  ),
                ],
              )
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: isDark ? Colors.white : Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                  ),
                  elevation: 4,
                ),
                onPressed: _handleRetry,
                child: Text(
                  'TRY AGAIN',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}