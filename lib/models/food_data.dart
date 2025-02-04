import 'dart:ui';

class FoodTag {
  final String name;
  final Color color;

  const FoodTag({
    required this.name,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'color': color.value,
      };

  factory FoodTag.fromJson(Map<String, dynamic> json) => FoodTag(
        name: json['name'],
        color: Color(json['color']),
      );
}

class FoodCategory {
  final String name;
  final String icon;
  final List<String> foodIds;

  const FoodCategory({
    required this.name,
    required this.icon,
    this.foodIds = const [],
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'icon': icon,
        'foodIds': foodIds,
      };

  factory FoodCategory.fromJson(Map<String, dynamic> json) => FoodCategory(
        name: json['name'],
        icon: json['icon'],
        foodIds: List<String>.from(json['foodIds'] ?? []),
      );
}

class FoodData {
  final String id;
  final String name;
  final String categoryId;
  final List<String> tagIds;
  final bool isActive;

  const FoodData({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.tagIds,
    this.isActive = true,
  });

  FoodData copyWith({
    String? id,
    String? name,
    String? categoryId,
    List<String>? tagIds,
    bool? isActive,
  }) {
    return FoodData(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      tagIds: tagIds ?? this.tagIds,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tagIds': tagIds,
        'categoryId': categoryId,
        'isActive': isActive,
      };

  factory FoodData.fromJson(Map<String, dynamic> json) => FoodData(
        id: json['id'],
        name: json['name'],
        tagIds: List<String>.from(json['tagIds'] ?? []),
        categoryId: json['categoryId'],
        isActive: json['isActive'] ?? true,
      );
}
