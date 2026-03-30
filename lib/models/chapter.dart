import 'package:blockrush/models/generated_level.dart';
import 'package:blockrush/config/constants.dart';

enum ChapterStatus {
  locked,      // 🔒 No disponible
  available,   // ▶️ Disponible para jugar
  inProgress,  // ⏳ En progreso
  completed,   // ⭐ Completado
  perfect,     // 👑 Perfecto (todas las estrellas)
}

class Chapter {
  final int id;
  final String title;
  final String world;
  final String guardian;
  final Biome biome;
  final ChapterStatus status;
  final List<int> completedLevels;
  final List<int> levelStars;
  final List<String> unlockedSkins;
  final int totalCoinsEarned;
  final bool bossDefeated;
  final bool dialoguesSeen;
  final DateTime? completionDate;
  final Map<String, dynamic> customData;
  
  const Chapter({
    required this.id,
    required this.title,
    required this.world,
    required this.guardian,
    required this.biome,
    required this.status,
    this.completedLevels = const [],
    this.levelStars = const [],
    this.unlockedSkins = const [],
    this.totalCoinsEarned = 0,
    this.bossDefeated = false,
    this.dialoguesSeen = false,
    this.completionDate,
    this.customData = const {},
  });
  
  // Obtener el número total de niveles en el capítulo
  int get totalLevels => GameConstants.levelsPerChapter;
  
  // Obtener el número de niveles normales
  int get normalLevels => 10;
  
  // Obtener el número de niveles especiales
  int get specialLevels => 2; // 1 reto + 1 jefe
  
  // Obtener el progreso del capítulo (0.0 a 1.0)
  double get progress {
    if (totalLevels == 0) return 0.0;
    return completedLevels.length / totalLevels;
  }
  
  // Obtener el número de estrellas totales
  int get totalStars {
    return levelStars.fold(0, (sum, stars) => sum + stars);
  }
  
  // Obtener el número máximo de estrellas posibles
  int get maxStars => totalLevels * 3;
  
  // Obtener el porcentaje de estrellas
  double get starPercentage {
    if (maxStars == 0) return 0.0;
    return totalStars / maxStars;
  }
  
  // Verificar si el capítulo está disponible
  bool get isAvailable => status == ChapterStatus.available || status == ChapterStatus.inProgress;
  
  // Verificar si el capítulo está completado
  bool get isCompleted => status == ChapterStatus.completed || status == ChapterStatus.perfect;
  
  // Verificar si el capítulo es perfecto
  bool get isPerfect => status == ChapterStatus.perfect;
  
  // Verificar si el jefe está disponible
  bool get isBossAvailable {
    return completedLevels.length >= normalLevels && !bossDefeated;
  }
  
  // Verificar si el nivel está disponible
  bool isLevelAvailable(int levelNumber) {
    if (levelNumber < 1 || levelNumber > totalLevels) return false;
    
    // Nivel 1 siempre disponible si el capítulo está disponible
    if (levelNumber == 1) return isAvailable;
    
    // Niveles 2-10: el anterior debe estar completado
    if (levelNumber <= normalLevels) {
      return completedLevels.contains(levelNumber - 1);
    }
    
    // Nivel 11 (reto): todos los niveles normales deben estar completados
    if (levelNumber == normalLevels + 1) {
      return completedLevels.length >= normalLevels;
    }
    
    // Nivel 12 (jefe): el nivel de reto debe estar completado
    if (levelNumber == totalLevels) {
      return completedLevels.contains(normalLevels + 1);
    }
    
    return false;
  }
  
  // Verificar si el nivel está completado
  bool isLevelCompleted(int levelNumber) {
    return completedLevels.contains(levelNumber);
  }
  
  // Obtener las estrellas de un nivel
  int getLevelStars(int levelNumber) {
    final index = levelNumber - 1;
    if (index >= 0 && index < levelStars.length) {
      return levelStars[index];
    }
    return 0;
  }
  
  // Obtener el tipo de nivel
  LevelType getLevelType(int levelNumber) {
    if (levelNumber <= normalLevels) {
      return LevelType.normal;
    } else if (levelNumber == normalLevels + 1) {
      return LevelType.challenge;
    } else if (levelNumber == totalLevels) {
      return LevelType.boss;
    }
    return LevelType.normal;
  }
  
  // Completar un nivel
  Chapter completeLevel(int levelNumber, int stars, int coinsEarned) {
    final newCompletedLevels = List<int>.from(completedLevels);
    if (!newCompletedLevels.contains(levelNumber)) {
      newCompletedLevels.add(levelNumber);
      newCompletedLevels.sort();
    }
    
    final newLevelStars = List<int>.from(levelStars);
    while (newLevelStars.length < levelNumber) {
      newLevelStars.add(0);
    }
    newLevelStars[levelNumber - 1] = stars;
    
    // Actualizar estado
    ChapterStatus newStatus = status;
    if (newCompletedLevels.length == totalLevels) {
      if (totalStars >= maxStars) {
        newStatus = ChapterStatus.perfect;
      } else {
        newStatus = ChapterStatus.completed;
      }
    } else if (status == ChapterStatus.available) {
      newStatus = ChapterStatus.inProgress;
    }
    
    return copyWith(
      status: newStatus,
      completedLevels: newCompletedLevels,
      levelStars: newLevelStars,
      totalCoinsEarned: totalCoinsEarned + coinsEarned,
      bossDefeated: levelNumber == totalLevels ? true : bossDefeated,
      completionDate: newStatus == ChapterStatus.completed || newStatus == ChapterStatus.perfect
          ? DateTime.now()
          : completionDate,
    );
  }
  
  // Desbloquear un skin
  Chapter unlockSkin(String skinName) {
    final newSkins = List<String>.from(unlockedSkins);
    if (!newSkins.contains(skinName)) {
      newSkins.add(skinName);
    }
    
    return copyWith(unlockedSkins: newSkins);
  }
  
  // Marcar diálogos como vistos
  Chapter markDialoguesSeen() {
    return copyWith(dialoguesSeen: true);
  }
  
  // Obtener recompensas del capítulo
  ChapterRewards getRewards() {
    if (!isCompleted) {
      return ChapterRewards(
        coins: 0,
        powerUps: const [],
        skins: const [],
        specialRewards: const [],
      );
    }
    
    final coins = 300 + (id * 100); // 300, 400, 500, 600, 700
    final powerUps = <String>[];
    final skins = <String>[];
    final specialRewards = <String>[];
    
    // Power-ups por capítulo
    switch (id) {
      case 1:
        powerUps.addAll(['bomb', 'bomb']);
        skins.add('Lumen Dorado');
        break;
      case 2:
        powerUps.addAll(['shuffle', 'bomb']);
        skins.add('Kira');
        break;
      case 3:
        powerUps.addAll(['wildcard', 'wildcard']);
        skins.add('Llama Eterna');
        break;
      case 4:
        powerUps.addAll(['bomb', 'shuffle', 'undo']);
        skins.add('Marea');
        break;
      case 5:
        powerUps.addAll(['bomb', 'shuffle', 'undo', 'wildcard']);
        skins.addAll(['El Arquitecto', 'La Entropía']);
        specialRewards.add('Restaurador del Universo');
        break;
    }
    
    return ChapterRewards(
      coins: coins,
      powerUps: powerUps,
      skins: skins,
      specialRewards: specialRewards,
    );
  }
  
  // Copiar con modificaciones
  Chapter copyWith({
    int? id,
    String? title,
    String? world,
    String? guardian,
    Biome? biome,
    ChapterStatus? status,
    List<int>? completedLevels,
    List<int>? levelStars,
    List<String>? unlockedSkins,
    int? totalCoinsEarned,
    bool? bossDefeated,
    bool? dialoguesSeen,
    DateTime? completionDate,
    Map<String, dynamic>? customData,
  }) {
    return Chapter(
      id: id ?? this.id,
      title: title ?? this.title,
      world: world ?? this.world,
      guardian: guardian ?? this.guardian,
      biome: biome ?? this.biome,
      status: status ?? this.status,
      completedLevels: completedLevels ?? this.completedLevels,
      levelStars: levelStars ?? this.levelStars,
      unlockedSkins: unlockedSkins ?? this.unlockedSkins,
      totalCoinsEarned: totalCoinsEarned ?? this.totalCoinsEarned,
      bossDefeated: bossDefeated ?? this.bossDefeated,
      dialoguesSeen: dialoguesSeen ?? this.dialoguesSeen,
      completionDate: completionDate ?? this.completionDate,
      customData: customData ?? this.customData,
    );
  }
  
  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'world': world,
      'guardian': guardian,
      'biome': biome.name,
      'status': status.name,
      'completedLevels': completedLevels,
      'levelStars': levelStars,
      'unlockedSkins': unlockedSkins,
      'totalCoinsEarned': totalCoinsEarned,
      'bossDefeated': bossDefeated,
      'dialoguesSeen': dialoguesSeen,
      'completionDate': completionDate?.toIso8601String(),
      'customData': customData,
    };
  }
  
  // Crear desde JSON
  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      title: json['title'],
      world: json['world'],
      guardian: json['guardian'],
      biome: Biome.values.firstWhere((e) => e.name == json['biome']),
      status: ChapterStatus.values.firstWhere((e) => e.name == json['status']),
      completedLevels: List<int>.from(json['completedLevels'] ?? []),
      levelStars: List<int>.from(json['levelStars'] ?? []),
      unlockedSkins: List<String>.from(json['unlockedSkins'] ?? []),
      totalCoinsEarned: json['totalCoinsEarned'] ?? 0,
      bossDefeated: json['bossDefeated'] ?? false,
      dialoguesSeen: json['dialoguesSeen'] ?? false,
      completionDate: json['completionDate'] != null
          ? DateTime.parse(json['completionDate'])
          : null,
      customData: Map<String, dynamic>.from(json['customData'] ?? {}),
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Chapter && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'Chapter($id: $title - $status)';
  }
}

enum LevelType {
  normal,
  challenge,
  boss,
}

class ChapterRewards {
  final int coins;
  final List<String> powerUps;
  final List<String> skins;
  final List<String> specialRewards;
  
  const ChapterRewards({
    required this.coins,
    required this.powerUps,
    required this.skins,
    required this.specialRewards,
  });
  
  // Obtener descripción de recompensas
  String get description {
    final parts = <String>[];
    
    if (coins > 0) {
      parts.add('$coins monedas');
    }
    
    if (powerUps.isNotEmpty) {
      parts.add('${powerUps.length} power-ups');
    }
    
    if (skins.isNotEmpty) {
      parts.add('${skins.length} skins');
    }
    
    if (specialRewards.isNotEmpty) {
      parts.add(specialRewards.join(', '));
    }
    
    return parts.join(', ');
  }
}
