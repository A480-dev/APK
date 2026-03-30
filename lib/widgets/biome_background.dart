import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:blockrush/models/generated_level.dart';

class BiomeBackground extends StatefulWidget {
  final Biome biome;
  final Widget child;
  final bool showParticles;
  
  const BiomeBackground({
    super.key,
    required this.biome,
    required this.child,
    this.showParticles = true,
  });
  
  @override
  State<BiomeBackground> createState() => _BiomeBackgroundState();
}

class _BiomeBackgroundState extends State<BiomeBackground>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late List<Particle> _particles;
  
  @override
  void initState() {
    super.initState();
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    
    _particles = _generateParticles();
    _particleController.repeat();
  }
  
  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo gradiente del bioma
        Container(
          decoration: BoxDecoration(
            gradient: _getBiomeGradient(),
          ),
        ),
        
        // Partículas animadas
        if (widget.showParticles)
          ..._particles.map((particle) => _buildParticle(particle)),
        
        // Contenido principal
        widget.child,
      ],
    );
  }
  
  LinearGradient _getBiomeGradient() {
    switch (widget.biome) {
      case Biome.garden:
        return const LinearGradient(
          colors: [
            Color(0xFF1B5E20), // Verde oscuro
            Color(0xFF2E7D32), // Verde medio
            Color(0xFF388E3C), // Verde claro
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
        
      case Biome.caverns:
        return const LinearGradient(
          colors: [
            Color(0xFF0D47A1), // Azul oscuro
            Color(0xFF1565C0), // Azul medio
            Color(0xFF1976D2), // Azul claro
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
        
      case Biome.volcano:
        return const LinearGradient(
          colors: [
            Color(0xFFBF360C), // Rojo oscuro
            Color(0xFFE64A19), // Rojo medio
            Color(0xFFFF6E40), // Rojo claro
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
        
      case Biome.ocean:
        return const LinearGradient(
          colors: [
            Color(0xFF01579B), // Azul profundo
            Color(FF0277BD), // Azul medio
            Color(0xFF0288D1), // Azul claro
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
        
      case Biome.storm:
        return const LinearGradient(
          colors: [
            Color(0xFF4A148C), // Púrpura oscuro
            Color(0xFF6A1B9A), // Púrpura medio
            Color(0xFF7B1FA2), // Púrpura claro
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
        
      case Biome.ice:
        return const LinearGradient(
          colors: [
            Color(0xFFE3F2FD), // Blanco azulado
            Color(0xFFBBDEFB), // Azul muy claro
            Color(0xFF90CAF9), // Azul claro
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
        
      case Biome.void:
        return const LinearGradient(
          colors: [
            Color(0xFF000000), // Negro
            Color(0xFF1A1A1A), // Gris muy oscuro
            Color(0xFF2C2C2C), // Gris oscuro
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
        
      case Biome.dome:
        return const LinearGradient(
          colors: [
            Color(0xFF424242), // Gris oscuro
            Color(0xFF616161), // Gris medio
            Color(0xFF757575), // Gris claro
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
    }
  }
  
  List<Particle> _generateParticles() {
    final particles = <Particle>[];
    final random = math.Random();
    
    switch (widget.biome) {
      case Biome.garden:
        // Hojas flotantes
        for (int i = 0; i < 15; i++) {
          particles.add(Particle(
            type: ParticleType.leaf,
            x: random.nextDouble() * MediaQuery.of(context).size.width,
            y: random.nextDouble() * MediaQuery.of(context).size.height,
            size: 8 + random.nextDouble() * 8,
            speed: 0.5 + random.nextDouble() * 0.5,
            color: _getLeafColor(random.nextInt(4)),
            rotation: random.nextDouble() * 2 * math.pi,
            rotationSpeed: (random.nextDouble() - 0.5) * 0.02,
          ));
        }
        break;
        
      case Biome.caverns:
        // Cristales brillantes
        for (int i = 0; i < 12; i++) {
          particles.add(Particle(
            type: ParticleType.crystal,
            x: random.nextDouble() * MediaQuery.of(context).size.width,
            y: random.nextDouble() * MediaQuery.of(context).size.height,
            size: 6 + random.nextDouble() * 6,
            speed: 0.3 + random.nextDouble() * 0.3,
            color: _getCrystalColor(random.nextInt(3)),
            rotation: random.nextDouble() * 2 * math.pi,
            rotationSpeed: (random.nextDouble() - 0.5) * 0.01,
          ));
        }
        break;
        
      case Biome.volcano:
        // Chispas de fuego
        for (int i = 0; i < 20; i++) {
          particles.add(Particle(
            type: ParticleType.spark,
            x: random.nextDouble() * MediaQuery.of(context).size.width,
            y: random.nextDouble() * MediaQuery.of(context).size.height,
            size: 4 + random.nextDouble() * 4,
            speed: 1.0 + random.nextDouble() * 1.0,
            color: _getSparkColor(random.nextInt(3)),
            rotation: random.nextDouble() * 2 * math.pi,
            rotationSpeed: (random.nextDouble() - 0.5) * 0.03,
          ));
        }
        break;
        
      case Biome.ocean:
        // Burbujas
        for (int i = 0; i < 10; i++) {
          particles.add(Particle(
            type: ParticleType.bubble,
            x: random.nextDouble() * MediaQuery.of(context).size.width,
            y: MediaQuery.of(context).size.height + random.nextDouble() * 100,
            size: 8 + random.nextDouble() * 8,
            speed: -0.3 - random.nextDouble() * 0.3,
            color: _getBubbleColor(random.nextInt(2)),
            rotation: 0,
            rotationSpeed: 0,
          ));
        }
        break;
        
      case Biome.storm:
        // Relámpagos ocasionales
        for (int i = 0; i < 3; i++) {
          particles.add(Particle(
            type: ParticleType.lightning,
            x: random.nextDouble() * MediaQuery.of(context).size.width,
            y: random.nextDouble() * MediaQuery.of(context).size.height,
            size: 20 + random.nextDouble() * 20,
            speed: 0,
            color: const Color(0xFFFFEB3B),
            rotation: 0,
            rotationSpeed: 0,
            opacity: 0.0,
            flashDuration: 200 + random.nextInt(400),
          ));
        }
        break;
        
      case Biome.ice:
        // Copos de nieve
        for (int i = 0; i < 25; i++) {
          particles.add(Particle(
            type: ParticleType.snowflake,
            x: random.nextDouble() * MediaQuery.of(context).size.width,
            y: -20 - random.nextDouble() * 20,
            size: 4 + random.nextDouble() * 4,
            speed: 0.2 + random.nextDouble() * 0.2,
            color: Colors.white,
            rotation: random.nextDouble() * 2 * math.pi,
            rotationSpeed: (random.nextDouble() - 0.5) * 0.02,
          ));
        }
        break;
        
      case Biome.void:
        // Estrellas y nebulosas
        for (int i = 0; i < 30; i++) {
          particles.add(Particle(
            type: ParticleType.star,
            x: random.nextDouble() * MediaQuery.of(context).size.width,
            y: random.nextDouble() * MediaQuery.of(context).size.height,
            size: 2 + random.nextDouble() * 2,
            speed: 0.1 + random.nextDouble() * 0.1,
            color: _getStarColor(random.nextInt(4)),
            rotation: 0,
            rotationSpeed: 0,
            twinkle: true,
          ));
        }
        break;
        
      case Biome.dome:
        // Energía eléctrica
        for (int i = 0; i < 15; i++) {
          particles.add(Particle(
            type: ParticleType.energy,
            x: random.nextDouble() * MediaQuery.of(context).size.width,
            y: random.nextDouble() * MediaQuery.of(context).size.height,
            size: 6 + random.nextDouble() * 6,
            speed: 0.4 + random.nextDouble() * 0.4,
            color: _getEnergyColor(random.nextInt(3)),
            rotation: random.nextDouble() * 2 * math.pi,
            rotationSpeed: (random.nextDouble() - 0.5) * 0.04,
          ));
        }
        break;
    }
    
    return particles;
  }
  
  Widget _buildParticle(Particle particle) {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        final progress = _particleController.value;
        double x = particle.x;
        double y = particle.y;
        double opacity = 1.0;
        
        // Actualizar posición
        switch (particle.type) {
          case ParticleType.bubble:
            y += particle.speed * progress * 100;
            if (y < -50) y = MediaQuery.of(context).size.height + 50;
            break;
          case ParticleType.snowflake:
            y += particle.speed * progress * 100;
            x += math.sin(progress * 2 * math.pi + particle.rotation) * 20;
            if (y > MediaQuery.of(context).size.height + 50) {
              y = -50;
              x = math.Random().nextDouble() * MediaQuery.of(context).size.width;
            }
            break;
          case ParticleType.lightning:
            // Relámpagos parpadeantes
            final flashTime = (progress * 1000) % (particle.flashDuration ?? 1000);
            opacity = flashTime < 100 ? 0.8 : 0.0;
            break;
          case ParticleType.star:
            // Estrellas titilantes
            opacity = 0.5 + math.sin(progress * 4 * math.pi + particle.rotation) * 0.5;
            break;
          default:
            y += particle.speed * progress * 50;
            if (y > MediaQuery.of(context).size.height + 50) {
              y = -50;
              x = math.Random().nextDouble() * MediaQuery.of(context).size.width;
            }
        }
        
        return Positioned(
          left: x,
          top: y,
          child: Transform.rotate(
            angle: particle.rotation + (particle.rotationSpeed * progress * 2 * math.pi),
            child: Opacity(
              opacity: opacity,
              child: _buildParticleShape(particle),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildParticleShape(Particle particle) {
    switch (particle.type) {
      case ParticleType.leaf:
        return Container(
          width: particle.size,
          height: particle.size,
          decoration: BoxDecoration(
            color: particle.color,
            borderRadius: BorderRadius.circular(particle.size / 4),
          ),
        );
        
      case ParticleType.crystal:
        return Container(
          width: particle.size,
          height: particle.size,
          decoration: BoxDecoration(
            color: particle.color,
            shape: BoxShape.polygon,
            boxShadow: [
              BoxShadow(
                color: particle.color.withOpacity(0.5),
                blurRadius: 4,
              ),
            ],
          ),
        );
        
      case ParticleType.spark:
        return Container(
          width: particle.size,
          height: particle.size,
          decoration: BoxDecoration(
            color: particle.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: particle.color.withOpacity(0.8),
                blurRadius: particle.size / 2,
              ),
            ],
          ),
        );
        
      case ParticleType.bubble:
        return Container(
          width: particle.size,
          height: particle.size,
          decoration: BoxDecoration(
            color: particle.color.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: particle.color,
              width: 1,
            ),
          ),
        );
        
      case ParticleType.snowflake:
        return Icon(
          Icons.ac_unit,
          color: particle.color,
          size: particle.size,
        );
        
      case ParticleType.lightning:
        return Container(
          width: particle.size,
          height: particle.size * 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                particle.color,
                Colors.white,
                particle.color,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        );
        
      case ParticleType.star:
        return Icon(
          Icons.star,
          color: particle.color,
          size: particle.size,
        );
        
      case ParticleType.energy:
        return Container(
          width: particle.size,
          height: particle.size,
          decoration: BoxDecoration(
            color: particle.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: particle.color.withOpacity(0.6),
                blurRadius: particle.size,
              ),
            ],
          ),
        );
    }
  }
  
  Color _getLeafColor(int index) {
    final colors = [
      const Color(0xFF4CAF50),
      const Color(0xFF8BC34A),
      const Color(0xFFCDDC39),
      const Color(0xFF689F38),
    ];
    return colors[index % colors.length];
  }
  
  Color _getCrystalColor(int index) {
    final colors = [
      const Color(0xFF2196F3),
      const Color(0xFF03A9F4),
      const Color(0xFF00BCD4),
    ];
    return colors[index % colors.length];
  }
  
  Color _getSparkColor(int index) {
    final colors = [
      const Color(0xFFFF5722),
      const Color(0xFFFF9800),
      const Color(0xFFFFEB3B),
    ];
    return colors[index % colors.length];
  }
  
  Color _getBubbleColor(int index) {
    final colors = [
      const Color(0xFFE1F5FE),
      const Color(0xFFB3E5FC),
    ];
    return colors[index % colors.length];
  }
  
  Color _getStarColor(int index) {
    final colors = [
      Colors.white,
      const Color(0xFFFFEB3B),
      const Color(0xFF81D4FA),
      const Color(0xFFE1BEE7),
    ];
    return colors[index % colors.length];
  }
  
  Color _getEnergyColor(int index) {
    final colors = [
      const Color(0xFF9C27B0),
      const Color(0xFFFFD700),
      const Color(0xFF00E5FF),
    ];
    return colors[index % colors.length];
  }
}

class Particle {
  final ParticleType type;
  double x;
  double y;
  final double size;
  final double speed;
  final Color color;
  final double rotation;
  final double rotationSpeed;
  final double opacity;
  final bool twinkle;
  final int? flashDuration;
  
  Particle({
    required this.type,
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    this.opacity = 1.0,
    this.twinkle = false,
    this.flashDuration,
  });
}

enum ParticleType {
  leaf,
  crystal,
  spark,
  bubble,
  snowflake,
  lightning,
  star,
  energy,
}
