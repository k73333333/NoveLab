// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outline_chapter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OutlineChapterAdapter extends TypeAdapter<OutlineChapter> {
  @override
  final int typeId = 5;

  @override
  OutlineChapter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OutlineChapter(
      id: fields[0] as String,
      projectId: fields[1] as String,
      title: fields[2] as String,
      summary: fields[3] as String?,
      orderIndex: fields[4] as int,
      characterIds: (fields[5] as List?)?.cast<String>(),
      locationIds: (fields[6] as List?)?.cast<String>(),
      createdAt: fields[7] as DateTime?,
      updatedAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, OutlineChapter obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.projectId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.summary)
      ..writeByte(4)
      ..write(obj.orderIndex)
      ..writeByte(5)
      ..write(obj.characterIds)
      ..writeByte(6)
      ..write(obj.locationIds)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutlineChapterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
