import 'package:hive/hive.dart';

part 'timeline_node.g.dart';

@HiveType(typeId: 2)
class TimelineNode extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String projectId;

  @HiveField(2)
  String title;

  @HiveField(3)
  String? description;

  @HiveField(4)
  DateTime? date;

  @HiveField(5)
  List<String> characterIds;

  @HiveField(6)
  List<String> locationIds;

  @HiveField(7)
  int orderIndex;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime updatedAt;

  TimelineNode({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    this.date,
    List<String>? characterIds,
    List<String>? locationIds,
    required this.orderIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : characterIds = characterIds ?? [],
        locationIds = locationIds ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  TimelineNode copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    DateTime? date,
    List<String>? characterIds,
    List<String>? locationIds,
    int? orderIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TimelineNode(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      characterIds: characterIds ?? this.characterIds,
      locationIds: locationIds ?? this.locationIds,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
