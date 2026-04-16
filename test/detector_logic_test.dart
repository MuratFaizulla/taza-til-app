import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/word.dart';

// Детектор логикасы — контроллерден бөлек тест үшін шығарылған
List<Word> detectKalkaInText(String text, Map<String, Word> kalkaMap) {
  if (text.trim().isEmpty) return [];
  final lowerText = text.toLowerCase();
  final result = <Word>[];
  final seen = <String>{};
  for (final entry in kalkaMap.entries) {
    final phrase = entry.key;
    if (phrase.length < 4) continue;
    if (seen.contains(phrase)) continue;
    if (lowerText.contains(phrase)) {
      seen.add(phrase);
      result.add(entry.value);
    }
  }
  return result;
}

void main() {
  // Тест үшін кішкентай база
  final testKalkaMap = {
    'профилактикалық шаралар': const Word(
      kalka: 'профилактикалық шаралар',
      kazakh: 'алдын алу шаралары',
      definition: 'тест',
      synonyms: [],
      example: 'тест',
      category: 'everyday',
      difficulty: 2,
    ),
    'тұмаумен ауырып қалдым': const Word(
      kalka: 'тұмаумен ауырып қалдым',
      kazakh: 'тұмауратып қалдым',
      definition: 'тест',
      synonyms: [],
      example: 'тест',
      category: 'everyday',
      difficulty: 2,
    ),
    'бірнәрсені еске түсіреді': const Word(
      kalka: 'бірнәрсені еске түсіреді',
      kazakh: 'бірнәрсеге ұқсайды',
      definition: 'тест',
      synonyms: [],
      example: 'тест',
      category: 'everyday',
      difficulty: 1,
    ),
    'қоқыс лақтыру': const Word(
      kalka: 'қоқыс лақтыру',
      kazakh: 'қоқыс тастау',
      definition: 'тест',
      synonyms: [],
      example: 'тест',
      category: 'everyday',
      difficulty: 1,
    ),
  };

  group('detectKalkaInText — фразалық іздеу', () {
    test('бос мәтін бос тізім қайтарады', () {
      expect(detectKalkaInText('', testKalkaMap), isEmpty);
      expect(detectKalkaInText('   ', testKalkaMap), isEmpty);
    });

    test('калька жоқ мәтін бос тізім қайтарады', () {
      final result = detectKalkaInText('Бүгін ауа райы жақсы', testKalkaMap);
      expect(result, isEmpty);
    });

    test('нақты фразаны табады', () {
      final result = detectKalkaInText(
          'Профилактикалық шаралар қабылданды', testKalkaMap);
      expect(result.length, 1);
      expect(result.first.kalka, 'профилактикалық шаралар');
    });

    test('регистрге тәуелсіз іздейді', () {
      final result = detectKalkaInText(
          'ПРОФИЛАКТИКАЛЫҚ ШАРАЛАР жасалды', testKalkaMap);
      expect(result.length, 1);
    });

    test('мәтін ішіндегі фразаны да табады', () {
      final result = detectKalkaInText(
          'Кеше мен тұмаумен ауырып қалдым, қазір жақсымын', testKalkaMap);
      expect(result.length, 1);
      expect(result.first.kazakh, 'тұмауратып қалдым');
    });

    test('бір мәтінде бірнеше калька табады', () {
      final result = detectKalkaInText(
          'Профилактикалық шаралар жасалды, ол бірнәрсені еске түсіреді',
          testKalkaMap);
      expect(result.length, 2);
    });

    test('бір фраза бірнеше рет кездессе бір рет қайтарады', () {
      final result = detectKalkaInText(
          'қоқыс лақтыру дегені қоқыс лақтыру болып табылады', testKalkaMap);
      expect(result.length, 1);
    });

    test('4 символдан қысқа кілттерді өткізіп жібереді', () {
      final mapWithShort = {
        'аб': const Word(
          kalka: 'аб',
          kazakh: 'тест',
          definition: '',
          synonyms: [],
          example: '',
          category: 'everyday',
          difficulty: 1,
        ),
        ...testKalkaMap,
      };
      // 'аб' кілті 4 символдан қысқа болғандықтан табылмауы керек
      final result = detectKalkaInText('аб бар мұнда', mapWithShort);
      expect(result.where((w) => w.kalka == 'аб'), isEmpty);
    });

    test('ескі токен-негізді іздеу ЖҰМЫС ЖАСАМАЙТЫНЫН тексереді', () {
      // Ескі алгоритм "профилактикалық" деген жеке сөзді іздеп таба алмайтын
      // Себебі калька кілті — толық фраза "профилактикалық шаралар"
      // Жаңа алгоритм оны табуы керек
      final result = detectKalkaInText(
          'профилактикалық шаралар керек', testKalkaMap);
      expect(result, isNotEmpty); // Жаңа алгоритм табады
    });
  });

  group('detectKalkaInText — шекаралық жағдайлар', () {
    test('тек бос орындардан тұратын мәтін', () {
      expect(detectKalkaInText('     ', testKalkaMap), isEmpty);
    });

    test('бос калька базасы', () {
      expect(detectKalkaInText('кез келген мәтін', {}), isEmpty);
    });

    test('мәтін дәл калька фразасына тең болса табады', () {
      final result = detectKalkaInText('қоқыс лақтыру', testKalkaMap);
      expect(result.length, 1);
    });

    test('нәтиже Word объектінің дұрыс баламасын қайтарады', () {
      final result = detectKalkaInText('қоқыс лақтыру', testKalkaMap);
      expect(result.first.kazakh, 'қоқыс тастау');
    });
  });
}
