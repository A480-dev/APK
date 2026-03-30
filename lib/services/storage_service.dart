import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blockrush/models/player_data.dart';
import 'package:blockrush/models/mission.dart';
import 'package:blockrush/config/constants.dart';

class StorageService {
  static SharedPreferences? _prefs;
  
  // Inicializar SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // Verificar si está inicializado
  static bool get isInitialized => _prefs != null;
  
  // Asegurar que esté inicializado
  static void _ensureInitialized() {
    if (_prefs == null) {
      throw Exception('StorageService no inicializado. Llamar a init() primero.');
    }
  }
  
  // ===== PLAYER DATA =====
  
  // Guardar datos del jugador
  static Future<void> savePlayerData(PlayerData playerData) async {
    _ensureInitialized();
    await _prefs!.setString('player_data', jsonEncode(playerData.toJson()));
  }
  
  // Cargar datos del jugador
  static PlayerData loadPlayerData() {
    _ensureInitialized();
    final jsonString = _prefs!.getString('player_data');
    if (jsonString == null) {
      return const PlayerData(); // Datos por defecto
    }
    
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return PlayerData.fromJson(json);
    } catch (e) {
      return const PlayerData(); // Si falla, retornar datos por defecto
    }
  }
  
  // Guardar high score
  static Future<void> setHighScore(int score) async {
    _ensureInitialized();
    await _prefs!.setInt(GameConstants.keyHighScore, score);
  }
  
  // Obtener high score
  static int getHighScore() {
    _ensureInitialized();
    return _prefs!.getInt(GameConstants.keyHighScore) ?? 0;
  }
  
  // Guardar nivel actual
  static Future<void> setCurrentLevel(int level) async {
    _ensureInitialized();
    await _prefs!.setInt(GameConstants.keyCurrentLevel, level);
  }
  
  // Obtener nivel actual
  static int getCurrentLevel() {
    _ensureInitialized();
    return _prefs!.getInt(GameConstants.keyCurrentLevel) ?? 1;
  }
  
  // Guardar monedas
  static Future<void> setCoins(int coins) async {
    _ensureInitialized();
    await _prefs!.setInt(GameConstants.keyCoins, coins);
  }
  
  // Obtener monedas
  static int getCoins() {
    _ensureInitialized();
    return _prefs!.getInt(GameConstants.keyCoins) ?? 0;
  }
  
  // Guardar streak
  static Future<void> setStreak(int streak) async {
    _ensureInitialized();
    await _prefs!.setInt(GameConstants.keyStreak, streak);
  }
  
  // Obtener streak
  static int getStreak() {
    _ensureInitialized();
    return _prefs!.getInt(GameConstants.keyStreak) ?? 0;
  }
  
  // Guardar última fecha de juego
  static Future<void> setLastPlayDate(DateTime date) async {
    _ensureInitialized();
    await _prefs!.setString(GameConstants.keyLastPlayDate, date.toIso8601String());
  }
  
  // Obtener última fecha de juego
  static DateTime? getLastPlayDate() {
    _ensureInitialized();
    final dateString = _prefs!.getString(GameConstants.keyLastPlayDate);
    return dateString != null ? DateTime.parse(dateString) : null;
  }
  
  // Guardar timestamp de ruleta diaria
  static Future<void> setDailyWheelTimestamp(DateTime timestamp) async {
    _ensureInitialized();
    await _prefs!.setString(GameConstants.keyDailyWheelTimestamp, timestamp.toIso8601String());
  }
  
  // Obtener timestamp de ruleta diaria
  static DateTime? getDailyWheelTimestamp() {
    _ensureInitialized();
    final dateString = _prefs!.getString(GameConstants.keyDailyWheelTimestamp);
    return dateString != null ? DateTime.parse(dateString) : null;
  }
  
  // Guardar power-ups
  static Future<void> setPowerUps(Map<String, int> powerUps) async {
    _ensureInitialized();
    await _prefs!.setString(GameConstants.keyPowerUps, jsonEncode(powerUps));
  }
  
  // Obtener power-ups
  static Map<String, int> getPowerUps() {
    _ensureInitialized();
    final jsonString = _prefs!.getString(GameConstants.keyPowerUps);
    if (jsonString == null) return {};
    
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return json.map((key, value) => MapEntry(key, value as int));
    } catch (e) {
      return {};
    }
  }
  
  // Guardar total de partidas jugadas
  static Future<void> setTotalGamesPlayed(int total) async {
    _ensureInitialized();
    await _prefs!.setInt(GameConstants.keyTotalGamesPlayed, total);
  }
  
  // Obtener total de partidas jugadas
  static int getTotalGamesPlayed() {
    _ensureInitialized();
    return _prefs!.getInt(GameConstants.keyTotalGamesPlayed) ?? 0;
  }
  
  // ===== CONFIGURACIÓN =====
  
  // Guardar consentimiento GDPR
  static Future<void> setGdprConsent(bool consent) async {
    _ensureInitialized();
    await _prefs!.setBool(GameConstants.keyGdprConsent, consent);
  }
  
  // Obtener consentimiento GDPR
  static bool getGdprConsent() {
    _ensureInitialized();
    return _prefs!.getBool(GameConstants.keyGdprConsent) ?? false;
  }
  
  // Guardar configuración de sonido
  static Future<void> setSoundEnabled(bool enabled) async {
    _ensureInitialized();
    await _prefs!.setBool(GameConstants.keySoundEnabled, enabled);
  }
  
  // Obtener configuración de sonido
  static bool isSoundEnabled() {
    _ensureInitialized();
    return _prefs!.getBool(GameConstants.keySoundEnabled) ?? true;
  }
  
  // Guardar configuración háptica
  static Future<void> setHapticEnabled(bool enabled) async {
    _ensureInitialized();
    await _prefs!.setBool(GameConstants.keyHapticEnabled, enabled);
  }
  
  // Obtener configuración háptica
  static bool isHapticEnabled() {
    _ensureInitialized();
    return _prefs!.getBool(GameConstants.keyHapticEnabled) ?? true;
  }
  
  // ===== MISIONES =====
  
  // Guardar misiones
  static Future<void> setMissions(List<Mission> missions) async {
    _ensureInitialized();
    final missionsJson = missions.map((m) => m.toJson()).toList();
    await _prefs!.setString(GameConstants.keyMissionsData, jsonEncode(missionsJson));
  }
  
  // Obtener misiones
  static List<Mission> getMissions() {
    _ensureInitialized();
    final jsonString = _prefs!.getString(GameConstants.keyMissionsData);
    if (jsonString == null) return [];
    
    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => Mission.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }
  
  // Limpiar todos los datos (para resetear el juego)
  static Future<void> clearAllData() async {
    _ensureInitialized();
    await _prefs!.clear();
  }
  
  // Verificar si es primer arranque
  static bool isFirstLaunch() {
    _ensureInitialized();
    return !_prefs!.containsKey('player_data');
  }
  
  // Guardar dato genérico
  static Future<void> setString(String key, String value) async {
    _ensureInitialized();
    await _prefs!.setString(key, value);
  }
  
  static Future<void> setInt(String key, int value) async {
    _ensureInitialized();
    await _prefs!.setInt(key, value);
  }
  
  static Future<void> setBool(String key, bool value) async {
    _ensureInitialized();
    await _prefs!.setBool(key, value);
  }
  
  // Obtener dato genérico
  static String? getString(String key) {
    _ensureInitialized();
    return _prefs!.getString(key);
  }
  
  static int getInt(String key, {int defaultValue = 0}) {
    _ensureInitialized();
    return _prefs!.getInt(key) ?? defaultValue;
  }
  
  static bool getBool(String key, {bool defaultValue = false}) {
    _ensureInitialized();
    return _prefs!.getBool(key) ?? defaultValue;
  }
  
  // Eliminar dato específico
  static Future<void> remove(String key) async {
    _ensureInitialized();
    await _prefs!.remove(key);
  }
  
  // ===== MODO INFINITO =====
  
  // Guardar el nivel más alto alcanzado en modo infinito
  static Future<void> setEndlessHighLevel(int level) async {
    _ensureInitialized();
    await _prefs!.setInt('endless_high_level', level);
  }
  
  // Obtener el nivel más alto alcanzado en modo infinito
  static int getEndlessHighLevel() {
    _ensureInitialized();
    return _prefs!.getInt('endless_high_level') ?? 1;
  }
  
  // ===== MODO HISTORIA =====
  
  // Guardar progreso de la historia
  static Future<void> setStoryProgress(Map<String, dynamic> progress) async {
    _ensureInitialized();
    await _prefs!.setString('story_progress', jsonEncode(progress));
  }
  
  // Obtener progreso de la historia
  static Map<String, dynamic>? getStoryProgress() {
    _ensureInitialized();
    final jsonString = _prefs!.getString('story_progress');
    if (jsonString == null) return null;
    
    try {
      return Map<String, dynamic>.from(jsonDecode(jsonString));
    } catch (e) {
      return null;
    }
  }
  
  // Guardar hitos desbloqueados
  static Future<void> setUnlockedMilestones(List<String> milestones) async {
    _ensureInitialized();
    await _prefs!.setStringList('unlocked_milestones', milestones);
  }
  
  // Obtener hitos desbloqueados
  static List<String> getUnlockedMilestones() {
    _ensureInitialized();
    return _prefs!.getStringList('unlocked_milestones') ?? [];
  }
}
