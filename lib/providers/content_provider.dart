import 'package:flutter/material.dart';
import '../models/content.dart';
import '../services/tmdb_api.dart';

class ContentProvider with ChangeNotifier {
  final TmdbApi _api = TmdbApi();

  List<Content> trendingContent = [];

  // This alias prevents the "trendingMovies isn't defined" error in your Home Screen
  List<Content> get trendingMovies => trendingContent;

  int _currentPage = 1;
  bool isLoading = false;
  bool isFetchingNextPage = false;

  Future<void> fetchTrending() async {
    _currentPage = 1;
    isLoading = true;
    notifyListeners();
    try {
      trendingContent = await _api.getTrending(page: _currentPage);
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
      final newContent = await _api.getTrending(page: _currentPage);
      if (newContent.isNotEmpty) {
        trendingContent.addAll(newContent);
      }
    } catch (e) {
      debugPrint("Error in fetchNextPage: $e");
    } finally {
      isFetchingNextPage = false;
      notifyListeners();
    }
  }
}