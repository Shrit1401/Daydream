import 'package:hive/hive.dart';

part 'types.g.dart';

@HiveType(typeId: 0)
class Note {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final List<dynamic> content;

  @HiveField(2)
  final String plainContent;

  @HiveField(3)
  final String id;

  @HiveField(4)
  final bool isGenerated;

  @HiveField(5)
  final List<String>? tags;

  @HiveField(6)
  final String? mood;

  @HiveField(7)
  final String? reflect;

  @HiveField(8)
  final String? title;

  @HiveField(9)
  final bool isCustom;

  const Note({
    required this.date,
    required this.content,
    required this.plainContent,
    required this.id,
    required this.isGenerated,
    this.tags,
    this.mood,
    this.reflect,
    this.title,
    this.isCustom = false,
  });
}

class UserType {
  final String name;
  final String email;
  final String uid;
  final String writingStyle;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserType({
    required this.name,
    required this.email,
    required this.uid,
    required this.writingStyle,
    required this.createdAt,
    required this.updatedAt,
  });
}
