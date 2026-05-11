import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ContentProvider>(context, listen: false).fetchTrending();
    });

    _scrollController.addListener(() {
      final provider = Provider.of<ContentProvider>(context, listen: false);
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
        provider.fetchNextPage();
      }
    });
  }

  @override
  void dispose() {
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
                Color inactiveColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFF01B4E4).withOpacity(0.5);

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