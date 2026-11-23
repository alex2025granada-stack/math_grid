import 'package:flutter/material.dart';
import '../../controllers/game_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/stats_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/enums/difficulty_level.dart';
import '../../services/storage_service.dart';
import '../widgets/cards/difficulty_card.dart';
import '../widgets/dialogs/settings_dialog.dart';
import 'game_screen.dart';
import 'stats_screen.dart';

/// Pantalla principal de Math Grid según la Sección 4 de especificaciones.
class HomeScreen extends StatefulWidget {
  final GameController gameController;
  final SettingsController settingsController;
  final StatsController statsController;

  const HomeScreen({
    super.key,
    required this.gameController,
    required this.settingsController,
    required this.statsController,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DifficultyLevel _selectedDifficulty = DifficultyLevel.medium;
  Map<String, dynamic>? _savedGame;

  @override
  void initState() {
    super.initState();
    _checkSavedGame();
  }

  Future<void> _checkSavedGame() async {
    final saved = await StorageService.loadActiveGame();
    if (mounted) {
      setState(() {
        _savedGame = saved;
      });
    }
  }

  void _onPlayPressed() {
    widget.gameController.startNewGame(_selectedDifficulty);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          gameController: widget.gameController,
          settingsController: widget.settingsController,
          statsController: widget.statsController,
        ),
      ),
    ).then((_) => _checkSavedGame());
  }

  void _onResumePressed() {
    if (_savedGame != null) {
      widget.gameController.resumeSavedGame(_savedGame!);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GameScreen(
            gameController: widget.gameController,
            settingsController: widget.settingsController,
            statsController: widget.statsController,
          ),
        ),
      ).then((_) => _checkSavedGame());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([widget.settingsController, widget.statsController]),
          builder: (context, _) {
            final stats = widget.statsController.stats;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 550),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      // Barra superior de acciones rápidas
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.bar_chart, size: 28),
                            color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                            tooltip: 'Estadísticas personales',
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => StatsScreen(statsController: widget.statsController),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings, size: 28),
                            color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                            tooltip: 'Configuración',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => SettingsDialog(
                                  settingsController: widget.settingsController,
                                  statsController: widget.statsController,
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Logotipo minimalista e identidad
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.cellFixed,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '+  −\n=  #',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      const Text(
                        'MATH GRID',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const Text(
                        'Juegos Matemáticos',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Tarjetas de los 4 niveles de dificultad
                      Expanded(
                        child: ListView.separated(
                          itemCount: DifficultyLevel.values.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final diff = DifficultyLevel.values[index];
                            return DifficultyCard(
                              difficulty: diff,
                              isSelected: diff == _selectedDifficulty,
                              stats: stats,
                              onTap: () {
                                setState(() {
                                  _selectedDifficulty = diff;
                                });
                              },
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Botón Continuar (si hay partida en curso)
                      if (_savedGame != null) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.play_circle_outline),
                            label: const Text(
                              'CONTINUAR PARTIDA',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary, width: 2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: _onResumePressed,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      // Botón principal: JUGAR
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _onPlayPressed,
                          child: Text(
                            'JUGAR • ${_selectedDifficulty.displayName.toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
