// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteAdapter extends TypeAdapter<Note> {
  @override
  final int typeId = 0;

  @override
  Note read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Note(
      date: fields[0] as DateTime,
      content: (fields[1] as List).cast<dynamic>(),
      plainContent: fields[2] as String,
      id: fields[3] as String,
      isGenerated: fields[4] as bool,
      tags: (fields[5] as List?)?.cast<String>(),
      mood: fields[6] as String?,
      reflect: fields[7] as String?,
      title: fields[8] as String?,
      isCustom: fields[9] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.plainContent)
      ..writeByte(3)
      ..write(obj.id)
      ..writeByte(4)
      ..write(obj.isGenerated)
      ..writeByte(5)
      ..write(obj.tags)
      ..writeByte(6)
      ..write(obj.mood)
      ..writeByte(7)
      ..write(obj.reflect)
      ..writeByte(8)
      ..write(obj.title)
      ..writeByte(9)
      ..write(obj.isCustom);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
