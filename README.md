# BlockRush: Puzzle & Survive

## 🎮 Descripción

BlockRush: Puzzle & Survive es un juego de puzzle de bloques con dos modos de juego principales:

- **Modo Infinito ♾️**: Generación procedural infinita con 7 biomas diferentes
- **Modo Historia ⚔️**: 5 capítulos con narrativa, personajes y jefes

## 🚀 Despliegue en Codemagic.io

El proyecto está configurado para compilarse automáticamente en Codemagic.io con las siguientes características:

### ✅ Configuración Incluida

- **Gradle 8.1.0** - Compatible con Android v2 embedding
- **Java 17** - Versión requerida por Flutter 3.19+
- **Flutter 3.19.0** - Versión estable con Android v2 embedding
- **Cache de dependencias** - Optimiza tiempos de compilación
- **GitHub Actions** - Workflow automatizado para builds

### 📋 Estructura del Proyecto

```
/
├── lib/
│   ├── models/          # Modelos de datos
│   ├── services/        # Servicios (API, almacenamiento)
│   ├── providers/        # State management (Riverpod)
│   ├── widgets/          # Componentes UI reutilizables
│   ├── screens/          # Pantallas de la aplicación
│   └── config/           # Configuración y constantes
├── android/
│   ├── app/
│   │   ├── build.gradle      # Configuración de Gradle
│   │   └── src/main/      # Código nativo Android
│   ├── build.gradle           # Configuración principal
│   ├── gradle.properties      # Propiedades de Gradle
│   └── gradlew              # Wrapper de Gradle
└── .github/workflows/         # CI/CD
```

### 🔧 Requisitos de Compilación

- **Flutter SDK**: 3.19.0+
- **Java**: 17+
- **Gradle**: 8.1.0+
- **Android SDK**: API 34

### 📱 Características Técnicas

- **Android v2 Embedding** - Última versión del embedding de Flutter
- **Material Design 3** - UI moderna y consistente
- **Riverpod 2.4.9** - State management optimizado
- **Animaciones Fluidas** - flutter_animate 4.2.0
- **Persistencia Local** - SharedPreferences
- **Monetización** - Google Mobile Ads integrado

## 🎯 Modos de Juego

### ♾️ Modo Infinito
- **7 Biomas**: garden, caverns, volcano, ocean, storm, ice, void, dome
- **Generación Procedural**: Niveles infinitos con semilla determinista
- **Dificultad Progresiva**: fácil → normal → difícil → experto → maestro
- **Eventos Especiales**: Retos cada 5 niveles, jefes cada 10
- **Hitos**: Títulos desbloqueables cada 25 niveles

### ⚔️ Modo Historia
- **5 Capítulos**: Cada uno con su propio bioma y lore
- **12 Niveles por Capítulo**: 10 normales + 1 reto + 1 jefe
- **Sistema de Diálogos**: 8 personajes con emociones y typewriter effect
- **Progresión Visual**: Mapa interactivo con desbloqueo progresivo
- **Skins Desbloqueables**: Recompensas cosméticas

## 🔧 Configuración para Codemagic.io

El proyecto ya está configurado para funcionar en Codemagic.io sin modificaciones:

1. **Variables de Entorno**: Configuradas automáticamente
2. **Dependencias**: Versiones compatibles y estables
3. **Gradle**: Configurado para Android v2 embedding
4. **Cache**: Optimizado para builds rápidos
5. **Workflow**: GitHub Actions listo para CI/CD

## 📦 Build Commands

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (para Play Store)
flutter build appbundle --release
```

## 🐛 Solución de Problemas Comunes

### Error: "Build failed due to use of deleted Android v1 embedding"
**Solución**: El proyecto ya está configurado con v2 embedding:
- ✅ MainActivity usa FlutterActivity
- ✅ AndroidManifest tiene flutterEmbedding="2"
- ✅ Gradle 8.1.0 configurado
- ✅ Java 17 configurado

### Error: "Dependency not found"
**Solución**: Las dependencias están fijadas a versiones estables:
- ✅ Todas las dependencias tienen versiones específicas
- ✅ flutter_haptic_feedback removido (causaba conflictos)
- ✅ user_messaging_platform degradado a 1.3.0

### Error: "SDK not found"
**Solución**: El workflow configura automáticamente:
- ✅ Java 17 configurado via setup-java@v3
- ✅ Flutter 3.19.0 configurado via flutter-action@v2
- ✅ Android SDK paths configurados

## 🚀 Despliegue

1. **Subir a GitHub**: El proyecto está listo para push
2. **Conectar a Codemagic.io**: Usar repositorio de GitHub
3. **Build Automático**: El workflow se ejecuta en cada push
4. **Descargar APK**: Disponible en artifacts de Codemagic.io

## 📊 Especificaciones Técnicas

| Característica | Especificación |
|---------------|---------------|
| Flutter | 3.19.0 |
| Dart | 3.3.1 |
| Android Target | API 34 (Android 14) |
| Min SDK | API 21 (Android 5.0) |
| Arquitectura | arm64-v8a, armeabi-v7a |
| Tamaño Estimado | ~25MB |
| RAM Mínima | 2GB |

## 🎮 Controles

- **Arrastrar y Soltar**: Para colocar piezas
- **Toques**: Para interacciones rápidas
- **Botones Flotantes**: Para acciones especiales
- **Gestos**: Para navegación y menús

## 🏆 Sistema de Progresión

- **Puntuación**: Por líneas completadas y combos
- **Monedas**: Moneda virtual del juego
- **Niveles**: Progresión infinita o por capítulos
- **Logros**: Hitos y títulos desbloqueables
- **Estadísticas**: Tiempo de juego, mejor puntuación

---

**El proyecto está 100% listo para despliegue en Codemagic.io** 🚀
