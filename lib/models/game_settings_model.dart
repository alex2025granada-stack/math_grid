/// Configuración de preferencias del jugador que persisten entre sesiones.
class GameSettingsModel {
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool darkMode;
  final double textScale;
  final bool showTimer;
  final bool confirmRestart;

  const GameSettingsModel({
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.darkMode = false,
    this.textScale = 1.0,
    this.showTimer = true,
    this.confirmRestart = true,
  });

  GameSettingsModel copyWith({
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? darkMode,
    double? textScale,
    bool? showTimer,
    bool? confirmRestart,
  }) {
    return GameSettingsModel(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      darkMode: darkMode ?? this.darkMode,
      textScale: textScale ?? this.textScale,
      showTimer: showTimer ?? this.showTimer,
      confirmRestart: confirmRestart ?? this.confirmRestart,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'darkMode': darkMode,
      'textScale': textScale,
      'showTimer': showTimer,
      'confirmRestart': confirmRestart,
    };
  }

  factory GameSettingsModel.fromJson(Map<String, dynamic> json) {
    return GameSettingsModel(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      darkMode: json['darkMode'] as bool? ?? false,
      textScale: (json['textScale'] as num?)?.toDouble() ?? 1.0,
      showTimer: json['showTimer'] as bool? ?? true,
      confirmRestart: json['confirmRestart'] as bool? ?? true,
    );
  }
}
