import 'package:flutter/material.dart';
import '../models/template.dart';
import '../models/field_definition.dart';
import '../services/data_service.dart';

class TemplateListScreen extends StatefulWidget {
  final DataService dataService;

  const TemplateListScreen({super.key, required this.dataService});

  @override
  State<TemplateListScreen> createState() => _TemplateListScreenState();
}

class _TemplateListScreenState extends State<TemplateListScreen> {
  List<Template> _templates = [];

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() {
      _templates = widget.dataService.getAllTemplates();
    });
  }

  Future<void> _createTemplate() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TemplateEditScreen(
          dataService: widget.dataService,
          template: null,
          onSaved: _loadTemplates,
        ),
      ),
    );
  }

  Future<void> _editTemplate(Template template) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TemplateEditScreen(
          dataService: widget.dataService,
          template: template,
          onSaved: _loadTemplates,
        ),
      ),
    );
  }

  Future<void> _deleteTemplate(Template template) async {
    if (template.isPreset) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('预设模板不可删除')),
      );
      return;
    }

    final projectsUsingTemplate = widget.dataService
        .getAllProjects()
        .where((p) => p.templateId == template.id)
        .toList();

    if (projectsUsingTemplate.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('该模板正在被项目使用，无法删除')),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除模板"${template.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await widget.dataService.deleteTemplate(template.id);
              Navigator.pop(context);
              _loadTemplates();
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
        title: const Text('模板管理'),
        centerTitle: true,
      ),
      body: _templates.isEmpty
          ? const Center(
              child: Text('暂无模板'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _templates.length,
              itemBuilder: (context, index) {
                final template = _templates[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(
                      template.isPreset ? Icons.star : Icons.description,
                      color: template.isPreset ? Colors.amber : Colors.grey,
                    ),
                    title: Text(template.name),
                    subtitle: Text(
                      '${template.characterFields.length}个角色字段, ${template.mapFields.length}个地图字段',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editTemplate(template),
                        ),
                        if (!template.isPreset)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTemplate(template),
                          ),
                      ],
                    ),
                    onTap: () => _editTemplate(template),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createTemplate,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TemplateEditScreen extends StatefulWidget {
  final DataService dataService;
  final Template? template;
  final VoidCallback? onSaved;

  const TemplateEditScreen({
    super.key,
    required this.dataService,
    this.template,
    this.onSaved,
  });

  @override
  State<TemplateEditScreen> createState() => _TemplateEditScreenState();
}

class _TemplateEditScreenState extends State<TemplateEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<FieldDefinition> _characterFields = [];
  List<FieldDefinition> _mapFields = [];

  bool get isEditing => widget.template != null;

  @override
  void initState() {
    super.initState();
    if (widget.template != null) {
      _nameController.text = widget.template!.name;
      _descriptionController.text = widget.template!.description ?? '';
      _characterFields = List.from(widget.template!.characterFields);
      _mapFields = List.from(widget.template!.mapFields);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTemplate() async {
    if (!_formKey.currentState!.validate()) return;

    final template = Template(
      id: widget.template?.id ?? widget.dataService.generateId(),
      name: _nameController.text,
      description: _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : null,
      isPreset: false,
      characterFields: _characterFields,
      mapFields: _mapFields,
    );

    await widget.dataService.saveTemplate(template);
    widget.onSaved?.call();
    Navigator.pop(context);
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

  Future<void> _saveAsNewTemplate() async {
    if (!_formKey.currentState!.validate()) return;

    final template = Template(
      id: widget.dataService.generateId(),
      name: '${_nameController.text} (副本)',
      description: _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : null,
      isPreset: false,
      characterFields: _characterFields,
      mapFields: _mapFields,
    );

    await widget.dataService.saveTemplate(template);
    widget.onSaved?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('模板已另存为新模板')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '编辑模板' : '新建模板'),
        centerTitle: true,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: _saveAsNewTemplate,
              tooltip: '另存为',
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTemplate,
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
                labelText: '模板名称',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? '请输入模板名称' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '模板描述',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            _buildFieldSection(
              title: '角色字段',
              fields: _characterFields,
              onAdd: _addCharacterField,
              onEdit: _editCharacterField,
            ),
            const SizedBox(height: 24),
            _buildFieldSection(
              title: '地图字段',
              fields: _mapFields,
              onAdd: _addMapField,
              onEdit: _editMapField,
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
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => onEdit(index),
                ),
              ),
            );
          }),
      ],
    );
  }
}
