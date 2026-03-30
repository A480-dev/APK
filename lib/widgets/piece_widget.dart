import 'package:flutter/material.dart';
import 'package:blockrush/models/piece.dart';
import 'package:blockrush/config/constants.dart';
import 'package:blockrush/config/theme.dart';

class PieceWidget extends StatefulWidget {
  final Piece piece;
  final double scale;
  final bool isDraggable;
  final VoidCallback? onTap;
  final Function(Piece piece, int x, int y)? onPiecePlaced;
  
  const PieceWidget({
    super.key,
    required this.piece,
    this.scale = 1.0,
    this.isDraggable = true,
    this.onTap,
    this.onPiecePlaced,
  });
  
  @override
  State<PieceWidget> createState() => _PieceWidgetState();
}

class _PieceWidgetState extends State<PieceWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _hoverController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _hoverAnimation;
  
  bool _isHovered = false;
  bool _isDragging = false;
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _hoverAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _hoverController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final child = _buildPieceGrid();
    
    if (!widget.isDraggable) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, _) {
          return Transform.scale(
            scale: _pulseAnimation.value * widget.scale,
            child: child,
          );
        },
      );
    }
    
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _hoverAnimation]),
      builder: (context, _) {
        return Transform.scale(
          scale: (_isHovered ? _hoverAnimation.value : _pulseAnimation.value) * widget.scale,
          child: Draggable<Piece>(
            data: widget.piece,
            feedback: Material(
              color: Colors.transparent,
              child: Transform.scale(
                scale: 1.2,
                child: Opacity(
                  opacity: 0.8,
                  child: child,
                ),
              ),
            ),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: child,
            ),
            onDragStarted: () {
              setState(() {
                _isDragging = true;
              });
            },
            onDragEnd: (details) {
              setState(() {
                _isDragging = false;
                _isHovered = false;
              });
            },
            child: GestureDetector(
              onTap: widget.onTap,
              onTapDown: (_) => _handleHover(true),
              onTapUp: (_) => _handleHover(false),
              onTapCancel: () => _handleHover(false),
              child: child,
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildPieceGrid() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: widget.piece.color.withOpacity(0.3),
            blurRadius: _isDragging ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        width: widget.piece.width * GameConstants.cellSize * widget.scale,
        height: widget.piece.height * GameConstants.cellSize * widget.scale,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.piece.width,
            childAspectRatio: 1.0,
          ),
          itemCount: widget.piece.width * widget.piece.height,
          itemBuilder: (context, index) {
            final x = index % widget.piece.width;
            final y = index ~/ widget.piece.width;
            
            if (widget.piece.shape[y][x]) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.all(2 * widget.scale),
                decoration: BoxDecoration(
                  color: widget.piece.color,
                  borderRadius: BorderRadius.circular(
                    GameConstants.cellRadius * widget.scale,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.piece.color.withOpacity(0.5),
                      blurRadius: 4 * widget.scale,
                      offset: Offset(0, 2 * widget.scale),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      (GameConstants.cellRadius - 2) * widget.scale,
                    ),
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
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
  
  void _handleHover(bool hovered) {
    if (_isHovered != hovered) {
      setState(() {
        _isHovered = hovered;
      });
      
      if (hovered) {
        _hoverController.forward();
      } else {
        _hoverController.reverse();
      }
    }
  }
}

// Widget para arrastrar piezas al tablero
class DraggablePieceWidget extends StatelessWidget {
  final Piece piece;
  final Function(Piece piece, int x, int y) onPiecePlaced;
  
  const DraggablePieceWidget({
    super.key,
    required this.piece,
    required this.onPiecePlaced,
  });
  
  @override
  Widget build(BuildContext context) {
    return DragTarget<Piece>(
      onAcceptWithDetails: (details) {
        // Esto se maneja en el tablero
      },
      builder: (context, candidateData, rejectedData) {
        return PieceWidget(
          piece: piece,
          isDraggable: true,
          onPiecePlaced: onPiecePlaced,
        );
      },
    );
  }
}

// Widget para contenedor de piezas disponibles
class PiecesContainerWidget extends StatelessWidget {
  final List<Piece> pieces;
  final Function(Piece piece, int x, int y)? onPiecePlaced;
  
  const PiecesContainerWidget({
    super.key,
    required this.pieces,
    required this.onPiecePlaced,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.secondaryText.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: pieces.map((piece) {
          return Expanded(
            child: Center(
              child: DraggablePieceWidget(
                piece: piece,
                onPiecePlaced: onPiecePlaced,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Widget para pieza comodín especial
class WildcardPieceWidget extends StatefulWidget {
  final VoidCallback? onTap;
  
  const WildcardPieceWidget({
    super.key,
    this.onTap,
  });
  
  @override
  State<WildcardPieceWidget> createState() => _WildcardPieceWidgetState();
}

class _WildcardPieceWidgetState extends State<WildcardPieceWidget>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    _glowController.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, _) {
        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: GameConstants.cellSize,
            height: GameConstants.cellSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(GameConstants.cellRadius),
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryAccent.withOpacity(_glowAnimation.value),
                  AppTheme.secondaryAccent.withOpacity(_glowAnimation.value),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryAccent.withOpacity(_glowAnimation.value * 0.5),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 20,
            ),
          ),
        );
      },
    );
  }
}
