import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/word_controller.dart';
import '../models/word.dart';

class WordCard extends StatelessWidget {
  final Word word;
  final bool expanded;
  final VoidCallback? onTap;

  const WordCard({
    super.key,
    required this.word,
    this.expanded = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WordController>();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, controller),
              if (expanded) ...[
                const SizedBox(height: 12),
                _buildDivider(),
                const SizedBox(height: 12),
                _buildDefinition(context),
                const SizedBox(height: 10),
                _buildExample(context),
                if (word.synonyms.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _buildSynonyms(context),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WordController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Kalka badge  ❌
        Expanded(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFEF9A9A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('❌',
                    style: TextStyle(fontSize: 11, height: 1)),
                const SizedBox(height: 2),
                Text(
                  word.kalka,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD32F2F),
                      height: 1.3),
                ),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Icon(Icons.arrow_forward,
              color: Colors.grey, size: 16),
        ),
        // Kazakh badge  ✅
        Expanded(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFA5D6A7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('✅',
                    style: TextStyle(fontSize: 11, height: 1)),
                const SizedBox(height: 2),
                Text(
                  word.kazakh,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B5E20),
                      height: 1.3),
                ),
              ],
            ),
          ),
        ),
        // Difficulty dot
        const SizedBox(width: 8),
        _diffDot(word.difficulty),
        const SizedBox(width: 4),
        // Favorite button — access RxList directly so GetX tracks it
        Obx(() {
          final isFav = controller.favorites
              .contains(word.kalka.toLowerCase());
          return GestureDetector(
            onTap: () => controller.toggleFavorite(word.kalka),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                size: 18,
                color: isFav ? Colors.red : Colors.grey[400],
              ),
            ),
          );
        }),
        // Expand arrow
        Icon(
          expanded ? Icons.expand_less : Icons.expand_more,
          color: Colors.grey[400],
          size: 18,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [
          Color(0xFFEF9A9A),
          Color(0xFFA5D6A7),
        ]),
      ),
    );
  }

  Widget _buildDefinition(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, size: 15, color: Color(0xFF2E7D32)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(word.definition,
              style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.8),
                  height: 1.4)),
        ),
      ],
    );
  }

  Widget _buildExample(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Color(0xFFF1F8E9),
        borderRadius: BorderRadius.all(Radius.circular(8)),
        border: Border(
          left: BorderSide(color: Color(0xFF2E7D32), width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Мысал:',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E7D32),
                  letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Text(word.example,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                  height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildSynonyms(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('Синонимдер:',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600])),
        ...word.synonyms.map((s) => Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.4)),
              ),
              child: Text(s,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF2E7D32))),
            )),
      ],
    );
  }

  Widget _diffDot(int d) {
    final color = d == 1
        ? const Color(0xFF2E7D32)
        : d == 2
            ? const Color(0xFFF57F17)
            : const Color(0xFFD32F2F);
    return Tooltip(
      message: d == 1 ? 'Оңай' : d == 2 ? 'Орташа' : 'Қиын',
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

// ─── Compact card for Detector results ────────────────────────────────────────
class WordCardHighlight extends StatelessWidget {
  final Word word;

  const WordCardHighlight({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WordController>();
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('❌',
                          style: TextStyle(fontSize: 10, height: 1)),
                      const SizedBox(height: 2),
                      Text(word.kalka,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFD32F2F),
                              fontSize: 13)),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.arrow_forward,
                      size: 14, color: Colors.grey),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('✅',
                          style: TextStyle(fontSize: 10, height: 1)),
                      const SizedBox(height: 2),
                      Text(word.kazakh,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1B5E20),
                              fontSize: 13)),
                    ],
                  ),
                ),
                const Spacer(),
                // Favorite — access RxList directly so GetX tracks it
                Obx(() {
                  final isFav = controller.favorites
                      .contains(word.kalka.toLowerCase());
                  return GestureDetector(
                    onTap: () => controller.toggleFavorite(word.kalka),
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: isFav ? Colors.red : Colors.grey[400],
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 8),
            Text(word.definition,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    height: 1.3)),
            const SizedBox(height: 6),
            Text('«${word.example}»',
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF2E7D32),
                    fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}
