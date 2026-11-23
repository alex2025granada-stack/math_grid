import 'dart:async';
import 'package:flutter/material.dart';
import '../core/enums/difficulty_level.dart';
import '../engine/math_generator.dart';
import '../engine/math_validator.dart';
import '../models/board_model.dart';
import '../models/cell_model.dart';
import '../services/audio_haptic_service.dart';
import '../services/storage_service.dart';
import 'stats_controller.dart';

/// Registro para el sistema de Deshacer (Undo).
class MoveHistoryEntry {
  final String cellId;
  final int? oldValue;
  final int? newValue;

  const MoveHistoryEntry({
    required this.cellId,
    required this.oldValue,
    required this.newValue,
  });
}

/// Controlador central del estado de la partida en Math Grid.
class GameController extends ChangeNotifier {
  final StatsController statsController;

  BoardModel? _board;
  String? _selectedCellId;
  int _elapsedSeconds = 0;
  bool _isPaused = false;
  bool _isGameOver = false;
  int _hintsRemaining = 3;
  int _errorsCount = 0;
  int _finalScore = 0;
  int _finalStars = 0;

  Timer? _timer;
  final List<MoveHistoryEntry> _history = [];

  // Getters reactivos
  BoardModel? get board => _board;
  String? get selectedCellId => _selectedCellId;
  int get elapsedSeconds => _elapsedSeconds;
  bool get isPaused => _isPaused;
  bool get isGameOver => _isGameOver;
  int get hintsRemaining => _hintsRemaining;
  int get errorsCount => _errorsCount;
  int get finalScore => _finalScore;
  int get finalStars => _finalStars;
  bool get canUndo => _history.isNotEmpty;

  CellModel? get selectedCell =>
      (_board != null && _selectedCellId != null) ? _board!.cells[_selectedCellId] : null;

  GameController({required this.statsController});

  /// Inicia un nuevo desafío con la dificultad seleccionada
  void startNewGame(DifficultyLevel difficulty) {
    _timer?.cancel();
    _history.clear();
    _elapsedSeconds = 0;
    _isPaused = false;
    _isGameOver = false;
    _errorsCount = 0;
    _finalScore = 0;
    _finalStars = 0;
    _hintsRemaining = difficulty.initialHints;

    // Generación matemática procedimental con solución única verificada
    _board = MathGenerator.generateBoard(difficulty);

    // Seleccionar automáticamente la primera casilla editable
    if (_board != null && _board!.editableCellIds.isNotEmpty) {
      _selectedCellId = _board!.editableCellIds.first;
    } else {
      _selectedCellId = null;
    }

    _startTimer();
    _autoSave();
    notifyListeners();
  }

  /// Carga una partida guardada previamente
  void resumeSavedGame(Map<String, dynamic> savedData) {
    _timer?.cancel();
    _history.clear();
    _board = savedData['board'] as BoardModel;
    _elapsedSeconds = savedData['elapsedSeconds'] as int;
    _hintsRemaining = savedData['hintsRemaining'] as int;
    _errorsCount = savedData['errors'] as int;
    _isPaused = false;
    _isGameOver = false;

    if (_board != null && _board!.editableCellIds.isNotEmpty) {
      // Buscar primera vacía o la primera
      final emptyFirst = _board!.cells.values.firstWhere(
        (c) => !c.isFixed && c.userValue == null,
        orElse: () => _board!.cells[_board!.editableCellIds.first]!,
      );
      _selectedCellId = emptyFirst.id;
    }

    _startTimer();
    notifyListeners();
  }

  /// Selecciona una casilla en el tablero
  void selectCell(String cellId) {
    final cell = _board?.cells[cellId];
    if (cell == null) return;

    // Solo se pueden seleccionar casillas editables (no fijas)
    if (!cell.isFixed && cell.type.isNumber) {
      _selectedCellId = cellId;
      AudioHapticService.tapFeedback();
      notifyListeners();
    }
  }

  /// Introduce un dígito numérico (0-9) en la casilla seleccionada
  void enterDigit(int digit) {
    if (_isGameOver || _isPaused || _board == null || _selectedCellId == null) return;
    final currentCell = _board!.cells[_selectedCellId];
    if (currentCell == null || currentCell.isFixed) return;

    final oldVal = currentCell.userValue;
    int newVal;

    if (oldVal == null) {
      newVal = digit;
    } else {
      // Concatenar dígitos hasta el límite del rango del nivel
      final oldStr = oldVal.toString();
      final isNegative = oldVal < 0 || oldStr.startsWith('-');
      final cleanStr = isNegative ? oldStr.substring(1) : oldStr;

      if (cleanStr.length >= 4) return; // Limitar longitud razonable

      final combined = '$cleanStr$digit';
      final parsed = int.tryParse(combined) ?? digit;
      newVal = isNegative ? -parsed : parsed;
    }

    _updateCellValue(_selectedCellId!, newVal, oldVal);
    AudioHapticService.tapFeedback();
  }

  /// Cambia el signo entre positivo y negativo (exclusivo para nivel Pro)
  void toggleNegativeSign() {
    if (_isGameOver || _isPaused || _board == null || _selectedCellId == null) return;
    if (!_board!.difficulty.allowNegative) return;

    final currentCell = _board!.cells[_selectedCellId];
    if (currentCell == null || currentCell.isFixed) return;

    final oldVal = currentCell.userValue;
    if (oldVal == null) {
      _updateCellValue(_selectedCellId!, -0, null);
    } else {
      _updateCellValue(_selectedCellId!, -oldVal, oldVal);
    }
    AudioHapticService.tapFeedback();
  }

  /// Borra el último dígito ingresado (Backspace)
  void backspace() {
    if (_isGameOver || _isPaused || _board == null || _selectedCellId == null) return;
    final currentCell = _board!.cells[_selectedCellId];
    if (currentCell == null || currentCell.isFixed || currentCell.userValue == null) return;

    final oldVal = currentCell.userValue!;
    final str = oldVal.toString();

    int? newVal;
    if (str.length > 1) {
      if (str.startsWith('-') && str.length == 2) {
        newVal = null;
      } else {
        newVal = int.tryParse(str.substring(0, str.length - 1));
      }
    } else {
      newVal = null;
    }

    _updateCellValue(_selectedCellId!, newVal, oldVal);
    AudioHapticService.tapFeedback();
  }

  /// Limpia completamente el contenido de la casilla actual (Clear)
  void clearCell() {
    if (_isGameOver || _isPaused || _board == null || _selectedCellId == null) return;
    final currentCell = _board!.cells[_selectedCellId];
    if (currentCell == null || currentCell.isFixed || currentCell.userValue == null) return;

    _updateCellValue(_selectedCellId!, null, currentCell.userValue);
    AudioHapticService.tapFeedback();
  }

  /// Deshace el último movimiento realizado
  void undo() {
    if (_history.isEmpty || _board == null || _isGameOver) return;

    final lastMove = _history.removeLast();
    final cell = _board!.cells[lastMove.cellId];
    if (cell != null && !cell.isFixed) {
      final updatedCell = cell.copyWith(
        userValue: lastMove.oldValue,
        clearUserValue: lastMove.oldValue == null,
        hasError: false,
      );
      final newCells = Map<String, CellModel>.from(_board!.cells);
      newCells[lastMove.cellId] = updatedCell;
      _board = _board!.copyWith(cells: newCells);
      _selectedCellId = lastMove.cellId;
      AudioHapticService.tapFeedback();
      notifyListeners();
    }
  }

  /// Solicita una pista inteligente que revela el valor exacto de una casilla
  void requestHint() {
    if (_isGameOver || _isPaused || _board == null || _hintsRemaining <= 0) return;

    // Buscar una casilla editable que esté vacía o tenga un número incorrecto
    final candidates = _board!.cells.values.where(
      (c) => !c.isFixed && c.type.isNumber && (c.userValue == null || c.userValue != c.expectedValue),
    ).toList();

    if (candidates.isEmpty) return;

    // Priorizar casillas que pertenezcan a ecuaciones con más intersecciones
    candidates.sort((a, b) {
      final eqCountA = _board!.equations.where((eq) => eq.numericCellIds.contains(a.id)).length;
      final eqCountB = _board!.equations.where((eq) => eq.numericCellIds.contains(b.id)).length;
      return eqCountB.compareTo(eqCountA);
    });

    final target = candidates.first;
    _hintsRemaining--;

    final updatedCell = target.copyWith(
      userValue: target.expectedValue,
      isHinted: true,
      hasError: false,
    );

    final newCells = Map<String, CellModel>.from(_board!.cells);
    newCells[target.id] = updatedCell;
    _board = _board!.copyWith(cells: newCells);
    _selectedCellId = target.id;

    AudioHapticService.successFeedback();
    _checkVictoryConditions();
    _autoSave();
    notifyListeners();
  }

  /// Comprueba manualmente todas las respuestas en el tablero
  void checkAnswers() {
    if (_board == null || _isGameOver) return;

    final validation = MathValidator.validateBoard(_board!);
    final newCells = Map<String, CellModel>.from(_board!.cells);

    // Actualizar estados visuales de error o acierto
    for (final entry in _board!.cells.entries) {
      final cell = entry.value;
      if (!cell.isFixed && cell.type.isNumber && cell.userValue != null) {
        final isError = validation.errorCellIds.contains(cell.id);
        final isValidated = validation.correctCellIds.contains(cell.id);

        newCells[cell.id] = cell.copyWith(
          hasError: isError,
          isValidated: isValidated,
        );
      }
    }

    _board = _board!.copyWith(cells: newCells);

    if (validation.errorCellIds.isNotEmpty) {
      _errorsCount++;
      AudioHapticService.errorFeedback();
    } else {
      AudioHapticService.successFeedback();
    }

    if (validation.hasVictory) {
      _triggerVictory();
    } else {
      notifyListeners();
    }
  }

  /// Reinicia el tablero actual a su estado original
  void restartGame() {
    if (_board == null) return;
    _timer?.cancel();
    _history.clear();
    _elapsedSeconds = 0;
    _errorsCount = 0;
    _isPaused = false;
    _isGameOver = false;

    // Limpiar respuestas del usuario
    final cleanedCells = <String, CellModel>{};
    for (final entry in _board!.cells.entries) {
      final cell = entry.value;
      if (!cell.isFixed) {
        cleanedCells[entry.key] = cell.copyWith(
          clearUserValue: true,
          hasError: false,
          isHinted: false,
          isValidated: false,
        );
      } else {
        cleanedCells[entry.key] = cell;
      }
    }

    _board = _board!.copyWith(cells: cleanedCells);
    _hintsRemaining = _board!.difficulty.initialHints;
    _selectedCellId = _board!.editableCellIds.first;
    _startTimer();
    _autoSave();
    notifyListeners();
  }

  void pauseGame() {
    if (_isPaused || _isGameOver) return;
    _isPaused = true;
    _timer?.cancel();
    notifyListeners();
  }

  void resumeGame() {
    if (!_isPaused || _isGameOver) return;
    _isPaused = false;
    _startTimer();
    notifyListeners();
  }

  // --- MÉTODOS PRIVADOS DE APOYO ---

  void _updateCellValue(String cellId, int? newValue, int? oldValue) {
    _history.add(MoveHistoryEntry(
      cellId: cellId,
      oldValue: oldValue,
      newValue: newValue,
    ));

    final cell = _board!.cells[cellId]!;
    final updatedCell = cell.copyWith(
      userValue: newValue,
      clearUserValue: newValue == null,
      hasError: false,
    );

    final newCells = Map<String, CellModel>.from(_board!.cells);
    newCells[cellId] = updatedCell;
    _board = _board!.copyWith(cells: newCells);

    _checkVictoryConditions();
    _autoSave();
    notifyListeners();
  }

  void _checkVictoryConditions() {
    if (_board == null) return;
    final validation = MathValidator.validateBoard(_board!);
    if (validation.hasVictory) {
      _triggerVictory();
    }
  }

  void _triggerVictory() {
    _timer?.cancel();
    _isGameOver = true;

    _finalScore = MathValidator.calculateScore(
      difficulty: _board!.difficulty,
      timeSeconds: _elapsedSeconds,
      hintsUsed: _board!.difficulty.initialHints - _hintsRemaining,
      errors: _errorsCount,
    );

    _finalStars = MathValidator.calculateStars(
      difficulty: _board!.difficulty,
      timeSeconds: _elapsedSeconds,
      hintsUsed: _board!.difficulty.initialHints - _hintsRemaining,
      errors: _errorsCount,
    );

    statsController.recordWin(
      difficulty: _board!.difficulty,
      timeSeconds: _elapsedSeconds,
      score: _finalScore,
      hintsUsed: _board!.difficulty.initialHints - _hintsRemaining,
      errors: _errorsCount,
    );

    StorageService.clearActiveGame();
    AudioHapticService.victoryFeedback();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && !_isGameOver) {
        _elapsedSeconds++;
        notifyListeners();
      }
    });
  }

  void _autoSave() {
    if (_board != null && !_isGameOver) {
      StorageService.saveActiveGame(
        board: _board!,
        elapsedSeconds: _elapsedSeconds,
        hintsRemaining: _hintsRemaining,
        errors: _errorsCount,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
