import 'package:flutter/material.dart';
import '../models/game_settings_model.dart';
import '../services/storage_service.dart';

/// Controlador reactivo para la configuración de la aplicación.
class SettingsController extends ChangeNotifier {
  GameSettingsModel _settings = const GameSettingsModel();

  GameSettingsModel get settings => _settings;

  SettingsController() {
    _settings = StorageService.loadSettings();
  }

  void toggleSound() {
    _update(_settings.copyWith(soundEnabled: !_settings.soundEnabled));
  }

  void toggleVibration() {
    _update(_settings.copyWith(vibrationEnabled: !_settings.vibrationEnabled));
  }

  void toggleDarkMode() {
    _update(_settings.copyWith(darkMode: !_settings.darkMode));
  }

  void toggleShowTimer() {
    _update(_settings.copyWith(showTimer: !_settings.showTimer));
  }

  void toggleConfirmRestart() {
    _update(_settings.copyWith(confirmRestart: !_settings.confirmRestart));
  }

  void setTextScale(double scale) {
    _update(_settings.copyWith(textScale: scale));
  }

  void _update(GameSettingsModel newSettings) {
    _settings = newSettings;
    StorageService.saveSettings(newSettings);
    notifyListeners();
  }
}
