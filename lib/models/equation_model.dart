import 'cell_model.dart';

/// Representa una ecuación matemática de 5 casillas contiguas en el crucigrama:
/// [A] [OP] [B] [=] [RESULTADO]
class EquationModel {
  final String id;
  final bool isHorizontal;
  final int startRow;
  final int startCol;
  final String cellAId;
  final String cellOpId;
  final String cellBId;
  final String cellEqualId;
  final String cellResultId;
  final String operatorSymbol; // '+' o '-'

  const EquationModel({
    required this.id,
    required this.isHorizontal,
    required this.startRow,
    required this.startCol,
    required this.cellAId,
    required this.cellOpId,
    required this.cellBId,
    required this.cellEqualId,
    required this.cellResultId,
    required this.operatorSymbol,
  });

  /// Lista de los 3 IDs de celdas numéricas (A, B, Resultado)
  List<String> get numericCellIds => [cellAId, cellBId, cellResultId];

  /// Lista ordenada de todos los 5 IDs de celdas de la ecuación
  List<String> get allCellIds => [cellAId, cellOpId, cellBId, cellEqualId, cellResultId];

  /// Obtiene los valores actuales (usuario si es editable, o fijo)
  int? getValueA(Map<String, CellModel> cells) {
    final c = cells[cellAId];
    return c?.isFixed == true ? c?.expectedValue : c?.userValue;
  }

  int? getValueB(Map<String, CellModel> cells) {
    final c = cells[cellBId];
    return c?.isFixed == true ? c?.expectedValue : c?.userValue;
  }

  int? getValueResult(Map<String, CellModel> cells) {
    final c = cells[cellResultId];
    return c?.isFixed == true ? c?.expectedValue : c?.userValue;
  }

  /// Verifica si todas las celdas numéricas de esta ecuación tienen un valor ingresado
  bool isComplete(Map<String, CellModel> cells) {
    return getValueA(cells) != null &&
           getValueB(cells) != null &&
           getValueResult(cells) != null;
  }

  /// Evalúa la ecuación aritméticamente de manera exacta
  bool isValid(Map<String, CellModel> cells) {
    final a = getValueA(cells);
    final b = getValueB(cells);
    final res = getValueResult(cells);

    if (a == null || b == null || res == null) return false;

    if (operatorSymbol == '+') {
      return a + b == res;
    } else if (operatorSymbol == '-') {
      return a - b == res;
    }
    return false;
  }

  /// Devuelve cuántas casillas faltan por rellenar en esta ecuación
  int missingCount(Map<String, CellModel> cells) {
    int count = 0;
    if (getValueA(cells) == null) count++;
    if (getValueB(cells) == null) count++;
    if (getValueResult(cells) == null) count++;
    return count;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isHorizontal': isHorizontal,
      'startRow': startRow,
      'startCol': startCol,
      'cellAId': cellAId,
      'cellOpId': cellOpId,
      'cellBId': cellBId,
      'cellEqualId': cellEqualId,
      'cellResultId': cellResultId,
      'operatorSymbol': operatorSymbol,
    };
  }

  factory EquationModel.fromJson(Map<String, dynamic> json) {
    return EquationModel(
      id: json['id'] as String,
      isHorizontal: json['isHorizontal'] as bool,
      startRow: json['startRow'] as int,
      startCol: json['startCol'] as int,
      cellAId: json['cellAId'] as String,
      cellOpId: json['cellOpId'] as String,
      cellBId: json['cellBId'] as String,
      cellEqualId: json['cellEqualId'] as String,
      cellResultId: json['cellResultId'] as String,
      operatorSymbol: json['operatorSymbol'] as String,
    );
  }
}
