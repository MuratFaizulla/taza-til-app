import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/word.dart';

void main() {
  group('Word model', () {
    const testWord = Word(
      kalka: 'профилактикалық шаралар',
      kazakh: 'алдын алу шаралары',
      definition: 'Профилактические меры',
      synonyms: ['алдын алу', 'сақтану'],
      example: 'алдын алу шаралары қабылданды',
      category: 'everyday',
      difficulty: 2,
    );

    test('toMap сақтайды барлық өрістерді', () {
      final map = testWord.toMap();
      expect(map['kalka'], 'профилактикалық шаралар');
      expect(map['kazakh'], 'алдын алу шаралары');
      expect(map['definition'], 'Профилактические меры');
      expect(map['synonyms'], ['алдын алу', 'сақтану']);
      expect(map['example'], 'алдын алу шаралары қабылданды');
      expect(map['category'], 'everyday');
      expect(map['difficulty'], 2);
    });

    test('fromMap дұрыс жасайды Word объектін', () {
      final map = testWord.toMap();
      final restored = Word.fromMap(map);
      expect(restored.kalka, testWord.kalka);
      expect(restored.kazakh, testWord.kazakh);
      expect(restored.definition, testWord.definition);
      expect(restored.synonyms, testWord.synonyms);
      expect(restored.example, testWord.example);
      expect(restored.category, testWord.category);
      expect(restored.difficulty, testWord.difficulty);
    });

    test('fromMap бос category болса everyday деп алады', () {
      final map = testWord.toMap();
      map.remove('category');
      final word = Word.fromMap(map);
      expect(word.category, 'everyday');
    });

    test('fromMap бос difficulty болса 1 деп алады', () {
      final map = testWord.toMap();
      map.remove('difficulty');
      final word = Word.fromMap(map);
      expect(word.difficulty, 1);
    });

    test('synonyms бос тізім болуы мүмкін', () {
      const noSynonyms = Word(
        kalka: 'тест',
        kazakh: 'тест',
        definition: 'тест',
        synonyms: [],
        example: 'тест',
        category: 'everyday',
        difficulty: 1,
      );
      final map = noSynonyms.toMap();
      final restored = Word.fromMap(map);
      expect(restored.synonyms, isEmpty);
    });
  });
}
