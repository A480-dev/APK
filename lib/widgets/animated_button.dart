import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:blockrush/config/theme.dart';

class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool isGradient;
  final bool isLoading;
  final bool isDisabled;
  final Duration animationDuration;
  
  const AnimatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.isGradient = true,
    this.isLoading = false,
    this.isDisabled = false,
    this.animationDuration = const Duration(milliseconds: 200),
  });
  
  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.isGradient) {
      _shimmerController.repeat();
    }
  }
  
  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }
  
  void _handleTapDown(TapDownDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      setState(() {
        _isPressed = true;
      });
      _scaleController.forward();
    }
  }
  
  void _handleTapUp(TapUpDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      setState(() {
        _isPressed = false;
      });
      _scaleController.reverse();
      widget.onPressed?.call();
    }
  }
  
  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _scaleController.reverse();
  }
  
  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = widget.backgroundColor ?? 
        (widget.isGradient ? null : AppTheme.primaryAccent);
    final effectiveForegroundColor = widget.foregroundColor ?? Colors.white;
    final effectiveBorderRadius = widget.borderRadius ?? BorderRadius.circular(12);
    
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _shimmerAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: AnimatedContainer(
              duration: widget.animationDuration,
              width: widget.width,
              height: widget.height,
              padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: widget.isGradient && !widget.isDisabled
                    ? AppTheme.primaryGradient
                    : null,
                color: effectiveBackgroundColor,
                borderRadius: effectiveBorderRadius,
                boxShadow: [
                  if (!widget.isDisabled && !_isPressed)
                    BoxShadow(
                      color: (effectiveBackgroundColor ?? AppTheme.primaryAccent)
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Stack(
                children: [
                  // Efecto shimmer para botones con gradiente
                  if (widget.isGradient && !widget.isDisabled)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: effectiveBorderRadius,
                        child: Transform.translate(
                          offset: Offset(_shimmerAnimation.value * 200, 0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withOpacity(0.3),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  // Contenido del botón
                  Center(
                    child: widget.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                effectiveForegroundColor,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.icon != null) ...[
                                widget.icon!,
                                const SizedBox(width: 8),
                              ],
                              Text(
                                widget.text,
                                style: TextStyle(
                                  color: effectiveForegroundColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  shadows: [
                                    if (widget.isGradient)
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Widget para botón primario grande
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  
  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      isGradient: true,
      isLoading: isLoading,
      isDisabled: isDisabled,
      width: width,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    );
  }
}

// Widget para botón secundario
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  
  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      backgroundColor: AppTheme.surfaceColor,
      foregroundColor: AppTheme.primaryText,
      isGradient: false,
      isLoading: isLoading,
      isDisabled: isDisabled,
      width: width,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }
}

// Widget para botón de icono circular
class IconButtonWidget extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final bool isLoading;
  final bool isDisabled;
  
  const IconButtonWidget({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
    this.isLoading = false,
    this.isDisabled = false,
  });
  
  @override
  State<IconButtonWidget> createState() => _IconButtonWidgetState();
}

class _IconButtonWidgetState extends State<IconButtonWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.isLoading) {
      _rotationController.repeat();
    }
  }
  
  @override
  void didUpdateWidget(IconButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
        _rotationController.reset();
      }
    }
  }
  
  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = widget.backgroundColor ?? AppTheme.primaryAccent;
    final effectiveIconColor = widget.iconColor ?? Colors.white;
    
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.isDisabled || widget.isLoading ? null : widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              gradient: widget.isDisabled
                  ? LinearGradient(
                      colors: [Colors.grey[400]!, Colors.grey[600]!],
                    )
                  : LinearGradient(
                      colors: [effectiveBackgroundColor, effectiveBackgroundColor.withOpacity(0.8)],
                    ),
              borderRadius: BorderRadius.circular(widget.size / 2),
              boxShadow: [
                if (!widget.isDisabled && !widget.isLoading)
                  BoxShadow(
                    color: effectiveBackgroundColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: widget.isLoading
                ? Transform.rotate(
                    angle: _rotationAnimation.value * 2 * 3.14159,
                    child: Icon(
                      Icons.refresh,
                      color: effectiveIconColor,
                      size: widget.size * 0.5,
                    ),
                  )
                : Icon(
                    widget.icon,
                    color: widget.isDisabled ? Colors.grey : effectiveIconColor,
                    size: widget.size * 0.5,
                  ),
          ),
        );
      },
    );
  }
}

// Widget para botón flotante
class FloatingActionButtonWidget extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool isLoading;
  final bool isDisabled;
  
  const FloatingActionButtonWidget({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
    this.isLoading = false,
    this.isDisabled = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final button = IconButtonWidget(
      icon: icon,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      size: 56,
      isLoading: isLoading,
      isDisabled: isDisabled,
    );
    
    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }
    
    return button;
  }
}
