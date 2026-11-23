import 'dart:math';
import 'package:flutter/material.dart';
import '../../../models/board_model.dart';
import 'math_cell_widget.dart';

/// Tablero de crucigrama interactivo con zoom suave, desplazamiento y centrado automático.
class CrosswordBoardWidget extends StatelessWidget {
  final BoardModel board;
  final String? selectedCellId;
  final Function(String cellId) onCellSelected;

  const CrosswordBoardWidget({
    super.key,
    required this.board,
    required this.selectedCellId,
    required this.onCellSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;

        // Calcular el tamaño óptimo de celda para que quepa en pantalla
        final maxCellWidth = (availableWidth - 32) / max(1, board.cols);
        final maxCellHeight = (availableHeight - 32) / max(1, board.rows);
        final optimalCellSize = min(maxCellWidth, maxCellHeight).clamp(32.0, 56.0);

        final boardWidth = board.cols * (optimalCellSize + 3.0);
        final boardHeight = board.rows * (optimalCellSize + 3.0);

        return Center(
          child: InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(40),
            minScale: 0.6,
            maxScale: 2.5,
            child: SizedBox(
              width: boardWidth,
              height: boardHeight,
              child: Stack(
                children: [
                  for (final cell in board.cells.values)
                    Positioned(
                      left: cell.col * (optimalCellSize + 3.0),
                      top: cell.row * (optimalCellSize + 3.0),
                      child: MathCellWidget(
                        cell: cell,
                        cellSize: optimalCellSize,
                        isSelected: cell.id == selectedCellId,
                        onTap: () => onCellSelected(cell.id),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
