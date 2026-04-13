import 'dart:math';
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
            const SizedBox(height: 16),
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
            const SizedBox(height: 14),
            _buildQuickQuiz(context, controller, word)
                .animate()
                .fadeIn(delay: 450.ms, duration: 400.ms),
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
                color: const Color(0xFF2E7D32).withValues(alpha: 0.3)),
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
            color: _diffColor(word.difficulty).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: _diffColor(word.difficulty).withValues(alpha: 0.4)),
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
            color: const Color(0xFF2E7D32).withValues(alpha: 0.35),
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
                color: Colors.white.withValues(alpha: 0.15),
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
                color: Colors.white.withValues(alpha: 0.15),
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
                // Mark as learned button
                Obx(() => _actionButton(
                      icon: controller.isWordLearned(word.kalka)
                          ? Icons.check_circle
                          : Icons.school_outlined,
                      label: controller.isWordLearned(word.kalka)
                          ? 'Үйренілді ✓'
                          : 'Үйрендім',
                      onTap: () => controller.markWordAsLearned(word.kalka),
                    )),
                const SizedBox(width: 8),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
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
                                  .withValues(alpha: 0.4)),
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

  Widget _buildQuickQuiz(
      BuildContext context, WordController controller, Word word) {
    return _QuickQuizCard(controller: controller, word: word);
  }

  Widget _buildMotivation(BuildContext context) {
    final quotes = [
      ('🌱', 'Ана тіліңді сақта!',
          'Күнделікті бір жаңа сөз үйрен — тілің тазарсын.'),
      ('📚', 'Тіл — халықтың жаны!',
          'Қазақ тілін дамыту — болашақ ұрпаққа сыйың.'),
      ('💪', 'Таза тілде сөйле!',
          'Калька сөздерден аулақ болу — тілдің байлығын сақтайды.'),
      ('🦅', 'Қазақша ойла!',
          'Ойлау тілінде болса — сөйлеуің де таза болады.'),
      ('⭐', 'Бүгін бір қадам!',
          'Бір сөзді үйрену — мың сөзге апаратын жол.'),
    ];
    final idx = DateTime.now()
            .difference(DateTime(DateTime.now().year, 1, 1))
            .inDays %
        quotes.length;
    final q = quotes[idx];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text(q.$1, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(q.$2,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1B5E20))),
                const SizedBox(height: 4),
                Text(
                  q.$3,
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
            color: color.withValues(alpha: 0.1),
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

// ── Quick Quiz Widget ──────────────────────────────────────────────────────────
class _QuickQuizCard extends StatefulWidget {
  final WordController controller;
  final Word word;

  const _QuickQuizCard({required this.controller, required this.word});

  @override
  State<_QuickQuizCard> createState() => _QuickQuizCardState();
}

class _QuickQuizCardState extends State<_QuickQuizCard> {
  late List<String> _options;
  int _selectedIndex = -1;
  bool _answered = false;
  late int _correctIndex;

  @override
  void initState() {
    super.initState();
    _buildOptions();
  }

  void _buildOptions() {
    final rng = Random();
    final allWords = widget.controller.allWords.toList();
    final wrongs = allWords
        .where((w) => w.kazakh != widget.word.kazakh)
        .toList()
      ..shuffle(rng);
    final opts = [widget.word.kazakh, ...wrongs.take(3).map((w) => w.kazakh)]
      ..shuffle(rng);
    _options = opts;
    _correctIndex = opts.indexOf(widget.word.kazakh);
  }

  void _resetQuiz() {
    setState(() {
      _selectedIndex = -1;
      _answered = false;
      _buildOptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A1B9A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.quiz,
                      size: 18, color: Color(0xFF6A1B9A)),
                ),
                const SizedBox(width: 10),
                const Text('Жылдам квиз',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF6A1B9A))),
                const Spacer(),
                if (_answered)
                  GestureDetector(
                    onTap: _resetQuiz,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6A1B9A).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Қайта',
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6A1B9A),
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Бұл сөздің қазақша баламасы қандай?',
              style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.word.kalka,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.red[700]),
              ),
            ),
            const SizedBox(height: 14),
            ...List.generate(_options.length, (i) {
              final isCorrect = i == _correctIndex;
              final isSelected = i == _selectedIndex;

              Color bgColor = Theme.of(context).colorScheme.surfaceContainerHighest;
              Color borderColor = Colors.transparent;
              Color textColor = Theme.of(context).colorScheme.onSurface;

              if (_answered) {
                if (isCorrect) {
                  bgColor = const Color(0xFFE8F5E9);
                  borderColor = const Color(0xFF2E7D32);
                  textColor = const Color(0xFF1B5E20);
                } else if (isSelected) {
                  bgColor = const Color(0xFFFFEBEE);
                  borderColor = const Color(0xFFD32F2F);
                  textColor = const Color(0xFFD32F2F);
                }
              }

              return GestureDetector(
                onTap: _answered
                    ? null
                    : () {
                        setState(() {
                          _selectedIndex = i;
                          _answered = true;
                          if (isCorrect) {
                            widget.controller
                                .markWordAsLearned(widget.word.kalka);
                          }
                        });
                      },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(_options[i],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: textColor)),
                      ),
                      if (_answered && isCorrect)
                        const Icon(Icons.check_circle,
                            color: Color(0xFF2E7D32), size: 18),
                      if (_answered && isSelected && !isCorrect)
                        const Icon(Icons.cancel,
                            color: Color(0xFFD32F2F), size: 18),
                    ],
                  ),
                ),
              );
            }),
            if (_answered) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedIndex == _correctIndex
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _selectedIndex == _correctIndex
                      ? 'Дұрыс! 🎉 «${widget.word.kazakh}» — дұрыс жауап.'
                      : 'Дұрыс жауап: «${widget.word.kazakh}»',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _selectedIndex == _correctIndex
                        ? const Color(0xFF1B5E20)
                        : const Color(0xFFD32F2F),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
