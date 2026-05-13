import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/content.dart';
import '../utils/constants.dart';
import '../services/tmdb_api.dart';

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

  // Update streaming URL based on content type
  void _updateVideoUrl() {
    videoUrl = widget.season != null
        ? '${AppConstants.vidsrcBaseUrl}/embed/tv/${widget.content.id}/${widget.season}/$_currentEpisode'
        : '${AppConstants.vidsrcBaseUrl}/embed/movie/${widget.content.id}';
  }

  // Auto-hide UI controls after 5 seconds
  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _showControls) setState(() => _showControls = false);
    });
  }

  // Toggle UI visibility
  void _handleToggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) _startHideTimer();
    });
  }

  void _playNext() {
    if (widget.episodesList != null && _currentEpisode != null && !_isLoading) {
      if (_currentEpisode! < widget.episodesList!.length) {
        setState(() {
          _isLoading = true;
          _currentEpisode = _currentEpisode! + 1;
          _updateVideoUrl();
          _controller.loadRequest(Uri.parse(videoUrl));
          _showControls = true;
          _startHideTimer();
        });
      }
    }
  }

  void _playPrevious() {
    if (_currentEpisode != null && _currentEpisode! > 1 && !_isLoading) {
      setState(() {
        _isLoading = true;
        _currentEpisode = _currentEpisode! - 1;
        _updateVideoUrl();
        _controller.loadRequest(Uri.parse(videoUrl));
        _showControls = true;
        _startHideTimer();
      });
    }
  }

  // --- WINDOWS LOGIC: BROWSER HUB ---
  Future<void> _handleWindowsLaunch() async {
    await Future.delayed(const Duration(seconds: 1));
    if (widget.content.mediaType == 'movie') {
      await _launchInBrowser(videoUrl);
    } else {
      await _generateAndLaunchHub();
    }
  }

  Future<void> _launchInBrowser(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch $url : $e');
    }
  }

  Future<void> _generateAndLaunchHub() async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/zero_stream_hub.html');
    final TmdbApi api = TmdbApi();

    try {
      final details = await api.getDetails(widget.content.id, 'tv');
      final List seasons = details['seasons'] ?? [];
      String seasonOptions = "";
      String episodesDataJs = "const episodesData = {};\n";

      for (var s in seasons) {
        int sNum = s['season_number'];
        if (sNum == 0) continue;
        seasonOptions += "<option value='$sNum' ${sNum == (widget.season ?? 1) ? 'selected' : ''}>Season $sNum</option>";
        final episodes = await api.getEpisodes(widget.content.id, sNum);
        String epListJs = episodes.map((e) => "{n: ${e['episode_number']}, title: '${e['name'].toString().replaceAll("'", "\\'")}'}").toList().toString();
        episodesDataJs += "episodesData[$sNum] = $epListJs;\n";
      }

      String htmlContent = """
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="referrer" content="no-referrer">
        <title>Zero Stream Hub | ${widget.content.title}</title>
        <style>
          :root { --primary: #01B4E4; --bg: #020d18; --sidebar: #0b1622; --card: rgba(255,255,255,0.05); }
          body { margin: 0; padding: 0; background: var(--bg); color: white; font-family: 'Segoe UI', sans-serif; display: flex; height: 100vh; overflow: hidden; }
          .sidebar { width: 350px; background: var(--sidebar); display: flex; flex-direction: column; border-right: 1px solid rgba(255,255,255,0.1); }
          .header { padding: 30px 20px; border-bottom: 1px solid rgba(255,255,255,0.05); }
          .header h1 { font-size: 1.3rem; margin: 0; color: var(--primary); }
          .season-selector { width: 100%; padding: 12px; margin-top: 15px; background: #1a2a3a; color: white; border: 1px solid var(--primary); border-radius: 8px; cursor: pointer; }
          .ep-list { flex: 1; overflow-y: auto; padding: 15px; }
          .ep-card { background: var(--card); padding: 15px; margin-bottom: 10px; border-radius: 10px; cursor: pointer; transition: 0.3s; display: flex; flex-direction: column; border: 1px solid transparent; }
          .ep-card:hover { background: rgba(1, 180, 228, 0.1); border-color: var(--primary); }
          .ep-card.active { background: linear-gradient(45deg, var(--primary), #005a8d); border: none; }
          .ep-label { font-size: 0.9rem; font-weight: bold; }
          .ep-title { font-size: 0.75rem; color: #abb7c4; margin-top: 4px; }
          .main-view { flex: 1; background: #000; position: relative; }
          iframe { width: 100%; height: 100%; border: none; }
        </style>
      </head>
      <body>
        <div class="sidebar">
          <div class="header"><h1>${widget.content.title}</h1><select class="season-selector" id="seasonSelect" onchange="loadNewSeason(this.value)">$seasonOptions</select></div>
          <div class="ep-list" id="epList"></div>
        </div>
        <div class="main-view"><iframe id="player" allowfullscreen referrerpolicy="no-referrer"></iframe></div>
        <script>
          $episodesDataJs
          const tmdbId = '${widget.content.id}';
          const baseUrl = '${AppConstants.vidsrcBaseUrl}';
          function updateSidebarUI(s, e) {
            document.querySelectorAll('.ep-card').forEach(c => c.classList.remove('active'));
            const activeCard = document.getElementById('ep-' + s + '-' + e);
            if(activeCard) { activeCard.classList.add('active'); activeCard.scrollIntoView({ behavior: 'smooth', block: 'nearest' }); }
          }
          function renderEpisodes(sNum) {
            const list = document.getElementById('epList');
            const episodes = episodesData[sNum] || [];
            let html = "";
            episodes.forEach(ep => {
              html += `<div class="ep-card" id="ep-\${sNum}-\${ep.n}" onclick="play(\${sNum}, \${ep.n}, true)"><span class="ep-label">Episode \${ep.n}</span><span class="ep-title">\${ep.title}</span></div>`;
            });
            list.innerHTML = html;
          }
          function loadNewSeason(sNum) { renderEpisodes(sNum); const firstEp = episodesData[sNum][0].n; play(sNum, firstEp, true); }
          function play(s, e, pushHistory) {
            updateSidebarUI(s, e);
            document.getElementById('player').src = `\${baseUrl}/embed/tv/\${tmdbId}/\${s}/\${e}`;
            if(pushHistory) { history.pushState({ season: s, episode: e }, '', '?s=' + s + '&e=' + e); }
          }
          window.onpopstate = function(event) {
            if(event.state) { document.getElementById('seasonSelect').value = event.state.season; renderEpisodes(event.state.season); play(event.state.season, event.state.episode, false); }
          };
          window.onload = () => {
            const initialS = '${widget.season ?? 1}'; const initialE = '${widget.episode ?? 1}';
            document.getElementById('seasonSelect').value = initialS; renderEpisodes(initialS);
            history.replaceState({ season: initialS, episode: initialE }, '', '?s=' + initialS + '&e=' + initialE);
            play(initialS, initialE, false); 
          };
        </script>
      </body>
      </html>
      """;

      await file.writeAsString(htmlContent);
      await _launchInBrowser('file:///${file.path}');
    } catch (e) { debugPrint("Hub Error: $e"); }
  }

  // --- MOBILE: WEBVIEW LOGIC ---
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
            Positioned.fill(child: Opacity(opacity: 0.3, child: Image.network(widget.content.fullBackdropUrl, fit: BoxFit.cover))),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: const Color(0xFF01B4E4).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.open_in_browser_rounded, size: 80, color: Color(0xFF01B4E4)),
                  ),
                  const SizedBox(height: 30),
                  Text("Playing in External Browser", style: GoogleFonts.montserrat(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  const Text("Please check your default browser for the video player.", style: TextStyle(color: Colors.white70, fontSize: 16), textAlign: TextAlign.center),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 250,
                    child: LinearProgressIndicator(backgroundColor: Colors.white10, color: const Color(0xFF01B4E4), minHeight: 6, borderRadius: BorderRadius.circular(10)),
                  ),
                ],
              ),
            ),
            Positioned(top: 30, left: 30, child: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 28), onPressed: () => Navigator.pop(context))),
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

          // Invisible toggle layer (Top only)
          Positioned(top: 0, left: 0, right: 0, height: 70, child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: _handleToggleControls, child: Container(color: Colors.transparent))),

          if (_isLoading) const Center(child: CircularProgressIndicator(color: Color(0xFF01B4E4))),

          IgnorePointer(
            ignoring: !_showControls,
            child: AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: SafeArea(
                child: Stack(
                  children: [
                    // Back & Title
                    Positioned(
                      top: 15, left: 20,
                      child: Row(
                        children: [
                          _controlCircle(Icons.arrow_back_ios_new, () => Navigator.pop(context), isBack: true),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: Text(displayTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                    // Next/Prev
                    if (widget.season != null)
                      Positioned(
                        top: 15, right: 25,
                        child: Row(
                          children: [
                            _controlCircle(Icons.skip_previous_rounded, (_currentEpisode! > 1 && !_isLoading) ? _playPrevious : null),
                            const SizedBox(width: 20),
                            _controlCircle(Icons.skip_next_rounded, (widget.episodesList != null && _currentEpisode! < widget.episodesList!.length && !_isLoading) ? _playNext : null),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlCircle(IconData icon, VoidCallback? onTap, {bool isBack = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isBack ? 8 : 9),
        decoration: BoxDecoration(color: onTap != null ? Colors.black87 : Colors.black26, shape: BoxShape.circle),
        child: Icon(icon, color: onTap != null ? Colors.white : Colors.white12, size: isBack ? 22 : 27),
      ),
    );
  }
}