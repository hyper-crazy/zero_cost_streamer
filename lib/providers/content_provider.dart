import 'dart:math';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/content.dart';
import '../services/tmdb_api.dart';

class ContentProvider with ChangeNotifier {
  final TmdbApi _api = TmdbApi();

  final List<Content> _watchingList = [];
  final List<Content> _completedList = [];
  final Map<int, String> _lastWatchedEpisode = {};

  List<Content> get watchingList => _watchingList;
  List<Content> get completedList => _completedList;

  String getLastEpisode(int id) => _lastWatchedEpisode[id] ?? "Season 1 • Ep 1";

  void updateLastEpisode(int id, String episodeInfo) {
    _lastWatchedEpisode[id] = episodeInfo;
    notifyListeners();
  }

  bool isWatching(int id) => _watchingList.any((c) => c.id == id);
  bool isCompleted(int id) => _completedList.any((c) => c.id == id);

  // ADDED: চেক করার জন্য মেথডটি
  bool isAlreadyInCompleted(int id) => _completedList.any((c) => c.id == id);

  void addToWatching(Content content) {
    if (!_watchingList.any((c) => c.id == content.id)) {
      _watchingList.add(content);
      notifyListeners();
    }
  }

  void addToWatchlist(Content content) {
    if (!_watchingList.any((c) => c.id == content.id)) {
      _watchingList.add(content);
      notifyListeners();
    }
  }

  void markAsCompleted(Content content) {
    _watchingList.removeWhere((c) => c.id == content.id);
    if (!_completedList.any((c) => c.id == content.id)) {
      _completedList.add(content);
      notifyListeners();
    }
  }

  void removeFromWatching(Content content) {
    _watchingList.removeWhere((c) => c.id == content.id);
    notifyListeners();
  }

  void removeFromCompleted(Content content) {
    _completedList.removeWhere((c) => c.id == content.id);
    notifyListeners();
  }

  void removeMultiple(List<Content> contents, int tabIndex) {
    for (var content in contents) {
      if (tabIndex == 0)
        _watchingList.removeWhere((c) => c.id == content.id);
      else
        _completedList.removeWhere((c) => c.id == content.id);
    }
    notifyListeners();
  }

  final Map<String, List<Content>> _cacheGridData = {};
  final Map<String, int> _pageTracker = {};
  List<Content> _sliderContent = [];
  bool _isLoading = false;
  bool _isFetchingNextPage = false;
  String _currentFilter = 'All';
  bool _isOffline = false;

  List<Content> get gridContent => _cacheGridData[_currentFilter] ?? [];
  List<Content> get sliderContent => _sliderContent;
  bool get isLoading => _isLoading;
  bool get isFetchingNextPage => _isFetchingNextPage;
  bool get isOffline => _isOffline;

  void setOfflineStatus(bool status) {
    _isOffline = status;
    notifyListeners();
  }

  double _calculateWeightedScore(Content content, int minVotes) {
    double v = content.voteCount.toDouble();
    double m = minVotes.toDouble();
    double R = content.rating;
    double C = 7.0;
    if (v < m) return R * (v / m);
    return (v / (v + m) * R) + (m / (v + m) * C);
  }

  Future<void> initHome() async {
    final results = await Connectivity().checkConnectivity();
    if (results.contains(ConnectivityResult.none)) {
      _isOffline = true;
      notifyListeners();
      return;
    }
    if (_sliderContent.isNotEmpty) return;
    _isLoading = true;
    notifyListeners();
    try {
      _sliderContent = await _api.getTrending(page: 1);
      await fetchContent(filter: 'All');
      _isOffline = false;
    } catch (e) {
      debugPrint("Init Error: $e");
      _isOffline = true;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshHome() async {
    _cacheGridData.clear();
    _pageTracker.clear();
    _sliderContent = [];
    await initHome();
  }

  Future<void> fetchContent({
    required String filter,
    bool isLoadMore = false,
  }) async {
    _currentFilter = filter;
    final results = await Connectivity().checkConnectivity();
    if (results.contains(ConnectivityResult.none)) {
      _isOffline = true;
      notifyListeners();
      return;
    }
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
        List<Content> popMovies = await _api.getDiscoverContent(
          null,
          type: 'movie',
          sortBy: 'popularity.desc',
          page: page,
        );
        List<Content> popTV = await _api.getDiscoverContent(
          null,
          type: 'tv',
          sortBy: 'popularity.desc',
          page: page,
        );
        data = [...popMovies, ...popTV];
        data.sort((a, b) => b.voteCount.compareTo(a.voteCount));
      } else if (filter == 'Top Rated') {
        List<Content> topMovies = await _api.getDiscoverContent(
          null,
          type: 'movie',
          sortBy: 'vote_average.desc',
          page: page,
          minVoteCount: 500,
        );
        List<Content> topTV = await _api.getDiscoverContent(
          null,
          type: 'tv',
          sortBy: 'vote_average.desc',
          page: page,
          minVoteCount: 300,
        );
        data = [...topMovies, ...topTV];
        data.sort((a, b) {
          int m = (a.mediaType == 'movie') ? 1000 : 500;
          return _calculateWeightedScore(
            b,
            m,
          ).compareTo(_calculateWeightedScore(a, m));
        });
      } else {
        List<Content> latest = [];
        if (filter == 'Movies')
          latest = await _api.getDiscoverContent(
            null,
            type: 'movie',
            page: page,
          );
        else if (filter == 'TV Shows')
          latest = await _api.getDiscoverContent(null, type: 'tv', page: page);
        else
          latest = await _api.getTrending(page: page);
        int randomPageNum = Random().nextInt(50) + 1;
        String randomType = (filter == 'TV Shows') ? 'tv' : 'movie';
        if (filter == 'All') randomType = Random().nextBool() ? 'movie' : 'tv';
        List<Content> randomData = await _api.getDiscoverContent(
          null,
          page: randomPageNum,
          type: randomType,
        );
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
      _isOffline = false;
    } catch (e) {
      debugPrint("Fetch Error: $e");
      _isOffline = true;
    }
    _isLoading = false;
    _isFetchingNextPage = false;
    notifyListeners();
  }

  Future<void> fetchNextPage() async {
    if (_isFetchingNextPage || _isLoading) return;
    await fetchContent(filter: _currentFilter, isLoadMore: true);
  }
}
