import 'package:hive/hive.dart';

part 'character.g.dart';

@HiveType(typeId: 0)
class Character extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String projectId;

  @HiveField(2)
  String name;

  @HiveField(3)
  int? age;

  @HiveField(4)
  String? gender;

  @HiveField(5)
  String? personality;

  @HiveField(6)
  String? background;

  @HiveField(7)
  String? avatar;

  @HiveField(8)
  Map<String, dynamic> customFields;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  DateTime updatedAt;

  Character({
    required this.id,
    required this.projectId,
    required this.name,
    this.age,
    this.gender,
    this.personality,
    this.background,
    this.avatar,
    Map<String, dynamic>? customFields,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : customFields = customFields ?? {},
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Character copyWith({
    String? id,
    String? projectId,
    String? name,
    int? age,
    String? gender,
    String? personality,
    String? background,
    String? avatar,
    Map<String, dynamic>? customFields,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Character(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      personality: personality ?? this.personality,
      background: background ?? this.background,
      avatar: avatar ?? this.avatar,
      customFields: customFields ?? this.customFields,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
