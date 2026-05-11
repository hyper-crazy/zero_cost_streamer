import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/movie.dart';

class TmdbApi {
  static final String _apiKey = dotenv.env['TMDB_API_KEY'] ?? '';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  // Added optional page parameter (defaults to 1)
  Future<List<Movie>> getTrending({int page = 1}) async {
    final url = Uri.parse('$_baseUrl/trending/all/day?api_key=$_apiKey&page=$page');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load trending data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Added optional page parameter for search
  Future<List<Movie>> searchQuery(String query, {int page = 1}) async {
    final url = Uri.parse('$_baseUrl/search/multi?api_key=$_apiKey&query=$query&page=$page');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        final filteredResults = results.where((item) => item['media_type'] != 'person').toList();
        return filteredResults.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}