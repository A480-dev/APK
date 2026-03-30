import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:blockrush/config/theme.dart';

class ScoreDisplay extends ConsumerWidget {
  final int score;
  final int? previousScore;
  final String? label;
  final double fontSize;
  final bool showAnimation;
  
  const ScoreDisplay({
    super.key,
    required this.score,
    this.previousScore,
    this.label,
    this.fontSize = 28,
    this.showAnimation = true,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasIncreased = previousScore != null && score > previousScore!;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.secondaryText,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasIncreased && showAnimation) ...[
              Icon(
                Icons.arrow_upward,
                color: AppTheme.successColor,
                size: fontSize * 0.6,
              ).animate().slideY(
                begin: -0.5,
                end: 0,
                duration: const Duration(milliseconds: 300),
              ).then().fadeOut(
                duration: const Duration(milliseconds: 200),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              _formatScore(score),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppTheme.primaryText,
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(
                    color: AppTheme.primaryAccent.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ).animate(target: hasIncreased ? score : null).scaleXY(
              begin: 1.2,
              end: 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
            ),
          ],
        ),
      ],
    );
  }
  
  String _formatScore(int score) {
    if (score >= 1000000) {
      return '${(score / 1000000).toStringAsFixed(1)}M';
    } else if (score >= 1000) {
      return '${(score / 1000).toStringAsFixed(1)}K';
    }
    return score.toString();
  }
}

// Widget para mostrar combo
class ComboDisplay extends StatefulWidget {
  final int multiplier;
  final String? message;
  final VoidCallback? onAnimationComplete;
  
  const ComboDisplay({
    super.key,
    required this.multiplier,
    this.message,
    this.onAnimationComplete,
  });
  
  @override
  State<ComboDisplay> createState() => _ComboDisplayState();
}

class _ComboDisplayState extends State<ComboDisplay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.2, curve: Curves.easeIn),
    ));
    
    _controller.forward().then((_) {
      widget.onAnimationComplete?.call();
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (widget.multiplier <= 1) return const SizedBox.shrink();
    
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _fadeAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: _getComboGradient(),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: _getComboColor().withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.message ?? _getComboMessage(),
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      shadows: [
                        const Shadow(
                          color: Colors.black,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.multiplier > 2) ...[
                    const SizedBox(height: 4),
                    Text(
                      '×${widget.multiplier}',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  String _getComboMessage() {
    switch (widget.multiplier) {
      case 2:
        return '¡COMBO!';
      case 3:
        return '¡MEGA COMBO!';
      case 4:
        return '¡ULTRA COMBO!';
      default:
        return '¡COMBO ×${widget.multiplier}!';
    }
  }
  
  LinearGradient _getComboGradient() {
    switch (widget.multiplier) {
      case 2:
        return AppTheme.primaryGradient;
      case 3:
        return const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 4:
        return const LinearGradient(
          colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFFFF5722), Color(0xFFD32F2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
  
  Color _getComboColor() {
    switch (widget.multiplier) {
      case 2:
        return AppTheme.primaryAccent;
      case 3:
        return const Color(0xFFFF9800);
      case 4:
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFFFF5722);
    }
  }
}

// Widget para mostrar estadísticas del juego
class GameStatsWidget extends StatelessWidget {
  final int score;
  final int level;
  final int linesCleared;
  final int coinsEarned;
  
  const GameStatsWidget({
    super.key,
    required this.score,
    required this.level,
    required this.linesCleared,
    required this.coinsEarned,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.secondaryText.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _StatRow(
            icon: Icons.star,
            label: 'Puntuación',
            value: _formatScore(score),
            color: AppTheme.primaryAccent,
          ),
          const SizedBox(height: 12),
          _StatRow(
            icon: Icons.layers,
            label: 'Nivel',
            value: level.toString(),
            color: AppTheme.secondaryAccent,
          ),
          const SizedBox(height: 12),
          _StatRow(
            icon: Icons.horizontal_rule,
            label: 'Líneas',
            value: linesCleared.toString(),
            color: AppTheme.successColor,
          ),
          const SizedBox(height: 12),
          _StatRow(
            icon: Icons.monetization_on,
            label: 'Monedas',
            value: coinsEarned.toString(),
            color: const Color(0xFFFFD700),
          ),
        ],
      ),
    );
  }
  
  String _formatScore(int score) {
    if (score >= 1000000) {
      return '${(score / 1000000).toStringAsFixed(1)}M';
    } else if (score >= 1000) {
      return '${(score / 1000).toStringAsFixed(1)}K';
    }
    return score.toString();
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.secondaryText,
            ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
