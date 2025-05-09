import 'package:flutter_quill/quill_delta.dart';

class Note {
  final String date;
  final Delta content;
  final String plainContent;
  final String id;
  final bool isGenerate;
  const Note({
    required this.date,
    required this.content,
    required this.plainContent,
    required this.id,
    required this.isGenerate,
  });
}

class User {
  final String name;
  final String email;
  final String uid;
  final String writingStyle;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.name,
    required this.email,
    required this.uid,
    required this.writingStyle,
    required this.createdAt,
    required this.updatedAt,
  });
}
