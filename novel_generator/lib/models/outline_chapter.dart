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
  String summary;

  @HiveField(4)
  int order;

  @HiveField(5)
  List<String> characterIds;

  @HiveField(6)
  String? locationId;

  @HiveField(7)
  DateTime? date;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime updatedAt;

  OutlineChapter({
    required this.id,
    required this.projectId,
    required this.title,
    required this.summary,
    this.order = 0,
    List<String>? characterIds,
    this.locationId,
    this.date,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : characterIds = characterIds ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  OutlineChapter copyWith({
    String? id,
    String? projectId,
    String? title,
    String? summary,
    int? order,
    List<String>? characterIds,
    String? locationId,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OutlineChapter(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      order: order ?? this.order,
      characterIds: characterIds ?? this.characterIds,
      locationId: locationId ?? this.locationId,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
