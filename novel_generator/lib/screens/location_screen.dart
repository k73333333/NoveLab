import 'package:flutter/material.dart';
import '../models/location.dart';
import '../models/template.dart';
import '../models/field_definition.dart';
import '../services/data_service.dart';

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
  final _descriptionController = TextEditingController();
  final _areaSizeController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final Map<String, TextEditingController> _customFieldControllers = {};

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    final projectId = widget.dataService.currentProjectId;
    if (projectId != null) {
      setState(() {
        _locations = widget.dataService.getLocations(projectId);
      });
    }
  }

  Future<void> _showLocationDialog([Location? location]) async {
    _clearForm();
    
    if (location != null) {
      _selectedLocation = location;
      _nameController.text = location.name;
      _descriptionController.text = location.description ?? '';
      _areaSizeController.text = location.areaSize?.toString() ?? '';
      _latitudeController.text = location.latitude?.toString() ?? '';
      _longitudeController.text = location.longitude?.toString() ?? '';
      
      final template = widget.dataService.getTemplate(widget.dataService.getProject(widget.dataService.currentProjectId!)!.templateId);
      if (template != null) {
        for (final field in template.mapFields) {
          if (!['name', 'description', 'areaSize', 'latitude', 'longitude'].contains(field.name)) {
            _customFieldControllers[field.name] = TextEditingController(
              text: location.customFields[field.name]?.toString() ?? '',
            );
          }
        }
      }
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(location == null ? '创建地点' : '编辑地点'),
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
                await _saveLocation();
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
        decoration: const InputDecoration(labelText: '名称 *'),
        validator: (value) => value?.isEmpty ?? true ? '请输入名称' : null,
      ),
    );
    
    fields.add(
      TextFormField(
        controller: _descriptionController,
        decoration: const InputDecoration(labelText: '描述'),
        maxLines: 3,
      ),
    );
    
    fields.add(
      TextFormField(
        controller: _areaSizeController,
        decoration: const InputDecoration(labelText: '面积(km²)'),
        keyboardType: TextInputType.number,
      ),
    );
    
    fields.add(
      TextFormField(
        controller: _latitudeController,
        decoration: const InputDecoration(labelText: '纬度'),
        keyboardType: TextInputType.number,
      ),
    );
    
    fields.add(
      TextFormField(
        controller: _longitudeController,
        decoration: const InputDecoration(labelText: '经度'),
        keyboardType: TextInputType.number,
      ),
    );

    final template = widget.dataService.getTemplate(widget.dataService.getProject(widget.dataService.currentProjectId!)!.templateId);
    if (template != null) {
      for (final field in template.mapFields) {
        if (!['name', 'description', 'areaSize', 'latitude', 'longitude'].contains(field.name)) {
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
    _selectedLocation = null;
    _nameController.clear();
    _descriptionController.clear();
    _areaSizeController.clear();
    _latitudeController.clear();
    _longitudeController.clear();
    _customFieldControllers.forEach((_, controller) => controller.clear());
  }

  Future<void> _saveLocation() async {
    final projectId = widget.dataService.currentProjectId!;
    final customFields = <String, dynamic>{};
    
    final template = widget.dataService.getTemplate(widget.dataService.getProject(projectId)!.templateId);
    if (template != null) {
      for (final field in template.mapFields) {
        if (!['name', 'description', 'areaSize', 'latitude', 'longitude'].contains(field.name)) {
          final value = _customFieldControllers[field.name]?.text;
          if (value != null && value.isNotEmpty) {
            customFields[field.name] = field.type == FieldType.number ? num.tryParse(value) : value;
          }
        }
      }
    }

    final location = Location(
      id: _selectedLocation?.id ?? widget.dataService.generateId(),
      projectId: projectId,
      name: _nameController.text,
      description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      areaSize: double.tryParse(_areaSizeController.text),
      latitude: double.tryParse(_latitudeController.text),
      longitude: double.tryParse(_longitudeController.text),
      customFields: customFields,
    );

    await widget.dataService.saveLocation(location);
    _loadLocations();
  }

  Future<void> _deleteLocation(String id) async {
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
              await widget.dataService.deleteLocation(id);
              Navigator.pop(context);
              _loadLocations();
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
      body: _locations.isEmpty
          ? const Center(child: Text('暂无地点'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _locations.length,
              itemBuilder: (context, index) {
                final location = _locations[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(location.name),
                    subtitle: Text(location.areaSize != null ? '面积: ${location.areaSize} km²' : ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showLocationDialog(location),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteLocation(location.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLocationDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
