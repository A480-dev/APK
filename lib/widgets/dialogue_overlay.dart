import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:blockrush/models/dialogue_line.dart';
import 'package:blockrush/models/story_character.dart';
import 'package:blockrush/config/theme.dart';

class DialogueOverlay extends ConsumerStatefulWidget {
  final List<DialogueLine> dialogues;
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;
  final bool canSkip;
  final bool showSkipButton;
  
  const DialogueOverlay({
    super.key,
    required this.dialogues,
    this.onComplete,
    this.onSkip,
    this.canSkip = true,
    this.showSkipButton = true,
  });
  
  @override
  ConsumerState<DialogueOverlay> createState() => _DialogueOverlayState();
}

class _DialogueOverlayState extends ConsumerState<DialogueOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _typewriterController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _typewriterAnimation;
  
  int _currentDialogueIndex = 0;
  String _displayedText = '';
  bool _isTyping = false;
  bool _showContinueButton = false;
  Timer? _typewriterTimer;
  
  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _typewriterController = AnimationController(
      duration: const Duration(milliseconds: 40),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _typewriterAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _typewriterController,
      curve: Curves.linear,
    ));
    
    _startDialogue();
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _typewriterController.dispose();
    _typewriterTimer?.cancel();
    super.dispose();
  }
  
  void _startDialogue() {
    if (widget.dialogues.isEmpty) {
      widget.onComplete?.call();
      return;
    }
    
    _fadeController.forward();
    _startTypewriter();
  }
  
  void _startTypewriter() {
    if (_currentDialogueIndex >= widget.dialogues.length) {
      _endDialogue();
      return;
    }
    
    final currentDialogue = widget.dialogues[_currentDialogueIndex];
    _displayedText = '';
    _isTyping = true;
    _showContinueButton = false;
    
    final fullText = currentDialogue.text;
    final speed = currentDialogue.typewriterSpeed;
    int currentIndex = 0;
    
    _typewriterTimer?.cancel();
    _typewriterTimer = Timer.periodic(Duration(milliseconds: speed), (timer) {
      if (currentIndex < fullText.length) {
        setState(() {
          _displayedText = fullText.substring(0, currentIndex + 1);
          currentIndex++;
        });
        
        _typewriterController.forward().then((_) {
          _typewriterController.reset();
        });
      } else {
        timer.cancel();
        setState(() {
          _isTyping = false;
          _showContinueButton = true;
        });
      }
    });
  }
  
  void _onTap() {
    if (_isTyping) {
      // Completar el texto inmediatamente
      _typewriterTimer?.cancel();
      final currentDialogue = widget.dialogues[_currentDialogueIndex];
      setState(() {
        _displayedText = currentDialogue.text;
        _isTyping = false;
        _showContinueButton = true;
      });
    } else {
      _nextDialogue();
    }
  }
  
  void _nextDialogue() {
    _currentDialogueIndex++;
    
    if (_currentDialogueIndex >= widget.dialogues.length) {
      _endDialogue();
    } else {
      _startTypewriter();
    }
  }
  
  void _endDialogue() {
    _fadeController.reverse().then((_) {
      widget.onComplete?.call();
    });
  }
  
  void _skipDialogue() {
    if (!widget.canSkip) return;
    
    _showSkipConfirmation();
  }
  
  void _showSkipConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          'Saltar cinemática',
          style: TextStyle(
            color: AppTheme.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          '¿Saltar cinemática? (puedes verla de nuevo en el mapa de historia)',
          style: TextStyle(
            color: AppTheme.secondaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.secondaryAccent),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onSkip?.call();
              _endDialogue();
            },
            child: Text(
              'Saltar',
              style: TextStyle(color: AppTheme.dangerColor),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (_currentDialogueIndex >= widget.dialogues.length) {
      return const SizedBox.shrink();
    }
    
    final currentDialogue = widget.dialogues[_currentDialogueIndex];
    final character = currentDialogue.character;
    
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: GestureDetector(
            onTap: _onTap,
            child: Container(
              color: Colors.black.withOpacity(0.8),
              child: Column(
                children: [
                  const Spacer(),
                  
                  // Panel de diálogo
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.secondaryText.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botón de saltar (si corresponde)
                        if (widget.showSkipButton && widget.canSkip)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: _skipDialogue,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.dangerColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.dangerColor.withOpacity(0.5),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    'Saltar todo',
                                    style: TextStyle(
                                      color: AppTheme.dangerColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        
                        // Contenido del diálogo
                        if (character.hasAvatar) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar del personaje
                              _buildAvatar(character),
                              const SizedBox(width: 16),
                              
                              // Nombre y texto
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Nombre del personaje
                                    Text(
                                      character.displayName,
                                      style: TextStyle(
                                        color: character.primaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // Texto del diálogo
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryBackground.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _displayedText,
                                        style: TextStyle(
                                          color: AppTheme.primaryText,
                                          fontSize: 16,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          // Diálogo del narrador (centrado)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBackground.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _displayedText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                color: AppTheme.secondaryText,
                fontSize: 16,
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
                        ],
                        
                        const SizedBox(height: 12),
                        
                        // Botón de continuar
                        if (_showContinueButton)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Toca para continuar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ).animate(onPlay: (controller) => controller.repeat())
                                .shimmer(
                                  duration: const Duration(milliseconds: 1500),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildAvatar(StoryCharacter character) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: character.primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: character.primaryColor.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: _buildAvatarShape(character),
    );
  }
  
  Widget _buildAvatarShape(StoryCharacter character) {
    switch (character.avatarShape) {
      case 'circle':
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: character.primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: character.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
        
      case 'square':
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                character.primaryColor,
                character.secondaryColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: character.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        );
        
      case 'hexagon':
        return CustomPaint(
          painter: HexagonPainter(character.primaryColor),
          child: Container(
            width: 40,
            height: 40,
          ),
        );
        
      case 'triangle':
        return CustomPaint(
          painter: TrianglePainter(character.primaryColor),
          child: Container(
            width: 40,
            height: 40,
          ),
        );
        
      case 'diamond':
        return Transform.rotate(
          angle: 45 * 3.14159 / 180,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: character.primaryColor,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: character.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        );
        
      case 'oval':
        return Container(
          width: 40,
          height: 50,
          decoration: BoxDecoration(
            color: character.primaryColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: character.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        );
        
      case 'pentagon':
        return CustomPaint(
          painter: PentagonPainter(character.primaryColor),
          child: Container(
            width: 40,
            height: 40,
          ),
        );
        
      default:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: character.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
        );
    }
  }
}

// Custom painters para formas de avatares
class HexagonPainter extends CustomPainter {
  final Color color;
  
  HexagonPainter(this.color);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * 3.14159 / 180;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant) => false;
}

class TrianglePainter extends CustomPainter {
  final Color color;
  
  TrianglePainter(this.color);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant) => false;
}

class PentagonPainter extends CustomPainter {
  final Color color;
  
  PentagonPainter(this.color);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72 - 90) * 3.14159 / 180;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant) => false;
}

// Funciones matemáticas auxiliares
double cos(double angle) => math.cos(angle);
double sin(double angle) => math.sin(angle);
