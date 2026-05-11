class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final String releaseYear;
  final double rating;       // New
  final int voteCount;       // New

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseYear,
    required this.rating,
    required this.voteCount,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    String rawDate = json['release_date'] ?? json['first_air_date'] ?? '';
    String parsedYear = rawDate.length >= 4 ? rawDate.substring(0, 4) : 'N/A';

    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? 'Unknown Title',
      overview: json['overview'] ?? 'No description available.',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      releaseYear: parsedYear,
      // Convert num to double safely
      rating: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] ?? 0,
    );
  }

  String get fullPosterUrl => 'https://image.tmdb.org/t/p/w500$posterPath';
  String get fullBackdropUrl => 'https://image.tmdb.org/t/p/w780$backdropPath';
}