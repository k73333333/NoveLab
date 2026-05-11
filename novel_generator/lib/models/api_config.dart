import 'package:hive/hive.dart';

part 'api_config.g.dart';

@HiveType(typeId: 4)
class ApiConfig extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String provider;

  @HiveField(2)
  String apiKey;

  @HiveField(3)
  String baseUrl;

  @HiveField(4)
  String model;

  @HiveField(5)
  int maxTokens;

  @HiveField(6)
  double temperature;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime updatedAt;

  ApiConfig({
    required this.id,
    required this.provider,
    required this.apiKey,
    required this.baseUrl,
    required this.model,
    this.maxTokens = 4096,
    this.temperature = 0.7,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  ApiConfig copyWith({
    String? id,
    String? provider,
    String? apiKey,
    String? baseUrl,
    String? model,
    int? maxTokens,
    double? temperature,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ApiConfig(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
      maxTokens: maxTokens ?? this.maxTokens,
      temperature: temperature ?? this.temperature,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
