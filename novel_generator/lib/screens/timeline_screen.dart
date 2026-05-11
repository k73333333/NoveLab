import 'package:flutter/material.dart';
import '../models/timeline_node.dart';
import '../models/character.dart';
import '../models/location.dart';
import '../services/data_service.dart';

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
  String? _selectedLocationId;

  @override
  void initState() {
    super.initState();
    _loadNodes();
  }

  Future<void> _loadNodes() async {
    final projectId = widget.dataService.currentProjectId;
    if (projectId != null) {
      setState(() {
        _nodes = widget.dataService.getTimelineNodes(projectId);
      });
    }
  }

  Future<void> _showNodeDialog([TimelineNode? node]) async {
    _clearForm();
    
    if (node != null) {
      _selectedNode = node;
      _titleController.text = node.title;
      _descriptionController.text = node.description ?? '';
      _dateController.text = node.date.toString().split(' ')[0];
      _selectedCharacterIds = List.from(node.characterIds);
      _selectedLocationId = node.locationId;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(node == null ? '创建时间节点' : '编辑时间节点'),
        content: SizedBox(
          width: 500,
          height: 500,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: '标题 *'),
                    validator: (value) => value?.isEmpty ?? true ? '请输入标题' : null,
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: '描述'),
                    maxLines: 3,
                  ),
                  TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(labelText: '日期 (YYYY-MM-DD)'),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        _dateController.text = picked.toString().split(' ')[0];
                      }
                    },
                  ),
                  _buildCharacterSelector(),
                  _buildLocationSelector(),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await _saveNode();
                Navigator.pop(context);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterSelector() {
    final projectId = widget.dataService.currentProjectId;
    final characters = projectId != null ? widget.dataService.getCharacters(projectId) : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('关联角色:'),
        Wrap(
          children: characters.map((char) {
            final isSelected = _selectedCharacterIds.contains(char.id);
            return FilterChip(
              label: Text(char.name),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCharacterIds.add(char.id);
                  } else {
                    _selectedCharacterIds.remove(char.id);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationSelector() {
    final projectId = widget.dataService.currentProjectId;
    final locations = projectId != null ? widget.dataService.getLocations(projectId) : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('关联地点:'),
        DropdownButtonFormField<String>(
          value: _selectedLocationId,
          hint: const Text('选择地点'),
          items: [
            const DropdownMenuItem(value: null, child: Text('无')),
            ...locations.map((loc) => DropdownMenuItem(
              value: loc.id,
              child: Text(loc.name),
            )),
          ],
          onChanged: (value) {
            _selectedLocationId = value;
          },
        ),
      ],
    );
  }

  void _clearForm() {
    _selectedNode = null;
    _titleController.clear();
    _descriptionController.clear();
    _dateController.clear();
    _selectedCharacterIds.clear();
    _selectedLocationId = null;
  }

  Future<void> _saveNode() async {
    final projectId = widget.dataService.currentProjectId!;
    final node = TimelineNode(
      id: _selectedNode?.id ?? widget.dataService.generateId(),
      projectId: projectId,
      title: _titleController.text,
      description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      date: DateTime.tryParse(_dateController.text) ?? DateTime.now(),
      characterIds: _selectedCharacterIds,
      locationId: _selectedLocationId,
      order: _selectedNode?.order ?? _nodes.length,
    );

    await widget.dataService.saveTimelineNode(node);
    _loadNodes();
  }

  Future<void> _deleteNode(String id) async {
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
              await widget.dataService.deleteTimelineNode(id);
              Navigator.pop(context);
              _loadNodes();
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
      body: _nodes.isEmpty
          ? const Center(child: Text('暂无时间节点'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _nodes.length,
              itemBuilder: (context, index) {
                final node = _nodes[index];
                final characters = node.characterIds
                    .map((id) => widget.dataService.getCharacter(id))
                    .whereType<Character>()
                    .toList();
                final location = node.locationId != null 
                    ? widget.dataService.getLocation(node.locationId!) 
                    : null;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(node.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('日期: ${node.date.toString().split(' ')[0]}'),
                        if (characters.isNotEmpty)
                          Text('角色: ${characters.map((c) => c.name).join(', ')}'),
                        if (location != null)
                          Text('地点: ${location.name}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showNodeDialog(node),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteNode(node.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNodeDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
