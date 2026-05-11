import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/template.dart';
import '../models/field_definition.dart';
import '../services/data_service.dart';

class ProjectSettingsScreen extends StatefulWidget {
  final DataService dataService;
  final Project project;

  const ProjectSettingsScreen({
    super.key,
    required this.dataService,
    required this.project,
  });

  @override
  State<ProjectSettingsScreen> createState() => _ProjectSettingsScreenState();
}

class _ProjectSettingsScreenState extends State<ProjectSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late List<FieldDefinition> _characterFields;
  late List<FieldDefinition> _mapFields;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.project.name;
    _characterFields = List.from(widget.project.characterFields);
    _mapFields = List.from(widget.project.mapFields);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedProject = widget.project.copyWith(
      name: _nameController.text,
      characterFields: _characterFields,
      mapFields: _mapFields,
    );

    await widget.dataService.saveProject(updatedProject);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('项目设置已保存')),
    );
    
    Navigator.pop(context);
  }

  Future<void> _reapplyTemplate() async {
    final template = widget.dataService.getTemplate(widget.project.templateId);
    if (template == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('未找到关联的模板')),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认重新应用模板'),
        content: Text(
          '此操作将使用模板"${template.name}"的字段配置覆盖当前项目的字段设置，所有自定义字段将丢失。确定继续吗？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _characterFields = List.from(template.characterFields);
                _mapFields = List.from(template.mapFields);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('模板配置已重新应用')),
              );
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void _addCharacterField() {
    _showFieldDialog(
      fieldGroup: 'character',
      onSave: (field) {
        setState(() {
          _characterFields.add(field);
        });
      },
    );
  }

  void _addMapField() {
    _showFieldDialog(
      fieldGroup: 'location',
      onSave: (field) {
        setState(() {
          _mapFields.add(field);
        });
      },
    );
  }

  void _editCharacterField(int index) {
    _showFieldDialog(
      fieldGroup: 'character',
      field: _characterFields[index],
      onSave: (field) {
        setState(() {
          _characterFields[index] = field;
        });
      },
    );
  }

  void _editMapField(int index) {
    _showFieldDialog(
      fieldGroup: 'location',
      field: _mapFields[index],
      onSave: (field) {
        setState(() {
          _mapFields[index] = field;
        });
      },
    );
  }

  void _deleteCharacterField(int index) {
    setState(() {
      _characterFields.removeAt(index);
    });
  }

  void _deleteMapField(int index) {
    setState(() {
      _mapFields.removeAt(index);
    });
  }

  void _showFieldDialog({
    required String fieldGroup,
    FieldDefinition? field,
    required Function(FieldDefinition) onSave,
  }) {
    final nameController = TextEditingController(text: field?.name ?? '');
    final labelController = TextEditingController(text: field?.label ?? '');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          FieldType selectedType = field?.type ?? FieldType.text;
          bool isRequired = field?.isRequired ?? false;

          return AlertDialog(
            title: Text(field == null ? '添加字段' : '编辑字段'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: '字段名(英文)',
                      hintText: '如: name, age, description',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: labelController,
                    decoration: const InputDecoration(
                      labelText: '显示名称',
                      hintText: '如: 姓名, 年龄, 描述',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<FieldType>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: '字段类型',
                    ),
                    items: FieldType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getFieldTypeName(type)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('必填字段'),
                    value: isRequired,
                    onChanged: (value) {
                      setDialogState(() {
                        isRequired = value!;
                      });
                    },
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
                onPressed: () {
                  if (nameController.text.isEmpty ||
                      labelController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('请填写完整信息')),
                    );
                    return;
                  }

                  final newField = FieldDefinition(
                    id: field?.id ?? widget.dataService.generateId(),
                    name: nameController.text,
                    label: labelController.text,
                    type: selectedType,
                    isRequired: isRequired,
                    fieldGroup: fieldGroup,
                  );
                  onSave(newField);
                  Navigator.pop(context);
                },
                child: const Text('保存'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getFieldTypeName(FieldType type) {
    switch (type) {
      case FieldType.text:
        return '文本';
      case FieldType.number:
        return '数字';
      case FieldType.date:
        return '日期';
      case FieldType.select:
        return '选择';
      case FieldType.textarea:
        return '多行文本';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('项目设置'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '项目名称',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? '请输入项目名称' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '项目字段配置',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '每个项目都有独立的字段配置，创建时导入的模板配置仅作为初始设置，您可以自由修改而不影响原模板。',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _reapplyTemplate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('重新应用模板'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            _buildFieldSection(
              title: '角色字段',
              fields: _characterFields,
              onAdd: _addCharacterField,
              onEdit: _editCharacterField,
              onDelete: _deleteCharacterField,
            ),
            const SizedBox(height: 24),
            _buildFieldSection(
              title: '地图字段',
              fields: _mapFields,
              onAdd: _addMapField,
              onEdit: _editMapField,
              onDelete: _deleteMapField,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldSection({
    required String title,
    required List<FieldDefinition> fields,
    required VoidCallback onAdd,
    required Function(int) onEdit,
    required Function(int) onDelete,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('添加字段'),
            ),
          ],
        ),
        const Divider(),
        if (fields.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('暂无字段，点击添加'),
          )
        else
          ...fields.asMap().entries.map((entry) {
            final index = entry.key;
            final field = entry.value;
            return Card(
              child: ListTile(
                title: Text(field.label),
                subtitle: Text(
                    '${field.name} - ${_getFieldTypeName(field.type)}${field.isRequired ? ' (必填)' : ''}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => onEdit(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onDelete(index),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}