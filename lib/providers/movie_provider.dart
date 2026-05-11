import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/tmdb_api.dart';

class MovieProvider with ChangeNotifier {
  final TmdbApi _api = TmdbApi();

  List<Movie> trendingMovies = [];
  int _currentPage = 1;
  bool isLoading = false;
  bool isFetchingNextPage = false;

  Future<void> fetchTrending() async {
    _currentPage = 1;
    isLoading = true;
    notifyListeners();
    try {
      trendingMovies = await _api.getTrending(page: _currentPage);
    } catch (e) {
      debugPrint("Error in fetchTrending: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNextPage() async {
    if (isFetchingNextPage || isLoading) return;
    isFetchingNextPage = true;
    notifyListeners();
    _currentPage++;
    try {
      final newMovies = await _api.getTrending(page: _currentPage);
      if (newMovies.isNotEmpty) {
        trendingMovies.addAll(newMovies);
      }
    } catch (e) {
      debugPrint("Error in fetchNextPage: $e");
    } finally {
      isFetchingNextPage = false;
      notifyListeners();
    }
  }
}