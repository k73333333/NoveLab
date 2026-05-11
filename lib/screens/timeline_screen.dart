import 'package:flutter/material.dart';
import '../models/timeline_node.dart';
import '../services/data_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class TimelineScreen extends StatefulWidget {
  final DataService dataService;

  const TimelineScreen({super.key, required this.dataService});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  List<TimelineNode> _nodes = [];
  TimelineNode? _selectedNode;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  List<String> _selectedCharacterIds = [];
  List<String> _selectedLocationIds = [];

  @override
  void initState() {
    super.initState();
    _loadNodes();
  }

  Future<void> _loadNodes() async {
    setState(() {
      _nodes = widget.dataService.getAllTimelineNodes();
    });
  }

  void _selectNode(TimelineNode node) {
    setState(() {
      _selectedNode = node;
      _titleController.text = node.title;
      _descriptionController.text = node.description ?? '';
      _dateController.text = node.date != null 
          ? '${node.date!.year}-${node.date!.month.toString().padLeft(2, '0')}-${node.date!.day.toString().padLeft(2, '0')}' 
          : '';
      _selectedCharacterIds = List.from(node.characterIds);
      _selectedLocationIds = List.from(node.locationIds);
    });
  }

  void _clearForm() {
    setState(() {
      _selectedNode = null;
      _titleController.clear();
      _descriptionController.clear();
      _dateController.clear();
      _selectedCharacterIds = [];
      _selectedLocationIds = [];
    });
  }

  Future<void> _saveNode() async {
    if (!_formKey.currentState!.validate()) return;

    DateTime? date;
    if (_dateController.text.isNotEmpty) {
      date = DateTime.tryParse(_dateController.text);
    }

    final projectId = widget.dataService.currentProjectId;
    if (projectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择项目')),
      );
      return;
    }

    final node = TimelineNode(
      id: _selectedNode?.id ?? widget.dataService.generateId(),
      projectId: projectId,
      title: _titleController.text,
      description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      date: date,
      characterIds: _selectedCharacterIds,
      locationIds: _selectedLocationIds,
      orderIndex: _selectedNode?.orderIndex ?? _nodes.length,
    );

    await widget.dataService.saveTimelineNode(node);
    _loadNodes();
    _clearForm();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('时间节点保存成功')),
    );
  }

  Future<void> _deleteNode() async {
    if (_selectedNode == null) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个时间节点吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await widget.dataService.deleteTimelineNode(_selectedNode!.id);
              _loadNodes();
              _clearForm();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('时间节点删除成功')),
              );
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final characters = widget.dataService.getAllCharacters();
    final locations = widget.dataService.getAllLocations();

    return Scaffold(
      appBar: const CustomAppBar(title: '时间线管理'),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: _nodes.length,
              itemBuilder: (context, index) {
                final node = _nodes[index];
                return ListTile(
                  title: Text(node.title),
                  subtitle: Text(node.date != null ? node.date!.toString().split(' ')[0] : '无日期'),
                  selected: _selectedNode?.id == node.id,
                  onTap: () => _selectNode(node),
                );
              },
            ),
          ),
          const VerticalDivider(),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      label: '标题',
                      hint: '输入事件标题',
                      controller: _titleController,
                      validator: (value) => value?.isEmpty ?? true ? '请输入标题' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: '描述',
                      hint: '输入事件描述',
                      controller: _descriptionController,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: '日期',
                      hint: 'YYYY-MM-DD',
                      controller: _dateController,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      hint: const Text('关联角色'),
                      initialValue: _selectedCharacterIds.isNotEmpty ? null : null,
                      items: characters.map((char) => DropdownMenuItem(
                        value: char.id,
                        child: Text(char.name),
                      )).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            if (_selectedCharacterIds.contains(value)) {
                              _selectedCharacterIds.remove(value);
                            } else {
                              _selectedCharacterIds.add(value);
                            }
                          });
                        }
                      },
                      isExpanded: true,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      children: _selectedCharacterIds.map((id) {
                        final char = characters.firstWhere((c) => c.id == id);
                        return Chip(
                          label: Text(char.name),
                          onDeleted: () {
                            setState(() => _selectedCharacterIds.remove(id));
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      hint: const Text('关联地点'),
                      items: locations.map((loc) => DropdownMenuItem(
                        value: loc.id,
                        child: Text(loc.name),
                      )).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            if (_selectedLocationIds.contains(value)) {
                              _selectedLocationIds.remove(value);
                            } else {
                              _selectedLocationIds.add(value);
                            }
                          });
                        }
                      },
                      isExpanded: true,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      children: _selectedLocationIds.map((id) {
                        final loc = locations.firstWhere((l) => l.id == id);
                        return Chip(
                          label: Text(loc.name),
                          onDeleted: () {
                            setState(() => _selectedLocationIds.remove(id));
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        CustomButton(
                          text: '保存',
                          onPressed: _saveNode,
                        ),
                        const SizedBox(width: 16),
                        CustomButton(
                          text: '新建',
                          onPressed: _clearForm,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 16),
                        if (_selectedNode != null)
                          CustomButton(
                            text: '删除',
                            onPressed: _deleteNode,
                            color: Colors.red,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
