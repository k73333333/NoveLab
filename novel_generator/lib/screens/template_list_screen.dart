import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  Template? _selectedTemplate;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<FieldDefinition> _characterFields = [];
  List<FieldDefinition> _mapFields = [];
  final _fieldNameController = TextEditingController();
  final _fieldLabelController = TextEditingController();
  FieldType _fieldType = FieldType.text;
  bool _fieldRequired = false;
  String _fieldGroup = 'character';

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

  Future<void> _showTemplateDialog([Template? template]) async {
    _clearForm();
    
    if (template != null) {
      _selectedTemplate = template;
      _nameController.text = template.name;
      _descriptionController.text = template.description ?? '';
      _characterFields = List.from(template.characterFields);
      _mapFields = List.from(template.mapFields);
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(template == null ? '创建模板' : '编辑模板'),
        content: SizedBox(
          width: 600,
          height: 500,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: '模板名称 *'),
                    validator: (value) => value?.isEmpty ?? true ? '请输入模板名称' : null,
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: '模板描述'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildFieldSection('角色字段', _characterFields, 'character'),
                  const SizedBox(height: 16),
                  _buildFieldSection('地图字段', _mapFields, 'location'),
                  const SizedBox(height: 16),
                  _buildAddFieldForm(),
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
                await _saveTemplate();
                Navigator.pop(context);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldSection(String title, List<FieldDefinition> fields, String group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Text('(${fields.length}个字段)'),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          children: fields.map((field) {
            return Chip(
              label: Text('${field.label}${field.isRequired ? ' *' : ''}'),
              backgroundColor: field.isRequired ? Colors.orange.shade100 : Colors.grey.shade100,
              deleteIcon: _selectedTemplate?.isPreset != true
                  ? const Icon(Icons.close)
                  : null,
              onDeleted: _selectedTemplate?.isPreset != true
                  ? () {
                      setState(() {
                        if (group == 'character') {
                          _characterFields.remove(field);
                        } else {
                          _mapFields.remove(field);
                        }
                      });
                    }
                  : null,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAddFieldForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '添加新字段:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _fieldLabelController,
                decoration: const InputDecoration(labelText: '字段显示名称'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _fieldNameController,
                decoration: const InputDecoration(labelText: '字段标识名'),
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<FieldType>(
              value: _fieldType,
              items: FieldType.values.map((type) => DropdownMenuItem(
                value: type,
                child: Text(type.toString().split('.').last),
              )).toList(),
              onChanged: (value) => setState(() => _fieldType = value!),
            ),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: _fieldGroup,
              items: const [
                DropdownMenuItem(value: 'character', child: Text('角色')),
                DropdownMenuItem(value: 'location', child: Text('地图')),
              ],
              onChanged: (value) => setState(() => _fieldGroup = value!),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                Checkbox(
                  value: _fieldRequired,
                  onChanged: (value) => setState(() => _fieldRequired = value!),
                ),
                const Text('必填'),
              ],
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addField,
              child: const Text('添加'),
            ),
          ],
        ),
      ],
    );
  }

  void _addField() {
    if (_fieldLabelController.text.isEmpty || _fieldNameController.text.isEmpty) {
      return;
    }

    final field = FieldDefinition(
      id: widget.dataService.generateId(),
      name: _fieldNameController.text,
      label: _fieldLabelController.text,
      type: _fieldType,
      isRequired: _fieldRequired,
      fieldGroup: _fieldGroup,
    );

    setState(() {
      if (_fieldGroup == 'character') {
        _characterFields.add(field);
      } else {
        _mapFields.add(field);
      }
    });

    _fieldLabelController.clear();
    _fieldNameController.clear();
  }

  void _clearForm() {
    _selectedTemplate = null;
    _nameController.clear();
    _descriptionController.clear();
    _characterFields = [];
    _mapFields = [];
  }

  void _showExportDialog() {
    if (_templates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('没有可导出的模板')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导出模板'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('选择要导出的模板:'),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _templates.length,
                  itemBuilder: (context, index) {
                    final template = _templates[index];
                    return CheckboxListTile(
                      title: Text(template.name),
                      subtitle: Text(template.description ?? ''),
                      value: false,
                      onChanged: (value) {},
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final exportData = _templates.map((t) => t.toJson()).toList();
                  final jsonString = const JsonEncoder.withIndent('  ').convert({
                    'version': 1,
                    'templates': exportData,
                  });
                  
                  await Clipboard.setData(ClipboardData(text: jsonString));
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('模板已复制到剪贴板')),
                    );
                  }
                },
                child: const Text('复制所有模板到剪贴板'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导入模板'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('粘贴模板JSON数据:'),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                maxLines: 10,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '粘贴JSON数据...',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '提示: 可以从其他设备复制模板JSON并粘贴到此处',
                style: TextStyle(fontSize: 12, color: Colors.grey),
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
              try {
                final jsonData = jsonDecode(textController.text);
                final templatesData = jsonData['templates'] as List?;
                
                if (templatesData == null) {
                  throw FormatException('无效的模板数据');
                }

                int importedCount = 0;
                for (final t in templatesData) {
                  final template = Template.fromJson(t);
                  template.id = widget.dataService.generateId();
                  template.isPreset = false;
                  await widget.dataService.saveTemplate(template);
                  importedCount++;
                }

                if (context.mounted) {
                  Navigator.pop(context);
                  _loadTemplates();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('成功导入 $importedCount 个模板')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('导入失败: $e')),
                );
              }
            },
            child: const Text('导入'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTemplate() async {
    final template = Template(
      id: _selectedTemplate?.id ?? widget.dataService.generateId(),
      name: _nameController.text,
      description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      isPreset: _selectedTemplate?.isPreset ?? false,
      characterFields: _characterFields,
      mapFields: _mapFields,
    );

    await widget.dataService.saveTemplate(template);
    _loadTemplates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('模板管理'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'export') {
                _showExportDialog();
              } else if (value == 'import') {
                _showImportDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.upload),
                    SizedBox(width: 8),
                    Text('导入模板'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('导出模板'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _templates.isEmpty
          ? const Center(child: Text('暂无模板'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _templates.length,
              itemBuilder: (context, index) {
                final template = _templates[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(template.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (template.description != null)
                          Text(template.description!),
                        Text('角色字段: ${template.characterFields.length} | 地图字段: ${template.mapFields.length}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (template.isPreset)
                          const Chip(label: Text('预设')),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showTemplateDialog(template),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTemplateDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
