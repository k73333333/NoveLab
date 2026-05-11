// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_node.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimelineNodeAdapter extends TypeAdapter<TimelineNode> {
  @override
  final int typeId = 2;

  @override
  TimelineNode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimelineNode(
      id: fields[0] as String,
      projectId: fields[1] as String,
      title: fields[2] as String,
      description: fields[3] as String?,
      date: fields[4] as DateTime,
      characterIds: (fields[5] as List?)?.cast<String>(),
      locationId: fields[6] as String?,
      order: fields[7] as int,
      createdAt: fields[8] as DateTime?,
      updatedAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TimelineNode obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.projectId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.characterIds)
      ..writeByte(6)
      ..write(obj.locationId)
      ..writeByte(7)
      ..write(obj.order)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimelineNodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
