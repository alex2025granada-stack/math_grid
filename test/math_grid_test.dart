import 'package:flutter_test/flutter_test.dart';
import 'package:math_grid/core/enums/cell_type.dart';
import 'package:math_grid/core/enums/difficulty_level.dart';
import 'package:math_grid/engine/math_generator.dart';
import 'package:math_grid/engine/math_solver.dart';
import 'package:math_grid/engine/math_validator.dart';
import 'package:math_grid/models/board_model.dart';
import 'package:math_grid/models/cell_model.dart';
import 'package:math_grid/models/equation_model.dart';

void main() {
  group('1-4. Pruebas de Generación de Tableros por Dificultad', () {
    test('Generación de tableros básicos', () {
      final board = MathGenerator.generateBoard(DifficultyLevel.basic, seed: 42);
      expect(board.equations.length, greaterThanOrEqualTo(DifficultyLevel.basic.minEquations));
      expect(board.equations.length, lessThanOrEqualTo(DifficultyLevel.basic.maxEquations));
      expect(board.editableCellIds.length, greaterThan(0));

      // Verificar que todos los números están en [0, 10]
      for (final cell in board.cells.values) {
        if (cell.type.isNumber) {
          expect(cell.expectedValue, greaterThanOrEqualTo(0));
          expect(cell.expectedValue, lessThanOrEqualTo(10));
        }
      }
    });

    test('Generación de tableros medios', () {
      final board = MathGenerator.generateBoard(DifficultyLevel.medium, seed: 101);
      expect(board.equations.length, greaterThanOrEqualTo(DifficultyLevel.medium.minEquations));
      expect(board.equations.length, lessThanOrEqualTo(DifficultyLevel.medium.maxEquations));
      expect(board.editableCellIds.length, greaterThanOrEqualTo(4));

      for (final cell in board.cells.values) {
        if (cell.type.isNumber) {
          expect(cell.expectedValue, greaterThanOrEqualTo(0));
          expect(cell.expectedValue, lessThanOrEqualTo(50));
        }
      }
    });

    test('Generación de tableros avanzados', () {
      final board = MathGenerator.generateBoard(DifficultyLevel.advanced, seed: 202);
      expect(board.equations.length, greaterThanOrEqualTo(DifficultyLevel.advanced.minEquations));
      expect(board.equations.length, lessThanOrEqualTo(DifficultyLevel.advanced.maxEquations));

      for (final cell in board.cells.values) {
        if (cell.type.isNumber) {
          expect(cell.expectedValue, greaterThanOrEqualTo(0));
          expect(cell.expectedValue, lessThanOrEqualTo(100));
        }
      }
    });

    test('Generación de tableros Pro', () {
      final board = MathGenerator.generateBoard(DifficultyLevel.pro, seed: 303);
      expect(board.equations.length, greaterThanOrEqualTo(DifficultyLevel.pro.minEquations));

      for (final cell in board.cells.values) {
        if (cell.type.isNumber) {
          expect(cell.expectedValue, greaterThanOrEqualTo(-50));
          expect(cell.expectedValue, lessThanOrEqualTo(500));
        }
      }
    });
  });

  group('5-6. Validación Aritmética de Sumas y Restas Exclusivas', () {
    test('Validación de sumas correctas e incorrectas', () {
      final cells = <String, CellModel>{
        '0_0': CellModel.number(row: 0, col: 0, expectedValue: 15, isFixed: false, userValue: 15),
        '0_1': CellModel.symbol(row: 0, col: 1, symbol: '+'),
        '0_2': CellModel.number(row: 0, col: 2, expectedValue: 25, isFixed: true),
        '0_3': CellModel.symbol(row: 0, col: 3, symbol: '='),
        '0_4': CellModel.number(row: 0, col: 4, expectedValue: 40, isFixed: true),
      };

      const eq = EquationModel(
        id: 'eq1',
        isHorizontal: true,
        startRow: 0,
        startCol: 0,
        cellAId: '0_0',
        cellOpId: '0_1',
        cellBId: '0_2',
        cellEqualId: '0_3',
        cellResultId: '0_4',
        operatorSymbol: '+',
      );

      expect(eq.isValid(cells), isTrue);

      // Con valor erróneo del usuario
      final cellsWrong = Map<String, CellModel>.from(cells);
      cellsWrong['0_0'] = cells['0_0']!.copyWith(userValue: 10);
      expect(eq.isValid(cellsWrong), isFalse);
    });

    test('Validación de restas correctas e incorrectas', () {
      final cells = <String, CellModel>{
        '0_0': CellModel.number(row: 0, col: 0, expectedValue: 50, isFixed: true),
        '0_1': CellModel.symbol(row: 0, col: 1, symbol: '-'),
        '0_2': CellModel.number(row: 0, col: 2, expectedValue: 18, isFixed: false, userValue: 18),
        '0_3': CellModel.symbol(row: 0, col: 3, symbol: '='),
        '0_4': CellModel.number(row: 0, col: 4, expectedValue: 32, isFixed: true),
      };

      const eq = EquationModel(
        id: 'eq2',
        isHorizontal: true,
        startRow: 0,
        startCol: 0,
        cellAId: '0_0',
        cellOpId: '0_1',
        cellBId: '0_2',
        cellEqualId: '0_3',
        cellResultId: '0_4',
        operatorSymbol: '-',
      );

      expect(eq.isValid(cells), isTrue);

      final cellsWrong = Map<String, CellModel>.from(cells);
      cellsWrong['0_2'] = cells['0_2']!.copyWith(userValue: 20);
      expect(eq.isValid(cellsWrong), isFalse);
    });

    test('Prohibición estricta de multiplicaciones y divisiones', () {
      final board = MathGenerator.generateBoard(DifficultyLevel.medium, seed: 777);
      for (final cell in board.cells.values) {
        if (cell.type.isOperator) {
          expect(cell.operatorSymbol == '+' || cell.operatorSymbol == '-', isTrue);
          expect(cell.operatorSymbol == '×' || cell.operatorSymbol == '*' || cell.operatorSymbol == '÷' || cell.operatorSymbol == '/', isFalse);
        }
      }
    });
  });

  group('7-8. Cruces entre Ecuaciones y Verificación de Solución Única', () {
    test('Las celdas de intersección son numéricas e idénticas en ambas ecuaciones', () {
      final board = MathGenerator.generateBoard(DifficultyLevel.medium, seed: 888);

      final cellToEquations = <String, List<EquationModel>>{};
      for (final eq in board.equations) {
        for (final cid in eq.allCellIds) {
          cellToEquations.putIfAbsent(cid, () => []).add(eq);
        }
      }

      // Buscar intersecciones
      final intersections = cellToEquations.entries.where((e) => e.value.length > 1).toList();
      expect(intersections.isNotEmpty, isTrue);

      for (final inter in intersections) {
        final cell = board.cells[inter.key]!;
        // Toda intersección debe ser una celda numérica
        expect(cell.type.isNumber, isTrue);
        expect(cell.type.isOperator, isFalse);
        expect(cell.type.isEquals, isFalse);

        // Una debe ser horizontal y la otra vertical
        final eqA = inter.value[0];
        final eqB = inter.value[1];
        expect(eqA.isHorizontal != eqB.isHorizontal, isTrue);
      }
    });

    test('El solucionador detecta solución única verificable', () {
      // 10 + 5 = 15
      // 15 - 8 = 7
      final equations = [
        const EquationModel(
          id: 'e1',
          isHorizontal: true,
          startRow: 0,
          startCol: 0,
          cellAId: '0_0',
          cellOpId: '0_1',
          cellBId: '0_2',
          cellEqualId: '0_3',
          cellResultId: '0_4',
          operatorSymbol: '+',
        ),
        const EquationModel(
          id: 'e2',
          isHorizontal: false,
          startRow: 0,
          startCol: 4,
          cellAId: '0_4',
          cellOpId: '1_4',
          cellBId: '2_4',
          cellEqualId: '3_4',
          cellResultId: '4_4',
          operatorSymbol: '-',
        ),
      ];

      final trueVals = {
        '0_0': 10,
        '0_2': 5,
        '0_4': 15,
        '2_4': 8,
        '4_4': 7,
      };

      // Si ocultamos solo '0_2' (5) y '4_4' (7)
      final blanks = {'0_2', '4_4'};
      final isUnique = MathSolver.hasUniqueSolution(
        equations: equations,
        blankCellIds: blanks,
        allTrueValues: trueVals,
        minNumber: 0,
        maxNumber: 50,
      );

      expect(isUnique, isTrue);
    });
  });

  group('9-12. Detección de Errores, Tableros Incompletos y Victoria', () {
    test('Detección de tablero incompleto y respuestas incorrectas', () {
      final cells = <String, CellModel>{
        '0_0': CellModel.number(row: 0, col: 0, expectedValue: 10, isFixed: true),
        '0_1': CellModel.symbol(row: 0, col: 1, symbol: '+'),
        '0_2': CellModel.number(row: 0, col: 2, expectedValue: 5, isFixed: false, userValue: null), // Vacío
        '0_3': CellModel.symbol(row: 0, col: 3, symbol: '='),
        '0_4': CellModel.number(row: 0, col: 4, expectedValue: 15, isFixed: true),
      };

      final board = BoardModel(
        difficulty: DifficultyLevel.basic,
        rows: 1,
        cols: 5,
        cells: cells,
        equations: [
          const EquationModel(
            id: 'e1',
            isHorizontal: true,
            startRow: 0,
            startCol: 0,
            cellAId: '0_0',
            cellOpId: '0_1',
            cellBId: '0_2',
            cellEqualId: '0_3',
            cellResultId: '0_4',
            operatorSymbol: '+',
          ),
        ],
      );

      final valIncomplete = MathValidator.validateBoard(board);
      expect(valIncomplete.isAllComplete, isFalse);
      expect(valIncomplete.hasVictory, isFalse);
      expect(valIncomplete.emptyCount, equals(1));

      // Respuesta incorrecta
      final cellsWrong = Map<String, CellModel>.from(cells);
      cellsWrong['0_2'] = cells['0_2']!.copyWith(userValue: 99);
      final boardWrong = board.copyWith(cells: cellsWrong);

      final valWrong = MathValidator.validateBoard(boardWrong);
      expect(valWrong.isAllComplete, isTrue);
      expect(valWrong.hasVictory, isFalse);
      expect(valWrong.errorCellIds.contains('0_2'), isTrue);

      // Respuesta correcta -> Victoria
      final cellsCorrect = Map<String, CellModel>.from(cells);
      cellsCorrect['0_2'] = cells['0_2']!.copyWith(userValue: 5);
      final boardCorrect = board.copyWith(cells: cellsCorrect);

      final valVictory = MathValidator.validateBoard(boardCorrect);
      expect(valVictory.isAllComplete, isTrue);
      expect(valVictory.isAllValid, isTrue);
      expect(valVictory.hasVictory, isTrue);
    });
  });

  group('15-16. Sistema de Puntuación, Estrellas y Pistas', () {
    test('Cálculo determinista de puntuación', () {
      final scoreHigh = MathValidator.calculateScore(
        difficulty: DifficultyLevel.medium,
        timeSeconds: 60, // Muy rápido
        hintsUsed: 0,
        errors: 0,
      );

      final scoreLow = MathValidator.calculateScore(
        difficulty: DifficultyLevel.medium,
        timeSeconds: 300, // Lento
        hintsUsed: 2,
        errors: 3,
      );

      expect(scoreHigh, greaterThan(scoreLow));
      expect(scoreHigh, greaterThanOrEqualTo(2000));
    });

    test('Cálculo de estrellas (0-3)', () {
      final stars3 = MathValidator.calculateStars(
        difficulty: DifficultyLevel.basic,
        timeSeconds: 50,
        hintsUsed: 0,
        errors: 0,
      );
      expect(stars3, equals(3));

      final stars2 = MathValidator.calculateStars(
        difficulty: DifficultyLevel.basic,
        timeSeconds: 150,
        hintsUsed: 1,
        errors: 1,
      );
      expect(stars2, equals(2));

      final stars1 = MathValidator.calculateStars(
        difficulty: DifficultyLevel.basic,
        timeSeconds: 400,
        hintsUsed: 3,
        errors: 5,
      );
      expect(stars1, equals(1));
    });
  });
}
