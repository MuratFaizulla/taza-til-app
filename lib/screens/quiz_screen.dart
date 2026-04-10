import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../controllers/word_controller.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final WordController controller = Get.find<WordController>();
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 4));
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  void _onFinished() {
    if (controller.quizScore.value >= 7) {
      _confetti.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(() {
          switch (controller.quizState.value) {
            case 'playing':
              return _PlayingView(controller: controller);
            case 'finished':
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _onFinished());
              return _FinishedView(controller: controller);
            default:
              return _IdleView(controller: controller);
          }
        }),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 40,
            colors: const [
              Color(0xFF2E7D32),
              Color(0xFF4CAF50),
              Colors.white,
              Colors.amber,
              Colors.lightGreen,
            ],
          ),
        ),
      ],
    );
  }
}

// ─── IDLE ──────────────────────────────────────────────────────────────────────
class _IdleView extends StatelessWidget {
  final WordController controller;
  const _IdleView({required this.controller});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.quiz, size: 52, color: primary),
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            const Text(
              'Викторина',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
            const SizedBox(height: 10),
            Text(
              '10 сұрақ · калькаларды қазақшамен сәйкестендір',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 32),
            Obx(() => controller.bestScore.value > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.emoji_events,
                            color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Ең жоғары: ${controller.bestScore.value}/10',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms)
                : const SizedBox.shrink()),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: controller.startQuiz,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Бастау',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26)),
                  elevation: 4,
                ),
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.5),
            const SizedBox(height: 40),
            _buildRules(primary),
          ],
        ),
      ),
    );
  }

  Widget _buildRules(Color primary) {
    final rules = [
      ('Калька сөз көрсетіледі', Icons.translate),
      ('4 нұсқадан дұрысын таңдаңыз', Icons.touch_app),
      ('10 сұрақ · максималды 10 ұпай', Icons.stars),
    ];
    return Column(
      children: rules
          .asMap()
          .entries
          .map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          Icon(e.value.$2, size: 16, color: primary),
                    ),
                    const SizedBox(width: 12),
                    Text(e.value.$1,
                        style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ).animate().fadeIn(delay: (600 + e.key * 100).ms))
          .toList(),
    );
  }
}

// ─── PLAYING ──────────────────────────────────────────────────────────────────
class _PlayingView extends StatelessWidget {
  final WordController controller;
  const _PlayingView({required this.controller});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Obx(() {
      final idx = controller.currentQuestionIndex.value;
      final total = controller.quizQuestions.length;
      if (idx >= total) return const SizedBox.shrink();

      final q = controller.quizQuestions[idx];
      final answered = controller.showAnswerResult.value;
      final selected = controller.selectedAnswer.value;

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress
            Row(
              children: [
                Text('${idx + 1} / $total',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primary)),
                const Spacer(),
                Text('${controller.quizScore.value} ұпай',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (idx + 1) / total,
                minHeight: 8,
                backgroundColor: primary.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(primary),
              ),
            ),
            const SizedBox(height: 24),

            // Question card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primary,
                    Color.lerp(primary, Colors.black, 0.25)!,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Қазақшасы қандай?',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7), fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    q.word.kalka,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      controller.categoryName(q.word.category),
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ).animate(key: ValueKey(idx)).fadeIn().scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1, 1),
                  duration: 300.ms,
                ),

            const SizedBox(height: 24),

            // Options
            ...q.options.asMap().entries.map((entry) {
              final optIdx = entry.key;
              final opt = entry.value;
              final isCorrect = optIdx == q.correctIndex;
              final isSelected = optIdx == selected;

              Color bgColor;
              Color borderColor;
              Color textColor;

              if (!answered) {
                bgColor = Theme.of(context).cardColor;
                borderColor = Colors.grey.withOpacity(0.3);
                textColor = Theme.of(context).colorScheme.onSurface;
              } else if (isCorrect) {
                bgColor = const Color(0xFFE8F5E9);
                borderColor = const Color(0xFF2E7D32);
                textColor = const Color(0xFF1B5E20);
              } else if (isSelected) {
                bgColor = const Color(0xFFFFEBEE);
                borderColor = const Color(0xFFD32F2F);
                textColor = const Color(0xFFD32F2F);
              } else {
                bgColor = Theme.of(context).cardColor.withOpacity(0.5);
                borderColor = Colors.grey.withOpacity(0.2);
                textColor = Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.5);
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => controller.answerQuiz(optIdx),
                  child: AnimatedContainer(
                    duration: 200.ms,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: borderColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: answered && isCorrect
                                ? const Icon(Icons.check,
                                    size: 16, color: Color(0xFF2E7D32))
                                : answered && isSelected
                                    ? const Icon(Icons.close,
                                        size: 16, color: Color(0xFFD32F2F))
                                    : Text(
                                        String.fromCharCode(65 + optIdx),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: textColor,
                                        ),
                                      ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            opt,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: textColor),
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: (optIdx * 80).ms).fadeIn().slideX(
                      begin: 0.1, duration: 250.ms),
                ),
              );
            }),

            if (answered) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        idx < controller.quizQuestions.length - 1
                            ? 'Келесі'
                            : 'Нәтижені көру',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ).animate().fadeIn().slideY(begin: 0.3),
            ],
          ],
        ),
      );
    });
  }
}

// ─── FINISHED ─────────────────────────────────────────────────────────────────
class _FinishedView extends StatelessWidget {
  final WordController controller;
  const _FinishedView({required this.controller});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final score = controller.quizScore.value;

    String message;
    Color scoreColor;
    if (score == 10) {
      message = 'Керемет! Сіз тіл шебересіз! 🏆';
      scoreColor = Colors.amber;
    } else if (score >= 7) {
      message = 'Тамаша нәтиже! Жалғастыр! 🌟';
      scoreColor = const Color(0xFF2E7D32);
    } else if (score >= 5) {
      message = 'Жаман емес, бірақ үйренуді жалғастыр! 📚';
      scoreColor = const Color(0xFFF57F17);
    } else {
      message = 'Сөздікпен жаттығуды жалғастыр! 💪';
      scoreColor = const Color(0xFFD32F2F);
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Score circle
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scoreColor.withOpacity(0.1),
                border: Border.all(color: scoreColor, width: 4),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$score',
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      color: scoreColor,
                    ),
                  ),
                  Text(
                    '/ 10',
                    style: TextStyle(fontSize: 16, color: scoreColor),
                  ),
                ],
              ),
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut),

            const SizedBox(height: 24),

            Text(
              'Нәтиже',
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w800),
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 12),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 16),

            if (controller.bestScore.value == score && score > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events,
                        color: Colors.amber, size: 18),
                    SizedBox(width: 6),
                    Text('Жаңа рекорд!',
                        style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: controller.startQuiz,
                icon: const Icon(Icons.replay),
                label: const Text('Қайта ойнау',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26)),
                ),
              ),
            ).animate().fadeIn(delay: 600.ms),

            const SizedBox(height: 12),

            TextButton(
              onPressed: controller.resetQuiz,
              child: Text('Мәзірге оралу',
                  style: TextStyle(color: Colors.grey[600])),
            ).animate().fadeIn(delay: 700.ms),
          ],
        ),
      ),
    );
  }
}
