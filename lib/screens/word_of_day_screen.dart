import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/word_controller.dart';
import '../models/word.dart';

class WordOfDayScreen extends StatelessWidget {
  const WordOfDayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WordController>();
    return Obx(() {
      final word = controller.wordOfDay.value;
      if (word == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateBadge(word)
                .animate()
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 20),
            _buildHeroCard(context, controller, word)
                .animate()
                .fadeIn(delay: 100.ms, duration: 400.ms)
                .slideY(begin: 0.15),
            const SizedBox(height: 20),
            _buildDefinitionCard(context, word)
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms),
            const SizedBox(height: 14),
            _buildExampleCard(context, word)
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms),
            if (word.synonyms.isNotEmpty) ...[
              const SizedBox(height: 14),
              _buildSynonymsCard(context, word)
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 400.ms),
            ],
            const SizedBox(height: 20),
            _buildMotivation(context)
                .animate()
                .fadeIn(delay: 500.ms, duration: 400.ms),
            const SizedBox(height: 32),
          ],
        ),
      );
    });
  }

  Widget _buildDateBadge(Word word) {
    final months = [
      'қаңтар', 'ақпан', 'наурыз', 'сәуір', 'мамыр', 'маусым',
      'шілде', 'тамыз', 'қыркүйек', 'қазан', 'қараша', 'желтоқсан',
    ];
    final n = DateTime.now();
    final dateStr = '${n.day} ${months[n.month - 1]}, ${n.year}';
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: const Color(0xFF2E7D32).withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today,
                  size: 13, color: Color(0xFF2E7D32)),
              const SizedBox(width: 6),
              Text(dateStr,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _diffColor(word.difficulty).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: _diffColor(word.difficulty).withOpacity(0.4)),
          ),
          child: Text(
            _diffLabel(word.difficulty),
            style: TextStyle(
                fontSize: 11,
                color: _diffColor(word.difficulty),
                fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(
      BuildContext context, WordController controller, Word word) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Күннің сөзі',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 20),
            Text(
              word.kalka,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.red[200],
                decoration: TextDecoration.lineThrough,
                decorationColor: Colors.red[200],
                decorationThickness: 2,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_downward,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              word.kazakh,
              style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Colors.white),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // TTS button
                Obx(() => _actionButton(
                      icon: controller.isSpeaking.value
                          ? Icons.stop
                          : Icons.volume_up,
                      label: controller.isSpeaking.value
                          ? 'Тоқтату'
                          : 'Тыңдау',
                      onTap: () => controller.speak(word.kazakh),
                    )),
                const SizedBox(width: 12),
                // Share button
                _actionButton(
                  icon: Icons.share,
                  label: 'Бөлісу',
                  onTap: () => Share.share(
                    '📚 Күнделікті сөз | Таза Тіл\n\n'
                    '❌ Калька: ${word.kalka}\n'
                    '✅ Қазақша: ${word.kazakh}\n\n'
                    '${word.definition}\n\n'
                    '«${word.example}»\n\n'
                    '#ТазаТіл #ҚазақТілі',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildDefinitionCard(BuildContext context, Word word) {
    return Card(
      margin: EdgeInsets.zero,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader(
                Icons.auto_stories, 'Анықтама', const Color(0xFF2E7D32)),
            const SizedBox(height: 12),
            Text(word.definition,
                style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleCard(BuildContext context, Word word) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC5E1A5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(
              Icons.format_quote, 'Мысал сөйлем', const Color(0xFF33691E)),
          const SizedBox(height: 12),
          Text('«${word.example}»',
              style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1B5E20),
                  fontStyle: FontStyle.italic,
                  height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildSynonymsCard(BuildContext context, Word word) {
    return Card(
      margin: EdgeInsets.zero,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader(Icons.compare_arrows, 'Синонимдер',
                const Color(0xFF2E7D32)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: word.synonyms
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFF2E7D32)
                                  .withOpacity(0.4)),
                        ),
                        child: Text(s,
                            style: const TextStyle(
                                color: Color(0xFF2E7D32),
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivation(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32).withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFF2E7D32).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Text('🌱', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ана тіліңді сақта!',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1B5E20))),
                const SizedBox(height: 4),
                Text(
                  'Күнделікті бір жаңа сөз үйрен — тілің тазарсын.',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: color)),
      ],
    );
  }

  Color _diffColor(int d) {
    if (d == 1) return const Color(0xFF2E7D32);
    if (d == 2) return const Color(0xFFF57F17);
    return const Color(0xFFD32F2F);
  }

  String _diffLabel(int d) {
    if (d == 1) return 'Оңай';
    if (d == 2) return 'Орташа';
    return 'Қиын';
  }
}
