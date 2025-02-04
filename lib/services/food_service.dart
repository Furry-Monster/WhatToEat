import 'package:witch_one/models/food_item.dart';
import 'package:witch_one/services/storage_service.dart';

class FoodService {
  final StorageService _storage = StorageService();

  // 单例模式
  static final FoodService _instance = FoodService._internal();

  factory FoodService() => _instance;

  FoodService._internal();

  // 选择食物
  Future<FoodItem> selectFood() async {
    final options = await _storage.getFoodOptions();
    if (options.isEmpty) {
      throw Exception('没有可用的食物选项');
    }

    final randomIndex = DateTime.now().millisecondsSinceEpoch % options.length;
    final selectedFood = options[randomIndex];

    final foodItem = FoodItem(
      name: selectedFood,
      timestamp: DateTime.now(),
    );

    await _storage.addToHistory(foodItem);
    return foodItem;
  }

  // 获取格式化的时间
  String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    final time =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

    if (difference.inDays == 0) return '今天 $time';
    if (difference.inDays == 1) return '昨天 $time';
    if (difference.inDays == 2) return '前天 $time';
    return '${timestamp.month}月${timestamp.day}日 $time';
  }
}
