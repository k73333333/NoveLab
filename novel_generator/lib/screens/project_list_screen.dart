import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/template.dart';
import '../services/data_service.dart';
import 'template_list_screen.dart';

class ProjectListScreen extends StatefulWidget {
  final DataService dataService;
  final VoidCallback? onProjectCreated;

  const ProjectListScreen({
    super.key,
    required this.dataService,
    this.onProjectCreated,
  });

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  List<Project> _projects = [];
  List<Template> _templates = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _projects = widget.dataService.getAllProjects();
      _templates = widget.dataService.getAllTemplates();
    });
  }

  Future<void> _showCreateProjectDialog() async {
    await _loadData();

    if (!mounted) return;

    final nameController = TextEditingController();
    Template? selectedTemplate =
        _templates.isNotEmpty ? _templates.first : null;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('创建新项目'),
          content: SizedBox(
            width: 500,
            height: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '项目名称',
                    hintText: '输入小说项目名称',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      '选择模板:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        _navigateToTemplateManagement();
                      },
                      icon: const Icon(Icons.settings, size: 16),
                      label: const Text('管理模板'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: _templates.map((template) {
                      final isSelected = selectedTemplate?.id == template.id;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: isSelected ? Colors.blue[50] : null,
                        child: InkWell(
                          onTap: () {
                            setDialogState(() {
                              selectedTemplate = template;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        template.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ),
                                    if (template.isPreset)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Chip(
                                          label: const Text('预设'),
                                          backgroundColor: Colors.blue.shade100,
                                        ),
                                      ),
                                  ],
                                ),
                                if (template.description != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      template.description!,
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    children: [
                                      _buildFieldBadge(
                                        '角色字段',
                                        template.characterFields.length,
                                      ),
                                      const SizedBox(width: 8),
                                      _buildFieldBadge(
                                        '地图字段',
                                        template.mapFields.length,
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '角色字段:',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 4,
                                          children: template.characterFields
                                              .map((f) => Chip(
                                                    label: Text(
                                                      '${f.label}${f.isRequired ? ' *' : ''}',
                                                    ),
                                                    backgroundColor: f
                                                            .isRequired
                                                        ? Colors.orange.shade100
                                                        : Colors.grey.shade100,
                                                  ))
                                              .toList(),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          '地图字段:',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 4,
                                          children: template.mapFields
                                              .map((f) => Chip(
                                                    label: Text(
                                                      '${f.label}${f.isRequired ? ' *' : ''}',
                                                    ),
                                                    backgroundColor: f
                                                            .isRequired
                                                        ? Colors.orange.shade100
                                                        : Colors.grey.shade100,
                                                  ))
                                              .toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请输入项目名称')),
                  );
                  return;
                }
                if (selectedTemplate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请选择模板')),
                  );
                  return;
                }

                final project = Project(
                  id: widget.dataService.generateId(),
                  name: nameController.text,
                  templateId: selectedTemplate!.id,
                );
                await widget.dataService.saveProject(project);
                await widget.dataService.switchProject(project.id);

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
                widget.onProjectCreated?.call();
              },
              child: const Text('创建'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldBadge(String label, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: $count',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildIconBadge(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  void _navigateToTemplateManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TemplateListScreen(dataService: widget.dataService),
      ),
    ).then((_) => _loadData());
  }

  Future<void> _showDeleteConfirmation(Project project) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除项目"${project.name}"吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await widget.dataService.deleteProject(project.id);
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择项目'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToTemplateManagement,
            tooltip: '管理模板',
          ),
        ],
      ),
      body: _projects.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.folder_open,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '还没有项目',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '创建一个新项目开始你的小说创作',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showCreateProjectDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('创建项目'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _navigateToTemplateManagement,
                    icon: const Icon(Icons.settings),
                    label: const Text('管理模板'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _projects.length,
              itemBuilder: (context, index) {
                final project = _projects[index];
                final template =
                    widget.dataService.getTemplate(project.templateId);
                final charCount =
                    widget.dataService.getProjectCharacterCount(project.id);
                final locCount =
                    widget.dataService.getProjectLocationCount(project.id);
                final chapterCount =
                    widget.dataService.getProjectChapterCount(project.id);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () async {
                      await widget.dataService.switchProject(project.id);
                      widget.onProjectCreated?.call();
                    },
                    onLongPress: () => _showDeleteConfirmation(project),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  project.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (template?.isPreset ?? false)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    template?.name ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '创建于: ${project.createdAt.toString().split(' ')[0]}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildIconBadge(Icons.person, '$charCount 角色'),
                              const SizedBox(width: 16),
                              _buildIconBadge(Icons.map, '$locCount 地点'),
                              const SizedBox(width: 16),
                              _buildIconBadge(Icons.book, '$chapterCount 章节'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateProjectDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
