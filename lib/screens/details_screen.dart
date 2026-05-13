import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../models/content.dart';
import '../services/tmdb_api.dart';
import '../utils/helpers.dart';
import '../widgets/content_card.dart';
import 'player_screen.dart';
import 'season_selection_screen.dart';

class DetailsScreen extends StatefulWidget {
  final Content movie;
  const DetailsScreen({super.key, required this.movie});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final TmdbApi _api = TmdbApi();
  List<Content> _recommendations = [];
  bool _isLoadingRecommendations = false;

  YoutubePlayerController? _ytController;
  String? _trailerKey;
  bool _isTrailerLoading = true;
  bool _wasPlayingBeforeScroll = false;

  @override
  void initState() {
    super.initState();
    _fetchGenreRecommendations();
    _loadTrailer();
  }

  Future<void> _loadTrailer() async {
    try {
      final key = await _api.getYoutubeKey(widget.movie.id, widget.movie.mediaType);
      if (mounted && key != null) {
        setState(() {
          _trailerKey = key;
          if (Platform.isAndroid || Platform.isIOS) {
            _ytController = YoutubePlayerController(
              initialVideoId: key,
              flags: const YoutubePlayerFlags(autoPlay: false, mute: false, useHybridComposition: true),
            );
          }
        });
      }
    } catch (e) {
      debugPrint("Trailer Error: $e");
    } finally {
      if (mounted) setState(() => _isTrailerLoading = false);
    }
  }

  Future<void> _launchTrailerUrl() async {
    if (_trailerKey == null) return;
    final Uri url = Uri.parse('https://www.youtube.com/watch?v=$_trailerKey');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch YouTube URL');
    }
  }

  Future<void> _fetchGenreRecommendations() async {
    if (widget.movie.genreIds.isEmpty) return;
    if (mounted) setState(() => _isLoadingRecommendations = true);
    try {
      final results = await _api.getDiscoverContent(widget.movie.genreIds[0]);
      if (mounted) {
        setState(() {
          _recommendations = results.where((item) => item.id != widget.movie.id).take(20).toList();
        });
      }
    } catch (e) {
      debugPrint("Recommendation Error: $e");
    } finally {
      if (mounted) setState(() => _isLoadingRecommendations = false);
    }
  }

  @override
  void deactivate() {
    _ytController?.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _ytController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color tmdbPrimaryDark = Color(0xFF0D253F);
    final Color textColor = isDark ? Colors.white : tmdbPrimaryDark;

    if (Platform.isWindows) {
      return _buildMainContent(context, null);
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(controller: _ytController ?? YoutubePlayerController(initialVideoId: '')),
      builder: (context, player) => _buildMainContent(context, player),
    );
  }

  Widget _buildMainContent(BuildContext context, Widget? player) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color tmdbSecondary = Color(0xFF01B4E4);
    const Color tmdbTertiary = Color(0xFF90CEA1);
    const Color tmdbPrimaryDark = Color(0xFF0D253F);
    final Color mainButtonColor = isDark ? tmdbSecondary : tmdbTertiary;
    final Color textColor = isDark ? Colors.white : tmdbPrimaryDark;
    final Color secondaryTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            backgroundColor: isDark ? tmdbPrimaryDark : const Color(0xFFE6E0D4),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/zs_logo_transparent bg.png', height: 45, width: 45, fit: BoxFit.contain),
                const SizedBox(width: 2),
                Text('Zero Stream', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
              ],
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'movie_${widget.movie.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(imageUrl: widget.movie.fullBackdropUrl, fit: BoxFit.cover),
                    const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black54, Colors.transparent, Colors.black87]))),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.movie.title, style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.w900, color: textColor)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.star, color: mainButtonColor, size: 22),
                      const SizedBox(width: 8),
                      Text(widget.movie.rating.toStringAsFixed(1), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(width: 8),
                      Text('(${widget.movie.voteCount} votes)', style: TextStyle(color: secondaryTextColor, fontSize: 13)),
                      const Spacer(),
                      Text(widget.movie.releaseYear, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                    ],
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _ytController?.pause();
                        if (widget.movie.mediaType == 'tv') {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => SeasonSelectionScreen(content: widget.movie)));
                        } else {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(content: widget.movie)));
                        }
                      },
                      icon: Icon(Icons.play_arrow, size: 28, color: isDark ? Colors.white : Colors.black87),
                      label: Text('WATCH NOW', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 15)),
                      style: ElevatedButton.styleFrom(backgroundColor: mainButtonColor, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                  const SizedBox(height: 25),

                  if (!_isTrailerLoading && _trailerKey != null) ...[
                    Text('Official Trailer', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 10),
                    Platform.isWindows
                        ? InkWell(
                      onTap: _launchTrailerUrl,
                      child: Container(
                        height: 220, width: double.infinity,
                        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16), image: DecorationImage(image: CachedNetworkImageProvider(widget.movie.fullBackdropUrl), fit: BoxFit.cover, opacity: 0.5)),
                        child: const Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 70)),
                      ),
                    )
                        : VisibilityDetector(
                      key: Key('trailer-${widget.movie.id}'),
                      onVisibilityChanged: (info) {
                        if (_ytController == null) return;
                        if (info.visibleFraction < 0.2 && _ytController!.value.isPlaying) {
                          _ytController!.pause(); _wasPlayingBeforeScroll = true;
                        } else if (info.visibleFraction > 0.8 && _wasPlayingBeforeScroll) {
                          _ytController!.play(); _wasPlayingBeforeScroll = false;
                        }
                      },
                      child: ClipRRect(borderRadius: BorderRadius.circular(12), child: player ?? const SizedBox()),
                    ),
                    const SizedBox(height: 25),
                  ],

                  Text('Storyline', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 8),
                  Text(widget.movie.overview, style: GoogleFonts.lato(fontSize: 16, height: 1.5, color: secondaryTextColor)),

                  const SizedBox(height: 30), // Gap optimized

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Explore More', style: GoogleFonts.montserrat(fontSize: 19, fontWeight: FontWeight.bold, color: textColor)),
                      if (!_isLoadingRecommendations)
                        IconButton(
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.refresh, color: mainButtonColor, size: 22),
                            onPressed: _fetchGenreRecommendations
                        ),
                    ],
                  ),
                  const SizedBox(height: 12), // Gap reduced between title and cards
                  _isLoadingRecommendations
                      ? const Center(child: CircularProgressIndicator())
                      : GridView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero, // Padding zero for tighter layout
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.62,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14
                    ),
                    itemCount: _recommendations.length,
                    itemBuilder: (context, index) => ContentCard(content: _recommendations[index]),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}