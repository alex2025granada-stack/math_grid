/// Tipo de celda en el tablero de crucigrama.
enum CellType {
  number,
  operator,
  equals;

  bool get isNumber => this == CellType.number;
  bool get isOperator => this == CellType.operator;
  bool get isEquals => this == CellType.equals;
}

/// Estado visual reactivo de una celda en la interfaz.
enum CellVisualState {
  normal,
  selected,
  error,
  hinted,
  validated;

  bool get isSelected => this == CellVisualState.selected;
  bool get hasError => this == CellVisualState.error;
  bool get isHinted => this == CellVisualState.hinted;
  bool get isValidated => this == CellVisualState.validated;
}
