import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Teclado numérico inferior adaptado fielmente a la interfaz de referencia.
class NumericKeypadWidget extends StatelessWidget {
  final Function(int digit) onNumberPressed;
  final VoidCallback onClearPressed;
  final VoidCallback onBackspacePressed;
  final VoidCallback? onNegativeToggle;
  final bool showNegativeKey;

  const NumericKeypadWidget({
    super.key,
    required this.onNumberPressed,
    required this.onClearPressed,
    required this.onBackspacePressed,
    this.onNegativeToggle,
    this.showNegativeKey = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      constraints: const BoxConstraints(maxWidth: 450),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow([1, 2, 3], isDark),
          const SizedBox(height: 8),
          _buildRow([4, 5, 6], isDark),
          const SizedBox(height: 8),
          _buildRow([7, 8, 9], isDark),
          const SizedBox(height: 8),
          _buildBottomRow(isDark),
        ],
      ),
    );
  }

  Widget _buildRow(List<int> numbers, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((n) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildKey(
              label: '$n',
              bgColor: isDark ? AppColors.darkKeypadBg : AppColors.keypadNumberBg,
              textColor: isDark ? AppColors.darkTextPrimary : AppColors.keypadNumberText,
              onTap: () => onNumberPressed(n),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomRow(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Botón C (Clear)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildKey(
              label: 'C',
              bgColor: AppColors.keypadActionBg,
              textColor: AppColors.keypadActionText,
              onTap: onClearPressed,
            ),
          ),
        ),
        // Botón 0
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildKey(
              label: '0',
              bgColor: isDark ? AppColors.darkKeypadBg : AppColors.keypadNumberBg,
              textColor: isDark ? AppColors.darkTextPrimary : AppColors.keypadNumberText,
              onTap: () => onNumberPressed(0),
            ),
          ),
        ),
        // Si el nivel Pro permite números negativos, botón +/-
        if (showNegativeKey)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildKey(
                label: '±',
                bgColor: AppColors.keypadSpecialBg,
                textColor: AppColors.keypadSpecialText,
                onTap: onNegativeToggle,
              ),
            ),
          ),
        // Botón Retroceso (Backspace)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildKey(
              icon: Icons.backspace_outlined,
              bgColor: AppColors.keypadActionBg,
              textColor: AppColors.keypadActionText,
              onTap: onBackspacePressed,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKey({
    String? label,
    IconData? icon,
    required Color bgColor,
    required Color textColor,
    VoidCallback? onTap,
  }) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: textColor.withOpacity(0.15),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          child: icon != null
              ? Icon(icon, color: textColor, size: 24)
              : Text(
                  label ?? '',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
