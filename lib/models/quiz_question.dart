import 'word.dart';

class QuizQuestion {
  final Word word;
  final List<String> options; // 4 kazakh alternatives
  final int correctIndex;

  const QuizQuestion({
    required this.word,
    required this.options,
    required this.correctIndex,
  });
}
