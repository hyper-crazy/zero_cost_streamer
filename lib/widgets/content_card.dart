import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/content.dart';
import '../screens/details_screen.dart';

class ContentCard extends StatelessWidget {
  final Content content;
  const ContentCard({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0D253F);
    final subTextColor = isDark ? Colors.white60 : Colors.black54;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 250),
            pageBuilder: (context, animation, secondaryAnimation) => DetailsScreen(movie: content),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero)
                      .animate(CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn)),
                  child: child,
                ),
              );
            },
          ),
        );
      },
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Hero(
                  tag: 'movie_${content.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: content.fullPosterUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6), // Gap komano hoise layout thik korte
              Text(
                content.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 13, // Standard kora hoise common usage er jonno
                  color: textColor,
                ),
              ),
              Text(
                '(${content.releaseYear})',
                style: GoogleFonts.montserrat(
                  color: subTextColor,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          // TYPE TAG (SERIES / MOVIE)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: content.mediaType == 'tv' ? const Color(0xFF90CEA1) : const Color(0xFF01B4E4),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                content.mediaType == 'tv' ? 'SERIES' : 'MOVIE',
                style: const TextStyle(color: Colors.black87, fontSize: 7, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // RATING BADGE
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primaryColor.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: primaryColor, size: 10),
                  const SizedBox(width: 4),
                  Text(
                    content.rating.toStringAsFixed(1),
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}