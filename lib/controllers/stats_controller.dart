import 'package:flutter/material.dart';
import '../core/enums/difficulty_level.dart';
import '../models/game_stats_model.dart';
import '../services/storage_service.dart';

/// Controlador reactivo para el registro y consulta de estadísticas del jugador.
class StatsController extends ChangeNotifier {
  GameStatsModel _stats = GameStatsModel.initial();

  GameStatsModel get stats => _stats;

  StatsController() {
    _stats = StorageService.loadStats();
  }

  void recordWin({
    required DifficultyLevel difficulty,
    required int timeSeconds,
    required int score,
    required int hintsUsed,
    required int errors,
  }) {
    _stats = _stats.recordWin(
      difficulty: difficulty,
      timeSeconds: timeSeconds,
      score: score,
      hintsUsed: hintsUsed,
      errors: errors,
    );
    StorageService.saveStats(_stats);
    notifyListeners();
  }

  Future<void> resetStats() async {
    await StorageService.resetStats();
    _stats = GameStatsModel.initial();
    notifyListeners();
  }
}
