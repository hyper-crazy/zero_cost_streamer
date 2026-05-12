import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/content.dart';
import '../services/tmdb_api.dart';
import 'player_screen.dart';

class SeasonSelectionScreen extends StatefulWidget {
  final Content content;
  const SeasonSelectionScreen({super.key, required this.content});

  @override
  State<SeasonSelectionScreen> createState() => _SeasonSelectionScreenState();
}

class _SeasonSelectionScreenState extends State<SeasonSelectionScreen> {
  final TmdbApi _api = TmdbApi();
  List<dynamic> seasons = [];
  List<dynamic> episodes = [];
  int? selectedSeason;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSeasons();
  }

  void _loadSeasons() async {
    var data = await _api.getSeasons(widget.content.id);
    setState(() {
      seasons = data.where((s) => s['season_number'] != 0).toList();
      if (seasons.isNotEmpty) {
        selectedSeason = seasons[0]['season_number'];
        _loadEpisodes(selectedSeason!);
      }
    });
  }

  void _loadEpisodes(int seasonNum) async {
    setState(() => isLoading = true);
    var data = await _api.getEpisodes(widget.content.id, seasonNum);
    setState(() {
      episodes = data;
      isLoading = false;
    });
  }

  void _showSeasonPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // DEFINING BOTH THEMES SIMULTANEOUSLY
    const Color tmdbSecondary = Color(0xFF01B4E4); // Blue (Dark Mode)
    const Color tmdbTertiary = Color(0xFF90CEA1);  // Green (Light Mode)
    const Color tmdbPrimaryDark = Color(0xFF0D253F);
    const Color coffeeCream = Color(0xFFE6E0D4);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // Key: to allow proper height calculation
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: SafeArea( // Fixed: Ensure it respects bottom nav bar
          child: Container(
            margin: const EdgeInsets.only(top: 100), // fixed height container
            decoration: BoxDecoration(
              color: isDark
                  ? tmdbPrimaryDark.withOpacity(0.9)
                  : coffeeCream.withOpacity(0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2)
                    )
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    itemCount: seasons.length,
                    itemBuilder: (context, index) {
                      final s = seasons[index];
                      final int sNum = s['season_number'];
                      final bool isSelected = selectedSeason == sNum;

                      // APPLYING BOTH MODES IN THE SELECTION TILE
                      final Color activeColor = isDark ? tmdbSecondary : tmdbTertiary;
                      final Color inactiveColor = isDark ? Colors.white60 : tmdbPrimaryDark.withOpacity(0.6);

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                        title: Text(
                          "Season $sNum",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                            fontSize: isSelected ? 18 : 16,
                            color: isSelected ? activeColor : inactiveColor,
                          ),
                        ),
                        tileColor: isSelected
                            ? activeColor.withOpacity(0.1)
                            : Colors.transparent,
                        onTap: () {
                          setState(() {
                            selectedSeason = sNum;
                            _loadEpisodes(sNum);
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const Color tmdbPrimaryDark = Color(0xFF0D253F);
    const Color tmdbSecondary = Color(0xFF01B4E4);
    const Color tmdbTertiary = Color(0xFF90CEA1);
    const Color coffeeCream = Color(0xFFE6E0D4);

    final Color tintLayerColor = isDark ? tmdbPrimaryDark : coffeeCream;
    final Color iconAccentColor = isDark ? tmdbSecondary : tmdbTertiary;
    final Color textColor = isDark ? Colors.white : tmdbPrimaryDark;
    final Color subTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          widget.content.title,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, fontSize: 18, color: textColor),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // LAYER 1: POSTER (FOR BOTH MODES)
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: widget.content.fullPosterUrl,
              fit: BoxFit.cover,
            ),
          ),

          // LAYER 2: BLUR (FOR BOTH MODES)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: const SizedBox.expand(),
            ),
          ),

          // LAYER 3: DYNAMIC TINT
          Positioned.fill(
            child: Container(
              color: tintLayerColor.withOpacity(0.75),
            ),
          ),

          // LAYER 4: WATERMORPHISM CONTENT
          isLoading
              ? Center(child: CircularProgressIndicator(color: iconAccentColor))
              : ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 60, 16, 130),
            itemCount: episodes.length,
            itemBuilder: (context, index) {
              final ep = episodes[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.03) : Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.4),
                      width: 1.5
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withOpacity(0.25) : Colors.black.withOpacity(0.05),
                      blurRadius: 20, spreadRadius: -4, offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      leading: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(width: 48, height: 48, color: iconAccentColor.withOpacity(0.15)),
                          ),
                          Icon(Icons.play_circle_fill, color: iconAccentColor, size: 38),
                        ],
                      ),
                      title: Text(
                          "Episode ${ep['episode_number']}",
                          style: GoogleFonts.montserrat(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)
                      ),
                      subtitle: Text(
                          ep['name'] ?? 'Untitled Episode',
                          style: GoogleFonts.lato(color: subTextColor, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 14, color: subTextColor),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(content: widget.content, season: selectedSeason, episode: ep['episode_number'], episodesList: episodes)));
                      },
                    ),
                  ),
                ),
              );
            },
          ),

          // LAYER 5: BOTTOM BAR (WATERMORPHISM FIX APPLIED)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: ClipRRect(
              // Key Fix Layer:
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  color: Colors.transparent, // Solid blue background layer remove korsi
                  child: ElevatedButton(
                    onPressed: _showSeasonPicker,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: iconAccentColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            "Season $selectedSeason",
                            style: GoogleFonts.montserrat(
                                color: isDark ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold
                            )
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.unfold_more, color: isDark ? Colors.black : Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}