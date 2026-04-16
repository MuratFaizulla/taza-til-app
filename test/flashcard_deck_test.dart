import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/word.dart';

// Флэшкарт колодасы логикасы — _prepareDeck-тен шығарылған
List<Word> prepareDeck(List<Word> allWords, Set<String> learnedKalkas,
    {int deckSize = 20}) {
  final unlearned = allWords
      .where((w) => !learnedKalkas.contains(w.kalka))
      .toList();
  final learned = allWords
      .where((w) => learnedKalkas.contains(w.kalka))
      .toList();
  final combined = [...unlearned, ...learned];
  return combined.take(deckSize).toList();
}

List<Word> _makeWords(int count) => List.generate(
      count,
      (i) => Word(
        kalka: 'калька $i',
        kazakh: 'қазақша $i',
        definition: 'анықтама $i',
        synonyms: [],
        example: 'мысал $i',
        category: 'everyday',
        difficulty: 1,
      ),
    );

void main() {
  group('prepareDeck — колода дайындау', () {
    test('үйренілмеген сөздер алдымен тізімде тұрады', () {
      final words = _makeWords(5);
      final learned = {words[0].kalka, words[1].kalka}; // 0 және 1 үйренілген

      final deck = prepareDeck(words, learned, deckSize: 5);

      // Алғашқы 3 сөз үйренілмеген болуы керек
      expect(deck[0].kalka, isNot(anyOf('калька 0', 'калька 1')));
      expect(deck[1].kalka, isNot(anyOf('калька 0', 'калька 1')));
      expect(deck[2].kalka, isNot(anyOf('калька 0', 'калька 1')));
    });

    test('барлығы үйренілген болса — үйренілгендер де кіреді', () {
      final words = _makeWords(3);
      final learned = {words[0].kalka, words[1].kalka, words[2].kalka};

      final deck = prepareDeck(words, learned, deckSize: 3);
      expect(deck.length, 3);
    });

    test('deckSize шегіне дейін ғана алады', () {
      final words = _makeWords(100);
      final deck = prepareDeck(words, {}, deckSize: 20);
      expect(deck.length, 20);
    });

    test('сөздер санынан аз deckSize болса — бар сөзді алады', () {
      final words = _makeWords(5);
      final deck = prepareDeck(words, {}, deckSize: 20);
      expect(deck.length, 5);
    });

    test('бос база — бос колода', () {
      final deck = prepareDeck([], {}, deckSize: 20);
      expect(deck, isEmpty);
    });

    test('үйренілген жоқ — барлық сөздер үйренілмеген ретінде', () {
      final words = _makeWords(5);
      final deck = prepareDeck(words, {}, deckSize: 5);
      expect(deck.length, 5);
    });
  });

  group('prepareDeck — үлгерім есебі', () {
    test('үйренілген санын дұрыс санайды', () {
      final words = _makeWords(10);
      final learned = {
        words[0].kalka,
        words[1].kalka,
        words[2].kalka,
      };
      final unlearnedCount =
          words.where((w) => !learned.contains(w.kalka)).length;
      expect(unlearnedCount, 7);
      expect(learned.length, 3);
    });

    test('барлығы үйренілсе үлгерім 100%', () {
      final words = _makeWords(5);
      final learned = words.map((w) => w.kalka).toSet();
      final percent = learned.length / words.length;
      expect(percent, 1.0);
    });

    test('ешкім үйренілмесе үлгерім 0%', () {
      final words = _makeWords(5);
      const learned = <String>{};
      final percent = learned.length / words.length;
      expect(percent, 0.0);
    });
  });
}
