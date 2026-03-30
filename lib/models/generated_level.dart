import 'package:blockrush/models/piece.dart';
import 'package:blockrush/config/constants.dart';

enum Biome {
  garden,      // 🌿 Niveles 1-24
  caverns,     // 🏔️ Niveles 25-49
  volcano,     // 🔥 Niveles 50-74
  ocean,       // 🌊 Niveles 75-99
  storm,       // ⚡ Niveles 100-124
  ice,         // ❄️ Niveles 125-149
  void,        // 🌌 Niveles 150+
  dome,        // 🏛️ Bioma especial del capítulo 5
}

enum SpecialEventType {
  none,
  challenge,   // Nivel múltiplo de 5
  boss,        // Nivel múltiplo de 10
  milestone,   // Nivel múltiplo de 25
}

enum Difficulty {
  easy,        // Niveles 1-10
  normal,      // Niveles 11-25
  hard,        // Niveles 26-50
  expert,      // Niveles 51-100
  master,      // Niveles 101+
}

enum ColorRestriction {
  none,
  specific,    // Limpiar X líneas de un color específico
  avoid,       // No usar un color específico
  rainbow,     // Solo usar colores del arcoíris
}

enum TimeLimit {
  none,
  short,       // 2 minutos
  medium,      // 3 minutos
  long,        // 5 minutos
}

class GeneratedLevel {
  final int levelNumber;
  final Biome biome;
  final Difficulty difficulty;
  final SpecialEventType specialEvent;
  final List<BoardObstacle> boardObstacles;
  final List<PieceType> allowedPieceTypes;
  final int targetScore;
  final TimeLimit timeLimit;
  final ColorRestriction colorRestriction;
  final String? targetColorHex;
  final bool hasCursedCells;
  final bool hasPositiveCells;
  final bool hasGhostBlocks;
  final int boardSize;
  final Map<String, dynamic> specialRules;
  
  const GeneratedLevel({
    required this.levelNumber,
    required this.biome,
    required this.difficulty,
    required this.specialEvent,
    required this.boardObstacles,
    required this.allowedPieceTypes,
    required this.targetScore,
    required this.timeLimit,
    required this.colorRestriction,
    this.targetColorHex,
    this.hasCursedCells = false,
    this.hasPositiveCells = false,
    this.hasGhostBlocks = false,
    this.boardSize = 8,
    this.specialRules = const {},
  });
  
  // Obtener título del nivel
  String get title {
    switch (specialEvent) {
      case SpecialEventType.challenge:
        return 'NIVEL RETO';
      case SpecialEventType.boss:
        return 'NIVEL JEFE';
      case SpecialEventType.milestone:
        return 'HITO DESBLOQUEADO';
      case SpecialEventType.none:
        return 'Nivel $levelNumber';
    }
  }
  
  // Obtener descripción del nivel
  String get description {
    final parts = <String>[];
    
    // Bioma
    parts.add(_getBiomeName());
    
    // Dificultad
    parts.add(_getDifficultyName());
    
    // Evento especial
    if (specialEvent != SpecialEventType.none) {
      parts.add(_getSpecialEventName());
    }
    
    // Restricciones
    if (colorRestriction != ColorRestriction.none) {
      parts.add(_getColorRestrictionName());
    }
    
    if (timeLimit != TimeLimit.none) {
      parts.add(_getTimeLimitName());
    }
    
    return parts.join(' • ');
  }
  
  // Obtener colores del bioma
  List<String> getBiomeColors() {
    switch (biome) {
      case Biome.garden:
        return ['#4CAF50', '#FFD700', '#8BC34A', '#CDDC39'];
      case Biome.caverns:
        return ['#2196F3', '#607D8B', '#90A4AE', '#B0BEC5'];
      case Biome.volcano:
        return ['#FF5722', '#FF9800', '#FFC107', '#FF5722'];
      case Biome.ocean:
        return ['#00BCD4', '#009688', '#4DD0E1', '#26C6DA'];
      case Biome.storm:
        return ['#9C27B0', '#FFD700', '#E91E63', '#FFEB3B'];
      case Biome.ice:
        return ['#E3F2FD', '#BBDEFB', '#90CAF9', '#64B5F6'];
      case Biome.void:
        return GameConstants.blockColors; // Todos los colores
      case Biome.dome:
        return ['#FFD700', '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4'];
    }
  }
  
  // Obtener tiempo límite en segundos
  int? getTimeLimitSeconds() {
    switch (timeLimit) {
      case TimeLimit.short:
        return 120; // 2 minutos
      case TimeLimit.medium:
        return 180; // 3 minutos
      case TimeLimit.long:
        return 300; // 5 minutos
      case TimeLimit.none:
        return null;
    }
  }
  
  // Verificar si es nivel de jefe
  bool get isBossLevel => specialEvent == SpecialEventType.boss;
  
  // Verificar si es nivel de reto
  bool get isChallengeLevel => specialEvent == SpecialEventType.challenge;
  
  // Verificar si es hito
  bool get isMilestone => specialEvent == SpecialEventType.milestone;
  
  // Obtener recompensa base
  int get baseReward {
    int reward = 50;
    
    // Bonus por dificultad
    switch (difficulty) {
      case Difficulty.easy:
        reward += 0;
      case Difficulty.normal:
        reward += 25;
      case Difficulty.hard:
        reward += 50;
      case Difficulty.expert:
        reward += 100;
      case Difficulty.master:
        reward += 200;
    }
    
    // Bonus por evento especial
    switch (specialEvent) {
      case SpecialEventType.challenge:
        reward += 100;
      case SpecialEventType.boss:
        reward += 200;
      case SpecialEventType.milestone:
        reward += 500;
      case SpecialEventType.none:
        break;
    }
    
    return reward;
  }
  
  // Métodos privados para nombres
  String _getBiomeName() {
    switch (biome) {
      case Biome.garden:
        return 'Jardines del Origen';
      case Biome.caverns:
        return 'Cavernas de Cristal';
      case Biome.volcano:
        return 'Cataratas de Magma';
      case Biome.ocean:
        return 'Océano Eterno';
      case Biome.storm:
        return 'Cúpula Eléctrica';
      case Biome.ice:
        return 'Tundra Silenciosa';
      case Biome.void:
        return 'El Espacio entre Todo';
      case Biome.dome:
        return 'El Trono de la Entropía';
    }
  }
  
  String _getDifficultyName() {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Fácil';
      case Difficulty.normal:
        return 'Normal';
      case Difficulty.hard:
        return 'Difícil';
      case Difficulty.expert:
        return 'Experto';
      case Difficulty.master:
        return 'Maestro';
    }
  }
  
  String _getSpecialEventName() {
    switch (specialEvent) {
      case SpecialEventType.challenge:
        return 'Reto Especial';
      case SpecialEventType.boss:
        return 'Enfrentamiento';
      case SpecialEventType.milestone:
        return 'Hito Épico';
      case SpecialEventType.none:
        return '';
    }
  }
  
  String _getColorRestrictionName() {
    switch (colorRestriction) {
      case ColorRestriction.specific:
        return 'Restricción de Color';
      case ColorRestriction.avoid:
        return 'Color Prohibido';
      case ColorRestriction.rainbow:
        return 'Arcoíris';
      case ColorRestriction.none:
        return '';
    }
  }
  
  String _getTimeLimitName() {
    switch (timeLimit) {
      case TimeLimit.short:
        return 'Contrarreloj';
      case TimeLimit.medium:
        return 'Tiempo Limitado';
      case TimeLimit.long:
        return 'Maratón';
      case TimeLimit.none:
        return '';
    }
  }
  
  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'levelNumber': levelNumber,
      'biome': biome.name,
      'difficulty': difficulty.name,
      'specialEvent': specialEvent.name,
      'boardObstacles': boardObstacles.map((o) => o.toJson()).toList(),
      'allowedPieceTypes': allowedPieceTypes.map((t) => t.name).toList(),
      'targetScore': targetScore,
      'timeLimit': timeLimit.name,
      'colorRestriction': colorRestriction.name,
      'targetColorHex': targetColorHex,
      'hasCursedCells': hasCursedCells,
      'hasPositiveCells': hasPositiveCells,
      'hasGhostBlocks': hasGhostBlocks,
      'boardSize': boardSize,
      'specialRules': specialRules,
    };
  }
  
  // Crear desde JSON
  factory GeneratedLevel.fromJson(Map<String, dynamic> json) {
    return GeneratedLevel(
      levelNumber: json['levelNumber'],
      biome: Biome.values.firstWhere((e) => e.name == json['biome']),
      difficulty: Difficulty.values.firstWhere((e) => e.name == json['difficulty']),
      specialEvent: SpecialEventType.values.firstWhere((e) => e.name == json['specialEvent']),
      boardObstacles: (json['boardObstacles'] as List<dynamic>?)
          ?.map((o) => BoardObstacle.fromJson(o as Map<String, dynamic>))
          .toList() ?? [],
      allowedPieceTypes: (json['allowedPieceTypes'] as List<dynamic>?)
          ?.map((t) => PieceType.values.firstWhere((e) => e.name == t))
          .toList() ?? [],
      targetScore: json['targetScore'] ?? 1000,
      timeLimit: TimeLimit.values.firstWhere((e) => e.name == json['timeLimit']),
      colorRestriction: ColorRestriction.values.firstWhere((e) => e.name == json['colorRestriction']),
      targetColorHex: json['targetColorHex'],
      hasCursedCells: json['hasCursedCells'] ?? false,
      hasPositiveCells: json['hasPositiveCells'] ?? false,
      hasGhostBlocks: json['hasGhostBlocks'] ?? false,
      boardSize: json['boardSize'] ?? 8,
      specialRules: Map<String, dynamic>.from(json['specialRules'] ?? {}),
    );
  }
}

class BoardObstacle {
  final int x;
  final int y;
  final ObstacleType type;
  final String? colorHex;
  final int? health; // Para obstáculos que requieren múltiples limpiezas
  final Map<String, dynamic>? properties;
  
  const BoardObstacle({
    required this.x,
    required this.y,
    required this.type,
    this.colorHex,
    this.health,
    this.properties,
  });
  
  // Tipos de obstáculos
  static BoardObstacle blocked(int x, int y) {
    return BoardObstacle(
      x: x,
      y: y,
      type: ObstacleType.blocked,
    );
  }
  
  static BoardObstacle crystal(int x, int y, {int health = 2}) {
    return BoardObstacle(
      x: x,
      y: y,
      type: ObstacleType.crystal,
      health: health,
    );
  }
  
  static BoardObstacle hot(int x, int y) {
    return BoardObstacle(
      x: x,
      y: y,
      type: ObstacleType.hot,
    );
  }
  
  static BoardObstacle cursed(int x, int y) {
    return BoardObstacle(
      x: x,
      y: y,
      type: ObstacleType.cursed,
    );
  }
  
  static BoardObstacle positive(int x, int y) {
    return BoardObstacle(
      x: x,
      y: y,
      type: ObstacleType.positive,
    );
  }
  
  static BoardObstacle ghost(int x, int y) {
    return BoardObstacle(
      x: x,
      y: y,
      type: ObstacleType.ghost,
    );
  }
  
  static BoardObstacle memory(int x, int y, {String? colorHex}) {
    return BoardObstacle(
      x: x,
      y: y,
      type: ObstacleType.memory,
      colorHex: colorHex,
    );
  }
  
  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'type': type.name,
      'colorHex': colorHex,
      'health': health,
      'properties': properties,
    };
  }
  
  // Crear desde JSON
  factory BoardObstacle.fromJson(Map<String, dynamic> json) {
    return BoardObstacle(
      x: json['x'],
      y: json['y'],
      type: ObstacleType.values.firstWhere((e) => e.name == json['type']),
      colorHex: json['colorHex'],
      health: json['health'],
      properties: json['properties'],
    );
  }
}

enum ObstacleType {
  blocked,    // Celda normal bloqueada
  crystal,    // Requiere múltiples limpiezas
  hot,        // Da puntos dobles
  cursed,     // Elimina una pieza al colocar sobre ella
  positive,   // Da puntos triples
  ghost,      // Solo se elimina con bomba
  memory,     // Bloque de memoria (océano)
}
