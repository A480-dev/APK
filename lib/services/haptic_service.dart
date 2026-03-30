import 'package:flutter_haptic_feedback/flutter_haptic_feedback.dart';
import 'package:blockrush/services/storage_service.dart';

class HapticService {
  static bool _isInitialized = false;
  
  // Inicializar servicio háptico
  static Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      // Verificar si el dispositivo soporta feedback háptico
      final canSupport = await Haptics.canVibrate();
      if (canSupport) {
        _isInitialized = true;
        debugPrint('HapticService inicializado correctamente');
      } else {
        debugPrint('El dispositivo no soporta feedback háptico');
      }
    } catch (e) {
      debugPrint('Error inicializando HapticService: $e');
      _isInitialized = false;
    }
  }
  
  // Verificar si el servicio está habilitado
  static bool get isEnabled {
    return _isInitialized && StorageService.isHapticEnabled();
  }
  
  // ===== TIPOS DE VIBRACIÓN =====
  
  // Feedback ligero (para toques de botones)
  static Future<void> light() async {
    if (!isEnabled) return;
    
    try {
      await Haptics.vibrate(HapticsType.light);
    } catch (e) {
      debugPrint('Error en vibración ligera: $e');
    }
  }
  
  // Feedback medio (para colocar piezas)
  static Future<void> medium() async {
    if (!isEnabled) return;
    
    try {
      await Haptics.vibrate(HapticsType.medium);
    } catch (e) {
      debugPrint('Error en vibración media: $e');
    }
  }
  
  // Feedback fuerte (para combos grandes)
  static Future<void> heavy() async {
    if (!isEnabled) return;
    
    try {
      await Haptics.vibrate(HapticsType.heavy);
    } catch (e) {
      debugPrint('Error en vibración fuerte: $e');
    }
  }
  
  // Éxito (para completar niveles, misiones)
  static Future<void> success() async {
    if (!isEnabled) return;
    
    try {
      await Haptics.vibrate(HapticsType.success);
    } catch (e) {
      debugPrint('Error en vibración de éxito: $e');
    }
  }
  
  // Warning (para game over, errores)
  static Future<void> warning() async {
    if (!isEnabled) return;
    
    try {
      await Haptics.vibrate(HapticsType.warning);
    } catch (e) {
      debugPrint('Error en vibración de advertencia: $e');
    }
  }
  
  // Error (para errores críticos)
  static Future<void> error() async {
    if (!isEnabled) return;
    
    try {
      await Haptics.vibrate(HapticsType.error);
    } catch (e) {
      debugPrint('Error en vibración de error: $e');
    }
  }
  
  // Selección (para navegación en menús)
  static Future<void> selection() async {
    if (!isEnabled) return;
    
    try {
      await Haptics.vibrate(HapticsType.selection);
    } catch (e) {
      debugPrint('Error en vibración de selección: $e');
    }
  }
  
  // Impacto (para eventos de impacto)
  static Future<void> impact() async {
    if (!isEnabled) return;
    
    try {
      await Haptics.vibrate(HapticsType.impact);
    } catch (e) {
      debugPrint('Error en vibración de impacto: $e');
    }
  }
  
  // ===== VIBRACIONES ESPECÍFICAS DEL JUEGO =====
  
  // Colocar pieza
  static Future<void> piecePlaced() async {
    await light();
  }
  
  // Limpiar línea
  static Future<void> lineCleared() async {
    await medium();
  }
  
  // Combo
  static Future<void> comboAchieved() async {
    await heavy();
  }
  
  // Game Over
  static Future<void> gameOver() async {
    await error();
  }
  
  // Subir de nivel
  static Future<void> levelUp() async {
    await success();
  }
  
  // Recoger monedas
  static Future<void> coinCollected() async {
    await selection();
  }
  
  // Botón presionado
  static Future<void> buttonPressed() async {
    await light();
  }
  
  // Power-up activado
  static Future<void> powerUpActivated() async {
    await impact();
  }
  
  // Misión completada
  static Future<void> missionCompleted() async {
    await success();
  }
  
  // ===== VIBRACIONES PERSONALIZADAS =====
  
  // Patrón de vibración para eventos especiales
  static Future<void> customPattern(List<int> pattern) async {
    if (!isEnabled) return;
    
    try {
      for (int i = 0; i < pattern.length; i++) {
        if (i > 0) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        
        final intensity = pattern[i];
        if (intensity <= 1) {
          await light();
        } else if (intensity == 2) {
          await medium();
        } else {
          await heavy();
        }
      }
    } catch (e) {
      debugPrint('Error en patrón de vibración: $e');
    }
  }
  
  // Vibración continua (para mantener presionado)
  static Future<void> continuousVibration(Duration duration) async {
    if (!isEnabled) return;
    
    try {
      final endTime = DateTime.now().add(duration);
      while (DateTime.now().isBefore(endTime)) {
        await light();
        await Future.delayed(const Duration(milliseconds: 200));
      }
    } catch (e) {
      debugPrint('Error en vibración continua: $e');
    }
  }
  
  // ===== CONTROL =====
  
  // Alternar estado háptico
  static Future<void> toggleHaptic() async {
    final currentEnabled = StorageService.isHapticEnabled();
    await StorageService.setHapticEnabled(!currentEnabled);
  }
  
  // Probar feedback háptico
  static Future<void> testHaptic() async {
    if (!isEnabled) {
      await light();
      await Future.delayed(const Duration(milliseconds: 200));
      await medium();
      await Future.delayed(const Duration(milliseconds: 200));
      await heavy();
      await Future.delayed(const Duration(milliseconds: 200));
      await success();
    }
  }
  
  // ===== UTILIDADES =====
  
  // Verificar si el dispositivo puede vibrar
  static Future<bool> canVibrate() async {
    try {
      return await Haptics.canVibrate();
    } catch (e) {
      return false;
    }
  }
  
  // Obtener tipos de vibración disponibles
  static List<HapticsType> getAvailableTypes() {
    return HapticsType.values;
  }
  
  // Vibración por tipo específico
  static Future<void> vibrateByType(HapticsType type) async {
    if (!isEnabled) return;
    
    try {
      await Haptics.vibrate(type);
    } catch (e) {
      debugPrint('Error en vibración tipo $type: $e');
    }
  }
  
  // Patrón para victoria
  static Future<void> victoryPattern() async {
    await customPattern([1, 2, 3]);
  }
  
  // Patrón para derrota
  static Future<void> defeatPattern() async {
    await customPattern([3, 2, 1]);
  }
  
  // Patrón para recompensa
  static Future<void> rewardPattern() async {
    await customPattern([2, 2, 3]);
  }
}
