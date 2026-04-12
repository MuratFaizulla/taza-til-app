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
            const SizedBox(height: 12),
            // Streak widget
            Obx(() => _buildStreakAndProgress(controller))
                .animate()
                .fadeIn(delay: 80.ms, duration: 400.ms),
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

  Widget _buildStreakAndProgress(WordController controller) {
  final streak = controller.streak.value;
  final learned = controller.learnedCount.value;
  const total = 76;

  // Определяем цвет и сообщение по streak
  final streakColor = streak == 0 ? Colors.grey :
                      streak < 3 ? const Color(0xFFFF9800) :
                      streak < 7 ? const Color(0xFFFF5722) :
                      const Color(0xFFE53935);

  final streakMsg = streak == 0 ? 'Бүгін бастаңыз!' :
                    streak == 1 ? 'Тамаша бастама! 💪' :
                    streak < 7 ? 'Жалғастырыңыз! 🔥' :
                    streak < 30 ? 'Керемет! Тоқтамаңыз! 🚀' :
                    'Ұлы жетістік! 👑';

  // Последние 7 дней для точек (streak показывает сколько дней подряд)
  final dots = List.generate(7, (i) => i < (streak > 7 ? 7 : streak));

  return Column(
    children: [
      // ── Streak карточка (Duolingo стиль) ─────────────────────────
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: streak == 0
                ? [Colors.grey.shade100, Colors.grey.shade200]
                : [
                    streakColor.withValues(alpha: 0.12),
                    streakColor.withValues(alpha: 0.05),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: streak == 0
                ? Colors.grey.withValues(alpha: 0.3)
                : streakColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Большой огонь с анимацией
                Column(
                  children: [
                    if (streak == 0)
                      const Text('🌱', style: TextStyle(fontSize: 48))
                    else
                      const _LiveFireWidget(),
                    const SizedBox(height: 2),
                    Text(
                      'STREAK',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: streakColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Счётчик и сообщение
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$streak',
                              style: TextStyle(
                                fontSize: 52,
                                fontWeight: FontWeight.w900,
                                color: streak == 0 ? Colors.grey : streakColor,
                                height: 1,
                              ),
                            ),
                            TextSpan(
                              text: '  күн',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: streak == 0
                                    ? Colors.grey
                                    : streakColor.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        streakMsg,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: streak == 0
                              ? Colors.grey[500]
                              : streakColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Лучший результат
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: streakColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: streakColor.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '🏆',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$learned',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: streakColor,
                            ),
                          ),
                          Text(
                            'сөз',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 7 точек недели (как в Duolingo)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (i) {
                final day = ['Дс', 'Сс', 'Ср', 'Бс', 'Жм', 'Сб', 'Жк'][i];
                final filled = dots[i];
                return Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled
                            ? streakColor
                            : streakColor.withValues(alpha: 0.1),
                        border: Border.all(
                          color: filled
                              ? streakColor
                              : streakColor.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: filled
                            ? [
                                BoxShadow(
                                  color: streakColor.withValues(alpha: 0.4),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                )
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          filled ? '🔥' : day,
                          style: TextStyle(
                            fontSize: filled ? 16 : 10,
                            fontWeight: FontWeight.w700,
                            color: filled ? Colors.white : Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      // ── Progress bar (Үйренілді) ──────────────────────────────────
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('📚',
                    style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                const Text(
                  'Үйренілген сөздер',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B5E20)),
                ),
                const Spacer(),
                Text(
                  '$learned / $total',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E7D32)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: total > 0 ? learned / total : 0,
                minHeight: 8,
                backgroundColor:
                    const Color(0xFF2E7D32).withValues(alpha: 0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF2E7D32)),
              ),
            ),
            if (learned > 0) ...[
              const SizedBox(height: 6),
              Text(
                '${((learned / total) * 100).toStringAsFixed(0)}% аяқталды',
                style: TextStyle(
                    fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ],
        ),
      ),
    ],
  );
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
                const SizedBox(width: 8),
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
            const SizedBox(height: 8),
            // TTS language status
            Obx(() => controller.ttsLanguage.value.isNotEmpty
                ? Text(
                    controller.ttsLanguage.value == 'kk-KZ'
                        ? '🇰🇿 Қазақша дауыс'
                        : controller.ttsLanguage.value == 'tr-TR'
                            ? '🇹🇷 Түрікше дауыс (жақын)'
                            : '🇷🇺 Орысша дауыс (қазақша жоқ)',
                    style: const TextStyle(
                        fontSize: 10, color: Colors.white60),
                  )
                : const SizedBox.shrink()),
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

// ── Live Fire Animation Widget (TikTok / Duolingo style) ─────────────────────
class _LiveFireWidget extends StatefulWidget {
  const _LiveFireWidget();

  @override
  State<_LiveFireWidget> createState() => _LiveFireWidgetState();
}

class _LiveFireWidgetState extends State<_LiveFireWidget>
    with TickerProviderStateMixin {
  // Glow: slow breathing pulse behind the main fire
  late AnimationController _glowCtrl;
  // Wobble: left-right lean + scale breathe
  late AnimationController _wobbleCtrl;
  // 4 independent sparks
  late List<AnimationController> _sparkCtrl;

  // X-offsets of sparks from center (pixels)
  static const List<double> _sparkX = [-18, 14, -6, 20];
  static const List<String> _sparkEmoji = ['✨', '⭐', '✨', '💫'];
  static const List<int> _sparkMs = [900, 1100, 750, 1250];
  static const List<int> _sparkDelayMs = [0, 300, 150, 600];

  @override
  void initState() {
    super.initState();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _wobbleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..repeat(reverse: true);

    _sparkCtrl = List.generate(4, (i) {
      final ctrl = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: _sparkMs[i]),
      );
      Future.delayed(Duration(milliseconds: _sparkDelayMs[i]), () {
        if (mounted) ctrl.repeat();
      });
      return ctrl;
    });
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _wobbleCtrl.dispose();
    for (final c in _sparkCtrl) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 80,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // ── Layer 1: glow (large semi-transparent fire, slow breathe) ──
          AnimatedBuilder(
            animation: _glowCtrl,
            builder: (_, __) {
              final scale = 0.88 + _glowCtrl.value * 0.28;
              final opacity = 0.18 + _glowCtrl.value * 0.22;
              return Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: const Text(
                    '🔥',
                    style: TextStyle(fontSize: 66),
                  ),
                ),
              );
            },
          ),

          // ── Layer 2: main fire (wobble + scale breathe) ──────────────
          AnimatedBuilder(
            animation: _wobbleCtrl,
            builder: (_, __) {
              // _wobbleCtrl goes 0→1→0 (reverse repeat)
              // angle swings -0.07 rad to +0.07 rad
              final t = _wobbleCtrl.value;
              final angle = (t - 0.5) * 0.14;
              final scale = 1.0 + t * 0.10;
              return Transform.rotate(
                angle: angle,
                child: Transform.scale(
                  scale: scale,
                  child: const Text(
                    '🔥',
                    style: TextStyle(fontSize: 52),
                  ),
                ),
              );
            },
          ),

          // ── Layer 3: flying sparks (float up + fade) ─────────────────
          ...List.generate(4, (i) {
            return AnimatedBuilder(
              animation: _sparkCtrl[i],
              builder: (_, __) {
                final t = _sparkCtrl[i].value; // 0..1
                // spark flies upward 50 px
                final yUp = t * 50.0;
                // fade in first 25 %, fade out remaining 75 %
                final opacity =
                    t < 0.25 ? (t / 0.25) : ((1.0 - t) / 0.75);
                return Positioned(
                  bottom: 28 + yUp,
                  left: 36 + _sparkX[i],
                  child: Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: Text(
                      _sparkEmoji[i],
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
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
