import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/content.dart';

class TmdbApi {
  final String apiKey = dotenv.env['TMDB_API_KEY'] ?? '';
  final String baseUrl = 'https://api.themoviedb.org/3';

  // 1. Trending
  Future<List<Content>> getTrending({int page = 1}) async {
    final response = await http.get(Uri.parse('$baseUrl/trending/all/day?api_key=$apiKey&page=$page'));
    if (response.statusCode == 200) {
      List data = json.decode(response.body)['results'];
      return data.where((item) => item['poster_path'] != null).map((item) => Content.fromJson(item)).toList();
    }
    throw Exception('Failed trending');
  }

  // 2. Discover with Strict Sorting Logic
  Future<List<Content>> getDiscoverContent(
      int? genreId, {
        int page = 1,
        String type = 'movie',
        String sortBy = 'popularity.desc',
        int minVoteCount = 0,
        String? year,
        double? minRating,
        double? maxRating,
        String? withGenres,
      }) async {
    String urlType = (type == 'all') ? 'movie' : type;

    // --- STRICT SORTING FIX ---
    // TMDB movies use 'primary_release_date', but TV uses 'first_air_date'.
    String finalSort = sortBy;
    if (sortBy.contains('primary_release_date')) {
      finalSort = (urlType == 'movie') ? sortBy : sortBy.replaceAll('primary_release_date', 'first_air_date');
    }

    String yearParam = (urlType == 'movie') ? 'primary_release_year' : 'first_air_date_year';

    String url = '$baseUrl/discover/$urlType?api_key=$apiKey&page=$page&sort_by=$finalSort&vote_count.gte=$minVoteCount';

    if (year != null && year != 'All') url += '&$yearParam=$year';
    if (minRating != null) url += '&vote_average.gte=$minRating';
    if (maxRating != null) url += '&vote_average.lte=$maxRating';
    if (withGenres != null) url += '&with_genres=$withGenres';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List data = json.decode(response.body)['results'];
      return data.where((item) => item['poster_path'] != null).map((item) => Content.fromJson(item)).toList();
    }
    throw Exception('Failed discover');
  }

  // 3. Search
  Future<List<Content>> searchContent(String query, {int page = 1}) async {
    final response = await http.get(Uri.parse('$baseUrl/search/multi?api_key=$apiKey&query=${Uri.encodeComponent(query)}&page=$page'));
    if (response.statusCode == 200) {
      List data = json.decode(response.body)['results'];
      return data.where((item) => (item['media_type'] == 'movie' || item['media_type'] == 'tv') && item['poster_path'] != null).map((item) => Content.fromJson(item)).toList();
    }
    throw Exception('Search failed');
  }

  // 4. Genres
  Future<Map<int, String>> getGenreList(String type) async {
    String urlType = (type == 'all') ? 'movie' : type;
    final response = await http.get(Uri.parse('$baseUrl/genre/$urlType/list?api_key=$apiKey'));
    if (response.statusCode == 200) {
      List genres = json.decode(response.body)['genres'];
      return {for (var g in genres) g['id']: g['name']};
    }
    return {};
  }

  // 5. TV Data Restoration
  Future<List<dynamic>> getSeasons(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/tv/$id?api_key=$apiKey'));
    return (response.statusCode == 200) ? json.decode(response.body)['seasons'] ?? [] : [];
  }

  Future<List<dynamic>> getEpisodes(int id, int seasonNum) async {
    final response = await http.get(Uri.parse('$baseUrl/tv/$id/season/$seasonNum?api_key=$apiKey'));
    return (response.statusCode == 200) ? json.decode(response.body)['episodes'] ?? [] : [];
  }
}