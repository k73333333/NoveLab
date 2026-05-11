import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/character.dart';
import '../models/location.dart';
import '../models/timeline_node.dart';
import '../models/change_log.dart';
import '../models/api_config.dart';
import '../models/outline_chapter.dart';
import '../models/novel_chapter.dart';
import '../models/project.dart';
import '../models/template.dart';
import '../models/app_settings.dart';

class DataService {
  static const String _charactersBoxName = 'characters';
  static const String _locationsBoxName = 'locations';
  static const String _timelineBoxName = 'timeline_nodes';
  static const String _changeLogsBoxName = 'change_logs';
  static const String _apiConfigBoxName = 'api_config';
  static const String _outlineBoxName = 'outline_chapters';
  static const String _novelBoxName = 'novel_chapters';
  static const String _projectsBoxName = 'projects';
  static const String _templatesBoxName = 'templates';
  static const String _settingsBoxName = 'app_settings';

  final Uuid _uuid = const Uuid();

  String? _currentProjectId;

  String? get currentProjectId => _currentProjectId;

  Future<void> init() async {
    await Hive.openBox<Character>(_charactersBoxName);
    await Hive.openBox<Location>(_locationsBoxName);
    await Hive.openBox<TimelineNode>(_timelineBoxName);
    await Hive.openBox<ChangeLog>(_changeLogsBoxName);
    await Hive.openBox<ApiConfig>(_apiConfigBoxName);
    await Hive.openBox<OutlineChapter>(_outlineBoxName);
    await Hive.openBox<NovelChapter>(_novelBoxName);
    await Hive.openBox<Project>(_projectsBoxName);
    await Hive.openBox<Template>(_templatesBoxName);
    await Hive.openBox<AppSettings>(_settingsBoxName);

    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settingsBox = Hive.box<AppSettings>(_settingsBoxName);
    final settings = settingsBox.get('settings');
    if (settings != null) {
      _currentProjectId = settings.currentProjectId;
    }
  }

  Future<void> _saveSettings() async {
    final settingsBox = Hive.box<AppSettings>(_settingsBoxName);
    final settings = AppSettings(
      currentProjectId: _currentProjectId,
      appVersion: 2,
    );
    await settingsBox.put('settings', settings);
  }

  Box<Character> get _characterBox => Hive.box<Character>(_charactersBoxName);
  Box<Location> get _locationBox => Hive.box<Location>(_locationsBoxName);
  Box<TimelineNode> get _timelineBox => Hive.box<TimelineNode>(_timelineBoxName);
  Box<ChangeLog> get _changeLogBox => Hive.box<ChangeLog>(_changeLogsBoxName);
  Box<ApiConfig> get _apiConfigBox => Hive.box<ApiConfig>(_apiConfigBoxName);
  Box<OutlineChapter> get _outlineBox => Hive.box<OutlineChapter>(_outlineBoxName);
  Box<NovelChapter> get _novelBox => Hive.box<NovelChapter>(_novelBoxName);
  Box<Project> get _projectBox => Hive.box<Project>(_projectsBoxName);
  Box<Template> get _templateBox => Hive.box<Template>(_templatesBoxName);

  Future<Project> saveProject(Project project) async {
    Project updated = project.copyWith(updatedAt: DateTime.now());
    
    if (updated.characterFields.isEmpty || updated.mapFields.isEmpty) {
      final template = _templateBox.get(project.templateId);
      if (template != null) {
        updated = updated.copyWith(
          characterFields: List.from(template.characterFields),
          mapFields: List.from(template.mapFields),
        );
      }
    }
    
    await _projectBox.put(updated.id, updated);
    return updated;
  }

  Future<void> deleteProject(String id) async {
    final characters = getAllCharacters().where((c) => c.projectId == id).toList();
    for (final char in characters) {
      await deleteCharacter(char.id);
    }

    final locations = getAllLocations().where((l) => l.projectId == id).toList();
    for (final loc in locations) {
      await deleteLocation(loc.id);
    }

    final timelines = getAllTimelineNodes().where((t) => t.projectId == id).toList();
    for (final timeline in timelines) {
      await deleteTimelineNode(timeline.id);
    }

    final outlines = getAllOutlineChapters().where((o) => o.projectId == id).toList();
    for (final outline in outlines) {
      await deleteOutlineChapter(outline.id);
    }

    final novels = getAllNovelChapters().where((n) => n.projectId == id).toList();
    for (final novel in novels) {
      await deleteNovelChapter(novel.id);
    }

    await _projectBox.delete(id);

    if (_currentProjectId == id) {
      _currentProjectId = null;
      await _saveSettings();
    }
  }

  List<Project> getAllProjects() => _projectBox.values.toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  Project? getProject(String id) => _projectBox.get(id);

  Future<void> switchProject(String projectId) async {
    _currentProjectId = projectId;
    await _saveSettings();
  }

  Future<Template> saveTemplate(Template template) async {
    final updated = template.copyWith(updatedAt: DateTime.now());
    await _templateBox.put(updated.id, updated);
    return updated;
  }

  Future<void> deleteTemplate(String id) async {
    final template = _templateBox.get(id);
    if (template != null && template.isPreset) {
      throw Exception('Cannot delete preset template');
    }

    final projectsUsingTemplate = getAllProjects().where((p) => p.templateId == id).toList();
    if (projectsUsingTemplate.isNotEmpty) {
      throw Exception('Template is in use by existing projects');
    }

    await _templateBox.delete(id);
  }

  List<Template> getAllTemplates() => _templateBox.values.toList()..sort((a, b) {
    if (a.isPreset && !b.isPreset) return -1;
    if (!a.isPreset && b.isPreset) return 1;
    return a.name.compareTo(b.name);
  });
  Template? getTemplate(String id) => _templateBox.get(id);
  List<Template> getPresetTemplates() => getAllTemplates().where((t) => t.isPreset).toList();
  List<Template> getCustomTemplates() => getAllTemplates().where((t) => !t.isPreset).toList();

  Future<Character> saveCharacter(Character character) async {
    final isNew = character.createdAt == character.updatedAt;
    
    final updated = character.copyWith(updatedAt: DateTime.now());
    await _characterBox.put(updated.id, updated);

    await _logChange(
      type: 'character',
      targetId: updated.id,
      oldValue: isNew ? null : 'updated',
      newValue: updated.name,
      projectId: updated.projectId,
    );

    return updated;
  }

  Future<void> deleteCharacter(String id) async {
    final character = _characterBox.get(id);
    if (character == null) return;

    await _characterBox.delete(id);
    for (final node in _timelineBox.values.where((node) => node.characterIds.contains(id))) {
      node.characterIds.remove(id);
      node.save();
    }
    await _logChange(type: 'character', targetId: id, oldValue: 'deleted', newValue: null, projectId: character.projectId);
  }

  List<Character> getAllCharacters() {
    if (_currentProjectId == null) return [];
    return _characterBox.values
        .where((c) => c.projectId == _currentProjectId)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  List<Character> getCharactersByProject(String projectId) {
    return _characterBox.values
        .where((c) => c.projectId == projectId)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Character? getCharacter(String id) => _characterBox.get(id);

  Future<Location> saveLocation(Location location) async {
    final isNew = location.createdAt == location.updatedAt;
    
    final updated = location.copyWith(updatedAt: DateTime.now());
    await _locationBox.put(updated.id, updated);

    await _logChange(
      type: 'location',
      targetId: updated.id,
      oldValue: isNew ? null : 'updated',
      newValue: updated.name,
      projectId: updated.projectId,
    );

    return updated;
  }

  Future<void> deleteLocation(String id) async {
    final location = _locationBox.get(id);
    if (location == null) return;

    await _locationBox.delete(id);
    for (final node in _timelineBox.values.where((node) => node.locationIds.contains(id))) {
      node.locationIds.remove(id);
      node.save();
    }
    await _logChange(type: 'location', targetId: id, oldValue: 'deleted', newValue: null, projectId: location.projectId);
  }

  List<Location> getAllLocations() {
    if (_currentProjectId == null) return [];
    return _locationBox.values
        .where((l) => l.projectId == _currentProjectId)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  List<Location> getLocationsByProject(String projectId) {
    return _locationBox.values
        .where((l) => l.projectId == projectId)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Location? getLocation(String id) => _locationBox.get(id);

  Future<TimelineNode> saveTimelineNode(TimelineNode node) async {
    final isNew = node.createdAt == node.updatedAt;
    
    final updated = node.copyWith(updatedAt: DateTime.now());
    await _timelineBox.put(updated.id, updated);

    await _logChange(
      type: 'timeline',
      targetId: updated.id,
      oldValue: isNew ? null : 'updated',
      newValue: updated.title,
      projectId: updated.projectId,
    );

    return updated;
  }

  Future<void> deleteTimelineNode(String id) async {
    final node = _timelineBox.get(id);
    if (node == null) return;

    await _timelineBox.delete(id);
    await _logChange(type: 'timeline', targetId: id, oldValue: 'deleted', newValue: null, projectId: node.projectId);
  }

  List<TimelineNode> getAllTimelineNodes() {
    if (_currentProjectId == null) return [];
    return _timelineBox.values
        .where((t) => t.projectId == _currentProjectId)
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  List<TimelineNode> getTimelineNodesByProject(String projectId) {
    return _timelineBox.values
        .where((t) => t.projectId == projectId)
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  Future<OutlineChapter> saveOutlineChapter(OutlineChapter chapter) async {
    final updated = chapter.copyWith(updatedAt: DateTime.now());
    await _outlineBox.put(updated.id, updated);
    return updated;
  }

  Future<void> deleteOutlineChapter(String id) async {
    await _outlineBox.delete(id);
  }

  List<OutlineChapter> getAllOutlineChapters() {
    if (_currentProjectId == null) return [];
    return _outlineBox.values
        .where((o) => o.projectId == _currentProjectId)
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  List<OutlineChapter> getOutlineChaptersByProject(String projectId) {
    return _outlineBox.values
        .where((o) => o.projectId == projectId)
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  OutlineChapter? getOutlineChapter(String id) => _outlineBox.get(id);

  Future<NovelChapter> saveNovelChapter(NovelChapter chapter) async {
    final updated = chapter.copyWith(updatedAt: DateTime.now());
    await _novelBox.put(updated.id, updated);
    return updated;
  }

  Future<void> deleteNovelChapter(String id) async {
    await _novelBox.delete(id);
  }

  List<NovelChapter> getAllNovelChapters() {
    if (_currentProjectId == null) return [];
    return _novelBox.values
        .where((n) => n.projectId == _currentProjectId)
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  List<NovelChapter> getNovelChaptersByProject(String projectId) {
    return _novelBox.values
        .where((n) => n.projectId == projectId)
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  NovelChapter? getNovelChapter(String id) => _novelBox.get(id);

  Future<ApiConfig> saveApiConfig(ApiConfig config) async {
    final updated = config.copyWith(updatedAt: DateTime.now());
    await _apiConfigBox.put(updated.id, updated);
    return updated;
  }

  ApiConfig? getApiConfig(String id) => _apiConfigBox.get(id);
  List<ApiConfig> getAllApiConfigs() => _apiConfigBox.values.toList();

  Future<void> _logChange({
    required String type,
    required String targetId,
    String? oldValue,
    String? newValue,
    String? projectId,
  }) async {
    final log = ChangeLog(
      id: _uuid.v4(),
      type: type,
      targetId: targetId,
      oldValue: oldValue,
      newValue: newValue,
      timestamp: DateTime.now(),
    );
    await _changeLogBox.put(log.id, log);
  }

  List<ChangeLog> getAllChangeLogs() => _changeLogBox.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  int getProjectCharacterCount(String projectId) => _characterBox.values.where((c) => c.projectId == projectId).length;
  int getProjectLocationCount(String projectId) => _locationBox.values.where((l) => l.projectId == projectId).length;
  int getProjectChapterCount(String projectId) => _novelBox.values.where((n) => n.projectId == projectId).length;

  String generateId() => _uuid.v4();
}
