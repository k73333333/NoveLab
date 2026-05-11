import 'package:hive/hive.dart';

part 'change_log.g.dart';

@HiveType(typeId: 3)
class ChangeLog extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String projectId;

  @HiveField(2)
  String entityType;

  @HiveField(3)
  String entityId;

  @HiveField(4)
  String action;

  @HiveField(5)
  String fieldName;

  @HiveField(6)
  String? oldValue;

  @HiveField(7)
  String? newValue;

  @HiveField(8)
  DateTime timestamp;

  ChangeLog({
    required this.id,
    required this.projectId,
    required this.entityType,
    required this.entityId,
    required this.action,
    required this.fieldName,
    this.oldValue,
    this.newValue,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
