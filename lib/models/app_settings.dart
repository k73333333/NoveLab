import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 14)
class AppSettings extends HiveObject {
  @HiveField(0)
  String? currentProjectId;

  @HiveField(1)
  int appVersion;

  @HiveField(2)
  String? defaultTemplateId;

  AppSettings({
    this.currentProjectId,
    this.appVersion = 1,
    this.defaultTemplateId,
  });
}
