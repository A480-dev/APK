import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:blockrush/config/theme.dart';
import 'package:blockrush/providers/story_provider.dart';
import 'package:blockrush/providers/ad_provider.dart';
import 'package:blockrush/widgets/score_display.dart';
import 'package:blockrush/widgets/ad_banner_widget.dart';
import 'package:blockrush/widgets/animated_button.dart';
import 'package:blockrush/widgets/particle_burst.dart';
import 'package:blockrush/widgets/dialogue_overlay.dart';
import 'package:blockrush/services/audio_service.dart';
import 'package:blockrush/services/haptic_service.dart';
import 'package:blockrush/models/chapter.dart';
import 'package:blockrush/screens/story_map_screen.dart';

class ChapterCompleteScreen extends ConsumerStatefulWidget {
  final int chapterId;
  final int starsEarned;
  final int coinsEarned;
  final ChapterRewards rewards;
  final bool isNewChapter;
  
  const ChapterCompleteScreen({
    super.key,
    required this.chapterId,
    required this.starsEarned,
    required this.coinsEarned,
    required this.rewards,
    this.isNewChapter = false,
  });

  @override
  ConsumerState<ChapterCompleteScreen> createState() => _ChapterCompleteScreenState();
}

class _ChapterCompleteScreenState extends ConsumerState<ChapterCompleteScreen>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late AnimationController _rewardController;
  late AnimationController _buttonController;
  late Animation<double> _celebrationAnimation;
  late Animation<double> _rewardAnimation;
  late Animation<double> _buttonAnimation;
  
  bool _showParticles = false;
  bool _showOutroDialogues = false;
  bool _showAdOption = false;
  bool _adWatched = false;
  
  @override
  void initState() {
    super.initState();
    
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _rewardController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _celebrationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));
    
    _rewardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rewardController,
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
    _celebrationController.dispose();
    _rewardController.dispose();
    _buttonController.dispose();
    super.dispose();
  }
  
  Future<void> _initializeScreen() async {
    // Reproducir efectos de celebración
    await AudioService.playLevelUp();
    await HapticService.victoryPattern();
    
    // Iniciar animación de celebración
    _celebrationController.forward();
    
    // Mostrar partículas después de la animación
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showParticles = true;
        });
      }
    });
    
    // Iniciar animación de recompensas
    Future.delayed(const Duration(milliseconds: 1000), () {
      _rewardController.forward();
    });
    
    // Mostrar diálogos de final del capítulo
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showOutroDialogues = true;
        });
      }
    });
    
    // Mostrar opción de anuncio
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _showAdOption = true;
        });
      }
    });
    
    // Iniciar animación de botones
    Future.delayed(const Duration(milliseconds: 2500), () {
      _buttonController.forward();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final storyState = ref.watch(storyProvider);
    final rewardedAdAvailable = ref.watch(rewardedAdAvailableProvider);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Partículas de celebración
              if (_showParticles)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Stack(
                      children: [
                        // Partículas superiores
                        Positioned(
                          top: 100,
                          left: 50,
                          child: ParticleBurst(
                            particleCount: 25,
                            baseColor: const Color(0xFFFFD700),
                            spreadRadius: 150,
                          ),
                        ),
                        // Partículas inferiores
                        Positioned(
                          bottom: 200,
                          right: 50,
                          child: ParticleBurst(
                            particleCount: 25,
                            baseColor: AppTheme.primaryAccent,
                            spreadRadius: 150,
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
                  
                  // Contenido de celebración
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Título y estrellas
                          _buildCelebrationTitle(),
                          
                          const SizedBox(height: 32),
                          
                          // Estadísticas del capítulo
                          _buildChapterStats(),
                          
                          const SizedBox(height: 32),
                          
                          // Recompensas
                          _buildRewards(),
                          
                          const SizedBox(height: 32),
                          
                          // Opción de anuncio
                          if (_showAdOption && !_adWatched)
                            _buildAdOption(rewardedAdAvailable),
                          
                          const SizedBox(height: 32),
                          
                          // Botones de acción
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              // Diálogos de final del capítulo
              if (_showOutroDialogues)
                DialogueOverlay(
                  dialogues: storyState.getChapterOutroDialogues(),
                  onComplete: () => _onOutroDialoguesComplete(),
                  canSkip: true,
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
            '¡Capítulo Completado!',
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
  
  Widget _buildCelebrationTitle() {
    return AnimatedBuilder(
      animation: _celebrationAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _celebrationAnimation.value,
          child: Column(
            children: [
              // Icono de celebración
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.5),
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
              
              const SizedBox(height: 24),
              
              // Título principal
              Text(
                '¡CAPÍTULOO ${widget.chapterId} COMPLETADO!',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                    ).createShader(
                      const Rect.fromLTWH(0, 0, 400, 60),
                    ),
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Estrellas ganadas
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final hasStar = index < widget.starsEarned;
                  return AnimatedBuilder(
                    animation: _celebrationAnimation,
                    builder: (context, child) {
                      final delay = index * 0.2;
                      final animationValue = ((_celebrationAnimation.value - delay) / (1 - delay))
                          .clamp(0.0, 1.0);
                      
                      return Transform.scale(
                        scale: animationValue,
                        child: Icon(
                          hasStar ? Icons.star : Icons.star_border,
                          color: hasStar ? const Color(0xFFFFD700) : AppTheme.secondaryText,
                          size: 40,
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildChapterStats() {
    return AnimatedBuilder(
      animation: _rewardAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _rewardAnimation.value) * 30),
          child: Opacity(
            opacity: _rewardAnimation.value,
            child: Container(
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
                  Text(
                    'Estadísticas del capítulo',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.primaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Estrellas totales
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Estrellas ganadas',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.secondaryText,
                        ),
                      ),
                      Row(
                        children: [
                          ...List.generate(widget.starsEarned, (index) {
                            return Icon(
                              Icons.star,
                              color: const Color(0xFFFFD700),
                              size: 20,
                            );
                          }),
                          ...List.generate(3 - widget.starsEarned, (index) {
                            return Icon(
                              Icons.star_border,
                              color: AppTheme.secondaryText,
                              size: 20,
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
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
                      Text(
                        '+${widget.coinsEarned}',
                        style: TextStyle(
                          color: const Color(0xFFFFD700),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  
                  if (widget.isNewChapter) ...[
                    const SizedBox(height: 12),
                    
                    // Nuevo capítulo desbloqueado
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.successColor, Color(0xFF388E3C)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.new_releases,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '¡Capítulo ${widget.chapterId + 1} desbloqueado!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
  
  Widget _buildRewards() {
    return AnimatedBuilder(
      animation: _rewardAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _rewardAnimation.value) * 50),
          child: Opacity(
            opacity: _rewardAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryAccent.withOpacity(0.2),
                    AppTheme.secondaryAccent.withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryAccent.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Recompensas del capítulo',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Power-ups
                  if (widget.rewards.powerUps.isNotEmpty) ...[
                    Text(
                      'Power-ups:',
                      style: TextStyle(
                        color: AppTheme.secondaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...widget.rewards.powerUps.map((powerUp) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.flash_on,
                              color: AppTheme.primaryAccent,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              powerUp,
                              style: TextStyle(
                                color: AppTheme.primaryText,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 12),
                  ],
                  
                  // Skins
                  if (widget.rewards.skins.isNotEmpty) ...[
                    Text(
                      'Skins desbloqueados:',
                      style: TextStyle(
                        color: AppTheme.secondaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...widget.rewards.skins.map((skin) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.palette,
                              color: AppTheme.secondaryAccent,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              skin,
                              style: TextStyle(
                                color: AppTheme.primaryText,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 12),
                  ],
                  
                  // Recompensas especiales
                  if (widget.rewards.specialRewards.isNotEmpty) ...[
                    Text(
                      'Recompensas especiales:',
                      style: TextStyle(
                        color: AppTheme.secondaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...widget.rewards.specialRewards.map((reward) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.emoji_events,
                              color: const Color(0xFFFFD700),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              reward,
                              style: TextStyle(
                                color: const Color(0xFFFFD700),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildAdOption(bool rewardedAdAvailable) {
    return AnimatedBuilder(
      animation: _buttonAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _buttonAnimation.value) * 30),
          child: Opacity(
            opacity: _buttonAnimation.value,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 32),
              child: ElevatedButton(
                onPressed: rewardedAdAvailable && !_adWatched 
                    ? _watchRewardedAd 
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryAccent,
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
                      '🎁 Ver un anuncio para doblar tus recompensas',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+${widget.rewards.coins} monedas + power-ups extra',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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
  
  Widget _buildActionButtons() {
    return AnimatedBuilder(
      animation: _buttonAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _buttonAnimation.value) * 50),
          child: Opacity(
            opacity: _buttonAnimation.value,
            child: Column(
              children: [
                // Botón de continuar
                PrimaryButton(
                  text: widget.isNewChapter 
                      ? 'Siguiente capítulo →' 
                      : 'Mapa de historia',
                  icon: widget.isNewChapter 
                      ? const Icon(Icons.arrow_forward)
                      : const Icon(Icons.map),
                  onPressed: _continueToNext,
                  width: double.infinity,
                ),
                
                const SizedBox(height: 12),
                
                // Botón de rejugar
                SecondaryButton(
                  text: 'Rejugar capítulo',
                  icon: const Icon(Icons.refresh),
                  onPressed: _replayChapter,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  void _onOutroDialoguesComplete() {
    setState(() {
      _showOutroDialogues = false;
    });
  }
  
  Future<void> _watchRewardedAd() async {
    final success = await ref.read(adProvider.notifier).showRewardedAd(
      onUserEarnedReward: () async {
        setState(() {
          _adWatched = true;
        });
        
        await HapticService.success();
        await AudioService.playCoinCollect();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Recompensas duplicadas! +${widget.rewards.coins} monedas extra'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      },
      onAdDismissed: () {
        // Si el anuncio se cierra sin completar
      },
    );
    
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay anuncios disponibles en este momento'),
          backgroundColor: AppTheme.dangerColor,
        ),
      );
    }
  }
  
  void _continueToNext() async {
    await HapticService.buttonPressed();
    await AudioService.playButtonTap();
    
    if (widget.isNewChapter) {
      // Navegar al siguiente capítulo
      ref.read(storyProvider.notifier).startChapter(widget.chapterId + 1);
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const StoryMapScreen(),
        ),
      );
    } else {
      // Volver al mapa de historia
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const StoryMapScreen(),
        ),
        (route) => false,
      );
    }
  }
  
  void _replayChapter() async {
    await HapticService.buttonPressed();
    await AudioService.playButtonTap();
    
    // Reiniciar el capítulo actual
    ref.read(storyProvider.notifier).startChapter(widget.chapterId);
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const StoryMapScreen(),
      ),
    );
  }
}
