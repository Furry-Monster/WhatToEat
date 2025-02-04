import 'package:flutter/material.dart';
import 'package:witch_one/models/food_data.dart';
import 'package:witch_one/theme/app_theme.dart';

class CategoryDialog extends StatefulWidget {
  final FoodCategory? category;

  const CategoryDialog({
    super.key,
    this.category,
  });

  @override
  State<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _iconController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    _iconController = TextEditingController(text: widget.category?.icon);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;

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
                isEditing ? '编辑分类' : '添加分类',
                style: AppTheme.dialogTitleStyle(context),
              ),
              const SizedBox(height: AppTheme.spacingNormal),
              TextFormField(
                controller: _nameController,
                decoration: AppTheme.textFieldDecoration.copyWith(
                  labelText: '分类名称',
                ),
                style: const TextStyle(fontSize: 16),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入分类名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacingNormal),
              TextFormField(
                controller: _iconController,
                decoration: AppTheme.textFieldDecoration.copyWith(
                  labelText: '分类图标',
                ),
                style: const TextStyle(fontSize: 16),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入分类图标';
                  }
                  return null;
                },
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
      final category = FoodCategory(
        name: _nameController.text.trim(),
        icon: _iconController.text.trim(),
        foodIds: widget.category?.foodIds ?? [],
      );
      Navigator.pop(context, category);
    }
  }
}
