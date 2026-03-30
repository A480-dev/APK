import 'package:blockrush/models/story_character.dart';

class DialogueLine {
  final StoryCharacter character;
  final String text;
  final CharacterEmotion emotion;
  final Duration? delay;
  final bool isImportant;
  final String? soundEffect;
  
  const DialogueLine({
    required this.character,
    required this.text,
    required this.emotion,
    this.delay,
    this.isImportant = false,
    this.soundEffect,
  });
  
  // Constructor para líneas del narrador (centradas, sin avatar)
  DialogueLine.narrator({
    required String text,
    this.delay,
    this.isImportant = false,
  }) : character = StoryCharacter.narrator,
       text = text,
       emotion = CharacterEmotion.narrative,
       soundEffect = null;
  
  // Constructor para líneas importantes (con efecto especial)
  DialogueLine.important({
    required StoryCharacter character,
    required String text,
    required CharacterEmotion emotion,
    this.soundEffect,
  }) : character = character,
       text = text,
       emotion = emotion,
       delay = null,
       isImportant = true;
  
  // Obtener el texto con formato para mostrar
  String get displayText {
    return text.trim();
  }
  
  // Obtener la duración estimada para el typewriter effect
  Duration get estimatedDuration {
    // Aproximadamente 40ms por caracter + 500ms base
    final baseDuration = const Duration(milliseconds: 500);
    final charDuration = Duration(milliseconds: text.length * 40);
    return baseDuration + charDuration;
  }
  
  // Verificar si es una línea corta (para ajustar velocidad de typewriter)
  bool get isShort => text.length <= 20;
  
  // Verificar si es una línea larga (para ajustar velocidad de typewriter)
  bool get isLong => text.length >= 60;
  
  // Obtener velocidad de typewriter ajustada
  int get typewriterSpeed {
    if (isShort) return 30; // Más rápido para líneas cortas
    if (isLong) return 50; // Más lento para líneas largas
    return 40; // Velocidad normal
  }
  
  // Verificar si debe tener pausa después
  bool get shouldPause {
    return isImportant || 
           emotion == CharacterEmotion.dramatic ||
           emotion == CharacterEmotion.revealing ||
           text.endsWith('?') ||
           text.endsWith('!');
  }
  
  // Copiar con modificaciones
  DialogueLine copyWith({
    StoryCharacter? character,
    String? text,
    CharacterEmotion? emotion,
    Duration? delay,
    bool? isImportant,
    String? soundEffect,
  }) {
    return DialogueLine(
      character: character ?? this.character,
      text: text ?? this.text,
      emotion: emotion ?? this.emotion,
      delay: delay ?? this.delay,
      isImportant: isImportant ?? this.isImportant,
      soundEffect: soundEffect ?? this.soundEffect,
    );
  }
  
  // Convertir a JSON para guardado
  Map<String, dynamic> toJson() {
    return {
      'character': character.name,
      'text': text,
      'emotion': emotion.name,
      'delay': delay?.inMilliseconds,
      'isImportant': isImportant,
      'soundEffect': soundEffect,
    };
  }
  
  // Crear desde JSON
  factory DialogueLine.fromJson(Map<String, dynamic> json) {
    return DialogueLine(
      character: StoryCharacter.values.firstWhere(
        (e) => e.name == json['character'],
        orElse: () => StoryCharacter.narrator,
      ),
      text: json['text'] ?? '',
      emotion: CharacterEmotion.values.firstWhere(
        (e) => e.name == json['emotion'],
        orElse: () => CharacterEmotion.calm,
      ),
      delay: json['delay'] != null 
          ? Duration(milliseconds: json['delay'])
          : null,
      isImportant: json['isImportant'] ?? false,
      soundEffect: json['soundEffect'],
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DialogueLine &&
        other.character == character &&
        other.text == text &&
        other.emotion == emotion;
  }
  
  @override
  int get hashCode => character.hashCode ^ text.hashCode ^ emotion.hashCode;
  
  @override
  String toString() {
    return 'DialogueLine(${character.name}: "$text" [${emotion.name}])';
  }
}

// Clase para manejar secuencias de diálogos
class DialogueSequence {
  final List<DialogueLine> lines;
  final String title;
  final bool canSkip;
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;
  
  const DialogueSequence({
    required this.lines,
    this.title = '',
    this.canSkip = true,
    this.onComplete,
    this.onSkip,
  });
  
  // Obtener duración total estimada
  Duration get totalEstimatedDuration {
    Duration total = Duration.zero;
    for (final line in lines) {
      total += line.estimatedDuration;
      if (line.delay != null) {
        total += line.delay!;
      }
    }
    return total;
  }
  
  // Verificar si es una secuencia larga
  bool get isLong => totalEstimatedDuration.inSeconds > 30;
  
  // Verificar si hay líneas importantes
  bool get hasImportantLines => lines.any((line) => line.isImportant);
  
  // Obtener líneas por personaje
  List<DialogueLine> getLinesByCharacter(StoryCharacter character) {
    return lines.where((line) => line.character == character).toList();
  }
  
  // Obtener líneas por emoción
  List<DialogueLine> getLinesByEmotion(CharacterEmotion emotion) {
    return lines.where((line) => line.emotion == emotion).toList();
  }
  
  // Crear una subsecuencia (para ramificaciones)
  DialogueSequence subsequence(int start, int end) {
    return DialogueSequence(
      lines: lines.sublist(start, end),
      title: title,
      canSkip: canSkip,
      onComplete: onComplete,
      onSkip: onSkip,
    );
  }
  
  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'canSkip': canSkip,
      'lines': lines.map((line) => line.toJson()).toList(),
    };
  }
  
  // Crear desde JSON
  factory DialogueSequence.fromJson(Map<String, dynamic> json) {
    return DialogueSequence(
      title: json['title'] ?? '',
      canSkip: json['canSkip'] ?? true,
      lines: (json['lines'] as List<dynamic>?)
          ?.map((line) => DialogueLine.fromJson(line as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

// Clase para manejar opciones de diálogo (si se añaden en el futuro)
class DialogueOption {
  final String text;
  final DialogueSequence? consequence;
  final VoidCallback? onSelect;
  final bool isEnabled;
  
  const DialogueOption({
    required this.text,
    this.consequence,
    this.onSelect,
    this.isEnabled = true,
  });
  
  // Seleccionar esta opción
  void select() {
    if (isEnabled) {
      onSelect?.call();
    }
  }
}

// Clase para estadísticas de diálogo (para analíticas)
class DialogueStats {
  final String sequenceId;
  final DateTime startTime;
  final DateTime? endTime;
  final bool wasSkipped;
  final int linesRead;
  final int totalLines;
  final Duration? readingTime;
  
  const DialogueStats({
    required this.sequenceId,
    required this.startTime,
    this.endTime,
    this.wasSkipped = false,
    this.linesRead = 0,
    this.totalLines = 0,
    this.readingTime,
  });
  
  // Completar las estadísticas
  DialogueStats complete({
    required int linesRead,
    required int totalLines,
    required bool wasSkipped,
  }) {
    final now = DateTime.now();
    return DialogueStats(
      sequenceId: sequenceId,
      startTime: startTime,
      endTime: now,
      wasSkipped: wasSkipped,
      linesRead: linesRead,
      totalLines: totalLines,
      readingTime: now.difference(startTime),
    );
  }
  
  // Obtener porcentaje de completion
  double get completionPercentage {
    if (totalLines == 0) return 0.0;
    return linesRead / totalLines;
  }
  
  // Obtener velocidad de lectura (líneas por minuto)
  double get readingSpeed {
    if (readingTime == null || readingTime!.inMinutes == 0) return 0.0;
    return linesRead / readingTime!.inMinutes;
  }
  
  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'sequenceId': sequenceId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'wasSkipped': wasSkipped,
      'linesRead': linesRead,
      'totalLines': totalLines,
      'readingTimeMs': readingTime?.inMilliseconds,
    };
  }
}
