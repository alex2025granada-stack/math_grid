import '../core/enums/difficulty_level.dart';

/// Modelo de estadísticas y récords personales del jugador por dificultad y globales.
class GameStatsModel {
  final Map<DifficultyLevel, int> gamesPlayed;
  final Map<DifficultyLevel, int> gamesWon;
  final Map<DifficultyLevel, int> bestTimeSeconds;
  final Map<DifficultyLevel, int> highestScore;
  final int totalScore;
  final int totalHintsUsed;
  final int totalErrors;
  final int currentStreak;
  final int bestStreak;

  const GameStatsModel({
    required this.gamesPlayed,
    required this.gamesWon,
    required this.bestTimeSeconds,
    required this.highestScore,
    this.totalScore = 0,
    this.totalHintsUsed = 0,
    this.totalErrors = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
  });

  factory GameStatsModel.initial() {
    return GameStatsModel(
      gamesPlayed: {for (var d in DifficultyLevel.values) d: 0},
      gamesWon: {for (var d in DifficultyLevel.values) d: 0},
      bestTimeSeconds: {for (var d in DifficultyLevel.values) d: 0},
      highestScore: {for (var d in DifficultyLevel.values) d: 0},
      totalScore: 0,
      totalHintsUsed: 0,
      totalErrors: 0,
      currentStreak: 0,
      bestStreak: 0,
    );
  }

  /// Registra una partida completada con victoria
  GameStatsModel recordWin({
    required DifficultyLevel difficulty,
    required int timeSeconds,
    required int score,
    required int hintsUsed,
    required int errors,
  }) {
    final newPlayed = Map<DifficultyLevel, int>.from(gamesPlayed);
    final newWon = Map<DifficultyLevel, int>.from(gamesWon);
    final newBestTime = Map<DifficultyLevel, int>.from(bestTimeSeconds);
    final newHighScore = Map<DifficultyLevel, int>.from(highestScore);

    newPlayed[difficulty] = (newPlayed[difficulty] ?? 0) + 1;
    newWon[difficulty] = (newWon[difficulty] ?? 0) + 1;

    final prevBestTime = newBestTime[difficulty] ?? 0;
    if (prevBestTime == 0 || timeSeconds < prevBestTime) {
      newBestTime[difficulty] = timeSeconds;
    }

    final prevHighScore = newHighScore[difficulty] ?? 0;
    if (score > prevHighScore) {
      newHighScore[difficulty] = score;
    }

    final newStreak = currentStreak + 1;
    final newBestStreak = newStreak > bestStreak ? newStreak : bestStreak;

    return GameStatsModel(
      gamesPlayed: newPlayed,
      gamesWon: newWon,
      bestTimeSeconds: newBestTime,
      highestScore: newHighScore,
      totalScore: totalScore + score,
      totalHintsUsed: totalHintsUsed + hintsUsed,
      totalErrors: totalErrors + errors,
      currentStreak: newStreak,
      bestStreak: newBestStreak,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gamesPlayed': gamesPlayed.map((k, v) => MapEntry(k.name, v)),
      'gamesWon': gamesWon.map((k, v) => MapEntry(k.name, v)),
      'bestTimeSeconds': bestTimeSeconds.map((k, v) => MapEntry(k.name, v)),
      'highestScore': highestScore.map((k, v) => MapEntry(k.name, v)),
      'totalScore': totalScore,
      'totalHintsUsed': totalHintsUsed,
      'totalErrors': totalErrors,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
    };
  }

  factory GameStatsModel.fromJson(Map<String, dynamic> json) {
    Map<DifficultyLevel, int> readMap(String key) {
      final res = <DifficultyLevel, int>{};
      final m = json[key] as Map<String, dynamic>?;
      for (var d in DifficultyLevel.values) {
        res[d] = (m != null && m[d.name] != null) ? m[d.name] as int : 0;
      }
      return res;
    }

    return GameStatsModel(
      gamesPlayed: readMap('gamesPlayed'),
      gamesWon: readMap('gamesWon'),
      bestTimeSeconds: readMap('bestTimeSeconds'),
      highestScore: readMap('highestScore'),
      totalScore: json['totalScore'] as int? ?? 0,
      totalHintsUsed: json['totalHintsUsed'] as int? ?? 0,
      totalErrors: json['totalErrors'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
    );
  }
}
