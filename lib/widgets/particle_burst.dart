import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:blockrush/config/theme.dart';

class ParticleBurst extends StatefulWidget {
  final int particleCount;
  final Color? baseColor;
  final Duration duration;
  final double spreadRadius;
  
  const ParticleBurst({
    super.key,
    this.particleCount = 30,
    this.baseColor,
    this.duration = const Duration(milliseconds: 1500),
    this.spreadRadius = 100,
  });
  
  @override
  State<ParticleBurst> createState() => _ParticleBurstState();
}

class _ParticleBurstState extends State<ParticleBurst>
    with TickerProviderStateMixin {
  late List<Particle> particles;
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    particles = _generateParticles();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _controller.forward().then((_) => _onAnimationComplete());
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  List<Particle> _generateParticles() {
    return List.generate(widget.particleCount, (index) {
      final angle = (index / widget.particleCount) * 2 * 3.14159;
      final velocity = 50 + (index % 3) * 30;
      final color = widget.baseColor ?? 
          AppTheme.blockColors[index % AppTheme.blockColors.length];
      
      return Particle(
        angle: angle,
        velocity: velocity.toDouble(),
        color: color,
        size: 4.0 + (index % 3) * 2,
        rotationSpeed: (index % 2 == 0 ? 1 : -1) * (2 + index % 3),
      );
    });
  }
  
  void _onAnimationComplete() {
    if (mounted) {
      setState(() {
        particles = [];
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: particles.map((particle) {
            final progress = _controller.value;
            final x = particle.velocity * progress * 0.01 * 
                      widget.spreadRadius * cos(particle.angle);
            final y = particle.velocity * progress * 0.01 * 
                      widget.spreadRadius * sin(particle.angle) - 
                      (progress * progress * 50);
            final opacity = (1 - progress).clamp(0.0, 1.0);
            final rotation = particle.rotationSpeed * progress * 2 * 3.14159;
            
            return Positioned(
              left: x,
              top: y,
              child: Transform.rotate(
                angle: rotation,
                child: Container(
                  width: particle.size,
                  height: particle.size,
                  decoration: BoxDecoration(
                    color: particle.color.withOpacity(opacity),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: particle.color.withOpacity(opacity * 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class Particle {
  final double angle;
  final double velocity;
  final Color color;
  final double size;
  final double rotationSpeed;
  
  Particle({
    required this.angle,
    required this.velocity,
    required this.color,
    required this.size,
    required this.rotationSpeed,
  });
}

double cos(double angle) => angle.cos();
double sin(double angle) => angle.sin();

extension on double {
  double cos() => math.cos(this);
  double sin() => math.sin(this);
}
