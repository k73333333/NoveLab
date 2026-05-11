/*
 * @Author: fukaidong
 * @Description: -
 * @Date: 2026-05-07
 * @LastEditTime: 2026-05-09
 */
import 'package:hive/hive.dart';
import 'field_definition.dart';

part 'project.g.dart';

@HiveType(typeId: 10)
class Project extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String templateId;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime updatedAt;

  @HiveField(5)
  List<FieldDefinition> characterFields;

  @HiveField(6)
  List<FieldDefinition> mapFields;

  Project({
    required this.id,
    required this.name,
    required this.templateId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<FieldDefinition>? characterFields,
    List<FieldDefinition>? mapFields,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        characterFields = characterFields ?? [],
        mapFields = mapFields ?? [];

  Project copyWith({
    String? id,
    String? name,
    String? templateId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<FieldDefinition>? characterFields,
    List<FieldDefinition>? mapFields,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      templateId: templateId ?? this.templateId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      characterFields: characterFields ?? this.characterFields,
      mapFields: mapFields ?? this.mapFields,
    );
  }
}
