class Note {
  final DateTime date;
  final List<dynamic> content;
  final String plainContent;
  final String id;
  final bool isGenerated;
  const Note({
    required this.date,
    required this.content,
    required this.plainContent,
    required this.id,
    required this.isGenerated,
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
