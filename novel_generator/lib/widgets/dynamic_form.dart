import 'package:flutter/material.dart';
import '../models/field_definition.dart';

class DynamicForm extends StatefulWidget {
  final List<FieldDefinition> fields;
  final Map<String, dynamic> initialValues;
  final void Function(Map<String, dynamic>) onSaved;

  const DynamicForm({
    super.key,
    required this.fields,
    required this.initialValues,
    required this.onSaved,
  });

  @override
  State<DynamicForm> createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    for (final field in widget.fields) {
      _controllers[field.name] = TextEditingController(
        text: widget.initialValues[field.name]?.toString() ?? '',
      );
    }
  }

  Widget _buildField(FieldDefinition field) {
    final controller = _controllers[field.name]!;
    
    return TextFormField(
      key: Key(field.name),
      controller: controller,
      decoration: InputDecoration(
        labelText: '${field.label}${field.isRequired ? ' *' : ''}',
        border: const OutlineInputBorder(),
      ),
      maxLines: field.type == FieldType.textarea ? 4 : 1,
      keyboardType: field.type == FieldType.number 
          ? TextInputType.number 
          : TextInputType.text,
      validator: field.isRequired 
          ? (value) => value?.isEmpty ?? true ? '请输入${field.label}' : null
          : null,
    );
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final values = <String, dynamic>{};
      for (final field in widget.fields) {
        final value = _controllers[field.name]?.text;
        if (value != null && value.isNotEmpty) {
          if (field.type == FieldType.number) {
            values[field.name] = num.tryParse(value);
          } else if (field.type == FieldType.date) {
            values[field.name] = DateTime.tryParse(value);
          } else {
            values[field.name] = value;
          }
        }
      }
      widget.onSaved(values);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          ...widget.fields.map(_buildField),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _saveForm,
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }
}
