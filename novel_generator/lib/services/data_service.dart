import 'package:hive/hive.dart';
import '../models/project.dart';
import '../models/template.dart';
import '../models/character.dart';
import '../models/location.dart';
import '../models/timeline_node.dart';
import '../models/change_log.dart';
import '../models/api_config.dart';
import '../models/outline_chapter.dart';
import '../models/novel_chapter.dart';
import '../models/app_settings.dart';

class DataService {
  late Box<Project> _projectBox;
  late Box<Template> _templateBox;
  late Box<Character> _characterBox;
  late Box<Location> _locationBox;
  late Box<TimelineNode> _timelineBox;
  late Box<ChangeLog> _changeLogBox;
  late Box<ApiConfig> _apiConfigBox;
  late Box<OutlineChapter> _outlineBox;
  late Box<NovelChapter> _novelBox;
  late Box<AppSettings> _settingsBox;

  String? _currentProjectId;

  Future<void> init() async {
    _projectBox = await Hive.openBox<Project>('projects');
    _templateBox = await Hive.openBox<Template>('templates');
    _characterBox = await Hive.openBox<Character>('characters');
    _locationBox = await Hive.openBox<Location>('locations');
    _timelineBox = await Hive.openBox<TimelineNode>('timeline_nodes');
    _changeLogBox = await Hive.openBox<ChangeLog>('change_logs');
    _apiConfigBox = await Hive.openBox<ApiConfig>('api_configs');
    _outlineBox = await Hive.openBox<OutlineChapter>('outline_chapters');
    _novelBox = await Hive.openBox<NovelChapter>('novel_chapters');
    _settingsBox = await Hive.openBox<AppSettings>('settings');

    final settings = _settingsBox.get('app_settings');
    if (settings != null) {
      _currentProjectId = settings.currentProjectId;
    }
  }

  String generateId() => DateTime.now().millisecondsSinceEpoch.toString();

  String? get currentProjectId => _currentProjectId;

  Future<void> switchProject(String projectId) async {
    _currentProjectId = projectId;
    final settings = _settingsBox.get('app_settings') ?? AppSettings();
    settings.currentProjectId = projectId;
    await _settingsBox.put('app_settings', settings);
  }

  List<Project> getAllProjects() => _projectBox.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  Project? getProject(String id) => _projectBox.get(id);
  Future<Project> saveProject(Project project) async {
    await _projectBox.put(project.id, project);
    return project;
  }
  Future<void> deleteProject(String id) async {
    await _characterBox.deleteAll(_characterBox.keys.where((k) => _characterBox.get(k)?.projectId == id));
    await _locationBox.deleteAll(_locationBox.keys.where((k) => _locationBox.get(k)?.projectId == id));
    await _timelineBox.deleteAll(_timelineBox.keys.where((k) => _timelineBox.get(k)?.projectId == id));
    await _outlineBox.deleteAll(_outlineBox.keys.where((k) => _outlineBox.get(k)?.projectId == id));
    await _novelBox.deleteAll(_novelBox.keys.where((k) => _novelBox.get(k)?.projectId == id));
    await _changeLogBox.deleteAll(_changeLogBox.keys.where((k) => _changeLogBox.get(k)?.projectId == id));
    await _projectBox.delete(id);
    if (_currentProjectId == id) {
      _currentProjectId = null;
    }
  }

  int getProjectCharacterCount(String projectId) => _characterBox.values.where((c) => c.projectId == projectId).length;
  int getProjectLocationCount(String projectId) => _locationBox.values.where((c) => c.projectId == projectId).length;
  int getProjectChapterCount(String projectId) => _novelBox.values.where((c) => c.projectId == projectId).length;

  List<Template> getAllTemplates() => _templateBox.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  Template? getTemplate(String id) => _templateBox.get(id);
  Future<Template> saveTemplate(Template template) async {
    await _templateBox.put(template.id, template);
    return template;
  }

  List<Character> getCharacters(String projectId) => _characterBox.values.where((c) => c.projectId == projectId).toList()..sort((a, b) => a.name.compareTo(b.name));
  Character? getCharacter(String id) => _characterBox.get(id);
  Future<Character> saveCharacter(Character character) async {
    await _characterBox.put(character.id, character);
    return character;
  }
  Future<void> deleteCharacter(String id) async {
    await _characterBox.delete(id);
  }

  List<Location> getLocations(String projectId) => _locationBox.values.where((l) => l.projectId == projectId).toList()..sort((a, b) => a.name.compareTo(b.name));
  Location? getLocation(String id) => _locationBox.get(id);
  Future<Location> saveLocation(Location location) async {
    await _locationBox.put(location.id, location);
    return location;
  }
  Future<void> deleteLocation(String id) async {
    await _locationBox.delete(id);
  }

  List<TimelineNode> getTimelineNodes(String projectId) => _timelineBox.values.where((t) => t.projectId == projectId).toList()..sort((a, b) => a.order.compareTo(b.order));
  TimelineNode? getTimelineNode(String id) => _timelineBox.get(id);
  Future<TimelineNode> saveTimelineNode(TimelineNode node) async {
    await _timelineBox.put(node.id, node);
    return node;
  }
  Future<void> deleteTimelineNode(String id) async {
    await _timelineBox.delete(id);
  }

  List<OutlineChapter> getOutlineChapters(String projectId) => _outlineBox.values.where((o) => o.projectId == projectId).toList()..sort((a, b) => a.order.compareTo(b.order));
  OutlineChapter? getOutlineChapter(String id) => _outlineBox.get(id);
  Future<OutlineChapter> saveOutlineChapter(OutlineChapter chapter) async {
    await _outlineBox.put(chapter.id, chapter);
    return chapter;
  }
  Future<void> deleteOutlineChapter(String id) async {
    await _outlineBox.delete(id);
  }

  List<NovelChapter> getNovelChapters(String projectId) => _novelBox.values.where((n) => n.projectId == projectId).toList()..sort((a, b) => a.order.compareTo(b.order));
  NovelChapter? getNovelChapter(String id) => _novelBox.get(id);
  Future<NovelChapter> saveNovelChapter(NovelChapter chapter) async {
    await _novelBox.put(chapter.id, chapter);
    return chapter;
  }
  Future<void> deleteNovelChapter(String id) async {
    await _novelBox.delete(id);
  }

  List<ChangeLog> getChangeLogs(String projectId) => _changeLogBox.values.where((c) => c.projectId == projectId).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  Future<ChangeLog> saveChangeLog(ChangeLog log) async {
    await _changeLogBox.put(log.id, log);
    return log;
  }

  ApiConfig? getApiConfig() => _apiConfigBox.get('default');
  Future<ApiConfig> saveApiConfig(ApiConfig config) async {
    await _apiConfigBox.put('default', config);
    return config;
  }
}
