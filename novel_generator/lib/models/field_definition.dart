import 'package:hive/hive.dart';

part 'field_definition.g.dart';

@HiveType(typeId: 11)
enum FieldType {
  @HiveField(0)
  text,
  @HiveField(1)
  number,
  @HiveField(2)
  date,
  @HiveField(3)
  select,
  @HiveField(4)
  textarea,
}

@HiveType(typeId: 12)
class FieldDefinition extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String label;

  @HiveField(3)
  FieldType type;

  @HiveField(4)
  bool isRequired;

  @HiveField(5)
  String fieldGroup;

  @HiveField(6)
  List<String>? options;

  FieldDefinition({
    required this.id,
    required this.name,
    required this.label,
    required this.type,
    this.isRequired = false,
    required this.fieldGroup,
    this.options,
  });

  FieldDefinition copyWith({
    String? id,
    String? name,
    String? label,
    FieldType? type,
    bool? isRequired,
    String? fieldGroup,
    List<String>? options,
  }) {
    return FieldDefinition(
      id: id ?? this.id,
      name: name ?? this.name,
      label: label ?? this.label,
      type: type ?? this.type,
      isRequired: isRequired ?? this.isRequired,
      fieldGroup: fieldGroup ?? this.fieldGroup,
      options: options ?? this.options,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'label': label,
      'type': type.index,
      'isRequired': isRequired,
      'fieldGroup': fieldGroup,
      'options': options,
    };
  }

  factory FieldDefinition.fromJson(Map<String, dynamic> json) {
    return FieldDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      label: json['label'] as String,
      type: FieldType.values[json['type'] as int],
      isRequired: json['isRequired'] as bool? ?? false,
      fieldGroup: json['fieldGroup'] as String,
      options: (json['options'] as List?)?.cast<String>(),
    );
  }
}
