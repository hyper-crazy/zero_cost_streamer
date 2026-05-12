import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/content.dart';
import '../services/tmdb_api.dart';
import '../widgets/content_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TmdbApi _api = TmdbApi();

  List<Content> _searchResults = [];
  List<String> _searchHistory = [];

  bool _isLoading = false;
  bool _isLoadMore = false;
  int _currentPage = 1;
  bool _hasNextPage = true;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();

    // Infinite scroll listener
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoading && !_isLoadMore && _hasNextPage && _searchController.text.isNotEmpty) {
          _loadMoreResults();
        }
      }
    });
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _searchHistory = prefs.getStringList('search_history') ?? []);
  }

  // Primary search logic
  void _onSearchChanged(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
        _currentPage = 1;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasNextPage = true;
    });

    try {
      final results = await _api.searchContent(query, page: 1);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Pagination: Load next page results
  Future<void> _loadMoreResults() async {
    setState(() => _isLoadMore = true);
    _currentPage++;

    try {
      final nextResults = await _api.searchContent(_searchController.text, page: _currentPage);

      if (nextResults.isEmpty) {
        _hasNextPage = false;
      } else {
        setState(() {
          _searchResults.addAll(nextResults);
        });
      }
    } catch (e) {
      _hasNextPage = false;
    } finally {
      setState(() => _isLoadMore = false);
    }
  }

  Future<void> _addToHistory(String query) async {
    if (query.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory.remove(query);
      _searchHistory.insert(0, query);
      if (_searchHistory.length > 10) _searchHistory.removeLast();
    });
    await prefs.setStringList('search_history', _searchHistory);
  }

  Future<void> _removeFromHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _searchHistory.remove(query));
    await prefs.setStringList('search_history', _searchHistory);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color tintColor = isDark ? const Color(0xFF0D253F) : const Color(0xFFE6E0D4);
    final Color textColor = isDark ? Colors.white : const Color(0xFF0D253F);

    return Scaffold(
      backgroundColor: tintColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
            'Search',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: textColor)
        ),
      ),
      body: Column(
        children: [
          // Search Input Field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onSubmitted: (val) => _addToHistory(val),
              style: GoogleFonts.montserrat(color: textColor),
              decoration: InputDecoration(
                hintText: 'Search movies or shows...',
                hintStyle: GoogleFonts.montserrat(color: textColor.withOpacity(0.5)),
                prefixIcon: Icon(Icons.search, color: textColor.withOpacity(0.7)),
                filled: true,
                fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none
                ),
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: isDark ? const Color(0xFF01B4E4) : const Color(0xFF90CEA1)))
                : _searchController.text.isEmpty
                ? _buildSearchHistory(textColor, isDark)
                : _buildResultsGrid(),
          ),

          // Bottom Pagination Loader
          if (_isLoadMore)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isDark ? const Color(0xFF01B4E4) : const Color(0xFF90CEA1)
                  )
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchHistory(Color textColor, bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (_searchHistory.isNotEmpty)
          Text(
              'Recent Searches',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: textColor, fontSize: 18)
          ),
        const SizedBox(height: 15),
        ..._searchHistory.map((query) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: textColor.withOpacity(0.1), width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: ListTile(
                leading: Icon(Icons.history, color: textColor.withOpacity(0.5)),
                title: Text(query, style: GoogleFonts.montserrat(color: textColor)),
                trailing: IconButton(
                    icon: Icon(Icons.close, size: 18, color: textColor.withOpacity(0.5)),
                    onPressed: () => _removeFromHistory(query)
                ),
                onTap: () {
                  _searchController.text = query;
                  _onSearchChanged(query);
                },
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildResultsGrid() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.60,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return ContentCard(content: _searchResults[index]);
      },
    );
  }
}