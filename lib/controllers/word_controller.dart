import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../models/word.dart';
import '../models/quiz_question.dart';
import '../data/words_data.dart';

class WordController extends GetxController {
  // ── Core data ──────────────────────────────────────────────────────────────
  final RxList<Word> allWords = <Word>[].obs;
  final RxList<Word> filteredWords = <Word>[].obs;

  // ── Search & filter ────────────────────────────────────────────────────────
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'all'.obs;
  final RxBool showFavoritesOnly = false.obs;

  // ── Favorites ──────────────────────────────────────────────────────────────
  final RxList<String> favorites = <String>[].obs;

  // ── Navigation ─────────────────────────────────────────────────────────────
  final RxInt currentTabIndex = 0.obs;

  // ── Detector ───────────────────────────────────────────────────────────────
  final RxString detectorText = ''.obs;
  final RxList<Map<String, dynamic>> detectorHistory =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> aiHistory =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoadingAI = false.obs;
  final RxString aiRewrittenText = ''.obs;

  // ── Word of Day ────────────────────────────────────────────────────────────
  final Rx<Word?> wordOfDay = Rx<Word?>(null);

  // ── Quiz ───────────────────────────────────────────────────────────────────
  final RxString quizState = 'idle'.obs; // idle | playing | finished
  final RxInt currentQuestionIndex = 0.obs;
  final RxInt quizScore = 0.obs;
  final RxList<QuizQuestion> quizQuestions = <QuizQuestion>[].obs;
  final RxInt selectedAnswer = (-1).obs;
  final RxBool showAnswerResult = false.obs;
  final RxInt bestScore = 0.obs;

  // ── Settings ───────────────────────────────────────────────────────────────
  final RxBool isDarkMode = false.obs;
  final RxString claudeApiKey = ''.obs;
  final RxString grokApiKey = ''.obs;
  final RxString selectedAIProvider = 'claude'.obs; // 'claude' | 'grok'

  // ── Font Scale ──────────────────────────────────────────────────────────────
  final RxDouble fontScale = 1.0.obs;

  // ── Word of Day stats ──────────────────────────────────────────────────────
  final RxInt learnedCount = 0.obs;
  final RxList<String> learnedWords = <String>[].obs;

  late final Map<String, Word> _kalkaMap;

  @override
  void onInit() {
    super.onInit();
    allWords.assignAll(WordsData.words);
    filteredWords.assignAll(WordsData.words);
    _kalkaMap = WordsData.kalkaMap;
    _loadSettings();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Settings & persistence
  // ══════════════════════════════════════════════════════════════════════════
  void _loadSettings() {
    final box = Hive.box('settings');

    isDarkMode.value = box.get('isDarkMode', defaultValue: false) as bool;
    claudeApiKey.value = box.get('claudeApiKey', defaultValue: '') as String;
    grokApiKey.value = box.get('grokApiKey', defaultValue: '') as String;
    selectedAIProvider.value =
        box.get('selectedAIProvider', defaultValue: 'claude') as String;
    bestScore.value = box.get('bestScore', defaultValue: 0) as int;

    // Font scale
    fontScale.value =
        (box.get('fontScale', defaultValue: 1.0) as num).toDouble();

    final favList = box.get('favorites', defaultValue: <dynamic>[]) as List;
    favorites.assignAll(favList.map((e) => e.toString()));

    final histList =
        box.get('detectorHistory', defaultValue: <dynamic>[]) as List;
    for (final item in histList) {
      if (item is Map) {
        detectorHistory.add(Map<String, dynamic>.from(item));
      }
    }

    final aiHistList =
        box.get('aiHistory', defaultValue: <dynamic>[]) as List;
    for (final item in aiHistList) {
      if (item is Map) {
        aiHistory.add(Map<String, dynamic>.from(item));
      }
    }

    _loadWordOfDay();

    final learnedList =
        box.get('learnedWords', defaultValue: <dynamic>[]) as List;
    learnedWords.assignAll(learnedList.map((e) => e.toString()));
    learnedCount.value = learnedWords.length;
  }

  void toggleDarkMode() {
    isDarkMode.value = !isDarkMode.value;
    Hive.box('settings').put('isDarkMode', isDarkMode.value);
    Get.changeThemeMode(
        isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void saveClaudeApiKey(String key) {
    claudeApiKey.value = key.trim();
    Hive.box('settings').put('claudeApiKey', claudeApiKey.value);
  }

  void saveGrokApiKey(String key) {
    grokApiKey.value = key.trim();
    Hive.box('settings').put('grokApiKey', grokApiKey.value);
  }

  void setAIProvider(String provider) {
    selectedAIProvider.value = provider;
    Hive.box('settings').put('selectedAIProvider', provider);
  }

  String get activeApiKey =>
      selectedAIProvider.value == 'claude' ? claudeApiKey.value : grokApiKey.value;

  bool get hasActiveKey => activeApiKey.isNotEmpty;

  // ── Font scale ─────────────────────────────────────────────────────────────
  void setFontScale(double scale) {
    fontScale.value = scale;
    Hive.box('settings').put('fontScale', scale);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Navigation
  // ══════════════════════════════════════════════════════════════════════════
  void changeTab(int index) => currentTabIndex.value = index;

  // ══════════════════════════════════════════════════════════════════════════
  // Search & Filter
  // ══════════════════════════════════════════════════════════════════════════
  void search(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  void toggleFavoritesFilter() {
    showFavoritesOnly.value = !showFavoritesOnly.value;
    _applyFilters();
  }

  void _applyFilters() {
    var words = allWords.toList();
    if (selectedCategory.value != 'all') {
      words = words.where((w) => w.category == selectedCategory.value).toList();
    }
    if (showFavoritesOnly.value) {
      words = words
          .where((w) => favorites.contains(w.kalka.toLowerCase()))
          .toList();
    }
    if (searchQuery.value.trim().isNotEmpty) {
      final q = searchQuery.value.trim().toLowerCase();
      words = words
          .where((w) =>
              w.kalka.toLowerCase().contains(q) ||
              w.kazakh.toLowerCase().contains(q) ||
              w.definition.toLowerCase().contains(q) ||
              w.synonyms.any((s) => s.toLowerCase().contains(q)))
          .toList();
    }
    filteredWords.assignAll(words);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Favorites
  // ══════════════════════════════════════════════════════════════════════════
  void toggleFavorite(String kalka) {
    final key = kalka.toLowerCase();
    if (favorites.contains(key)) {
      favorites.remove(key);
    } else {
      favorites.add(key);
    }
    Hive.box('settings').put('favorites', favorites.toList());
    _applyFilters();
  }

  bool isFavorite(String kalka) => favorites.contains(kalka.toLowerCase());

  int get favoritesCount => favorites.length;

  // ══════════════════════════════════════════════════════════════════════════
  // Detector
  // ══════════════════════════════════════════════════════════════════════════
  void updateDetectorText(String text) {
    detectorText.value = text;
    aiRewrittenText.value = '';
  }

  Set<String> get kalkaWordSet => _kalkaMap.keys.toSet();

  Word? kalkaAlternative(String word) => _kalkaMap[word.toLowerCase()];

  List<Word> detectKalkaInText(String text) {
    if (text.trim().isEmpty) return [];
    final lowerText = text.toLowerCase();
    final result = <Word>[];
    final seen = <String>{};
    for (final entry in _kalkaMap.entries) {
      final phrase = entry.key; // already lowercase
      if (phrase.length < 4) continue;
      if (seen.contains(phrase)) continue;
      if (lowerText.contains(phrase)) {
        seen.add(phrase);
        result.add(entry.value);
      }
    }
    return result;
  }

  void saveToHistory(String text, int kalkaCount) {
    if (text.trim().isEmpty) return;
    detectorHistory.insert(0, {
      'text': text.length > 100 ? '${text.substring(0, 100)}...' : text,
      'kalkaCount': kalkaCount,
      'timestamp': DateTime.now().toIso8601String(),
    });
    if (detectorHistory.length > 20) detectorHistory.removeLast();
    Hive.box('settings').put('detectorHistory', detectorHistory.toList());
  }

  void clearHistory() {
    detectorHistory.clear();
    Hive.box('settings').put('detectorHistory', []);
  }

  void saveAiAnalysis(String inputText, String aiResult, String provider) {
    final truncated =
        inputText.length > 80 ? '${inputText.substring(0, 80)}...' : inputText;
    aiHistory.insert(0, {
      'text': truncated,
      'aiResult': aiResult,
      'provider': provider,
      'timestamp': DateTime.now().toIso8601String(),
    });
    if (aiHistory.length > 30) aiHistory.removeLast();
    Hive.box('settings').put('aiHistory', aiHistory.toList());
  }

  void clearAiHistory() {
    aiHistory.clear();
    Hive.box('settings').put('aiHistory', []);
  }

  // ── AI rewrite (Claude or Grok) ────────────────────────────────────────────
  static const String _prompt =
      'Сен — қазақ тілінің лингвистикасы, этимологиясы, терминологиясы және аударма теориясы '
      'бойынша PhD деңгейіндегі жоғары білікті сарапшысың. Қазақ тілінің түркі тамырын, '
      'Кеңес дәуірінен кейінгі терминжасамды, техникалық терминдердің қабылдануын және '
      'тілдік тазалық мәселелерін өте терең білесің.\n\n'
      'ҚАТАҢ ЕРЕЖЕЛЕР:\n'
      '• Егер тіркес қазақ тілінің өз сөздерінің табиғи комбинациясы болса (мысалы, «ата-баба»), '
      'оны «орысша калька» деп кінәлама. Тек нақты сөзбе-сөз аударма (loan translation) '
      'арқылы жасалған жағдайда ғана калька деп ата.\n'
      '• Тек қазақша сөздерден тұрса да, орыс синтаксисі үлгісімен жасалса — синтаксистік калька.\n'
      '  Мысал: «жаңбыр басталды» → орысша «дождь начался» үлгісі. Таза қазақша: «жаңбыр жауып кетті».\n'
      '• Техникалық терминдерде қазіргі нақты қолданысты ескер: ресми құжаттар, Wikipedia, '
      'IT-сала, оқулықтар, мемлекеттік стандарттар.\n'
      '• Баламаларды ойлап таппа — шынайы қолданыста бар нұсқаларды ғана келтір.\n'
      '• Жауапты кесіп тастама, толық аяқта.\n\n'
      'Берілген мәтіндегі БАРЛЫҚ калька сөздер мен тіркестерді тап. '
      'Әрбір табылған калька үшін мына 7 бөлімді толық жаз:\n\n'
      '«[калька сөз/тіркес]» талдауы:\n\n'
      '1. Калька ма?\n'
      'Иә / Жоқ / Жартылай. Қандай түрі (фразалық, морфологиялық, семантикалық, синтаксистік)? Қысқаша негізде.\n\n'
      '2. Этимология және шығу тарихы\n'
      '• Түпнұсқа (ағылшын, орыс немесе басқа): [...]\n'
      '• Қазақ тіліне ену жолы, уақыты және делдал тіл (егер бар болса): [...]\n'
      '• Қазақтың өз тіліндегі ежелгі тамыры немесе табиғи баламалары (түркі контексті): [...]\n\n'
      '3. Табиғилық деңгейі\n'
      'Қазақтың сөйлеу тіліне, грамматикасына, мәдениетіне және қазіргі қолданысына қаншалықты сәйкес?\n'
      '• Ресми қолданыста: [...]\n'
      '• IT/техникалық салада: [...]\n'
      '• Күнделікті тілде: [...]\n\n'
      '4. Артықшылықтары мен кемшіліктері\n'
      '+ [...]\n'
      '- [...]\n\n'
      '5. Балама нұсқалар\n'
      '• [нұсқа 1] ← табиғилық/қысқалық/түсініктілік/қолданыс жиілігі бойынша ең жақсы\n'
      '• [нұсқа 2] — [...]\n'
      '• [нұсқа 3] — [...]\n\n'
      '6. Салыстыру\n'
      '❌ Калька/негізгі нұсқа: [мысал сөйлем]\n'
      '✅ Ең табиғи/қолайлы нұсқа: [мысал сөйлем]\n'
      '★ Ұсынылатын нұсқа: [нұсқа] — себебі: [...]\n\n'
      '7. Қорытынды және практикалық ұсыныс\n'
      '• Ресми құжаттарда / ғылыми жұмыстарда: [...]\n'
      '• IT-салада / техникалық мәтіндерде: [...]\n'
      '• Күнделікті сөйлеуде: [...]\n'
      '• Жақсарту мүмкіндігі: [...]\n\n'
      'Бірнеше калька болса, әрқайсысын жеке талда, арасына --- қой.\n'
      'Калька мүлдем жоқ болса ҒАНА: «✅ Мәтін таза — калька сөздер жоқ!» деп жаз.\n\n'
      'Мәтін:\n';

  Future<void> rewriteWithAI(String text) async {
    if (!hasActiveKey) {
      final provider =
          selectedAIProvider.value == 'claude' ? 'Claude' : 'Grok';
      Get.snackbar(
        'API кілті жоқ',
        'Баптаулар бетінде $provider API кілтін енгізіңіз',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 10,
      );
      return;
    }
    isLoadingAI.value = true;
    aiRewrittenText.value = '';
    try {
      final result = selectedAIProvider.value == 'claude'
          ? await _callClaude(text)
          : await _callGrok(text);
      aiRewrittenText.value = result;
      saveAiAnalysis(text, result, selectedAIProvider.value);
    } catch (e) {
      final err = e.toString().toLowerCase();
      String msg;
      if (err.contains('xmlhttprequest') ||
          err.contains('cors') ||
          err.contains('failed to fetch') ||
          err.contains('network error')) {
        msg = 'Браузерде API-ға тікелей қол жеткізу мүмкін емес (CORS). '
            'Қосымшаны мобиль немесе десктоп режимінде іске қосыңыз.';
      } else if (err.contains('timeout') || err.contains('timed out')) {
        msg = 'Уақыт асып кетті. Қайта көріңіз.';
      } else if (err.contains('401') || err.contains('403')) {
        msg = 'API кілті дұрыс емес. Баптауларда тексеріңіз.';
      } else {
        msg = 'Қате: ${e.toString()}';
      }
      Get.snackbar(
        'Қате',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(12),
      );
    } finally {
      isLoadingAI.value = false;
    }
  }

  Future<String> _callClaude(String text) async {
    final response = await http
        .post(
          Uri.parse('https://api.anthropic.com/v1/messages'),
          headers: {
            'x-api-key': claudeApiKey.value,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json',
          },
          body: jsonEncode({
            'model': 'claude-haiku-4-5-20251001',
            'max_tokens': 1024,
            'messages': [
              {'role': 'user', 'content': '$_prompt"$text"'}
            ],
          }),
        )
        .timeout(const Duration(seconds: 20));
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return (data['content'][0]['text'] as String).trim();
    }
    throw Exception('Claude API қатесі: ${response.statusCode}');
  }

  Future<String> _callGrok(String text) async {
    final response = await http
        .post(
          Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer ${grokApiKey.value}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': 'llama-3.3-70b-versatile',
            'messages': [
              {'role': 'user', 'content': '$_prompt"$text"'}
            ],
            'temperature': 0.3,
            'max_tokens': 1024,
          }),
        )
        .timeout(const Duration(seconds: 20));
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return (data['choices'][0]['message']['content'] as String).trim();
    }
    throw Exception('Grok API қатесі: ${response.statusCode}');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Word of Day
  // ══════════════════════════════════════════════════════════════════════════
  void _loadWordOfDay() {
    final box = Hive.box('settings');
    final today = _todayStr();
    final storedDate = box.get('wordOfDayDate', defaultValue: '') as String;
    final storedIndex = box.get('wordOfDayIndex', defaultValue: -1) as int;

    if (storedDate == today &&
        storedIndex >= 0 &&
        storedIndex < allWords.length) {
      wordOfDay.value = allWords[storedIndex];
    } else {
      final now = DateTime.now();
      final index =
          now.difference(DateTime(now.year, 1, 1)).inDays % allWords.length;
      wordOfDay.value = allWords[index];
      box.put('wordOfDayDate', today);
      box.put('wordOfDayIndex', index);
    }
  }

  String _todayStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  // ── Word of Day helpers ────────────────────────────────────────────────────
  void markWordAsLearned(String kalka) {
    if (!learnedWords.contains(kalka)) {
      learnedWords.add(kalka);
      learnedCount.value = learnedWords.length;
      Hive.box('settings').put('learnedWords', learnedWords.toList());
    }
  }

  bool isWordLearned(String kalka) => learnedWords.contains(kalka);

  void clearLearnedWords() {
    learnedWords.clear();
    learnedCount.value = 0;
    Hive.box('settings').put('learnedWords', []);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Quiz
  // ══════════════════════════════════════════════════════════════════════════
  void startQuiz() {
    final rng = Random();
    final shuffled = [...allWords]..shuffle(rng);
    final selected = shuffled.take(10).toList();

    quizQuestions.assignAll(selected.map((word) {
      final wrongs = allWords
          .where((w) => w.kazakh != word.kazakh)
          .toList()
        ..shuffle(rng);
      final opts = [word.kazakh, ...wrongs.take(3).map((w) => w.kazakh)]
        ..shuffle(rng);
      return QuizQuestion(
        word: word,
        options: opts,
        correctIndex: opts.indexOf(word.kazakh),
      );
    }));

    currentQuestionIndex.value = 0;
    quizScore.value = 0;
    selectedAnswer.value = -1;
    showAnswerResult.value = false;
    quizState.value = 'playing';
  }

  void answerQuiz(int answerIndex) {
    if (showAnswerResult.value) return;
    selectedAnswer.value = answerIndex;
    showAnswerResult.value = true;
    if (answerIndex == quizQuestions[currentQuestionIndex.value].correctIndex) {
      quizScore.value++;
    }
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < quizQuestions.length - 1) {
      currentQuestionIndex.value++;
      selectedAnswer.value = -1;
      showAnswerResult.value = false;
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    quizState.value = 'finished';
    if (quizScore.value > bestScore.value) {
      bestScore.value = quizScore.value;
      Hive.box('settings').put('bestScore', bestScore.value);
    }
  }

  void resetQuiz() {
    quizState.value = 'idle';
    currentQuestionIndex.value = 0;
    quizScore.value = 0;
    selectedAnswer.value = -1;
    showAnswerResult.value = false;
    quizQuestions.clear();
  }

  String categoryName(String cat) =>
      WordsData.categoryNames[cat] ?? 'Барлығы';

  List<String> get categories => WordsData.categories;

  String difficultyLabel(int d) {
    switch (d) {
      case 1: return 'Оңай';
      case 2: return 'Орташа';
      case 3: return 'Қиын';
      default: return '';
    }
  }

  Color difficultyColor(int d) {
    switch (d) {
      case 1: return const Color(0xFF2E7D32);
      case 2: return const Color(0xFFF57F17);
      case 3: return const Color(0xFFD32F2F);
      default: return Colors.grey;
    }
  }
}
