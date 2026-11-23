import 'package:flutter/material.dart';
import 'controllers/game_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/stats_controller.dart';
import 'core/constants/app_theme.dart';
import 'services/storage_service.dart';
import 'views/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

  final settingsController = SettingsController();
  final statsController = StatsController();
  final gameController = GameController(statsController: statsController);

  runApp(MathGridApp(
    settingsController: settingsController,
    statsController: statsController,
    gameController: gameController,
  ));
}

class MathGridApp extends StatelessWidget {
  final SettingsController settingsController;
  final StatsController statsController;
  final GameController gameController;

  const MathGridApp({
    super.key,
    required this.settingsController,
    required this.statsController,
    required this.gameController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (context, _) {
        final settings = settingsController.settings;

        return MaterialApp(
          title: 'Math Grid – Juegos Matemáticos',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(settings.textScale),
              ),
              child: child!,
            );
          },
          home: HomeScreen(
            gameController: gameController,
            settingsController: settingsController,
            statsController: statsController,
          ),
        );
      },
    );
  }
}
