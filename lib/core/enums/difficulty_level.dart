import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Niveles de dificultad estrictamente definidos según la sección 2 del proyecto.
enum DifficultyLevel {
  basic,
  medium,
  advanced,
  pro;

  String get displayName {
    switch (this) {
      case DifficultyLevel.basic:
        return 'Básico';
      case DifficultyLevel.medium:
        return 'Medio';
      case DifficultyLevel.advanced:
        return 'Avanzado';
      case DifficultyLevel.pro:
        return 'Pro';
    }
  }

  String get description {
    switch (this) {
      case DifficultyLevel.basic:
        return 'Números del 0 al 10 • Sin negativos • Ideal para principiantes';
      case DifficultyLevel.medium:
        return 'Números del 0 al 50 • Ecuaciones cruzadas • Razonamiento medio';
      case DifficultyLevel.advanced:
        return 'Números del 0 al 100 • Tableros grandes y conexiones múltiples';
      case DifficultyLevel.pro:
        return 'Números del 0 al 500 • Resultados negativos • Desafío experto';
    }
  }

  int get minNumber {
    switch (this) {
      case DifficultyLevel.basic:
      case DifficultyLevel.medium:
      case DifficultyLevel.advanced:
        return 0;
      case DifficultyLevel.pro:
        return -50;
    }
  }

  int get maxNumber {
    switch (this) {
      case DifficultyLevel.basic:
        return 10;
      case DifficultyLevel.medium:
        return 50;
      case DifficultyLevel.advanced:
        return 100;
      case DifficultyLevel.pro:
        return 500;
    }
  }

  int get minEquations {
    switch (this) {
      case DifficultyLevel.basic:
        return 3;
      case DifficultyLevel.medium:
        return 6;
      case DifficultyLevel.advanced:
        return 9;
      case DifficultyLevel.pro:
        return 13;
    }
  }

  int get maxEquations {
    switch (this) {
      case DifficultyLevel.basic:
        return 5;
      case DifficultyLevel.medium:
        return 8;
      case DifficultyLevel.advanced:
        return 12;
      case DifficultyLevel.pro:
        return 18;
    }
  }

  int get targetEmptyCells {
    switch (this) {
      case DifficultyLevel.basic:
        return 4;
      case DifficultyLevel.medium:
        return 8;
      case DifficultyLevel.advanced:
        return 14;
      case DifficultyLevel.pro:
        return 20;
    }
  }

  bool get allowNegative {
    return this == DifficultyLevel.pro;
  }

  int get initialHints {
    switch (this) {
      case DifficultyLevel.basic:
        return 5;
      case DifficultyLevel.medium:
        return 3;
      case DifficultyLevel.advanced:
        return 2;
      case DifficultyLevel.pro:
        return 1;
    }
  }

  int get targetTimeSeconds {
    switch (this) {
      case DifficultyLevel.basic:
        return 120;
      case DifficultyLevel.medium:
        return 240;
      case DifficultyLevel.advanced:
        return 360;
      case DifficultyLevel.pro:
        return 600;
    }
  }

  Color get cardColor {
    switch (this) {
      case DifficultyLevel.basic:
        return AppColors.basicColor;
      case DifficultyLevel.medium:
        return AppColors.mediumColor;
      case DifficultyLevel.advanced:
        return AppColors.advancedColor;
      case DifficultyLevel.pro:
        return AppColors.proColor;
    }
  }

  IconData get icon {
    switch (this) {
      case DifficultyLevel.basic:
        return Icons.sentiment_satisfied_alt;
      case DifficultyLevel.medium:
        return Icons.auto_awesome;
      case DifficultyLevel.advanced:
        return Icons.psychology;
      case DifficultyLevel.pro:
        return Icons.local_fire_department;
    }
  }
}
