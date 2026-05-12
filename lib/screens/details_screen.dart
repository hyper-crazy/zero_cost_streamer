import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/content.dart';
import 'player_screen.dart';
import 'season_selection_screen.dart';

class DetailsScreen extends StatelessWidget {
  final Content movie;
  const DetailsScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // TMDB Branding Colors
    const Color tmdbSecondary = Color(0xFF01B4E4);
    const Color tmdbTertiary = Color(0xFF90CEA1);
    const Color tmdbPrimaryDark = Color(0xFF0D253F);

    final Color mainButtonColor = isDark ? tmdbSecondary : tmdbTertiary;
    final Color textColor = isDark ? Colors.white : tmdbPrimaryDark;
    final Color secondaryTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Dynamic AppBar with Zero Stream Branding
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            leading: BackButton(color: Colors.white), // Image-er upore back button visible thakbe
            backgroundColor: isDark ? tmdbPrimaryDark : Colors.white,

            // Scroll korle AppBar-e tor logo show korbe
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/zs_logo_transparent bg.png',
                  height: 45,
                  width: 45,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
                const SizedBox(width: 2),
                Text(
                  'Zero Stream',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),

            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'movie_${movie.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: movie.fullBackdropUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                    ),
                    // Shadow overlay for readability
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black54, Colors.transparent, Colors.black87],
                        ),
                      ),
                    ),
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
                  // Movie Title
                  Text(
                    movie.title,
                    style: GoogleFonts.montserrat(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: textColor
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Rating & Release Info
                  Row(
                    children: [
                      Icon(Icons.star, color: mainButtonColor, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        movie.rating.toStringAsFixed(1),
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      const SizedBox(width: 8),
                      Text('(${movie.voteCount} votes)', style: TextStyle(color: secondaryTextColor)),
                      const Spacer(),
                      Text(movie.releaseYear, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Watch Now Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (movie.mediaType == 'tv') {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 400),
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  SeasonSelectionScreen(content: movie),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.1),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuart)),
                                  child: FadeTransition(opacity: animation, child: child),
                                );
                              },
                            ),
                          );
                        } else {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerScreen(content: movie)));
                        }
                      },
                      icon: Icon(Icons.play_arrow, size: 32, color: isDark ? Colors.white : Colors.black87),
                      label: Text(
                        'WATCH NOW',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainButtonColor,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                  Text('Storyline', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 12),
                  Text(
                    movie.overview,
                    style: GoogleFonts.lato(fontSize: 17, height: 1.6, color: secondaryTextColor),
                  ),

                  const SizedBox(height: 40),

                  // TMDB Legal Attribution
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/TMDB_attribution.svg',
                          height: 20,
                          colorFilter: const ColorFilter.mode(tmdbSecondary, BlendMode.srcIn),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "This product uses the TMDB API but is not endorsed or certified by TMDB.",
                            style: GoogleFonts.lato(
                              fontSize: 11,
                              color: secondaryTextColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}