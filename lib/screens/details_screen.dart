import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../models/content.dart';
import '../services/tmdb_api.dart';
import '../widgets/content_card.dart';
import '../providers/content_provider.dart';
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
    if (Platform.isWindows) return _buildMainContent(context, null);

    return YoutubePlayerBuilder(
      player: YoutubePlayer(controller: _ytController ?? YoutubePlayerController(initialVideoId: '')),
      builder: (context, player) => _buildMainContent(context, player),
    );
  }

  Widget _buildMainContent(BuildContext context, Widget? player) {
    final provider = Provider.of<ContentProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bool isWatching = provider.isWatching(widget.movie.id);
    final bool isCompleted = provider.isCompleted(widget.movie.id);

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
                decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {
                  if (value == 'completed') {
                    provider.markAsCompleted(widget.movie);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Marked as Completed!")));
                  } else if (value == 'remove_completed') {
                    provider.removeFromCompleted(widget.movie);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Removed from Completed!")));
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  if (!isCompleted)
                    const PopupMenuItem<String>(value: 'completed', child: Text('Mark as Completed')),
                  if (isCompleted)
                    const PopupMenuItem<String>(value: 'remove_completed', child: Text('Remove from Completed')),
                ],
              ),
            ],
            backgroundColor: isDark ? tmdbPrimaryDark : const Color(0xFFE6E0D4),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/zs_logo_transparent bg.png', height: 40),
                const SizedBox(width: 8),
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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.movie.title, style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.w900, color: textColor)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.star, color: mainButtonColor, size: 20),
                      const SizedBox(width: 6),
                      Text(widget.movie.rating.toStringAsFixed(1), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(width: 8),
                      Text('(${widget.movie.voteCount} votes)', style: TextStyle(color: secondaryTextColor, fontSize: 13)),
                      const SizedBox(width: 12),
                      Text(widget.movie.releaseYear, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        flex: 8,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _ytController?.pause();
                            provider.addToWatching(widget.movie);
                            if (Platform.isWindows) {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(content: widget.movie)));
                            } else {
                              if (widget.movie.mediaType == 'tv') {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => SeasonSelectionScreen(content: widget.movie)));
                              } else {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(content: widget.movie)));
                              }
                            }
                          },
                          icon: const Icon(Icons.play_arrow, size: 28),
                          label: Text(isCompleted ? 'REWATCH' : 'WATCH NOW', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainButtonColor,
                            foregroundColor: isDark ? Colors.white : Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: isCompleted ? null : () {
                            if (isWatching) {
                              showDialog(context: context, builder: (ctx) => AlertDialog(
                                title: const Text("Remove from Watching?"),
                                content: const Text("Do you want to remove this content?"),
                                actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("No")), TextButton(onPressed: () { provider.removeFromWatching(widget.movie); Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Removed from Watching list!"))); }, child: const Text("Yes"))],
                              ));
                            } else {
                              provider.addToWatching(widget.movie);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Added to Watching list!")));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: mainButtonColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: isCompleted ? Colors.green : mainButtonColor),
                            ),
                          ),
                          child: Icon(
                              isCompleted ? Icons.check_circle : (isWatching ? Icons.bookmark : Icons.bookmark_add_outlined),
                              size: 28,
                              color: isCompleted ? Colors.green : mainButtonColor
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  Text('Official Trailer', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 12),
                  if (_isTrailerLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_trailerKey == null)
                    Container(
                      height: 200, width: double.infinity,
                      decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(16)),
                      child: Center(child: Text("Trailer not available for this content", style: TextStyle(color: secondaryTextColor))),
                    )
                  else
                    Platform.isWindows
                        ? InkWell(
                      onTap: _launchTrailerUrl,
                      child: Container(
                        height: 200, width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(image: CachedNetworkImageProvider(widget.movie.fullBackdropUrl), fit: BoxFit.cover, opacity: 0.4),
                          color: Colors.black,
                        ),
                        child: const Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 64)),
                      ),
                    )
                        : VisibilityDetector(
                      key: Key('trailer-${widget.movie.id}'),
                      onVisibilityChanged: (info) {
                        if (_ytController == null) return;
                        if (info.visibleFraction < 0.2 && _ytController!.value.isPlaying) {
                          _ytController!.pause();
                          _wasPlayingBeforeScroll = true;
                        } else if (info.visibleFraction > 0.8 && _wasPlayingBeforeScroll) {
                          _ytController!.play();
                          _wasPlayingBeforeScroll = false;
                        }
                      },
                      child: ClipRRect(borderRadius: BorderRadius.circular(12), child: player ?? const SizedBox()),
                    ),

                  const SizedBox(height: 32),

                  Text('Storyline', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 12),
                  Text(widget.movie.overview, style: GoogleFonts.lato(fontSize: 16, height: 1.6, color: secondaryTextColor)),

                  const SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Explore More', style: GoogleFonts.montserrat(fontSize: 19, fontWeight: FontWeight.bold, color: textColor)),
                      if (!_isLoadingRecommendations)
                        IconButton(icon: Icon(Icons.refresh, color: mainButtonColor), onPressed: _fetchGenreRecommendations),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _isLoadingRecommendations
                      ? const Center(child: CircularProgressIndicator())
                      : GridView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 16, mainAxisSpacing: 16,
                    ),
                    itemCount: _recommendations.length,
                    itemBuilder: (context, index) => ContentCard(content: _recommendations[index]),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}