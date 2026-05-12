class AppConstants {
  // API and Streaming Base URLs
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String vidsrcBaseUrl = 'https://vidsrc.icu';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  // Trusted domains list for WebView navigation filtering
  static const List<String> trustedStreamingDomains = [
    'vidsrc',
    'vidplay',
    '2embed',
    'mcloud',
    'cloudnest',
    'vizcloud',
    'filemoon',
  ];

  // Core Theme Colors (TMDB Palette)
  static const int primaryColor = 0xFF01B4E4;
  static const int backgroundColor = 0xFF0D253F;
}