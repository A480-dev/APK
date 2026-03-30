import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:blockrush/config/theme.dart';
import 'package:blockrush/providers/story_provider.dart';
import 'package:blockrush/widgets/chapter_card.dart';
import 'package:blockrush/widgets/ad_banner_widget.dart';

class StoryMapScreen extends ConsumerStatefulWidget {
  const StoryMapScreen({super.key});

  @override
  ConsumerState<StoryMapScreen> createState() => _StoryMapScreenState();
}

class _StoryMapScreenState extends ConsumerState<StoryMapScreen>
    with TickerProviderStateMixin {
  late AnimationController _mapController;
  late AnimationController _architectController;
  late Animation<double> _mapAnimation;
  late Animation<double> _architectAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _mapController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _architectController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _mapAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mapController,
      curve: Curves.easeInOut,
    ));
    
    _architectAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _architectController,
      curve: Curves.easeInOut,
    ));
    
    // Iniciar animaciones con retraso
    Future.delayed(const Duration(milliseconds: 200), () {
      _mapController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 800), () {
      _architectController.forward();
    });
  }
  
  @override
  void dispose() {
    _mapController.dispose();
    _architectController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final storyState = ref.watch(storyProvider);
    final architectState = ref.watch(architectStateProvider);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: _getCosmicGradient(),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Contenido principal
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // El Arquitecto
                      _buildArchitect(architectState),
                      
                      const SizedBox(height: 40),
                      
                      // Línea de progreso y capítulos
                      _buildChapterMap(storyState),
                      
                      const SizedBox(height: 40),
                      
                      // Banner de anuncios
                      const AdBannerWidget(),
                    ],
                  ),
                ),
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
            icon: const Icon(Icons.arrow_back, color: AppTheme.primaryText),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          Text(
            'Mapa de Historia',
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
  
  Widget _buildArchitect(ArchitectState architectState) {
    return AnimatedBuilder(
      animation: _architectAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _architectAnimation.value,
          child: Column(
            children: [
              // Título del Arquitecto
              Text(
                'El Arquitecto',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFFFFD700),
                  fontWeight: FontWeight.w800,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Representación visual del Arquitecto
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: _getArchitectGradient(architectState),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Figura del Arquitecto
                    Center(
                      child: Icon(
                        Icons.account_balance,
                        color: Colors.white.withOpacity(0.8),
                        size: 60,
                      ),
                    ),
                    
                    // Indicador de completion
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${(architectState.completion * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Estado del Arquitecto
              Text(
                _getArchitectStatus(architectState),
                style: TextStyle(
                  color: const Color(0xFFFFD700),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildChapterMap(storyState) {
    return AnimatedBuilder(
      animation: _mapAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _mapAnimation.value) * 30),
          child: Opacity(
            opacity: _mapAnimation.value,
            child: Column(
              children: [
                // Línea de conexión
                _buildConnectionLine(),
                
                const SizedBox(height: 20),
                
                // Capítulos
                ...storyState.chapters.asMap().entries.map((entry) {
                  final index = entry.key;
                  final chapter = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < storyState.chapters.length - 1 ? 20 : 0,
                    ),
                    child: ChapterCard(
                      chapter: chapter,
                      isSelected: chapter.id == storyState.currentChapter,
                      onTap: chapter.isAvailable 
                          ? () => _selectChapter(chapter.id)
                          : null,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildConnectionLine() {
    final storyState = ref.read(storyProvider);
    final completedChapters = storyState.chapters.where((c) => c.isCompleted).length;
    final totalChapters = storyState.chapters.length;
    final progress = completedChapters / totalChapters;
    
    return Container(
      width: 300,
      height: 4,
      decoration: BoxDecoration(
        color: AppTheme.secondaryText.withOpacity(0.2),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
  
  void _selectChapter(int chapterId) {
    final storyState = ref.read(storyProvider);
    
    if (chapterId == storyState.currentChapter) {
      // Navegar al primer nivel del capítulo actual
      _navigateToChapterIntro(chapterId);
    } else if (storyState.chapters.firstWhere((c) => c.id == chapterId).isCompleted) {
      // Capítulo completado - mostrar opciones
      _showChapterOptions(chapterId);
    } else {
      // Capítulo disponible pero no actual - navegar a intro
      _navigateToChapterIntro(chapterId);
    }
  }
  
  void _navigateToChapterIntro(int chapterId) {
    ref.read(storyProvider.notifier).startChapter(chapterId);
    
    // Aquí navegaríamos a la pantalla de intro del capítulo
    // Por ahora, solo mostramos un mensaje
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Iniciando capítulo $chapterId'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }
  
  void _showChapterOptions(int chapterId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          'Capítulo $chapterId Completado',
          style: TextStyle(
            color: AppTheme.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¿Qué deseas hacer?',
              style: TextStyle(
                color: AppTheme.secondaryText,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToChapterIntro(chapterId);
            },
            child: Text(
              'Rejugar capítulo',
              style: TextStyle(color: AppTheme.primaryAccent),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _viewCinematics(chapterId);
            },
            child: Text(
              'Ver cinemáticas',
              style: TextStyle(color: AppTheme.secondaryAccent),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.secondaryText),
            ),
          ),
        ],
      ),
    );
  }
  
  void _viewCinematics(int chapterId) {
    // Aquí mostraríamos las cinemáticas del capítulo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viendo cinemáticas del capítulo $chapterId'),
        backgroundColor: AppTheme.secondaryAccent,
      ),
    );
  }
  
  LinearGradient _getCosmicGradient() {
    return const LinearGradient(
      colors: [
        Color(0xFF0F0F23), // Azul muy oscuro
        Color(0xFF1A1A2E), // Azul oscuro
        Color(0xFF16213E), // Azul medio oscuro
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }
  
  LinearGradient _getArchitectGradient(ArchitectState state) {
    switch (state) {
      case ArchitectState.minimal:
        return const LinearGradient(
          colors: [Color(0xFF424242), Color(0xFF616161)],
        );
      case ArchitectState.partiallyComplete:
        return const LinearGradient(
          colors: [Color(0xFF616161), Color(0xFF757575)],
        );
      case ArchitectState.halfComplete:
        return const LinearGradient(
          colors: [Color(0xFF757575), Color(0xFF9E9E9E)],
        );
      case ArchitectState.mostlyComplete:
        return const LinearGradient(
          colors: [Color(0xFF9E9E9E), Color(0xFFBDBDBD)],
        );
      case ArchitectState.nearlyComplete:
        return const LinearGradient(
          colors: [Color(0xFFBDBDBD), Color(0xFFE0E0E0)],
        );
      case ArchitectState.complete:
        return const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
        );
    }
  }
  
  String _getArchitectStatus(ArchitectState state) {
    switch (state) {
      case ArchitectState.minimal:
        return 'Fragmentado - Buscando unidad';
      case ArchitectState.partiallyComplete:
        return 'Parcialmente restaurado';
      case ArchitectState.halfComplete:
        return 'Mitad completo';
      case ArchitectState.mostlyComplete:
        return 'Casi completo';
      case ArchitectState.nearlyComplete:
        return 'Casi restaurado';
      case ArchitectState.complete:
        return '¡Completo! El universo está en equilibrio';
    }
  }
}
