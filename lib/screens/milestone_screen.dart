import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:blockrush/config/theme.dart';
import 'package:blockrush/widgets/milestone_popup.dart';
import 'package:blockrush/widgets/particle_burst.dart';

class MilestoneScreen extends StatefulWidget {
  final String title;
  final String description;
  final int level;
  final String milestoneTitle;
  final int coinsReward;
  final List<String> powerUpsReward;
  final List<String> unlockedTitles;
  final VoidCallback? onDismiss;
  
  const MilestoneScreen({
    super.key,
    required this.title,
    required this.description,
    required this.level,
    required this.milestoneTitle,
    required this.coinsReward,
    this.powerUpsReward = const [],
    this.unlockedTitles = const [],
    this.onDismiss,
  });
  
  @override
  State<MilestoneScreen> createState() => _MilestoneScreenState();
}

class _MilestoneScreenState extends State<MilestoneScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  late AnimationController _titleController;
  late Animation<double> _mainAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _titleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _mainAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOut,
    ));
    
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeInOut,
    ));
    
    _titleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: Curves.elasticOut,
    ));
    
    // Iniciar animaciones
    Future.delayed(const Duration(milliseconds: 200), () {
      _titleController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 500), () {
      _mainController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 800), () {
      _particleController.forward();
    });
  }
  
  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    _titleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: _getMilestoneGradient(),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Partículas de celebración
              AnimatedBuilder(
                animation: _particleAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _particleAnimation.value,
                    child: Stack(
                      children: [
                        // Partículas superiores
                        Positioned(
                          top: 100,
                          left: 50,
                          child: ParticleBurst(
                            particleCount: 30,
                            baseColor: const Color(0xFFFFD700),
                            spreadRadius: 200,
                          ),
                        ),
                        // Partículas derechas
                        Positioned(
                          top: 200,
                          right: 50,
                          child: ParticleBurst(
                            particleCount: 25,
                            baseColor: AppTheme.primaryAccent,
                            spreadRadius: 180,
                          ),
                        ),
                        // Partículas inferiores
                        Positioned(
                          bottom: 150,
                          left: 100,
                          child: ParticleBurst(
                            particleCount: 35,
                            baseColor: AppTheme.secondaryAccent,
                            spreadRadius: 220,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              // Contenido principal
              AnimatedBuilder(
                animation: _mainAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _mainAnimation.value,
                    child: Column(
                      children: [
                        // Header
                        _buildHeader(),
                        
                        // Contenido del hito
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                // Título principal animado
                                _buildMainTitle(),
                                
                                const SizedBox(height: 40),
                                
                                // Icono del hito
                                _buildMilestoneIcon(),
                                
                                const SizedBox(height: 40),
                                
                                // Información del hito
                                _buildMilestoneInfo(),
                                
                                const SizedBox(height: 40),
                                
                                // Estadísticas del jugador
                                _buildPlayerStats(),
                                
                                const SizedBox(height: 40),
                                
                                // Recompensas
                                _buildRewards(),
                                
                                const SizedBox(height: 40),
                                
                                // Botón de continuar
                                _buildContinueButton(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
          const SizedBox(width: 48), // Espacio para balance
          const Spacer(),
          Text(
            'Hito Desbloqueado',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => widget.onDismiss?.call(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMainTitle() {
    return AnimatedBuilder(
      animation: _titleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _titleAnimation.value,
          child: Column(
            children: [
              // Título principal
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Título del hito
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Text(
                  widget.milestoneTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                .shimmer(
                  duration: const Duration(milliseconds: 2000),
                ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildMilestoneIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(60),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: const Icon(
        Icons.emoji_events,
        color: Colors.white,
        size: 60,
      ),
    ).animate(onPlay: (controller) => controller.repeat())
      .rotate(
        begin: -0.05,
        end: 0.05,
        duration: const Duration(milliseconds: 2000),
      )
      .then()
      .rotate(
        begin: 0.05,
        end: -0.05,
        duration: const Duration(milliseconds: 2000),
      );
  }
  
  Widget _buildMilestoneInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            widget.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Nivel alcanzado
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.layers,
                color: Colors.white.withOpacity(0.8),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Nivel ${widget.level} alcanzado',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlayerStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Títulos Desbloqueados',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Lista de títulos
          ...widget.unlockedTitles.map((title) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.military_tech,
                      color: Color(0xFFFFD700),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          
          if (widget.unlockedTitles.isEmpty)
            Text(
              'Sigue jugando para desbloquear más títulos',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildRewards() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            '🎁 Recompensas del Hito',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Monedas
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.monetization_on,
                color: Color(0xFFFFD700),
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                '+${widget.coinsReward}',
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          
          if (widget.powerUpsReward.isNotEmpty) ...[
            const SizedBox(height: 20),
            
            // Power-ups
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Power-ups obtenidos:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...widget.powerUpsReward.map((powerUp) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.flash_on,
                          color: Colors.white.withOpacity(0.8),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          powerUp,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
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
    );
  }
  
  Widget _buildContinueButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 32),
      child: ElevatedButton(
        onPressed: widget.onDismiss,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF4CAF50),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '¡Continuar la aventura!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward),
          ],
        ),
      ),
    );
  }
  
  LinearGradient _getMilestoneGradient() {
    return const LinearGradient(
      colors: [
        Color(0xFF1B5E20), // Verde oscuro
        Color(0xFF2E7D32), // Verde medio
        Color(0xFF388E3C), // Verde claro
        Color(0xFF43A047), // Verde brillante
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }
}
