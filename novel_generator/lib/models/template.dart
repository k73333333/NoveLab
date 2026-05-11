import 'package:hive/hive.dart';
import 'field_definition.dart';

part 'template.g.dart';

@HiveType(typeId: 13)
class Template extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  bool isPreset;

  @HiveField(4)
  List<FieldDefinition> characterFields;

  @HiveField(5)
  List<FieldDefinition> mapFields;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  Template({
    required this.id,
    required this.name,
    this.description,
    this.isPreset = false,
    List<FieldDefinition>? characterFields,
    List<FieldDefinition>? mapFields,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : characterFields = characterFields ?? [],
        mapFields = mapFields ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Template copyWith({
    String? id,
    String? name,
    String? description,
    bool? isPreset,
    List<FieldDefinition>? characterFields,
    List<FieldDefinition>? mapFields,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Template(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isPreset: isPreset ?? this.isPreset,
      characterFields: characterFields ?? this.characterFields,
      mapFields: mapFields ?? this.mapFields,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isPreset': isPreset,
      'characterFields': characterFields.map((f) => f.toJson()).toList(),
      'mapFields': mapFields.map((f) => f.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      isPreset: json['isPreset'] as bool? ?? false,
      characterFields: (json['characterFields'] as List?)
              ?.map((f) => FieldDefinition.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [],
      mapFields: (json['mapFields'] as List?)
              ?.map((f) => FieldDefinition.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}
