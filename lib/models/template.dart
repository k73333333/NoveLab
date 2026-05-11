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
}
