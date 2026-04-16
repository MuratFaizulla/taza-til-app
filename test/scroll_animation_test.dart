import 'package:flutter_test/flutter_test.dart';

// Скролл анимация кешігуі — dictionary_screen.dart баптауы
// Ескі: delay: (i * 30).ms  — 100-ші элемент 3000ms күтеді!
// Жаңа: delay: (i.clamp(0, 10) * 30).ms — максимум 300ms

int oldDelay(int index) => index * 30;
int newDelay(int index) => index.clamp(0, 10) * 30;

void main() {
  group('Скролл анимация кешігуі', () {
    group('Ескі алгоритм (баг)', () {
      test('10-шы элемент 300ms күтеді', () {
        expect(oldDelay(10), 300);
      });

      test('50-ші элемент 1500ms күтеді — тым ұзақ!', () {
        expect(oldDelay(50), 1500);
      });

      test('100-ші элемент 3000ms күтеді — баг!', () {
        expect(oldDelay(100), 3000);
      });
    });

    group('Жаңа алгоритм (fix)', () {
      test('бірінші элемент 0ms — лезде шығады', () {
        expect(newDelay(0), 0);
      });

      test('5-ші элемент 150ms', () {
        expect(newDelay(5), 150);
      });

      test('10-шы элемент 300ms — максимум', () {
        expect(newDelay(10), 300);
      });

      test('50-ші элемент 300ms — шектелген!', () {
        expect(newDelay(50), 300); // clamp(50, 0, 10) = 10 → 300ms
      });

      test('100-ші элемент 300ms — баг жоқ!', () {
        expect(newDelay(100), 300); // 3000ms емес
      });

      test('1000-ші элемент де 300ms', () {
        expect(newDelay(1000), 300);
      });
    });

    group('Жақсарту дәлелі', () {
      test('100-ші элементте жаңа алгоритм 10x жылдамырақ', () {
        final old = oldDelay(100); // 3000ms
        final fresh = newDelay(100); // 300ms
        expect(fresh, lessThan(old));
        expect(old / fresh, greaterThanOrEqualTo(10));
      });

      test('максимум кешігу 300ms-тан аспайды', () {
        for (int i = 0; i <= 1000; i++) {
          expect(newDelay(i), lessThanOrEqualTo(300),
              reason: '$i-ші элемент үшін кешігу 300ms-тан асып кетті');
        }
      });
    });
  });
}
