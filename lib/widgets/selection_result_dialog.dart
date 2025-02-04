import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:witch_one/theme/app_theme.dart';

class SelectionResultDialog extends StatefulWidget {
  final String foodName;

  const SelectionResultDialog({
    super.key,
    required this.foodName,
  });

  @override
  State<SelectionResultDialog> createState() => _SelectionResultDialogState();
}

class _SelectionResultDialogState extends State<SelectionResultDialog> {
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: AppTheme.dialogDecoration,
        padding: AppTheme.dialogPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择结果',
              style: AppTheme.dialogTitleStyle(context),
            ),
            const SizedBox(height: AppTheme.spacingNormal),
            Text(
              widget.foodName,
              style: AppTheme.dialogSubtitleStyle(context),
            ),
            const SizedBox(height: AppTheme.spacingNormal),
            TextField(
              controller: _priceController,
              decoration: AppTheme.textFieldDecoration.copyWith(
                labelText: '消费金额',
                prefixText: '¥',
              ),
              style: const TextStyle(fontSize: 16),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
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
                  child: const Text('确定'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_priceController.text.isEmpty) {
      Navigator.pop(context);
      return;
    }
    final price = double.parse(_priceController.text);
    Navigator.pop(context, price);
  }
}
