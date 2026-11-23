import 'package:flutter/material.dart';
import '../../../controllers/settings_controller.dart';
import '../../../controllers/stats_controller.dart';
import '../../../core/constants/app_colors.dart';

/// Modal para configurar las preferencias del juego.
class SettingsDialog extends StatelessWidget {
  final SettingsController settingsController;
  final StatsController statsController;

  const SettingsDialog({
    super.key,
    required this.settingsController,
    required this.statsController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (context, _) {
        final settings = settingsController.settings;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Configuración',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(),

                  // 1. Sonido
                  SwitchListTile(
                    title: const Text('Sonido'),
                    subtitle: const Text('Efectos sonoros del juego'),
                    value: settings.soundEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (_) => settingsController.toggleSound(),
                  ),

                  // 2. Vibración háptica
                  SwitchListTile(
                    title: const Text('Vibración háptica'),
                    subtitle: const Text('Retroalimentación al pulsar casillas'),
                    value: settings.vibrationEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (_) => settingsController.toggleVibration(),
                  ),

                  // 3. Modo Oscuro
                  SwitchListTile(
                    title: const Text('Modo Oscuro'),
                    subtitle: const Text('Tema visual relajante para la vista'),
                    value: settings.darkMode,
                    activeColor: AppColors.primary,
                    onChanged: (_) => settingsController.toggleDarkMode(),
                  ),

                  // 4. Mostrar cronómetro
                  SwitchListTile(
                    title: const Text('Mostrar Cronómetro'),
                    subtitle: const Text('Tiempo visible durante el juego'),
                    value: settings.showTimer,
                    activeColor: AppColors.primary,
                    onChanged: (_) => settingsController.toggleShowTimer(),
                  ),

                  // 5. Confirmar reinicio
                  SwitchListTile(
                    title: const Text('Confirmar al reiniciar'),
                    subtitle: const Text('Preguntar antes de borrar el tablero'),
                    value: settings.confirmRestart,
                    activeColor: AppColors.primary,
                    onChanged: (_) => settingsController.toggleConfirmRestart(),
                  ),

                  const SizedBox(height: 12),
                  const Text(
                    'Tamaño de texto',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: settings.textScale,
                    min: 0.8,
                    max: 1.3,
                    divisions: 5,
                    label: '${(settings.textScale * 100).round()}%',
                    activeColor: AppColors.primary,
                    onChanged: (val) => settingsController.setTextScale(val),
                  ),

                  const Divider(height: 24),

                  // Botón peligroso: Reiniciar estadísticas
                  Center(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      label: const Text(
                        'Reiniciar Estadísticas',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                      onPressed: () => _confirmResetStats(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmResetStats(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Reiniciar estadísticas?'),
        content: const Text(
          'Esta acción borrará todas tus partidas jugadas, victorias, récords y rachas. No se puede deshacer.',
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Borrar Todo', style: TextStyle(color: Colors.white)),
            onPressed: () {
              statsController.resetStats();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Estadísticas reiniciadas')),
              );
            },
          ),
        ],
      ),
    );
  }
}
