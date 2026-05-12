import 'dart:math';
import 'package:flutter/material.dart';
import '../models/content.dart';
import '../services/tmdb_api.dart';

class ContentProvider with ChangeNotifier {
  final TmdbApi _api = TmdbApi();
  final Map<String, List<Content>> _cacheGridData = {};
  final Map<String, int> _pageTracker = {};
  List<Content> _sliderContent = [];
  bool _isLoading = false;
  bool _isFetchingNextPage = false;
  String _currentFilter = 'All';

  List<Content> get gridContent => _cacheGridData[_currentFilter] ?? [];
  List<Content> get sliderContent => _sliderContent;
  bool get isLoading => _isLoading;
  bool get isFetchingNextPage => _isFetchingNextPage;

  // Weighted Rating Calculation (IMDb Style)
  double _calculateWeightedScore(Content content, int minVotes) {
    double v = content.voteCount.toDouble();
    double m = minVotes.toDouble();
    double R = content.rating;
    double C = 7.0; // Average rating across the platform

    if (v < m) return R * (v / m); // Penalty for very low votes
    return (v / (v + m) * R) + (m / (v + m) * C);
  }

  Future<void> initHome() async {
    if (_sliderContent.isNotEmpty) return;
    _isLoading = true;
    notifyListeners();
    try {
      _sliderContent = await _api.getTrending(page: 1);
      await fetchContent(filter: 'All');
    } catch (e) { debugPrint("Error: $e"); }
  }

  Future<void> refreshHome() async {
    _cacheGridData.clear();
    _pageTracker.clear();
    _sliderContent = [];
    await initHome();
  }

  Future<void> fetchContent({required String filter, bool isLoadMore = false}) async {
    _currentFilter = filter;
    if (!isLoadMore && _cacheGridData.containsKey(filter)) {
      notifyListeners();
      return;
    }

    if (isLoadMore) {
      _isFetchingNextPage = true;
      _pageTracker[filter] = (_pageTracker[filter] ?? 1) + 1;
    } else {
      _isLoading = true;
      _pageTracker[filter] = 1;
    }
    notifyListeners();

    try {
      int page = _pageTracker[filter]!;
      List<Content> data = [];

      if (filter == 'Popular') {
        // Popular: Trends are driven by Buzz (High Vote Count + Recent Popularity)
        List<Content> popMovies = await _api.getDiscoverContent(null, type: 'movie', sortBy: 'popularity.desc', page: page);
        List<Content> popTV = await _api.getDiscoverContent(null, type: 'tv', sortBy: 'popularity.desc', page: page);

        data = [...popMovies, ...popTV];
        data.sort((a, b) => b.voteCount.compareTo(a.voteCount));

      } else if (filter == 'Top Rated') {
        // Top Rated: Hall of Fame (Strict Weighted Rating)
        List<Content> topMovies = await _api.getDiscoverContent(null, type: 'movie', sortBy: 'vote_average.desc', page: page, minVoteCount: 500);
        List<Content> topTV = await _api.getDiscoverContent(null, type: 'tv', sortBy: 'vote_average.desc', page: page, minVoteCount: 300);

        data = [...topMovies, ...topTV];
        data.sort((a, b) {
          int m = (a.mediaType == 'movie') ? 1000 : 500;
          return _calculateWeightedScore(b, m).compareTo(_calculateWeightedScore(a, m));
        });

      } else {
        // All, Movies, TV Shows: Mixture logic with Randomization
        List<Content> latest = [];
        if (filter == 'Movies') latest = await _api.getDiscoverContent(null, type: 'movie', page: page);
        else if (filter == 'TV Shows') latest = await _api.getDiscoverContent(null, type: 'tv', page: page);
        else latest = await _api.getTrending(page: page);

        int randomPageNum = Random().nextInt(50) + 1;
        String randomType = (filter == 'TV Shows') ? 'tv' : 'movie';
        if (filter == 'All') randomType = Random().nextBool() ? 'movie' : 'tv';

        List<Content> randomData = await _api.getDiscoverContent(null, page: randomPageNum, type: randomType);

        double latestRatio = (filter == 'All') ? 0.5 : 0.25;
        latest = latest.take((latest.length * latestRatio).round()).toList();
        randomData = randomData.take(max(0, 20 - latest.length)).toList();

        data = [...latest, ...randomData];
        data.shuffle();
      }

      if (isLoadMore) {
        _cacheGridData[filter]!.addAll(data);
      } else {
        _cacheGridData[filter] = data;
      }
    } catch (e) { debugPrint("Fetch Error: $e"); }

    _isLoading = false;
    _isFetchingNextPage = false;
    notifyListeners();
  }

  Future<void> fetchNextPage() async {
    if (_isFetchingNextPage || _isLoading) return;
    await fetchContent(filter: _currentFilter, isLoadMore: true);
  }
}