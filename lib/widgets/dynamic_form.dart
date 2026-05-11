import 'package:flutter/material.dart';
import '../models/field_definition.dart';

class DynamicForm extends StatefulWidget {
  final List<FieldDefinition> fields;
  final Map<String, dynamic> initialValues;
  final Function(Map<String, dynamic>) onChanged;
  final bool enabled;

  const DynamicForm({
    super.key,
    required this.fields,
    this.initialValues = const {},
    required this.onChanged,
    this.enabled = true,
  });

  @override
  State<DynamicForm> createState() => DynamicFormState();
}

class DynamicFormState extends State<DynamicForm> {
  late Map<String, dynamic> _values;

  @override
  void initState() {
    super.initState();
    _values = Map.from(widget.initialValues);
  }

  @override
  void didUpdateWidget(DynamicForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValues != oldWidget.initialValues) {
      _values = Map.from(widget.initialValues);
    }
  }

  void updateValue(String fieldName, dynamic value) {
    setState(() {
      _values[fieldName] = value;
    });
    widget.onChanged(_values);
  }

  dynamic getValue(String fieldName) {
    return _values[fieldName];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.fields.map((field) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildField(field),
        );
      }).toList(),
    );
  }

  Widget _buildField(FieldDefinition field) {
    switch (field.type) {
      case FieldType.text:
        return _buildTextField(field);
      case FieldType.number:
        return _buildNumberField(field);
      case FieldType.date:
        return _buildDateField(field);
      case FieldType.select:
        return _buildSelectField(field);
      case FieldType.textarea:
        return _buildTextAreaField(field);
    }
  }

  Widget _buildTextField(FieldDefinition field) {
    return TextFormField(
      initialValue: _values[field.name] as String?,
      decoration: InputDecoration(
        labelText: field.label + (field.isRequired ? ' *' : ''),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      enabled: widget.enabled,
      onChanged: (value) => updateValue(field.name, value),
      validator: field.isRequired
          ? (value) => value?.isEmpty ?? true ? '请输入${field.label}' : null
          : null,
    );
  }

  Widget _buildNumberField(FieldDefinition field) {
    return TextFormField(
      initialValue: _values[field.name]?.toString(),
      decoration: InputDecoration(
        labelText: field.label + (field.isRequired ? ' *' : ''),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      keyboardType: TextInputType.number,
      enabled: widget.enabled,
      onChanged: (value) {
        if (value.isEmpty) {
          updateValue(field.name, null);
        } else {
          final number = double.tryParse(value);
          updateValue(field.name, number);
        }
      },
      validator: field.isRequired
          ? (value) {
              if (value?.isEmpty ?? true) return '请输入${field.label}';
              if (double.tryParse(value!) == null) return '请输入有效数字';
              return null;
            }
          : null,
    );
  }

  Widget _buildDateField(FieldDefinition field) {
    return InkWell(
      onTap: widget.enabled
          ? () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _values[field.name] as DateTime? ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                updateValue(field.name, date);
              }
            }
          : null,
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
              _values[field.name] != null
                  ? _formatDate(_values[field.name] as DateTime)
                  : '选择日期',
              style: TextStyle(
                color: _values[field.name] != null ? Colors.black : Colors.grey,
              ),
            ),
            const Icon(Icons.calendar_today, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectField(FieldDefinition field) {
    return DropdownButtonFormField<String>(
      initialValue: _values[field.name] as String?,
      decoration: InputDecoration(
        labelText: field.label + (field.isRequired ? ' *' : ''),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: (field.options ?? []).map((option) {
        return DropdownMenuItem(
          value: option,
          child: Text(option),
        );
      }).toList(),
      onChanged:
          widget.enabled ? (value) => updateValue(field.name, value) : null,
      validator: field.isRequired
          ? (value) => value == null ? '请选择${field.label}' : null
          : null,
    );
  }

  Widget _buildTextAreaField(FieldDefinition field) {
    return TextFormField(
      initialValue: _values[field.name] as String?,
      decoration: InputDecoration(
        labelText: field.label + (field.isRequired ? ' *' : ''),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      maxLines: 4,
      enabled: widget.enabled,
      onChanged: (value) => updateValue(field.name, value),
      validator: field.isRequired
          ? (value) => value?.isEmpty ?? true ? '请输入${field.label}' : null
          : null,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
