import 'package:blockrush/models/story_character.dart';
import 'package:blockrush/models/dialogue_line.dart';

class StoryData {
  // Datos hardcoded de toda la historia del juego
  static const List<ChapterData> chapters = [
    ChapterData(
      id: 1,
      title: "Los Jardines del Origen",
      world: "Un jardín celestial que se está desintegrando",
      guardian: "FLORAX",
      biome: "garden",
      introDialogues: [
        DialogueLine(
          character: StoryCharacter.architect,
          text: "Lumen... ¿puedes oírme? El tiempo se acaba.",
          emotion: CharacterEmotion.urgent,
        ),
        DialogueLine(
          character: StoryCharacter.lumen,
          text: "¿Quién eres? ¿Dónde estoy?",
          emotion: CharacterEmotion.confused,
        ),
        DialogueLine(
          character: StoryCharacter.architect,
          text: "Soy el que te creó. Y ahora necesito que salves lo que yo no pude.",
          emotion: CharacterEmotion.wise,
        ),
        DialogueLine(
          character: StoryCharacter.architect,
          text: "Los Jardines del Origen están cayendo. Los bloques de vida se desordenan. Ve. Restaura. Es todo lo que debes hacer.",
          emotion: CharacterEmotion.determined,
        ),
        DialogueLine(
          character: StoryCharacter.lumen,
          text: "¿Cómo sabré que lo estoy haciendo bien?",
          emotion: CharacterEmotion.curious,
        ),
        DialogueLine(
          character: StoryCharacter.architect,
          text: "Cuando sientas que todo encaja... lo sabrás.",
          emotion: CharacterEmotion.mysterious,
        ),
        DialogueLine(
          character: StoryCharacter.narrator,
          text: "Lumen da sus primeros pasos en un jardín que agoniza. Flores de cristal se deshacen en fragmentos. El aire huele a bloques quemados.",
          emotion: CharacterEmotion.narrative,
        ),
      ],
      outroDialogues: [
        DialogueLine(
          character: StoryCharacter.florax,
          text: "Lumen... gracias. Yo... yo no era yo.",
          emotion: CharacterEmotion.relieved,
        ),
        DialogueLine(
          character: StoryCharacter.florax,
          text: "La Entropía... viene del Este. Del reino de cristal. Ten cuidado.",
          emotion: CharacterEmotion.warning,
        ),
        DialogueLine(
          character: StoryCharacter.architect,
          text: "Bien hecho, Lumen. Siento tu luz desde aquí. El primer fragmento mío... regresa.",
          emotion: CharacterEmotion.proud,
        ),
        DialogueLine(
          character: StoryCharacter.narrator,
          text: "Un destello dorado desciende del cielo y se une a Lumen. El Arquitecto está un paso más cerca de ser completo.",
          emotion: CharacterEmotion.narrative,
        ),
      ],
      bossPreDialogue: [
        DialogueLine(
          character: StoryCharacter.florax,
          text: "Los bloques... no deben tener orden... el caos... es la vida verdadera...",
          emotion: CharacterEmotion.corrupted,
        ),
        DialogueLine(
          character: StoryCharacter.lumen,
          text: "¡Florax! Sé que estás ahí dentro. ¡Lucha!",
          emotion: CharacterEmotion.determined,
        ),
      ],
      bossPostDialogue: [
        DialogueLine(
          character: StoryCharacter.florax,
          text: "Lumen... gracias. Yo... yo no era yo.",
          emotion: CharacterEmotion.relieved,
        ),
        DialogueLine(
          character: StoryCharacter.florax,
          text: "La Entropía... viene del Este. Del reino de cristal. Ten cuidado.",
          emotion: CharacterEmotion.warning,
        ),
        DialogueLine(
          character: StoryCharacter.architect,
          text: "Bien hecho, Lumen. Siento tu luz desde aquí. El primer fragmento mío... regresa.",
          emotion: CharacterEmotion.proud,
        ),
      ],
    ),
    
    ChapterData(
      id: 2,
      title: "Las Cavernas de Cristal",
      world: "Minas subterráneas de cristal viviente",
      guardian: "PETRA",
      biome: "caverns",
      introDialogues: [
        DialogueLine(
          character: StoryCharacter.narrator,
          text: "Las cavernas de cristal alguna vez cantaron. Ahora solo gritan.",
          emotion: CharacterEmotion.narrative,
        ),
        DialogueLine(
          character: StoryCharacter.kira,
          text: "¡Oye! ¡Bloque brillante! ¿Qué haces aquí?",
          emotion: CharacterEmotion.sarcastic,
        ),
        DialogueLine(
          character: StoryCharacter.lumen,
          text: "Vengo a restaurar el orden.",
          emotion: CharacterEmotion.calm,
        ),
        DialogueLine(
          character: StoryCharacter.kira,
          text: "¿Orden? ¿Aquí? Llevo semanas intentando salir y es imposible. Los túneles cambian solos.",
          emotion: CharacterEmotion.frustrated,
        ),
        DialogueLine(
          character: StoryCharacter.lumen,
          text: "Entonces ven conmigo.",
          emotion: CharacterEmotion.inviting,
        ),
        DialogueLine(
          character: StoryCharacter.kira,
          text: "¿Seguirte? No te conozco. Eso es una pésima idea.",
          emotion: CharacterEmotion.skeptical,
        ),
        DialogueLine(
          character: StoryCharacter.kira,
          text: "...Aunque tampoco tengo un plan mejor. Bien.",
          emotion: CharacterEmotion.resigned,
        ),
        DialogueLine(
          character: StoryCharacter.architect,
          text: "Lumen, las cavernas tienen celdas de cristal petrificado. Necesitarás más fuerza para limpiarlas.",
          emotion: CharacterEmotion.direct,
        ),
      ],
      outroDialogues: [
        DialogueLine(
          character: StoryCharacter.petra,
          text: "El cristal... recuerda su forma. Gracias, Lumen.",
          emotion: CharacterEmotion.grateful,
        ),
        DialogueLine(
          character: StoryCharacter.kira,
          text: "Oye, lo logramos. Nosotros. Juntos.",
          emotion: CharacterEmotion.surprised,
        ),
        DialogueLine(
          character: StoryCharacter.lumen,
          text: "Nosotros.",
          emotion: CharacterEmotion.happy,
        ),
        DialogueLine(
          character: StoryCharacter.kira,
          text: "No te emociones, sigo sin fiarme del todo.",
          emotion: CharacterEmotion.sarcastic,
        ),
        DialogueLine(
          character: StoryCharacter.narrator,
          text: "Por primera vez, Kira sonríe. El segundo fragmento del Arquitecto brilla en la oscuridad.",
          emotion: CharacterEmotion.narrative,
        ),
      ],
      bossPreDialogue: [
        DialogueLine(
          character: StoryCharacter.kira,
          text: "Eso es Petra. Era... buena. La vi antes de que la Entropía la tocara.",
          emotion: CharacterEmotion.concerned,
        ),
        DialogueLine(
          character: StoryCharacter.lumen,
          text: "La liberaremos.",
          emotion: CharacterEmotion.determined,
        ),
        DialogueLine(
          character: StoryCharacter.kira,
          text: "¿Tan seguro? Me gusta esa confianza. Sigue siendo un plan terrible, pero me gusta.",
          emotion: CharacterEmotion.sarcastic,
        ),
      ],
      bossPostDialogue: [
        DialogueLine(
          character: StoryCharacter.petra,
          text: "El cristal... recuerda su forma. Gracias, Lumen.",
          emotion: CharacterEmotion.grateful,
        ),
        DialogueLine(
          character: StoryCharacter.kira,
          text: "Oye, lo logramos. Nosotros. Juntos.",
          emotion: CharacterEmotion.surprised,
        ),
        DialogueLine(
          character: StoryCharacter.lumen,
          text: "Nosotros.",
          emotion: CharacterEmotion.happy,
        ),
      ],
    ),
    
    ChapterData(
      id: 3,
      title: "Las Cataratas de Magma",
      world: "Un volcán vivo cuya lava es energía corrompida del Arquitecto",
      guardian: "IGNIX",
      biome: "volcano",
      introDialogues: [
        DialogueLine(
          character: StoryCharacter.narrator,
          text: "El calor aquí no quema el cuerpo. Quema la memoria. Quema la identidad.",
          emotion: CharacterEmotion.narrative,
        ),
        DialogueLine(
          character: StoryCharacter.kira,
          text: "No me gusta este lugar. ¿Podemos ir a otro lado?",
          emotion: CharacterEmotion.nervous,
        ),
        DialogueLine(
          character: StoryCharacter.architect,
          text: "Lumen, este fragmento mío es especial. Es mi voluntad. Sin él, nunca podré sellar La Entropía. Ignix lo protege sin saberlo.",
          emotion: CharacterEmotion.serious,
        ),
        DialogueLine(
          character: StoryCharacter.lumen,
          text: "¿Ignix está de nuestro lado?",
          emotion: CharacterEmotion.curious,
        ),
        DialogueLine(
          character: StoryCharacter.architect,
          text: "Lo estaba. La Entropía usa su fuego como arma ahora. Tendrás que apagarlo... con orden.",
          emotion: CharacterEmotion.determined,
        ),
      ],
      outroDialogues: [
        DialogueLine(
          character: StoryCharacter.ignix,
          text: "El fuego no entiende de orden, pequeño bloque.",
          emotion: CharacterEmotion.philosophical,
        ),
        DialogueLine(
          character: StoryCharacter.lumen,
          text: "Pero el fuego sí entiende de propósito.",
          emotion: CharacterEmotion.wise,
        ),
        DialogueLine(
          character: StoryCharacter.ignix,
          text: "...Tenías razón. Yo era el guardián. El fuego es mío, no de ella.",
          emotion: CharacterEmotion.enlightened,
        ),
        DialogueLine(
          character: StoryCharacter.kira,
          text: "Eso fue... poético. ¿Quién te enseñó eso?",
          emotion: CharacterEmotion.impressed,
        ),
        DialogueLine(
          character: StoryCharacter.lumen,
          text: "El Arquitecto.",
          emotion: CharacterEmotion.humble,
        ),
        DialogueLine(
          character: StoryCharacter.architect,
          text: "No. Lo aprendiste tú solo, Lumen.",
          emotion: CharacterEmotion.proud,
        ),
      ],
      bossPreDialogue: [
        DialogueLine(
          character: StoryCharacter.ignix,
          text: "El fuego no entiende de orden, pequeño bloque.",
          emotion: CharacterEmotion.arrogant,
        ),
        DialogueLine(
          character: StoryCharacter.lumen,
          text: "Pero el fuego sí entiende de propósito.",
          emotion: CharacterEmotion.confident,
        ),
      ],
      bossPostDialogue: [
        DialogueLine(
          character: StoryCharacter.ignix,
          text: "...Tenías razón. Yo era el guardián. El fuego es mío, no de ella.",
          emotion: CharacterEmotion.enlightened,
        ),
        DialogueLine(
          character: StoryCharacter.kira,
          text: "Eso fue... poético. ¿Quién te enseñó eso?",
          emotion: CharacterEmotion.impressed,
        ),
        DialogueLine(
          character: StoryCharacter.lumen,
          text: "El Arquitecto.",
          emotion: CharacterEmotion.humble,
        ),
        DialogueLine(
          character: StoryCharacter.architect,
          text: "No. Lo aprendiste tú solo, Lumen.",
          emotion: CharacterEmotion.proud,
        ),
      ],
    ),
    
    ChapterData(
      id: 4,
      title: "El Océano Eterno",
      world: "Un océano infinito donde el agua es tiempo solidificado",
      guardian: "MAREEN",
      biome: "ocean",
      introDialogues: [
        DialogueLine(
          character: StoryCharacter.narrator,
          text: "El océano huele a 'antes'. A cosas que nunca ocurrirán. A elecciones no tomadas.",
          emotion: CharacterEmotion.narrative,
        ),
        DialogueLine(
          character: StoryCharacter.kira,
          text: "Empiezo a recordar cosas que no viví. ¿Es normal?",
          emotion: CharacterEmotion.confused,
        ),
        DialogueLine(
          character: StoryCharacter.lumen,
          text: "No lo sé.",
          emotion: CharacterEmotion.confused,
        ),
        DialogueLine(
          character: StoryCharacter.entropy,
          text: "Qué conmovedora su pequeña cruzada.",
          emotion: CharacterEmotion.mocking,
        ),
        DialogueLine(
          character: StoryCharacter.kira,
          text: "¿Quién...?!",
          emotion: CharacterEmotion.shocked,
        ),
        DialogueLine(
          character: StoryCharacter.entropy,
          text: "El orden que buscan restaurar... ¿alguna vez les preguntaron a los bloques si querían estar en ese orden?",
          emotion: CharacterEmotion.philosophical,
        ),
        DialogueLine(
          character: StoryCharacter.lumen,
          text: "Los bloques no pueden querer.",
          emotion: CharacterEmotion.logical,
        ),
        DialogueLine(
          character: StoryCharacter.entropy,
          text: "Exactamente. Y tú tampoco deberías poder. Y sin embargo... aquí estás. Interesante.",
          emotion: CharacterEmotion.curious,
        ),
        DialogueLine(
          character: StoryCharacter.lumen,
          text: "¿Qué quieres?",
          emotion: CharacterEmotion.direct,
        ),
        DialogueLine(
          character: StoryCharacter.entropy,
          text: "Ver hasta dónde llega tu fe en el orden, Lumen. Nada más.",
          emotion: CharacterEmotion.mysterious,
        ),
      ],
      outroDialogues: [
        DialogueLine(
          character: StoryCharacter.mareen,
          text: "Los recuerdos... estaban tan mezclados... no sabía cuáles eran míos.",
          emotion: CharacterEmotion.confused,
        ),
        DialogueLine(
          character: StoryCharacter.kira,
          text: "...Era feliz. Eso es lo que recuerdo. Eso es suficiente para seguir.",
          emotion: CharacterEmotion.emotional,
        ),
        DialogueLine(
          character: StoryCharacter.lumen,
          text: "¿Recuerdas ahora?",
          emotion: CharacterEmotion.caring,
        ),
        DialogueLine(
          character: StoryCharacter.kira,
          text: "...Era feliz. Eso es lo que recuerdo. Eso es suficiente para seguir.",
          emotion: CharacterEmotion.hopeful,
        ),
        DialogueLine(
          character: StoryCharacter.architect,
          text: "Lumen. El último fragmento está en La Cúpula Eléctrica. La Entropía te estará esperando.",
          emotion: CharacterEmotion.warning,
        ),
        DialogueLine(
          character: StoryCharacter.entropy,
          text: "Contaba con eso.",
          emotion: CharacterEmotion.confident,
        ),
      ],
      bossPreDialogue: [
        DialogueLine(
          character: StoryCharacter.kira,
          text: "Lumen. Si esto sale mal...",
          emotion: CharacterEmotion.worried,
        ),
        DialogueLine(
          character: StoryCharacter.lumen,
          text: "No saldrá mal.",
          emotion: CharacterEmotion.confident,
        ),
        DialogueLine(
          character: StoryCharacter.kira,
          text: "¿Cómo puedes estar tan seguro?",
          emotion: CharacterEmotion.skeptical,
        ),
        DialogueLine(
          character: StoryCharacter.lumen,
          text: "No estoy seguro. Pero tengo que actuar como si lo estuviera.",
          emotion: CharacterEmotion.determined,
        ),
        DialogueLine(
          character: StoryCharacter.entropy,
          text: "Qué filosofía tan... ordenada.",
          emotion: CharacterEmotion.mocking,
        ),
      ],
      bossPostDialogue: [
        DialogueLine(
          character: StoryCharacter.mareen,
          text: "Los recuerdos... estaban tan mezclados... no sabía cuáles eran míos.",
          emotion: CharacterEmotion.relieved,
        ),
        DialogueLine(
          character: StoryCharacter.kira,
          text: "...Era feliz. Eso es lo que recuerdo. Eso es suficiente para seguir.",
          emotion: CharacterEmotion.emotional,
        ),
      ],
    ),
    
    ChapterData(
      id: 5,
      title: "La Cúpula Eléctrica",
      world: "Una cúpula artificial que La Entropía construyó como su trono",
      guardian: "LA ENTROPÍA",
      biome: "dome",
      introDialogues: [
        DialogueLine(
          character: StoryCharacter.narrator,
          text: "La cúpula no fue construida. Fue des-construida hasta que tuvo esta forma.",
          emotion: CharacterEmotion.narrative,
        ),
        DialogueLine(
          character: StoryCharacter.kira,
          text: "Lumen. Si esto sale mal...",
          emotion: CharacterEmotion.worried,
        ),
        DialogueLine(
          character: StoryCharacter.lumen,
          text: "No saldrá mal.",
          emotion: CharacterEmotion.confident,
        ),
        DialogueLine(
          character: StoryCharacter.kira,
          text: "¿Cómo puedes estar tan seguro?",
          emotion: CharacterEmotion.skeptical,
        ),
        DialogueLine(
          character: StoryCharacter.lumen,
          text: "No estoy seguro. Pero tengo que actuar como si lo estuviera.",
          emotion: CharacterEmotion.determined,
        ),
        DialogueLine(
          character: StoryCharacter.entropy,
          text: "Qué filosofía tan... ordenada.",
          emotion: CharacterEmotion.mocking,
        ),
        DialogueLine(
          character: StoryCharacter.entropy,
          text: "¿Sabes lo que me parece más fascinante de ti, Lumen? Eres un bloque. Un simple bloque de luz. Y sin embargo has venido hasta aquí.",
          emotion: CharacterEmotion.curious,
        ),
        DialogueLine(
          character: StoryCharacter.lumen,
          text: "Vine a restaurar lo que rompiste.",
          emotion: CharacterEmotion.determined,
        ),
        DialogueLine(
          character: StoryCharacter.entropy,
          text: "¿Lo que rompí? Lumen, yo no rompo. Yo libero. Cada bloque que desordenó tenía un lugar fijo, un rol que cumplir. Yo les di... posibilidades.",
          emotion: CharacterEmotion.philosophical,
        ),
        DialogueLine(
          character: StoryCharacter.architect,
          text: "Y les quitaste propósito.",
          emotion: CharacterEmotion.angry,
        ),
        DialogueLine(
          character: StoryCharacter.entropy,
          text: "Arquitecto. Cuánto tiempo.",
          emotion: CharacterEmotion.surprised,
        ),
        DialogueLine(
          character: StoryCharacter.architect,
          text: "Demasiado.",
          emotion: CharacterEmotion.serious,
        ),
        DialogueLine(
          character: StoryCharacter.entropy,
          text: "Bien. Entonces que el universo decida. Demuéstrame, pequeño Lumen, que el orden puede vencer al caos infinito.",
          emotion: CharacterEmotion.determined,
        ),
      ],
      outroDialogues: [
        DialogueLine(
          character: StoryCharacter.entropy,
          text: "¿Cómo...?",
          emotion: CharacterEmotion.shocked,
        ),
        DialogueLine(
          character: StoryCharacter.lumen,
          text: "Porque no luchaba contra el desorden. Solo colocaba cada cosa en su lugar.",
          emotion: CharacterEmotion.wise,
        ),
        DialogueLine(
          character: StoryCharacter.entropy,
          text: "Quizás... quizás el orden y el caos no son enemigos.",
          emotion: CharacterEmotion.enlightened,
        ),
        DialogueLine(
          character: StoryCharacter.architect,
          text: "Nunca lo fueron. El orden sin caos es prisión. El caos sin orden es silencio.",
          emotion: CharacterEmotion.philosophical,
        ),
        DialogueLine(
          character: StoryCharacter.entropy,
          text: "¿Me dejarás existir?",
          emotion: CharacterEmotion.hopeful,
        ),
        DialogueLine(
          character: StoryCharacter.architect,
          text: "El universo te necesita. Como necesita el viento. Pero no como fuerza de destrucción.",
          emotion: CharacterEmotion.wise,
        ),
        DialogueLine(
          character: StoryCharacter.entropy,
          text: "...Acepto.",
          emotion: CharacterEmotion.humble,
        ),
        DialogueLine(
          character: StoryCharacter.kira,
          text: "¿Eso es todo? ¿Así termina?",
          emotion: CharacterEmotion.disappointed,
        ),
        DialogueLine(
          character: StoryCharacter.lumen,
          text: "¿Esperabas algo más dramático?",
          emotion: CharacterEmotion.playful,
        ),
        DialogueLine(
          character: StoryCharacter.kira,
          text: "Un poco sí.",
          emotion: CharacterEmotion.sarcastic,
        ),
        DialogueLine(
          character: StoryCharacter.architect,
          text: "Lumen. Lo que eres... lo que llegaste a ser... ya no eres un bloque. Eres un Arquitecto.",
          emotion: CharacterEmotion.proud,
        ),
        DialogueLine(
          character: StoryCharacter.lumen,
          text: "¿Y ahora qué?",
          emotion: CharacterEmotion.curious,
        ),
        DialogueLine(
          character: StoryCharacter.architect,
          text: "Ahora... construyes.",
          emotion: CharacterEmotion.inspiring,
        ),
        DialogueLine(
          character: StoryCharacter.narrator,
          text: "El universo respira. Los bloques encuentran su lugar. Y en algún punto entre el orden y el caos, Lumen y Kira miran el cosmos reconstruido. No es perfecto. Nunca lo fue. Pero es suyo.",
          emotion: CharacterEmotion.narrative,
        ),
      ],
      bossPreDialogue: [
        DialogueLine(
          character: StoryCharacter.entropy,
          text: "¿Sabes lo que me parece más fascinante de ti, Lumen? Eres un bloque. Un simple bloque de luz. Y sin embargo has venido hasta aquí.",
          emotion: CharacterEmotion.curious,
        ),
        DialogueLine(
          character: StoryCharacter.lumen,
          text: "Vine a restaurar lo que rompiste.",
          emotion: CharacterEmotion.determined,
        ),
        DialogueLine(
          character: StoryCharacter.entropy,
          text: "¿Lo que rompí? Lumen, yo no rompo. Yo libero. Cada bloque que desordenó tenía un lugar fijo, un rol que cumplir. Yo les di... posibilidades.",
          emotion: CharacterEmotion.philosophical,
        ),
        DialogueLine(
          character: StoryCharacter.architect,
          text: "Y les quitaste propósito.",
          emotion: CharacterEmotion.angry,
        ),
      ],
      bossPostDialogue: [
        DialogueLine(
          character: StoryCharacter.entropy,
          text: "¿Cómo...?",
          emotion: CharacterEmotion.shocked,
        ),
        DialogueLine(
          character: StoryCharacter.lumen,
          text: "Porque no luchaba contra el desorden. Solo colocaba cada cosa en su lugar.",
          emotion: CharacterEmotion.wise,
        ),
        DialogueLine(
          character: StoryCharacter.entropy,
          text: "Quizás... quizás el orden y el caos no son enemigos.",
          emotion: CharacterEmotion.enlightened,
        ),
        DialogueLine(
          character: StoryCharacter.architect,
          text: "Nunca lo fueron. El orden sin caos es prisión. El caos sin orden es silencio.",
          emotion: CharacterEmotion.philosophical,
        ),
      ],
    ),
  ];
  
  // Diálogos de tutoriales y eventos especiales
  static const List<DialogueLine> comboTutorial = [
    DialogueLine(
      character: StoryCharacter.architect,
      text: "Los bloques del mismo color resuenan entre sí. Cuando llenas una línea de un solo color... el universo canta.",
      emotion: CharacterEmotion.teaching,
    ),
    DialogueLine(
      character: StoryCharacter.lumen,
      text: "¿Canta?",
      emotion: CharacterEmotion.curious,
    ),
    DialogueLine(
      character: StoryCharacter.architect,
      text: "Sí. Y te recompensa con puntos extra. Intenta hacer combos de color.",
      emotion: CharacterEmotion.encouraging,
    ),
  ];
  
  static const List<DialogueLine> milestoneUnlocked = [
    DialogueLine(
      character: StoryCharacter.narrator,
      text: "Has alcanzado un nuevo hito en tu viaje. El universo reconoce tu progreso.",
      emotion: CharacterEmotion.narrative,
    ),
  ];
  
  // Obtener capítulo por ID
  static ChapterData? getChapter(int id) {
    try {
      return chapters.firstWhere((chapter) => chapter.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Obtener diálogo de tutorial
  static List<DialogueLine> getTutorialDialogues(String type) {
    switch (type) {
      case 'combo':
        return comboTutorial;
      case 'milestone':
        return milestoneUnlocked;
      default:
        return [];
    }
  }
}

class ChapterData {
  final int id;
  final String title;
  final String world;
  final String guardian;
  final String biome;
  final List<DialogueLine> introDialogues;
  final List<DialogueLine> outroDialogues;
  final List<DialogueLine> bossPreDialogue;
  final List<DialogueLine> bossPostDialogue;
  
  const ChapterData({
    required this.id,
    required this.title,
    required this.world,
    required this.guardian,
    required this.biome,
    required this.introDialogues,
    required this.outroDialogues,
    required this.bossPreDialogue,
    required this.bossPostDialogue,
  });
  
  // Verificar si el capítulo está disponible
  bool isAvailable(int currentChapter) {
    return id <= currentChapter;
  }
  
  // Verificar si el capítulo está completado
  bool isCompleted(Map<String, dynamic> progress) {
    final chapterProgress = progress['chapter_$id'] as Map<String, dynamic>?;
    return chapterProgress?['completed'] ?? false;
  }
  
  // Obtener estrellas del capítulo
  int getStars(Map<String, dynamic> progress) {
    final chapterProgress = progress['chapter_$id'] as Map<String, dynamic>?;
    final stars = chapterProgress?['stars'] as List<int>? ?? [];
    return stars.fold(0, (sum, star) => sum + star);
  }
  
  // Verificar si es perfecto (todas las estrellas)
  bool isPerfect(Map<String, dynamic> progress) {
    return getStars(progress) >= 36; // 12 niveles × 3 estrellas máximo
  }
}
