import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../providers/content_provider.dart';
import '../widgets/content_card.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Movies', 'TV Shows', 'Trending', 'Popular', 'Top Rated'];

  // Connectivity variables
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();

    // Initial data fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ContentProvider>(context, listen: false).fetchTrending();
    });

    // 1. Connection Monitor Logic
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      final bool hasNoConnection = result.contains(ConnectivityResult.none);

      if (hasNoConnection) {
        setState(() => _isOffline = true);
        _showStatusSnackBar("Connection Lost!", isError: true);
      } else {
        if (_isOffline) {
          _showStatusSnackBar("Connecting to the server...", isError: false);
          // Auto refresh logic when back online
          Provider.of<ContentProvider>(context, listen: false).fetchTrending();
        }
        setState(() => _isOffline = false);
      }
    });

    // Pagination Logic
    _scrollController.addListener(() {
      final provider = Provider.of<ContentProvider>(context, listen: false);
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
        if (!_isOffline) provider.fetchNextPage();
      }
    });
  }

  // Connectivity SnackBar Logic
  void _showStatusSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Purono ta shoraia notun ta dibe
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.wifi_off : Icons.wifi, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(message, style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: isError ? Colors.redAccent.withOpacity(0.9) : Colors.green.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isError ? 5 : 2),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _connectivitySubscription.cancel(); // Memory leak prevent korbe
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ContentProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final textColor = isDark ? Colors.white : const Color(0xFF0D253F);

    return Scaffold(
      appBar: AppBar(
        title: Text('Zero Stream', style: GoogleFonts.montserrat(color: textColor, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.search, size: 28, color: textColor),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
          ),
          const SizedBox(width: 8),
        ],
        bottom: provider.isFetchingNextPage
            ? PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: LinearProgressIndicator(
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            minHeight: 2,
          ),
        )
            : null,
      ),
      body: Column(
        children: [
          // Offline Indicator Banner (Optional but very pro look)
          if (_isOffline)
            Container(
              width: double.infinity,
              color: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: const Text(
                "You are currently offline",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),

          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(vertical: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                bool isSelected = selectedFilter == filters[index];
                Color activeColor = isDark ? const Color(0xFF01B4E4) : const Color(0xFF90CEA1);
                Color inactiveColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFF01B4E4).withOpacity(0.1);

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => selectedFilter = filters[index]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? activeColor : inactiveColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : (isDark ? Colors.white10 : Colors.black12),
                        ),
                      ),
                      child: Text(
                        filters[index],
                        style: GoogleFonts.montserrat(
                          color: isSelected ? Colors.black : textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: provider.isLoading && provider.trendingContent.isEmpty
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : GridView.builder(
              key: const PageStorageKey('home_grid'),
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.60,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: provider.trendingContent.length,
              itemBuilder: (context, index) {
                return ContentCard(content: provider.trendingContent[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}