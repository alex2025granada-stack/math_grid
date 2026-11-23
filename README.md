# Math Grid – Juegos Matemáticos

Videojuego interactivo de crucigramas matemáticos desarrollado con **Flutter y Dart**, optimizado para dispositivos móviles Android y compatible con Flutter Web.

El jugador completa casillas vacías deduciendo números mediante lógica y cálculo mental, satisfaciendo simultáneamente operaciones de suma (`+`) y resta (`-`) dispuestas en forma de crucigrama.

---

## 🎯 Reglas Matemáticas Estrictas

- **Operaciones autorizadas exclusivamente:** Suma (`+`) y Resta (`−`).
- **Operaciones prohibidas:** Multiplicaciones (`×`), Divisiones (`÷`), Potencias.
- **Formato contiguo de ecuaciones:** `NÚMERO | OPERADOR | NÚMERO | = | RESULTADO` (5 casillas consecutivas horizontales o verticales).
- **Intersecciones:** Ocurren **únicamente** en casillas numéricas compatibles que satisfacen ambas ecuaciones a la vez.
- **Garantía de Solución Única:** El 100% de los desafíos publicados al jugador cuenta con **una y solo una solución posible**, verificada por el solucionador interno de restricciones y backtracking.

---

## 📱 Niveles de Dificultad

| Nivel | Rango Numérico | Ecuaciones | Casillas a Rellenar | Pistas Iniciales | Negativos | Tiempo Objetivo |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **BÁSICO** | `0` a `10` | 3 a 5 | 3 a 5 | 5 pistas | No | 120s (2 min) |
| **MEDIO** | `0` a `50` | 6 a 8 | 6 a 10 | 3 pistas | No | 240s (4 min) |
| **AVANZADO** | `0` a `100` | 9 a 12 | 10 a 16 | 2 pistas | No | 360s (6 min) |
| **PRO** | `-50` a `500` | 13 a 18 | 15 a 24 | 1 pista | Sí (`±`) | 600s (10 min) |

---

## 🎨 Sistema de Diseño Visual (Fidelidad a la Referencia)

- **Fondo:** `#F8FAF7` (crema suave / verde claro)
- **Casillas fijas:** `#A5D6A7` (verde menta suave con tipografía oscura destacada)
- **Casillas editables:** `#DDF5E5` (verde muy claro para respuestas del jugador)
- **Casilla seleccionada:** Borde de `2.5px` en `#1B5E20` (verde bosque profundo)
- **Verde corporativo:** `#2E6538`
- **Botones numéricos del teclado:** `#F2EDF7` (lavanda/gris claro)
- **Botones de borrado (C y ⌫):** `#FBE0E0` con texto rojizo `#7A1B1B`
- **Tinte de error:** `#FBE0E0` con borde `#D32F2F`
- **Pista revelada:** `#FFF9C4` (amarillo pastel suave)

---

## 🏗️ Arquitectura Técnica Modular

El código está estructurado bajo principios de arquitectura limpia y separación de responsabilidades:

```text
math_grid/
├── lib/
│   ├── main.dart                       # Punto de entrada de la aplicación
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart         # Paleta cromática oficial
│   │   │   └── app_theme.dart          # Temas Material 3 (Claro y Oscuro)
│   │   └── enums/
│   │       ├── cell_type.dart          # number, operator, equals y estados visuales
│   │       └── difficulty_level.dart   # Básico, Medio, Avanzado, Pro
│   ├── models/
│   │   ├── cell_model.dart             # Modelo inmutable de celda con coordenadas
│   │   ├── equation_model.dart         # Modelo de ecuación de 5 casillas
│   │   ├── board_model.dart            # Modelo del crucigrama completo
│   │   ├── game_stats_model.dart       # Estadísticas y récords por dificultad
│   │   └── game_settings_model.dart    # Ajustes persistentes de usuario
│   ├── engine/
│   │   ├── math_generator.dart         # Generador procedimental de grafos de ecuaciones
│   │   ├── math_solver.dart            # Solucionador CSP con propagación y unicidad
│   │   └── math_validator.dart         # Validador en tiempo real y puntuación
│   ├── controllers/
│   │   ├── game_controller.dart        # Gestión de partida, temporizador, historial undo
│   │   ├── settings_controller.dart    # Gestión reactiva de ajustes
│   │   └── stats_controller.dart       # Registro de victorias y rachas
│   ├── services/
│   │   ├── storage_service.dart        # Persistencia local offline
│   │   └── audio_haptic_service.dart   # Vibración y respuesta sensorial
│   └── views/
│       ├── screens/
│       │   ├── home_screen.dart        # Menú principal y selección de nivel
│       │   ├── game_screen.dart        # Experiencia central de juego
│       │   └── stats_screen.dart       # Pantalla de estadísticas personales
│       └── widgets/
│           ├── board/                  # Tablero interactivo con zoom/pan y celdas
│           ├── keypad/                 # Teclado numérico inferior adaptado
│           ├── toolbar/                # Barra de herramientas (Deshacer, Pista, Comprobar...)
│           ├── topbar/                 # Barra superior (Nivel, 0:00, Ajustes)
│           ├── cards/                  # Tarjetas de nivel en el Home
│           └── dialogs/                # Victoria, Ajustes y Confirmaciones
├── test/
│   └── math_grid_test.dart             # Suite de pruebas unitarias completas en Dart
├── web/                                # Soporte completo para Flutter Web
├── android/                            # Manifiestos y configuración para Android
└── test_math_engine_massive.py         # Test de estrés masivo (400 tableros)
```

---

## 🧪 Pruebas Automatizadas y Verificación Masiva

Se implementaron dos niveles de pruebas automáticas:

1. **Suite en Dart (`test/math_grid_test.dart`):**
   - Cobertura de las 17 pruebas obligatorias (generación por niveles, sumas, restas, intersecciones, detección de incompletos/errores, victoria, cálculo de puntuación y estrellas).

2. **Verificación Masiva de Solución Única (`test_math_engine_massive.py`):**
   - **400 tableros generados y resueltos** (100 Básico, 100 Medio, 100 Avanzado, 100 Pro).
   - **100% de tasa de éxito con solución única garantizada.**
   - Velocidad de cálculo: entre 0.2 ms y 12.7 ms por tablero.

---

## 🚀 Instrucciones para Ejecutar

### Requisitos previos
- Tener instalado el SDK de Flutter (versión `>=3.0.0`).
- Android Studio / SDK de Android (para dispositivos Android) o Google Chrome (para Web).

### 1. Descargar dependencias
```bash
cd e:/APPS/math_grid
flutter pub get
```

### 2. Ejecutar pruebas unitarias
```bash
flutter test
```

### 3. Ejecutar en Navegador Web (Chrome)
```bash
flutter run -d chrome
```

### 4. Ejecutar en Dispositivo o Emulador Android
```bash
flutter run
```

### 5. Compilar APK para distribución
```bash
flutter build apk --release
```
El archivo `.apk` compilado se generará en:
`build/app/outputs/flutter-apk/app-release.apk`
