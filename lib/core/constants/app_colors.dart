import 'package:flutter/material.dart';

/// Paleta de colores oficial de Math Grid basada en la captura de referencia
/// y las especificaciones visuales de la aplicación.
class AppColors {
  // Fondos y superficies
  static const Color background = Color(0xFFF8FAF7);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFEDF2EC);

  // Casillas del crucigrama
  static const Color cellFixed = Color(0xFFA5D6A7); // Verde menta pastel para celdas fijas
  static const Color cellEditable = Color(0xFFDDF5E5); // Verde muy claro para respuestas del jugador
  static const Color cellSelectedBorder = Color(0xFF1B5E20); // Borde verde oscuro al seleccionar
  static const Color cellError = Color(0xFFFBE0E0); // Rosa suave de error
  static const Color cellErrorBorder = Color(0xFFD32F2F);
  static const Color cellHinted = Color(0xFFFFF9C4); // Amarillo suave de pista revelada
  static const Color cellValidated = Color(0xFF81C784); // Verde de éxito al comprobar

  // Identidad y textos
  static const Color primary = Color(0xFF2E6538); // Verde principal de la marca
  static const Color primaryDark = Color(0xFF1B5E20); // Verde oscuro para énfasis
  static const Color primaryLight = Color(0xFF4C8C58);
  static const Color textPrimary = Color(0xFF203A24); // Texto oscuro principal
  static const Color textSecondary = Color(0xFF5A735E); // Texto secundario
  static const Color textOnPrimary = Colors.white;

  // Teclado inferior
  static const Color keypadNumberBg = Color(0xFFF2EDF7); // Lavanda/gris muy claro
  static const Color keypadNumberText = Color(0xFF203A24);
  static const Color keypadActionBg = Color(0xFFFBE0E0); // Fondo rojizo suave para C y Borrar
  static const Color keypadActionText = Color(0xFF7A1B1B);
  static const Color keypadSpecialBg = Color(0xFFE8F5E9); // Para tecla +/- de signo negativo
  static const Color keypadSpecialText = Color(0xFF1B5E20);

  // Gamificación y Dificultades
  static const Color starGold = Color(0xFFFFB300);
  static const Color basicColor = Color(0xFF4CAF50);
  static const Color mediumColor = Color(0xFF2E7D32);
  static const Color advancedColor = Color(0xFF1565C0);
  static const Color proColor = Color(0xFF6A1B9A);

  // Modo Oscuro
  static const Color darkBackground = Color(0xFF131A14);
  static const Color darkSurface = Color(0xFF1B241D);
  static const Color darkCellFixed = Color(0xFF2A4D33);
  static const Color darkCellEditable = Color(0xFF1E3825);
  static const Color darkTextPrimary = Color(0xFFE2EBE3);
  static const Color darkKeypadBg = Color(0xFF232D25);
}
