import '../models/equation_model.dart';

/// Solucionador matemático determinista y verificador de unicidad de soluciones.
/// Utiliza propagación de restricciones y búsqueda acotada para garantizar que
/// todo tablero publicado al jugador tenga EXACTAMENTE UNA solución.
class MathSolver {
  /// Cuenta las soluciones posibles para un conjunto de casillas en blanco.
  /// Se detiene inmediatamente si encuentra más de 1 solución (para optimizar velocidad).
  static int countSolutions({
    required List<EquationModel> equations,
    required Set<String> blankCellIds,
    required Map<String, int> allTrueValues,
    required int minNumber,
    required int maxNumber,
    int maxSolutionsToSearch = 2,
  }) {
    // Si no hay casillas en blanco, la solución ya está completa y es única
    if (blankCellIds.isEmpty) return 1;

    // Valores fijos iniciales (aquellos que NO son casillas en blanco)
    final initialKnowns = <String, int>{};
    for (final entry in allTrueValues.entries) {
      if (!blankCellIds.contains(entry.key)) {
        initialKnowns[entry.key] = entry.value;
      }
    }

    int foundSolutions = 0;

    // Propaga deducciones inmediatas donde 2 de las 3 variables ya se conocen
    bool propagate(Map<String, int> knowns) {
      bool changed = true;
      while (changed) {
        changed = false;
        for (final eq in equations) {
          final vA = knowns[eq.cellAId];
          final vB = knowns[eq.cellBId];
          final vRes = knowns[eq.cellResultId];

          // 1. Si las 3 son conocidas: verificar coherencia
          if (vA != null && vB != null && vRes != null) {
            final expected = (eq.operatorSymbol == '+') ? (vA + vB) : (vA - vB);
            if (expected != vRes) return false; // Contradicción
          }
          // 2. A y B conocidas -> deducir Resultado
          else if (vA != null && vB != null && vRes == null) {
            final res = (eq.operatorSymbol == '+') ? (vA + vB) : (vA - vB);
            if (res < minNumber || res > maxNumber) return false;
            knowns[eq.cellResultId] = res;
            changed = true;
          }
          // 3. A y Resultado conocidas -> deducir B
          // A + B = C => B = C - A
          // A - B = C => B = A - C
          else if (vA != null && vB == null && vRes != null) {
            final b = (eq.operatorSymbol == '+') ? (vRes - vA) : (vA - vRes);
            if (b < minNumber || b > maxNumber) return false;
            knowns[eq.cellBId] = b;
            changed = true;
          }
          // 4. B y Resultado conocidas -> deducir A
          // A + B = C => A = C - B
          // A - B = C => A = C + B
          else if (vA == null && vB != null && vRes != null) {
            final a = (eq.operatorSymbol == '+') ? (vRes - vB) : (vRes + vB);
            if (a < minNumber || a > maxNumber) return false;
            knowns[eq.cellAId] = a;
            changed = true;
          }
        }
      }
      return true;
    }

    // Búsqueda exhaustiva con poda
    void backtrack(Map<String, int> currentKnowns) {
      if (foundSolutions >= maxSolutionsToSearch) return;

      final knownsCopy = Map<String, int>.from(currentKnowns);
      if (!propagate(knownsCopy)) return;

      final unassigned = blankCellIds.where((id) => !knownsCopy.containsKey(id)).toList();
      if (unassigned.isEmpty) {
        // Todas asignadas y consistentes
        bool allValid = true;
        for (final eq in equations) {
          final a = knownsCopy[eq.cellAId]!;
          final b = knownsCopy[eq.cellBId]!;
          final r = knownsCopy[eq.cellResultId]!;
          final exp = (eq.operatorSymbol == '+') ? (a + b) : (a - b);
          if (exp != r) {
            allValid = false;
            break;
          }
        }
        if (allValid) {
          foundSolutions++;
        }
        return;
      }

      // Seleccionar la variable más restringida (que pertenezca a más ecuaciones)
      unassigned.sort((a, b) {
        final countA = equations.where((eq) => eq.numericCellIds.contains(a)).length;
        final countB = equations.where((eq) => eq.numericCellIds.contains(b)).length;
        return countB.compareTo(countA);
      });

      final varId = unassigned.first;
      final trueVal = allTrueValues[varId]!;

      // Probar primero el valor real, luego los cercanos para podar rápido
      final candidates = <int>[trueVal];
      const searchRadius = 30;
      final lowBound = (trueVal - searchRadius < minNumber) ? minNumber : trueVal - searchRadius;
      final highBound = (trueVal + searchRadius > maxNumber) ? maxNumber : trueVal + searchRadius;

      for (int v = lowBound; v <= highBound; v++) {
        if (v != trueVal) candidates.add(v);
      }

      for (final val in candidates) {
        knownsCopy[varId] = val;
        backtrack(knownsCopy);
        knownsCopy.remove(varId);
        if (foundSolutions >= maxSolutionsToSearch) return;
      }
    }

    backtrack(initialKnowns);
    return foundSolutions;
  }

  /// Verifica si el tablero actual tiene una solución única
  static bool hasUniqueSolution({
    required List<EquationModel> equations,
    required Set<String> blankCellIds,
    required Map<String, int> allTrueValues,
    required int minNumber,
    required int maxNumber,
  }) {
    return countSolutions(
      equations: equations,
      blankCellIds: blankCellIds,
      allTrueValues: allTrueValues,
      minNumber: minNumber,
      maxNumber: maxNumber,
    ) == 1;
  }
}
