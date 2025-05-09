class Note {
  final String date;
  final Map<dynamic, dynamic> content;
  final String plainContent;
  final String id;
  final bool isGenerated;
  const Note({
    required this.date,
    required this.content,
    required this.plainContent,
    required this.id,
    required this.isGenerated,
    required String note,
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
