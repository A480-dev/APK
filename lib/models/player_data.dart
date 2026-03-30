import 'package:blockrush/config/constants.dart';

class PlayerData {
  final int highScore;
  final int currentLevel;
  final int coins;
  final int streak;
  final DateTime? lastPlayDate;
  final DateTime? dailyWheelTimestamp;
  final Map<String, int> powerUps;
  final int totalGamesPlayed;
  final bool soundEnabled;
  final bool hapticEnabled;

  const PlayerData({
    this.highScore = 0,
    this.currentLevel = 1,
    this.coins = 0,
    this.streak = 0,
    this.lastPlayDate,
    this.dailyWheelTimestamp,
    this.powerUps = const {},
    this.totalGamesPlayed = 0,
    this.soundEnabled = true,
    this.hapticEnabled = true,
  });

  PlayerData copyWith({
    int? highScore,
    int? currentLevel,
    int? coins,
    int? streak,
    DateTime? lastPlayDate,
    DateTime? dailyWheelTimestamp,
    Map<String, int>? powerUps,
    int? totalGamesPlayed,
    bool? soundEnabled,
    bool? hapticEnabled,
  }) {
    return PlayerData(
      highScore: highScore ?? this.highScore,
      currentLevel: currentLevel ?? this.currentLevel,
      coins: coins ?? this.coins,
      streak: streak ?? this.streak,
      lastPlayDate: lastPlayDate ?? this.lastPlayDate,
      dailyWheelTimestamp: dailyWheelTimestamp ?? this.dailyWheelTimestamp,
      powerUps: powerUps ?? this.powerUps,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
    );
  }

  // Verificar si puede girar la ruleta diaria
  bool canSpinWheel() {
    if (dailyWheelTimestamp == null) return true;
    
    final now = DateTime.now();
    final lastSpin = dailyWheelTimestamp!;
    
    // Puede girar si es un día diferente
    return now.year != lastSpin.year || 
           now.month != lastSpin.month || 
           now.day != lastSpin.day;
  }

  // Obtener recompensa de streak
  int getStreakReward() {
    if (streak == 0) return 0;
    if (streak >= GameConstants.streakCoins.length) {
      return GameConstants.streakCoins.last;
    }
    return GameConstants.streakCoins[streak - 1];
  }

  // Verificar si mantuvo la racha
  bool maintainedStreak() {
    if (lastPlayDate == null) return true;
    
    final now = DateTime.now();
    final lastPlay = lastPlayDate!;
    
    final difference = now.difference(lastPlay).inDays;
    return difference <= 1; // Permitir 1 día de diferencia
  }

  // Actualizar streak basado en la fecha de juego
  PlayerData updateStreak() {
    final now = DateTime.now();
    
    if (lastPlayDate == null) {
      // Primer día jugando
      return copyWith(
        streak: 1,
        lastPlayDate: now,
      );
    }
    
    final difference = now.difference(lastPlayDate!).inDays;
    
    if (difference == 0) {
      // Mismo día, no cambiar streak
      return copyWith(lastPlayDate: now);
    } else if (difference == 1) {
      // Día consecutivo, aumentar streak
      return copyWith(
        streak: streak + 1,
        lastPlayDate: now,
      );
    } else {
      // Rompió la racha, reiniciar
      return copyWith(
        streak: 1,
        lastPlayDate: now,
      );
    }
  }

  // Añadir monedas
  PlayerData addCoins(int amount) {
    return copyWith(coins: coins + amount);
  }

  // Gastar monedas
  PlayerData spendCoins(int amount) {
    if (coins < amount) return this;
    return copyWith(coins: coins - amount);
  }

  // Añadir power-up
  PlayerData addPowerUp(String powerUpType, int quantity) {
    final newPowerUps = Map<String, int>.from(powerUps);
    newPowerUps[powerUpType] = (newPowerUps[powerUpType] ?? 0) + quantity;
    return copyWith(powerUps: newPowerUps);
  }

  // Usar power-up
  PlayerData usePowerUp(String powerUpType) {
    final currentQuantity = powerUps[powerUpType] ?? 0;
    if (currentQuantity <= 0) return this;
    
    final newPowerUps = Map<String, int>.from(powerUps);
    newPowerUps[powerUpType] = currentQuantity - 1;
    
    return copyWith(powerUps: newPowerUps);
  }

  // Obtener cantidad de un power-up
  int getPowerUpQuantity(String powerUpType) {
    return powerUps[powerUpType] ?? 0;
  }

  // Verificar si puede comprar power-up
  bool canBuyPowerUp(String powerUpType, int cost) {
    return coins >= cost;
  }

  // Comprar power-up
  PlayerData buyPowerUp(String powerUpType, int cost) {
    if (!canBuyPowerUp(powerUpType, cost)) return this;
    
    return addPowerUp(powerUpType, 1).spendCoins(cost);
  }

  // Incrementar partidas jugadas
  PlayerData incrementGamesPlayed() {
    return copyWith(totalGamesPlayed: totalGamesPlayed + 1);
  }

  // Subir de nivel
  PlayerData levelUp() {
    return copyWith(
      currentLevel: currentLevel + 1,
      coins: coins + GameConstants.coinsPerLevel,
    );
  }

  // Actualizar high score
  PlayerData updateHighScore(int score) {
    if (score <= highScore) return this;
    return copyWith(highScore: score);
  }

  // Convertir a JSON para SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      GameConstants.keyHighScore: highScore,
      GameConstants.keyCurrentLevel: currentLevel,
      GameConstants.keyCoins: coins,
      GameConstants.keyStreak: streak,
      GameConstants.keyLastPlayDate: lastPlayDate?.toIso8601String(),
      GameConstants.keyDailyWheelTimestamp: dailyWheelTimestamp?.toIso8601String(),
      GameConstants.keyPowerUps: powerUps,
      GameConstants.keyTotalGamesPlayed: totalGamesPlayed,
      GameConstants.keySoundEnabled: soundEnabled,
      GameConstants.keyHapticEnabled: hapticEnabled,
    };
  }

  // Crear desde JSON
  factory PlayerData.fromJson(Map<String, dynamic> json) {
    return PlayerData(
      highScore: json[GameConstants.keyHighScore] ?? 0,
      currentLevel: json[GameConstants.keyCurrentLevel] ?? 1,
      coins: json[GameConstants.keyCoins] ?? 0,
      streak: json[GameConstants.keyStreak] ?? 0,
      lastPlayDate: json[GameConstants.keyLastPlayDate] != null 
          ? DateTime.parse(json[GameConstants.keyLastPlayDate])
          : null,
      dailyWheelTimestamp: json[GameConstants.keyDailyWheelTimestamp] != null
          ? DateTime.parse(json[GameConstants.keyDailyWheelTimestamp])
          : null,
      powerUps: Map<String, int>.from(json[GameConstants.keyPowerUps] ?? {}),
      totalGamesPlayed: json[GameConstants.keyTotalGamesPlayed] ?? 0,
      soundEnabled: json[GameConstants.keySoundEnabled] ?? true,
      hapticEnabled: json[GameConstants.keyHapticEnabled] ?? true,
    );
  }

  @override
  String toString() {
    return 'PlayerData('
        'highScore: $highScore, '
        'level: $currentLevel, '
        'coins: $coins, '
        'streak: $streak, '
        'games: $totalGamesPlayed'
        ')';
  }
}
