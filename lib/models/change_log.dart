/*
 * @Author: fukaidong
 * @Date: 2026-05-07
 * @LastEditors: fukaidong
 * @LastEditTime: 2026-05-08
 * @FilePath: \NoveLab\novel_generator\lib\models\change_log.dart
 * @Description: 变更日志模型
 */
import 'package:hive/hive.dart';

part 'change_log.g.dart';

@HiveType(typeId: 3)
class ChangeLog extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String type;

  @HiveField(2)
  String targetId;

  @HiveField(3)
  String? oldValue;

  @HiveField(4)
  String? newValue;

  @HiveField(5)
  DateTime timestamp;

  ChangeLog({
    required this.id,
    required this.type,
    required this.targetId,
    this.oldValue,
    this.newValue,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
