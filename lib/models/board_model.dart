import '../core/enums/difficulty_level.dart';
import 'cell_model.dart';
import 'equation_model.dart';

/// Representa el tablero completo del crucigrama matemático.
class BoardModel {
  final DifficultyLevel difficulty;
  final int rows;
  final int cols;
  final Map<String, CellModel> cells;
  final List<EquationModel> equations;

  const BoardModel({
    required this.difficulty,
    required this.rows,
    required this.cols,
    required this.cells,
    required this.equations,
  });

  /// Lista de IDs de todas las casillas editables
  List<String> get editableCellIds {
    return cells.values
        .where((cell) => !cell.isFixed && cell.type.isNumber)
        .map((cell) => cell.id)
        .toList();
  }

  /// Cantidad de casillas editables que aún están vacías
  int get emptyCellCount {
    return cells.values.where((c) => !c.isFixed && c.userValue == null).length;
  }

  /// Cantidad total de casillas que el jugador debe completar
  int get totalToFillCount => editableCellIds.length;

  /// Cantidad de casillas completadas por el jugador
  int get filledCellCount => totalToFillCount - emptyCellCount;

  /// Progreso de resolución entre 0.0 y 1.0
  double get progressRatio {
    if (totalToFillCount == 0) return 1.0;
    return filledCellCount / totalToFillCount;
  }

  /// Obtiene una celda por sus coordenadas (o null si está fuera o vacía)
  CellModel? getCell(int row, int col) => cells['${row}_$col'];

  BoardModel copyWith({
    DifficultyLevel? difficulty,
    int? rows,
    int? cols,
    Map<String, CellModel>? cells,
    List<EquationModel>? equations,
  }) {
    return BoardModel(
      difficulty: difficulty ?? this.difficulty,
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
      cells: cells ?? this.cells,
      equations: equations ?? this.equations,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'difficulty': difficulty.name,
      'rows': rows,
      'cols': cols,
      'cells': cells.map((k, v) => MapEntry(k, v.toJson())),
      'equations': equations.map((e) => e.toJson()).toList(),
    };
  }

  factory BoardModel.fromJson(Map<String, dynamic> json) {
    final cellsMap = <String, CellModel>{};
    final rawCells = json['cells'] as Map<String, dynamic>;
    rawCells.forEach((k, v) {
      cellsMap[k] = CellModel.fromJson(v as Map<String, dynamic>);
    });

    final eqList = (json['equations'] as List<dynamic>)
        .map((e) => EquationModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return BoardModel(
      difficulty: DifficultyLevel.values.firstWhere((d) => d.name == json['difficulty']),
      rows: json['rows'] as int,
      cols: json['cols'] as int,
      cells: cellsMap,
      equations: eqList,
    );
  }
}
