import 'package:audioplayers/audioplayers.dart';
import 'package:blockrush/config/constants.dart';
import 'package:blockrush/services/storage_service.dart';

class AudioService {
  static final AudioPlayer _backgroundPlayer = AudioPlayer();
  static final AudioPlayer _sfxPlayer = AudioPlayer();
  static bool _isInitialized = false;
  
  // Inicializar servicio de audio
  static Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      // Configurar players
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
      await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
      
      _isInitialized = true;
    } catch (e) {
      print('Error inicializando AudioService: $e');
      _isInitialized = false;
    }
  }
  
  // Reproducir sonido de efecto
  static Future<void> playSfx(String soundFile) async {
    if (!_isInitialized || !StorageService.isSoundEnabled()) return;
    
    try {
      await _sfxPlayer.play(AssetSource('audio/$soundFile'));
    } catch (e) {
      // Silenciar errores de audio para no interrumpir el juego
      print('Error reproduciendo sonido $soundFile: $e');
    }
  }
  
  // Reproducir música de fondo
  static Future<void> playBackgroundMusic() async {
    if (!_isInitialized || !StorageService.isSoundEnabled()) return;
    
    try {
      await _backgroundPlayer.play(AssetSource('audio/background_music.mp3'));
      await _backgroundPlayer.setVolume(0.3); // Volumen bajo para música de fondo
    } catch (e) {
      print('Error reproduciendo música de fondo: $e');
    }
  }
  
  // Pausar música de fondo
  static Future<void> pauseBackgroundMusic() async {
    if (!_isInitialized) return;
    
    try {
      await _backgroundPlayer.pause();
    } catch (e) {
      print('Error pausando música de fondo: $e');
    }
  }
  
  // Reanudar música de fondo
  static Future<void> resumeBackgroundMusic() async {
    if (!_isInitialized || !StorageService.isSoundEnabled()) return;
    
    try {
      await _backgroundPlayer.resume();
    } catch (e) {
      print('Error reanudando música de fondo: $e');
    }
  }
  
  // Detener música de fondo
  static Future<void> stopBackgroundMusic() async {
    if (!_isInitialized) return;
    
    try {
      await _backgroundPlayer.stop();
    } catch (e) {
      print('Error deteniendo música de fondo: $e');
    }
  }
  
  // ===== SONIDOS ESPECÍFICOS DEL JUEGO =====
  
  // Colocar pieza
  static Future<void> playPlacePiece() async {
    await playSfx(GameConstants.placePieceSound);
  }
  
  // Limpiar línea
  static Future<void> playLineClear() async {
    await playSfx(GameConstants.lineClearSound);
  }
  
  // Combo
  static Future<void> playCombo() async {
    await playSfx(GameConstants.comboSound);
  }
  
  // Game over
  static Future<void> playGameOver() async {
    await playSfx(GameConstants.gameOverSound);
  }
  
  // Subir de nivel
  static Future<void> playLevelUp() async {
    await playSfx(GameConstants.levelUpSound);
  }
  
  // Recoger monedas
  static Future<void> playCoinCollect() async {
    await playSfx(GameConstants.coinCollectSound);
  }
  
  // Tocar botón
  static Future<void> playButtonTap() async {
    await playSfx(GameConstants.buttonTapSound);
  }
  
  // ===== CONTROL DE VOLUMEN =====
  
  // Establecer volumen de efectos
  static Future<void> setSfxVolume(double volume) async {
    if (!_isInitialized) return;
    
    try {
      await _sfxPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      print('Error estableciendo volumen SFX: $e');
    }
  }
  
  // Establecer volumen de música de fondo
  static Future<void> setBackgroundVolume(double volume) async {
    if (!_isInitialized) return;
    
    try {
      await _backgroundPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      print('Error estableciendo volumen de fondo: $e');
    }
  }
  
  // ===== UTILIDADES =====
  
  // Verificar si el audio está habilitado
  static bool isAudioEnabled() {
    return StorageService.isSoundEnabled();
  }
  
  // Alternar estado del audio
  static Future<void> toggleAudio() async {
    final currentEnabled = StorageService.isSoundEnabled();
    await StorageService.setSoundEnabled(!currentEnabled);
    
    if (!currentEnabled) {
      await resumeBackgroundMusic();
    } else {
      await pauseBackgroundMusic();
    }
  }
  
  // Liberar recursos
  static Future<void> dispose() async {
    if (!_isInitialized) return;
    
    try {
      await _backgroundPlayer.dispose();
      await _sfxPlayer.dispose();
      _isInitialized = false;
    } catch (e) {
      print('Error liberando recursos de audio: $e');
    }
  }
  
  // Reproducir sonido de vibración (como alternativa si no hay archivo)
  static Future<void> playVibrationSound() async {
    if (!_isInitialized) return;
    
    try {
      // Generar un sonido de vibración simple
      await _sfxPlayer.play(AssetSource('audio/vibration.mp3'));
    } catch (e) {
      // Si no hay archivo, simplemente ignorar
    }
  }
}
