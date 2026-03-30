import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blockrush/models/dialogue_line.dart';
import 'package:blockrush/models/chapter.dart';
import 'package:blockrush/services/story_service.dart';
import 'package:blockrush/config/story_data.dart';
import 'package:blockrush/models/generated_level.dart';

// Información del nivel para modo historia
class StoryLevelInfo {
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
  
  const StoryLevelInfo({
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

// Estado del modo historia
class StoryState {
  final int currentChapter;
  final int currentLevel;
  final List<Chapter> chapters;
  final List<String> unlockedSkins;
  final double architectCompletion;
  final bool isInCutscene;
  final List<DialogueLine>? activeDialogue;
  final bool isLoading;
  final String? error;
  
  const StoryState({
    this.currentChapter = 1,
    this.currentLevel = 1,
    this.chapters = const [],
    this.unlockedSkins = const [],
    this.architectCompletion = 0.0,
    this.isInCutscene = false,
    this.activeDialogue,
    this.isLoading = false,
    this.error,
  });
  
  StoryState copyWith({
    int? currentChapter,
    int? currentLevel,
    List<Chapter>? chapters,
    List<String>? unlockedSkins,
    double? architectCompletion,
    bool? isInCutscene,
    List<DialogueLine>? activeDialogue,
    bool? isLoading,
    String? error,
  }) {
    return StoryState(
      currentChapter: currentChapter ?? this.currentChapter,
      currentLevel: currentLevel ?? this.currentLevel,
      chapters: chapters ?? this.chapters,
      unlockedSkins: unlockedSkins ?? this.unlockedSkins,
      architectCompletion: architectCompletion ?? this.architectCompletion,
      isInCutscene: isInCutscene ?? this.isInCutscene,
      activeDialogue: activeDialogue ?? this.activeDialogue,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class StoryProvider extends StateNotifier<StoryState> {
  StoryProvider() : super(const StoryState()) {
    _loadStoryProgress();
  }
  
  // Cargar progreso de la historia
  Future<void> _loadStoryProgress() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final progress = StoryService.getStoryProgress();
      
      state = state.copyWith(
        currentChapter: progress.currentChapter,
        currentLevel: progress.currentLevel,
        chapters: progress.chapters,
        unlockedSkins: progress.unlockedSkins,
        architectCompletion: progress.architectCompletion,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error cargando progreso: $e',
      );
    }
  }
  
  // Iniciar capítulo
  Future<void> startChapter(int chapterId) async {
    if (!StoryService.canAccessChapter(chapterId)) {
      state = state.copyWith(error: 'Capítulo no disponible');
      return;
    }
    
    state = state.copyWith(
      currentChapter: chapterId,
      currentLevel: 1,
      isLoading: true,
    );
    
    try {
      // Actualizar progreso
      final progress = StoryService.getStoryProgress();
      final updatedProgress = progress.copyWith(
        currentChapter: chapterId,
        currentLevel: 1,
      );
      await StoryService.saveStoryProgress(updatedProgress);
      
      state = state.copyWith(
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error iniciando capítulo: $e',
      );
    }
  }
  
  // Iniciar nivel
  Future<void> startLevel(int levelNumber) async {
    final currentChapter = state.chapters.firstWhere(
      (chapter) => chapter.id == state.currentChapter,
    );
    
    if (!currentChapter.isLevelAvailable(levelNumber)) {
      state = state.copyWith(error: 'Nivel no disponible');
      return;
    }
    
    state = state.copyWith(
      currentLevel: levelNumber,
      isLoading: true,
    );
    
    try {
      // Actualizar progreso
      final progress = StoryService.getStoryProgress();
      final updatedProgress = progress.copyWith(
        currentLevel: levelNumber,
      );
      await StoryService.saveStoryProgress(updatedProgress);
      
      state = state.copyWith(
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error iniciando nivel: $e',
      );
    }
  }
  
  // Completar nivel
  Future<ChapterProgressResult> completeLevel({
    required int stars,
    required int coinsEarned,
    required Duration playTime,
  }) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final result = await StoryService.advanceToNextLevel(
        levelNumber: state.currentLevel,
        stars: stars,
        coinsEarned: coinsEarned,
        playTime: playTime,
      );
      
      // Recargar progreso
      await _loadStoryProgress();
      
      // Desbloquear skins si es necesario
      if (result.chapterRewards.skins.isNotEmpty) {
        for (final skin in result.chapterRewards.skins) {
          await StoryService.unlockSkin(skin);
        }
      }
      
      state = state.copyWith(isLoading: false);
      
      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error completando nivel: $e',
      );
      
      return ChapterProgressResult(
        success: false,
        nextChapter: state.currentChapter,
        nextLevel: state.currentLevel,
        chapterCompleted: false,
        starsEarned: 0,
        coinsEarned: 0,
        chapterRewards: const ChapterRewards(
          coins: 0,
          powerUps: [],
          skins: [],
          specialRewards: [],
        ),
        isNewChapter: false,
      );
    }
  }
  
  // Iniciar cinemática
  void startCutscene(List<DialogueLine> dialogues) {
    state = state.copyWith(
      isInCutscene: true,
      activeDialogue: dialogues,
    );
  }
  
  // Finalizar cinemática
  void endCutscene() {
    state = state.copyWith(
      isInCutscene: false,
      activeDialogue: null,
    );
  }
  
  // Marcar diálogos como vistos
  Future<void> markDialoguesSeen() async {
    try {
      await StoryService.markDialoguesSeen(state.currentChapter);
    } catch (e) {
      state = state.copyWith(error: 'Error marcando diálogos: $e');
    }
  }
  
  // Obtener diálogos de introducción del capítulo
  List<DialogueLine> getChapterIntroDialogues() {
    final chapterData = StoryData.getChapter(state.currentChapter);
    return chapterData?.introDialogues ?? [];
  }
  
  // Obtener diálogos de final del capítulo
  List<DialogueLine> getChapterOutroDialogues() {
    final chapterData = StoryData.getChapter(state.currentChapter);
    return chapterData?.outroDialogues ?? [];
  }
  
  // Obtener diálogos pre-jefe
  List<DialogueLine> getBossPreDialogues() {
    final chapterData = StoryData.getChapter(state.currentChapter);
    return chapterData?.bossPreDialogue ?? [];
  }
  
  // Obtener diálogos post-jefe
  List<DialogueLine> getBossPostDialogues() {
    final chapterData = StoryData.getChapter(state.currentChapter);
    return chapterData?.bossPostDialogue ?? [];
  }
  
  // Obtener capítulo actual
  Chapter? getCurrentChapter() {
    try {
      return state.chapters.firstWhere(
        (chapter) => chapter.id == state.currentChapter,
      );
    } catch (e) {
      return null;
    }
  }
  
  // Obtener información del nivel actual
  StoryLevelInfo? getCurrentLevelInfo() {
    final currentChapter = getCurrentChapter();
    if (currentChapter == null) return null;
    
    return StoryLevelInfo(
      levelNumber: state.currentLevel,
      title: 'Nivel ${state.currentLevel}',
      description: _getLevelDescription(),
      biome: currentChapter.biome,
      difficulty: _getLevelDifficulty(),
      specialEvent: _getLevelSpecialEvent(),
      targetScore: _getLevelTargetScore(),
      timeLimit: _getLevelTimeLimit(),
      colorRestriction: ColorRestriction.none,
      hasCursedCells: false,
      hasPositiveCells: false,
      hasGhostBlocks: false,
      boardSize: 8,
      allowedPieceTypes: [],
      boardObstacles: [],
      specialRules: {},
      biomeColors: [],
      baseReward: 50,
      isBossLevel: state.currentLevel == 12,
      isChallengeLevel: state.currentLevel == 11,
      isMilestone: false,
    );
  }
  
  // Métodos auxiliares para información del nivel
  String _getLevelDescription() {
    if (state.currentLevel == 11) {
      return 'Nivel especial de reto';
    } else if (state.currentLevel == 12) {
      return 'Enfrentamiento contra el jefe';
    } else {
      return 'Nivel ${state.currentLevel} de ${getCurrentChapter()?.title ?? ''}';
    }
  }
  
  Difficulty _getLevelDifficulty() {
    final chapter = state.currentChapter;
    if (chapter <= 2) return Difficulty.normal;
    if (chapter <= 3) return Difficulty.hard;
    if (chapter <= 4) return Difficulty.expert;
    return Difficulty.master;
  }
  
  SpecialEventType _getLevelSpecialEvent() {
    if (state.currentLevel == 11) return SpecialEventType.challenge;
    if (state.currentLevel == 12) return SpecialEventType.boss;
    return SpecialEventType.none;
  }
  
  int _getLevelTargetScore() {
    return 1000 * state.currentChapter + state.currentLevel * 200;
  }
  
  TimeLimit _getLevelTimeLimit() {
    if (state.currentLevel == 11) return TimeLimit.medium;
    return TimeLimit.none;
  }
  
  // Verificar si el capítulo está completado
  bool isChapterCompleted() {
    final currentChapter = getCurrentChapter();
    return currentChapter?.isCompleted ?? false;
  }
  
  // Verificar si el capítulo es perfecto
  bool isChapterPerfect() {
    final currentChapter = getCurrentChapter();
    return currentChapter?.isPerfect ?? false;
  }
  
  // Obtener resumen del progreso
  StorySummary getStorySummary() {
    return StoryService.getStorySummary();
  }
  
  // Obtener estadísticas detalladas
  StoryStats getStoryStats() {
    return StoryService.getStoryStats();
  }
  
  // Verificar si un skin está desbloqueado
  bool isSkinUnlocked(String skinName) {
    return StoryService.isSkinUnlocked(skinName);
  }
  
  // Obtener skins desbloqueados
  List<String> getUnlockedSkins() {
    return StoryService.getUnlockedSkins();
  }
  
  // Reiniciar progreso de la historia
  Future<void> resetProgress() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await StoryService.resetStoryProgress();
      await _loadStoryProgress();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error reiniciando progreso: $e',
      );
    }
  }
  
  // Limpiar errores
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
  
  // Obtener estado del Arquitecto (para visualización)
  ArchitectState getArchitectState() {
    final completion = state.architectCompletion;
    
    if (completion >= 1.0) {
      return ArchitectState.complete;
    } else if (completion >= 0.8) {
      return ArchitectState.nearlyComplete;
    } else if (completion >= 0.6) {
      return ArchitectState.mostlyComplete;
    } else if (completion >= 0.4) {
      return ArchitectState.halfComplete;
    } else if (completion >= 0.2) {
      return ArchitectState.partiallyComplete;
    } else {
      return ArchitectState.minimal;
    }
  }
}

// Estado del Arquitecto para visualización
enum ArchitectState {
  minimal,        // 0-20%
  partiallyComplete, // 20-40%
  halfComplete,   // 40-60%
  mostlyComplete, // 60-80%
  nearlyComplete, // 80-99%
  complete,      // 100%
}

// Providers
final storyProvider = StateNotifierProvider<StoryProvider, StoryState>((ref) {
  return StoryProvider();
});

final currentChapterProvider = Provider<Chapter?>((ref) {
  return ref.watch(storyProvider.notifier).getCurrentChapter();
});

final currentLevelInfoProvider = Provider<LevelInfo?>((ref) {
  return ref.watch(storyProvider.notifier).getCurrentLevelInfo();
});

final storySummaryProvider = Provider<StorySummary>((ref) {
  return ref.watch(storyProvider.notifier).getStorySummary();
});

final storyStatsProvider = Provider<StoryStats>((ref) {
  return ref.watch(storyProvider.notifier).getStoryStats();
});

final architectStateProvider = Provider<ArchitectState>((ref) {
  return ref.watch(storyProvider.notifier).getArchitectState();
});
