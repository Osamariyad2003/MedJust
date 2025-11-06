// lib/features/guidies/presentation/widgets/virtual_arabic_keyboard.dart
import 'package:flutter/material.dart';

class VirtualArabicKeyboard extends StatelessWidget {
  final Function(String) onKeyPress;
  final Color? backgroundColor;
  final Color? textColor;

  const VirtualArabicKeyboard({
    super.key,
    required this.onKeyPress,
    this.backgroundColor,
    this.textColor,
  });

  static const _arabicKeys = [
    ['ض', 'ص', 'ث', 'ق', 'ف', 'غ', 'ع', 'ه', 'خ', 'ح', 'ج', 'د'],
    ['ش', 'س', 'ي', 'ب', 'ل', 'ا', 'ت', 'ن', 'م', 'ك', 'ط'],
    ['ئ', 'ء', 'ؤ', 'ر', 'لا', 'ى', 'ة', 'و', 'ز', 'ظ'],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ..._arabicKeys.map((row) => _buildKeyboardRow(context, row)),
          _buildBottomRow(context),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(BuildContext context, List<String> keys) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: keys.map((key) => _buildKey(context, key, flex: 1)).toList(),
      ),
    );
  }

  Widget _buildBottomRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildKey(context, 'backspace', flex: 2, isSpecial: true),
          _buildKey(context, 'space', flex: 4, isSpecial: true),
          _buildKey(context, 'send', flex: 2, isSpecial: true),
        ],
      ),
    );
  }

  Widget _buildKey(
    BuildContext context,
    String key, {
    int flex = 1,
    bool isSpecial = false,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Material(
          color:
              isSpecial
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: () => onKeyPress(key),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 48,
              alignment: Alignment.center,
              child: _buildKeyContent(context, key, isSpecial),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyContent(BuildContext context, String key, bool isSpecial) {
    if (key == 'backspace') {
      return Icon(
        Icons.backspace_outlined,
        size: 20,
        color: textColor ?? Theme.of(context).colorScheme.onSurface,
      );
    } else if (key == 'space') {
      return Text(
        'مسافة',
        style: TextStyle(
          fontSize: 14,
          fontFamily: 'Cairo',
          color: textColor ?? Theme.of(context).colorScheme.onSurface,
        ),
      );
    } else if (key == 'send') {
      return Icon(
        Icons.send_rounded,
        size: 20,
        color: Theme.of(context).colorScheme.primary,
      );
    }

    return Text(
      key,
      style: TextStyle(
        fontSize: 18,
        fontFamily: 'Cairo',
        color: textColor ?? Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
