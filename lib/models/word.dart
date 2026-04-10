import 'package:hive/hive.dart';

class Word {
  final String kalka;
  final String kazakh;
  final String definition;
  final List<String> synonyms;
  final String example;
  final String category;
  final int difficulty; // 1=easy, 2=medium, 3=hard

  const Word({
    required this.kalka,
    required this.kazakh,
    required this.definition,
    required this.synonyms,
    required this.example,
    required this.category,
    required this.difficulty,
  });

  Map<String, dynamic> toMap() => {
        'kalka': kalka,
        'kazakh': kazakh,
        'definition': definition,
        'synonyms': synonyms,
        'example': example,
        'category': category,
        'difficulty': difficulty,
      };

  factory Word.fromMap(Map<String, dynamic> map) => Word(
        kalka: map['kalka'] as String,
        kazakh: map['kazakh'] as String,
        definition: map['definition'] as String,
        synonyms: List<String>.from(map['synonyms'] as List),
        example: map['example'] as String,
        category: (map['category'] as String?) ?? 'everyday',
        difficulty: (map['difficulty'] as int?) ?? 1,
      );
}

class WordAdapter extends TypeAdapter<Word> {
  @override
  final int typeId = 0;

  @override
  Word read(BinaryReader reader) {
    return Word(
      kalka: reader.readString(),
      kazakh: reader.readString(),
      definition: reader.readString(),
      synonyms: List<String>.generate(reader.readInt(), (_) => reader.readString()),
      example: reader.readString(),
      category: reader.readString(),
      difficulty: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Word obj) {
    writer.writeString(obj.kalka);
    writer.writeString(obj.kazakh);
    writer.writeString(obj.definition);
    writer.writeInt(obj.synonyms.length);
    for (final s in obj.synonyms) {
      writer.writeString(s);
    }
    writer.writeString(obj.example);
    writer.writeString(obj.category);
    writer.writeInt(obj.difficulty);
  }
}
