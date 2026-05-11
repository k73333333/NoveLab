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
    if (_templates.isEmpty) {
      await _loadData();
    }

    final nameController = TextEditingController();
    String? selectedTemplateId =
        _templates.isNotEmpty ? _templates.first.id : null;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建新项目'),
        contentPadding: const EdgeInsets.all(16),
        content: SizedBox(
          width: 400,
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
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.copy, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  const Text(
                    '导入模板配置:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TemplateListScreen(
                            dataService: widget.dataService,
                          ),
                        ),
                      );
                      await _loadData();
                      _showCreateProjectDialog();
                    },
                    child: const Text('管理模板'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                '选择模板将复制其字段配置到新项目，创建后可自由修改',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  setState(() {
                    selectedTemplateId = '';
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selectedTemplateId == ''
                          ? Colors.blue
                          : Colors.grey.shade200,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: const Text(
                          '不使用模板（空项目）',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      if (selectedTemplateId == '')
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                    ],
                  ),
                ),
              ),
              if (_templates.isNotEmpty)
                ..._templates.map((template) {
                  final isSelected = selectedTemplateId == template.id;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedTemplateId = template.id;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? Colors.blue
                              : Colors.grey.shade200,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                                const Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Chip(
                                    label: Text('预设'),
                                    backgroundColor: Colors.blue,
                                    labelStyle:
                                        TextStyle(color: Colors.white),
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
                        ],
                      ),
                    ),
                  );
                }).toList(),
              if (_templates.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('暂无模板可用'),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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

              final project = Project(
                id: widget.dataService.generateId(),
                name: nameController.text,
                templateId: selectedTemplateId ?? '',
              );
              await widget.dataService.saveProject(project);
              await widget.dataService.switchProject(project.id);

              Navigator.pop(context);
              widget.onProjectCreated?.call();
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择项目'),
        centerTitle: true,
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
                              _buildStat(Icons.person, '$charCount 角色'),
                              const SizedBox(width: 16),
                              _buildStat(Icons.map, '$locCount 地点'),
                              const SizedBox(width: 16),
                              _buildStat(Icons.book, '$chapterCount 章节'),
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

  Widget _buildStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
