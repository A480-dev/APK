import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:blockrush/config/theme.dart';
import 'package:blockrush/widgets/particle_burst.dart';

class MilestonePopup extends StatefulWidget {
  final String title;
  final String description;
  final String milestoneTitle;
  final int level;
  final int coinsReward;
  final List<String> powerUpsReward;
  final VoidCallback? onDismiss;
  
  const MilestonePopup({
    super.key,
    required this.title,
    required this.description,
    required this.milestoneTitle,
    required this.level,
    required this.coinsReward,
    this.powerUpsReward = const [],
    this.onDismiss,
  });
  
  @override
  State<MilestonePopup> createState() => _MilestonePopupState();
}

class _MilestonePopupState extends State<MilestonePopup>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.forward();
    
    // Auto-dismiss después de 5 segundos
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _dismiss();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _fadeAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: GestureDetector(
              onTap: _dismiss,
              child: Container(
                color: Colors.black.withOpacity(0.8),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(40),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryAccent.withOpacity(0.9),
                          AppTheme.secondaryAccent.withOpacity(0.9),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryAccent.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icono de celebración
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: const Icon(
                            Icons.emoji_events,
                            color: Colors.white,
                            size: 40,
                          ),
                        ).animate(onPlay: (controller) => controller.repeat())
                          .rotate(
                            begin: -0.1,
                            end: 0.1,
                            duration: const Duration(milliseconds: 1000),
                          )
                          .then()
                          .rotate(
                            begin: 0.1,
                            end: -0.1,
                            duration: const Duration(milliseconds: 1000),
                          ),
                        
                        const SizedBox(height: 20),
                        
                        // Título principal
                        Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Título del hito
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            widget.milestoneTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Descripción
                        Text(
                          widget.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Nivel alcanzado
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.layers,
                              color: Colors.white.withOpacity(0.8),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Nivel ${widget.level}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Recompensas
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              // Monedas
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.monetization_on,
                                    color: Color(0xFFFFD700),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '+${widget.coinsReward}',
                                    style: const TextStyle(
                                      color: Color(0xFFFFD700),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              
                              if (widget.powerUpsReward.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                
                                // Power-ups
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Power-ups:',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...widget.powerUpsReward.map((powerUp) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.flash_on,
                                              color: Colors.white.withOpacity(0.8),
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              powerUp,
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.9),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Botón de continuar
                        GestureDetector(
                          onTap: _dismiss,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              '¡Continuar!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Widget para mostrar popup de hito desbloqueado
class MilestoneUnlockedPopup extends StatelessWidget {
  final int level;
  final String title;
  final VoidCallback? onDismiss;
  
  const MilestoneUnlockedPopup({
    super.key,
    required this.level,
    required this.title,
    this.onDismiss,
  });
  
  @override
  Widget build(BuildContext context) {
    return MilestonePopup(
      title: '¡HITO DESBLOQUEADO!',
      description: 'Has alcanzado un hito importante en tu viaje infinito. El universo reconoce tu progreso.',
      milestoneTitle: title,
      level: level,
      coinsReward: 500,
      powerUpsReward: ['Bomba', 'Shuffle', 'Deshacer'],
      onDismiss: onDismiss,
    );
  }
}

// Widget para mostrar popup de título desbloqueado
class TitleUnlockedPopup extends StatelessWidget {
  final String title;
  final int level;
  final VoidCallback? onDismiss;
  
  const TitleUnlockedPopup({
    super.key,
    required this.title,
    required this.level,
    this.onDismiss,
  });
  
  @override
  Widget build(BuildContext context) {
    return MilestonePopup(
      title: '¡NUEVO TÍTULO!',
      description: 'Has desbloqueado un nuevo título que refleja tu maestría en el modo infinito. Muéstralo con orgullo.',
      milestoneTitle: title,
      level: level,
      coinsReward: 200,
      powerUpsReward: ['Comodín'],
      onDismiss: onDismiss,
    );
  }
}

// Widget para mostrar popup de celebración
class CelebrationPopup extends StatelessWidget {
  final String title;
  final String message;
  final int coinsReward;
  final VoidCallback? onDismiss;
  
  const CelebrationPopup({
    super.key,
    required this.title,
    required this.message,
    this.coinsReward = 0,
    this.onDismiss,
  });
  
  @override
  Widget build(BuildContext context) {
    return MilestonePopup(
      title: title,
      description: message,
      milestoneTitle: 'Celebración',
      level: 0,
      coinsReward: coinsReward,
      onDismiss: onDismiss,
    );
  }
}
