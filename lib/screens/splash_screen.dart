import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:blockrush/config/theme.dart';
import 'package:blockrush/config/constants.dart';
import 'package:blockrush/providers/player_provider.dart';
import 'package:blockrush/providers/ad_provider.dart';
import 'package:blockrush/services/audio_service.dart';
import 'package:blockrush/services/haptic_service.dart';
import 'package:blockrush/screens/main_menu_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _progressController;
  late Animation<double> _logoAnimation;
  late Animation<double> _progressAnimation;
  
  double _progress = 0.0;
  
  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: GameConstants.splashDuration),
      vsync: this,
    );
    
    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _initializeApp();
  }
  
  Future<void> _initializeApp() async {
    // Iniciar animaciones
    _logoController.forward();
    
    // Simular progreso de carga
    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) {
        setState(() {
          _progress = i / 100.0;
        });
      }
    }
    
    // Iniciar animación de progreso
    _progressController.forward();
    
    // Inicializar servicios
    await _initializeServices();
    
    // Esperar a que termine la animación
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Navegar al menú principal
    if (mounted) {
      _navigateToMainMenu();
    }
  }
  
  Future<void> _initializeServices() async {
    try {
      // Inicializar audio
      await AudioService.init();
      
      // Inicializar háptico
      await HapticService.init();
      
      // Actualizar streak diario
      await ref.read(playerProvider.notifier).updateDailyStreak();
      
      // Cargar anuncios
      await ref.read(adProvider.notifier).refreshAds();
      
      // Feedback háptico de bienvenida
      await HapticService.success();
      
      // Reproducir sonido de bienvenida
      await AudioService.playButtonTap();
      
    } catch (e) {
      // Silenciar errores durante la inicialización
      debugPrint('Error en inicialización: $e');
    }
  }
  
  void _navigateToMainMenu() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainMenuScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
  
  @override
  void dispose() {
    _logoController.dispose();
    _progressController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                
                // Logo animado
                AnimatedBuilder(
                  animation: _logoAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoAnimation.value,
                      child: Column(
                        children: [
                          // Logo principal
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryAccent.withOpacity(0.5),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.grid_view,
                              color: Colors.white,
                              size: 60,
                            ),
                          ).animate(onPlay: (controller) => controller.repeat())
                            .shimmer(
                              duration: const Duration(milliseconds: 2000),
                            ),
                          
                          const SizedBox(height: 24),
                          
                          // Título del juego
                          Text(
                            'BlockRush',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              foreground: Paint()
                                ..shader = AppTheme.primaryGradient.createShader(
                                  const Rect.fromLTWH(0, 0, 300, 60),
                                ),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Subtítulo
                          Text(
                            'Puzzle & Survive',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.secondaryText,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                const Spacer(flex: 3),
                
                // Barra de progreso
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: _progressAnimation.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Text(
                        'Cargando...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Versión
                Text(
                  'v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.secondaryText.withOpacity(0.5),
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget para partículas de fondo animadas
class BackgroundParticles extends StatefulWidget {
  final int particleCount;
  
  const BackgroundParticles({
    super.key,
    this.particleCount = 20,
  });
  
  @override
  State<BackgroundParticles> createState() => _BackgroundParticlesState();
}

class _BackgroundParticlesState extends State<BackgroundParticles>
    with TickerProviderStateMixin {
  late List<Particle> particles;
  
  @override
  void initState() {
    super.initState();
    particles = List.generate(widget.particleCount, (index) => Particle());
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: particles.map((particle) {
        return AnimatedPositioned(
          duration: Duration(seconds: particle.duration),
          curve: Curves.linear,
          left: particle.x,
          top: particle.y,
          child: Container(
            width: particle.size,
            height: particle.size,
            decoration: BoxDecoration(
              color: AppTheme.primaryAccent.withOpacity(particle.opacity),
              shape: BoxShape.circle,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class Particle {
  final double x;
  final double y;
  final double size;
  final double opacity;
  final int duration;
  
  Particle()
      : x = -50 + (DateTime.now().millisecondsSinceEpoch % 400),
        y = (DateTime.now().millisecondsSinceEpoch % 600).toDouble(),
        size = 2 + (DateTime.now().millisecondsSinceEpoch % 6),
        opacity = 0.1 + (DateTime.now().millisecondsSinceEpoch % 30) / 100,
        duration = 10 + (DateTime.now().millisecondsSinceEpoch % 20);
}
