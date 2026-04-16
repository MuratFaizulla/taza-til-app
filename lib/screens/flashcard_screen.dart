import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/word_controller.dart';
import '../models/word.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with TickerProviderStateMixin {
  final WordController controller = Get.find<WordController>();

  late List<Word> _deck;
  int _currentIndex = 0;
  bool _isFlipped = false;
  int _knownCount = 0;
  int _unknownCount = 0;

  // Drag state
  double _dragOffset = 0;

  // Animations
  late AnimationController _flipController;
  late AnimationController _snapController;
  late Animation<double> _snapAnimation;

  @override
  void initState() {
    super.initState();
    _prepareDeck();

    _flipController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _snapController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _snapAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.elasticOut),
    );
  }

  void _prepareDeck() {
    final learned = controller.learnedWords.toSet();
    final unlearned = [...controller.allWords]
        .where((w) => !learned.contains(w.kalka))
        .toList()
      ..shuffle();
    final learnedList = [...controller.allWords]
        .where((w) => learned.contains(w.kalka))
        .toList()
      ..shuffle();
    // Unlearned words first, then already learned (for review)
    final combined = [...unlearned, ...learnedList];
    _deck = combined.take(20).toList();
  }

  @override
  void dispose() {
    _flipController.dispose();
    _snapController.dispose();
    super.dispose();
  }

  bool get _isFinished => _currentIndex >= _deck.length;

  void _flipCard() {
    if (_flipController.isAnimating) return;
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  void _nextCard(bool known) {
    if (known && _currentIndex < _deck.length) {
      controller.markWordAsLearned(_deck[_currentIndex].kalka);
    }
    setState(() {
      if (known) {
        _knownCount++;
      } else {
        _unknownCount++;
      }
      _currentIndex++;
      _isFlipped = false;
      _dragOffset = 0;
    });
    _flipController.reset();
  }

  void _snapBack() {
    final start = _dragOffset;
    _snapAnimation = Tween<double>(begin: start, end: 0).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.elasticOut),
    );
    _snapController.forward(from: 0).then((_) {
      if (mounted) setState(() => _dragOffset = 0);
    });
    _snapAnimation.addListener(() {
      if (mounted) setState(() => _dragOffset = _snapAnimation.value);
    });
  }

  void _restart() {
    _prepareDeck();
    setState(() {
      _currentIndex = 0;
      _knownCount = 0;
      _unknownCount = 0;
      _isFlipped = false;
      _dragOffset = 0;
    });
    _flipController.reset();
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) return _buildResults();

    final word = _deck[_currentIndex];
    final progress = _currentIndex / _deck.length;

    return Column(
      children: [
        _buildProgressBar(progress),
        _buildStats(),
        const SizedBox(height: 8),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Next card peek (behind)
              if (_currentIndex + 1 < _deck.length)
                Transform.scale(
                  scale: 0.93,
                  child: Transform.translate(
                    offset: const Offset(0, 12),
                    child: _buildCardSurface(
                      _deck[_currentIndex + 1],
                      isFront: true,
                      dragOffset: 0,
                      isPreview: true,
                    ),
                  ),
                ),
              // Current card
              GestureDetector(
                onHorizontalDragUpdate: (d) {
                  setState(() {
                    _dragOffset += d.delta.dx;
                  });
                },
                onHorizontalDragEnd: (_) {
                  if (_dragOffset > 100) {
                    _nextCard(true);
                  } else if (_dragOffset < -100) {
                    _nextCard(false);
                  } else {
                    _snapBack();
                  }
                },
                onTap: _flipCard,
                child: AnimatedBuilder(
                  animation: _flipController,
                  builder: (context, _) {
                    final angle = _flipController.value * pi;
                    final isFront = angle <= pi / 2;
                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(isFront ? angle : angle - pi),
                      alignment: Alignment.center,
                      child: _buildCardSurface(
                        word,
                        isFront: isFront,
                        dragOffset: _dragOffset,
                        isPreview: false,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildSwipeHint(),
        const SizedBox(height: 12),
        _buildButtons(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCardSurface(
    Word word, {
    required bool isFront,
    required double dragOffset,
    required bool isPreview,
  }) {
    final isSwipingRight = dragOffset > 50 && !isPreview;
    final isSwipingLeft = dragOffset < -50 && !isPreview;
    final tiltAngle = dragOffset / 600;

    return Transform.translate(
      offset: Offset(dragOffset, dragOffset.abs() * 0.08),
      child: Transform.rotate(
        angle: tiltAngle,
        child: isFront
            ? _buildFront(word, isSwipingRight, isSwipingLeft, isPreview)
            : _buildBack(word),
      ),
    );
  }

  Widget _buildFront(
      Word word, bool isSwipingRight, bool isSwipingLeft, bool isPreview) {
    return Container(
      width: 320,
      height: 400,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSwipingRight
              ? const Color(0xFF2E7D32)
              : isSwipingLeft
                  ? const Color(0xFFD32F2F)
                  : Colors.grey.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isPreview ? 0.06 : 0.14),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Swipe overlays
          if (isSwipingRight)
            Positioned(
              top: 20,
              left: 20,
              child: _SwipeLabel(
                  label: '✅ БІЛДІМ', color: const Color(0xFF2E7D32)),
            ),
          if (isSwipingLeft)
            Positioned(
              top: 20,
              right: 20,
              child: _SwipeLabel(
                  label: '❌ БІЛМЕДІМ', color: const Color(0xFFD32F2F)),
            ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('❌ Калька сөз',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFD32F2F),
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    word.kalka,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD32F2F),
                        height: 1.35),
                  ),
                  const SizedBox(height: 36),
                  if (!isPreview) ...[
                    Icon(Icons.touch_app,
                        color: Colors.grey[350], size: 30),
                    const SizedBox(height: 6),
                    Text('Дұрысын көру үшін басыңыз',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey[400])),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBack(Word word) {
    return Container(
      width: 320,
      height: 400,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F5E9), Color(0xFFDCEDC8)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFA5D6A7), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('✅ Дұрыс нұсқа',
                  style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 24),
            Text(
              word.kazakh,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B5E20),
                  height: 1.35),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                word.definition,
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2E7D32),
                    height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_currentIndex + 1} / ${_deck.length}',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              Text('${(progress * 100).toInt()}%',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(primary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        children: [
          _StatChip(
              count: _knownCount,
              label: 'Білдім',
              color: const Color(0xFF2E7D32)),
          const Spacer(),
          _StatChip(
              count: _unknownCount,
              label: 'Білмедім',
              color: const Color(0xFFD32F2F)),
        ],
      ),
    );
  }

  Widget _buildSwipeHint() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.arrow_back, size: 14, color: Colors.grey[400]),
        const SizedBox(width: 4),
        Text('білмедім',
            style: TextStyle(fontSize: 11, color: Colors.grey[400])),
        const SizedBox(width: 16),
        Text('свайп',
            style: TextStyle(fontSize: 11, color: Colors.grey[400])),
        const SizedBox(width: 16),
        Text('білдім',
            style: TextStyle(fontSize: 11, color: Colors.grey[400])),
        const SizedBox(width: 4),
        Icon(Icons.arrow_forward, size: 14, color: Colors.grey[400]),
      ],
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _nextCard(false),
              icon: const Icon(Icons.close, size: 20),
              label: const Text('Білмедім'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFEBEE),
                foregroundColor: const Color(0xFFD32F2F),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _nextCard(true),
              icon: const Icon(Icons.check, size: 20),
              label: const Text('Білдім'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8F5E9),
                foregroundColor: const Color(0xFF2E7D32),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final total = _deck.length;
    final percent = total > 0 ? (_knownCount / total * 100).toInt() : 0;
    final primary = Theme.of(context).colorScheme.primary;
    final emoji = percent >= 80
        ? '🏆'
        : percent >= 60
            ? '🎉'
            : '📚';
    final message = percent >= 80
        ? 'Тамаша нәтиже!'
        : percent >= 60
            ? 'Керемет!'
            : 'Жалғастыр, жақсы болады!';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 72)),
            const SizedBox(height: 12),
            Text(message,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Сессия аяқталды',
                style: TextStyle(fontSize: 13, color: Colors.grey[500])),
            const SizedBox(height: 28),
            _ResultRow(
                label: '✅ Білдім',
                value: '$_knownCount',
                color: const Color(0xFF2E7D32)),
            const SizedBox(height: 8),
            _ResultRow(
                label: '❌ Білмедім',
                value: '$_unknownCount',
                color: const Color(0xFFD32F2F)),
            const SizedBox(height: 8),
            _ResultRow(label: '📊 Нәтиже', value: '$percent%', color: primary),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _restart,
                icon: const Icon(Icons.refresh),
                label: const Text('Қайта бастау'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SwipeLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 2),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w800, fontSize: 14)),
    );
  }
}

class _StatChip extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  const _StatChip(
      {required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$count',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color)),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ResultRow(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }
}
