import 'package:blockrush/models/piece.dart';
import 'package:blockrush/config/constants.dart';

class GameLogic {
  // Colocar pieza en el tablero
  static List<List<BoardCell?>> placePiece(
    Piece piece,
    int x,
    int y,
    List<List<BoardCell?>> board,
  ) {
    final newBoard = _copyBoard(board);
    
    for (int py = 0; py < piece.height; py++) {
      for (int px = 0; px < piece.width; px++) {
        if (piece.shape[py][px]) {
          newBoard[y + py][x + px] = BoardCell(
            color: piece.color,
            colorHex: piece.colorHex,
          );
        }
      }
    }
    
    return newBoard;
  }
  
  // Limpiar líneas completas y retornar información
  static ClearResult clearLines(List<List<BoardCell?>> board) {
    final clearedLines = <int>[];
    final newBoard = _copyBoard(board);
    
    // Verificar y limpiar filas
    for (int y = 0; y < newBoard.length; y++) {
      if (_isRowFull(newBoard[y])) {
        clearedLines.add(y);
        _clearRow(newBoard, y);
      }
    }
    
    // Verificar y limpiar columnas
    for (int x = 0; x < newBoard[0].length; x++) {
      if (_isColumnFull(newBoard, x)) {
        clearedLines.add(-x - 1); // Negativo para identificar columnas
        _clearColumn(newBoard, x);
      }
    }
    
    // Calcular puntuación
    final score = _calculateClearScore(clearedLines);
    final comboMultiplier = _getComboMultiplier(clearedLines.length);
    
    return ClearResult(
      board: newBoard,
      clearedLines: clearedLines,
      score: score,
      comboMultiplier: comboMultiplier,
      coinsEarned: _calculateCoinsEarned(clearedLines.length, comboMultiplier),
    );
  }
  
  // Verificar si el juego ha terminado
  static bool isGameOver(List<Piece> availablePieces, List<List<BoardCell?>> board) {
    for (final piece in availablePieces) {
      if (_canPlacePieceAnywhere(piece, board)) {
        return false;
      }
    }
    return true;
  }
  
  // Aplicar power-up de bomba
  static List<List<BoardCell?>> applyBomb(
    int centerX,
    int centerY,
    List<List<BoardCell?>> board,
  ) {
    final newBoard = _copyBoard(board);
    
    for (int y = centerY - GameConstants.bombRadius; 
         y <= centerY + GameConstants.bombRadius; y++) {
      for (int x = centerX - GameConstants.bombRadius; 
           x <= centerX + GameConstants.bombRadius; x++) {
        if (y >= 0 && y < newBoard.length && 
            x >= 0 && x < newBoard[0].length) {
          final cell = newBoard[y][x];
          if (cell != null && !cell.isEmpty && !cell.isBlocked) {
            newBoard[y][x] = const BoardCell.empty();
          }
        }
      }
    }
    
    return newBoard;
  }
  
  // Generar celdas bloqueadas para niveles avanzados
  static List<List<BoardCell?>> generateBlockedCells(
    List<List<BoardCell?>> board,
    int level,
  ) {
    final newBoard = _copyBoard(board);
    
    if (level <= GameConstants.maxBasicLevel) {
      return newBoard; // Sin celdas bloqueadas en niveles básicos
    }
    
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    int blockedCount = 2;
    
    if (level > GameConstants.maxMediumLevel) {
      blockedCount = 4; // Más celdas bloqueadas en niveles duros
    }
    
    int placed = 0;
    while (placed < blockedCount) {
      final x = random % GameConstants.boardSize;
      final y = (random ~/ GameConstants.boardSize) % GameConstants.boardSize;
      
      if (newBoard[y][x] == null || newBoard[y][x]!.isEmpty) {
        newBoard[y][x] = const BoardCell.blocked();
        placed++;
      }
    }
    
    return newBoard;
  }
  
  // Verificar si se cumplen objetivos de color (niveles avanzados)
  static bool checkColorObjective(
    List<List<BoardCell?>> board,
    String targetColorHex,
    int requiredLines,
  ) {
    int colorLinesCleared = 0;
    
    // Verificar filas monocromáticas
    for (int y = 0; y < board.length; y++) {
      if (_isRowFull(board[y]) && _isRowMonochrome(board[y], targetColorHex)) {
        colorLinesCleared++;
      }
    }
    
    // Verificar columnas monocromáticas
    for (int x = 0; x < board[0].length; x++) {
      if (_isColumnFull(board, x) && _isColumnMonochrome(board, x, targetColorHex)) {
        colorLinesCleared++;
      }
    }
    
    return colorLinesCleared >= requiredLines;
  }
  
  // Copiar tablero
  static List<List<BoardCell?>> _copyBoard(List<List<BoardCell?>> board) {
    return board.map((row) => List.from(row)).toList();
  }
  
  // Verificar si una pieza puede colocarse en alguna parte
  static bool _canPlacePieceAnywhere(Piece piece, List<List<BoardCell?>> board) {
    for (int y = 0; y <= board.length - piece.height; y++) {
      for (int x = 0; x <= board[0].length - piece.width; x++) {
        if (piece.canPlaceAt(x, y, board)) {
          return true;
        }
      }
    }
    return false;
  }
  
  // Verificar si una fila está completa
  static bool _isRowFull(List<BoardCell?> row) {
    for (final cell in row) {
      if (cell == null || cell.isEmpty || cell.isBlocked) {
        return false;
      }
    }
    return true;
  }
  
  // Verificar si una columna está completa
  static bool _isColumnFull(List<List<BoardCell?>> board, int x) {
    for (int y = 0; y < board.length; y++) {
      final cell = board[y][x];
      if (cell == null || cell.isEmpty || cell.isBlocked) {
        return false;
      }
    }
    return true;
  }
  
  // Verificar si una fila es monocromática
  static bool _isRowMonochrome(List<BoardCell?> row, String targetColorHex) {
    for (final cell in row) {
      if (cell == null || cell.isEmpty || cell.colorHex != targetColorHex) {
        return false;
      }
    }
    return true;
  }
  
  // Verificar si una columna es monocromática
  static bool _isColumnMonochrome(List<List<BoardCell?>> board, int x, String targetColorHex) {
    for (int y = 0; y < board.length; y++) {
      final cell = board[y][x];
      if (cell == null || cell.isEmpty || cell.colorHex != targetColorHex) {
        return false;
      }
    }
    return true;
  }
  
  // Limpiar una fila
  static void _clearRow(List<List<BoardCell?>> board, int rowIndex) {
    for (int x = 0; x < board[rowIndex].length; x++) {
      final cell = board[rowIndex][x];
      if (cell != null && !cell.isBlocked) {
        board[rowIndex][x] = const BoardCell.empty();
      }
    }
  }
  
  // Limpiar una columna
  static void _clearColumn(List<List<BoardCell?>> board, int columnIndex) {
    for (int y = 0; y < board.length; y++) {
      final cell = board[y][columnIndex];
      if (cell != null && !cell.isBlocked) {
        board[y][columnIndex] = const BoardCell.empty();
      }
    }
  }
  
  // Calcular puntuación por limpiar líneas
  static int _calculateClearScore(List<int> clearedLines) {
    if (clearedLines.isEmpty) return 0;
    
    int score = 0;
    final lineCount = clearedLines.length;
    
    if (lineCount == 1) {
      score = GameConstants.pointsPerLine;
    } else if (lineCount == 2) {
      score = GameConstants.pointsPerLine * GameConstants.comboMultiplier2;
    } else if (lineCount == 3) {
      score = GameConstants.pointsPerLine * GameConstants.comboMultiplier3;
    } else {
      score = GameConstants.pointsPerLine * GameConstants.comboMultiplier4;
    }
    
    // Bonus si hay filas y columnas simultáneas
    final hasRows = clearedLines.any((index) => index >= 0);
    final hasColumns = clearedLines.any((index) => index < 0);
    if (hasRows && hasColumns) {
      score = (score * GameConstants.crossLineMultiplier ~/ 10);
    }
    
    return score;
  }
  
  // Obtener multiplicador de combo
  static int _getComboMultiplier(int lineCount) {
    if (lineCount == 0) return 0;
    if (lineCount == 1) return 1;
    if (lineCount == 2) return 2;
    if (lineCount == 3) return 3;
    return 4; // 4+ líneas
  }
  
  // Calcular monedas ganadas
  static int _calculateCoinsEarned(int lineCount, int comboMultiplier) {
    int coins = 0;
    
    if (lineCount >= 2) {
      coins += GameConstants.coinsForCombo3Plus;
    }
    
    if (comboMultiplier >= 3) {
      coins += GameConstants.coinsForCombo3Plus;
    }
    
    return coins;
  }
}

// Resultado de limpiar líneas
class ClearResult {
  final List<List<BoardCell?>> board;
  final List<int> clearedLines;
  final int score;
  final int comboMultiplier;
  final int coinsEarned;
  
  const ClearResult({
    required this.board,
    required this.clearedLines,
    required this.score,
    required this.comboMultiplier,
    required this.coinsEarned,
  });
  
  int get lineCount => clearedLines.length;
  bool get hasRows => clearedLines.any((index) => index >= 0);
  bool get hasColumns => clearedLines.any((index) => index < 0);
  bool get isColorBonus => false; // Se implementaría en versión avanzada
}
