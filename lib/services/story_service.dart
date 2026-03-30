import 'dart:convert';
import 'package:blockrush/services/storage_service.dart';
import 'package:blockrush/models/chapter.dart';
import 'package:blockrush/config/constants.dart';
import 'package:blockrush/config/story_data.dart';

class StoryService {
  static const String _storyProgressKey = 'story_progress';
  static const String _unlockedSkinsKey = 'unlocked_skins';
  static const String _storyStatsKey = 'story_stats';
  
  // Obtener progreso de la historia
  static StoryProgress getStoryProgress() {
    try {
      final jsonString = StorageService.getString(_storyProgressKey);
      if (jsonString == null) {
        return _createDefaultProgress();
      }
      
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return StoryProgress.fromJson(json);
    } catch (e) {
      return _createDefaultProgress();
    }
  }
  
  // Guardar progreso de la historia
  static Future<void> saveStoryProgress(StoryProgress progress) async {
    try {
      await StorageService.setString(_storyProgressKey, jsonEncode(progress.toJson()));
    } catch (e) {
      // Silenciar errores de guardado
    }
  }
  
  // Crear progreso por defecto
  static StoryProgress _createDefaultProgress() {
    final chapters = <Chapter>[];
    
    // Crear capítulos 1-5
    for (int i = 1; i <= GameConstants.totalStoryChapters; i++) {
      final chapterData = StoryData.getChapter(i);
      if (chapterData != null) {
        chapters.add(Chapter(
          id: i,
          title: chapterData.title,
          world: chapterData.world,
          guardian: chapterData.guardian,
          biome: _getBiomeFromName(chapterData.biome),
          status: i == 1 ? ChapterStatus.available : ChapterStatus.locked,
        ));
      }
    }
    
    return StoryProgress(
      currentChapter: 1,
      currentLevel: 1,
      chapters: chapters,
      totalStoryCoinsEarned: 0,
      unlockedSkins: [],
      architectCompletion: 0.0,
      lastPlayDate: DateTime.now(),
      totalPlayTime: Duration.zero,
      dialoguesSkipped: 0,
      levelsCompleted: 0,
      totalStarsEarned: 0,
    );
  }
  
  // Convertir nombre de bioma a enum
  static Biome _getBiomeFromName(String biomeName) {
    switch (biomeName) {
      case 'garden':
        return Biome.garden;
      case 'caverns':
        return Biome.caverns;
      case 'volcano':
        return Biome.volcano;
      case 'ocean':
        return Biome.ocean;
      case 'dome':
        return Biome.dome;
      default:
        return Biome.garden;
    }
  }
  
  // Obtener capítulo actual
  static Chapter getCurrentChapter() {
    final progress = getStoryProgress();
    try {
      return progress.chapters.firstWhere(
        (chapter) => chapter.id == progress.currentChapter,
      );
    } catch (e) {
      return progress.chapters.first;
    }
  }
  
  // Avanzar al siguiente nivel
  static Future<ChapterProgressResult> advanceToNextLevel({
    required int levelNumber,
    required int stars,
    required int coinsEarned,
    required Duration playTime,
  }) async {
    final progress = getStoryProgress();
    final currentChapter = progress.chapters.firstWhere(
      (chapter) => chapter.id == progress.currentChapter,
    );
    
    // Completar el nivel
    final updatedChapter = currentChapter.completeLevel(levelNumber, stars, coinsEarned);
    
    // Actualizar capítulo en la lista
    final updatedChapters = progress.chapters.map((chapter) {
      return chapter.id == progress.currentChapter ? updatedChapter : chapter;
    }).toList();
    
    // Determinar siguiente capítulo/nivel
    int nextChapter = progress.currentChapter;
    int nextLevel = progress.currentLevel;
    
    if (levelNumber >= GameConstants.levelsPerChapter) {
      // Capítulo completado
      if (progress.currentChapter < GameConstants.totalStoryChapters) {
        nextChapter++;
        nextLevel = 1;
        
        // Desbloquear siguiente capítulo
        final nextChapterIndex = nextChapter - 1;
        if (nextChapterIndex < updatedChapters.length) {
          updatedChapters[nextChapterIndex] = updatedChapters[nextChapterIndex].copyWith(
            status: ChapterStatus.available,
          );
        }
      }
    } else {
      // Siguiente nivel del mismo capítulo
      nextLevel = levelNumber + 1;
    }
    
    // Actualizar estadísticas
    final newProgress = progress.copyWith(
      currentChapter: nextChapter,
      currentLevel: nextLevel,
      chapters: updatedChapters,
      totalStoryCoinsEarned: progress.totalStoryCoinsEarned + coinsEarned,
      lastPlayDate: DateTime.now(),
      totalPlayTime: progress.totalPlayTime + playTime,
      levelsCompleted: progress.levelsCompleted + 1,
      totalStarsEarned: progress.totalStarsEarned + stars,
      architectCompletion: _calculateArchitectCompletion(updatedChapters),
    );
    
    await saveStoryProgress(newProgress);
    
    return ChapterProgressResult(
      success: true,
      nextChapter: nextChapter,
      nextLevel: nextLevel,
      chapterCompleted: levelNumber >= GameConstants.levelsPerChapter,
      starsEarned: stars,
      coinsEarned: coinsEarned,
      chapterRewards: updatedChapter.getRewards(),
      isNewChapter: nextChapter > progress.currentChapter,
    );
  }
  
  // Calcular completion del Arquitecto
  static double _calculateArchitectCompletion(List<Chapter> chapters) {
    if (chapters.isEmpty) return 0.0;
    
    int totalChapters = GameConstants.totalStoryChapters;
    int completedChapters = chapters.where((c) => c.isCompleted).length;
    
    return completedChapters / totalChapters;
  }
  
  // Desbloquear skin
  static Future<void> unlockSkin(String skinName) async {
    final progress = getStoryProgress();
    final unlockedSkins = List<String>.from(progress.unlockedSkins);
    
    if (!unlockedSkins.contains(skinName)) {
      unlockedSkins.add(skinName);
      
      final newProgress = progress.copyWith(unlockedSkins: unlockedSkins);
      await saveStoryProgress(newProgress);
    }
  }
  
  // Verificar si un skin está desbloqueado
  static bool isSkinUnlocked(String skinName) {
    final progress = getStoryProgress();
    return progress.unlockedSkins.contains(skinName);
  }
  
  // Obtener skins desbloqueados
  static List<String> getUnlockedSkins() {
    final progress = getStoryProgress();
    return progress.unlockedSkins;
  }
  
  // Marcar diálogos como vistos
  static Future<void> markDialoguesSeen(int chapterId) async {
    final progress = getStoryProgress();
    final chapters = progress.chapters.map((chapter) {
      if (chapter.id == chapterId) {
        return chapter.markDialoguesSeen();
      }
      return chapter;
    }).toList();
    
    final newProgress = progress.copyWith(chapters: chapters);
    await saveStoryProgress(newProgress);
  }
  
  // Verificar si los diálogos fueron vistos
  static bool areDialoguesSeen(int chapterId) {
    final progress = getStoryProgress();
    try {
      final chapter = progress.chapters.firstWhere((c) => c.id == chapterId);
      return chapter.dialoguesSeen;
    } catch (e) {
      return false;
    }
  }
  
  // Obtener estadísticas de la historia
  static StoryStats getStoryStats() {
    final progress = getStoryProgress();
    
    int totalStars = 0;
    int maxStars = 0;
    int completedChapters = 0;
    int perfectChapters = 0;
    
    for (final chapter in progress.chapters) {
      totalStars += chapter.totalStars;
      maxStars += chapter.maxStars;
      if (chapter.isCompleted) completedChapters++;
      if (chapter.isPerfect) perfectChapters++;
    }
    
    return StoryStats(
      totalPlayTime: progress.totalPlayTime,
      levelsCompleted: progress.levelsCompleted,
      chaptersCompleted: completedChapters,
      perfectChapters: perfectChapters,
      totalStarsEarned: totalStars,
      maxStarsPossible: maxStars,
      totalCoinsEarned: progress.totalStoryCoinsEarned,
      skinsUnlocked: progress.unlockedSkins.length,
      architectCompletion: progress.architectCompletion,
      dialoguesSkipped: progress.dialoguesSkipped,
      currentChapter: progress.currentChapter,
      currentLevel: progress.currentLevel,
    );
  }
  
  // Reiniciar progreso de la historia
  static Future<void> resetStoryProgress() async {
    await StorageService.remove(_storyProgressKey);
    await StorageService.remove(_unlockedSkinsKey);
    await StorageService.remove(_storyStatsKey);
  }
  
  // Verificar si se puede acceder a un capítulo
  static bool canAccessChapter(int chapterId) {
    final progress = getStoryProgress();
    
    if (chapterId == 1) return true;
    if (chapterId > GameConstants.totalStoryChapters) return false;
    
    // Verificar si el capítulo anterior está completado
    try {
      final previousChapter = progress.chapters.firstWhere(
        (chapter) => chapter.id == chapterId - 1,
      );
      return previousChapter.isCompleted;
    } catch (e) {
      return false;
    }
  }
  
  // Obtener resumen del progreso total
  static StorySummary getStorySummary() {
    final progress = getStoryProgress();
    final stats = getStoryStats();
    
    return StorySummary(
      currentChapter: progress.currentChapter,
      currentLevel: progress.currentLevel,
      totalChapters: GameConstants.totalStoryChapters,
      completedChapters: stats.chaptersCompleted,
      perfectChapters: stats.perfectChapters,
      totalStars: stats.totalStarsEarned,
      maxStars: stats.maxStarsPossible,
      completionPercentage: (stats.chaptersCompleted / GameConstants.totalStoryChapters) * 100,
      starPercentage: stats.totalStarsEarned > 0 ? (stats.totalStarsEarned / stats.maxStarsPossible) * 100 : 0,
      totalCoinsEarned: stats.totalCoinsEarned,
      skinsUnlocked: stats.skinsUnlocked,
      architectCompletion: stats.architectCompletion,
      totalPlayTime: stats.totalPlayTime,
    );
  }
}

// Clase para el progreso de la historia
class StoryProgress {
  final int currentChapter;
  final int currentLevel;
  final List<Chapter> chapters;
  final int totalStoryCoinsEarned;
  final List<String> unlockedSkins;
  final double architectCompletion;
  final DateTime lastPlayDate;
  final Duration totalPlayTime;
  final int dialoguesSkipped;
  final int levelsCompleted;
  final int totalStarsEarned;
  
  const StoryProgress({
    required this.currentChapter,
    required this.currentLevel,
    required this.chapters,
    required this.totalStoryCoinsEarned,
    required this.unlockedSkins,
    required this.architectCompletion,
    required this.lastPlayDate,
    required this.totalPlayTime,
    required this.dialoguesSkipped,
    required this.levelsCompleted,
    required this.totalStarsEarned,
  });
  
  StoryProgress copyWith({
    int? currentChapter,
    int? currentLevel,
    List<Chapter>? chapters,
    int? totalStoryCoinsEarned,
    List<String>? unlockedSkins,
    double? architectCompletion,
    DateTime? lastPlayDate,
    Duration? totalPlayTime,
    int? dialoguesSkipped,
    int? levelsCompleted,
    int? totalStarsEarned,
  }) {
    return StoryProgress(
      currentChapter: currentChapter ?? this.currentChapter,
      currentLevel: currentLevel ?? this.currentLevel,
      chapters: chapters ?? this.chapters,
      totalStoryCoinsEarned: totalStoryCoinsEarned ?? this.totalStoryCoinsEarned,
      unlockedSkins: unlockedSkins ?? this.unlockedSkins,
      architectCompletion: architectCompletion ?? this.architectCompletion,
      lastPlayDate: lastPlayDate ?? this.lastPlayDate,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
      dialoguesSkipped: dialoguesSkipped ?? this.dialoguesSkipped,
      levelsCompleted: levelsCompleted ?? this.levelsCompleted,
      totalStarsEarned: totalStarsEarned ?? this.totalStarsEarned,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'currentChapter': currentChapter,
      'currentLevel': currentLevel,
      'chapters': chapters.map((c) => c.toJson()).toList(),
      'totalStoryCoinsEarned': totalStoryCoinsEarned,
      'unlockedSkins': unlockedSkins,
      'architectCompletion': architectCompletion,
      'lastPlayDate': lastPlayDate.toIso8601String(),
      'totalPlayTimeMs': totalPlayTime.inMilliseconds,
      'dialoguesSkipped': dialoguesSkipped,
      'levelsCompleted': levelsCompleted,
      'totalStarsEarned': totalStarsEarned,
    };
  }
  
  factory StoryProgress.fromJson(Map<String, dynamic> json) {
    return StoryProgress(
      currentChapter: json['currentChapter'] ?? 1,
      currentLevel: json['currentLevel'] ?? 1,
      chapters: (json['chapters'] as List<dynamic>?)
          ?.map((c) => Chapter.fromJson(c as Map<String, dynamic>))
          .toList() ?? [],
      totalStoryCoinsEarned: json['totalStoryCoinsEarned'] ?? 0,
      unlockedSkins: List<String>.from(json['unlockedSkins'] ?? []),
      architectCompletion: (json['architectCompletion'] ?? 0.0).toDouble(),
      lastPlayDate: json['lastPlayDate'] != null
          ? DateTime.parse(json['lastPlayDate'])
          : DateTime.now(),
      totalPlayTime: Duration(milliseconds: json['totalPlayTimeMs'] ?? 0),
      dialoguesSkipped: json['dialoguesSkipped'] ?? 0,
      levelsCompleted: json['levelsCompleted'] ?? 0,
      totalStarsEarned: json['totalStarsEarned'] ?? 0,
    );
  }
}

// Resultado de avanzar de capítulo
class ChapterProgressResult {
  final bool success;
  final int nextChapter;
  final int nextLevel;
  final bool chapterCompleted;
  final int starsEarned;
  final int coinsEarned;
  final ChapterRewards chapterRewards;
  final bool isNewChapter;
  
  const ChapterProgressResult({
    required this.success,
    required this.nextChapter,
    required this.nextLevel,
    required this.chapterCompleted,
    required this.starsEarned,
    required this.coinsEarned,
    required this.chapterRewards,
    required this.isNewChapter,
  });
}

// Estadísticas de la historia
class StoryStats {
  final Duration totalPlayTime;
  final int levelsCompleted;
  final int chaptersCompleted;
  final int perfectChapters;
  final int totalStarsEarned;
  final int maxStarsPossible;
  final int totalCoinsEarned;
  final int skinsUnlocked;
  final double architectCompletion;
  final int dialoguesSkipped;
  final int currentChapter;
  final int currentLevel;
  
  const StoryStats({
    required this.totalPlayTime,
    required this.levelsCompleted,
    required this.chaptersCompleted,
    required this.perfectChapters,
    required this.totalStarsEarned,
    required this.maxStarsPossible,
    required this.totalCoinsEarned,
    required this.skinsUnlocked,
    required this.architectCompletion,
    required this.dialoguesSkipped,
    required this.currentChapter,
    required this.currentLevel,
  });
}

// Resumen del progreso
class StorySummary {
  final int currentChapter;
  final int currentLevel;
  final int totalChapters;
  final int completedChapters;
  final int perfectChapters;
  final int totalStars;
  final int maxStars;
  final double completionPercentage;
  final double starPercentage;
  final int totalCoinsEarned;
  final int skinsUnlocked;
  final double architectCompletion;
  final Duration totalPlayTime;
  
  const StorySummary({
    required this.currentChapter,
    required this.currentLevel,
    required this.totalChapters,
    required this.completedChapters,
    required this.perfectChapters,
    required this.totalStars,
    required this.maxStars,
    required this.completionPercentage,
    required this.starPercentage,
    required this.totalCoinsEarned,
    required this.skinsUnlocked,
    required this.architectCompletion,
    required this.totalPlayTime,
  });
}
