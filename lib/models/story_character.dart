import 'package:flutter/material.dart';

enum StoryCharacter {
  lumen,
  architect,
  kira,
  entropy,
  narrator,
  florax,
  petra,
  ignix,
  mareen,
}

extension StoryCharacterExtension on StoryCharacter {
  String get name {
    switch (this) {
      case StoryCharacter.lumen:
        return 'LUMEN';
      case StoryCharacter.architect:
        return 'ARQUITECTO';
      case StoryCharacter.kira:
        return 'KIRA';
      case StoryCharacter.entropy:
        return 'ENTROPÍA';
      case StoryCharacter.narrator:
        return 'NARRADOR';
      case StoryCharacter.florax:
        return 'FLORAX';
      case StoryCharacter.petra:
        return 'PETRA';
      case StoryCharacter.ignix:
        return 'IGNIX';
      case StoryCharacter.mareen:
        return 'MAREEN';
    }
  }
  
  String get displayName {
    switch (this) {
      case StoryCharacter.lumen:
        return 'Lumen';
      case StoryCharacter.architect:
        return 'El Arquitecto';
      case StoryCharacter.kira:
        return 'Kira';
      case StoryCharacter.entropy:
        return 'La Entropía';
      case StoryCharacter.narrator:
        return '';
      case StoryCharacter.florax:
        return 'Florax';
      case StoryCharacter.petra:
        return 'Petra';
      case StoryCharacter.ignix:
        return 'Ignix';
      case StoryCharacter.mareen:
        return 'Mareen';
    }
  }
  
  Color get primaryColor {
    switch (this) {
      case StoryCharacter.lumen:
        return Colors.white;
      case StoryCharacter.architect:
        return const Color(0xFFFFD700); // Dorado
      case StoryCharacter.kira:
        return const Color(0xFF9C27B0); // Morado multicolor
      case StoryCharacter.entropy:
        return const Color(0xFF424242); // Gris oscuro
      case StoryCharacter.narrator:
        return const Color(0xFF757575); // Gris medio
      case StoryCharacter.florax:
        return const Color(0xFF4CAF50); // Verde
      case StoryCharacter.petra:
        return const Color(0xFF2196F3); // Azul cristal
      case StoryCharacter.ignix:
        return const Color(0xFFFF5722); // Rojo fuego
      case StoryCharacter.mareen:
        return const Color(0xFF00BCD4); // Cian agua
    }
  }
  
  Color get secondaryColor {
    switch (this) {
      case StoryCharacter.lumen:
        return const Color(0xFFE3F2FD); // Azul muy claro
      case StoryCharacter.architect:
        return const Color(0xFFFFA000); // Ámbar
      case StoryCharacter.kira:
        return const Color(0xFFE91E63); // Rosa
      case StoryCharacter.entropy:
        return const Color(0xFF000000); // Negro
      case StoryCharacter.narrator:
        return const Color(0xFF9E9E9E); // Gris claro
      case StoryCharacter.florax:
        return const Color(0xFF8BC34A); // Verde lima
      case StoryCharacter.petra:
        return const Color(0xFF03A9F4); // Azul claro
      case StoryCharacter.ignix:
        return const Color(0xFFFF9800); // Naranja
      case StoryCharacter.mareen:
        return const Color(0xFF009688); // Verde azulado
    }
  }
  
  String get avatarShape {
    switch (this) {
      case StoryCharacter.lumen:
        return 'circle'; // Círculo pequeño blanco brillante
      case StoryCharacter.architect:
        return 'hexagon'; // Hexágono dorado con líneas
      case StoryCharacter.kira:
        return 'square'; // Cuadrado multicolor
      case StoryCharacter.entropy:
        return 'irregular'; // Forma irregular oscura
      case StoryCharacter.narrator:
        return 'none'; // Sin avatar
      case StoryCharacter.florax:
        return 'pentagon'; // Pentágono verde
      case StoryCharacter.petra:
        return 'diamond'; // Diamante azul
      case StoryCharacter.ignix:
        return 'triangle'; // Triángulo rojo
      case StoryCharacter.mareen:
        return 'oval'; // Óvalo azul
    }
  }
  
  bool get hasAvatar {
    return this != StoryCharacter.narrator;
  }
  
  bool get isAlly {
    return [
      StoryCharacter.lumen,
      StoryCharacter.architect,
      StoryCharacter.kira,
      StoryCharacter.florax,
      StoryCharacter.petra,
      StoryCharacter.ignix,
      StoryCharacter.mareen,
    ].contains(this);
  }
  
  bool get isAntagonist {
    return this == StoryCharacter.entropy;
  }
  
  bool get isNeutral {
    return this == StoryCharacter.narrator;
  }
  
  // Posición del avatar en el diálogo
  AvatarPosition get avatarPosition {
    switch (this) {
      case StoryCharacter.lumen:
      case StoryCharacter.architect:
      case StoryCharacter.kira:
      case StoryCharacter.florax:
      case StoryCharacter.petra:
      case StoryCharacter.ignix:
      case StoryCharacter.mareen:
        return AvatarPosition.left;
      case StoryCharacter.entropy:
        return AvatarPosition.right;
      case StoryCharacter.narrator:
        return AvatarPosition.center;
    }
  }
  
  // Descripción para tooltips o ayuda
  String get description {
    switch (this) {
      case StoryCharacter.lumen:
        return 'Un pequeño bloque de luz creado por el Arquitecto. El protagonista de nuestra historia.';
      case StoryCharacter.architect:
        return 'El ser que construyó el universo. Ahora fragmentado, guía a Lumen en su misión.';
      case StoryCharacter.kira:
        return 'Un bloque de color cambiante que no confía fácilmente pero se vuelve un aliado leal.';
      case StoryCharacter.entropy:
        return 'Una fuerza del vacío que cree que el desorden es la verdadera libertad.';
      case StoryCharacter.narrator:
        return 'La voz que narra los eventos y da contexto al mundo.';
      case StoryCharacter.florax:
        return 'La guardiana de los Jardines del Origen, corrompida por La Entropía.';
      case StoryCharacter.petra:
        return 'La guardiana de las Cavernas de Cristal, protectora de los minerales.';
      case StoryCharacter.ignix:
        return 'El guardián del fuego interior, protector de la voluntad del Arquitecto.';
      case StoryCharacter.mareen:
        return 'La guardiana del Océano Eterno, protectora de los recuerdos.';
    }
  }
}

enum AvatarPosition {
  left,
  right,
  center,
}

// Clase para representar un estado emocional del personaje
enum CharacterEmotion {
  calm,
  determined,
  confused,
  wise,
  urgent,
  mysterious,
  curious,
  skeptical,
  sarcastic,
  frustrated,
  resigned,
  nervous,
  serious,
  worried,
  confident,
  shocked,
  proud,
  relieved,
  grateful,
  surprised,
  happy,
  concerned,
  impressed,
  humble,
  angry,
  philosophical,
  mocking,
  intrigued,
  direct,
  logical,
  accusatory,
  excited,
  sad,
  enlightened,
  emotional,
  hopeful,
  caring,
  playful,
  disappointed,
  inspiring,
  narrative,
  corrupted,
  inviting,
  warning,
  teaching,
  encouraging,
  arrogant,
}

extension CharacterEmotionExtension on CharacterEmotion {
  String get displayName {
    switch (this) {
      case CharacterEmotion.calm:
        return 'Calma';
      case CharacterEmotion.determined:
        return 'Determinado';
      case CharacterEmotion.confused:
        return 'Confundido';
      case CharacterEmotion.wise:
        return 'Sabio';
      case CharacterEmotion.urgent:
        return 'Urgente';
      case CharacterEmotion.mysterious:
        return 'Misterioso';
      case CharacterEmotion.curious:
        return 'Curioso';
      case CharacterEmotion.skeptical:
        return 'Escéptico';
      case CharacterEmotion.sarcastic:
        return 'Sarcástico';
      case CharacterEmotion.frustrated:
        return 'Frustrado';
      case CharacterEmotion.resigned:
        return 'Resignado';
      case CharacterEmotion.nervous:
        return 'Nervioso';
      case CharacterEmotion.serious:
        return 'Serio';
      case CharacterEmotion.worried:
        return 'Preocupado';
      case CharacterEmotion.confident:
        return 'Confiado';
      case CharacterEmotion.shocked:
        return 'Sorprendido';
      case CharacterEmotion.proud:
        return 'Orgulloso';
      case CharacterEmotion.relieved:
        return 'Aliviado';
      case CharacterEmotion.grateful:
        return 'Agradecido';
      case CharacterEmotion.surprised:
        return 'Sorprendido';
      case CharacterEmotion.happy:
        return 'Feliz';
      case CharacterEmotion.concerned:
        return 'Preocupado';
      case CharacterEmotion.impressed:
        return 'Impresionado';
      case CharacterEmotion.humble:
        return 'Humilde';
      case CharacterEmotion.angry:
        return 'Enojado';
      case CharacterEmotion.philosophical:
        return 'Filosófico';
      case CharacterEmotion.mocking:
        return 'Burlón';
      case CharacterEmotion.intrigued:
        return 'Intrigado';
      case CharacterEmotion.direct:
        return 'Directo';
      case CharacterEmotion.logical:
        return 'Lógico';
      case CharacterEmotion.accusatory:
        return 'Acusador';
      case CharacterEmotion.enlightened:
        return 'Iluminado';
      case CharacterEmotion.emotional:
        return 'Emocional';
      case CharacterEmotion.hopeful:
        return 'Esperanzado';
      case CharacterEmotion.caring:
        return 'Cariñoso';
      case CharacterEmotion.playful:
        return 'Juguetón';
      case CharacterEmotion.disappointed:
        return 'Decepcionado';
      case CharacterEmotion.inspiring:
        return 'Inspirador';
      case CharacterEmotion.narrative:
        return 'Narrativo';
      case CharacterEmotion.corrupted:
        return 'Corrompido';
      case CharacterEmotion.inviting:
        return 'Invitador';
      case CharacterEmotion.warning:
        return 'Advertencia';
      case CharacterEmotion.teaching:
        return 'Enseñando';
      case CharacterEmotion.encouraging:
        return 'Animador';
      case CharacterEmotion.arrogant:
        return 'Arrogante';
    }
  }
  
  // Modificar el color según la emoción
  Color getModifiedColor(Color baseColor) {
    switch (this) {
      case CharacterEmotion.angry:
      case CharacterEmotion.frustrated:
        return baseColor.withOpacity(0.8);
      case CharacterEmotion.happy:
      case CharacterEmotion.excited:
        return baseColor;
      case CharacterEmotion.sad:
      case CharacterEmotion.worried:
        return baseColor.withOpacity(0.6);
      case CharacterEmotion.corrupted:
        return Colors.red.withOpacity(0.8);
      default:
        return baseColor;
    }
  }
}
