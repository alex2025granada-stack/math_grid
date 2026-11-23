import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/board_model.dart';
import '../models/game_settings_model.dart';
import '../models/game_stats_model.dart';

/// Servicio de persistencia local offline para configuraciones, estadísticas
/// y partidas en curso.
class StorageService {
  static const _keySettings = 'math_grid_settings';
  static const _keyStats = 'math_grid_stats';
  static const _keySavedBoard = 'math_grid_saved_board';
  static const _keySavedTime = 'math_grid_saved_time';
  static const _keySavedHints = 'math_grid_saved_hints';
  static const _keySavedErrors = 'math_grid_saved_errors';

  // Caché en memoria para funcionamiento 100% resiliente incluso sin almacenamiento físico
  static GameSettingsModel _cachedSettings = const GameSettingsModel();
  static GameStatsModel _cachedStats = GameStatsModel.initial();

  /// Inicializa y carga datos guardados
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final settingsRaw = prefs.getString(_keySettings);
      if (settingsRaw != null) {
        _cachedSettings = GameSettingsModel.fromJson(jsonDecode(settingsRaw));
      }

      final statsRaw = prefs.getString(_keyStats);
      if (statsRaw != null) {
        _cachedStats = GameStatsModel.fromJson(jsonDecode(statsRaw));
      }
    } catch (_) {
      // Si ocurre cualquier error, continúa con la caché en memoria
    }
  }

  // --- CONFIGURACIÓN ---
  static GameSettingsModel loadSettings() => _cachedSettings;

  static Future<void> saveSettings(GameSettingsModel settings) async {
    _cachedSettings = settings;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySettings, jsonEncode(settings.toJson()));
    } catch (_) {}
  }

  // --- ESTADÍSTICAS ---
  static GameStatsModel loadStats() => _cachedStats;

  static Future<void> saveStats(GameStatsModel stats) async {
    _cachedStats = stats;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyStats, jsonEncode(stats.toJson()));
    } catch (_) {}
  }

  static Future<void> resetStats() async {
    _cachedStats = GameStatsModel.initial();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyStats);
    } catch (_) {}
  }

  // --- PARTIDA EN CURSO ---
  static Future<void> saveActiveGame({
    required BoardModel board,
    required int elapsedSeconds,
    required int hintsRemaining,
    required int errors,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySavedBoard, jsonEncode(board.toJson()));
      await prefs.setInt(_keySavedTime, elapsedSeconds);
      await prefs.setInt(_keySavedHints, hintsRemaining);
      await prefs.setInt(_keySavedErrors, errors);
    } catch (_) {}
  }

  static Future<Map<String, dynamic>?> loadActiveGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final boardRaw = prefs.getString(_keySavedBoard);
      if (boardRaw == null) return null;

      final boardJson = jsonDecode(boardRaw) as Map<String, dynamic>;
      final board = BoardModel.fromJson(boardJson);
      final elapsed = prefs.getInt(_keySavedTime) ?? 0;
      final hints = prefs.getInt(_keySavedHints) ?? board.difficulty.initialHints;
      final errors = prefs.getInt(_keySavedErrors) ?? 0;

      return {
        'board': board,
        'elapsedSeconds': elapsed,
        'hintsRemaining': hints,
        'errors': errors,
      };
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearActiveGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keySavedBoard);
      await prefs.remove(_keySavedTime);
      await prefs.remove(_keySavedHints);
      await prefs.remove(_keySavedErrors);
    } catch (_) {}
  }
}
