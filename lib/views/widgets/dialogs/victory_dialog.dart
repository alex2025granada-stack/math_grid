import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Modal animado de felicitación al completar el tablero.
class VictoryDialog extends StatelessWidget {
  final int stars;
  final int score;
  final int elapsedSeconds;
  final int errors;
  final int hintsUsed;
  final VoidCallback onNextChallenge;
  final VoidCallback onPlayAgain;
  final VoidCallback onGoHome;

  const VictoryDialog({
    super.key,
    required this.stars,
    required this.score,
    required this.elapsedSeconds,
    required this.errors,
    required this.hintsUsed,
    required this.onNextChallenge,
    required this.onPlayAgain,
    required this.onGoHome,
  });

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        constraints: const BoxConstraints(maxWidth: 380),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícono de trofeo con halo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cellEditable,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: const Icon(
                Icons.emoji_events,
                size: 52,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),

            // Título
            const Text(
              '¡Excelente trabajo!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 12),

            // Estrellas obtenidas (0-3)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final earned = index < stars;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    earned ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: earned ? AppColors.starGold : Colors.grey.shade400,
                    size: 40,
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Métricas de desempeño
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : AppColors.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildMetricRow('Puntos:', '$score pts', isDark),
                  const Divider(height: 14),
                  _buildMetricRow('Tiempo empleado:', _formatTime(elapsedSeconds), isDark),
                  const Divider(height: 14),
                  _buildMetricRow('Errores cometidos:', '$errors', isDark),
                  const Divider(height: 14),
                  _buildMetricRow('Pistas utilizadas:', '$hintsUsed', isDark),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botón: Siguiente Desafío
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward),
                label: const Text(
                  'SIGUIENTE DESAFÍO',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onNextChallenge();
                },
              ),
            ),
            const SizedBox(height: 10),

            // Botón: Jugar de Nuevo
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Jugar de Nuevo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onPlayAgain();
                },
              ),
            ),
            const SizedBox(height: 6),

            // Botón: Volver al Inicio
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onGoHome();
              },
              child: Text(
                'Volver al Inicio',
                style: TextStyle(
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }
}
