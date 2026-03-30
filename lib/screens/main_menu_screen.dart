import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:blockrush/config/theme.dart';
import 'package:blockrush/providers/player_provider.dart';
import 'package:blockrush/providers/ad_provider.dart';
import 'package:blockrush/widgets/coin_display.dart';
import 'package:blockrush/widgets/ad_banner_widget.dart';
import 'package:blockrush/widgets/animated_button.dart';
import 'package:blockrush/screens/mode_select_screen.dart';
import 'package:blockrush/screens/daily_wheel_screen.dart';
import 'package:blockrush/screens/missions_screen.dart';
import 'package:blockrush/screens/store_screen.dart';
import 'package:blockrush/screens/settings_screen.dart';

class MainMenuScreen extends ConsumerStatefulWidget {
  const MainMenuScreen({super.key});

  @override
  ConsumerState<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends ConsumerState<MainMenuScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _buttonController;
  
  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Iniciar animaciones con retraso
    Future.delayed(const Duration(milliseconds: 300), () {
      _logoController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 800), () {
      _buttonController.forward();
    });
  }
  
  @override
  void dispose() {
    _logoController.dispose();
    _buttonController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final playerStats = ref.watch(playerStatsProvider);
    final canSpinWheel = ref.watch(canSpinWheelProvider);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header con stats
              _buildHeader(playerStats),
              
              // Logo principal
              _buildLogo(),
              
              // Botones de modo de juego
              _buildGameModeButtons(),
              
              // Fila de botones secundarios
              _buildSecondaryButtons(canSpinWheel),
              
              const Spacer(),
              
              // Banner de anuncios
              const MenuAdBannerWidget(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader(PlayerStats playerStats) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nivel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.secondaryAccent.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.layers,
                  color: AppTheme.secondaryAccent,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Nivel ${playerStats.currentLevel}',
                  style: TextStyle(
                    color: AppTheme.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // Monedas
          const CoinDisplay(),
          
          // Streak
          if (playerStats.currentStreak > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.successColor,
                    AppTheme.successColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${playerStats.currentStreak} días',
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
      ),
    );
  }
  
  Widget _buildLogo() {
    return Expanded(
      flex: 3,
      child: Center(
        child: AnimatedBuilder(
          animation: _logoController,
          builder: (context, child) {
            return Transform.scale(
              scale: _logoController.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo principal
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(35),
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
                      size: 70,
                    ),
                  ).animate(onPlay: (controller) => controller.repeat())
                    .shimmer(
                      duration: const Duration(milliseconds: 3000),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Título
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
      ),
    );
  }
  
  Widget _buildGameModeButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: AnimatedBuilder(
        animation: _buttonController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, (1 - _buttonController.value) * 50),
            child: Opacity(
              opacity: _buttonController.value,
              child: Column(
                children: [
                  // Botón Modo Historia
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _goToStoryMode,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '⚔️ MODO HISTORIA',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Botón Modo Infinito
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9C27B0).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _goToEndlessMode,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '♾️ MODO INFINITO',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildSecondaryButtons(bool canSpinWheel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: AnimatedBuilder(
        animation: _buttonController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, (1 - _buttonController.value) * 100),
            child: Opacity(
              opacity: _buttonController.value,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSecondaryButton(
                    icon: Icons.casino,
                    label: 'Ruleta',
                    onTap: () => _navigateToScreen(const DailyWheelScreen()),
                    hasNotification: canSpinWheel,
                  ),
                  
                  _buildSecondaryButton(
                    icon: Icons.assignment,
                    label: 'Misiones',
                    onTap: () => _navigateToScreen(const MissionsScreen()),
                    hasNotification: false,
                  ),
                  
                  _buildSecondaryButton(
                    icon: Icons.store,
                    label: 'Tienda',
                    onTap: () => _navigateToScreen(const StoreScreen()),
                    hasNotification: false,
                  ),
                  
                  _buildSecondaryButton(
                    icon: Icons.settings,
                    label: 'Config',
                    onTap: () => _navigateToScreen(const SettingsScreen()),
                    hasNotification: false,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildSecondaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool hasNotification,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.secondaryText.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: AppTheme.primaryAccent,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.primaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            // Indicador de notificación
            if (hasNotification)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.dangerColor,
                    shape: BoxShape.circle,
                  ),
                ).animate(onPlay: (controller) => controller.repeat())
                  .scale(
                    begin: 1.0,
                    end: 1.3,
                    duration: const Duration(milliseconds: 1000),
                  )
                  .then()
                  .scale(
                    begin: 1.3,
                    end: 1.0,
                    duration: const Duration(milliseconds: 1000),
                  ),
              ),
          ],
        ),
      ),
    );
  }
  
  void _goToStoryMode() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const ModeSelectScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
  
  void _goToEndlessMode() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const ModeSelectScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
  
  void _navigateToScreen(Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
