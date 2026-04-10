import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
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

  // ── TTS ────────────────────────────────────────────────────────────────────
  late FlutterTts _tts;
  final RxBool isSpeaking = false.obs;
  final RxBool ttsAvailable = false.obs;

  late final Map<String, Word> _kalkaMap;

  @override
  void onInit() {
    super.onInit();
    allWords.assignAll(WordsData.words);
    filteredWords.assignAll(WordsData.words);
    _kalkaMap = WordsData.kalkaMap;
    _initTts();
    _loadSettings();
  }

  @override
  void onClose() {
    _tts.stop();
    super.onClose();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TTS
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> _initTts() async {
    try {
      _tts = FlutterTts();
      final result = await _tts.setLanguage('kk-KZ');
      if (result != 1) await _tts.setLanguage('ru-RU');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      _tts.setStartHandler(() => isSpeaking.value = true);
      _tts.setCompletionHandler(() => isSpeaking.value = false);
      _tts.setCancelHandler(() => isSpeaking.value = false);
      _tts.setErrorHandler((_) => isSpeaking.value = false);
      ttsAvailable.value = true;
    } catch (_) {
      ttsAvailable.value = false;
    }
  }

  Future<void> speak(String text) async {
    if (!ttsAvailable.value) return;
    if (isSpeaking.value) {
      await _tts.stop();
      isSpeaking.value = false;
      return;
    }
    await _tts.speak(text);
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

    final favList = box.get('favorites', defaultValue: <dynamic>[]) as List;
    favorites.assignAll(favList.map((e) => e.toString()));

    final histList =
        box.get('detectorHistory', defaultValue: <dynamic>[]) as List;
    for (final item in histList) {
      if (item is Map) {
        detectorHistory.add(Map<String, dynamic>.from(item));
      }
    }

    _loadWordOfDay();
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
    final seen = <String>{};
    final result = <Word>[];
    final tokens = text.split(RegExp(r'[^\p{L}\p{N}]+', unicode: true));
    for (final token in tokens) {
      final clean = token.toLowerCase().trim();
      if (clean.isEmpty || seen.contains(clean)) continue;
      final match = _kalkaMap[clean];
      if (match != null) {
        seen.add(clean);
        result.add(match);
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

  // ── AI rewrite (Claude or Grok) ────────────────────────────────────────────
  static const String _prompt =
      'Мына мәтіндегі орыс сөздерін (калька) таза қазақша баламасымен ауыстыр. '
      'Тек мәтінді ғана қайтар, ешқандай түсіндірме жазба:\n\n';

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
    } catch (e) {
      Get.snackbar('Қате', 'Байланыс қатесі. Интернетті тексеріңіз.',
          snackPosition: SnackPosition.BOTTOM);
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
          Uri.parse('https://api.x.ai/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer ${grokApiKey.value}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': 'grok-3-fast',
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
