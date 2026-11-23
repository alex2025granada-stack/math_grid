import 'package:flutter/material.dart';
import '../../controllers/game_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/stats_controller.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/board/crossword_board_widget.dart';
import '../widgets/dialogs/settings_dialog.dart';
import '../widgets/dialogs/victory_dialog.dart';
import '../widgets/keypad/numeric_keypad_widget.dart';
import '../widgets/toolbar/game_toolbar.dart';
import '../widgets/topbar/game_top_bar.dart';

/// Pantalla central de juego interactivo de Math Grid.
class GameScreen extends StatefulWidget {
  final GameController gameController;
  final SettingsController settingsController;
  final StatsController statsController;

  const GameScreen({
    super.key,
    required this.gameController,
    required this.settingsController,
    required this.statsController,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _victoryModalShown = false;

  @override
  void initState() {
    super.initState();
    widget.gameController.addListener(_onGameStateChanged);
  }

  @override
  void dispose() {
    widget.gameController.removeListener(_onGameStateChanged);
    super.dispose();
  }

  void _onGameStateChanged() {
    if (widget.gameController.isGameOver && !_victoryModalShown) {
      _victoryModalShown = true;
      Future.microtask(() => _showVictoryDialog());
    }
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => VictoryDialog(
        stars: widget.gameController.finalStars,
        score: widget.gameController.finalScore,
        elapsedSeconds: widget.gameController.elapsedSeconds,
        errors: widget.gameController.errorsCount,
        hintsUsed: widget.gameController.board!.difficulty.initialHints -
            widget.gameController.hintsRemaining,
        onNextChallenge: () {
          _victoryModalShown = false;
          widget.gameController.startNewGame(widget.gameController.board!.difficulty);
        },
        onPlayAgain: () {
          _victoryModalShown = false;
          widget.gameController.restartGame();
        },
        onGoHome: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _handleRestart() {
    final confirm = widget.settingsController.settings.confirmRestart;
    if (confirm) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('¿Reiniciar partida?'),
          content: const Text('Se restablecerán las casillas del tablero actual.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                Navigator.of(ctx).pop();
                widget.gameController.restartGame();
              },
              child: const Text('Reiniciar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      widget.gameController.restartGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.gameController, widget.settingsController]),
      builder: (context, _) {
        final board = widget.gameController.board;
        final settings = widget.settingsController.settings;

        if (board == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // 1. Barra Superior (Nivel, Tiempo, Ajustes)
                GameTopBar(
                  difficulty: board.difficulty,
                  elapsedSeconds: widget.gameController.elapsedSeconds,
                  showTimer: settings.showTimer,
                  onBackPressed: () => Navigator.of(context).pop(),
                  onSettingsPressed: () {
                    widget.gameController.pauseGame();
                    showDialog(
                      context: context,
                      builder: (_) => SettingsDialog(
                        settingsController: widget.settingsController,
                        statsController: widget.statsController,
                      ),
                    ).then((_) => widget.gameController.resumeGame());
                  },
                ),

                // 2. Tablero Central de Crucigrama (ocupa el máximo espacio disponible)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: CrosswordBoardWidget(
                      board: board,
                      selectedCellId: widget.gameController.selectedCellId,
                      onCellSelected: widget.gameController.selectCell,
                    ),
                  ),
                ),

                // 3. Barra de Herramientas (Deshacer, Pista, Comprobar, Reiniciar, Nuevo)
                GameToolbar(
                  canUndo: widget.gameController.canUndo,
                  hintsRemaining: widget.gameController.hintsRemaining,
                  onUndo: widget.gameController.undo,
                  onHint: widget.gameController.requestHint,
                  onCheck: widget.gameController.checkAnswers,
                  onRestart: _handleRestart,
                  onNewBoard: () {
                    _victoryModalShown = false;
                    widget.gameController.startNewGame(board.difficulty);
                  },
                ),

                // 4. Teclado Numérico Inferior
                NumericKeypadWidget(
                  onNumberPressed: widget.gameController.enterDigit,
                  onClearPressed: widget.gameController.clearCell,
                  onBackspacePressed: widget.gameController.backspace,
                  onNegativeToggle: widget.gameController.toggleNegativeSign,
                  showNegativeKey: board.difficulty.allowNegative,
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
  }
}
