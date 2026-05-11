import 'package:hive/hive.dart';

part 'outline_chapter.g.dart';

@HiveType(typeId: 5)
class OutlineChapter extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String projectId;

  @HiveField(2)
  String title;

  @HiveField(3)
  String? summary;

  @HiveField(4)
  int orderIndex;

  @HiveField(5)
  List<String> characterIds;

  @HiveField(6)
  List<String> locationIds;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime updatedAt;

  OutlineChapter({
    required this.id,
    required this.projectId,
    required this.title,
    this.summary,
    required this.orderIndex,
    List<String>? characterIds,
    List<String>? locationIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : characterIds = characterIds ?? [],
        locationIds = locationIds ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  OutlineChapter copyWith({
    String? id,
    String? projectId,
    String? title,
    String? summary,
    int? orderIndex,
    List<String>? characterIds,
    List<String>? locationIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OutlineChapter(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      orderIndex: orderIndex ?? this.orderIndex,
      characterIds: characterIds ?? this.characterIds,
      locationIds: locationIds ?? this.locationIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
