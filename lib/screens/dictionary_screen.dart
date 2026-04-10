import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../controllers/word_controller.dart';
import '../widgets/word_card.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final WordController controller = Get.find<WordController>();
  final TextEditingController _searchController = TextEditingController();
  final Set<int> _expanded = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        _buildCategoryChips(),
        _buildFavoritesToggle(),
        Expanded(
          child: Obx(() {
            final words = controller.filteredWords;
            if (words.isEmpty) return _buildEmpty();
            return ListView.builder(
              padding: const EdgeInsets.only(top: 4, bottom: 24),
              itemCount: words.length,
              itemBuilder: (context, i) {
                final word = words[i];
                final isExpanded = _expanded.contains(i);
                return WordCard(
                  key: ValueKey('${word.kalka}_$i'),
                  word: word,
                  expanded: isExpanded,
                  onTap: () => setState(() {
                    if (isExpanded) {
                      _expanded.remove(i);
                    } else {
                      _expanded.add(i);
                    }
                  }),
                ).animate(delay: (i * 30).ms).fadeIn(duration: 250.ms).slideX(
                    begin: -0.05, duration: 250.ms);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: TextField(
        controller: _searchController,
        onChanged: (v) {
          controller.search(v);
          setState(() => _expanded.clear());
        },
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Сөз іздеу...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(Icons.search,
              color: Theme.of(context).colorScheme.primary),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  color: Colors.grey[500],
                  onPressed: () {
                    _searchController.clear();
                    controller.search('');
                    setState(() => _expanded.clear());
                  },
                )
              : const SizedBox.shrink()),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final primary = Theme.of(context).colorScheme.primary;
    // Read .value here (in build scope), not inside itemBuilder callback —
    // GetX only tracks observables accessed during the synchronous build call.
    return Obx(() {
      final selectedCat = controller.selectedCategory.value;
      return SizedBox(
        height: 44,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: controller.categories.length,
          itemBuilder: (context, i) {
            final cat = controller.categories[i];
            final selected = selectedCat == cat;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                label: Text(controller.categoryName(cat)),
                selected: selected,
                onSelected: (_) {
                  controller.selectCategory(cat);
                  setState(() => _expanded.clear());
                },
                selectedColor: primary.withOpacity(0.15),
                checkmarkColor: primary,
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? primary : null,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                side: BorderSide(
                    color: selected
                        ? primary
                        : Colors.grey.withOpacity(0.3)),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildFavoritesToggle() {
    return Obx(() {
      final active = controller.showFavoritesOnly.value;
      // Always read favorites.length so GetX tracks it even when active=false
      final count = controller.favorites.length;
      return InkWell(
        onTap: () {
          controller.toggleFavoritesFilter();
          setState(() => _expanded.clear());
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: active
                ? Colors.red.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active
                  ? Colors.red.withOpacity(0.4)
                  : Colors.grey.withOpacity(0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                active ? Icons.favorite : Icons.favorite_border,
                size: 16,
                color: active ? Colors.red : Colors.grey[500],
              ),
              const SizedBox(width: 6),
              Text(
                active
                    ? 'Таңдаулылар ($count)'
                    : 'Таңдаулыларды көрсету',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      active ? FontWeight.w600 : FontWeight.w400,
                  color: active ? Colors.red : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Нәтиже табылмады',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[500])),
          const SizedBox(height: 8),
          // Read BOTH observables upfront so GetX tracks both as dependencies.
          // If only the first branch is evaluated, the second never registers.
          Obx(() {
            final query = controller.searchQuery.value;
            final favsOnly = controller.showFavoritesOnly.value;
            if (query.isNotEmpty) {
              return Text('"$query" бойынша жоқ',
                  style: TextStyle(fontSize: 13, color: Colors.grey[400]));
            }
            if (favsOnly) {
              return Text('Таңдаулы сөздер жоқ',
                  style: TextStyle(fontSize: 13, color: Colors.grey[400]));
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
