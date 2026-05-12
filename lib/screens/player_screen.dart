import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/content.dart';
import '../utils/constants.dart';

class PlayerScreen extends StatefulWidget {
  final Content content;
  final int? season;
  final int? episode;
  final List<dynamic>? episodesList;

  const PlayerScreen({
    super.key,
    required this.content,
    this.season,
    this.episode,
    this.episodesList,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isLandscape = true;
  bool _isChangingEpisode = false;

  @override
  void initState() {
    super.initState();
    _setLandscape();

    final String videoUrl = widget.season != null
        ? '${AppConstants.vidsrcBaseUrl}/embed/tv/${widget.content.id}/${widget.season}/${widget.episode}'
        : '${AppConstants.vidsrcBaseUrl}/embed/movie/${widget.content.id}';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
    // Release APK Fix: Hybrid Mobile UserAgent to bypass blocks & Cloudflare
      ..setUserAgent("Mozilla/5.0 (Linux; Android 14; SM-S928B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36")
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final url = request.url.toLowerCase();

            // Check if URL belongs to trusted domains from constants.dart
            bool isTrusted = AppConstants.trustedStreamingDomains.any(
                    (domain) => url.contains(domain.toLowerCase())
            );

            if (isTrusted) {
              return NavigationDecision.navigate;
            }

            // Block all other main frame redirects (STOPS ADS/GOOGLE SEARCH REDIRECTS)
            if (request.isMainFrame) {
              debugPrint("Blocked Ad Redirect: $url");
              return NavigationDecision.prevent;
            }

            return NavigationDecision.prevent;
          },
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
            // Injecting CSS to hide ad overlays
            _controller.runJavaScript("""
              (function() {
                var style = document.createElement('style');
                style.innerHTML = '#overlay, .ads, .ad-box, .pop-under, .pop-up, [class*="ad-"] { display: none !important; }';
                document.head.appendChild(style);
                window.open = function() { return null; };
              })();
            """);
          },
        ),
      )
      ..loadRequest(Uri.parse(videoUrl));
  }

  void _changeEpisode(int newEpisode) {
    setState(() => _isChangingEpisode = true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerScreen(
          content: widget.content,
          season: widget.season,
          episode: newEpisode,
          episodesList: widget.episodesList,
        ),
      ),
    );
  }

  void _setLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _setPortrait() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
    if (!_isChangingEpisode) {
      _setPortrait();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(child: WebViewWidget(controller: _controller)),

          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Color(0xFF01B4E4))),

          // UI OVERLAY
          Positioned(
            top: 20, left: 20, right: 20,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: _buildControlButton(Icons.arrow_back_ios_new),
                  ),
                  Row(
                    children: [
                      // PREVIOUS EPISODE
                      if (widget.episode != null && widget.episode! > 1)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () => _changeEpisode(widget.episode! - 1),
                            child: _buildControlButton(Icons.skip_previous),
                          ),
                        ),

                      // NEXT EPISODE
                      if (widget.episode != null && widget.episodesList != null && widget.episode! < widget.episodesList!.length)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () => _changeEpisode(widget.episode! + 1),
                            child: _buildControlButton(Icons.skip_next),
                          ),
                        ),

                      // ROTATION
                      GestureDetector(
                        onTap: _toggleRotation,
                        child: _buildControlButton(_isLandscape ? Icons.screen_lock_portrait : Icons.screen_lock_landscape),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}