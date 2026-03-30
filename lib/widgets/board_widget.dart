import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blockrush/models/piece.dart';
import 'package:blockrush/config/constants.dart';
import 'package:blockrush/config/theme.dart';

class BoardWidget extends ConsumerWidget {
  final List<List<BoardCell?>> board;
  final Piece? ghostPiece;
  final Function(int x, int y)? onCellTap;
  final Function(int x, int y)? onCellLongPress;
  
  const BoardWidget({
    super.key,
    required this.board,
    this.ghostPiece,
    this.onCellTap,
    this.onCellLongPress,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: GameConstants.boardSize * GameConstants.cellSize,
          height: GameConstants.boardSize * GameConstants.cellSize,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.surfaceColor,
                AppTheme.surfaceColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: GameConstants.boardSize,
              childAspectRatio: 1.0,
            ),
            itemCount: GameConstants.boardSize * GameConstants.boardSize,
            itemBuilder: (context, index) {
              final x = index % GameConstants.boardSize;
              final y = index ~/ GameConstants.boardSize;
              
              return _BoardCell(
                x: x,
                y: y,
                cell: board[y][x],
                isGhost: _isGhostCell(x, y),
                onTap: onCellTap != null ? () => onCellTap!(x, y) : null,
                onLongPress: onCellLongPress != null 
                    ? () => onCellLongPress!(x, y) 
                    : null,
              );
            },
          ),
        ),
      ),
    );
  }
  
  // Verificar si una celda es parte del ghost piece
  bool _isGhostCell(int x, int y) {
    if (ghostPiece == null) return false;
    
    for (int py = 0; py < ghostPiece!.height; py++) {
      for (int px = 0; px < ghostPiece!.width; px++) {
        if (ghostPiece!.shape[py][px]) {
          final ghostX = x; // Esto debería calcularse según la posición del ghost
          final ghostY = y;
          if (ghostX == x && ghostY == y) {
            return true;
          }
        }
      }
    }
    return false;
  }
}

class _BoardCell extends StatelessWidget {
  final int x;
  final int y;
  final BoardCell? cell;
  final bool isGhost;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  
  const _BoardCell({
    required this.x,
    required this.y,
    this.cell,
    this.isGhost = false,
    this.onTap,
    this.onLongPress,
  });
  
  @override
  Widget build(BuildContext context) {
    Widget child;
    
    if (isGhost && cell?.isEmpty != false) {
      // Ghost preview
      child = Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(GameConstants.cellRadius),
          border: Border.all(
            color: Colors.white.withOpacity(0.6),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
      );
    } else if (cell?.isBlocked == true) {
      // Celda bloqueada
      child = Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.grey[600],
          borderRadius: BorderRadius.circular(GameConstants.cellRadius),
          border: Border.all(
            color: Colors.grey[400]!,
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.lock,
          color: Colors.white,
          size: 16,
        ),
      );
    } else if (cell?.isEmpty == false) {
      // Celda ocupada
      child = Container(
        margin: const EdgeInsets.all(2),
        decoration: AppTheme.getBlockDecoration(cell!.color),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GameConstants.cellRadius - 2),
            gradient: RadialGradient(
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.transparent,
              ],
              center: const Alignment(-0.3, -0.3),
              radius: 0.8,
            ),
          ),
        ),
      );
    } else {
      // Celda vacía
      child = Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(GameConstants.cellRadius),
          border: Border.all(
            color: AppTheme.secondaryText.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      );
    }
    
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: child,
      ),
    );
  }
}

// Widget para el tablero con animaciones
class AnimatedBoardWidget extends StatefulWidget {
  final List<List<BoardCell?>> board;
  final List<int>? clearedLines;
  final Piece? ghostPiece;
  final Function(int x, int y)? onCellTap;
  
  const AnimatedBoardWidget({
    super.key,
    required this.board,
    this.clearedLines,
    this.ghostPiece,
    this.onCellTap,
  });
  
  @override
  State<AnimatedBoardWidget> createState() => _AnimatedBoardWidgetState();
}

class _AnimatedBoardWidgetState extends State<AnimatedBoardWidget>
    with TickerProviderStateMixin {
  late AnimationController _flashController;
  late AnimationController _shakeController;
  late Animation<double> _flashAnimation;
  late Animation<double> _shakeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _flashAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flashController,
      curve: Curves.easeInOut,
    ));
    
    _shakeAnimation = Tween<double>(
      begin: -5.0,
      end: 5.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
    
    if (widget.clearedLines != null && widget.clearedLines!.isNotEmpty) {
      _flashController.forward().then((_) {
        _flashController.reverse();
      });
    }
  }
  
  @override
  void didUpdateWidget(AnimatedBoardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.clearedLines != null && 
        widget.clearedLines!.isNotEmpty &&
        oldWidget.clearedLines != widget.clearedLines) {
      _flashController.forward().then((_) {
        _flashController.reverse();
      });
    }
  }
  
  @override
  void dispose() {
    _flashController.dispose();
    _shakeController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_flashAnimation, _shakeAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(_flashAnimation.value * 0.3),
                  blurRadius: 20 * _flashAnimation.value,
                  spreadRadius: 5 * _flashAnimation.value,
                ),
              ],
            ),
            child: BoardWidget(
              board: widget.board,
              ghostPiece: widget.ghostPiece,
              onCellTap: widget.onCellTap,
            ),
          ),
        );
      },
    );
  }
}

// Widget para preview de piezas
class PiecePreviewWidget extends StatelessWidget {
  final Piece piece;
  final double scale;
  
  const PiecePreviewWidget({
    super.key,
    required this.piece,
    this.scale = 1.0,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.secondaryText.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: SizedBox(
        width: piece.width * GameConstants.cellSize * scale,
        height: piece.height * GameConstants.cellSize * scale,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: piece.width,
            childAspectRatio: 1.0,
          ),
          itemCount: piece.width * piece.height,
          itemBuilder: (context, index) {
            final x = index % piece.width;
            final y = index ~/ piece.width;
            
            if (piece.shape[y][x]) {
              return Container(
                margin: const EdgeInsets.all(1),
                decoration: AppTheme.getBlockDecoration(piece.color),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}
