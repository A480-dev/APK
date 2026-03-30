import 'package:blockrush/config/constants.dart';

class Mission {
  final String id;
  final String title;
  final String description;
  final MissionType type;
  final int target;
  final int current;
  final int reward;
  final bool isCompleted;
  final bool isClaimed;
  final DateTime createdAt;

  const Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    this.current = 0,
    required this.reward,
    this.isCompleted = false,
    this.isClaimed = false,
    required this.createdAt,
  });

  Mission copyWith({
    String? id,
    String? title,
    String? description,
    MissionType? type,
    int? target,
    int? current,
    int? reward,
    bool? isCompleted,
    bool? isClaimed,
    DateTime? createdAt,
  }) {
    return Mission(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      target: target ?? this.target,
      current: current ?? this.current,
      reward: reward ?? this.reward,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Progreso de la misión (0.0 a 1.0)
  double get progress {
    if (target == 0) return 1.0;
    return (current / target).clamp(0.0, 1.0);
  }

  // Verificar si está completada
  bool get isMissionCompleted {
    return current >= target;
  }

  // Actualizar progreso
  Mission updateProgress(int increment) {
    final newCurrent = (current + increment).clamp(0, target);
    final completed = newCurrent >= target;
    
    return copyWith(
      current: newCurrent,
      isCompleted: completed,
    );
  }

  // Reclamar recompensa
  Mission claim() {
    return copyWith(isClaimed: true);
  }

  // Verificar si la misión está activa (no reclamada y no expirada)
  bool get isActive {
    if (isClaimed) return false;
    
    final now = DateTime.now();
    final difference = now.difference(createdAt).inHours;
    return difference < GameConstants.hoursBetweenMissionReset;
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'target': target,
      'current': current,
      'reward': reward,
      'isCompleted': isCompleted,
      'isClaimed': isClaimed,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Crear desde JSON
  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: MissionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MissionType.clearLines,
      ),
      target: json['target'],
      current: json['current'] ?? 0,
      reward: json['reward'],
      isCompleted: json['isCompleted'] ?? false,
      isClaimed: json['isClaimed'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Mission && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Mission($title: $current/$target, ${isCompleted ? "Completed" : "In Progress"})';
  }
}

// Tipos de misiones
enum MissionType {
  clearLines,
  reachCombo,
  playGames,
  reachLevel,
  scorePoints,
  usePowerUps,
  collectCoins,
  playMinutes,
}

class MissionGenerator {
  // Generar misiones diarias aleatorias
  static List<Mission> generateDailyMissions() {
    final now = DateTime.now();
    final missions = <Mission>[];
    
    // Misión 1: Limpiar líneas
    missions.add(Mission(
      id: 'daily_clear_lines_${now.millisecondsSinceEpoch}',
      title: 'Maestro de Líneas',
      description: 'Limpia 5 líneas en una partida',
      type: MissionType.clearLines,
      target: 5,
      reward: 50,
      createdAt: now,
    ));
    
    // Misión 2: Alcanzar combo
    missions.add(Mission(
      id: 'daily_combo_${now.millisecondsSinceEpoch}',
      title: 'Experto en Combos',
      description: 'Alcanza un combo ×3',
      type: MissionType.reachCombo,
      target: 3,
      reward: 30,
      createdAt: now,
    ));
    
    // Misión 3: Jugar partidas
    missions.add(Mission(
      id: 'daily_play_games_${now.millisecondsSinceEpoch}',
      title: 'Jugador Activo',
      description: 'Juega 3 partidas hoy',
      type: MissionType.playGames,
      target: 3,
      reward: 40,
      createdAt: now,
    ));
    
    return missions;
  }

  // Generar misión basada en el tipo
  static Mission generateMission(MissionType type, DateTime createdAt) {
    switch (type) {
      case MissionType.clearLines:
        return Mission(
          id: 'clear_lines_${createdAt.millisecondsSinceEpoch}',
          title: 'Limpiador de Líneas',
          description: 'Limpia 10 líneas',
          type: type,
          target: 10,
          reward: 40,
          createdAt: createdAt,
        );
        
      case MissionType.reachCombo:
        return Mission(
          id: 'reach_combo_${createdAt.millisecondsSinceEpoch}',
          title: 'Combo Master',
          description: 'Alcanza un combo ×4',
          type: type,
          target: 4,
          reward: 60,
          createdAt: createdAt,
        );
        
      case MissionType.playGames:
        return Mission(
          id: 'play_games_${createdAt.millisecondsSinceEpoch}',
          title: 'Jugador Dedicado',
          description: 'Juega 5 partidas',
          type: type,
          target: 5,
          reward: 50,
          createdAt: createdAt,
        );
        
      case MissionType.reachLevel:
        return Mission(
          id: 'reach_level_${createdAt.millisecondsSinceEpoch}',
          title: 'Nivel Avanzado',
          description: 'Alcanza el nivel 10',
          type: type,
          target: 10,
          reward: 80,
          createdAt: createdAt,
        );
        
      case MissionType.scorePoints:
        return Mission(
          id: 'score_points_${createdAt.millisecondsSinceEpoch}',
          title: 'Puntaje Alto',
          description: 'Alcanza 5000 puntos',
          type: type,
          target: 5000,
          reward: 70,
          createdAt: createdAt,
        );
        
      case MissionType.usePowerUps:
        return Mission(
          id: 'use_powerups_${createdAt.millisecondsSinceEpoch}',
          title: 'Estratega',
          description: 'Usa 3 power-ups',
          type: type,
          target: 3,
          reward: 45,
          createdAt: createdAt,
        );
        
      case MissionType.collectCoins:
        return Mission(
          id: 'collect_coins_${createdAt.millisecondsSinceEpoch}',
          title: 'Cazador de Monedas',
          description: 'Recoge 200 monedas',
          type: type,
          target: 200,
          reward: 55,
          createdAt: createdAt,
        );
        
      case MissionType.playMinutes:
        return Mission(
          id: 'play_minutes_${createdAt.millisecondsSinceEpoch}',
          title: 'Maratón',
          description: 'Juega durante 15 minutos',
          type: type,
          target: 15,
          reward: 65,
          createdAt: createdAt,
        );
    }
  }
}
