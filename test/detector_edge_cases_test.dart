import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/word.dart';

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

const _w = Word(
  kalka: 'профилактикалық шаралар',
  kazakh: 'алдын алу шаралары',
  definition: 'тест',
  synonyms: [],
  example: 'тест',
  category: 'everyday',
  difficulty: 2,
);

final _map = {'профилактикалық шаралар': _w};

void main() {
  group('Детектор — арнайы символдар', () {
    test('үтір мен нүкте бар мәтін', () {
      final result = detectKalkaInText(
          'Профилактикалық шаралар, қабылданды.', _map);
      expect(result.length, 1);
    });

    test('жолдың соңындағы фраза', () {
      final result =
          detectKalkaInText('Бізде бар профилактикалық шаралар', _map);
      expect(result.length, 1);
    });

    test('жолдың басындағы фраза', () {
      final result =
          detectKalkaInText('профилактикалық шаралар керек болды', _map);
      expect(result.length, 1);
    });

    test('тырнақша ішіндегі фраза', () {
      final result = detectKalkaInText(
          '"профилактикалық шаралар" туралы', _map);
      expect(result.length, 1);
    });

    test('жол аралық (\\n) мәтін', () {
      final result = detectKalkaInText(
          'Бірінші жол\nпрофилактикалық шаралар\nекінші жол', _map);
      expect(result.length, 1);
    });

    test('өте ұзын мәтінде фраза', () {
      final longText =
          '${'Бұл өте ұзын мәтін. ' * 50}профилактикалық шаралар ${'Тағы мәтін. ' * 50}';
      final result = detectKalkaInText(longText, _map);
      expect(result.length, 1);
    });
  });

  group('Детектор — бірнеше калька', () {
    final multiMap = {
      'профилактикалық шаралар': const Word(
        kalka: 'профилактикалық шаралар',
        kazakh: 'алдын алу шаралары',
        definition: '',
        synonyms: [],
        example: '',
        category: 'everyday',
        difficulty: 1,
      ),
      'бизнес жоспар': const Word(
        kalka: 'бизнес жоспар',
        kazakh: 'іскерлік жоспар',
        definition: '',
        synonyms: [],
        example: '',
        category: 'business',
        difficulty: 1,
      ),
      'қоқыс лақтыру': const Word(
        kalka: 'қоқыс лақтыру',
        kazakh: 'қоқыс тастау',
        definition: '',
        synonyms: [],
        example: '',
        category: 'everyday',
        difficulty: 1,
      ),
    };

    test('3 калька бір мәтінде', () {
      final text =
          'Профилактикалық шаралар мен бизнес жоспар бар, қоқыс лақтыру жасалды';
      final result = detectKalkaInText(text, multiMap);
      expect(result.length, 3);
    });

    test('2 калька, бірі жоқ', () {
      final text = 'Профилактикалық шаралар мен бизнес жоспар жасалды';
      final result = detectKalkaInText(text, multiMap);
      expect(result.length, 2);
    });

    test('нәтиже тізімі дұрыс калькаларды қайтарады', () {
      final text = 'бизнес жоспар бекітілді';
      final result = detectKalkaInText(text, multiMap);
      expect(result.first.kazakh, 'іскерлік жоспар');
    });
  });

  group('Детектор — регистр комбинациялары', () {
    test('бас әріппен басталса табылады', () {
      expect(detectKalkaInText('Профилактикалық шаралар', _map), isNotEmpty);
    });

    test('толық бас әріппен табылады', () {
      expect(
          detectKalkaInText('ПРОФИЛАКТИКАЛЫҚ ШАРАЛАР', _map), isNotEmpty);
    });

    test('аралас регистр табылады', () {
      expect(
          detectKalkaInText('Профилактикалық ШАРАЛАР', _map), isNotEmpty);
    });
  });

  group('Детектор — ұқсас сөздер', () {
    final similarMap = {
      'қоқыс лақтыру': const Word(
        kalka: 'қоқыс лақтыру',
        kazakh: 'қоқыс тастау',
        definition: '',
        synonyms: [],
        example: '',
        category: 'everyday',
        difficulty: 1,
      ),
    };

    test('ұқсас бірақ басқа фраза табылмайды', () {
      // "қоқыс" жеке сөзі калька емес, толық фраза керек
      final result = detectKalkaInText('қоқыс жатыр', similarMap);
      expect(result, isEmpty);
    });

    test('дәл фраза ғана табылады', () {
      final result = detectKalkaInText('қоқыс лақтыру', similarMap);
      expect(result.length, 1);
    });
  });
}
