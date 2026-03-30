import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:blockrush/models/chapter.dart';
import 'package:blockrush/config/theme.dart';

class ChapterCard extends ConsumerWidget {
  final Chapter chapter;
  final VoidCallback? onTap;
  final bool isSelected;
  
  const ChapterCard({
    super.key,
    required this.chapter,
    this.onTap,
    this.isSelected = false,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: chapter.isAvailable ? onTap : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: _getGradientForChapter(),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getBorderColor(),
            width: _getBorderWidth(),
          ),
          boxShadow: [
            if (chapter.isAvailable)
              BoxShadow(
                color: _getShadowColor(),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Avatar del capítulo
              _buildChapterAvatar(),
              
              const SizedBox(width: 16),
              
              // Información del capítulo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título y estado
                    Row(
                      children: [
                        Text(
                          chapter.title,
                          style: TextStyle(
                            color: _getTextColor(),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Descripción
                    Text(
                      chapter.world,
                      style: TextStyle(
                        color: _getTextColor().withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Progreso y estadísticas
                    _buildProgressInfo(),
                  ],
                ),
              ),
              
              // Estrellas y acciones
              _buildRightSection(),
            ],
          ),
        ),
      ).animate(target: chapter.isAvailable ? 1 : 0)
        .scaleXY(
          begin: 0.9,
          end: 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        ),
      ),
    );
  }
  
  Widget _buildChapterAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: _getAvatarColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getAvatarBorderColor(),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              _getChapterIcon(),
              color: Colors.white,
              size: 30,
            ),
          ),
          
          // Indicador de jefe
          if (chapter.isBossLevel && !chapter.bossDefeated)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppTheme.dangerColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.warning,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildStatusBadge() {
    Widget badge;
    Color color;
    
    switch (chapter.status) {
      case ChapterStatus.locked:
        badge = const Icon(Icons.lock, size: 16);
        color = AppTheme.secondaryText;
        break;
      case ChapterStatus.available:
        badge = const Icon(Icons.play_arrow, size: 16);
        color = AppTheme.successColor;
        break;
      case ChapterStatus.inProgress:
        badge = const Icon(Icons.hourglass_empty, size: 16);
        color = AppTheme.secondaryAccent;
        break;
      case ChapterStatus.completed:
        badge = const Icon(Icons.star, size: 16);
        color = const Color(0xFFFFD700);
        break;
      case ChapterStatus.perfect:
        badge = const Icon(Icons.emoji_events, size: 16);
        color = const Color(0xFFFFD700);
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: badge,
    );
  }
  
  Widget _buildProgressInfo() {
    if (chapter.status == ChapterStatus.locked) {
      return Row(
        children: [
          Icon(
            Icons.lock,
            color: _getTextColor().withOpacity(0.5),
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            'Bloqueado',
            style: TextStyle(
              color: _getTextColor().withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barra de progreso
        Row(
          children: [
            Text(
              'Progreso: ',
              style: TextStyle(
                color: _getTextColor().withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            Text(
              '${(chapter.progress * 100).toInt()}%',
              style: TextStyle(
                color: _getTextColor(),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 4),
        
        // Barra de progreso visual
        Container(
          width: double.infinity,
          height: 4,
          decoration: BoxDecoration(
            color: _getTextColor().withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: chapter.progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 4),
        
        // Estadísticas
        Row(
          children: [
            Icon(
              Icons.star,
              color: const Color(0xFFFFD700),
              size: 14,
            ),
            const SizedBox(width: 2),
            Text(
              '${chapter.totalStars}/${chapter.maxStars}',
              style: TextStyle(
                color: _getTextColor().withOpacity(0.8),
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.monetization_on,
              color: const Color(0xFFFFD700),
              size: 14,
            ),
            const SizedBox(width: 2),
            Text(
              '${chapter.totalCoinsEarned}',
              style: TextStyle(
                color: _getTextColor().withOpacity(0.8),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildRightSection() {
    return Column(
      children: [
        // Estrellas
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final starIndex = index;
            final hasStar = starIndex < chapter.totalStars;
            
            return Icon(
              hasStar ? Icons.star : Icons.star_border,
              color: hasStar ? const Color(0xFFFFD700) : _getTextColor().withOpacity(0.3),
              size: 20,
            );
          }),
        ),
        
        const SizedBox(height: 8),
        
        // Indicador de nuevo
        if (chapter.status == ChapterStatus.available && chapter.completedLevels.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.successColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '¡NUEVO!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
            .scaleXY(
              begin: 1.0,
              end: 1.1,
              duration: const Duration(milliseconds: 1000),
            )
            .then()
            .scaleXY(
              begin: 1.1,
              end: 1.0,
              duration: const Duration(milliseconds: 1000),
            ),
      ],
    );
  }
  
  LinearGradient _getGradientForChapter() {
    switch (chapter.status) {
      case ChapterStatus.locked:
        return LinearGradient(
          colors: [
            AppTheme.surfaceColor.withOpacity(0.5),
            AppTheme.surfaceColor.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ChapterStatus.available:
        return LinearGradient(
          colors: [
            AppTheme.primaryAccent.withOpacity(0.2),
            AppTheme.primaryAccent.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ChapterStatus.inProgress:
        return LinearGradient(
          colors: [
            AppTheme.secondaryAccent.withOpacity(0.2),
            AppTheme.secondaryAccent.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ChapterStatus.completed:
        return LinearGradient(
          colors: [
            const Color(0xFFFFD700).withOpacity(0.2),
            const Color(0xFFFFD700).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ChapterStatus.perfect:
        return LinearGradient(
          colors: [
            const Color(0xFFFFD700),
            const Color(0xFFFFA000),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
  
  Color _getBorderColor() {
    switch (chapter.status) {
      case ChapterStatus.locked:
        return AppTheme.secondaryText.withOpacity(0.3);
      case ChapterStatus.available:
        return AppTheme.primaryAccent.withOpacity(0.5);
      case ChapterStatus.inProgress:
        return AppTheme.secondaryAccent.withOpacity(0.5);
      case ChapterStatus.completed:
        return const Color(0xFFFFD700).withOpacity(0.5);
      case ChapterStatus.perfect:
        return const Color(0xFFFFD700);
    }
  }
  
  double _getBorderWidth() {
    return chapter.isPerfect ? 3.0 : 1.0;
  }
  
  Color _getShadowColor() {
    switch (chapter.status) {
      case ChapterStatus.locked:
        return Colors.transparent;
      case ChapterStatus.available:
        return AppTheme.primaryAccent.withOpacity(0.3);
      case ChapterStatus.inProgress:
        return AppTheme.secondaryAccent.withOpacity(0.3);
      case ChapterStatus.completed:
        return const Color(0xFFFFD700).withOpacity(0.3);
      case ChapterStatus.perfect:
        return const Color(0xFFFFD700).withOpacity(0.5);
    }
  }
  
  Color _getTextColor() {
    switch (chapter.status) {
      case ChapterStatus.locked:
        return AppTheme.secondaryText;
      default:
        return AppTheme.primaryText;
    }
  }
  
  Color _getAvatarColor() {
    switch (chapter.biome) {
      case Biome.garden:
        return const Color(0xFF4CAF50);
      case Biome.caverns:
        return const Color(0xFF2196F3);
      case Biome.volcano:
        return const Color(0xFFFF5722);
      case Biome.ocean:
        return const Color(0xFF00BCD4);
      case Biome.storm:
        return const Color(0xFF9C27B0);
      case Biome.ice:
        return const Color(0xFF90CAF9);
      case Biome.void:
        return const Color(0xFF424242);
      case Biome.dome:
        return const Color(0xFFFFD700);
    }
  }
  
  Color _getAvatarBorderColor() {
    return Colors.white.withOpacity(0.3);
  }
  
  IconData _getChapterIcon() {
    switch (chapter.biome) {
      case Biome.garden:
        return Icons.nature;
      case Biome.caverns:
        return Icons.terrain;
      case Biome.volcano:
        return Icons.local_fire_department;
      case Biome.ocean:
        return Icons.water;
      case Biome.storm:
        return Icons.flash_on;
      case Biome.ice:
        return Icons.ac_unit;
      case Biome.void:
        return Icons.blur_on;
      case Biome.dome:
        return Icons.account_balance;
    }
  }
}
