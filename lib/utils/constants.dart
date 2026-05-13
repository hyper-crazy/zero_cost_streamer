class AppConstants {
  // API and Streaming Base URLs
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String vidsrcBaseUrl = 'https://vidsrc.icu';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  // TMDB API Key for fetching data (Series/Seasons/Episodes)
  static const String tmdbApiKey = 'TMDB_API_KEY';

  // Allowed domains for WebView navigation filter
  static const List<String> trustedStreamingDomains = [
    'vidsrc',
    'vidplay',
    '2embed',
    'mcloud',
    'cloudnest',
    'vizcloud',
    'filemoon',
  ];

  // App Theme Colors
  static const int primaryColor = 0xFF01B4E4;
  static const int backgroundColor = 0xFF0D253F;
}