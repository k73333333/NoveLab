import 'package:hive/hive.dart';

part 'novel_chapter.g.dart';

@HiveType(typeId: 6)
class NovelChapter extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String projectId;

  @HiveField(2)
  String title;

  @HiveField(3)
  String content;

  @HiveField(4)
  int order;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  NovelChapter({
    required this.id,
    required this.projectId,
    required this.title,
    required this.content,
    this.order = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  NovelChapter copyWith({
    String? id,
    String? projectId,
    String? title,
    String? content,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NovelChapter(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      content: content ?? this.content,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
