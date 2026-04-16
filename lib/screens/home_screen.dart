import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/word_controller.dart';
import 'dictionary_screen.dart';
import 'detector_screen.dart';
import 'quiz_screen.dart';
import 'word_of_day_screen.dart';
import 'flashcard_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WordController>();

    const tabs = [
      _TabItem(label: 'Сөздік',     icon: Icons.menu_book_outlined,     activeIcon: Icons.menu_book),
      _TabItem(label: 'Анықтаушы', icon: Icons.find_in_page_outlined,   activeIcon: Icons.find_in_page),
      _TabItem(label: 'Викторина', icon: Icons.quiz_outlined,            activeIcon: Icons.quiz),
      _TabItem(label: 'Күн сөзі',  icon: Icons.wb_sunny_outlined,       activeIcon: Icons.wb_sunny),
    ];

    return Obx(() {
      final idx = controller.currentTabIndex.value;
      final isFlashcard = idx == 4;

      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: isFlashcard
            ? AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      size: 20, color: Colors.white),
                  onPressed: () => controller.changeTab(2),
                ),
                title: const Text('Жаттығу — Флэшкарталар',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: Colors.white)),
              )
            : AppBar(
                title: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'ТТ',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: 0.5),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Таза Тіл',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Colors.white,
                              letterSpacing: 0.3)),
                      Text('Қазақ тілінің тазалық тексергіші',
                          style:
                              TextStyle(fontSize: 11, color: Colors.white70)),
                    ],
                  ),
                ]),
                actions: [
                  if (idx == 0)
                    Obx(() => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${controller.filteredWords.length} сөз',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        )),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined,
                        color: Colors.white),
                    onPressed: () => Get.to(() => const SettingsScreen()),
                  ),
                ],
              ),
        body: IndexedStack(
          index: idx,
          children: [
            const DictionaryScreen(),
            DetectorScreen(),
            const QuizScreen(),
            const WordOfDayScreen(),
            const FlashcardScreen(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: idx.clamp(0, 3),
            onTap: controller.changeTab,
            elevation: 0,
            selectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            items: tabs
                .map((t) => BottomNavigationBarItem(
                      icon: Icon(t.icon),
                      activeIcon: Icon(t.activeIcon),
                      label: t.label,
                    ))
                .toList(),
          ),
        ),
      );
    });
  }
}

class _TabItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  const _TabItem(
      {required this.label,
      required this.icon,
      required this.activeIcon});
}
