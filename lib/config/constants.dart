class GameConstants {
  // Tablero
  static const int boardSize = 8;
  static const double cellSize = 40.0;
  static const double cellRadius = 6.0;
  
  // Puntuación
  static const int pointsPerBlock = 10;
  static const int pointsPerLine = 100;
  static const int comboMultiplier2 = 3; // x2 puntos para 2 líneas
  static const int comboMultiplier3 = 7; // x7 puntos para 3 líneas
  static const int comboMultiplier4 = 15; // x15 puntos para 4+ líneas
  static const int colorBonusMultiplier = 2;
  static const int crossLineMultiplier = 15; // x1.5 puntos para columna+fila
  
  // Niveles
  static const int pointsPerLevel = 1000;
  static const int maxBasicLevel = 10;
  static const int maxMediumLevel = 20;
  static const int maxHardLevel = 30;
  static const int coinsPerLevel = 50;
  static const int coinsForCombo3Plus = 5;
  
  // Monedas
  static const int coinsForLevelComplete = 30;
  static const int coinsForRewardedAd = 20;
  static const int minDailyWheelCoins = 25;
  static const int maxDailyWheelCoins = 150;
  static const int streak7DaysCoins = 200;
  
  // Streak diario
  static const List<int> streakCoins = [25, 30, 40, 50, 75, 100, 200];
  
  // Power-ups precios
  static const int bombPrice = 80;
  static const int shufflePrice = 40;
  static const int undoPrice = 60;
  static const int wildcardPrice = 120;
  
  // Tiempos y animaciones
  static const int splashDuration = 2500; // 2.5 segundos
  static const int comboDisplayDuration = 2000; // 2 segundos
  static const int particleDuration = 1500; // 1.5 segundos
  static const int shakeAnimationDuration = 500; // 0.5 segundos
  
  // Frecuencia de anuncios
  static const int gamesBetweenInterstitials = 3;
  
  // Misiones
  static const int dailyMissionCount = 3;
  static const int hoursBetweenMissionReset = 24;
  
  // Colores de bloques
  static const List<String> blockColors = [
    '#FF4757', // Rojo
    '#2196F3', // Azul
    '#4CAF50', // Verde
    '#FFD700', // Amarillo
    '#9C27B0', // Morado
    '#FF9800', // Naranja
    '#00BCD4', // Cyan
  ];
  
  // Nombres de power-ups
  static const String bombPowerUp = '💣 Bomba';
  static const String shufflePowerUp = '🔀 Shuffle';
  static const String undoPowerUp = '↩️ Deshacer';
  static const String wildcardPowerUp = '✨ Comodín';
  
  // Nombres de archivos de audio
  static const String placePieceSound = 'place_piece.mp3';
  static const String lineClearSound = 'line_clear.mp3';
  static const String comboSound = 'combo.mp3';
  static const String gameOverSound = 'game_over.mp3';
  static const String levelUpSound = 'level_up.mp3';
  static const String coinCollectSound = 'coin_collect.mp3';
  static const String buttonTapSound = 'button_tap.mp3';
  
  // SharedPreferences keys
  static const String keyHighScore = 'high_score';
  static const String keyCurrentLevel = 'current_level';
  static const String keyCoins = 'coins';
  static const String keyStreak = 'streak';
  static const String keyLastPlayDate = 'last_play_date';
  static const String keyDailyWheelTimestamp = 'daily_wheel_timestamp';
  static const String keyMissionsData = 'missions_data';
  static const String keyGdprConsent = 'gdpr_consent';
  static const String keySoundEnabled = 'sound_enabled';
  static const String keyHapticEnabled = 'haptic_enabled';
  static const String keyPowerUps = 'power_ups';
  static const String keyTotalGamesPlayed = 'total_games_played';
  
  // Límites del juego
  static const int maxPiecesInHand = 3;
  static const int bombRadius = 1; // Radio 1 significa área 3x3
  
  // Constantes para modos expandidos
  static const int biomeChangeEvery = 25;  // cada 25 niveles cambia bioma
  static const int bossLevelEvery = 10;    // jefe cada 10 niveles
  static const int milestoneEvery = 25;     // hito cada 25 niveles
  static const int totalStoryChapters = 5;
  static const int levelsPerChapter = 12;   // 10 normales + 1 especial + 1 jefe
}
