import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witch_one/models/food_data.dart';
import 'package:witch_one/models/food_item.dart';
import 'package:flutter/material.dart';

class StorageService {
  static const String _historyKey = 'food_history';
  static const String _foodDataKey = 'food_data';
  static const String _categoriesKey = 'food_categories';
  static const String _tagsKey = 'food_tags';

  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 历史记录操作
  Future<List<FoodItem>> getHistory() async {
    final String? historyJson = _prefs.getString(_historyKey);
    if (historyJson == null) return [];

    final List<dynamic> decoded = jsonDecode(historyJson);
    return decoded.map((item) => FoodItem.fromJson(item)).toList();
  }

  Future<void> saveHistory(List<FoodItem> history) async {
    await _prefs.setString(
      _historyKey,
      jsonEncode(history.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> addToHistory(FoodItem item) async {
    final history = await getHistory();
    history.insert(0, item);

    if (history.length > 50) {
      history.removeRange(50, history.length);
    }

    await saveHistory(history);
  }

  Future<void> clearHistory() async {
    await _prefs.remove(_historyKey);
  }

  // 食物数据操作
  Future<List<String>> getFoodOptions() async {
    final foodData = await getAllFoodData();
    if (foodData.isEmpty) {
      return ['火锅', '烤肉', '麻辣烫', '炒菜', '寿司', '披萨', '汉堡', '面条'];
    }
    return foodData
        .where((food) => food.isActive)
        .map((food) => food.name)
        .toList();
  }

  Future<List<FoodData>> getAllFoodData() async {
    final String? dataJson = _prefs.getString(_foodDataKey);
    if (dataJson == null) return [];

    final List<dynamic> decoded = jsonDecode(dataJson);
    return decoded.map((item) => FoodData.fromJson(item)).toList();
  }

  Future<void> saveFoodData(List<FoodData> foodList) async {
    await _prefs.setString(
      _foodDataKey,
      jsonEncode(foodList.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> addFoodData(FoodData food) async {
    final foodList = await getAllFoodData();
    foodList.add(food);
    await saveFoodData(foodList);
  }

  // 分类操作
  static final List<FoodCategory> defaultCategories = [
    FoodCategory(name: '中餐', icon: '🥘', foodIds: []),
    FoodCategory(name: '日料', icon: '🍱', foodIds: []),
    FoodCategory(name: '西餐', icon: '🍝', foodIds: []),
    FoodCategory(name: '快餐', icon: '🍔', foodIds: []),
    FoodCategory(name: '甜点', icon: '🍰', foodIds: []),
    FoodCategory(name: '饮品', icon: '🥤', foodIds: []),
  ];

  Future<List<FoodCategory>> getCategories() async {
    final String? categoriesJson = _prefs.getString(_categoriesKey);
    if (categoriesJson == null) {
      await saveCategories(defaultCategories);
      return defaultCategories;
    }

    final List<dynamic> decoded = jsonDecode(categoriesJson);
    return decoded.map((item) => FoodCategory.fromJson(item)).toList();
  }

  Future<void> saveCategories(List<FoodCategory> categories) async {
    await _prefs.setString(
      _categoriesKey,
      jsonEncode(categories.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> addCategory(FoodCategory category) async {
    final categories = await getCategories();
    if (categories.any((c) => c.name == category.name)) {
      throw Exception('分类已存在');
    }
    categories.add(category);
    await saveCategories(categories);
  }

  Future<void> updateCategory(
      FoodCategory oldCategory, FoodCategory newCategory) async {
    final categories = await getCategories();
    final index = categories.indexWhere((c) => c.name == oldCategory.name);
    if (index == -1) {
      throw Exception('分类不存在');
    }
    categories[index] = newCategory;
    await saveCategories(categories);

    // 更新相关食物的分类
    if (oldCategory.name != newCategory.name) {
      final foodList = await getAllFoodData();
      final updatedFoodList = foodList.map((food) {
        if (food.categoryId == oldCategory.name) {
          return food.copyWith(categoryId: newCategory.name);
        }
        return food;
      }).toList();
      await saveFoodData(updatedFoodList);
    }
  }

  Future<void> deleteCategory(FoodCategory category) async {
    final categories = await getCategories();
    if (categories.length <= 1) {
      throw Exception('至少保留一个分类');
    }

    // 检查是否有食物使用此分类
    final foodList = await getAllFoodData();
    if (foodList.any((food) => food.categoryId == category.name)) {
      throw Exception('此分类下还有食物，无法删除');
    }

    categories.removeWhere((c) => c.name == category.name);
    await saveCategories(categories);
  }

  // 标签操作
  static final List<FoodTag> defaultTags = [
    FoodTag(name: '辣', color: Colors.red),
    FoodTag(name: '甜', color: Colors.pink),
    FoodTag(name: '酸', color: Colors.green),
    FoodTag(name: '咸', color: Colors.orange),
    FoodTag(name: '清淡', color: Colors.blue),
    FoodTag(name: '重口味', color: Colors.purple),
  ];

  Future<List<FoodTag>> getTags() async {
    final String? tagsJson = _prefs.getString(_tagsKey);
    if (tagsJson == null) {
      await saveTags(defaultTags);
      return defaultTags;
    }

    final List<dynamic> decoded = jsonDecode(tagsJson);
    return decoded.map((item) => FoodTag.fromJson(item)).toList();
  }

  Future<void> saveTags(List<FoodTag> tags) async {
    await _prefs.setString(
      _tagsKey,
      jsonEncode(tags.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> addTag(FoodTag tag) async {
    final tags = await getTags();
    if (tags.any((t) => t.name == tag.name)) {
      throw Exception('标签已存在');
    }
    tags.add(tag);
    await saveTags(tags);
  }

  Future<void> updateTag(FoodTag oldTag, FoodTag newTag) async {
    final tags = await getTags();
    final index = tags.indexWhere((t) => t.name == oldTag.name);
    if (index == -1) {
      throw Exception('标签不存在');
    }
    tags[index] = newTag;
    await saveTags(tags);

    // 更新相关食物的标签
    if (oldTag.name != newTag.name) {
      final foodList = await getAllFoodData();
      final updatedFoodList = foodList.map((food) {
        if (food.tagIds.contains(oldTag.name)) {
          final newTagIds = food.tagIds
              .map((id) => id == oldTag.name ? newTag.name : id)
              .toList();
          return food.copyWith(tagIds: newTagIds);
        }
        return food;
      }).toList();
      await saveFoodData(updatedFoodList);
    }
  }

  Future<void> deleteTag(FoodTag tag) async {
    final tags = await getTags();

    // 从所有食物中移除此标签
    final foodList = await getAllFoodData();
    final updatedFoodList = foodList.map((food) {
      if (food.tagIds.contains(tag.name)) {
        return food.copyWith(
          tagIds: food.tagIds.where((id) => id != tag.name).toList(),
        );
      }
      return food;
    }).toList();
    await saveFoodData(updatedFoodList);

    tags.removeWhere((t) => t.name == tag.name);
    await saveTags(tags);
  }
}
