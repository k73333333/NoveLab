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
      projectId: fields[1] as String,
      entityType: fields[2] as String,
      entityId: fields[3] as String,
      action: fields[4] as String,
      fieldName: fields[5] as String,
      oldValue: fields[6] as String?,
      newValue: fields[7] as String?,
      timestamp: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ChangeLog obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.projectId)
      ..writeByte(2)
      ..write(obj.entityType)
      ..writeByte(3)
      ..write(obj.entityId)
      ..writeByte(4)
      ..write(obj.action)
      ..writeByte(5)
      ..write(obj.fieldName)
      ..writeByte(6)
      ..write(obj.oldValue)
      ..writeByte(7)
      ..write(obj.newValue)
      ..writeByte(8)
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
