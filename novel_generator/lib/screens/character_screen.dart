import 'package:flutter/material.dart';
import '../models/character.dart';
import '../models/template.dart';
import '../models/field_definition.dart';
import '../services/data_service.dart';

class CharacterScreen extends StatefulWidget {
  final DataService dataService;

  const CharacterScreen({super.key, required this.dataService});

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {
  List<Character> _characters = [];
  Character? _selectedCharacter;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _genderController = TextEditingController();
  final _personalityController = TextEditingController();
  final _backgroundController = TextEditingController();
  final Map<String, TextEditingController> _customFieldControllers = {};

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    final projectId = widget.dataService.currentProjectId;
    if (projectId != null) {
      setState(() {
        _characters = widget.dataService.getCharacters(projectId);
      });
    }
  }

  Future<void> _showCharacterDialog([Character? character]) async {
    _clearForm();
    
    if (character != null) {
      _selectedCharacter = character;
      _nameController.text = character.name;
      _ageController.text = character.age?.toString() ?? '';
      _genderController.text = character.gender ?? '';
      _personalityController.text = character.personality ?? '';
      _backgroundController.text = character.background ?? '';
      
      final template = widget.dataService.getTemplate(widget.dataService.getProject(widget.dataService.currentProjectId!)!.templateId);
      if (template != null) {
        for (final field in template.characterFields) {
          if (!['name', 'age', 'gender', 'personality', 'background'].contains(field.name)) {
            _customFieldControllers[field.name] = TextEditingController(
              text: character.customFields[field.name]?.toString() ?? '',
            );
          }
        }
      }
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(character == null ? '创建角色' : '编辑角色'),
        content: SizedBox(
          width: 500,
          height: 500,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: _buildFormFields(),
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
                await _saveCharacter();
                Navigator.pop(context);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFormFields() {
    final fields = <Widget>[];
    
    fields.add(
      TextFormField(
        controller: _nameController,
        decoration: const InputDecoration(labelText: '姓名 *'),
        validator: (value) => value?.isEmpty ?? true ? '请输入姓名' : null,
      ),
    );
    
    fields.add(
      TextFormField(
        controller: _ageController,
        decoration: const InputDecoration(labelText: '年龄'),
        keyboardType: TextInputType.number,
      ),
    );
    
    fields.add(
      TextFormField(
        controller: _genderController,
        decoration: const InputDecoration(labelText: '性别'),
      ),
    );
    
    fields.add(
      TextFormField(
        controller: _personalityController,
        decoration: const InputDecoration(labelText: '性格'),
        maxLines: 3,
      ),
    );
    
    fields.add(
      TextFormField(
        controller: _backgroundController,
        decoration: const InputDecoration(labelText: '背景故事'),
        maxLines: 4,
      ),
    );

    final template = widget.dataService.getTemplate(widget.dataService.getProject(widget.dataService.currentProjectId!)!.templateId);
    if (template != null) {
      for (final field in template.characterFields) {
        if (!['name', 'age', 'gender', 'personality', 'background'].contains(field.name)) {
          if (_customFieldControllers[field.name] == null) {
            _customFieldControllers[field.name] = TextEditingController();
          }
          
          fields.add(
            TextFormField(
              controller: _customFieldControllers[field.name],
              decoration: InputDecoration(
                labelText: '${field.label}${field.isRequired ? ' *' : ''}',
              ),
              maxLines: field.type == FieldType.textarea ? 3 : 1,
              keyboardType: field.type == FieldType.number ? TextInputType.number : TextInputType.text,
              validator: field.isRequired 
                  ? (value) => value?.isEmpty ?? true ? '请输入${field.label}' : null
                  : null,
            ),
          );
        }
      }
    }

    return fields;
  }

  void _clearForm() {
    _selectedCharacter = null;
    _nameController.clear();
    _ageController.clear();
    _genderController.clear();
    _personalityController.clear();
    _backgroundController.clear();
    _customFieldControllers.forEach((_, controller) => controller.clear());
  }

  Future<void> _saveCharacter() async {
    final projectId = widget.dataService.currentProjectId!;
    final customFields = <String, dynamic>{};
    
    final template = widget.dataService.getTemplate(widget.dataService.getProject(projectId)!.templateId);
    if (template != null) {
      for (final field in template.characterFields) {
        if (!['name', 'age', 'gender', 'personality', 'background'].contains(field.name)) {
          final value = _customFieldControllers[field.name]?.text;
          if (value != null && value.isNotEmpty) {
            customFields[field.name] = field.type == FieldType.number ? num.tryParse(value) : value;
          }
        }
      }
    }

    final character = Character(
      id: _selectedCharacter?.id ?? widget.dataService.generateId(),
      projectId: projectId,
      name: _nameController.text,
      age: int.tryParse(_ageController.text),
      gender: _genderController.text.isNotEmpty ? _genderController.text : null,
      personality: _personalityController.text.isNotEmpty ? _personalityController.text : null,
      background: _backgroundController.text.isNotEmpty ? _backgroundController.text : null,
      customFields: customFields,
    );

    await widget.dataService.saveCharacter(character);
    _loadCharacters();
  }

  Future<void> _deleteCharacter(String id) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个角色吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await widget.dataService.deleteCharacter(id);
              Navigator.pop(context);
              _loadCharacters();
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
      body: _characters.isEmpty
          ? const Center(child: Text('暂无角色'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _characters.length,
              itemBuilder: (context, index) {
                final character = _characters[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(character.name),
                    subtitle: Text(character.age != null ? '年龄: ${character.age}' : ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showCharacterDialog(character),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCharacter(character.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCharacterDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
