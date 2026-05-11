import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/content.dart';

class TmdbApi {
  final String apiKey = dotenv.env['TMDB_API_KEY'] ?? '';
  final String baseUrl = 'https://api.themoviedb.org/3';

  // Home screen er trending er jonno page already ase
  Future<List<Content>> getTrending({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/trending/all/day?api_key=$apiKey&page=$page'),
    );
    if (response.statusCode == 200) {
      List data = json.decode(response.body)['results'];
      return data.where((item) => item['poster_path'] != null)
          .map((item) => Content.fromJson(item)).toList();
    }
    throw Exception('Failed to load trending content');
  }

  // --- SEARCH METHOD UPDATE: 'page' parameter add kora hoise ---
  Future<List<Content>> searchContent(String query, {int page = 1}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/search/multi?api_key=$apiKey&query=${Uri.encodeComponent(query)}&page=$page'),
    );

    if (response.statusCode == 200) {
      List data = json.decode(response.body)['results'];
      return data.where((item) =>
      (item['media_type'] == 'movie' || item['media_type'] == 'tv') &&
          item['poster_path'] != null)
          .map((item) => Content.fromJson(item)).toList();
    } else {
      throw Exception('Search failed');
    }
  }

  // Seasons ar Episodes logic age ja chhilo tai thakbe...
  Future<List<dynamic>> getSeasons(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/tv/$id?api_key=$apiKey'));
    return response.statusCode == 200 ? json.decode(response.body)['seasons'] : [];
  }

  Future<List<dynamic>> getEpisodes(int id, int seasonNum) async {
    final response = await http.get(Uri.parse('$baseUrl/tv/$id/season/$seasonNum?api_key=$apiKey'));
    return response.statusCode == 200 ? json.decode(response.body)['episodes'] : [];
  }
}