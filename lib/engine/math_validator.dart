import 'dart:math';
import '../core/enums/difficulty_level.dart';
import '../models/board_model.dart';

/// Resultado detallado de la comprobación matemática de un tablero.
class ValidationResult {
  final bool isAllComplete;
  final bool isAllValid;
  final bool hasVictory;
  final Set<String> errorCellIds;
  final Set<String> correctCellIds;
  final int emptyCount;

  const ValidationResult({
    required this.isAllComplete,
    required this.isAllValid,
    required this.hasVictory,
    required this.errorCellIds,
    required this.correctCellIds,
    required this.emptyCount,
  });
}

/// Motor de validación matemática en tiempo real y cálculo de puntuación.
class MathValidator {
  /// Evalúa el estado completo del tablero
  static ValidationResult validateBoard(BoardModel board) {
    final cells = board.cells;
    final equations = board.equations;

    final errorCells = <String>{};
    final correctCells = <String>{};
    int emptyCount = 0;

    // 1. Identificar casillas vacías y errores en celdas editables individuales
    for (final entry in cells.entries) {
      final cell = entry.value;
      if (!cell.isFixed && cell.type.isNumber) {
        if (cell.userValue == null) {
          emptyCount++;
        } else if (cell.userValue != cell.expectedValue) {
          errorCells.add(cell.id);
        } else {
          correctCells.add(cell.id);
        }
      }
    }

    // 2. Verificar ecuaciones
    bool allEquationsValid = true;
    for (final eq in equations) {
      if (!eq.isComplete(cells)) {
        allEquationsValid = false;
      } else if (!eq.isValid(cells)) {
        allEquationsValid = false;
        // Marcar todas las celdas editables involucradas en una ecuación fallida
        for (final cid in eq.numericCellIds) {
          final c = cells[cid];
          if (c != null && !c.isFixed) {
            errorCells.add(cid);
            correctCells.remove(cid);
          }
        }
      }
    }

    final isAllComplete = emptyCount == 0;
    final isAllValid = allEquationsValid && errorCells.isEmpty;
    final hasVictory = isAllComplete && isAllValid;

    return ValidationResult(
      isAllComplete: isAllComplete,
      isAllValid: isAllValid,
      hasVictory: hasVictory,
      errorCellIds: errorCells,
      correctCellIds: correctCells,
      emptyCount: emptyCount,
    );
  }

  /// Calcula la puntuación final de la partida de forma determinista
  static int calculateScore({
    required DifficultyLevel difficulty,
    required int timeSeconds,
    required int hintsUsed,
    required int errors,
  }) {
    int baseScore;
    int diffMultiplier;
    switch (difficulty) {
      case DifficultyLevel.basic:
        baseScore = 1000;
        diffMultiplier = 3;
        break;
      case DifficultyLevel.medium:
        baseScore = 2000;
        diffMultiplier = 5;
        break;
      case DifficultyLevel.advanced:
        baseScore = 3500;
        diffMultiplier = 8;
        break;
      case DifficultyLevel.pro:
        baseScore = 5000;
        diffMultiplier = 12;
        break;
    }

    final targetTime = difficulty.targetTimeSeconds;
    final timeDifference = targetTime - timeSeconds;
    final timeBonus = timeDifference > 0 ? timeDifference * diffMultiplier : 0;

    final hintPenalty = hintsUsed * 150;
    final errorPenalty = errors * 50;

    final total = baseScore + timeBonus - hintPenalty - errorPenalty;
    return max(100, total);
  }

  /// Calcula la cantidad de estrellas obtenidas (1 a 3)
  static int calculateStars({
    required DifficultyLevel difficulty,
    required int timeSeconds,
    required int hintsUsed,
    required int errors,
  }) {
    final target = difficulty.targetTimeSeconds;

    // 3 estrellas: dentro del tiempo objetivo, sin pistas y máximo 1 error
    if (timeSeconds <= target && hintsUsed == 0 && errors <= 1) {
      return 3;
    }
    // 2 estrellas: dentro de 1.5x tiempo objetivo y no más de 1 pista
    if (timeSeconds <= (target * 1.5) && hintsUsed <= 1) {
      return 2;
    }
    // 1 estrella por completar el crucigrama
    return 1;
  }
}
