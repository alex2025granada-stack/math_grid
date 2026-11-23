import '../core/enums/cell_type.dart';

/// Modelo fuertemente tipado que representa una celda en la cuadrícula de Math Grid.
class CellModel {
  final String id;
  final int row;
  final int col;
  final CellType type;
  final int? expectedValue;
  final int? userValue;
  final String? operatorSymbol;
  final bool isFixed;
  final bool isHinted;
  final bool hasError;
  final bool isValidated;

  const CellModel({
    required this.id,
    required this.row,
    required this.col,
    required this.type,
    this.expectedValue,
    this.userValue,
    this.operatorSymbol,
    this.isFixed = true,
    this.isHinted = false,
    this.hasError = false,
    this.isValidated = false,
  });

  /// Crea una celda numérica con un valor esperado
  factory CellModel.number({
    required int row,
    required int col,
    required int expectedValue,
    bool isFixed = true,
    int? userValue,
  }) {
    return CellModel(
      id: '${row}_$col',
      row: row,
      col: col,
      type: CellType.number,
      expectedValue: expectedValue,
      userValue: isFixed ? expectedValue : userValue,
      isFixed: isFixed,
    );
  }

  /// Crea una celda de operador (+ o -) o igual (=)
  factory CellModel.symbol({
    required int row,
    required int col,
    required String symbol,
  }) {
    final isEq = symbol == '=';
    return CellModel(
      id: '${row}_$col',
      row: row,
      col: col,
      type: isEq ? CellType.equals : CellType.operator,
      operatorSymbol: symbol,
      isFixed: true,
    );
  }

  /// Texto a mostrar en la interfaz
  String get displayText {
    if (type.isOperator || type.isEquals) {
      return operatorSymbol ?? '';
    }
    if (isFixed) {
      return expectedValue?.toString() ?? '';
    }
    return userValue != null ? userValue.toString() : '';
  }

  /// Indica si la celda editable está actualmente vacía
  bool get isEmpty => !isFixed && userValue == null;

  /// Indica si el valor actual coincide con el esperado
  bool get isCorrect => !isFixed && userValue == expectedValue;

  CellModel copyWith({
    int? userValue,
    bool? isFixed,
    bool? isHinted,
    bool? hasError,
    bool? isValidated,
    bool clearUserValue = false,
  }) {
    return CellModel(
      id: id,
      row: row,
      col: col,
      type: type,
      expectedValue: expectedValue,
      userValue: clearUserValue ? null : (userValue ?? this.userValue),
      operatorSymbol: operatorSymbol,
      isFixed: isFixed ?? this.isFixed,
      isHinted: isHinted ?? this.isHinted,
      hasError: hasError ?? this.hasError,
      isValidated: isValidated ?? this.isValidated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'row': row,
      'col': col,
      'type': type.name,
      'expectedValue': expectedValue,
      'userValue': userValue,
      'operatorSymbol': operatorSymbol,
      'isFixed': isFixed,
      'isHinted': isHinted,
      'hasError': hasError,
      'isValidated': isValidated,
    };
  }

  factory CellModel.fromJson(Map<String, dynamic> json) {
    return CellModel(
      id: json['id'] as String,
      row: json['row'] as int,
      col: json['col'] as int,
      type: CellType.values.firstWhere((e) => e.name == json['type']),
      expectedValue: json['expectedValue'] as int?,
      userValue: json['userValue'] as int?,
      operatorSymbol: json['operatorSymbol'] as String?,
      isFixed: json['isFixed'] as bool? ?? true,
      isHinted: json['isHinted'] as bool? ?? false,
      hasError: json['hasError'] as bool? ?? false,
      isValidated: json['isValidated'] as bool? ?? false,
    );
  }
}
