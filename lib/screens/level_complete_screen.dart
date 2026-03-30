import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:blockrush/config/theme.dart';
import 'package:blockrush/config/constants.dart';
import 'package:blockrush/providers/player_provider.dart';
import 'package:blockrush/widgets/score_display.dart';
import 'package:blockrush/widgets/particle_burst.dart';
import 'package:blockrush/services/audio_service.dart';
import 'package:blockrush/services/haptic_service.dart';
import 'package:blockrush/screens/game_screen.dart';

class LevelCompleteScreen extends ConsumerStatefulWidget {
  final int level;
  final int score;
  final int coinsEarned;
  final VoidCallback? onNextLevel;
  
  const LevelCompleteScreen({
    super.key,
    required this.level,
    required this.score,
    required this.coinsEarned,
    this.onNextLevel,
  });

  @override
  ConsumerState<LevelCompleteScreen> createState() => _LevelCompleteScreenState();
}

class _LevelCompleteScreenState extends ConsumerState<LevelCompleteScreen>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _starController;
  late AnimationController _buttonController;
  late Animation<double> _starAnimation;
  late Animation<double> _buttonAnimation;
  
  bool _showConfetti = false;
  
  @override
  void initState() {
    super.initState();
    
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: GameConstants.particleDuration),
      vsync: this,
    );
    
    _starController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _starAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _starController,
      curve: Curves.elasticOut,
    ));
    
    _buttonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));
    
    _initializeScreen();
  }
  
  @override
  void dispose() {
    _confettiController.dispose();
    _starController.dispose();
    _buttonController.dispose();
    super.dispose();
  }
  
  Future<void> _initializeScreen() async {
    // Reproducir efectos de celebración
    await AudioService.playLevelUp();
    await HapticService.victoryPattern();
    
    // Mostrar confetti
    setState(() {
      _showConfetti = true;
    });
    
    // Iniciar animación de estrellas
    Future.delayed(const Duration(milliseconds: 500), () {
      _starController.forward();
    });
    
    // Iniciar animación de botones
    Future.delayed(const Duration(milliseconds: 1200), () {
      _buttonController.forward();
    });
    
    // Añadir monedas y subir de nivel
    await ref.read(playerProvider.notifier).addCoins(widget.coinsEarned);
    await ref.read(playerProvider.notifier).levelUp();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Confetti de fondo
              if (_showConfetti)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Stack(
                      children: [
                        // Confetti superior izquierdo
                        Positioned(
                          top: 100,
                          left: 50,
                          child: ParticleBurst(
                            particleCount: 20,
                            baseColor: AppTheme.primaryAccent,
                            spreadRadius: 150,
                          ),
                        ),
                        // Confetti superior derecho
                        Positioned(
                          top: 100,
                          right: 50,
                          child: ParticleBurst(
                            particleCount: 20,
                            baseColor: AppTheme.secondaryAccent,
                            spreadRadius: 150,
                          ),
                        ),
                        // Confetti inferior
                        Positioned(
                          bottom: 200,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: ParticleBurst(
                              particleCount: 30,
                              baseColor: const Color(0xFFFFD700),
                              spreadRadius: 200,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Contenido principal
              Column(
                children: [
                  // Header
                  _buildHeader(),
                  
                  // Contenido
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Título y estrellas
                          _buildTitleWithStars(),
                          
                          const SizedBox(height: 32),
                          
                          // Estadísticas del nivel
                          _buildLevelStats(),
                          
                          const SizedBox(height: 32),
                          
                          // Botón de siguiente nivel
                          _buildNextLevelButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: AppTheme.primaryText),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          Text(
            'Nivel Completado',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48), // Balance para centrar el título
        ],
      ),
    );
  }
  
  Widget _buildTitleWithStars() {
    return Column(
      children: [
        // Icono de celebración
        AnimatedBuilder(
          animation: _starAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _starAnimation.value,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryAccent.withOpacity(0.5),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 24),
        
        // Título principal
        Text(
          '¡NIVEL ${widget.level} COMPLETADO!',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            foreground: Paint()
              ..shader = AppTheme.primaryGradient.createShader(
                const Rect.fromLTWH(0, 0, 400, 60),
              ),
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        // Estrellas de calificación
        _buildStars(),
      ],
    );
  }
  
  Widget _buildStars() {
    final stars = _calculateStars();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _starAnimation,
          builder: (context, child) {
            final delay = index * 0.2;
            final animationValue = ((_starAnimation.value - delay) / (1 - delay))
                .clamp(0.0, 1.0);
            
            return Transform.scale(
              scale: animationValue,
              child: Icon(
                index < stars ? Icons.star : Icons.star_border,
                color: index < stars ? const Color(0xFFFFD700) : AppTheme.secondaryText,
                size: 40,
              ),
            );
          },
        );
      }),
    );
  }
  
  int _calculateStars() {
    // Calificar basado en la puntuación
    if (widget.score >= widget.level * 2000) return 3;
    if (widget.score >= widget.level * 1500) return 2;
    return 1;
  }
  
  Widget _buildLevelStats() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.secondaryText.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Puntuación del nivel
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Puntuación del nivel',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.secondaryText,
                ),
              ),
              ScoreDisplay(
                score: widget.score,
                fontSize: 24,
                showAnimation: false,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Monedas ganadas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Color(0xFFFFD700),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Monedas ganadas',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      '+${widget.coinsEarned}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Bonus de nivel
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.card_giftcard,
                    color: AppTheme.successColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Bonus de nivel',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.successColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_circle,
                      color: AppTheme.successColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${GameConstants.coinsPerLevel}',
                      style: TextStyle(
                        color: AppTheme.successColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildNextLevelButton() {
    return AnimatedBuilder(
      animation: _buttonAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _buttonAnimation.value) * 50),
          child: Opacity(
            opacity: _buttonAnimation.value,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 32),
            child: ElevatedButton(
              onPressed: _goToNextLevel,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Siguiente nivel',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  void _goToNextLevel() async {
    await HapticService.success();
    await AudioService.playButtonTap();
    
    if (widget.onNextLevel != null) {
      widget.onNextLevel!();
    } else {
      // Navegar al siguiente nivel
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const GameScreen()),
        );
      }
    }
  }
}
