import 'package:flutter/material.dart';
import 'package:witch_one/models/food_item.dart';
import 'package:witch_one/services/storage_service.dart';
import 'package:witch_one/theme/app_theme.dart';
import 'package:witch_one/theme/colors.dart';
import 'package:witch_one/widgets/animated_background.dart';
import 'package:witch_one/widgets/food_item_card.dart';
import 'package:witch_one/widgets/selection_result_dialog.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final StorageService _storage = StorageService();
  List<FoodItem> _historyItems = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _storage.getHistory();
    setState(() {
      _historyItems = history;
    });
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清空'),
        content: const Text('确定要清空所有历史记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '清空',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storage.clearHistory();
      setState(() {
        _historyItems = [];
      });
    }
  }

  Future<void> _selectFood(FoodItem item) async {
    // 显示选择结果对话框
    if (!mounted) return;
    final price = await showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SelectionResultDialog(foodName: item.name),
    );

    if (price != null) {
      // 更新历史记录中的价格
      final updatedItem = FoodItem(
        name: item.name,
        timestamp: item.timestamp,
        price: price,
      );

      // 找到并更新历史记录
      final index = _historyItems.indexWhere(
          (i) => i.name == item.name && i.timestamp == item.timestamp);
      if (index != -1) {
        setState(() {
          _historyItems[index] = updatedItem;
        });
        await _storage.saveHistory(_historyItems);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('消费金额: ¥${price.toStringAsFixed(2)}')),
      );
    }
  }

  // 添加删除单个记录的方法
  Future<void> _deleteHistoryItem(FoodItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条记录吗？'),
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
      setState(() {
        _historyItems.removeWhere(
            (i) => i.name == item.name && i.timestamp == item.timestamp);
      });
      await _storage.saveHistory(_historyItems);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已删除记录')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _historyItems.isEmpty ? null : _clearHistory,
          ),
        ],
      ),
      body: AnimatedBackground(
        child: _historyItems.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history,
                      size: AppTheme.emptyStateIconSize,
                      color: AppColors.onBackgroundMuted,
                    ),
                    const SizedBox(height: AppTheme.spacingNormal),
                    Text(
                      '还没有历史记录',
                      style: AppTheme.emptyStateStyle,
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: AppTheme.listViewPadding,
                itemCount: _historyItems.length,
                itemBuilder: (context, index) {
                  final item = _historyItems[index];
                  return FoodItemCard(
                    foodName: item.name,
                    timestamp: item.formattedDate,
                    price: item.price,
                    onDeletePressed: () => _deleteHistoryItem(item),
                    onTap: () => _selectFood(item),
                  );
                },
              ),
      ),
    );
  }
}
