import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/movie.dart';

class PlayerScreen extends StatefulWidget {
  final Movie movie;
  const PlayerScreen({super.key, required this.movie});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isLandscape = true; // Track current rotation state

  @override
  void initState() {
    super.initState();

    // Initial setup: Force Landscape and Fullscreen
    _setLandscape();

    final String videoUrl = 'https://vidsrc.to/embed/movie/${widget.movie.id}';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setUserAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36")
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('vidsrc.to') ||
                request.url.contains('vidsrc.stream') ||
                request.url.contains('vidplay') ||
                request.url.contains('2embed')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
          onPageStarted: (String url) => setState(() => _isLoading = true),
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            _controller.runJavaScript("""
              (function() {
                var style = document.createElement('style');
                style.innerHTML = '#overlay, .ads, .ad-box, .pop-under, .pop-up { display: none !important; }';
                document.head.appendChild(style);
                window.open = function() { return null; };
              })();
            """);
          },
        ),
      )
      ..loadRequest(Uri.parse(videoUrl));
  }

  // --- ROTATION HELPERS ---

  void _setLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _setPortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    // Optionally show status bars in portrait
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _toggleRotation() {
    setState(() {
      if (_isLandscape) {
        _setPortrait();
      } else {
        _setLandscape();
      }
      _isLandscape = !_isLandscape;
    });
  }

  @override
  void dispose() {
    // ALWAYS reset to Portrait when exiting the player
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // The Player
          Center(
            child: WebViewWidget(controller: _controller),
          ),

          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Color(0xFF01B4E4))),

          // UI OVERLAY: Buttons
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: _buildControlButton(Icons.arrow_back_ios_new),
                  ),

                  // MANUAL ROTATION TOGGLE
                  GestureDetector(
                    onTap: _toggleRotation,
                    child: _buildControlButton(
                      _isLandscape ? Icons.screen_lock_portrait : Icons.screen_lock_landscape,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper for consistent button styling
  Widget _buildControlButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}