import 'package:flutter/material.dart';
import 'package:witch_one/models/food_data.dart';
import 'package:witch_one/theme/app_theme.dart';
import 'package:witch_one/theme/colors.dart';

class EditFoodDialog extends StatefulWidget {
  final FoodData food;
  final List<FoodCategory> categories;
  final List<FoodTag> tags;

  const EditFoodDialog({
    super.key,
    required this.food,
    required this.categories,
    required this.tags,
  });

  @override
  State<EditFoodDialog> createState() => _EditFoodDialogState();
}

class _EditFoodDialogState extends State<EditFoodDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late String _selectedCategory;
  late final Set<String> _selectedTags;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.food.name);
    _selectedCategory = widget.food.categoryId;
    _selectedTags = Set.from(widget.food.tagIds);
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
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient.scale(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '编辑食物',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.onBackground,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('确认删除'),
                            content: const Text('确定要删除这个食物吗？'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('取消'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // 关闭确认对话框
                                  Navigator.pop(
                                      context, null); // 关闭编辑对话框，返回null表示删除
                                },
                                child: const Text(
                                  '删除',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.tags.map((tag) {
                    return FilterChip(
                      label: Text(tag.name),
                      selected: _selectedTags.contains(tag.name),
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
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: _selectedTags.contains(tag.name)
                            ? Colors.white
                            : tag.color,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _submit,
                      child: const Text('保存'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final updatedFood = FoodData(
        id: widget.food.id,
        name: _nameController.text.trim(),
        categoryId: _selectedCategory,
        tagIds: _selectedTags.toList(),
        isActive: widget.food.isActive,
      );
      Navigator.pop(context, updatedFood);
    }
  }
}
