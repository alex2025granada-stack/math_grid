import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/difficulty_level.dart';

/// Barra superior del juego según la captura:
/// Nivel actual a la izquierda | Cronómetro y engranaje de configuración a la derecha.
class GameTopBar extends StatelessWidget {
  final DifficultyLevel difficulty;
  final int elapsedSeconds;
  final bool showTimer;
  final VoidCallback onSettingsPressed;
  final VoidCallback onBackPressed;

  const GameTopBar({
    super.key,
    required this.difficulty,
    required this.elapsedSeconds,
    this.showTimer = true,
    required this.onSettingsPressed,
    required this.onBackPressed,
  });

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Izquierda: Botón volver y Nivel
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                color: textColor,
                onPressed: onBackPressed,
                tooltip: 'Volver al menú',
              ),
              const SizedBox(width: 4),
              Text(
                'Nivel: ${difficulty.displayName}',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Derecha: Cronómetro y Ajustes
          Row(
            children: [
              if (showTimer) ...[
                Text(
                  _formatTime(elapsedSeconds),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 12),
              ],
              IconButton(
                icon: const Icon(Icons.settings, size: 26),
                color: textColor,
                onPressed: onSettingsPressed,
                tooltip: 'Configuración',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
