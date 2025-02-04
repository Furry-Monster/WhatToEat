import 'package:flutter/material.dart';
import 'package:witch_one/models/food_data.dart';
import 'package:witch_one/services/storage_service.dart';
import 'package:witch_one/theme/colors.dart';
import 'package:witch_one/widgets/add_food_dialog.dart';
import 'package:witch_one/widgets/edit_food_dialog.dart';
import 'package:witch_one/widgets/category_dialog.dart';
import 'package:witch_one/widgets/tag_dialog.dart';
import 'package:witch_one/widgets/animated_background.dart';

class FoodDatabaseScreen extends StatefulWidget {
  const FoodDatabaseScreen({super.key});

  @override
  State<FoodDatabaseScreen> createState() => _FoodDatabaseScreenState();
}

class _FoodDatabaseScreenState extends State<FoodDatabaseScreen>
    with SingleTickerProviderStateMixin {
  final StorageService _storage = StorageService();

  List<FoodCategory> _categories = [];
  List<FoodData> _foodList = [];
  List<FoodTag> _tags = [];

  // 添加标签筛选状态
  final Set<String> _selectedFilterTags = {};

  // 添加筛选后的食物列表计算属性
  List<FoodData> get _filteredFoodList {
    if (_selectedFilterTags.isEmpty) {
      return _foodList;
    }
    return _foodList.where((food) {
      return _selectedFilterTags.every((tag) => food.tagIds.contains(tag));
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final categories = await _storage.getCategories();
    final foodList = await _storage.getAllFoodData();
    final tags = await _storage.getTags();

    setState(() {
      _categories = categories;
      _foodList = foodList;
      _tags = tags;
    });
  }

  void _showAddFoodDialog() async {
    final result = await showDialog<FoodData>(
      context: context,
      builder: (context) => AddFoodDialog(
        categories: _categories,
        tags: _tags,
      ),
    );

    if (result != null) {
      setState(() {
        _foodList.add(result);
      });
      await _storage.saveFoodData(_foodList);

      // 更新分类中的食物ID列表
      final categoryIndex =
          _categories.indexWhere((c) => c.name == result.categoryId);
      if (categoryIndex != -1) {
        setState(() {
          final updatedCategory = FoodCategory(
            name: _categories[categoryIndex].name,
            icon: _categories[categoryIndex].icon,
            foodIds: [..._categories[categoryIndex].foodIds, result.id],
          );
          _categories[categoryIndex] = updatedCategory;
        });
        await _storage.saveCategories(_categories);
      }
    }
  }

  void _showEditFoodDialog(FoodData food) async {
    final result = await showDialog<FoodData?>(
      context: context,
      builder: (context) => EditFoodDialog(
        food: food,
        categories: _categories,
        tags: _tags,
      ),
    );

    if (result == null) {
      // 删除食物
      setState(() {
        _foodList.removeWhere((f) => f.id == food.id);
      });
      await _storage.saveFoodData(_foodList);

      // 从分类中移除食物ID
      final categoryIndex =
          _categories.indexWhere((c) => c.name == food.categoryId);
      if (categoryIndex != -1) {
        setState(() {
          final updatedCategory = FoodCategory(
            name: _categories[categoryIndex].name,
            icon: _categories[categoryIndex].icon,
            foodIds: _categories[categoryIndex]
                .foodIds
                .where((id) => id != food.id)
                .toList(),
          );
          _categories[categoryIndex] = updatedCategory;
        });
        await _storage.saveCategories(_categories);
      }
    } else if (result != food) {
      // 更新食物
      setState(() {
        final index = _foodList.indexWhere((f) => f.id == food.id);
        if (index != -1) {
          _foodList[index] = result;
        }
      });
      await _storage.saveFoodData(_foodList);

      // 如果分类发生变化，更新分类的食物ID列表
      if (result.categoryId != food.categoryId) {
        // 从旧分类中移除
        final oldCategoryIndex =
            _categories.indexWhere((c) => c.name == food.categoryId);
        if (oldCategoryIndex != -1) {
          setState(() {
            final updatedCategory = FoodCategory(
              name: _categories[oldCategoryIndex].name,
              icon: _categories[oldCategoryIndex].icon,
              foodIds: _categories[oldCategoryIndex]
                  .foodIds
                  .where((id) => id != food.id)
                  .toList(),
            );
            _categories[oldCategoryIndex] = updatedCategory;
          });
        }

        // 添加到新分类
        final newCategoryIndex =
            _categories.indexWhere((c) => c.name == result.categoryId);
        if (newCategoryIndex != -1) {
          setState(() {
            final updatedCategory = FoodCategory(
              name: _categories[newCategoryIndex].name,
              icon: _categories[newCategoryIndex].icon,
              foodIds: [..._categories[newCategoryIndex].foodIds, result.id],
            );
            _categories[newCategoryIndex] = updatedCategory;
          });
        }

        await _storage.saveCategories(_categories);
      }
    }
  }

  // 添加排序相关的方法
  Future<void> _reorderFood(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    setState(() {
      final food = _filteredFoodList[oldIndex];
      _foodList.remove(food);
      _foodList.insert(
        _foodList.indexWhere((f) => f.id == _filteredFoodList[newIndex].id),
        food,
      );
    });

    await _storage.saveFoodData(_foodList);
  }

  Future<void> _reorderCategory(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    setState(() {
      final category = _categories.removeAt(oldIndex);
      _categories.insert(newIndex, category);
    });

    await _storage.saveCategories(_categories);
  }

  // 添加管理分类的方法
  Future<void> _showCategoryDialog([FoodCategory? category]) async {
    final result = await showDialog<FoodCategory>(
      context: context,
      builder: (context) => CategoryDialog(category: category),
    );

    if (result != null) {
      try {
        if (category == null) {
          await _storage.addCategory(result);
        } else {
          await _storage.updateCategory(category, result);
        }
        await _loadData();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _deleteCategory(FoodCategory category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个分类吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '删除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _storage.deleteCategory(category);
        await _loadData();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  // 添加管理标签的方法
  Future<void> _showTagDialog([FoodTag? tag]) async {
    final result = await showDialog<FoodTag>(
      context: context,
      builder: (context) => TagDialog(tag: tag),
    );

    if (result != null) {
      try {
        if (tag == null) {
          await _storage.addTag(result);
        } else {
          await _storage.updateTag(tag, result);
        }
        await _loadData();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _deleteTag(FoodTag tag) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个标签吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '删除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _storage.deleteTag(tag);
        await _loadData();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  // 添加设置对话框
  Future<void> _showSettingsDialog() async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient.scale(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '管理分类和标签',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              Text(
                '分类',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.onBackground,
                    ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100, // 固定高度
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length + 1, // +1 for add button
                  itemBuilder: (context, index) {
                    if (index == _categories.length) {
                      return Center(
                        child: InkWell(
                          onTap: () => _showCategoryDialog(),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.onBackgroundMuted,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.add,
                              color: AppColors.onBackgroundMuted,
                              size: 32,
                            ),
                          ),
                        ),
                      );
                    }

                    final category = _categories[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => _showCategoryDialog(category),
                        onLongPress: () => _deleteCategory(category),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient.scale(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                category.icon,
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                category.name,
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '标签',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.onBackground,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._tags.map(
                    (tag) => InputChip(
                      label: Text(tag.name),
                      backgroundColor: tag.color,
                      labelStyle: const TextStyle(color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                        _showTagDialog(tag);
                      },
                      onDeleted: () {
                        Navigator.pop(context);
                        _deleteTag(tag);
                      },
                    ),
                  ),
                  ActionChip(
                    label: const Text('添加'),
                    avatar: const Icon(Icons.add, size: 18),
                    onPressed: () {
                      Navigator.pop(context);
                      _showTagDialog();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('关闭'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('食物数据库'),
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            tabs: [
              Tab(text: '食物'),
              Tab(text: '标签'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showSettingsDialog,
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddFoodDialog,
            ),
          ],
        ),
        body: AnimatedBackground(
          child: TabBarView(
            children: [
              _buildFoodList(),
              _buildTagList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodList() {
    if (_foodList.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: AppColors.onBackgroundMuted,
            ),
            const SizedBox(height: 16),
            Text(
              '还没有添加任何食物\n点击右上角的+号添加',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.onBackgroundMuted,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _categories.length,
      onReorder: _reorderCategory,
      proxyDecorator: (child, index, animation) {
        return Material(
          elevation: 8,
          color: Colors.transparent,
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final category = _categories[index];
        final categoryFoods = _foodList
            .where((food) => food.categoryId == category.name)
            .toList();

        return Card(
          key: ValueKey(category.name),
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExpansionTile(
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_handle),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ],
                ),
                title: Text(category.name),
                children: [
                  if (categoryFoods.isNotEmpty)
                    ReorderableListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      onReorder: (oldIndex, newIndex) async {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final foods = categoryFoods.toList();
                        final food = foods.removeAt(oldIndex);
                        foods.insert(newIndex, food);

                        // 更新主列表中的顺序
                        setState(() {
                          for (var i = 0; i < foods.length; i++) {
                            final index = _foodList
                                .indexWhere((f) => f.id == foods[i].id);
                            if (index != -1) {
                              final food = _foodList.removeAt(index);
                              _foodList.insert(
                                _foodList.indexWhere(
                                      (f) => f.categoryId == category.name,
                                    ) +
                                    i,
                                food,
                              );
                            }
                          }
                        });
                        await _storage.saveFoodData(_foodList);
                      },
                      children: categoryFoods.map((food) {
                        final foodTags = _tags
                            .where((tag) => food.tagIds.contains(tag.name))
                            .toList();

                        return ListTile(
                          key: ValueKey(food.id),
                          leading: const Icon(Icons.drag_handle),
                          title: Text(food.name),
                          subtitle: Wrap(
                            spacing: 4,
                            children: foodTags.map((tag) {
                              return Chip(
                                label: Text(
                                  tag.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: tag.color,
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              );
                            }).toList(),
                          ),
                          onTap: () => _showEditFoodDialog(food),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTagList() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) {
              return FilterChip(
                label: Text(tag.name),
                selected: _selectedFilterTags.contains(tag.name),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedFilterTags.add(tag.name);
                    } else {
                      _selectedFilterTags.remove(tag.name);
                    }
                  });
                },
                backgroundColor: tag.color.withOpacity(0.2),
                selectedColor: tag.color,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: _selectedFilterTags.contains(tag.name)
                      ? Colors.white
                      : tag.color,
                ),
              );
            }).toList(),
          ),
        ),
        if (_filteredFoodList.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.no_meals,
                    size: 64,
                    color: AppColors.onBackgroundMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '没有找到符合条件的食物',
                    style: TextStyle(
                      color: AppColors.onBackgroundMuted,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredFoodList.length,
              onReorder: _reorderFood,
              proxyDecorator: (child, index, animation) {
                return Material(
                  elevation: 8,
                  color: Colors.transparent,
                  child: child,
                );
              },
              itemBuilder: (context, index) {
                final food = _filteredFoodList[index];
                final foodTags = _tags
                    .where((tag) => food.tagIds.contains(tag.name))
                    .toList();
                return Card(
                  key: ValueKey(food.id),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.drag_handle),
                    title: Text(food.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _categories
                              .firstWhere((cat) => cat.name == food.categoryId)
                              .name,
                        ),
                        if (foodTags.isNotEmpty)
                          Wrap(
                            spacing: 4,
                            children: foodTags.map((tag) {
                              return Chip(
                                label: Text(
                                  tag.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: tag.color,
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                    onTap: () => _showEditFoodDialog(food),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
