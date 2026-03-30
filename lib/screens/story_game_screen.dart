import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:blockrush/config/theme.dart';
import 'package:blockrush/providers/story_provider.dart';
import 'package:blockrush/providers/player_provider.dart';
import 'package:blockrush/widgets/board_widget.dart';
import 'package:blockrush/widgets/piece_widget.dart';
import 'package:blockrush/widgets/score_display.dart';
import 'package:blockrush/widgets/coin_display.dart';
import 'package:blockrush/widgets/biome_background.dart';
import 'package:blockrush/widgets/dialogue_overlay.dart';
import 'package:blockrush/services/audio_service.dart';
import 'package:blockrush/services/haptic_service.dart';
import 'package:blockrush/screens/chapter_complete_screen.dart';

class StoryGameScreen extends ConsumerStatefulWidget {
  const StoryGameScreen({super.key});

  @override
  ConsumerState<StoryGameScreen> createState() => _StoryGameScreenState();
}

class _StoryGameScreenState extends ConsumerState<StoryGameScreen>
    with TickerProviderStateMixin {
  bool _isInitialized = false;
  bool _showBossDialogues = false;
  
  @override
  void initState() {
    super.initState();
    
    // Mantener pantalla encendida
    WakelockPlus.enable();
    
    // Inicializar juego
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGame();
    });
  }
  
  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }
  
  void _initializeGame() {
    if (!_isInitialized) {
      _isInitialized = true;
      
      // Verificar si es nivel de jefe para mostrar diálogos
      final storyState = ref.read(storyProvider);
      if (storyState.currentLevel == 12) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
              _showBossDialogues = true;
            });
          }
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final storyState = ref.watch(storyProvider);
    final levelInfo = ref.watch(currentLevelInfoProvider);
    final playerData = ref.watch(playerProvider);
    final currentChapter = storyState.getCurrentChapter();
    
    return Scaffold(
      body: BiomeBackground(
        biome: currentChapter?.biome ?? Biome.garden,
        child: SafeArea(
          child: Stack(
            children: [
              // Contenido principal del juego
              Column(
                children: [
                  // Panel superior con información del nivel
                  _buildTopPanel(levelInfo, storyState),
                  
                  // Tablero de juego
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: _buildGameBoard(levelInfo, storyState),
                    ),
                  ),
                  
                  // Panel inferior con piezas disponibles
                  Expanded(
                    flex: 1,
                    child: _buildPiecesPanel(levelInfo, playerData),
                  ),
                ],
              ),
              
              // Diálogos de jefe
              if (_showBossDialogues)
                DialogueOverlay(
                  dialogues: storyState.getBossPreDialogues(),
                  onComplete: () => _onBossDialoguesComplete(),
                  canSkip: true,
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTopPanel(levelInfo, storyState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón de pausa
          IconButton(
            icon: const Icon(Icons.pause, color: AppTheme.primaryText),
            onPressed: _showPauseMenu,
          ),
          
          // Información del capítulo y nivel
          if (levelInfo != null) ...[
            // Capítulo actual
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.secondaryText.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                'Cap ${storyState.currentChapter}',
                style: TextStyle(
                  color: AppTheme.primaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Nivel actual
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.secondaryText.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.layers,
                    color: AppTheme.secondaryAccent,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Nvl ${storyState.currentLevel}',
                    style: TextStyle(
                      color: AppTheme.primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Badge especial para niveles de reto/jefe
            if (levelInfo.isChallengeLevel || levelInfo.isBossLevel) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: levelInfo.isBossLevel 
                      ? const LinearGradient(
                          colors: [AppTheme.dangerColor, Color(0xFFD32F2F)],
                        )
                      : const LinearGradient(
                          colors: [AppTheme.secondaryAccent, Color(0xFF0288D1)],
                        ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  levelInfo.isBossLevel ? 'JEFE' : 'RETO',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
          
          // Puntuación
          ScoreDisplay(
            score: 0, // Esto se actualizaría con el score real
            fontSize: 20,
            showAnimation: true,
          ),
          
          // Monedas
          const CoinDisplay(),
        ],
      ),
    );
  }
  
  Widget _buildGameBoard(levelInfo, storyState) {
    if (levelInfo == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryAccent,
        ),
      );
    }
    
    return Stack(
      children: [
        // Tablero principal
        Container(
          width: 320,
          height: 320,
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.secondaryText.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: const Center(
            child: Text(
              'Tablero de juego',
              style: TextStyle(
                color: AppTheme.secondaryText,
                fontSize: 16,
              ),
            ),
          ),
        ),
        
        // Overlay de información del nivel
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    levelInfo.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryText,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    levelInfo.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.secondaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  if (levelInfo.isChallengeLevel || levelInfo.isBossLevel) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: levelInfo.isBossLevel 
                            ? AppTheme.dangerColor.withOpacity(0.2)
                            : AppTheme.secondaryAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          if (levelInfo.isChallengeLevel) ...[
                            Text(
                              'NIVEL RETO',
                              style: TextStyle(
                                color: AppTheme.secondaryAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Completa el objetivo especial',
                              style: TextStyle(
                                color: AppTheme.secondaryText,
                                fontSize: 11,
                              ),
                            ),
                          ],
                          
                          if (levelInfo.isBossLevel) ...[
                            Text(
                              '¡ENFRENTAMIENTO FINAL!',
                              style: TextStyle(
                                color: AppTheme.dangerColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Derrota al guardián del capítulo',
                              style: TextStyle(
                                color: AppTheme.secondaryText,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPiecesPanel(levelInfo, playerData) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.secondaryText.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Arrastra las piezas al tablero',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: Text(
                'Piezas disponibles',
                style: TextStyle(
                  color: AppTheme.primaryText.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showPauseMenu() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          'Juego Pausado',
          style: TextStyle(
            color: AppTheme.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.play_arrow, color: AppTheme.primaryAccent),
              title: Text(
                'Reanudar',
                style: TextStyle(color: AppTheme.primaryText),
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.refresh, color: AppTheme.secondaryAccent),
              title: Text(
                'Reiniciar nivel',
                style: TextStyle(color: AppTheme.primaryText),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _restartLevel();
              },
            ),
            ListTile(
              leading: Icon(Icons.map, color: AppTheme.secondaryAccent),
              title: Text(
                'Mapa de historia',
                style: TextStyle(color: AppTheme.primaryText),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.home, color: AppTheme.dangerColor),
              title: Text(
                'Salir al menú',
                style: TextStyle(color: AppTheme.primaryText),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _restartLevel() {
    final storyState = ref.read(storyProvider);
    ref.read(storyProvider.notifier).startLevel(storyState.currentLevel);
  }
  
  void _onBossDialoguesComplete() {
    setState(() {
      _showBossDialogues = false;
    });
    
    // Aquí comenzaría el combate contra el jefe
    // Por ahora, solo mostramos un mensaje
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('¡Comienza el enfrentamiento!'),
        backgroundColor: AppTheme.dangerColor,
      ),
    );
  }
  
  void _completeLevel({
    required int stars,
    required int score,
    required int coinsEarned,
    required Duration playTime,
  }) async {
    final storyState = ref.read(storyProvider);
    
    // Completar el nivel
    final result = await ref.read(storyProvider.notifier).completeLevel(
      stars: stars,
      coinsEarned: coinsEarned,
      playTime: playTime,
    );
    
    if (result.success) {
      if (result.chapterCompleted) {
        // Navegar a pantalla de capítulo completado
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ChapterCompleteScreen(
              chapterId: result.nextChapter - 1,
              starsEarned: result.starsEarned,
              coinsEarned: result.coinsEarned,
              rewards: result.chapterRewards,
              isNewChapter: result.isNewChapter,
            ),
          ),
        );
      } else {
        // Continuar al siguiente nivel
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Nivel ${result.nextLevel} desbloqueado!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }
  
  void _gameOver({
    required int score,
    required int coinsEarned,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          'Game Over',
          style: TextStyle(
            color: AppTheme.dangerColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¿Qué deseas hacer?',
              style: TextStyle(
                color: AppTheme.secondaryText,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _restartLevel();
            },
            child: Text(
              'Reintentar',
              style: TextStyle(color: AppTheme.primaryAccent),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Mapa de historia',
              style: TextStyle(color: AppTheme.secondaryAccent),
            ),
          ),
        ],
      ),
    );
  }
}
