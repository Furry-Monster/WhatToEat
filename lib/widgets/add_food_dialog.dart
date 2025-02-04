import 'package:flutter/material.dart';
import 'package:witch_one/models/food_data.dart';
import 'package:witch_one/theme/app_theme.dart';

class AddFoodDialog extends StatefulWidget {
  final List<FoodCategory> categories;
  final List<FoodTag> tags;

  const AddFoodDialog({
    super.key,
    required this.categories,
    required this.tags,
  });

  @override
  State<AddFoodDialog> createState() => _AddFoodDialogState();
}

class _AddFoodDialogState extends State<AddFoodDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late String _selectedCategory;
  final Set<String> _selectedTags = {};

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.categories.first.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                '添加食物',
                style: AppTheme.dialogTitleStyle(context),
              ),
              const SizedBox(height: AppTheme.spacingNormal),
              TextFormField(
                controller: _nameController,
                decoration: AppTheme.textFieldDecoration.copyWith(
                  labelText: '食物名称',
                ),
                style: const TextStyle(fontSize: 16),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入食物名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacingNormal),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: AppTheme.dropdownDecoration.copyWith(
                  labelText: '分类',
                ),
                style: const TextStyle(fontSize: 16),
                items: widget.categories.map((category) {
                  return DropdownMenuItem(
                    value: category.name,
                    child: Text(
                      '${category.icon} ${category.name}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: AppTheme.spacingNormal),
              Text(
                '标签',
                style: AppTheme.dialogSubtitleStyle(context),
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              Theme(
                data: Theme.of(context).copyWith(
                  chipTheme: AppTheme.tagChipTheme,
                ),
                child: Wrap(
                  spacing: AppTheme.tagChipSpacing,
                  runSpacing: AppTheme.tagChipSpacing,
                  children: widget.tags.map((tag) {
                    final isSelected = _selectedTags.contains(tag.name);
                    return FilterChip(
                      label: Text(tag.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTags.add(tag.name);
                          } else {
                            _selectedTags.remove(tag.name);
                          }
                        });
                      },
                      backgroundColor: tag.color.withOpacity(0.2),
                      selectedColor: tag.color,
                      labelStyle: isSelected
                          ? AppTheme.tagChipSelectedLabelStyle
                          : AppTheme.tagChipLabelStyle(tag.color),
                    );
                  }).toList(),
                ),
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
                    child: const Text('添加'),
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
      final food = FoodData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        categoryId: _selectedCategory,
        tagIds: _selectedTags.toList(),
      );
      Navigator.pop(context, food);
    }
  }
}
