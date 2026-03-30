import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blockrush/config/theme.dart';
import 'package:blockrush/providers/story_provider.dart';
import 'package:blockrush/widgets/dialogue_overlay.dart';
import 'package:blockrush/widgets/biome_background.dart';
import 'package:blockrush/screens/story_game_screen.dart';

class ChapterIntroScreen extends ConsumerStatefulWidget {
  const ChapterIntroScreen({super.key});

  @override
  ConsumerState<ChapterIntroScreen> createState() => _ChapterIntroScreenState();
}

class _ChapterIntroScreenState extends ConsumerState<ChapterIntroScreen>
    with TickerProviderStateMixin {
  bool _showDialogues = false;
  bool _canSkip = false;
  
  @override
  void initState() {
    super.initState();
    
    // Pequeña pausa antes de mostrar los diálogos
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showDialogues = true;
          _canSkip = true;
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final storyState = ref.watch(storyProvider);
    final currentChapter = storyState.getCurrentChapter();
    
    if (currentChapter == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      body: BiomeBackground(
        biome: currentChapter.biome,
        child: Stack(
          children: [
            // Fondo con información del capítulo
            _buildChapterBackground(currentChapter),
            
            // Diálogos
            if (_showDialogues)
              DialogueOverlay(
                dialogues: storyState.getChapterIntroDialogues(),
                onComplete: () => _onDialoguesComplete(),
                onSkip: () => _onDialoguesSkipped(),
                canSkip: _canSkip,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChapterBackground(chapter) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          // Header
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.primaryText),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  Text(
                    'Capítulo ${chapter.id}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48), // Balance
                ],
              ),
            ),
          ),
          
          const Spacer(),
          
          // Información del capítulo
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                // Título del capítulo
                Text(
                  chapter.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppTheme.primaryText,
                    fontWeight: FontWeight.w800,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Mundo del capítulo
                Text(
                  chapter.world,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.secondaryText,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Guardián del capítulo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.secondaryText.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getGuardianIcon(chapter.guardian),
                        color: _getGuardianColor(chapter.guardian),
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Guardián: ${chapter.guardian}',
                        style: TextStyle(
                          color: AppTheme.primaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Indicador de progreso
          Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.secondaryText.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Progreso del capítulo',
                  style: TextStyle(
                    color: AppTheme.secondaryText,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${chapter.completedLevels.length}/${chapter.totalLevels} niveles',
                  style: TextStyle(
                    color: AppTheme.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                // Barra de progreso
                Container(
                  width: 200,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryText.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: chapter.progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _onDialoguesComplete() {
    // Marcar diálogos como vistos
    ref.read(storyProvider.notifier).markDialoguesSeen();
    
    // Navegar al primer nivel del capítulo
    _navigateToFirstLevel();
  }
  
  void _onDialoguesSkipped() {
    // Navegar directamente al primer nivel
    _navigateToFirstLevel();
  }
  
  void _navigateToFirstLevel() {
    ref.read(storyProvider.notifier).startLevel(1);
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const StoryGameScreen(),
      ),
    );
  }
  
  IconData _getGuardianIcon(String guardian) {
    switch (guardian) {
      case 'FLORAX':
        return Icons.nature;
      case 'PETRA':
        return Icons.terrain;
      case 'IGNIX':
        return Icons.local_fire_department;
      case 'MAREEN':
        return Icons.water;
      case 'LA ENTROPÍA':
        return Icons.blur_on;
      default:
        return Icons.help;
    }
  }
  
  Color _getGuardianColor(String guardian) {
    switch (guardian) {
      case 'FLORAX':
        return const Color(0xFF4CAF50);
      case 'PETRA':
        return const Color(0xFF2196F3);
      case 'IGNIX':
        return const Color(0xFFFF5722);
      case 'MAREEN':
        return const Color(0xFF00BCD4);
      case 'LA ENTROPÍA':
        return const Color(0xFF424242);
      default:
        return AppTheme.secondaryText;
    }
  }
}
