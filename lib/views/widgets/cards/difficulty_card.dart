import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/difficulty_level.dart';
import '../../../models/game_stats_model.dart';

/// Tarjeta de selección de dificultad para la pantalla principal.
class DifficultyCard extends StatelessWidget {
  final DifficultyLevel difficulty;
  final bool isSelected;
  final GameStatsModel stats;
  final VoidCallback onTap;

  const DifficultyCard({
    super.key,
    required this.difficulty,
    required this.isSelected,
    required this.stats,
    required this.onTap,
  });

  String _formatTime(int totalSeconds) {
    if (totalSeconds == 0) return '--:--';
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wins = stats.gamesWon[difficulty] ?? 0;
    final bestTime = stats.bestTimeSeconds[difficulty] ?? 0;
    final bestScore = stats.highestScore[difficulty] ?? 0;

    return Material(
      color: isSelected
          ? (isDark ? AppColors.darkCellEditable : AppColors.cellEditable)
          : (isDark ? AppColors.darkSurface : Colors.white),
      borderRadius: BorderRadius.circular(20),
      elevation: isSelected ? 4 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.black12,
              width: isSelected ? 2.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              // Ícono con fondo coloreado
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: difficulty.cardColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  difficulty.icon,
                  color: difficulty.cardColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),

              // Textos de título y descripción
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          difficulty.displayName.toUpperCase(),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
                          ),
                        ),
                        if (wins > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.cellFixed,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '★ $wins victorias',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      difficulty.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Registro récord
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, size: 14, color: isDark ? Colors.white54 : AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'Mejor: ${_formatTime(bestTime)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.military_tech_outlined, size: 14, color: isDark ? Colors.white54 : AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'Récord: $bestScore pts',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
