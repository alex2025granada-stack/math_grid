import 'package:flutter/material.dart';
import '../../controllers/stats_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/enums/difficulty_level.dart';

/// Pantalla detallada de estadísticas y progreso del jugador.
class StatsScreen extends StatelessWidget {
  final StatsController statsController;

  const StatsScreen({super.key, required this.statsController});

  String _formatTime(int totalSeconds) {
    if (totalSeconds == 0) return '--:--';
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: statsController,
          builder: (context, _) {
            final stats = statsController.stats;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 550),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Tarjetas de Resumen Global
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            title: 'Puntuación Total',
                            value: '${stats.totalScore}',
                            icon: Icons.stars_rounded,
                            color: AppColors.primary,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            title: 'Racha Actual',
                            value: '${stats.currentStreak} 🔥',
                            icon: Icons.local_fire_department,
                            color: Colors.orange.shade800,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            title: 'Pistas Usadas',
                            value: '${stats.totalHintsUsed}',
                            icon: Icons.lightbulb_outline,
                            color: Colors.amber.shade800,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            title: 'Total Errores',
                            value: '${stats.totalErrors}',
                            icon: Icons.warning_amber_rounded,
                            color: Colors.red.shade700,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Rendimiento por Nivel',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Desglose por Dificultad
                    for (final diff in DifficultyLevel.values) ...[
                      Card(
                        elevation: 1,
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(diff.icon, color: diff.cardColor, size: 22),
                                  const SizedBox(width: 8),
                                  Text(
                                    diff.displayName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: diff.cardColor,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${stats.gamesWon[diff] ?? 0} ganadas',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildStatItem('Partidas', '${stats.gamesPlayed[diff] ?? 0}'),
                                  _buildStatItem('Mejor Tiempo', _formatTime(stats.bestTimeSeconds[diff] ?? 0)),
                                  _buildStatItem('Récord Puntos', '${stats.highestScore[diff] ?? 0}'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
