import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:blockrush/config/theme.dart';
import 'package:blockrush/providers/level_provider.dart';
import 'package:blockrush/providers/player_provider.dart';
import 'package:blockrush/widgets/board_widget.dart';
import 'package:blockrush/widgets/piece_widget.dart';
import 'package:blockrush/widgets/score_display.dart';
import 'package:blockrush/widgets/coin_display.dart';
import 'package:blockrush/widgets/biome_background.dart';
import 'package:blockrush/widgets/milestone_popup.dart';
import 'package:blockrush/services/audio_service.dart';
import 'package:blockrush/services/haptic_service.dart';
import 'package:blockrush/screens/game_over_screen.dart';

class EndlessGameScreen extends ConsumerStatefulWidget {
  const EndlessGameScreen({super.key});

  @override
  ConsumerState<EndlessGameScreen> createState() => _EndlessGameScreenState();
}

class _EndlessGameScreenState extends ConsumerState<EndlessGameScreen>
    with TickerProviderStateMixin {
  bool _isInitialized = false;
  bool _showMilestonePopup = false;
  String? _milestoneTitle;
  
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
      ref.read(levelProvider.notifier).generateLevel(1);
      _isInitialized = true;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final levelState = ref.watch(levelProvider);
    final levelInfo = ref.watch(currentLevelInfoProvider);
    final playerData = ref.watch(playerProvider);
    
    return Scaffold(
      body: BiomeBackground(
        biome: levelInfo?.biome ?? Biome.garden,
        child: SafeArea(
          child: Column(
            children: [
              // Panel superior con información del nivel
              _buildTopPanel(levelInfo, levelState),
              
              // Tablero de juego
              Expanded(
                flex: 4,
                child: Center(
                  child: _buildGameBoard(levelInfo),
                ),
              ),
              
              // Panel inferior con piezas disponibles
              Expanded(
                flex: 1,
                child: _buildPiecesPanel(levelInfo, playerData),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTopPanel(levelInfo, levelState) {
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
          
          // Información del nivel actual
          if (levelInfo != null) ...[
            // Indicador de bioma
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
                    _getBiomeIcon(levelInfo.biome),
                    color: _getBiomeColor(levelInfo.biome),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getBiomeName(levelInfo.biome),
                    style: TextStyle(
                      color: AppTheme.primaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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
                    'Nvl ${levelState.currentLevel}',
                    style: TextStyle(
                      color: AppTheme.primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Badge de jefe si aplica
            if (levelInfo.isBossLevel) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.dangerColor, Color(0xFFD32F2F)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'JEFE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                .scaleXY(
                  begin: 1.0,
                  end: 1.1,
                  duration: const Duration(milliseconds: 1000),
                )
                .then()
                .scaleXY(
                  begin: 1.1,
                  end: 1.0,
                  duration: const Duration(milliseconds: 1000),
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
  
  Widget _buildGameBoard(levelInfo) {
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
                        color: AppTheme.primaryAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          if (levelInfo.isChallengeLevel) ...[
                            Text(
                              'OBJETIVO ESPECIAL',
                              style: TextStyle(
                                color: AppTheme.primaryAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Completa el reto para avanzar',
                              style: TextStyle(
                                color: AppTheme.secondaryText,
                                fontSize: 11,
                              ),
                            ),
                          ],
                          
                          if (levelInfo.isBossLevel) ...[
                            Text(
                              '¡ENFRENTAMIENTO!',
                              style: TextStyle(
                                color: AppTheme.dangerColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Derrota al jefe para continuar',
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
              leading: Icon(Icons.home, color: AppTheme.dangerColor),
              title: Text(
                'Salir al menú',
                style: TextStyle(color: AppTheme.primaryText),
              ),
              onTap: () {
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
    final levelState = ref.read(levelProvider);
    ref.read(levelProvider.notifier).generateLevel(levelState.currentLevel);
  }
  
  void _completeLevel({
    required int stars,
    required int score,
    required int coinsEarned,
    required int linesCleared,
  }) async {
    final levelState = ref.read(levelProvider);
    
    // Avanzar al siguiente nivel
    await ref.read(levelProvider.notifier).advanceToNextLevel(
      score: score,
      coinsEarned: coinsEarned,
      linesCleared: linesCleared,
    );
    
    // Verificar si se desbloqueó un hito
    final nextMilestone = ref.read(nextMilestoneProvider);
    if (nextMilestone.isUnlocked && !_showMilestonePopup) {
      setState(() {
        _showMilestonePopup = true;
        _milestoneTitle = nextMilestone.title;
      });
    }
  }
  
  void _gameOver({
    required int score,
    required int level,
    required int coinsEarned,
  }) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => GameOverScreen(
          finalScore: score,
          level: level,
          linesCleared: 0,
          coinsEarned: coinsEarned,
        ),
      ),
    );
  }
  
  IconData _getBiomeIcon(Biome biome) {
    switch (biome) {
      case Biome.garden:
        return Icons.nature;
      case Biome.caverns:
        return Icons.terrain;
      case Biome.volcano:
        return Icons.local_fire_department;
      case Biome.ocean:
        return Icons.water;
      case Biome.storm:
        return Icons.flash_on;
      case Biome.ice:
        return Icons.ac_unit;
      case Biome.void:
        return Icons.blur_on;
      case Biome.dome:
        return Icons.account_balance;
    }
  }
  
  Color _getBiomeColor(Biome biome) {
    switch (biome) {
      case Biome.garden:
        return const Color(0xFF4CAF50);
      case Biome.caverns:
        return const Color(0xFF2196F3);
      case Biome.volcano:
        return const Color(0xFFFF5722);
      case Biome.ocean:
        return const Color(0xFF00BCD4);
      case Biome.storm:
        return const Color(0xFF9C27B0);
      case Biome.ice:
        return const Color(0xFF90CAF9);
      case Biome.void:
        return const Color(0xFF424242);
      case Biome.dome:
        return const Color(0xFFFFD700);
    }
  }
  
  String _getBiomeName(Biome biome) {
    switch (biome) {
      case Biome.garden:
        return 'Jardines';
      case Biome.caverns:
        return 'Cavernas';
      case Biome.volcano:
        return 'Volcán';
      case Biome.ocean:
        return 'Océano';
      case Biome.storm:
        return 'Tormenta';
      case Biome.ice:
        return 'Hielo';
      case Biome.void:
        return 'Vacío';
      case Biome.dome:
        return 'Cúpula';
    }
  }
}
