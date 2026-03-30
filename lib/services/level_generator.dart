import 'dart:math';
import 'package:blockrush/models/generated_level.dart';
import 'package:blockrush/models/piece.dart';
import 'package:blockrush/config/constants.dart';

class LevelGenerator {
  static final Random _random = Random();
  
  // Generar nivel procedural determinista
  static GeneratedLevel generate(int levelNumber) {
    final seed = levelNumber * 31337; // Semilla determinista
    final rng = Random(seed);
    
    return GeneratedLevel(
      levelNumber: levelNumber,
      biome: _getBiome(levelNumber),
      difficulty: _getDifficulty(levelNumber),
      specialEvent: _getSpecialEvent(levelNumber),
      boardObstacles: _generateObstacles(levelNumber, rng),
      allowedPieceTypes: _getPiecePool(levelNumber),
      targetScore: _getTargetScore(levelNumber),
      timeLimit: _getTimeLimit(levelNumber),
      colorRestriction: _getColorChallenge(levelNumber),
      targetColorHex: _getTargetColor(levelNumber),
      hasCursedCells: _hasCursedCells(levelNumber),
      hasPositiveCells: _hasPositiveCells(levelNumber),
      hasGhostBlocks: _hasGhostBlocks(levelNumber),
      boardSize: _getBoardSize(levelNumber),
      specialRules: _getSpecialRules(levelNumber, rng),
    );
  }
  
  // Obtener bioma según nivel
  static Biome _getBiome(int levelNumber) {
    if (levelNumber <= 24) return Biome.garden;
    if (levelNumber <= 49) return Biome.caverns;
    if (levelNumber <= 74) return Biome.volcano;
    if (levelNumber <= 99) return Biome.ocean;
    if (levelNumber <= 124) return Biome.storm;
    if (levelNumber <= 149) return Biome.ice;
    return Biome.void;
  }
  
  // Obtener dificultad según nivel
  static Difficulty _getDifficulty(int levelNumber) {
    if (levelNumber <= 10) return Difficulty.easy;
    if (levelNumber <= 25) return Difficulty.normal;
    if (levelNumber <= 50) return Difficulty.hard;
    if (levelNumber <= 100) return Difficulty.expert;
    return Difficulty.master;
  }
  
  // Obtener evento especial
  static SpecialEventType _getSpecialEvent(int levelNumber) {
    if (levelNumber % 25 == 0) return SpecialEventType.milestone;
    if (levelNumber % 10 == 0) return SpecialEventType.boss;
    if (levelNumber % 5 == 0) return SpecialEventType.challenge;
    return SpecialEventType.none;
  }
  
  // Generar obstáculos del tablero
  static List<BoardObstacle> _generateObstacles(int levelNumber, Random rng) {
    final obstacles = <BoardObstacle>[];
    final difficulty = _getDifficulty(levelNumber);
    final biome = _getBiome(levelNumber);
    
    int obstacleCount;
    switch (difficulty) {
      case Difficulty.easy:
        obstacleCount = 0;
        break;
      case Difficulty.normal:
        obstacleCount = 2 + rng.nextInt(3); // 2-4
        break;
      case Difficulty.hard:
        obstacleCount = 4 + rng.nextInt(5); // 4-8
        break;
      case Difficulty.expert:
        obstacleCount = 8 + rng.nextInt(7); // 8-14
        break;
      case Difficulty.master:
        obstacleCount = 14 + rng.nextInt(7); // 14-20
        break;
    }
    
    // Generar posiciones aleatorias
    final usedPositions = <String>{};
    while (obstacles.length < obstacleCount) {
      final x = rng.nextInt(GameConstants.boardSize);
      final y = rng.nextInt(GameConstants.boardSize);
      final posKey = '$x,$y';
      
      if (!usedPositions.contains(posKey)) {
        usedPositions.add(posKey);
        obstacles.add(_generateObstacleForBiome(x, y, biome, difficulty, rng));
      }
    }
    
    return obstacles;
  }
  
  // Generar obstáculo específico para bioma
  static BoardObstacle _generateObstacleForBiome(
    int x, 
    int y, 
    Biome biome, 
    Difficulty difficulty, 
    Random rng
  ) {
    switch (biome) {
      case Biome.caverns:
        // Obstáculos de cristal que requieren 2 limpiezas
        return BoardObstacle.crystal(x, y, health: 2);
        
      case Biome.volcano:
        // Celdas calientes para puntos dobles
        if (rng.nextDouble() < 0.3) {
          return BoardObstacle.hot(x, y);
        }
        break;
        
      case Biome.ocean:
        // Bloques de memoria
        if (rng.nextDouble() < 0.2) {
          final colors = ['#00BCD4', '#009688', '#4DD0E1'];
          return BoardObstacle.memory(
            x, 
            y, 
            colorHex: colors[rng.nextInt(colors.length)]
          );
        }
        break;
        
      case Biome.void:
        // Mezcla de todos los tipos
        final types = [
          () => BoardObstacle.cursed(x, y),
          () => BoardObstacle.positive(x, y),
          () => BoardObstacle.ghost(x, y),
        ];
        return types[rng.nextInt(types.length)]();
        
      default:
        break;
    }
    
    // Obstáculo normal bloqueado
    return BoardObstacle.blocked(x, y);
  }
  
  // Obtener pool de piezas disponibles
  static List<PieceType> _getPiecePool(int levelNumber) {
    final difficulty = _getDifficulty(levelNumber);
    final allPieces = PieceType.values;
    
    switch (difficulty) {
      case Difficulty.easy:
        // Solo piezas pequeñas (máx 3 celdas)
        return allPieces.where((piece) {
          final shape = _getShapeForType(piece);
          final size = shape.fold(0, (sum, row) => sum + row.where((cell) => cell).length);
          return size <= 3;
        }).toList();
        
      case Difficulty.normal:
        // Piezas medianas (máx 4 celdas)
        return allPieces.where((piece) {
          final shape = _getShapeForType(piece);
          final size = shape.fold(0, (sum, row) => sum + row.where((cell) => cell).length);
          return size <= 4;
        }).toList();
        
      case Difficulty.hard:
        // Piezas grandes (hasta 5 celdas)
        return allPieces.where((piece) {
          final shape = _getShapeForType(piece);
          final size = shape.fold(0, (sum, row) => sum + row.where((cell) => cell).length);
          return size <= 5;
        }).toList();
        
      case Difficulty.expert:
      case Difficulty.master:
        // Todas las piezas disponibles
        return allPieces;
    }
  }
  
  // Obtener forma de pieza (auxiliar)
  static List<List<bool>> _getShapeForType(PieceType type) {
    switch (type) {
      case PieceType.square2x2:
        return [[true, true], [true, true]];
      case PieceType.lShape:
        return [[true, false], [true, false], [true, true]];
      case PieceType.lShapeInverse:
        return [[false, true], [false, true], [true, true]];
      case PieceType.line3:
        return [[true, true, true]];
      case PieceType.line2:
        return [[true, true]];
      case PieceType.line1x3:
        return [[true], [true], [true]];
      case PieceType.tShape:
        return [[true, true, true], [false, true, false]];
      case PieceType.sShape:
        return [[false, true, true], [true, true, false]];
      case PieceType.zShape:
        return [[true, true, false], [false, true, true]];
      case PieceType.single:
        return [[true]];
      case PieceType.lShapeLarge:
        return [[true, false, false], [true, false, false], [true, true, true]];
      case PieceType.cross:
        return [[false, true, false], [true, true, true], [false, true, false]];
      case PieceType.diagonal:
        return [[true, false, false], [false, true, false], [false, false, true]];
    }
  }
  
  // Obtener puntuación objetivo
  static int _getTargetScore(int levelNumber) {
    final difficulty = _getDifficulty(levelNumber);
    final baseScore = 1000;
    final levelMultiplier = levelNumber;
    
    switch (difficulty) {
      case Difficulty.easy:
        return baseScore + (levelNumber * 200);
      case Difficulty.normal:
        return baseScore * 2 + (levelNumber * 500);
      case Difficulty.hard:
        return baseScore * 3 + (levelNumber * 800);
      case Difficulty.expert:
        return baseScore * 5 + (levelNumber * 1200);
      case Difficulty.master:
        return baseScore * 8 + (levelNumber * 1500);
    }
  }
  
  // Obtener límite de tiempo
  static TimeLimit _getTimeLimit(int levelNumber) {
    final difficulty = _getDifficulty(levelNumber);
    
    switch (difficulty) {
      case Difficulty.easy:
      case Difficulty.normal:
        return TimeLimit.none;
      case Difficulty.hard:
        return TimeLimit.medium; // 3 minutos
      case Difficulty.expert:
        return TimeLimit.short; // 2 minutos
      case Difficulty.master:
        // Timer decreciente: 2min en lvl100, baja 5s cada 10 niveles
        final extraLevels = (levelNumber - 100);
        final deduction = (extraLevels ~/ 10) * 5;
        final totalSeconds = (120 - deduction).clamp(60, 120);
        return totalSeconds <= 90 ? TimeLimit.short : TimeLimit.medium;
    }
  }
  
  // Obtener desafío de color
  static ColorRestriction _getColorChallenge(int levelNumber) {
    final difficulty = _getDifficulty(levelNumber);
    final rng = Random(levelNumber * 42); // Semilla diferente
    
    switch (difficulty) {
      case Difficulty.easy:
      case Difficulty.normal:
        return ColorRestriction.none;
      case Difficulty.hard:
        // 30% probabilidad de desafío de color
        return rng.nextDouble() < 0.3 ? ColorRestriction.specific : ColorRestriction.none;
      case Difficulty.expert:
      case Difficulty.master:
        // Siempre activo
        return rng.nextDouble() < 0.7 ? ColorRestriction.specific : ColorRestriction.avoid;
    }
  }
  
  // Obtener color objetivo para restricción
  static String? _getTargetColor(int levelNumber) {
    final rng = Random(levelNumber * 99);
    final colors = GameConstants.blockColors;
    return colors[rng.nextInt(colors.length)];
  }
  
  // Verificar si hay celdas malditas
  static bool _hasCursedCells(int levelNumber) {
    final difficulty = _getDifficulty(levelNumber);
    return difficulty == Difficulty.expert || difficulty == Difficulty.master;
  }
  
  // Verificar si hay celdas positivas
  static bool _hasPositiveCells(int levelNumber) {
    final difficulty = _getDifficulty(levelNumber);
    return difficulty == Difficulty.master;
  }
  
  // Verificar si hay bloques fantasmas
  static bool _hasGhostBlocks(int levelNumber) {
    final difficulty = _getDifficulty(levelNumber);
    return difficulty == Difficulty.master;
  }
  
  // Obtener tamaño del tablero
  static int _getBoardSize(int levelNumber) {
    // Solo el capítulo 5 (bioma dome) tiene 9x9
    return 8;
  }
  
  // Obtener reglas especiales
  static Map<String, dynamic> _getSpecialRules(int levelNumber, Random rng) {
    final rules = <String, dynamic>{};
    final specialEvent = _getSpecialEvent(levelNumber);
    
    switch (specialEvent) {
      case SpecialEventType.challenge:
        // Objetivos específicos para niveles de reto
        final challengeTypes = [
          'clear_specific_color_lines',
          'reach_combo_target',
          'fill_board_percentage',
        ];
        rules['challengeType'] = challengeTypes[rng.nextInt(challengeTypes.length)];
        rules['challengeTarget'] = _getChallengeTarget(rules['challengeType'], rng);
        break;
        
      case SpecialEventType.boss:
        // Mecánicas de jefe
        final bossTypes = [
          'the_devourer', // Añade filas desde arriba
          'the_duplicator', // Duplica piezas
          'the_inverter', // Cambia colores
          'the_chaotic', // Rota tablero
        ];
        rules['bossType'] = bossTypes[(levelNumber ~/ 10) % bossTypes.length];
        rules['bossFrequency'] = _getBossFrequency(rules['bossType']);
        break;
        
      case SpecialEventType.milestone:
        // Configuración de hito
        rules['milestoneTitle'] = _getMilestoneTitle(levelNumber);
        rules['milestoneReward'] = _getMilestoneReward(levelNumber);
        break;
        
      case SpecialEventType.none:
        break;
    }
    
    // Reglas específicas de bioma
    final biome = _getBiome(levelNumber);
    switch (biome) {
      case Biome.volcano:
        rules['hotCellBonus'] = 2.0; // Puntos dobles
        break;
      case Biome.ocean:
        rules['currentFrequency'] = 15; // Cada 15 piezas
        break;
      case Biome.storm:
        rules['lightningFrequency'] = 5; // Cada 5 piezas
        break;
      case Biome.ice:
        rules['frozenCellMechanic'] = true;
        break;
      case Biome.void:
        rules['gravityInversion'] = true;
        rules['maxIntensity'] = true;
        break;
      default:
        break;
    }
    
    return rules;
  }
  
  // Obtener objetivo de desafío
  static int _getChallengeTarget(String challengeType, Random rng) {
    switch (challengeType) {
      case 'clear_specific_color_lines':
        return 8 + rng.nextInt(5); // 8-12 líneas
      case 'reach_combo_target':
        return 3 + rng.nextInt(3); // x3, x4, x5
      case 'fill_board_percentage':
        return 80; // 80% del tablero
      default:
        return 10;
    }
  }
  
  // Obtener frecuencia de jefe
  static int _getBossFrequency(String bossType) {
    switch (bossType) {
      case 'the_devourer':
        return 8; // Cada 8 piezas
      case 'the_duplicator':
        return 1; // Cada pieza
      case 'the_inverter':
        return 5; // Cada 5 líneas
      case 'the_chaotic':
        return 15; // Cada 15 piezas
      default:
        return 10;
    }
  }
  
  // Obtener título de hito
  static String _getMilestoneTitle(int levelNumber) {
    final titles = {
      25: '🌱 Aprendiz de Bloques',
      50: '🔨 Constructor Hábil',
      75: '⚡ Maestro del Combo',
      100: '💎 Arquitecto de Cristal',
      150: '🔥 Señor del Caos',
      200: '⭐ Leyenda Viviente',
      300: '🌌 El que Nunca Para',
      500: '👑 Eterno',
      999: '🎭 El Arquitecto',
    };
    
    return titles[levelNumber] ?? 'Hito Desbloqueado';
  }
  
  // Obtener recompensa de hito
  static int _getMilestoneReward(int levelNumber) {
    return 500 + (levelNumber ~/ 25) * 100;
  }
  
  // Generar nivel para modo historia
  static GeneratedLevel generateStoryLevel(int chapter, int levelInChapter) {
    final globalLevel = (chapter - 1) * GameConstants.levelsPerChapter + levelInChapter;
    final seed = globalLevel * 1000 + chapter * 100 + levelInChapter;
    final rng = Random(seed);
    
    // Niveles de historia tienen reglas específicas
    Biome biome;
    switch (chapter) {
      case 1:
        biome = Biome.garden;
        break;
      case 2:
        biome = Biome.caverns;
        break;
      case 3:
        biome = Biome.volcano;
        break;
      case 4:
        biome = Biome.ocean;
        break;
      case 5:
        biome = Biome.dome;
        break;
      default:
        biome = Biome.garden;
    }
    
    SpecialEventType specialEvent = SpecialEventType.none;
    if (levelInChapter == 11) {
      specialEvent = SpecialEventType.challenge;
    } else if (levelInChapter == 12) {
      specialEvent = SpecialEventType.boss;
    }
    
    Difficulty difficulty = Difficulty.easy;
    if (chapter >= 2) difficulty = Difficulty.normal;
    if (chapter >= 3) difficulty = Difficulty.hard;
    if (chapter >= 4) difficulty = Difficulty.expert;
    if (chapter >= 5) difficulty = Difficulty.master;
    
    return GeneratedLevel(
      levelNumber: globalLevel,
      biome: biome,
      difficulty: difficulty,
      specialEvent: specialEvent,
      boardObstacles: _generateStoryObstacles(chapter, levelInChapter, rng),
      allowedPieceTypes: _getStoryPiecePool(chapter, levelInChapter),
      targetScore: _getStoryTargetScore(chapter, levelInChapter),
      timeLimit: _getStoryTimeLimit(chapter, levelInChapter),
      colorRestriction: ColorRestriction.none,
      boardSize: chapter == 5 ? 9 : 8,
      specialRules: _getStorySpecialRules(chapter, levelInChapter, rng),
    );
  }
  
  // Generar obstáculos para modo historia
  static List<BoardObstacle> _generateStoryObstacles(int chapter, int levelInChapter, Random rng) {
    final obstacles = <BoardObstacle>[];
    
    // Capítulo 2: Cristales que requieren 2 limpiezas
    if (chapter == 2 && levelInChapter > 5) {
      final count = 2 + rng.nextInt(3);
      for (int i = 0; i < count; i++) {
        final x = rng.nextInt(8);
        final y = rng.nextInt(8);
        obstacles.add(BoardObstacle.crystal(x, y, health: 2));
      }
    }
    
    // Capítulo 3: Celdas calientes
    if (chapter == 3) {
      final count = 3 + rng.nextInt(4);
      for (int i = 0; i < count; i++) {
        final x = rng.nextInt(8);
        final y = rng.nextInt(8);
        obstacles.add(BoardObstacle.hot(x, y));
      }
    }
    
    // Capítulo 4: Bloques de memoria
    if (chapter == 4) {
      final count = 2 + rng.nextInt(3);
      for (int i = 0; i < count; i++) {
        final x = rng.nextInt(8);
        final y = rng.nextInt(8);
        obstacles.add(BoardObstacle.memory(x, y));
      }
    }
    
    // Capítulo 5: Mezcla de todo
    if (chapter == 5) {
      final types = [
        () => BoardObstacle.cursed(rng.nextInt(9), rng.nextInt(9)),
        () => BoardObstacle.positive(rng.nextInt(9), rng.nextInt(9)),
        () => BoardObstacle.ghost(rng.nextInt(9), rng.nextInt(9)),
      ];
      final count = 5 + rng.nextInt(5);
      for (int i = 0; i < count; i++) {
        obstacles.add(types[rng.nextInt(types.length)]());
      }
    }
    
    return obstacles;
  }
  
  // Obtener pool de piezas para modo historia
  static List<PieceType> _getStoryPiecePool(int chapter, int levelInChapter) {
    if (levelInChapter <= 3) {
      // Primeros niveles: solo piezas básicas
      return [
        PieceType.square2x2,
        PieceType.lShape,
        PieceType.lShapeInverse,
        PieceType.line3,
        PieceType.line2,
        PieceType.single,
      ];
    } else if (levelInChapter <= 8) {
      // Niveles medios: piezas intermedias
      return [
        PieceType.square2x2,
        PieceType.lShape,
        PieceType.lShapeInverse,
        PieceType.line3,
        PieceType.line2,
        PieceType.line1x3,
        PieceType.tShape,
        PieceType.sShape,
        PieceType.zShape,
        PieceType.single,
      ];
    } else {
      // Niveles avanzados: todas las piezas
      return PieceType.values;
    }
  }
  
  // Obtener puntuación objetivo para modo historia
  static int _getStoryTargetScore(int chapter, int levelInChapter) {
    final baseScore = 1000 * chapter;
    final levelBonus = levelInChapter * 200;
    return baseScore + levelBonus;
  }
  
  // Obtener límite de tiempo para modo historia
  static TimeLimit _getStoryTimeLimit(int chapter, int levelInChapter) {
    if (levelInChapter == 11) {
      // Niveles de reto tienen tiempo
      return TimeLimit.medium;
    }
    return TimeLimit.none;
  }
  
  // Obtener reglas especiales para modo historia
  static Map<String, dynamic> _getStorySpecialRules(int chapter, int levelInChapter, Random rng) {
    final rules = <String, dynamic>{};
    
    if (levelInChapter == 12) {
      // Niveles jefe tienen mecánicas específicas
      switch (chapter) {
        case 1:
          rules['bossType'] = 'florax';
          rules['addCorruptedBlocks'] = 2;
          rules['frequency'] = 6;
          break;
        case 2:
          rules['bossType'] = 'petra';
          rules['crystallizeCells'] = true;
          break;
        case 3:
          rules['bossType'] = 'ignix';
          rules['eruptionCells'] = 6;
          rules['eruptionFrequency'] = 10;
          break;
        case 4:
          rules['bossType'] = 'mareen';
          rules['memoryBlocks'] = 6;
          rules['currentFrequency'] = 8;
          break;
        case 5:
          rules['bossType'] = 'entropy';
          rules['phases'] = 3;
          rules['maxIntensity'] = true;
          break;
      }
    }
    
    return rules;
  }
}
