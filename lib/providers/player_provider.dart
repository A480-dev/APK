import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blockrush/models/player_data.dart';
import 'package:blockrush/models/mission.dart';
import 'package:blockrush/services/storage_service.dart';
import 'package:blockrush/config/constants.dart';

class PlayerProvider extends StateNotifier<PlayerData> {
  PlayerProvider() : super(const PlayerData()) {
    _loadPlayerData();
  }
  
  // Cargar datos del jugador desde almacenamiento
  Future<void> _loadPlayerData() async {
    final playerData = StorageService.loadPlayerData();
    state = playerData;
  }
  
  // Guardar datos del jugador
  Future<void> _savePlayerData() async {
    await StorageService.savePlayerData(state);
  }
  
  // Actualizar high score
  Future<void> updateHighScore(int score) async {
    if (score > state.highScore) {
      state = state.updateHighScore(score);
      await _savePlayerData();
    }
  }
  
  // Subir de nivel
  Future<void> levelUp() async {
    state = state.levelUp();
    await _savePlayerData();
  }
  
  // Añadir monedas
  Future<void> addCoins(int amount) async {
    state = state.addCoins(amount);
    await _savePlayerData();
  }
  
  // Gastar monedas
  Future<bool> spendCoins(int amount) async {
    if (state.coins < amount) return false;
    
    state = state.spendCoins(amount);
    await _savePlayerData();
    return true;
  }
  
  // Actualizar streak diario
  Future<void> updateDailyStreak() async {
    state = state.updateStreak();
    await _savePlayerData();
  }
  
  // Girar ruleta diaria
  Future<bool> spinDailyWheel() async {
    if (!state.canSpinWheel()) return false;
    
    final now = DateTime.now();
    state = state.copyWith(dailyWheelTimestamp: now);
    await _savePlayerData();
    return true;
  }
  
  // Comprar power-up
  Future<bool> buyPowerUp(String powerUpType, int cost) async {
    if (!state.canBuyPowerUp(powerUpType, cost)) return false;
    
    state = state.buyPowerUp(powerUpType, cost);
    await _savePlayerData();
    return true;
  }
  
  // Usar power-up
  Future<bool> usePowerUp(String powerUpType) async {
    if (state.getPowerUpQuantity(powerUpType) <= 0) return false;
    
    state = state.usePowerUp(powerUpType);
    await _savePlayerData();
    return true;
  }
  
  // Añadir power-up (recompensa)
  Future<void> addPowerUp(String powerUpType, int quantity) async {
    state = state.addPowerUp(powerUpType, quantity);
    await _savePlayerData();
  }
  
  // Incrementar partidas jugadas
  Future<void> incrementGamesPlayed() async {
    state = state.incrementGamesPlayed();
    await _savePlayerData();
  }
  
  // Alternar sonido
  Future<void> toggleSound() async {
    state = state.copyWith(soundEnabled: !state.soundEnabled);
    await _savePlayerData();
  }
  
  // Alternar háptico
  Future<void> toggleHaptic() async {
    state = state.copyWith(hapticEnabled: !state.hapticEnabled);
    await _savePlayerData();
  }
  
  // Obtener cantidad de power-up
  int getPowerUpQuantity(String powerUpType) {
    return state.getPowerUpQuantity(powerUpType);
  }
  
  // Verificar si puede girar la ruleta
  bool canSpinWheel() {
    return state.canSpinWheel();
  }
  
  // Obtener recompensa de streak
  int getStreakReward() {
    return state.getStreakReward();
  }
  
  // Verificar si mantuvo la racha
  bool maintainedStreak() {
    return state.maintainedStreak();
  }
  
  // Resetear datos del jugador (para testing)
  Future<void> resetData() async {
    state = const PlayerData();
    await _savePlayerData();
  }
  
  // Obtener estadísticas del jugador
  PlayerStats getStats() {
    return PlayerStats(
      highScore: state.highScore,
      currentLevel: state.currentLevel,
      totalCoins: state.coins,
      currentStreak: state.streak,
      totalGamesPlayed: state.totalGamesPlayed,
      powerUpsCollected: state.powerUps.values.fold(0, (sum, qty) => sum + qty),
      canSpinWheel: canSpinWheel(),
      streakReward: getStreakReward(),
    );
  }
}

// Estadísticas del jugador
class PlayerStats {
  final int highScore;
  final int currentLevel;
  final int totalCoins;
  final int currentStreak;
  final int totalGamesPlayed;
  final int powerUpsCollected;
  final bool canSpinWheel;
  final int streakReward;
  
  const PlayerStats({
    required this.highScore,
    required this.currentLevel,
    required this.totalCoins,
    required this.currentStreak,
    required this.totalGamesPlayed,
    required this.powerUpsCollected,
    required this.canSpinWheel,
    required this.streakReward,
  });
}

// Provider de datos del jugador
final playerProvider = StateNotifierProvider<PlayerProvider, PlayerData>((ref) {
  return PlayerProvider();
});

// Provider de estadísticas
final playerStatsProvider = Provider<PlayerStats>((ref) {
  return ref.watch(playerProvider.notifier).getStats();
});

// Provider para verificar si puede girar la ruleta
final canSpinWheelProvider = Provider<bool>((ref) {
  return ref.watch(playerProvider.select((data) => data.canSpinWheel()));
});

// Provider de monedas actuales
final coinsProvider = Provider<int>((ref) {
  return ref.watch(playerProvider.select((data) => data.coins));
});

// Provider de nivel actual
final levelProvider = Provider<int>((ref) {
  return ref.watch(playerProvider.select((data) => data.currentLevel));
});

// Provider de streak actual
final streakProvider = Provider<int>((ref) {
  return ref.watch(playerProvider.select((data) => data.streak));
});

// Provider de high score
final highScoreProvider = Provider<int>((ref) {
  return ref.watch(playerProvider.select((data) => data.highScore));
});

// Provider de configuración de sonido
final soundEnabledProvider = Provider<bool>((ref) {
  return ref.watch(playerProvider.select((data) => data.soundEnabled));
});

// Provider de configuración háptica
final hapticEnabledProvider = Provider<bool>((ref) {
  return ref.watch(playerProvider.select((data) => data.hapticEnabled));
});
