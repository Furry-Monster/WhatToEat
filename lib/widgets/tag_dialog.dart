import 'package:flutter/material.dart';
import 'package:witch_one/models/food_data.dart';
import 'package:witch_one/theme/app_theme.dart';

class TagDialog extends StatefulWidget {
  final FoodTag? tag;

  const TagDialog({
    super.key,
    this.tag,
  });

  @override
  State<TagDialog> createState() => _TagDialogState();
}

class _TagDialogState extends State<TagDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late Color _selectedColor;

  static const List<Color> _colorOptions = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tag?.name);
    _selectedColor = widget.tag?.color ?? _colorOptions.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.tag != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: AppTheme.dialogDecoration,
        padding: AppTheme.dialogPadding,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? '编辑标签' : '添加标签',
                style: AppTheme.dialogTitleStyle(context),
              ),
              const SizedBox(height: AppTheme.spacingNormal),
              TextFormField(
                controller: _nameController,
                decoration: AppTheme.textFieldDecoration.copyWith(
                  labelText: '标签名称',
                ),
                style: const TextStyle(fontSize: 16),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入标签名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacingNormal),
              Text(
                '标签颜色',
                style: AppTheme.dialogSubtitleStyle(context),
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              Wrap(
                spacing: AppTheme.spacingSmall,
                runSpacing: AppTheme.spacingSmall,
                children: _colorOptions.map((color) {
                  return InkWell(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedColor == color
                              ? Colors.white
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppTheme.spacingNormal),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: AppTheme.spacingSmall),
                  FilledButton(
                    onPressed: _submit,
                    style: AppTheme.filledButtonStyle,
                    child: Text(isEditing ? '保存' : '添加'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final tag = FoodTag(
        name: _nameController.text.trim(),
        color: _selectedColor,
      );
      Navigator.pop(context, tag);
    }
  }
}
