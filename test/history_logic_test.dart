import 'package:flutter_test/flutter_test.dart';

// Тарих логикасы — контроллерден бөлек
List<Map<String, dynamic>> saveToHistory(
  List<Map<String, dynamic>> history,
  String text,
  int kalkaCount, {
  int maxSize = 20,
}) {
  if (text.trim().isEmpty) return history;
  final truncated = text.length > 100 ? '${text.substring(0, 100)}...' : text;
  final updated = [
    {'text': truncated, 'kalkaCount': kalkaCount, 'timestamp': DateTime.now().toIso8601String()},
    ...history,
  ];
  if (updated.length > maxSize) return updated.sublist(0, maxSize);
  return updated;
}

List<Map<String, dynamic>> saveAiHistory(
  List<Map<String, dynamic>> history,
  String text,
  String aiResult,
  String provider, {
  int maxSize = 30,
}) {
  final truncated = text.length > 80 ? '${text.substring(0, 80)}...' : text;
  final updated = [
    {'text': truncated, 'aiResult': aiResult, 'provider': provider, 'timestamp': DateTime.now().toIso8601String()},
    ...history,
  ];
  if (updated.length > maxSize) return updated.sublist(0, maxSize);
  return updated;
}

void main() {
  group('saveToHistory — тексеру тарихы', () {
    test('жаңа жазба алдымен тізімде тұрады', () {
      final history = saveToHistory([], 'тест мәтін', 2);
      expect(history.length, 1);
      expect(history.first['kalkaCount'], 2);
    });

    test('бос мәтін сақталмайды', () {
      final history = saveToHistory([], '   ', 0);
      expect(history, isEmpty);
    });

    test('100 символдан ұзын мәтін кесіледі', () {
      final longText = 'а' * 150;
      final history = saveToHistory([], longText, 0);
      expect((history.first['text'] as String).endsWith('...'), isTrue);
      expect((history.first['text'] as String).length, lessThanOrEqualTo(103));
    });

    test('100 символдан қысқа мәтін кесілмейді', () {
      const text = 'қысқа мәтін';
      final history = saveToHistory([], text, 1);
      expect(history.first['text'], text);
    });

    test('максимум 20 жазба сақталады', () {
      var history = <Map<String, dynamic>>[];
      for (int i = 0; i < 25; i++) {
        history = saveToHistory(history, 'мәтін $i', i);
      }
      expect(history.length, 20);
    });

    test('ең соңғы жазба бірінші орында', () {
      var history = saveToHistory([], 'бірінші', 1);
      history = saveToHistory(history, 'екінші', 2);
      expect(history.first['text'], 'екінші');
    });

    test('kalkaCount 0 болса да сақталады (таза мәтін)', () {
      final history = saveToHistory([], 'таза мәтін', 0);
      expect(history.first['kalkaCount'], 0);
    });

    test('timestamp бар', () {
      final history = saveToHistory([], 'тест', 1);
      expect(history.first['timestamp'], isNotNull);
      expect(DateTime.tryParse(history.first['timestamp'] as String), isNotNull);
    });
  });

  group('saveAiHistory — ЖИ тарихы', () {
    test('жаңа ЖИ жазба сақталады', () {
      final history = saveAiHistory([], 'кіріс', 'нәтиже', 'claude');
      expect(history.length, 1);
      expect(history.first['provider'], 'claude');
    });

    test('80 символдан ұзын мәтін кесіледі', () {
      final longText = 'б' * 120;
      final history = saveAiHistory([], longText, 'нәтиже', 'grok');
      expect((history.first['text'] as String).endsWith('...'), isTrue);
    });

    test('максимум 30 жазба сақталады', () {
      var history = <Map<String, dynamic>>[];
      for (int i = 0; i < 35; i++) {
        history = saveAiHistory(history, 'мәтін $i', 'нәтиже $i', 'claude');
      }
      expect(history.length, 30);
    });

    test('claude және grok провайдерлер сақталады', () {
      var history = saveAiHistory([], 'мәтін', 'нәтиже', 'claude');
      history = saveAiHistory(history, 'мәтін 2', 'нәтиже 2', 'grok');
      expect(history[0]['provider'], 'grok');
      expect(history[1]['provider'], 'claude');
    });

    test('aiResult толық сақталады', () {
      const result = '**Калька:** профилактикалық\n✅ Дұрысы: алдын алу';
      final history = saveAiHistory([], 'тест', result, 'claude');
      expect(history.first['aiResult'], result);
    });
  });

  group('Тарих — шекаралық жағдайлар', () {
    test('бір жазба maxSize-тен үлкен болмайды', () {
      var history = <Map<String, dynamic>>[];
      history = saveToHistory(history, 'мәтін', 1, maxSize: 1);
      history = saveToHistory(history, 'жаңа мәтін', 2, maxSize: 1);
      expect(history.length, 1);
      expect(history.first['text'], 'жаңа мәтін');
    });

    test('тізім өзгермейді — immutable логика', () {
      final original = <Map<String, dynamic>>[];
      saveToHistory(original, 'тест', 1);
      expect(original, isEmpty); // бастапқы тізім өзгермеуі керек
    });
  });
}
