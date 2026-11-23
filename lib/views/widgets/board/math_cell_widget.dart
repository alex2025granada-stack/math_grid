import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/cell_model.dart';

/// Casilla individual del crucigrama matemático diseñada con máxima fidelidad
/// a la captura de referencia.
class MathCellWidget extends StatelessWidget {
  final CellModel cell;
  final bool isSelected;
  final double cellSize;
  final VoidCallback? onTap;

  const MathCellWidget({
    super.key,
    required this.cell,
    required this.isSelected,
    this.cellSize = 48.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determinación de color de fondo y borde según el estado
    Color bgColor;
    Color textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    Border? border;

    if (cell.type.isOperator || cell.type.isEquals) {
      // Operadores (+, -, =)
      bgColor = isDark ? AppColors.darkCellFixed : AppColors.cellFixed;
    } else if (cell.isFixed) {
      // Números fijos predeterminados del desafío
      bgColor = isDark ? AppColors.darkCellFixed : AppColors.cellFixed;
    } else {
      // Casillas editables para el jugador
      if (cell.hasError) {
        bgColor = AppColors.cellError;
        border = Border.all(color: AppColors.cellErrorBorder, width: 2.0);
      } else if (cell.isHinted) {
        bgColor = AppColors.cellHinted;
        border = Border.all(color: AppColors.primary, width: 1.5);
      } else if (cell.isValidated) {
        bgColor = AppColors.cellValidated;
      } else {
        bgColor = isDark ? AppColors.darkCellEditable : AppColors.cellEditable;
      }

      // Resaltado de la casilla actualmente seleccionada
      if (isSelected) {
        border = Border.all(
          color: isDark ? Colors.white : AppColors.cellSelectedBorder,
          width: 2.5,
        );
      }
    }

    // Tamaño de fuente escalado proporcionalmente a la celda
    final fontSize = cellSize * 0.42;

    return GestureDetector(
      onTap: cell.isFixed ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: cellSize,
        height: cellSize,
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6.0),
          border: border ??
              Border.all(
                color: isDark ? Colors.black26 : Colors.black12,
                width: 0.5,
              ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.cellSelectedBorder.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            cell.displayText,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
    );
  }
}
