import 'package:flutter/material.dart';
import 'package:blockrush/config/constants.dart';

class Piece {
  final List<List<bool>> shape;
  final Color color;
  final String colorHex;
  
  const Piece({
    required this.shape,
    required this.color,
    required this.colorHex,
  });
  
  // Constructor para crear una pieza desde un tipo predefinido
  factory Piece.fromType(PieceType type, Color color, String colorHex) {
    return Piece(
      shape: _getShapeForType(type),
      color: color,
      colorHex: colorHex,
    );
  }
  
  // Obtener las dimensiones de la pieza
  int get width => shape.isNotEmpty ? shape[0].length : 0;
  int get height => shape.length;
  
  // Obtener el número de bloques en la pieza
  int get blockCount {
    int count = 0;
    for (final row in shape) {
      for (final cell in row) {
        if (cell) count++;
      }
    }
    return count;
  }
  
  // Rotar la pieza 90 grados en sentido horario
  Piece get rotated {
    if (width == height) return this; // Las piezas cuadradas no cambian al rotar
    
    final newShape = List.generate(
      width,
      (i) => List.generate(
        height,
        (j) => shape[height - 1 - j][i],
      ),
    );
    
    return Piece(
      shape: newShape,
      color: color,
      colorHex: colorHex,
    );
  }
  
  // Verificar si la pieza puede colocarse en una posición dada
  bool canPlaceAt(int boardX, int boardY, List<List<BoardCell?>> board) {
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (shape[y][x]) {
          final boardY = boardY + y;
          final boardX = boardX + x;
          
          // Verificar límites del tablero
          if (boardY >= board.length || boardX >= board[0].length || 
              boardY < 0 || boardX < 0) {
            return false;
          }
          
          // Verificar si la celda está ocupada o bloqueada
          final cell = board[boardY][boardX];
          if (cell != null && !cell.isEmpty) {
            return false;
          }
        }
      }
    }
    return true;
  }
  
  // Copia de la pieza
  Piece copyWith({
    List<List<bool>>? shape,
    Color? color,
    String? colorHex,
  }) {
    return Piece(
      shape: shape ?? this.shape,
      color: color ?? this.color,
      colorHex: colorHex ?? this.colorHex,
    );
  }
  
  // Obtener la forma para un tipo específico
  static List<List<bool>> _getShapeForType(PieceType type) {
    switch (type) {
      case PieceType.square2x2:
        return [
          [true, true],
          [true, true],
        ];
      case PieceType.lShape:
        return [
          [true, false],
          [true, false],
          [true, true],
        ];
      case PieceType.lShapeInverse:
        return [
          [false, true],
          [false, true],
          [true, true],
        ];
      case PieceType.line3:
        return [
          [true, true, true],
        ];
      case PieceType.line2:
        return [
          [true, true],
        ];
      case PieceType.line1x3:
        return [
          [true],
          [true],
          [true],
        ];
      case PieceType.tShape:
        return [
          [true, true, true],
          [false, true, false],
        ];
      case PieceType.sShape:
        return [
          [false, true, true],
          [true, true, false],
        ];
      case PieceType.zShape:
        return [
          [true, true, false],
          [false, true, true],
        ];
      case PieceType.single:
        return [
          [true],
        ];
      case PieceType.lShapeLarge:
        return [
          [true, false, false],
          [true, false, false],
          [true, true, true],
        ];
      case PieceType.cross:
        return [
          [false, true, false],
          [true, true, true],
          [false, true, false],
        ];
      case PieceType.diagonal:
        return [
          [true, false, false],
          [false, true, false],
          [false, false, true],
        ];
    }
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Piece &&
        other.shape.toString() == shape.toString() &&
        other.color == color;
  }
  
  @override
  int get hashCode => shape.hashCode ^ color.hashCode;
  
  @override
  String toString() {
    return 'Piece(color: $colorHex, blocks: $blockCount, shape: ${width}x$height)';
  }
}

// Tipos de piezas disponibles
enum PieceType {
  square2x2,
  lShape,
  lShapeInverse,
  line3,
  line2,
  line1x3,
  tShape,
  sShape,
  zShape,
  single,
  lShapeLarge,
  cross,
  diagonal,
}

// Clase para representar una celda del tablero
class BoardCell {
  final Color color;
  final String colorHex;
  final bool isEmpty;
  final bool isBlocked;
  
  const BoardCell({
    required this.color,
    required this.colorHex,
    this.isEmpty = false,
    this.isBlocked = false,
  });
  
  // Celda vacía
  const BoardCell.empty()
      : color = Colors.transparent,
        colorHex = '#000000',
        isEmpty = true,
        isBlocked = false;
  
  // Celda bloqueada (para niveles avanzados)
  const BoardCell.blocked()
      : color = Colors.grey,
        colorHex = '#808080',
        isEmpty = false,
        isBlocked = true;
  
  BoardCell copyWith({
    Color? color,
    String? colorHex,
    bool? isEmpty,
    bool? isBlocked,
  }) {
    return BoardCell(
      color: color ?? this.color,
      colorHex: colorHex ?? this.colorHex,
      isEmpty: isEmpty ?? this.isEmpty,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BoardCell &&
        other.color == color &&
        other.isEmpty == isEmpty &&
        other.isBlocked == isBlocked;
  }
  
  @override
  int get hashCode => color.hashCode ^ isEmpty.hashCode ^ isBlocked.hashCode;
}
