import 'dart:math';
import '../core/enums/difficulty_level.dart';
import '../models/board_model.dart';
import '../models/cell_model.dart';
import '../models/equation_model.dart';
import 'math_solver.dart';

/// Generador procedimental de tableros de crucigramas matemáticos.
/// Construye un grafo conexo de ecuaciones interconectadas que utilizan
/// EXCLUSIVAMENTE sumas (+) y restas (-).
class MathGenerator {
  static final Random _rnd = Random();

  /// Genera un tablero matemáticamente válido con solución única garantizada.
  static BoardModel generateBoard(DifficultyLevel difficulty, {int? seed}) {
    final random = seed != null ? Random(seed) : _rnd;
    final minNum = difficulty.minNumber;
    final maxNum = difficulty.maxNumber;
    final targetEquations = difficulty.minEquations +
        random.nextInt(difficulty.maxEquations - difficulty.minEquations + 1);

    for (int retry = 0; retry < 50; retry++) {
      final board = _tryBuildConnectedBoard(
        difficulty: difficulty,
        targetEquations: targetEquations,
        minNum: minNum,
        maxNum: maxNum,
        random: random,
      );
      if (board != null) {
        return board;
      }
    }

    // Tablero de respaldo de alta fidelidad si todos los reintentos aleatorios fallan
    return _buildFallbackBoard(difficulty);
  }

  static BoardModel? _tryBuildConnectedBoard({
    required DifficultyLevel difficulty,
    required int targetEquations,
    required int minNum,
    required int maxNum,
    required Random random,
  }) {
    // Mapa de celdas temporales: 'r_c' -> {type: 'num'/'op', val: int/str, r: int, c: int}
    final grid = <String, Map<String, dynamic>>{};
    final rawEquations = <Map<String, dynamic>>[];

    // 1. Crear ecuación raíz horizontal en (0, 0)
    final rootOp = random.nextBool() ? '+' : '-';
    int rootA, rootB, rootC;

    if (rootOp == '+') {
      rootA = random.nextInt((maxNum / 2).clamp(1, maxNum).toInt() + 1);
      final maxB = maxNum - rootA;
      rootB = maxB > 0 ? random.nextInt(maxB + 1) : 0;
      rootC = rootA + rootB;
    } else {
      rootA = random.nextInt(maxNum + 1);
      if (difficulty.allowNegative) {
        rootB = random.nextInt(maxNum + 1);
        rootC = rootA - rootB;
      } else {
        rootB = rootA > 0 ? random.nextInt(rootA + 1) : 0;
        rootC = rootA - rootB;
      }
    }

    // Colocar ecuación raíz
    _placeRawEquation(
      grid: grid,
      rawEquations: rawEquations,
      startRow: 0,
      startCol: 0,
      isHorizontal: true,
      op: rootOp,
      valA: rootA,
      valB: rootB,
      valC: rootC,
    );

    // 2. Expandir el crucigrama añadiendo ecuaciones perpendiculares en intersecciones numéricas
    int attempts = 0;
    while (rawEquations.length < targetEquations && attempts < 600) {
      attempts++;

      // Elegir una ecuación base existente
      final baseEq = rawEquations[random.nextInt(rawEquations.length)];
      final baseIsHoriz = baseEq['isHorizontal'] as bool;
      final newIsHoriz = !baseIsHoriz; // Perpendicular obligatoria

      // Elegir un slot numérico de la ecuación base (0: A, 2: B, 4: Resultado)
      final baseSlot = [0, 2, 4][random.nextInt(3)];
      final baseCoords = baseEq['coords'] as List<Point<int>>;
      final interPoint = baseCoords[baseSlot];
      final interVal = grid['${interPoint.x}_${interPoint.y}']!['val'] as int;

      // Elegir qué slot numérico de la nueva ecuación ocupará la intersección
      final newSlot = [0, 2, 4][random.nextInt(3)];

      // Calcular el punto de inicio de la nueva ecuación
      final startRow = newIsHoriz ? interPoint.x : interPoint.x - newSlot;
      final startCol = newIsHoriz ? interPoint.y - newSlot : interPoint.y;

      // Coordenadas de las 5 celdas de la nueva ecuación
      final newCoords = <Point<int>>[];
      for (int i = 0; i < 5; i++) {
        final r = newIsHoriz ? startRow : startRow + i;
        final c = newIsHoriz ? startCol + i : startCol;
        newCoords.add(Point(r, c));
      }

      // Validar colisiones con el tablero actual
      bool collision = false;
      for (int i = 0; i < 5; i++) {
        final pt = newCoords[i];
        final key = '${pt.x}_${pt.y}';
        final isNumSlot = (i == 0 || i == 2 || i == 4);

        if (grid.containsKey(key)) {
          final existing = grid[key]!;
          if (!isNumSlot || existing['type'] != 'num' || existing['val'] != interVal) {
            collision = true;
            break;
          }
        } else {
          // Evitar que celdas de operadores toquen ecuaciones paralelas contiguas
          if (!isNumSlot) {
            final adj1 = newIsHoriz ? '${pt.x - 1}_${pt.y}' : '${pt.x}_${pt.y - 1}';
            final adj2 = newIsHoriz ? '${pt.x + 1}_${pt.y}' : '${pt.x}_${pt.y + 1}';
            if (grid.containsKey(adj1) || grid.containsKey(adj2)) {
              collision = true;
              break;
            }
          }
        }
      }

      if (collision) continue;

      // Generar operación matemática válida que coincida con interVal en newSlot
      final newOp = random.nextBool() ? '+' : '-';
      int? newA, newB, newC;

      if (newSlot == 0) {
        newA = interVal;
        if (newOp == '+') {
          final maxB = maxNum - newA;
          if (maxB >= 0) {
            newB = random.nextInt(maxB + 1);
            newC = newA + newB;
          }
        } else {
          if (difficulty.allowNegative) {
            newB = random.nextInt(maxNum + 1);
            newC = newA - newB;
          } else if (newA >= 0) {
            newB = random.nextInt(newA + 1);
            newC = newA - newB;
          }
        }
      } else if (newSlot == 2) {
        newB = interVal;
        if (newOp == '+') {
          final maxA = maxNum - newB;
          if (maxA >= 0) {
            newA = random.nextInt(maxA + 1);
            newC = newA + newB;
          }
        } else {
          if (difficulty.allowNegative) {
            newA = random.nextInt(maxNum + 1);
            newC = newA - newB;
          } else {
            final span = maxNum - newB;
            if (span >= 0) {
              newA = newB + random.nextInt(span + 1);
              newC = newA - newB;
            }
          }
        }
      } else {
        // newSlot == 4 (Resultado)
        newC = interVal;
        if (newOp == '+') {
          if (newC >= 0) {
            newA = random.nextInt(newC + 1);
            newB = newC - newA;
          }
        } else {
          final maxB = maxNum - newC;
          if (maxB >= 0) {
            newB = random.nextInt((maxB > 0 ? maxB : 1) + 1);
            newA = newC + newB;
            if (newA > maxNum) newA = null;
          }
        }
      }

      if (newA == null || newB == null || newC == null) continue;
      if (!difficulty.allowNegative && (newA < 0 || newB < 0 || newC < 0)) continue;
      if (newA > maxNum || newB > maxNum || newC > maxNum) continue;

      // Colocar nueva ecuación
      _placeRawEquation(
        grid: grid,
        rawEquations: rawEquations,
        startRow: startRow,
        startCol: startCol,
        isHorizontal: newIsHoriz,
        op: newOp,
        valA: newA,
        valB: newB,
        valC: newC,
      );
    }

    if (rawEquations.length < difficulty.minEquations) {
      return null; // No alcanzó la cantidad mínima de ecuaciones
    }

    // 3. Normalizar coordenadas para centrar en el origen (0, 0)
    int minRow = 9999, minCol = 9999, maxRow = -9999, maxCol = -9999;
    for (final raw in grid.values) {
      final r = raw['r'] as int;
      final c = raw['c'] as int;
      if (r < minRow) minRow = r;
      if (c < minCol) minCol = c;
      if (r > maxRow) maxRow = r;
      if (c > maxCol) maxCol = c;
    }

    final normalizedCells = <String, CellModel>{};
    final allTrueValues = <String, int>{};

    for (final raw in grid.values) {
      final r = (raw['r'] as int) - minRow;
      final c = (raw['c'] as int) - minCol;
      final type = raw['type'] as String;

      if (type == 'num') {
        final val = raw['val'] as int;
        final cell = CellModel.number(
          row: r,
          col: c,
          expectedValue: val,
          isFixed: true, // Inicialmente todas fijas antes de vaciar
        );
        normalizedCells[cell.id] = cell;
        allTrueValues[cell.id] = val;
      } else {
        final sym = raw['val'] as String;
        final cell = CellModel.symbol(row: r, col: c, symbol: sym);
        normalizedCells[cell.id] = cell;
      }
    }

    final normalizedEquations = <EquationModel>[];
    for (int i = 0; i < rawEquations.length; i++) {
      final raw = rawEquations[i];
      final isH = raw['isHorizontal'] as bool;
      final op = raw['op'] as String;
      final coords = raw['coords'] as List<Point<int>>;

      final normCoords = coords.map((pt) => Point(pt.x - minRow, pt.y - minCol)).toList();
      final cellA = normalizedCells['${normCoords[0].x}_${normCoords[0].y}']!;
      final cellOp = normalizedCells['${normCoords[1].x}_${normCoords[1].y}']!;
      final cellB = normalizedCells['${normCoords[2].x}_${normCoords[2].y}']!;
      final cellEq = normalizedCells['${normCoords[3].x}_${normCoords[3].y}']!;
      final cellRes = normalizedCells['${normCoords[4].x}_${normCoords[4].y}']!;

      normalizedEquations.add(
        EquationModel(
          id: 'eq_$i',
          isHorizontal: isH,
          startRow: normCoords[0].x,
          startCol: normCoords[0].y,
          cellAId: cellA.id,
          cellOpId: cellOp.id,
          cellBId: cellB.id,
          cellEqualId: cellEq.id,
          cellResultId: cellRes.id,
          operatorSymbol: op,
        ),
      );
    }

    // 4. Vaciado inteligente con comprobación de unicidad de solución
    final allNumericCellIds = allTrueValues.keys.toList()..shuffle(random);
    final targetBlanks = difficulty.targetEmptyCells.clamp(2, allNumericCellIds.length - 2);
    final blankIds = <String>{};

    for (final candidateId in allNumericCellIds) {
      blankIds.add(candidateId);

      // Comprobar si al ocultar esta casilla la solución sigue siendo ÚNICA
      final isUnique = MathSolver.hasUniqueSolution(
        equations: normalizedEquations,
        blankCellIds: blankIds,
        allTrueValues: allTrueValues,
        minNumber: minNum,
        maxNumber: maxNum,
      );

      if (isUnique) {
        if (blankIds.length >= targetBlanks) break;
      } else {
        // Generaba múltiples soluciones: revertir y dejarla visible
        blankIds.remove(candidateId);
      }
    }

    // Si por alguna razón quedaron muy pocas casillas en blanco, garantizar al menos 2
    if (blankIds.length < 2) {
      return null;
    }

    // Actualizar celdas marcando las vacías como editables
    final finalCells = <String, CellModel>{};
    for (final entry in normalizedCells.entries) {
      if (blankIds.contains(entry.key)) {
        finalCells[entry.key] = entry.value.copyWith(
          isFixed: false,
          clearUserValue: true,
        );
      } else {
        finalCells[entry.key] = entry.value;
      }
    }

    return BoardModel(
      difficulty: difficulty,
      rows: maxRow - minRow + 1,
      cols: maxCol - minCol + 1,
      cells: finalCells,
      equations: normalizedEquations,
    );
  }

  static void _placeRawEquation({
    required Map<String, Map<String, dynamic>> grid,
    required List<Map<String, dynamic>> rawEquations,
    required int startRow,
    required int startCol,
    required bool isHorizontal,
    required String op,
    required int valA,
    required int valB,
    required int valC,
  }) {
    final coords = <Point<int>>[];
    for (int i = 0; i < 5; i++) {
      final r = isHorizontal ? startRow : startRow + i;
      final c = isHorizontal ? startCol + i : startCol;
      coords.add(Point(r, c));
    }

    grid['${coords[0].x}_${coords[0].y}'] = {'type': 'num', 'val': valA, 'r': coords[0].x, 'c': coords[0].y};
    grid['${coords[1].x}_${coords[1].y}'] = {'type': 'op', 'val': op, 'r': coords[1].x, 'c': coords[1].y};
    grid['${coords[2].x}_${coords[2].y}'] = {'type': 'num', 'val': valB, 'r': coords[2].x, 'c': coords[2].y};
    grid['${coords[3].x}_${coords[3].y}'] = {'type': 'op', 'val': '=', 'r': coords[3].x, 'c': coords[3].y};
    grid['${coords[4].x}_${coords[4].y}'] = {'type': 'num', 'val': valC, 'r': coords[4].x, 'c': coords[4].y};

    rawEquations.add({
      'isHorizontal': isHorizontal,
      'op': op,
      'coords': coords,
    });
  }

  /// Tablero estático de emergencia precalculado y matemáticamente impecable
  static BoardModel _buildFallbackBoard(DifficultyLevel difficulty) {
    final cells = <String, CellModel>{};
    final equations = <EquationModel>[];

    // Ecuación 1 (H): 12 + 8 = [20]
    // Ecuación 2 (V cruzando en 8): 25 - [8] = 17
    // Ecuación 3 (H cruzando en 17): 17 - 5 = [12]
    cells['0_0'] = CellModel.number(row: 0, col: 0, expectedValue: 12, isFixed: true);
    cells['0_1'] = CellModel.symbol(row: 0, col: 1, symbol: '+');
    cells['0_2'] = CellModel.number(row: 0, col: 2, expectedValue: 8, isFixed: false);
    cells['0_3'] = CellModel.symbol(row: 0, col: 3, symbol: '=');
    cells['0_4'] = CellModel.number(row: 0, col: 4, expectedValue: 20, isFixed: true);

    cells['1_2'] = CellModel.symbol(row: 1, col: 2, symbol: '-');
    cells['2_2'] = CellModel.number(row: 2, col: 2, expectedValue: 25, isFixed: true); // Se invierte: 25 - 8 = 17
    cells['3_2'] = CellModel.symbol(row: 3, col: 2, symbol: '=');
    cells['4_2'] = CellModel.number(row: 4, col: 2, expectedValue: 17, isFixed: true);

    cells['4_3'] = CellModel.symbol(row: 4, col: 3, symbol: '-');
    cells['4_4'] = CellModel.number(row: 4, col: 4, expectedValue: 5, isFixed: true);
    cells['4_5'] = CellModel.symbol(row: 4, col: 5, symbol: '=');
    cells['4_6'] = CellModel.number(row: 4, col: 6, expectedValue: 12, isFixed: false);

    equations.add(const EquationModel(
      id: 'fallback_0',
      isHorizontal: true,
      startRow: 0,
      startCol: 0,
      cellAId: '0_0',
      cellOpId: '0_1',
      cellBId: '0_2',
      cellEqualId: '0_3',
      cellResultId: '0_4',
      operatorSymbol: '+',
    ));

    equations.add(const EquationModel(
      id: 'fallback_1',
      isHorizontal: false,
      startRow: 0,
      startCol: 2,
      cellAId: '2_2',
      cellOpId: '1_2',
      cellBId: '0_2',
      cellEqualId: '3_2',
      cellResultId: '4_2',
      operatorSymbol: '-',
    ));

    equations.add(const EquationModel(
      id: 'fallback_2',
      isHorizontal: true,
      startRow: 4,
      startCol: 2,
      cellAId: '4_2',
      cellOpId: '4_3',
      cellBId: '4_4',
      cellEqualId: '4_5',
      cellResultId: '4_6',
      operatorSymbol: '-',
    ));

    return BoardModel(
      difficulty: difficulty,
      rows: 5,
      cols: 7,
      cells: cells,
      equations: equations,
    );
  }
}
