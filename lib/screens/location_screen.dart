import 'package:flutter/material.dart';
import '../models/location.dart';
import '../models/project.dart';
import '../models/field_definition.dart';
import '../services/data_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';

class LocationScreen extends StatefulWidget {
  final DataService dataService;

  const LocationScreen({super.key, required this.dataService});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  List<Location> _locations = [];
  Location? _selectedLocation;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  Map<String, dynamic> _customFieldValues = {};
  List<FieldDefinition> _mapFields = [];

  @override
  void initState() {
    super.initState();
    _loadLocations();
    _loadMapFields();
  }

  void _loadMapFields() {
    final projectId = widget.dataService.currentProjectId;
    if (projectId != null) {
      final project = widget.dataService.getProject(projectId);
      if (project != null) {
        _mapFields = project.mapFields;
      }
    }
    setState(() {});
  }

  Future<void> _loadLocations() async {
    setState(() {
      _locations = widget.dataService.getAllLocations();
    });
  }

  void _selectLocation(Location location) {
    setState(() {
      _selectedLocation = location;
      _nameController.text = location.name;
      _customFieldValues = Map.from(location.customFields);
    });
  }

  void _clearForm() {
    setState(() {
      _selectedLocation = null;
      _nameController.clear();
      _customFieldValues.clear();
    });
  }

  Future<void> _saveLocation() async {
    if (!_formKey.currentState!.validate()) return;

    final projectId = widget.dataService.currentProjectId;
    if (projectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择项目')),
      );
      return;
    }

    final location = Location(
      id: _selectedLocation?.id ?? widget.dataService.generateId(),
      projectId: projectId,
      name: _nameController.text,
      customFields: _customFieldValues,
    );

    await widget.dataService.saveLocation(location);
    _loadLocations();
    _clearForm();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('地点保存成功')),
    );
  }

  Future<void> _deleteLocation() async {
    if (_selectedLocation == null) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个地点吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await widget.dataService.deleteLocation(_selectedLocation!.id);
              _loadLocations();
              _clearForm();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('地点删除成功')),
              );
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicFields() {
    if (_mapFields.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('请先选择项目以加载字段'),
        ),
      );
    }

    return Column(
      children: _mapFields.map((field) {
        if (field.name == 'name') return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildFieldWidget(field),
        );
      }).toList(),
    );
  }

  Widget _buildFieldWidget(FieldDefinition field) {
    final value = _customFieldValues[field.name];

    switch (field.type) {
      case FieldType.text:
        return TextFormField(
          initialValue: value as String?,
          decoration: InputDecoration(
            labelText: field.label + (field.isRequired ? ' *' : ''),
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          onChanged: (v) => _customFieldValues[field.name] = v,
          validator: field.isRequired
              ? (v) => (v?.isEmpty ?? true) ? '请输入${field.label}' : null
              : null,
        );

      case FieldType.number:
        return TextFormField(
          initialValue: value?.toString(),
          decoration: InputDecoration(
            labelText: field.label + (field.isRequired ? ' *' : ''),
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          keyboardType: TextInputType.number,
          onChanged: (v) {
            if (v.isEmpty) {
              _customFieldValues[field.name] = null;
            } else {
              _customFieldValues[field.name] = double.tryParse(v);
            }
          },
          validator: field.isRequired
              ? (v) {
                  if (v?.isEmpty ?? true) return '请输入${field.label}';
                  if (double.tryParse(v!) == null) return '请输入有效数字';
                  return null;
                }
              : null,
        );

      case FieldType.date:
        return InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: value as DateTime? ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              setState(() {
                _customFieldValues[field.name] = date;
              });
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: field.label + (field.isRequired ? ' *' : ''),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value != null ? _formatDate(value as DateTime) : '选择日期',
                  style: TextStyle(
                    color: value != null ? Colors.black : Colors.grey,
                  ),
                ),
                const Icon(Icons.calendar_today, size: 20),
              ],
            ),
          ),
        );

      case FieldType.select:
        return DropdownButtonFormField<String>(
          initialValue: value as String?,
          decoration: InputDecoration(
            labelText: field.label + (field.isRequired ? ' *' : ''),
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items: (field.options ?? []).map((option) {
            return DropdownMenuItem(value: option, child: Text(option));
          }).toList(),
          onChanged: (v) => _customFieldValues[field.name] = v,
          validator: field.isRequired
              ? (v) => v == null ? '请选择${field.label}' : null
              : null,
        );

      case FieldType.textarea:
        return TextFormField(
          initialValue: value as String?,
          decoration: InputDecoration(
            labelText: field.label + (field.isRequired ? ' *' : ''),
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          maxLines: 3,
          onChanged: (v) => _customFieldValues[field.name] = v,
          validator: field.isRequired
              ? (v) => (v?.isEmpty ?? true) ? '请输入${field.label}' : null
              : null,
        );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: '地图管理'),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: _locations.length,
              itemBuilder: (context, index) {
                final location = _locations[index];
                return ListTile(
                  title: Text(location.name),
                  selected: _selectedLocation?.id == location.id,
                  onTap: () => _selectLocation(location),
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
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: '名称 *',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? '请输入名称' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDynamicFields(),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        CustomButton(
                          text: '保存',
                          onPressed: _saveLocation,
                        ),
                        const SizedBox(width: 16),
                        CustomButton(
                          text: '新建',
                          onPressed: _clearForm,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 16),
                        if (_selectedLocation != null)
                          CustomButton(
                            text: '删除',
                            onPressed: _deleteLocation,
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
