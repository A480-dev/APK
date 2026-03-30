import 'dart:math';
import 'package:flutter/material.dart';
import 'package:blockrush/models/piece.dart';
import 'package:blockrush/config/constants.dart';

class PieceGenerator {
  static final Random _random = Random();
  
  // Generar piezas disponibles según el nivel
  static List<PieceType> getAvailablePieces(int level) {
    final pieces = <PieceType>[
      PieceType.square2x2,
      PieceType.lShape,
      PieceType.lShapeInverse,
      PieceType.line3,
      PieceType.line2,
      PieceType.line1x3,
      PieceType.tShape,
      PieceType.sShape,
      PieceType.zShape,
      PieceType.single,
    ];
    
    // Añadir piezas complejas para niveles avanzados
    if (level > GameConstants.maxBasicLevel) {
      pieces.addAll([
        PieceType.lShapeLarge,
        PieceType.cross,
        PieceType.diagonal,
      ]);
    }
    
    return pieces;
  }
  
  // Generar una pieza aleatoria
  static Piece generateRandomPiece(int level, Set<String> usedColors) {
    final availableTypes = getAvailablePieces(level);
    final type = availableTypes[_random.nextInt(availableTypes.length)];
    
    // Seleccionar color que no esté en uso
    final availableColors = GameConstants.blockColors.where(
      (color) => !usedColors.contains(color)
    ).toList();
    
    // Si todos los colores están en uso, usar cualquiera
    final colorHex = availableColors.isNotEmpty 
        ? availableColors[_random.nextInt(availableColors.length)]
        : GameConstants.blockColors[_random.nextInt(GameConstants.blockColors.length)];
    
    final color = _hexToColor(colorHex);
    
    return Piece.fromType(type, color, colorHex);
  }
  
  // Generar 3 piezas para el jugador
  static List<Piece> generateThreePieces(int level) {
    final pieces = <Piece>[];
    final usedColors = <String>{};
    
    for (int i = 0; i < GameConstants.maxPiecesInHand; i++) {
      final piece = generateRandomPiece(level, usedColors);
      pieces.add(piece);
      usedColors.add(piece.colorHex);
    }
    
    return pieces;
  }
  
  // Regenerar las 3 piezas actuales (power-up Shuffle)
  static List<Piece> shufflePieces(int level) {
    return generateThreePieces(level);
  }
  
  // Generar pieza comodín (power-up Wildcard)
  static Piece generateWildcardPiece() {
    // El comodín es una pieza 1x1 de cualquier color
    final colorHex = GameConstants.blockColors[
        _random.nextInt(GameConstants.blockColors.length)];
    final color = _hexToColor(colorHex);
    
    return Piece.fromType(PieceType.single, color, colorHex);
  }
  
  // Convertir color hex a Color
  static Color _hexToColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }
  
  // Verificar si hay movimientos posibles
  static bool hasValidMoves(List<Piece> pieces, List<List<BoardCell?>> board) {
    for (final piece in pieces) {
      if (_canPlacePieceAnywhere(piece, board)) {
        return true;
      }
    }
    return false;
  }
  
  // Verificar si una pieza puede colocarse en alguna parte del tablero
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
  
  // Obtener sugerencia de movimiento (para tutoriales o ayuda)
  static Map<String, int>? getSuggestedMove(Piece piece, List<List<BoardCell?>> board) {
    for (int y = 0; y <= board.length - piece.height; y++) {
      for (int x = 0; x <= board[0].length - piece.width; x++) {
        if (piece.canPlaceAt(x, y, board)) {
          // Calcular puntuación potencial de este movimiento
          final score = _calculateMoveScore(piece, x, y, board);
          return {'x': x, 'y': y, 'score': score};
        }
      }
    }
    return null;
  }
  
  // Calcular puntuación potencial de un movimiento
  static int _calculateMoveScore(Piece piece, int x, int y, List<List<BoardCell?>> board) {
    int score = piece.blockCount * GameConstants.pointsPerBlock;
    
    // Simular colocación
    final tempBoard = _copyBoard(board);
    _placePieceOnBoard(piece, x, y, tempBoard);
    
    // Verificar líneas que se limpiarían
    final clearedLines = _getClearedLines(tempBoard);
    score += clearedLines.length * GameConstants.pointsPerLine;
    
    // Bonus por múltiples líneas
    if (clearedLines.length >= 2) {
      score *= clearedLines.length;
    }
    
    return score;
  }
  
  // Copiar tablero
  static List<List<BoardCell?>> _copyBoard(List<List<BoardCell?>> board) {
    return board.map((row) => List.from(row)).toList();
  }
  
  // Colocar pieza en tablero simulado
  static void _placePieceOnBoard(Piece piece, int x, int y, List<List<BoardCell?>> board) {
    for (int py = 0; py < piece.height; py++) {
      for (int px = 0; px < piece.width; px++) {
        if (piece.shape[py][px]) {
          board[y + py][x + px] = BoardCell(
            color: piece.color,
            colorHex: piece.colorHex,
          );
        }
      }
    }
  }
  
  // Obtener líneas que serían limpiadas
  static List<int> _getClearedLines(List<List<BoardCell?>> board) {
    final clearedLines = <int>[];
    
    // Verificar filas
    for (int y = 0; y < board.length; y++) {
      if (_isRowFull(board[y])) {
        clearedLines.add(y);
      }
    }
    
    // Verificar columnas
    for (int x = 0; x < board[0].length; x++) {
      if (_isColumnFull(board, x)) {
        clearedLines.add(-x - 1); // Negativo para diferenciar columnas
      }
    }
    
    return clearedLines;
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
}
