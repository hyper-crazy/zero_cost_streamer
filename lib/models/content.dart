class Content {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final String releaseYear;
  final double rating;
  final int voteCount;
  final String mediaType;
  final List<int> genreIds;

  Content({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseYear,
    required this.rating,
    required this.voteCount,
    required this.mediaType,
    required this.genreIds,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    // Extract year from release_date (Movie) or first_air_date (TV)
    String rawDate = json['release_date'] ?? json['first_air_date'] ?? '';
    String parsedYear = rawDate.length >= 4 ? rawDate.substring(0, 4) : 'N/A';

    // Determine media type based on available keys or explicit media_type field
    String determinedType = json['media_type'] ?? (json['title'] != null ? 'movie' : 'tv');

    return Content(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? 'Unknown Title',
      overview: json['overview'] ?? 'No description available.',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      releaseYear: parsedYear,
      rating: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] ?? 0,
      mediaType: determinedType,
      genreIds: List<int>.from(json['genre_ids'] ?? []),
    );
  }

  // TMDB Image URL helpers
  String get fullPosterUrl => 'https://image.tmdb.org/t/p/w500$posterPath';
  String get fullBackdropUrl => 'https://image.tmdb.org/t/p/w1280$backdropPath';
}