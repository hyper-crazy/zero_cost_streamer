import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchGenreRecommendations();
  }

  Future<void> _fetchGenreRecommendations() async {
    if (widget.movie.genreIds.isEmpty) return;
    if (mounted) setState(() => _isLoadingRecommendations = true);

    try {
      final results = await _api.getDiscoverContent(widget.movie.genreIds[0]);
      if (mounted) {
        setState(() {
          _recommendations = results
              .where((item) => item.id != widget.movie.id)
              .take(20)
              .toList();
        });
      }
    } catch (e) {
      debugPrint("Error fetching recommendations: $e");
    } finally {
      if (mounted) setState(() => _isLoadingRecommendations = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            leading: const BackButton(color: Colors.white),
            backgroundColor: isDark ? tmdbPrimaryDark : Colors.white,
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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.movie.title, style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.w900, color: textColor)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.star, color: mainButtonColor, size: 24),
                      const SizedBox(width: 8),
                      Text(widget.movie.rating.toStringAsFixed(1), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(width: 8),
                      Text('(${widget.movie.voteCount} votes)', style: TextStyle(color: secondaryTextColor)),
                      const Spacer(),
                      Text(widget.movie.releaseYear, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: widget.movie.genreIds.map((id) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                      ),
                      child: Text(AppHelpers.getGenreName(id), style: GoogleFonts.montserrat(fontSize: 12, color: secondaryTextColor, fontWeight: FontWeight.w600)),
                    )).toList(),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (widget.movie.mediaType == 'tv') {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => SeasonSelectionScreen(content: widget.movie)));
                        } else {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(content: widget.movie)));
                        }
                      },
                      icon: Icon(Icons.play_arrow, size: 32, color: isDark ? Colors.white : Colors.black87),
                      label: Text('WATCH NOW', style: TextStyle(color: isDark ? Colors.white : Colors.black87, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: mainButtonColor, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text('Storyline', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 12),
                  Text(widget.movie.overview, style: GoogleFonts.lato(fontSize: 17, height: 1.6, color: secondaryTextColor)),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        SvgPicture.asset('assets/images/TMDB_attribution.svg', height: 20, colorFilter: const ColorFilter.mode(tmdbSecondary, BlendMode.srcIn)),
                        const SizedBox(width: 12),
                        Expanded(child: Text("This product uses the TMDB API but is not endorsed or certified by TMDB.", style: GoogleFonts.lato(fontSize: 11, color: secondaryTextColor, fontStyle: FontStyle.italic))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Explore More Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Explore More', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                      if (!_isLoadingRecommendations)
                        IconButton(icon: Icon(Icons.refresh, color: mainButtonColor), onPressed: _fetchGenreRecommendations),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _isLoadingRecommendations
                      ? const Center(child: CircularProgressIndicator())
                      : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.60,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _recommendations.length,
                    itemBuilder: (context, index) => ContentCard(content: _recommendations[index]),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}