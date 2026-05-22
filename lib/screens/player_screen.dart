import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/content.dart';
import '../utils/constants.dart';
import '../services/tmdb_api.dart';
import '../services/hub_generator.dart';
import '../providers/content_provider.dart';

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
  bool _showControls = true;
  bool _isBrowserOpened = false;
  Timer? _hideTimer;
  int? _currentEpisode;
  late String videoUrl;

  @override
  void initState() {
    super.initState();
    _currentEpisode = widget.episode;
    _updateVideoUrl();

    if (Platform.isAndroid || Platform.isIOS) {
      _setLandscape();
      _initMobileController();
      _startHideTimer();
    } else if (Platform.isWindows) {
      _handleWindowsLaunch();
    }
  }

  void _updateVideoUrl() {
    videoUrl = widget.season != null
        ? '${AppConstants.vidsrcBaseUrl}/embed/tv/${widget.content.id}/${widget.season}/$_currentEpisode'
        : '${AppConstants.vidsrcBaseUrl}/embed/movie/${widget.content.id}';
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _showControls) setState(() => _showControls = false);
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    } else {
      _hideTimer?.cancel();
    }
  }

  // Back action with auto-update tracker
  void _onBackPress() {
    if (widget.season != null) {
      Provider.of<ContentProvider>(context, listen: false)
          .updateLastEpisode(widget.content.id, "S${widget.season} E$_currentEpisode");
    }
    Navigator.pop(context);
  }

  void _showEpisodesBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false, initialChildSize: 0.6, maxChildSize: 0.9, minChildSize: 0.4,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 10),
                Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 15),
                Text("Season ${widget.season} Episodes", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Divider(color: Colors.white12, thickness: 1),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: widget.episodesList!.length,
                    itemBuilder: (context, index) {
                      final ep = widget.episodesList![index];
                      final epNum = ep['episode_number'];
                      final epTitle = ep['name'];
                      bool isActive = epNum == _currentEpisode;
                      return ListTile(
                        tileColor: isActive ? Colors.white.withOpacity(0.05) : Colors.transparent,
                        leading: Text("$epNum", style: TextStyle(color: isActive ? const Color(0xFF01B4E4) : Colors.white54, fontSize: 18, fontWeight: FontWeight.bold)),
                        title: Text(epTitle, style: TextStyle(color: isActive ? Colors.white : Colors.white70)),
                        trailing: isActive ? const Icon(Icons.circle, size: 8, color: Color(0xFF01B4E4)) : null,
                        onTap: () {
                          Navigator.pop(context);
                          if (!isActive) {
                            setState(() {
                              _isLoading = true;
                              _currentEpisode = epNum;
                              _updateVideoUrl();
                              _controller.loadRequest(Uri.parse(videoUrl));
                            });
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleWindowsLaunch() async {
    setState(() => _isBrowserOpened = false);
    await Future.delayed(const Duration(seconds: 1));
    if (widget.content.mediaType == 'movie') {
      await launchUrl(Uri.parse(videoUrl), mode: LaunchMode.externalApplication);
    } else {
      await HubGenerator.generateAndLaunch(widget.content, widget.season, widget.episode);
    }
    setState(() => _isBrowserOpened = true);
  }

  void _initMobileController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setUserAgent("Mozilla/5.0 (Linux; Android 14; SM-S928B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36")
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final url = request.url.toLowerCase();
            if (AppConstants.trustedStreamingDomains.any((d) => url.contains(d.toLowerCase()))) return NavigationDecision.navigate;
            return NavigationDecision.prevent;
          },
          onPageStarted: (s) => setState(() => _isLoading = true),
          onPageFinished: (s) {
            setState(() => _isLoading = false);
            _controller.runJavaScript("""
              (function() {
                var style = document.createElement('style');
                style.innerHTML = '#overlay, .ads, .ad-box, .pop-under, .pop-up, [class*="ad-"], [id*="ad-"], iframe[src*="ads"] { display: none !important; pointer-events: none !important; }';
                document.head.appendChild(style);
                window.open = function() { return null; };
              })();
            """);
          },
        ),
      )
      ..loadRequest(Uri.parse(videoUrl));
  }

  void _setLandscape() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    if (Platform.isAndroid || Platform.isIOS) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(child: Image.network(widget.content.fullBackdropUrl, fit: BoxFit.cover)),
            Positioned.fill(child: Container(color: Colors.black.withOpacity(0.85))),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_isBrowserOpened) ...[
                    const SizedBox(width: 60, height: 60, child: CircularProgressIndicator(color: Color(0xFF01B4E4), strokeWidth: 4)),
                    const SizedBox(height: 20),
                    Text("Opening external hub...", style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16)),
                  ] else ...[
                    const Icon(Icons.desktop_windows_outlined, size: 80, color: Color(0xFF01B4E4)),
                    const SizedBox(height: 20),
                    Text("Video playing in external browser", style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                  ]
                ],
              ),
            ),
            Positioned(top: 30, left: 30, child: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 28), onPressed: _onBackPress)),
          ],
        ),
      );
    }

    String displayTitle = widget.content.title + (widget.season != null ? " (S${widget.season} E$_currentEpisode)" : " (${widget.content.releaseYear})");

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: WebViewWidget(controller: _controller)),

          Positioned(
            top: 0, left: 0, right: 0, height: 100,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _toggleControls,
              child: Container(color: Colors.transparent),
            ),
          ),

          IgnorePointer(
            ignoring: !_showControls,
            child: AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                  ),
                ),
                child: SafeArea(
                  child: Stack(
                    children: [
                      Positioned(
                        top: 15, left: 20,
                        child: Row(
                          children: [
                            _controlCircle(Icons.arrow_back_ios_new, _onBackPress, isBack: true),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Text(displayTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                      if (widget.season != null)
                        Positioned(
                          top: 15, right: 25,
                          child: _controlCircle(Icons.video_library_rounded, _showEpisodesBottomSheet),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (_isLoading) const Center(child: CircularProgressIndicator(color: Color(0xFF01B4E4))),
        ],
      ),
    );
  }

  Widget _controlCircle(IconData icon, VoidCallback? onTap, {bool isBack = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isBack ? 8 : 9),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.15), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: isBack ? 22 : 27),
      ),
    );
  }
}