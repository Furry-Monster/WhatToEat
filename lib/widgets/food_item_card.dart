import 'package:flutter/material.dart';
import 'package:witch_one/theme/app_theme.dart';

class FoodItemCard extends StatelessWidget {
  final String foodName;
  final String? timestamp;
  final double? price;
  final VoidCallback? onDeletePressed;
  final VoidCallback? onTap;

  const FoodItemCard({
    super.key,
    required this.foodName,
    this.timestamp,
    this.price,
    this.onDeletePressed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: AppTheme.cardMargin,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: AppTheme.cardPadding,
          decoration: AppTheme.cardDecoration,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      foodName,
                      style: AppTheme.cardTitleStyle(context),
                    ),
                    if (timestamp != null || price != null) ...[
                      const SizedBox(height: AppTheme.spacingSmall),
                      Row(
                        children: [
                          if (timestamp != null)
                            Text(
                              timestamp!,
                              style: AppTheme.cardSubtitleStyle(context),
                            ),
                          if (timestamp != null && price != null)
                            Text(
                              ' · ',
                              style: AppTheme.cardSubtitleStyle(context),
                            ),
                          if (price != null)
                            Text(
                              '¥${price!.toStringAsFixed(2)}',
                              style: AppTheme.cardSubtitleStyle(context),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (onDeletePressed != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  onPressed: onDeletePressed,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
