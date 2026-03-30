import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:blockrush/providers/player_provider.dart';
import 'package:blockrush/config/theme.dart';

class CoinDisplay extends ConsumerWidget {
  final int? coins;
  final double fontSize;
  final bool showAnimation;
  final VoidCallback? onTap;
  
  const CoinDisplay({
    super.key,
    this.coins,
    this.fontSize = 20,
    this.showAnimation = true,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCoins = coins ?? ref.watch(coinsProvider);
    final previousCoins = ref.watch(playerProvider.select((data) => data.coins));
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.monetization_on,
              color: Colors.white,
              size: fontSize * 0.9,
            ),
            const SizedBox(width: 6),
            Text(
              _formatCoins(currentCoins),
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                shadows: [
                  const Shadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate(target: showAnimation && currentCoins != previousCoins ? currentCoins : null)
        .scaleXY(
          begin: 1.2,
          end: 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
        )
        .shake(
          hz: 4,
          duration: const Duration(milliseconds: 300),
        ),
    );
  }
  
  String _formatCoins(int coins) {
    if (coins >= 1000000) {
      return '${(coins / 1000000).toStringAsFixed(1)}M';
    } else if (coins >= 1000) {
      return '${(coins / 1000).toStringAsFixed(1)}K';
    }
    return coins.toString();
  }
}

// Widget para animación de monedas ganadas
class CoinEarnedAnimation extends StatefulWidget {
  final int amount;
  final Offset startPosition;
  final VoidCallback? onComplete;
  
  const CoinEarnedAnimation({
    super.key,
    required this.amount,
    required this.startPosition,
    this.onComplete,
  });
  
  @override
  State<CoinEarnedAnimation> createState() => _CoinEarnedAnimationState();
}

class _CoinEarnedAnimationState extends State<CoinEarnedAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _positionAnimation = Tween<Offset>(
      begin: widget.startPosition,
      end: const Offset(0, -100),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.5,
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
      widget.onComplete?.call();
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_positionAnimation, _scaleAnimation, _fadeAnimation]),
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx,
          top: _positionAnimation.value.dy,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '+${widget.amount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Widget para mostrar recompensa de monedas
class CoinRewardWidget extends StatelessWidget {
  final int amount;
  final String? label;
  final VoidCallback? onClaim;
  final bool isClaimed;
  
  const CoinRewardWidget({
    super.key,
    required this.amount,
    this.label,
    this.onClaim,
    this.isClaimed = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isClaimed 
            ? LinearGradient(
                colors: [Colors.grey[400]!, Colors.grey[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isClaimed 
                ? Colors.grey.withOpacity(0.3)
                : const Color(0xFFFFD700).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isClaimed ? Icons.check_circle : Icons.monetization_on,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 8),
          if (label != null) ...[
            Text(
              label!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
          ],
          Text(
            '+$amount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
          if (!isClaimed && onClaim != null) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onClaim,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFFFA000),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'RECLAMAR',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Widget para mostrar costo de power-up
class PowerUpCostWidget extends StatelessWidget {
  final int cost;
  final bool canAfford;
  final double fontSize;
  
  const PowerUpCostWidget({
    super.key,
    required this.cost,
    required this.canAfford,
    this.fontSize = 16,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: canAfford 
            ? const Color(0xFFFFD700).withOpacity(0.2)
            : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: canAfford 
              ? const Color(0xFFFFD700)
              : Colors.grey,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.monetization_on,
            color: canAfford 
                ? const Color(0xFFFFD700)
                : Colors.grey,
            size: fontSize * 0.9,
          ),
          const SizedBox(width: 4),
          Text(
            cost.toString(),
            style: TextStyle(
              color: canAfford 
                  ? const Color(0xFFFFD700)
                  : Colors.grey,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
