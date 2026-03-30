import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:blockrush/config/theme.dart';
import 'package:blockrush/config/constants.dart';
import 'package:blockrush/providers/game_provider.dart';
import 'package:blockrush/providers/player_provider.dart';
import 'package:blockrush/providers/ad_provider.dart';
import 'package:blockrush/widgets/score_display.dart';
import 'package:blockrush/widgets/ad_banner_widget.dart';
import 'package:blockrush/widgets/animated_button.dart';
import 'package:blockrush/widgets/particle_burst.dart';
import 'package:blockrush/services/audio_service.dart';
import 'package:blockrush/services/haptic_service.dart';
import 'package:blockrush/screens/main_menu_screen.dart';
import 'package:blockrush/screens/game_screen.dart';

class GameOverScreen extends ConsumerStatefulWidget {
  final int finalScore;
  final int level;
  final int linesCleared;
  final int coinsEarned;
  
  const GameOverScreen({
    super.key,
    required this.finalScore,
    required this.level,
    required this.linesCleared,
    required this.coinsEarned,
  });

  @override
  ConsumerState<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends ConsumerState<GameOverScreen>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _scoreController;
  late AnimationController _buttonController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _scoreAnimation;
  late Animation<double> _buttonAnimation;
  
  bool _showParticles = false;
  
  @override
  void initState() {
    super.initState();
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: GameConstants.shakeAnimationDuration),
      vsync: this,
    );
    
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
    
    _scoreAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scoreController,
      curve: Curves.easeInOut,
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
    _shakeController.dispose();
    _scoreController.dispose();
    _buttonController.dispose();
    super.dispose();
  }
  
  Future<void> _initializeScreen() async {
    // Reproducir sonido de game over
    await AudioService.playGameOver();
    await HapticService.gameOver();
    
    // Iniciar animación de shake
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
    
    // Mostrar partículas después del shake
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showParticles = true;
        });
      }
    });
    
    // Iniciar animación de puntuación
    Future.delayed(const Duration(milliseconds: 800), () {
      _scoreController.forward();
    });
    
    // Iniciar animación de botones
    Future.delayed(const Duration(milliseconds: 1200), () {
      _buttonController.forward();
    });
    
    // Actualizar high score
    await ref.read(playerProvider.notifier).updateHighScore(widget.finalScore);
    
    // Incrementar partidas jugadas
    await ref.read(playerProvider.notifier).incrementGamesPlayed();
    
    // Verificar si mostrar anuncio interstitial
    if (ref.read(adProvider.notifier).shouldShowInterstitialAd()) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        ref.read(adProvider.notifier).showInterstitialAd();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final playerData = ref.watch(playerProvider);
    final rewardedAdAvailable = ref.watch(rewardedAdAvailableProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Contenido principal
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Título Game Over con shake
                      _buildGameOverTitle(),
                      
                      const SizedBox(height: 32),
                      
                      // Estadísticas finales
                      _buildFinalStats(),
                      
                      const SizedBox(height: 32),
                      
                      // Botones de acción
                      _buildActionButtons(rewardedAdAvailable, playerData.coins),
                    ],
                  ),
                ),
              ),
              
              // Banner de anuncios
              const GameOverAdBannerWidget(),
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
            icon: const Icon(Icons.arrow_back, color: AppTheme.primaryText),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          Text(
            'Game Over',
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
  
  Widget _buildGameOverTitle() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: Column(
            children: [
              Icon(
                Icons.sentiment_very_dissatisfied,
                color: AppTheme.dangerColor,
                size: 80,
              ).animate(onPlay: (controller) => controller.repeat())
                .scale(
                  begin: 1.0,
                  end: 1.1,
                  duration: const Duration(milliseconds: 1000),
                )
                .then()
                .scale(
                  begin: 1.1,
                  end: 1.0,
                  duration: const Duration(milliseconds: 1000),
                ),
              
              const SizedBox(height: 16),
              
              Text(
                '¡GAME OVER!',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppTheme.dangerColor,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(
                      color: AppTheme.dangerColor.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildFinalStats() {
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
          // Puntuación final animada
          AnimatedBuilder(
            animation: _scoreAnimation,
            builder: (context, child) {
              final displayScore = (widget.finalScore * _scoreAnimation.value).round();
              return Column(
                children: [
                  Text(
                    'Puntuación Final',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ScoreDisplay(
                    score: displayScore,
                    fontSize: 36,
                    showAnimation: false,
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // High score
          Consumer(
            builder: (context, ref, _) {
              final highScore = ref.watch(highScoreProvider);
              final isNewHighScore = widget.finalScore >= highScore;
              
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Mejor Puntuación: ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.secondaryText,
                        ),
                      ),
                      Text(
                        highScore.toString(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isNewHighScore ? AppTheme.successColor : AppTheme.primaryText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (isNewHighScore) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.star,
                          color: AppTheme.successColor,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                  if (isNewHighScore) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.successColor, AppTheme.successColor.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '¡NUEVO RÉCORD!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Estadísticas adicionales
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                icon: Icons.layers,
                label: 'Nivel',
                value: widget.level.toString(),
                color: AppTheme.secondaryAccent,
              ),
              _buildStatItem(
                icon: Icons.horizontal_rule,
                label: 'Líneas',
                value: widget.linesCleared.toString(),
                color: AppTheme.successColor,
              ),
              _buildStatItem(
                icon: Icons.monetization_on,
                label: 'Monedas',
                value: widget.coinsEarned.toString(),
                color: const Color(0xFFFFD700),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.secondaryText,
          ),
        ),
        const SizedBox(height: 2),
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
  
  Widget _buildActionButtons(bool rewardedAdAvailable, int playerCoins) {
    return AnimatedBuilder(
      animation: _buttonAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _buttonAnimation.value) * 50),
          child: Opacity(
            opacity: _buttonAnimation.value,
            child: Column(
              children: [
                // Botón de ver anuncio para continuar
                if (rewardedAdAvailable)
                  RewardedAdButton(
                    label: '▶️ VER ANUNCIO Y CONTINUAR',
                    reward: '5 piezas extra',
                    onAdCompleted: _continueWithAd,
                  ),
                
                // Botón de usar shuffle
                if (playerCoins >= GameConstants.shufflePrice)
                  SecondaryButton(
                    text: '🔀 Usar Shuffle (${GameConstants.shufflePrice} monedas)',
                    onPressed: _useShuffle,
                    width: double.infinity,
                  ),
                
                // Botón de volver al menú
                const SizedBox(height: 12),
                PrimaryButton(
                  text: '🏠 Menú Principal',
                  icon: const Icon(Icons.home),
                  onPressed: _goToMainMenu,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  void _continueWithAd() async {
    // Mostrar anuncio rewarded
    final success = await ref.read(adProvider.notifier).showRewardedAd(
      onUserEarnedReward: () async {
        // Dar 5 piezas extra
        await HapticService.success();
        await AudioService.playLevelUp();
        
        // Navegar de vuelta al juego con piezas extra
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const GameScreen()),
          );
        }
      },
      onAdDismissed: () {
        // Si el anuncio se cierra sin completar, no hacer nada
      },
    );
    
    if (!success) {
      // Mostrar mensaje si no hay anuncio disponible
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay anuncios disponibles en este momento'),
          backgroundColor: AppTheme.dangerColor,
        ),
      );
    }
  }
  
  void _useShuffle() async {
    final success = await ref.read(playerProvider.notifier).spendCoins(GameConstants.shufflePrice);
    
    if (success) {
      await HapticService.success();
      await AudioService.playButtonTap();
      
      // Navegar de vuelta al juego con piezas mezcladas
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const GameScreen()),
        );
      }
    } else {
      await HapticService.error();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes suficientes monedas'),
          backgroundColor: AppTheme.dangerColor,
        ),
      );
    }
  }
  
  void _goToMainMenu() async {
    await HapticService.buttonPressed();
    await AudioService.playButtonTap();
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainMenuScreen()),
        (route) => false,
      );
    }
  }
}

// Widget personalizado para botón de anuncio rewarded
class RewardedAdButton extends StatelessWidget {
  final String label;
  final String reward;
  final VoidCallback? onAdCompleted;
  
  const RewardedAdButton({
    super.key,
    required this.label,
    required this.reward,
    this.onAdCompleted,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: onAdCompleted,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              reward,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
