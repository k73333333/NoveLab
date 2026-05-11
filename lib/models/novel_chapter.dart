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
  int orderIndex;

  @HiveField(5)
  String? outlineChapterId;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  NovelChapter({
    required this.id,
    required this.projectId,
    required this.title,
    required this.content,
    required this.orderIndex,
    this.outlineChapterId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  NovelChapter copyWith({
    String? id,
    String? projectId,
    String? title,
    String? content,
    int? orderIndex,
    String? outlineChapterId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NovelChapter(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      content: content ?? this.content,
      orderIndex: orderIndex ?? this.orderIndex,
      outlineChapterId: outlineChapterId ?? this.outlineChapterId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
