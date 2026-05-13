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
  final FocusNode _searchFocusNode = FocusNode();
  final TmdbApi _api = TmdbApi();

  List<Content> _searchResults = [];
  List<String> _searchHistory = [];
  Map<int, String> _availableGenres = {};

  bool _isLoading = false;
  bool _isLoadMore = false;
  int _currentPage = 1;
  bool _hasNextPage = true;

  // Filters & Sorting State
  String _selectedType = 'all';
  String _selectedYear = 'All';
  List<int> _selectedGenreIds = [];
  String _ratingCondition = 'Greater Than';
  double _ratingValue = 5.0;
  String _currentSort = 'popularity.desc';

  // --- LOGIC: Checks ---
  bool get _isAdvanceSearchActive =>
      _selectedType != 'all' || _selectedYear != 'All' || _selectedGenreIds.isNotEmpty || _ratingValue != 5.0;

  bool get _isSortApplied => _currentSort != 'popularity.desc';

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _fetchGenres();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoading && !_isLoadMore && _hasNextPage) _loadMoreResults();
      }
    });
  }

  // --- HELPERS ---
  void _resetFilters() {
    setState(() {
      _selectedType = 'all'; _selectedYear = 'All'; _selectedGenreIds = [];
      _ratingCondition = 'Greater Than'; _ratingValue = 5.0; _currentSort = 'popularity.desc';
    });
    _performSearch();
  }

  void _resetSorting() {
    setState(() => _currentSort = 'popularity.desc');
    _performSearch();
  }

  String _getSortName(String value) {
    if (value.contains('vote_average.desc')) return 'High Rating';
    if (value.contains('vote_average.asc')) return 'Low Rating';
    if (value.contains('primary_release_date.desc')) return 'Latest';
    if (value.contains('primary_release_date.asc')) return 'Oldest';
    if (value.contains('original_title.asc')) return 'A to Z';
    if (value.contains('original_title.desc')) return 'Z to A';
    return 'Popularity';
  }

  // --- DATA LOGIC ---
  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _searchHistory = prefs.getStringList('search_history') ?? []);
  }

  Future<void> _saveToHistory(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty || trimmed.length < 2) return;
    final prefs = await SharedPreferences.getInstance();
    _searchHistory.remove(trimmed);
    _searchHistory.insert(0, trimmed);
    if (_searchHistory.length > 10) _searchHistory.removeLast();
    await prefs.setStringList('search_history', _searchHistory);
    setState(() {});
  }

  Future<void> _deleteFromHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    _searchHistory.remove(query);
    await prefs.setStringList('search_history', _searchHistory);
    setState(() {});
  }

  Future<void> _fetchGenres() async {
    final genres = await _api.getGenreList(_selectedType);
    setState(() => _availableGenres = genres);
  }

  // --- CORE SEARCH & FILTER LOGIC ---
  void _performSearch({bool isNewSearch = true, bool triggerHistory = false}) async {
    if (isNewSearch) {
      setState(() { _isLoading = true; _currentPage = 1; _hasNextPage = true; _searchResults = []; });
      if (triggerHistory) _saveToHistory(_searchController.text);
    }

    try {
      List<Content> finalResults = [];
      String query = _searchController.text.trim().toLowerCase();

      // IF Query is present, search whole database and manually filter
      if (query.isNotEmpty) {
        List<Content> rawResults = await _api.searchContent(query, page: _currentPage);

        finalResults = rawResults.where((item) {
          // Accurate Partial Matching
          bool titleMatch = item.title.toLowerCase().contains(query);

          // Apply Advanced Filters on top of search results
          bool yearMatch = _selectedYear == 'All' || item.releaseYear == _selectedYear;
          bool genreMatch = _selectedGenreIds.isEmpty || _selectedGenreIds.any((id) => item.genreIds.contains(id));
          bool ratingMatch = _ratingCondition == 'Greater Than' ? item.rating >= _ratingValue : item.rating <= _ratingValue;

          return titleMatch && yearMatch && genreMatch && ratingMatch;
        }).toList();

        // Manual Sort for search results
        if (_isSortApplied) {
          _applyClientSorting(finalResults);
        }
      }
      // IF No query, fetch based on Discover (Advanced Filters)
      else if (_isAdvanceSearchActive) {
        finalResults = await _api.getDiscoverContent(
          null, page: _currentPage, type: _selectedType, sortBy: _currentSort,
          year: _selectedYear == 'All' ? null : _selectedYear,
          minRating: _ratingCondition == 'Greater Than' ? _ratingValue : null,
          maxRating: _ratingCondition == 'Less Than' ? _ratingValue : null,
          withGenres: _selectedGenreIds.isEmpty ? null : _selectedGenreIds.join(','),
        );
      }

      setState(() {
        if (isNewSearch) _searchResults = finalResults; else _searchResults.addAll(finalResults);
        _isLoading = false; _isLoadMore = false;
        if (finalResults.isEmpty) _hasNextPage = false;
      });
    } catch (e) { setState(() { _isLoading = false; _isLoadMore = false; }); }
  }

  void _applyClientSorting(List<Content> list) {
    if (_currentSort.contains('vote_average')) {
      list.sort((a, b) => _currentSort.contains('desc') ? b.rating.compareTo(a.rating) : a.rating.compareTo(b.rating));
    } else if (_currentSort.contains('primary_release_date')) {
      list.sort((a, b) => _currentSort.contains('desc') ? b.releaseYear.compareTo(a.releaseYear) : a.releaseYear.compareTo(b.releaseYear));
    } else if (_currentSort.contains('original_title')) {
      list.sort((a, b) => _currentSort.contains('asc') ? a.title.compareTo(b.title) : b.title.compareTo(a.title));
    }
  }

  Future<void> _loadMoreResults() async {
    setState(() => _isLoadMore = true);
    _currentPage++;
    _performSearch(isNewSearch: false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : const Color(0xFF0D253F);
    final Color fieldColor = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D253F) : const Color(0xFFE6E0D4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Search', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: textColor)),
      ),
      floatingActionButton: (_searchResults.isNotEmpty && _isAdvanceSearchActive) ? _buildSortFAB() : null,
      body: Column(children: [
        // Search Input
        Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (v) => _performSearch(triggerHistory: false),
                onSubmitted: (v) => _performSearch(triggerHistory: true),
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Search movies or shows...',
                  filled: true,
                  fillColor: fieldColor,
                  prefixIcon: Icon(Icons.search, color: textColor.withOpacity(0.5)),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Container(
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(12)),
                      child: IconButton(padding: EdgeInsets.zero, icon: const Icon(Icons.tune_rounded, color: Colors.black, size: 20), onPressed: _showFilterSheet),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: textColor.withOpacity(0.1))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5))),
                )
            )
        ),

        // --- APPLIED CHIPS SECTION ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (_isAdvanceSearchActive)
                GestureDetector(
                  onTap: _resetFilters,
                  child: Chip(
                    label: const Text("Filters Applied", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onDeleted: _resetFilters,
                    deleteIcon: const Icon(Icons.close, size: 14),
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    side: BorderSide(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              if (_isSortApplied)
                GestureDetector(
                  onTap: _resetSorting,
                  child: Chip(
                    label: Text("Sorted: ${_getSortName(_currentSort)}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onDeleted: _resetSorting,
                    deleteIcon: const Icon(Icons.close, size: 14),
                    backgroundColor: Colors.orange.withOpacity(0.1),
                    side: const BorderSide(color: Colors.orange),
                  ),
                ),
            ],
          ),
        ),

        Expanded(child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _searchResults.isEmpty
            ? _buildHistoryView(textColor)
            : _buildResultsGrid()
        ),
      ]),
    );
  }

  // --- UI COMPONENTS ---
  Widget _buildSortFAB() {
    final Map<String, String> sortOptions = {
      'Latest': 'primary_release_date.desc', 'Oldest': 'primary_release_date.asc',
      'Rating (High)': 'vote_average.desc', 'Rating (Low)': 'vote_average.asc',
      'A to Z': 'original_title.asc', 'Z to A': 'original_title.desc',
    };
    return PopupMenuButton<String>(
      onSelected: (val) { _searchFocusNode.unfocus(); setState(() => _currentSort = val); _performSearch(); },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      offset: const Offset(0, -320),
      child: Container(
        height: 56, width: 56,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle, boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))]),
        child: const Icon(Icons.sort_rounded, color: Colors.black, size: 28),
      ),
      itemBuilder: (context) => sortOptions.entries.map((e) => PopupMenuItem(
        value: e.value,
        child: Row(children: [
          Icon(_currentSort == e.value ? Icons.check_circle : Icons.circle_outlined, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(e.key, style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 13)),
        ]),
      )).toList(),
    );
  }

  void _showFilterSheet() {
    _searchFocusNode.unfocus();
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 20),
                Text('Advance Search', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold)),
                _sectionTitle('Media Type'),
                Wrap(spacing: 10, children: [
                  _choiceChip('All', _selectedType == 'all', () { setModalState(() => _selectedType = 'all'); _fetchGenres(); }),
                  _choiceChip('Movies', _selectedType == 'movie', () { setModalState(() => _selectedType = 'movie'); _fetchGenres(); }),
                  _choiceChip('TV Shows', _selectedType == 'tv', () { setModalState(() => _selectedType = 'tv'); _fetchGenres(); }),
                ]),
                _sectionTitle('Release Year'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: DropdownButton<String>(
                    value: _selectedYear, isExpanded: true, underline: const SizedBox(),
                    items: ['All', ...List.generate((DateTime.now().year + 1) - 1900, (index) => (DateTime.now().year + 1 - index).toString())]
                        .map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                    onChanged: (v) => setModalState(() => _selectedYear = v!),
                  ),
                ),
                _sectionTitle('Genres'),
                Wrap(spacing: 8, children: _availableGenres.entries.map((e) {
                  bool isSelected = _selectedGenreIds.contains(e.key);
                  return FilterChip(
                    label: Text(e.value, style: TextStyle(fontSize: 12, color: isSelected ? Colors.black : null)),
                    selected: isSelected,
                    onSelected: (val) => setModalState(() { val ? _selectedGenreIds.add(e.key) : _selectedGenreIds.remove(e.key); }),
                    selectedColor: Theme.of(context).colorScheme.primary,
                  );
                }).toList()),
                _sectionTitle('Rating Condition'),
                Row(children: [
                  _choiceChip('Greater Than', _ratingCondition == 'Greater Than', () => setModalState(() => _ratingCondition = 'Greater Than')),
                  const SizedBox(width: 10),
                  _choiceChip('Less Than', _ratingCondition == 'Less Than', () => setModalState(() => _ratingCondition = 'Less Than')),
                ]),
                Slider(value: _ratingValue, min: 0, max: 10, divisions: 10, label: _ratingValue.toString(), onChanged: (v) => setModalState(() => _ratingValue = v)),
                const SizedBox(height: 30),
                SizedBox(width: double.infinity, height: 55, child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  onPressed: () { Navigator.pop(context); _performSearch(triggerHistory: true); },
                  child: const Text('Apply Filters', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(padding: const EdgeInsets.only(top: 20, bottom: 10), child: Text(title, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16)));
  Widget _choiceChip(String label, bool selected, VoidCallback onSelected) => ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onSelected(), selectedColor: Theme.of(context).colorScheme.primary);
  Widget _buildResultsGrid() => GridView.builder(controller: _scrollController, padding: const EdgeInsets.all(16), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.6, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: _searchResults.length, itemBuilder: (context, index) => ContentCard(content: _searchResults[index]));
  Widget _buildHistoryView(Color t) {
    if (_searchHistory.isEmpty) return Center(child: Text("Search for your favorite content", style: TextStyle(color: t.withOpacity(0.5))));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), child: Text("Recent Searches", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: t))), Expanded(child: ListView.builder(itemCount: _searchHistory.length, itemBuilder: (context, index) => ListTile(leading: Icon(Icons.history, color: t.withOpacity(0.5)), title: Text(_searchHistory[index], style: TextStyle(color: t)), trailing: IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => _deleteFromHistory(_searchHistory[index])), onTap: () { _searchController.text = _searchHistory[index]; _performSearch(triggerHistory: true); })))]);
  }
}