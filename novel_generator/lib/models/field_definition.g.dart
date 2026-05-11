// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'field_definition.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FieldDefinitionAdapter extends TypeAdapter<FieldDefinition> {
  @override
  final int typeId = 12;

  @override
  FieldDefinition read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FieldDefinition(
      id: fields[0] as String,
      name: fields[1] as String,
      label: fields[2] as String,
      type: fields[3] as FieldType,
      isRequired: fields[4] as bool,
      fieldGroup: fields[5] as String,
      options: (fields[6] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, FieldDefinition obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.label)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.isRequired)
      ..writeByte(5)
      ..write(obj.fieldGroup)
      ..writeByte(6)
      ..write(obj.options);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FieldDefinitionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FieldTypeAdapter extends TypeAdapter<FieldType> {
  @override
  final int typeId = 11;

  @override
  FieldType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FieldType.text;
      case 1:
        return FieldType.number;
      case 2:
        return FieldType.date;
      case 3:
        return FieldType.select;
      case 4:
        return FieldType.textarea;
      default:
        return FieldType.text;
    }
  }

  @override
  void write(BinaryWriter writer, FieldType obj) {
    switch (obj) {
      case FieldType.text:
        writer.writeByte(0);
        break;
      case FieldType.number:
        writer.writeByte(1);
        break;
      case FieldType.date:
        writer.writeByte(2);
        break;
      case FieldType.select:
        writer.writeByte(3);
        break;
      case FieldType.textarea:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FieldTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
