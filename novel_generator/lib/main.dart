import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/character.dart';
import 'models/location.dart';
import 'models/timeline_node.dart';
import 'models/change_log.dart';
import 'models/api_config.dart';
import 'models/outline_chapter.dart';
import 'models/novel_chapter.dart';
import 'models/project.dart';
import 'models/template.dart';
import 'models/app_settings.dart';
import 'models/field_definition.dart';
import 'services/data_service.dart';
import 'services/ai_service.dart';
import 'services/sync_service.dart';
import 'screens/project_list_screen.dart';
import 'screens/character_screen.dart';
import 'screens/location_screen.dart';
import 'screens/timeline_screen.dart';
import 'screens/outline_screen.dart';
import 'screens/novel_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  Hive.registerAdapter(CharacterAdapter());
  Hive.registerAdapter(LocationAdapter());
  Hive.registerAdapter(TimelineNodeAdapter());
  Hive.registerAdapter(ChangeLogAdapter());
  Hive.registerAdapter(ApiConfigAdapter());
  Hive.registerAdapter(OutlineChapterAdapter());
  Hive.registerAdapter(NovelChapterAdapter());
  Hive.registerAdapter(ProjectAdapter());
  Hive.registerAdapter(TemplateAdapter());
  Hive.registerAdapter(AppSettingsAdapter());
  Hive.registerAdapter(FieldTypeAdapter());
  Hive.registerAdapter(FieldDefinitionAdapter());

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final DataService _dataService = DataService();
  final AIService _aiService = DummyAIService();
  bool _isInitialized = false;
  bool _hasProjects = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _dataService.init();
    await _initPresetTemplates();
    
    final projects = _dataService.getAllProjects();
    _hasProjects = projects.isNotEmpty;
    
    setState(() => _isInitialized = true);
  }

  Future<void> _initPresetTemplates() async {
    final templates = _dataService.getAllTemplates();
    if (templates.isEmpty) {
      final presetTemplate = Template(
        id: _dataService.generateId(),
        name: '通用小说模板',
        description: '适用于大多数小说类型的默认模板',
        isPreset: true,
        characterFields: [
          FieldDefinition(
            id: _dataService.generateId(),
            name: 'name',
            label: '姓名',
            type: FieldType.text,
            isRequired: true,
            fieldGroup: 'character',
          ),
          FieldDefinition(
            id: _dataService.generateId(),
            name: 'age',
            label: '年龄',
            type: FieldType.number,
            isRequired: false,
            fieldGroup: 'character',
          ),
          FieldDefinition(
            id: _dataService.generateId(),
            name: 'gender',
            label: '性别',
            type: FieldType.text,
            isRequired: false,
            fieldGroup: 'character',
          ),
          FieldDefinition(
            id: _dataService.generateId(),
            name: 'personality',
            label: '性格',
            type: FieldType.textarea,
            isRequired: false,
            fieldGroup: 'character',
          ),
          FieldDefinition(
            id: _dataService.generateId(),
            name: 'background',
            label: '背景故事',
            type: FieldType.textarea,
            isRequired: false,
            fieldGroup: 'character',
          ),
        ],
        mapFields: [
          FieldDefinition(
            id: _dataService.generateId(),
            name: 'name',
            label: '名称',
            type: FieldType.text,
            isRequired: true,
            fieldGroup: 'location',
          ),
          FieldDefinition(
            id: _dataService.generateId(),
            name: 'description',
            label: '描述',
            type: FieldType.textarea,
            isRequired: false,
            fieldGroup: 'location',
          ),
          FieldDefinition(
            id: _dataService.generateId(),
            name: 'areaSize',
            label: '面积(km²)',
            type: FieldType.number,
            isRequired: false,
            fieldGroup: 'location',
          ),
          FieldDefinition(
            id: _dataService.generateId(),
            name: 'latitude',
            label: '纬度',
            type: FieldType.number,
            isRequired: false,
            fieldGroup: 'location',
          ),
          FieldDefinition(
            id: _dataService.generateId(),
            name: 'longitude',
            label: '经度',
            type: FieldType.number,
            isRequired: false,
            fieldGroup: 'location',
          ),
        ],
      );
      await _dataService.saveTemplate(presetTemplate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '小说生成器',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: _isInitialized 
          ? _hasProjects
              ? MainScreen(
                  dataService: _dataService,
                  aiService: _aiService,
                )
              : ProjectListScreen(
                  dataService: _dataService,
                  onProjectCreated: () {
                    setState(() => _hasProjects = true);
                  },
                )
          : const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final DataService dataService;
  final AIService aiService;

  const MainScreen({
    super.key,
    required this.dataService,
    required this.aiService,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return CharacterScreen(dataService: widget.dataService);
      case 1:
        return LocationScreen(dataService: widget.dataService);
      case 2:
        return TimelineScreen(dataService: widget.dataService);
      case 3:
        return OutlineScreen(
          dataService: widget.dataService,
          aiService: widget.aiService,
        );
      case 4:
        return NovelScreen(
          dataService: widget.dataService,
          aiService: widget.aiService,
        );
      default:
        return CharacterScreen(dataService: widget.dataService);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentProject = widget.dataService.currentProjectId != null
        ? widget.dataService.getProject(widget.dataService.currentProjectId!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentProject?.name ?? '未选择项目'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.folder),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProjectListScreen(
                    dataService: widget.dataService,
                    onProjectCreated: () {
                      setState(() {});
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildScreen(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '角色',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: '地图',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: '时间线',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '大纲',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: '小说',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
