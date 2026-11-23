import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Barra de herramientas con las 5 acciones clave del juego:
/// 1. Deshacer (Undo)
/// 2. Pista (Hint)
/// 3. Comprobar (Check)
/// 4. Reiniciar (Restart)
/// 5. Nuevo Tablero (New Challenge)
class GameToolbar extends StatelessWidget {
  final bool canUndo;
  final int hintsRemaining;
  final VoidCallback onUndo;
  final VoidCallback onHint;
  final VoidCallback onCheck;
  final VoidCallback onRestart;
  final VoidCallback onNewBoard;

  const GameToolbar({
    super.key,
    required this.canUndo,
    required this.hintsRemaining,
    required this.onUndo,
    required this.onHint,
    required this.onCheck,
    required this.onRestart,
    required this.onNewBoard,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? AppColors.darkTextPrimary : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      constraints: const BoxConstraints(maxWidth: 450),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. Deshacer
          _buildActionButton(
            icon: Icons.undo,
            color: canUndo ? iconColor : Colors.grey.shade400,
            tooltip: 'Deshacer movimiento',
            onTap: canUndo ? onUndo : null,
          ),

          // 2. Pista inteligente con contador
          Stack(
            clipBehavior: Clip.none,
            children: [
              _buildActionButton(
                icon: Icons.lightbulb_outline,
                color: hintsRemaining > 0 ? iconColor : Colors.grey.shade400,
                tooltip: 'Solicitar pista ($hintsRemaining restantes)',
                onTap: hintsRemaining > 0 ? onHint : null,
              ),
              if (hintsRemaining > 0)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryDark,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$hintsRemaining',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // 3. Comprobar respuestas
          _buildActionButton(
            icon: Icons.verified_user_outlined,
            color: iconColor,
            tooltip: 'Comprobar respuestas',
            onTap: onCheck,
          ),

          // 4. Reiniciar partida
          _buildActionButton(
            icon: Icons.refresh,
            color: iconColor,
            tooltip: 'Reiniciar partida',
            onTap: onRestart,
          ),

          // 5. Generar nuevo tablero
          _buildActionButton(
            icon: Icons.auto_awesome_outlined,
            color: iconColor,
            tooltip: 'Nuevo desafío',
            onTap: onNewBoard,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    VoidCallback? onTap,
  }) {
    return IconButton(
      icon: Icon(icon, size: 28),
      color: color,
      tooltip: tooltip,
      onPressed: onTap,
      splashRadius: 24,
    );
  }
}
