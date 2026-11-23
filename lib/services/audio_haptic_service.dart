import 'package:flutter/services.dart';
import 'storage_service.dart';

/// Servicio para proporcionar sensaciones táctiles y auditivas durante el juego.
class AudioHapticService {
  /// Vibración suave al presionar un botón del teclado o seleccionar una casilla
  static void tapFeedback() {
    final settings = StorageService.loadSettings();
    if (!settings.vibrationEnabled) return;
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Vibración de confirmación al validar exitosamente una casilla o ecuación
  static void successFeedback() {
    final settings = StorageService.loadSettings();
    if (!settings.vibrationEnabled) return;
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Vibración de error al cometer un fallo matemático
  static void errorFeedback() {
    final settings = StorageService.loadSettings();
    if (!settings.vibrationEnabled) return;
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  /// Vibración y celebración de victoria
  static void victoryFeedback() {
    final settings = StorageService.loadSettings();
    if (!settings.vibrationEnabled) return;
    try {
      HapticFeedback.vibrate();
    } catch (_) {}
  }
}
