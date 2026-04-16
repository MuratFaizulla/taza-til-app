import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/word.dart';

// Сүзгі логикасы — контроллерден бөлек тест үшін шығарылған
List<Word> applyFilters(
  List<Word> words, {
  String category = 'all',
  bool favoritesOnly = false,
  Set<String> favorites = const {},
  String query = '',
}) {
  var result = words.toList();
  if (category != 'all') {
    result = result.where((w) => w.category == category).toList();
  }
  if (favoritesOnly) {
    result =
        result.where((w) => favorites.contains(w.kalka.toLowerCase())).toList();
  }
  if (query.trim().isNotEmpty) {
    final q = query.trim().toLowerCase();
    result = result
        .where((w) =>
            w.kalka.toLowerCase().contains(q) ||
            w.kazakh.toLowerCase().contains(q) ||
            w.definition.toLowerCase().contains(q) ||
            w.synonyms.any((s) => s.toLowerCase().contains(q)))
        .toList();
  }
  return result;
}

const _words = [
  Word(
    kalka: 'профилактикалық шаралар',
    kazakh: 'алдын алу шаралары',
    definition: 'Профилактические меры',
    synonyms: ['алдын алу'],
    example: 'тест',
    category: 'everyday',
    difficulty: 2,
  ),
  Word(
    kalka: 'программалық қамтамасыз ету',
    kazakh: 'бағдарламалық жасақтама',
    definition: 'Программное обеспечение',
    synonyms: ['ПО'],
    example: 'тест',
    category: 'technology',
    difficulty: 3,
  ),
  Word(
    kalka: 'бизнес жоспар',
    kazakh: 'іскерлік жоспар',
    definition: 'Бизнес-план',
    synonyms: [],
    example: 'тест',
    category: 'business',
    difficulty: 1,
  ),
];

void main() {
  group('applyFilters — санат бойынша сүзгі', () {
    test('all — барлық сөздерді қайтарады', () {
      final result = applyFilters(_words, category: 'all');
      expect(result.length, 3);
    });

    test('technology — тек технология санатын қайтарады', () {
      final result = applyFilters(_words, category: 'technology');
      expect(result.length, 1);
      expect(result.first.kalka, 'программалық қамтамасыз ету');
    });

    test('everyday — тек күнделікті санатын қайтарады', () {
      final result = applyFilters(_words, category: 'everyday');
      expect(result.length, 1);
      expect(result.first.kalka, 'профилактикалық шаралар');
    });

    test('жоқ санат — бос тізім қайтарады', () {
      final result = applyFilters(_words, category: 'medicine');
      expect(result, isEmpty);
    });
  });

  group('applyFilters — таңдаулылар сүзгісі', () {
    test('таңдаулылар қосылған, тізім бар', () {
      final result = applyFilters(
        _words,
        favoritesOnly: true,
        favorites: {'бизнес жоспар'},
      );
      expect(result.length, 1);
      expect(result.first.kalka, 'бизнес жоспар');
    });

    test('таңдаулылар қосылған, тізім бос', () {
      final result = applyFilters(_words, favoritesOnly: true, favorites: {});
      expect(result, isEmpty);
    });

    test('таңдаулылар өшірулі — барлығын қайтарады', () {
      final result = applyFilters(
        _words,
        favoritesOnly: false,
        favorites: {'бизнес жоспар'},
      );
      expect(result.length, 3);
    });
  });

  group('applyFilters — мәтін іздеу', () {
    test('калька бойынша іздеу', () {
      final result = applyFilters(_words, query: 'профилактикалық');
      expect(result.length, 1);
      expect(result.first.kalka, 'профилактикалық шаралар');
    });

    test('қазақша нұсқа бойынша іздеу', () {
      final result = applyFilters(_words, query: 'іскерлік');
      expect(result.length, 1);
      expect(result.first.kalka, 'бизнес жоспар');
    });

    test('анықтама бойынша іздеу', () {
      final result = applyFilters(_words, query: 'программное');
      expect(result.length, 1);
    });

    test('синоним бойынша іздеу', () {
      final result = applyFilters(_words, query: 'алдын алу');
      expect(result.length, 1);
      expect(result.first.kalka, 'профилактикалық шаралар');
    });

    test('регистрге тәуелсіз іздеу', () {
      final result = applyFilters(_words, query: 'БИЗНЕС');
      expect(result.length, 1);
    });

    test('бос іздеу — барлығын қайтарады', () {
      final result = applyFilters(_words, query: '');
      expect(result.length, 3);
    });

    test('табылмаған іздеу — бос тізім', () {
      final result = applyFilters(_words, query: 'мүлдем жоқ сөз xyz');
      expect(result, isEmpty);
    });
  });

  group('applyFilters — комбинирленген сүзгілер', () {
    test('санат + іздеу', () {
      final result = applyFilters(
        _words,
        category: 'technology',
        query: 'бағдарламалық',
      );
      expect(result.length, 1);
    });

    test('санат + таңдаулылар', () {
      final result = applyFilters(
        _words,
        category: 'business',
        favoritesOnly: true,
        favorites: {'бизнес жоспар'},
      );
      expect(result.length, 1);
      expect(result.first.category, 'business');
    });

    test('санат сәйкес емес + таңдаулылар — бос', () {
      final result = applyFilters(
        _words,
        category: 'technology',
        favoritesOnly: true,
        favorites: {'бизнес жоспар'}, // business санатында
      );
      expect(result, isEmpty);
    });
  });
}
