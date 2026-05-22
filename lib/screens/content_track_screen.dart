import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/content_provider.dart';
import '../models/content.dart';
import 'player_screen.dart';
import 'season_selection_screen.dart';
import 'details_screen.dart'; // DetailsScreen import নিশ্চিত করুন

class ContentTrackScreen extends StatefulWidget {
  const ContentTrackScreen({super.key});

  @override
  State<ContentTrackScreen> createState() => _ContentTrackScreenState();
}

class _ContentTrackScreenState extends State<ContentTrackScreen> {
  int _tabIndex = 0;
  String selectedFilter = 'All';
  bool _isSelectionMode = false;
  final Set<int> _selectedIds = {};

  Future<bool?> _showDeleteDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove?"),
        content: const Text("Are you sure you want to delete the selected item(s)?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("No")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Yes")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<ContentProvider>(
      builder: (context, provider, child) {
        List<Content> displayList = (_tabIndex == 0) ? provider.watchingList : provider.completedList;
        final filteredList = displayList.where((item) {
          if (selectedFilter == 'Movies') return item.mediaType == 'movie';
          if (selectedFilter == 'Series') return item.mediaType == 'tv';
          return true;
        }).toList();

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: _isSelectionMode ? IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() { _isSelectionMode = false; _selectedIds.clear(); })) : null,
            title: Text(_isSelectionMode ? "${_selectedIds.length} Selected" : "My Collection", style: GoogleFonts.montserrat(fontWeight: FontWeight.w800)),
            centerTitle: true,
            actions: [
              if (_isSelectionMode) ...[
                IconButton(icon: const Icon(Icons.select_all), onPressed: () => setState(() => _selectedIds.addAll(filteredList.map((e) => e.id)))),
                IconButton(icon: const Icon(Icons.delete), onPressed: () async {
                  bool? confirmed = await _showDeleteDialog();
                  if (confirmed == true) {
                    provider.removeMultiple(filteredList.where((e) => _selectedIds.contains(e.id)).toList(), _tabIndex);
                    setState(() { _isSelectionMode = false; _selectedIds.clear(); });
                  }
                })
              ]
            ],
          ),
          body: Column(
            children: [
              _buildSegmentedTabs(cs, isDark),
              _buildFilterRow(cs, isDark),
              Expanded(
                child: filteredList.isEmpty
                    ? Center(child: Text("No items in ${_tabIndex == 0 ? 'Watching' : 'Completed'}", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final content = filteredList[index];
                    return Dismissible(
                      key: Key(content.id.toString()),
                      direction: _tabIndex == 0 ? DismissDirection.horizontal : DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd && _tabIndex == 0) {
                          if (provider.isAlreadyInCompleted(content.id)) {
                            bool? confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
                                title: const Text("Already Completed"),
                                content: const Text("Already in Completed. Remove from Watching?"),
                                actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("No")), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Yes"))]
                            ));
                            if (confirm == true) provider.removeFromWatching(content);
                            return false;
                          }
                          provider.markAsCompleted(content);
                          return false;
                        }
                        return await _showDeleteDialog();
                      },
                      onDismissed: (direction) {
                        if (direction == DismissDirection.endToStart) {
                          _tabIndex == 0 ? provider.removeFromWatching(content) : provider.removeFromCompleted(content);
                        }
                      },
                      background: Container(color: Colors.green, alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 20), child: const Icon(Icons.check, color: Colors.white)),
                      secondaryBackground: Container(color: Colors.redAccent, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                      child: GestureDetector(
                        onLongPress: () => setState(() => _isSelectionMode = true),
                        onTap: () {
                          if (_isSelectionMode) setState(() => _selectedIds.contains(content.id) ? _selectedIds.remove(content.id) : _selectedIds.add(content.id));
                        },
                        child: _buildModernCard(cs, isDark, content, provider, _selectedIds.contains(content.id)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernCard(ColorScheme cs, bool isDark, Content content, ContentProvider provider, bool isSelected) {
    String subTitle = content.mediaType == 'tv' ? provider.getLastEpisode(content.id) : "${content.mediaType.toUpperCase()} • ${content.releaseYear}";
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03), borderRadius: BorderRadius.circular(20), border: isSelected ? Border.all(color: cs.primary, width: 2) : null),
      child: Row(
        children: [
          // ইমেজ টাচেবল করা হয়েছে
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailsScreen(movie: content))),
            child: ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(content.fullBackdropUrl, width: 80, height: 110, fit: BoxFit.cover)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(content.title, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                Text(subTitle, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12)),
              ],
            ),
          ),
          if (_isSelectionMode)
            Padding(padding: const EdgeInsets.only(left: 10), child: Icon(isSelected ? Icons.check_circle : Icons.radio_button_unchecked, color: cs.primary)),
          if (_tabIndex == 0 && !_isSelectionMode)
            InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => content.mediaType == 'tv' ? SeasonSelectionScreen(content: content) : PlayerScreen(content: content))),
              child: Column(children: [Icon(Icons.play_circle_fill, color: cs.primary, size: 30), Text("Continue", style: TextStyle(color: cs.primary, fontSize: 10, fontWeight: FontWeight.bold))]),
            ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTabs(ColorScheme cs, bool isDark) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), child: Container(height: 45, decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(15)), child: Row(children: ["Watching", "Completed"].asMap().entries.map((entry) { bool isSelected = _tabIndex == entry.key; return Expanded(child: GestureDetector(onTap: () => setState(() => _tabIndex = entry.key), child: AnimatedContainer(duration: const Duration(milliseconds: 200), margin: const EdgeInsets.all(4), decoration: BoxDecoration(color: isSelected ? cs.primary : Colors.transparent, borderRadius: BorderRadius.circular(12)), child: Center(child: Text(entry.value, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.black : (isDark ? Colors.white60 : Colors.black54))))))); }).toList())));
  }

  Widget _buildFilterRow(ColorScheme cs, bool isDark) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: ['All', 'Movies', 'Series'].map((filter) { bool isSelected = selectedFilter == filter; return Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: ChoiceChip(label: Text(filter, style: TextStyle(color: isSelected ? Colors.black : (isDark ? Colors.white : Colors.black))), selected: isSelected, onSelected: (val) => setState(() => selectedFilter = filter), selectedColor: cs.primary, backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05))); }).toList());
  }
}