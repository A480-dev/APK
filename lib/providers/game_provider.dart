import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blockrush/models/piece.dart';
import 'package:blockrush/models/player_data.dart';
import 'package:blockrush/models/mission.dart';
import 'package:blockrush/utils/game_logic.dart';
import 'package:blockrush/utils/piece_generator.dart';
import 'package:blockrush/config/constants.dart';

// Modos de juego
enum GameMode {
  classic,
  endless,
  story,
}

// Estado del juego
class GameState {
  final List<List<BoardCell?>> board;
  final List<Piece> availablePieces;
  final int score;
  final int level;
  final int comboMultiplier;
  final bool isGameOver;
  final bool isPaused;
  final int linesCleared;
  final int coinsEarned;
  final String? lastComboMessage;
  final DateTime? lastComboTime;
  final GameMode gameMode;
  
  const GameState({
    this.board = const [],
    this.availablePieces = const [],
    this.score = 0,
    this.level = 1,
    this.comboMultiplier = 0,
    this.isGameOver = false,
    this.isPaused = false,
    this.linesCleared = 0,
    this.coinsEarned = 0,
    this.lastComboMessage,
    this.lastComboTime,
    this.gameMode = GameMode.classic,
  });
  
  GameState copyWith({
    List<List<BoardCell?>>? board,
    List<Piece>? availablePieces,
    int? score,
    int? level,
    int? comboMultiplier,
    bool? isGameOver,
    bool? isPaused,
    int? linesCleared,
    int? coinsEarned,
    String? lastComboMessage,
    DateTime? lastComboTime,
    GameMode? gameMode,
  }) {
    return GameState(
      board: board ?? this.board,
      availablePieces: availablePieces ?? this.availablePieces,
      score: score ?? this.score,
      level: level ?? this.level,
      comboMultiplier: comboMultiplier ?? this.comboMultiplier,
      isGameOver: isGameOver ?? this.isGameOver,
      isPaused: isPaused ?? this.isPaused,
      linesCleared: linesCleared ?? this.linesCleared,
      coinsEarned: coinsEarned ?? this.coinsEarned,
      lastComboMessage: lastComboMessage ?? this.lastComboMessage,
      lastComboTime: lastComboTime ?? this.lastComboTime,
      gameMode: gameMode ?? this.gameMode,
    );
  }
}

// Provider del estado del juego
class GameProvider extends StateNotifier<GameState> {
  GameProvider() : super(const GameState()) {
    _initializeGame();
  }
  
  // Inicializar juego
  void _initializeGame() {
    final emptyBoard = List.generate(
      GameConstants.boardSize,
      (y) => List.generate(GameConstants.boardSize, (x) => null),
    );
    
    final pieces = PieceGenerator.generateThreePieces(1);
    
    state = GameState(
      board: emptyBoard,
      availablePieces: pieces,
      level: 1,
    );
  }
  
  // Iniciar nuevo juego
  void startNewGame() {
    final emptyBoard = List.generate(
      GameConstants.boardSize,
      (y) => List.generate(GameConstants.boardSize, (x) => null),
    );
    
    final pieces = PieceGenerator.generateThreePieces(1);
    
    state = GameState(
      board: emptyBoard,
      availablePieces: pieces,
      score: 0,
      level: 1,
      comboMultiplier: 0,
      isGameOver: false,
      isPaused: false,
      linesCleared: 0,
      coinsEarned: 0,
    );
  }
  
  // Colocar pieza
  bool placePiece(Piece piece, int x, int y) {
    if (state.isGameOver || state.isPaused) return false;
    
    // Verificar si la pieza puede colocarse
    if (!piece.canPlaceAt(x, y, state.board)) return false;
    
    // Colocar pieza en el tablero
    final newBoard = GameLogic.placePiece(piece, x, y, state.board);
    
    // Limpiar líneas
    final clearResult = GameLogic.clearLines(newBoard);
    
    // Actualizar piezas disponibles
    final newPieces = List<Piece>.from(state.availablePieces);
    newPieces.remove(piece);
    
    // Generar nueva pieza si es necesario
    if (newPieces.length < GameConstants.maxPiecesInHand) {
      final newPiece = PieceGenerator.generateRandomPiece(
        state.level,
        newPieces.map((p) => p.colorHex).toSet(),
      );
      newPieces.add(newPiece);
    }
    
    // Calcular puntuación
    final pieceScore = piece.blockCount * GameConstants.pointsPerBlock;
    final totalScore = state.score + pieceScore + clearResult.score;
    
    // Verificar si sube de nivel
    final newLevel = _calculateNewLevel(totalScore);
    
    // Actualizar combo
    final comboMessage = _getComboMessage(clearResult.comboMultiplier);
    
    state = state.copyWith(
      board: clearResult.board,
      availablePieces: newPieces,
      score: totalScore,
      level: newLevel,
      comboMultiplier: clearResult.comboMultiplier,
      linesCleared: state.linesCleared + clearResult.lineCount,
      coinsEarned: state.coinsEarned + clearResult.coinsEarned,
      lastComboMessage: comboMessage,
      lastComboTime: comboMessage != null ? DateTime.now() : null,
    );
    
    // Verificar game over
    _checkGameOver();
    
    return true;
  }
  
  // Aplicar power-up de bomba
  bool applyBomb(int centerX, int centerY) {
    if (state.isGameOver || state.isPaused) return false;
    
    final newBoard = GameLogic.applyBomb(centerX, centerY, state.board);
    
    state = state.copyWith(board: newBoard);
    
    return true;
  }
  
  // Mezclar piezas (power-up shuffle)
  void shufflePieces() {
    if (state.isGameOver || state.isPaused) return;
    
    final newPieces = PieceGenerator.shufflePieces(state.level);
    
    state = state.copyWith(availablePieces: newPieces);
  }
  
  // Pausar/reanudar juego
  void togglePause() {
    state = state.copyWith(isPaused: !state.isPaused);
  }
  
  // Calcular nuevo nivel basado en puntuación
  int _calculateNewLevel(int score) {
    return (score ~/ GameConstants.pointsPerLevel) + 1;
  }
  
  // Obtener mensaje de combo
  String? _getComboMessage(int multiplier) {
    switch (multiplier) {
      case 0:
        return null;
      case 1:
        return null;
      case 2:
        return '¡COMBO x2!';
      case 3:
        return '¡MEGA COMBO!';
      case 4:
        return '¡ULTRA COMBO!';
      default:
        return '¡COMBO x$multiplier!';
    }
  }
  
  // Verificar si el juego ha terminado
  void _checkGameOver() {
    if (GameLogic.isGameOver(state.availablePieces, state.board)) {
      state = state.copyWith(isGameOver: true);
    }
  }
  
  // Obtener información del juego
  GameInfo getGameInfo() {
    return GameInfo(
      score: state.score,
      level: state.level,
      linesCleared: state.linesCleared,
      coinsEarned: state.coinsEarned,
      isGameOver: state.isGameOver,
      isPaused: state.isPaused,
      availablePieces: state.availablePieces.length,
      comboMultiplier: state.comboMultiplier,
      lastComboMessage: state.lastComboMessage,
    );
  }
  
  // Verificar si puede usar power-up
  bool canUsePowerUp(String powerUpType, int playerCoins) {
    switch (powerUpType) {
      case 'bomb':
        return playerCoins >= GameConstants.bombPrice;
      case 'shuffle':
        return playerCoins >= GameConstants.shufflePrice;
      case 'undo':
        return playerCoins >= GameConstants.undoPrice;
      case 'wildcard':
        return playerCoins >= GameConstants.wildcardPrice;
      default:
        return false;
    }
  }
  
  // Obtener precio de power-up
  int getPowerUpPrice(String powerUpType) {
    switch (powerUpType) {
      case 'bomb':
        return GameConstants.bombPrice;
      case 'shuffle':
        return GameConstants.shufflePrice;
      case 'undo':
        return GameConstants.undoPrice;
      case 'wildcard':
        return GameConstants.wildcardPrice;
      default:
        return 0;
    }
  }
}

// Información del juego
class GameInfo {
  final int score;
  final int level;
  final int linesCleared;
  final int coinsEarned;
  final bool isGameOver;
  final bool isPaused;
  final int availablePieces;
  final int comboMultiplier;
  final String? lastComboMessage;
  
  const GameInfo({
    required this.score,
    required this.level,
    required this.linesCleared,
    required this.coinsEarned,
    required this.isGameOver,
    required this.isPaused,
    required this.availablePieces,
    required this.comboMultiplier,
    this.lastComboMessage,
  });
}

// Provider
final gameProvider = StateNotifierProvider<GameProvider, GameState>((ref) {
  return GameProvider();
});

// Provider de información del juego
final gameInfoProvider = Provider<GameInfo>((ref) {
  return ref.watch(gameProvider.notifier).getGameInfo();
});
