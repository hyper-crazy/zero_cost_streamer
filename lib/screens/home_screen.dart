import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/content_provider.dart';
import '../services/update_service.dart';
import '../widgets/content_card.dart';
import 'details_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late PageController _pageController;
  late AnimationController _progressController;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  int _currentTrendingPage = 500;
  bool _isAutoSliding = false;
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Movies', 'TV Shows', 'Popular', 'Top Rated'];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await UpdateService().checkUpdate(context);
    });

    _pageController = PageController(viewportFraction: 0.9, initialPage: _currentTrendingPage);
    _progressController = AnimationController(vsync: this, duration: const Duration(seconds: 5));

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _slideNext();
      }
    });

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      final hasNet = !results.contains(ConnectivityResult.none);
      final provider = Provider.of<ContentProvider>(context, listen: false);

      if (!hasNet) {
        provider.setOfflineStatus(true);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<ContentProvider>(context, listen: false);
      await provider.initHome();
      if (mounted && provider.sliderContent.isNotEmpty) {
        _progressController.forward();
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
        Provider.of<ContentProvider>(context, listen: false).fetchNextPage();
      }
    });
  }

  void _slideNext() {
    if (!_pageController.hasClients) return;

    _isAutoSliding = true;
    _currentTrendingPage++;
    _pageController.animateToPage(
      _currentTrendingPage,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOutCubic,
    ).then((_) {
      if (!mounted) return;
      _isAutoSliding = false;
      _progressController.reset();
      _progressController.forward();
    });
  }

  // --- FIXED REFRESH LOGIC ---
  Future<void> _manualReconnect() async {
    final provider = Provider.of<ContentProvider>(context, listen: false);
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasNet = !connectivityResult.contains(ConnectivityResult.none);

    if (!hasNet) {
      provider.setOfflineStatus(true);
      return;
    }

    provider.setOfflineStatus(false);

    // Refresh korar somoy 'All' chip select kore deya hobe
    setState(() {
      selectedFilter = 'All';
    });

    await provider.refreshHome();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _progressController.dispose();
    _pageController.dispose();
    _scrollController.dispose();
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
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          Image.asset('assets/images/zs_logo_transparent bg.png', height: 65, width: 65),
          Text('Zero Stream', style: GoogleFonts.montserrat(color: textColor, fontWeight: FontWeight.bold, fontSize: 20)),
        ]),
        actions: [
          IconButton(icon: Icon(Icons.search, size: 28, color: textColor), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())))
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            color: primaryColor,
            onRefresh: _manualReconnect,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 10, 20, 10), child: Text('Trending Now', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w900, color: textColor)))),

                SliverToBoxAdapter(
                  child: Column(children: [
                    SizedBox(
                      height: 220,
                      child: provider.sliderContent.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : PageView.builder(
                        controller: _pageController,
                        itemCount: 10000,
                        onPageChanged: (index) {
                          if (!_isAutoSliding) {
                            _currentTrendingPage = index;
                            _progressController.reset();
                            _progressController.forward();
                          }
                        },
                        itemBuilder: (context, index) {
                          final list = provider.sliderContent.take(7).toList();
                          final content = list[index % list.length];
                          return GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailsScreen(movie: content))),
                            child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Stack(fit: StackFit.expand, children: [
                                      CachedNetworkImage(imageUrl: content.fullBackdropUrl, fit: BoxFit.cover, placeholder: (context, url) => Container(color: Colors.white10)),
                                      DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.95)]))),
                                      Positioned(bottom: 15, left: 15, right: 85, child: Text("${content.title} (${content.releaseYear})", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                                      Positioned(bottom: 15, right: 15, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: primaryColor.withOpacity(0.85), borderRadius: BorderRadius.circular(8)), child: Text(content.mediaType.toUpperCase(), style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)))),
                                    ]))),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: AnimatedBuilder(
                            animation: _progressController,
                            builder: (context, child) => LinearProgressIndicator(value: _progressController.value, minHeight: 3, borderRadius: BorderRadius.circular(10), backgroundColor: isDark ? Colors.white10 : Colors.black12, valueColor: AlwaysStoppedAnimation<Color>(primaryColor)))),
                    const SizedBox(height: 16),
                  ]),
                ),

                SliverPersistentHeader(pinned: true, delegate: _StickyChipDelegate(height: 68, child: Container(color: Theme.of(context).scaffoldBackgroundColor, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), itemCount: filters.length, itemBuilder: (context, index) { final isSelected = selectedFilter == filters[index]; return Padding(padding: const EdgeInsets.only(right: 10), child: GestureDetector(onTap: () { setState(() => selectedFilter = filters[index]); provider.fetchContent(filter: filters[index]); }, child: AnimatedContainer(duration: const Duration(milliseconds: 200), alignment: Alignment.center, padding: const EdgeInsets.symmetric(horizontal: 20), decoration: BoxDecoration(color: isSelected ? primaryColor : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)), borderRadius: BorderRadius.circular(100), border: Border.all(color: isSelected ? primaryColor : Colors.white.withOpacity(0.1))), child: Text(filters[index], style: GoogleFonts.montserrat(color: isSelected ? Colors.black : textColor, fontWeight: FontWeight.bold, fontSize: 13))))); })))),
                SliverPadding(padding: const EdgeInsets.all(16), sliver: provider.isLoading ? const SliverToBoxAdapter(child: SizedBox(height: 300, child: Center(child: CircularProgressIndicator()))) : SliverGrid(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.62, crossAxisSpacing: 16, mainAxisSpacing: 16), delegate: SliverChildBuilderDelegate((context, index) => ContentCard(content: provider.gridContent[index]), childCount: provider.gridContent.length))),
                if (provider.isFetchingNextPage) const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()))),
              ],
            ),
          ),

          if (provider.isOffline)
            Container(
              color: Colors.black.withOpacity(0.75),
              child: Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.wifi_off, size: 70, color: Colors.white),
                    const SizedBox(height: 20),
                    const Text("No Internet Connection", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 40), child: Text("Please check your internet and press Try Again.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 15))),
                    const SizedBox(height: 30),
                    ElevatedButton(onPressed: _manualReconnect, child: const Text("Try Again")),
                  ])),
            ),
        ],
      ),
    );
  }
}

class _StickyChipDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  _StickyChipDelegate({required this.child, required this.height});
  @override double get minExtent => height;
  @override double get maxExtent => height;
  @override Widget build(context, shrink, overlaps) => child;
  @override bool shouldRebuild(covariant _StickyChipDelegate old) => true;
}