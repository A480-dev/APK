import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blockrush/models/generated_level.dart';
import 'package:blockrush/services/level_generator.dart';
import 'package:blockrush/services/storage_service.dart';
import 'package:blockrush/config/constants.dart';

// Estado del modo infinito
class EndlessState {
  final int currentLevel;
  final GeneratedLevel? currentGeneratedLevel;
  final int highestLevel;
  final int totalCoinsEarned;
  final int totalLinesCleared;
  final int totalGamesPlayed;
  final List<String> unlockedTitles;
  final bool isLoading;
  final String? error;
  
  const EndlessState({
    this.currentLevel = 1,
    this.currentGeneratedLevel,
    this.highestLevel = 1,
    this.totalCoinsEarned = 0,
    this.totalLinesCleared = 0,
    this.totalGamesPlayed = 0,
    this.unlockedTitles = const [],
    this.isLoading = false,
    this.error,
  });
  
  EndlessState copyWith({
    int? currentLevel,
    GeneratedLevel? currentGeneratedLevel,
    int? highestLevel,
    int? totalCoinsEarned,
    int? totalLinesCleared,
    int? totalGamesPlayed,
    List<String>? unlockedTitles,
    bool? isLoading,
    String? error,
  }) {
    return EndlessState(
      currentLevel: currentLevel ?? this.currentLevel,
      currentGeneratedLevel: currentGeneratedLevel ?? this.currentGeneratedLevel,
      highestLevel: highestLevel ?? this.highestLevel,
      totalCoinsEarned: totalCoinsEarned ?? this.totalCoinsEarned,
      totalLinesCleared: totalLinesCleared ?? this.totalLinesCleared,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      unlockedTitles: unlockedTitles ?? this.unlockedTitles,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class LevelProvider extends StateNotifier<EndlessState> {
  LevelProvider() : super(const EndlessState()) {
    _loadEndlessProgress();
  }
  
  // Cargar progreso del modo infinito
  Future<void> _loadEndlessProgress() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final highestLevel = StorageService.getEndlessHighLevel();
      final unlockedTitles = StorageService.getUnlockedMilestones();
      
      state = state.copyWith(
        highestLevel: highestLevel,
        unlockedTitles: unlockedTitles,
        isLoading: false,
      );
      
      // Generar nivel actual
      generateLevel(state.currentLevel);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error cargando progreso: $e',
      );
    }
  }
  
  // Generar nivel para el modo infinito
  Future<void> generateLevel(int levelNumber) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final generatedLevel = LevelGenerator.generate(levelNumber);
      
      state = state.copyWith(
        currentLevel: levelNumber,
        currentGeneratedLevel: generatedLevel,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error generando nivel: $e',
      );
    }
  }
  
  // Avanzar al siguiente nivel
  Future<void> advanceToNextLevel({
    required int score,
    required int coinsEarned,
    required int linesCleared,
  }) async {
    try {
      final nextLevel = state.currentLevel + 1;
      
      // Actualizar estadísticas
      final newTotalCoins = state.totalCoinsEarned + coinsEarned;
      final newTotalLines = state.totalLinesCleared + linesCleared;
      final newGamesPlayed = state.totalGamesPlayed + 1;
      
      // Verificar si es nuevo récord
      int newHighestLevel = state.highestLevel;
      if (nextLevel > state.highestLevel) {
        newHighestLevel = nextLevel;
        await StorageService.setEndlessHighLevel(newHighestLevel);
      }
      
      // Verificar hitos desbloqueados
      final newTitles = List<String>.from(state.unlockedTitles);
      final unlockedTitle = _checkMilestoneUnlock(nextLevel);
      if (unlockedTitle != null && !newTitles.contains(unlockedTitle)) {
        newTitles.add(unlockedTitle);
        await StorageService.setUnlockedMilestones(newTitles);
      }
      
      // Generar siguiente nivel
      await generateLevel(nextLevel);
      
      // Actualizar estado
      state = state.copyWith(
        totalCoinsEarned: newTotalCoins,
        totalLinesCleared: newTotalLines,
        totalGamesPlayed: newGamesPlayed,
        highestLevel: newHighestLevel,
        unlockedTitles: newTitles,
      );
    } catch (e) {
      state = state.copyWith(error: 'Error avanzando de nivel: $e');
    }
  }
  
  // Reiniciar el modo infinito
  Future<void> resetProgress() async {
    try {
      await StorageService.setEndlessHighLevel(1);
      await StorageService.setUnlockedMilestones([]);
      
      state = const EndlessState();
      await generateLevel(1);
    } catch (e) {
      state = state.copyWith(error: 'Error reiniciando progreso: $e');
    }
  }
  
  // Verificar desbloqueo de hitos
  String? _checkMilestoneUnlock(int level) {
    switch (level) {
      case 25:
        return '🌱 Aprendiz de Bloques';
      case 50:
        return '🔨 Constructor Hábil';
      case 75:
        return '⚡ Maestro del Combo';
      case 100:
        return '💎 Arquitecto de Cristal';
      case 150:
        return '🔥 Señor del Caos';
      case 200:
        return '⭐ Leyenda Viviente';
      case 300:
        return '🌌 El que Nunca Para';
      case 500:
        return '👑 Eterno';
      case 999:
        return '🎭 El Arquitecto';
      default:
        return null;
    }
  }
  
  // Obtener título actual del jugador
  String getCurrentTitle() {
    if (state.unlockedTitles.isEmpty) {
      return 'Principiante';
    }
    
    // Devolver el título más alto desbloqueado
    final titles = [
      '🎭 El Arquitecto',
      '👑 Eterno',
      '🌌 El que Nunca Para',
      '⭐ Leyenda Viviente',
      '🔥 Señor del Caos',
      '💎 Arquitecto de Cristal',
      '⚡ Maestro del Combo',
      '🔨 Constructor Hábil',
      '🌱 Aprendiz de Bloques',
    ];
    
    for (final title in titles) {
      if (state.unlockedTitles.contains(title)) {
        return title;
      }
    }
    
    return 'Principiante';
  }
  
  // Obtener información del nivel actual
  LevelInfo? getCurrentLevelInfo() {
    if (state.currentGeneratedLevel == null) return null;
    
    final level = state.currentGeneratedLevel!;
    return LevelInfo(
      levelNumber: level.levelNumber,
      title: level.title,
      description: level.description,
      biome: level.biome,
      difficulty: level.difficulty,
      specialEvent: level.specialEvent,
      targetScore: level.targetScore,
      timeLimit: level.timeLimit,
      colorRestriction: level.colorRestriction,
      hasCursedCells: level.hasCursedCells,
      hasPositiveCells: level.hasPositiveCells,
      hasGhostBlocks: level.hasGhostBlocks,
      boardSize: level.boardSize,
      allowedPieceTypes: level.allowedPieceTypes,
      boardObstacles: level.boardObstacles,
      specialRules: level.specialRules,
      biomeColors: level.getBiomeColors(),
      baseReward: level.baseReward,
      isBossLevel: level.isBossLevel,
      isChallengeLevel: level.isChallengeLevel,
      isMilestone: level.isMilestone,
    );
  }
  
  // Obtener estadísticas del modo infinito
  EndlessStats getStats() {
    return EndlessStats(
      currentLevel: state.currentLevel,
      highestLevel: state.highestLevel,
      totalCoinsEarned: state.totalCoinsEarned,
      totalLinesCleared: state.totalLinesCleared,
      totalGamesPlayed: state.totalGamesPlayed,
      unlockedTitles: state.unlockedTitles,
      currentTitle: getCurrentTitle(),
      averageScore: state.totalGamesPlayed > 0 
          ? (state.totalCoinsEarned * 10) ~/ state.totalGamesPlayed 
          : 0,
    );
  }
  
  // Verificar si el nivel actual está disponible
  bool isLevelAvailable(int levelNumber) {
    return levelNumber <= (state.highestLevel + 1);
  }
  
  // Obtener progreso hacia el siguiente hito
  MilestoneProgress getNextMilestone() {
    final milestones = [
      25, 50, 75, 100, 150, 200, 300, 500, 999,
    ];
    
    for (final milestone in milestones) {
      if (state.highestLevel < milestone) {
        final progress = state.highestLevel / milestone;
        final previousMilestone = milestones.indexOf(milestone) > 0 
            ? milestones[milestones.indexOf(milestone) - 1]
            : 0;
        
        return MilestoneProgress(
          milestone: milestone,
          title: _checkMilestoneUnlock(milestone) ?? '',
          currentLevel: state.highestLevel,
          previousMilestone: previousMilestone,
          progress: progress,
          levelsToGo: milestone - state.highestLevel,
          isUnlocked: false,
        );
      }
    }
    
    // Todos los hitos desbloqueados
    return MilestoneProgress(
      milestone: 999,
      title: '🎭 El Arquitecto',
      currentLevel: state.highestLevel,
      previousMilestone: 500,
      progress: 1.0,
      levelsToGo: 0,
      isUnlocked: true,
    );
  }
  
  // Limpiar errores
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}

// Información del nivel
class LevelInfo {
  final int levelNumber;
  final String title;
  final String description;
  final Biome biome;
  final Difficulty difficulty;
  final SpecialEventType specialEvent;
  final int targetScore;
  final TimeLimit timeLimit;
  final ColorRestriction colorRestriction;
  final bool hasCursedCells;
  final bool hasPositiveCells;
  final bool hasGhostBlocks;
  final int boardSize;
  final List<PieceType> allowedPieceTypes;
  final List<BoardObstacle> boardObstacles;
  final Map<String, dynamic> specialRules;
  final List<String> biomeColors;
  final int baseReward;
  final bool isBossLevel;
  final bool isChallengeLevel;
  final bool isMilestone;
  
  const LevelInfo({
    required this.levelNumber,
    required this.title,
    required this.description,
    required this.biome,
    required this.difficulty,
    required this.specialEvent,
    required this.targetScore,
    required this.timeLimit,
    required this.colorRestriction,
    required this.hasCursedCells,
    required this.hasPositiveCells,
    required this.hasGhostBlocks,
    required this.boardSize,
    required this.allowedPieceTypes,
    required this.boardObstacles,
    required this.specialRules,
    required this.biomeColors,
    required this.baseReward,
    required this.isBossLevel,
    required this.isChallengeLevel,
    required this.isMilestone,
  });
}

// Estadísticas del modo infinito
class EndlessStats {
  final int currentLevel;
  final int highestLevel;
  final int totalCoinsEarned;
  final int totalLinesCleared;
  final int totalGamesPlayed;
  final List<String> unlockedTitles;
  final String currentTitle;
  final int averageScore;
  
  const EndlessStats({
    required this.currentLevel,
    required this.highestLevel,
    required this.totalCoinsEarned,
    required this.totalLinesCleared,
    required this.totalGamesPlayed,
    required this.unlockedTitles,
    required this.currentTitle,
    required this.averageScore,
  });
}

// Progreso hacia hito
class MilestoneProgress {
  final int milestone;
  final String title;
  final int currentLevel;
  final int previousMilestone;
  final double progress;
  final int levelsToGo;
  final bool isUnlocked;
  
  const MilestoneProgress({
    required this.milestone,
    required this.title,
    required this.currentLevel,
    required this.previousMilestone,
    required this.progress,
    required this.levelsToGo,
    required this.isUnlocked,
  });
}

// Providers
final levelProvider = StateNotifierProvider<LevelProvider, EndlessState>((ref) {
  return LevelProvider();
});

final currentLevelInfoProvider = Provider<LevelInfo?>((ref) {
  return ref.watch(levelProvider.notifier).getCurrentLevelInfo();
});

final endlessStatsProvider = Provider<EndlessStats>((ref) {
  return ref.watch(levelProvider.notifier).getStats();
});

final nextMilestoneProvider = Provider<MilestoneProgress>((ref) {
  return ref.watch(levelProvider.notifier).getNextMilestone();
});
