import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      emoji: '🇰🇿',
      title: 'Таза Тіл-ге қош келдің!',
      subtitle:
          'Қазақ мәтіндеріндегі орыс калькаларын\nанықтайтын ақылды қосымша',
      bullets: [
        '📚 1 748 калька сөз базасы',
        '🤖 Claude және Groq AI қолдауы',
        '🎮 Викторина мен жаттығу режимдері',
      ],
      gradient: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
    ),
    _OnboardingPage(
      emoji: '🔍',
      title: 'Калькаларды анықта',
      subtitle:
          'Мәтін жазсаң — қате қолданыстар\nавтоматты түрде белгіленеді',
      bullets: [
        '❌  "профилактикалық шаралар"',
        '✅  "алдын алу шаралары"',
        '⚡ ЖИ арқылы терең талдау',
      ],
      gradient: [Color(0xFF1565C0), Color(0xFF1976D2)],
    ),
    _OnboardingPage(
      emoji: '🃏',
      title: 'Жаттығу режимі',
      subtitle: 'Флэшкарталармен сөздерді жылдам\nүйрен — свайп оң/сол',
      bullets: [
        '👉 Оңға — білдім ✅',
        '👈 Солға — білмедім ❌',
        '📊 Үлгерімің автоматты сақталады',
      ],
      gradient: [Color(0xFF6A1B9A), Color(0xFF7B1FA2)],
    ),
    _OnboardingPage(
      emoji: '🏆',
      title: 'Викторина мен сөздік',
      subtitle:
          '10 сұрақты квизбен білімді тексер,\nсөздікте 1 700+ сөзді қарастыр',
      bullets: [
        '🎯 10 сұрақ, 4 нұсқа',
        '🌟 Рекорд жүйесі',
        '🔖 Таңдаулы сөздер',
      ],
      gradient: [Color(0xFFE65100), Color(0xFFF57C00)],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    Hive.box('settings').put('onboardingDone', true);
    Get.off(() => const HomeScreen(), transition: Transition.fade);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (_, i) => _PageContent(page: _pages[i]),
          ),
          // Top skip button
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AnimatedOpacity(
                  opacity: _currentPage < _pages.length - 1 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: TextButton(
                    onPressed: _finish,
                    child: const Text(
                      'Өткізу',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Bottom controls
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dot indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == i ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == i
                                ? Colors.white
                                : Colors.white38,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Next / Start button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor:
                              _pages[_currentPage].gradient.first,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            _currentPage == _pages.length - 1
                                ? 'Бастау! 🚀'
                                : 'Келесі →',
                            key: ValueKey(_currentPage),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _pages[_currentPage].gradient.first,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  final _OnboardingPage page;
  const _PageContent({required this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: page.gradient,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 80, 32, 160),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Emoji icon
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(page.emoji,
                      style: const TextStyle(fontSize: 56)),
                ),
              ),
              const SizedBox(height: 40),
              // Title
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 14),
              // Subtitle
              Text(
                page.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.85),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),
              // Bullet points
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: page.bullets
                      .map((b) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              b,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                height: 1.4,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final String emoji;
  final String title;
  final String subtitle;
  final List<String> bullets;
  final List<Color> gradient;

  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.bullets,
    required this.gradient,
  });
}
