// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChangeLogAdapter extends TypeAdapter<ChangeLog> {
  @override
  final int typeId = 3;

  @override
  ChangeLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChangeLog(
      id: fields[0] as String,
      type: fields[1] as String,
      targetId: fields[2] as String,
      oldValue: fields[3] as String?,
      newValue: fields[4] as String?,
      timestamp: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ChangeLog obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.targetId)
      ..writeByte(3)
      ..write(obj.oldValue)
      ..writeByte(4)
      ..write(obj.newValue)
      ..writeByte(5)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChangeLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
