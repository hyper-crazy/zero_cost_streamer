class Content {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final String releaseYear;
  final double rating;
  final int voteCount;
  final String mediaType; // Added to distinguish movie vs tv

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
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    String rawDate = json['release_date'] ?? json['first_air_date'] ?? '';
    String parsedYear = rawDate.length >= 4 ? rawDate.substring(0, 4) : 'N/A';

    return Content(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? 'Unknown Title',
      overview: json['overview'] ?? 'No description available.',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      releaseYear: parsedYear,
      rating: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] ?? 0,
      mediaType: json['media_type'] ?? 'movie',
    );
  }

  String get fullPosterUrl => 'https://image.tmdb.org/t/p/w500$posterPath';
  String get fullBackdropUrl => 'https://image.tmdb.org/t/p/w1280$backdropPath';
}