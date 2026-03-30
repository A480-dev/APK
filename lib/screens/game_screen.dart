import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:blockrush/config/theme.dart';
import 'package:blockrush/config/constants.dart';
import 'package:blockrush/providers/game_provider.dart';
import 'package:blockrush/providers/player_provider.dart';
import 'package:blockrush/widgets/board_widget.dart';
import 'package:blockrush/widgets/piece_widget.dart';
import 'package:blockrush/widgets/score_display.dart';
import 'package:blockrush/widgets/coin_display.dart';
import 'package:blockrush/widgets/particle_burst.dart';
import 'package:blockrush/services/audio_service.dart';
import 'package:blockrush/services/haptic_service.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  late AnimationController _comboController;
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    
    _comboController = AnimationController(
      duration: const Duration(milliseconds: GameConstants.comboDisplayDuration),
      vsync: this,
    );
    
    // Mantener pantalla encendida
    WakelockPlus.enable();
    
    // Inicializar juego
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGame();
    });
  }
  
  @override
  void dispose() {
    _comboController.dispose();
    WakelockPlus.disable();
    super.dispose();
  }
  
  void _initializeGame() {
    if (!_isInitialized) {
      ref.read(gameProvider.notifier).startNewGame();
      _isInitialized = true;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final gameInfo = ref.watch(gameInfoProvider);
    final playerData = ref.watch(playerProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: _buildAppBar(gameState, gameInfo),
      body: SafeArea(
        child: Column(
          children: [
            // Panel superior con puntuación y monedas
            _buildTopPanel(gameInfo),
            
            // Tablero de juego
            Expanded(
              flex: 4,
              child: Center(
                child: _buildGameBoard(gameState),
              ),
            ),
            
            // Panel inferior con piezas disponibles
            Expanded(
              flex: 1,
              child: _buildPiecesPanel(gameState, playerData),
            ),
          ],
        ),
      ),
    );
  }
  
  PreferredSizeWidget _buildAppBar(GameState gameState, GameInfo gameInfo) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.pause, color: AppTheme.primaryText),
        onPressed: _showPauseMenu,
      ),
      title: ScoreDisplay(
        score: gameInfo.score,
        fontSize: 24,
        showAnimation: true,
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.secondaryAccent.withOpacity(0.3),
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
                'Nvl ${gameInfo.level}',
                style: TextStyle(
                  color: AppTheme.primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTopPanel(GameInfo gameInfo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Líneas limpiadas
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.horizontal_rule,
                  color: AppTheme.successColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${gameInfo.linesCleared}',
                  style: TextStyle(
                    color: AppTheme.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // Monedas ganadas en esta partida
          if (gameInfo.coinsEarned > 0)
            CoinRewardDisplay(
              amount: gameInfo.coinsEarned,
            ),
          
          // Combo activo
          if (gameInfo.comboMultiplier > 1)
            ComboDisplay(
              multiplier: gameInfo.comboMultiplier,
              message: gameInfo.lastComboMessage,
              onAnimationComplete: () {
                _comboController.reset();
              },
            ),
        ],
      ),
    );
  }
  
  Widget _buildGameBoard(GameState gameState) {
    if (gameState.isGameOver) {
      return _buildGameOverOverlay();
    }
    
    return Stack(
      children: [
        // Tablero principal
        DragTarget<Piece>(
          onAccept: (piece) {
            // El drag&drop se maneja en el tablero
          },
          builder: (context, candidateData, rejectedData) {
            return AnimatedBoardWidget(
              board: gameState.board,
              clearedLines: [], // Se actualizaría cuando se limpien líneas
            );
          },
        ),
        
        // Overlay de combo
        if (gameState.comboMultiplier > 1)
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: ComboDisplay(
                  multiplier: gameState.comboMultiplier,
                  message: gameState.lastComboMessage,
                  onAnimationComplete: () {
                    _comboController.reset();
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildPiecesPanel(GameState gameState, playerData) {
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: gameState.availablePieces.map((piece) {
                return Expanded(
                  child: Center(
                    child: DragTarget<Piece>(
                      onAccept: (draggedPiece) {
                        // Manejar el drop en el tablero
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Draggable<Piece>(
                          data: piece,
                          feedback: Material(
                            color: Colors.transparent,
                            child: Transform.scale(
                              scale: 1.2,
                              child: Opacity(
                                opacity: 0.8,
                                child: PieceWidget(
                                  piece: piece,
                                  scale: 0.8,
                                ),
                              ),
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: PieceWidget(
                              piece: piece,
                              scale: 0.8,
                            ),
                          ),
                          child: PieceWidget(
                            piece: piece,
                            scale: 0.8,
                            isDraggable: true,
                          ),
                        );
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGameOverOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sentiment_very_dissatisfied,
              color: AppTheme.dangerColor,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              '¡GAME OVER!',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: AppTheme.dangerColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Volver al menú',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
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
                ref.read(gameProvider.notifier).togglePause();
              },
            ),
            ListTile(
              leading: Icon(Icons.refresh, color: AppTheme.secondaryAccent),
              title: Text(
                'Reiniciar',
                style: TextStyle(color: AppTheme.primaryText),
              ),
              onTap: () {
                Navigator.of(context).pop();
                ref.read(gameProvider.notifier).startNewGame();
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
}

// Widget para mostrar recompensa de monedas
class CoinRewardDisplay extends StatelessWidget {
  final int amount;
  
  const CoinRewardDisplay({
    super.key,
    required this.amount,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.add_circle,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '+$amount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
