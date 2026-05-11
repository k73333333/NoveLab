// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'novel_chapter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NovelChapterAdapter extends TypeAdapter<NovelChapter> {
  @override
  final int typeId = 6;

  @override
  NovelChapter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NovelChapter(
      id: fields[0] as String,
      projectId: fields[1] as String,
      title: fields[2] as String,
      content: fields[3] as String,
      order: fields[4] as int,
      createdAt: fields[5] as DateTime?,
      updatedAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, NovelChapter obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.projectId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.order)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NovelChapterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
