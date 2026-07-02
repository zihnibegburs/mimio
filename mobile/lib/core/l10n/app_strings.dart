import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimio/core/models/recurrence.dart';
import 'package:mimio/core/storage/settings_storage.dart';

const supportedLanguageCodes = ['en', 'tr', 'es', 'fr', 'de'];

final appLanguageProvider = AsyncNotifierProvider<AppLanguageNotifier, String>(AppLanguageNotifier.new);

class AppLanguageNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    return ref.read(settingsStorageProvider).getLanguage();
  }

  Future<void> setLanguage(String code) async {
    await ref.read(settingsStorageProvider).setLanguage(code);
    state = AsyncData(code);
  }
}

String l10n(String lang, Map<String, String> translations) {
  return translations[lang] ?? translations['en']!;
}

String dateLocaleFor(String lang) => switch (lang) {
      'tr' => 'tr_TR',
      'es' => 'es_ES',
      'fr' => 'fr_FR',
      'de' => 'de_DE',
      _ => 'en_US',
    };

class S {
  S(this.lang);

  final String lang;

  bool get isEn => lang == 'en';

  // Profile & settings
  String get profile => l10n(lang, _m(en: 'Profile', tr: 'Profil', es: 'Perfil', fr: 'Profil', de: 'Profil'));
  String get editProfile =>
      l10n(lang, _m(en: 'Edit profile', tr: 'Profili düzenle', es: 'Editar perfil', fr: 'Modifier le profil', de: 'Profil bearbeiten'));
  String get displayName =>
      l10n(lang, _m(en: 'Display name', tr: 'Görünen ad', es: 'Nombre visible', fr: 'Nom affiché', de: 'Anzeigename'));
  String get avatarColor =>
      l10n(lang, _m(en: 'Avatar color', tr: 'Avatar rengi', es: 'Color del avatar', fr: 'Couleur de l\'avatar', de: 'Avatar-Farbe'));
  String get language => l10n(lang, _m(en: 'Language', tr: 'Dil', es: 'Idioma', fr: 'Langue', de: 'Sprache'));
  String get preferences =>
      l10n(lang, _m(en: 'Preferences', tr: 'Tercihler', es: 'Preferencias', fr: 'Préférences', de: 'Einstellungen'));
  String get account => l10n(lang, _m(en: 'Account', tr: 'Hesap', es: 'Cuenta', fr: 'Compte', de: 'Konto'));
  String get logout => l10n(lang, _m(en: 'Log out', tr: 'Çıkış yap', es: 'Cerrar sesión', fr: 'Se déconnecter', de: 'Abmelden'));
  String get save => l10n(lang, _m(en: 'Save', tr: 'Kaydet', es: 'Guardar', fr: 'Enregistrer', de: 'Speichern'));
  String get cancel => l10n(lang, _m(en: 'Cancel', tr: 'İptal', es: 'Cancelar', fr: 'Annuler', de: 'Abbrechen'));
  String get version => l10n(lang, _m(en: 'Version', tr: 'Sürüm', es: 'Versión', fr: 'Version', de: 'Version'));
  String get notifications =>
      l10n(lang, _m(en: 'Notifications', tr: 'Bildirimler', es: 'Notificaciones', fr: 'Notifications', de: 'Benachrichtigungen'));
  String get comingSoon =>
      l10n(lang, _m(en: 'Coming soon', tr: 'Yakında', es: 'Próximamente', fr: 'Bientôt disponible', de: 'Demnächst'));
  String get profileUpdated =>
      l10n(lang, _m(en: 'Profile updated', tr: 'Profil güncellendi', es: 'Perfil actualizado', fr: 'Profil mis à jour', de: 'Profil aktualisiert'));

  // Tasks
  String get taskOptions =>
      l10n(lang, _m(en: 'Task options', tr: 'Görev seçenekleri', es: 'Opciones de tarea', fr: 'Options de tâche', de: 'Aufgabenoptionen'));
  String get startTask =>
      l10n(lang, _m(en: 'Start task', tr: 'Göreve başla', es: 'Iniciar tarea', fr: 'Commencer la tâche', de: 'Aufgabe starten'));
  String get start =>
      l10n(lang, _m(en: 'Start', tr: 'Başlat', es: 'Iniciar', fr: 'Démarrer', de: 'Starten'));
  String get edit => l10n(lang, _m(en: 'Edit', tr: 'Düzenle', es: 'Editar', fr: 'Modifier', de: 'Bearbeiten'));
  String get delete => l10n(lang, _m(en: 'Delete', tr: 'Sil', es: 'Eliminar', fr: 'Supprimer', de: 'Löschen'));
  String get splitSubtasks =>
      l10n(lang, _m(en: 'Split into subtasks', tr: 'Adımlara böl', es: 'Dividir en pasos', fr: 'Diviser en étapes', de: 'In Schritte aufteilen'));
  String get goToFocus =>
      l10n(lang, _m(en: 'Go to focus', tr: 'Odağa git', es: 'Ir al enfoque', fr: 'Aller au focus', de: 'Zum Fokus'));
  String get pause => l10n(lang, _m(en: 'Pause', tr: 'Duraklat', es: 'Pausar', fr: 'Pause', de: 'Pause'));
  String get resume => l10n(lang, _m(en: 'Resume', tr: 'Devam et', es: 'Reanudar', fr: 'Reprendre', de: 'Fortsetzen'));
  String get complete => l10n(lang, _m(en: 'Complete', tr: 'Tamamla', es: 'Completar', fr: 'Terminer', de: 'Abschließen'));
  String get undoComplete =>
      l10n(lang, _m(en: 'Undo complete', tr: 'Tamamlamayı geri al', es: 'Deshacer completado', fr: 'Annuler la complétion', de: 'Abschluss rückgängig'));
  String get taskCompletedUndo =>
      l10n(lang, _m(en: 'Task completed', tr: 'Görev tamamlandı', es: 'Tarea completada', fr: 'Tâche terminée', de: 'Aufgabe abgeschlossen'));
  String get undo =>
      l10n(lang, _m(en: 'Undo', tr: 'Geri al', es: 'Deshacer', fr: 'Annuler', de: 'Rückgängig'));
  String get deleteTask =>
      l10n(lang, _m(en: 'Delete task', tr: 'Görevi sil', es: 'Eliminar tarea', fr: 'Supprimer la tâche', de: 'Aufgabe löschen'));
  String get deleteConfirm =>
      l10n(lang, _m(en: 'Delete this task?', tr: 'Bu görev silinsin mi?', es: '¿Eliminar esta tarea?', fr: 'Supprimer cette tâche ?', de: 'Diese Aufgabe löschen?'));
  String get addTask =>
      l10n(lang, _m(en: 'Add task', tr: 'Görev Ekle', es: 'Añadir tarea', fr: 'Ajouter une tâche', de: 'Aufgabe hinzufügen'));
  String get newTask =>
      l10n(lang, _m(en: 'New task', tr: 'Yeni Görev', es: 'Nueva tarea', fr: 'Nouvelle tâche', de: 'Neue Aufgabe'));
  String get editTask =>
      l10n(lang, _m(en: 'Edit task', tr: 'Görevi Düzenle', es: 'Editar tarea', fr: 'Modifier la tâche', de: 'Aufgabe bearbeiten'));
  String get editStep =>
      l10n(lang, _m(en: 'Edit step', tr: 'Adımı Düzenle', es: 'Editar paso', fr: 'Modifier l\'étape', de: 'Schritt bearbeiten'));
  String get taskNameHint =>
      l10n(lang, _m(en: 'Task name...', tr: 'Görev adı...', es: 'Nombre de la tarea...', fr: 'Nom de la tâche...', de: 'Aufgabenname...'));
  String get rewardLabel =>
      l10n(lang, _m(en: 'Reward', tr: 'Ödül', es: 'Recompensa', fr: 'Récompense', de: 'Belohnung'));
  String get rewardHint => l10n(lang, _m(
        en: 'What will you treat yourself to?',
        tr: 'Kendine ne ödül vereceksin?',
        es: '¿Con qué te recompensarás?',
        fr: 'Comment allez-vous vous récompenser ?',
        de: 'Womit belohnst du dich?',
      ));
  String get rewardOptionalHint => l10n(lang, _m(
        en: 'Optional — a little motivation when you finish',
        tr: 'İsteğe bağlı — bitirince seni motive etsin',
        es: 'Opcional — un extra de motivación al terminar',
        fr: 'Facultatif — une motivation à la fin',
        de: 'Optional — Motivation nach dem Abschluss',
      ));
  String get taskCompletedTitle =>
      l10n(lang, _m(en: 'Well done!', tr: 'Tebrikler!', es: '¡Bien hecho!', fr: 'Bravo !', de: 'Gut gemacht!'));
  String taskCompletedSubtitle(String title) => l10n(lang, _m(
        en: 'You completed "$title"',
        tr: '"$title" görevini tamamladın',
        es: 'Completaste "$title"',
        fr: 'Vous avez terminé « $title »',
        de: 'Du hast „$title“ abgeschlossen',
      ));
  String get yourReward =>
      l10n(lang, _m(en: 'Your reward', tr: 'Ödülün', es: 'Tu recompensa', fr: 'Votre récompense', de: 'Deine Belohnung'));
  String get rewardReminder => l10n(lang, _m(
        en: 'Time to enjoy your reward!',
        tr: 'Şimdi ödülünün tadını çıkarma zamanı!',
        es: '¡Es hora de disfrutar tu recompensa!',
        fr: 'Il est temps de profiter de votre récompense !',
        de: 'Zeit, deine Belohnung zu genießen!',
      ));
  String get awesome =>
      l10n(lang, _m(en: 'Awesome!', tr: 'Harika!', es: '¡Genial!', fr: 'Super !', de: 'Super!'));
  String get addTaskButton =>
      l10n(lang, _m(en: 'Add task', tr: 'Görevi Ekle', es: 'Añadir tarea', fr: 'Ajouter la tâche', de: 'Aufgabe hinzufügen'));
  String get addTaskAndSteps =>
      l10n(lang, _m(en: 'Add task and steps', tr: 'Görev ve Adımları Ekle', es: 'Añadir tarea y pasos', fr: 'Ajouter tâche et étapes', de: 'Aufgabe und Schritte hinzufügen'));
  String get addFirstTask =>
      l10n(lang, _m(en: 'Add first task', tr: 'İlk Görevi Ekle', es: 'Añadir primera tarea', fr: 'Ajouter la première tâche', de: 'Erste Aufgabe hinzufügen'));
  String get duration =>
      l10n(lang, _m(en: 'Duration', tr: 'Süre', es: 'Duración', fr: 'Durée', de: 'Dauer'));
  String get time => l10n(lang, _m(en: 'Time', tr: 'Saat', es: 'Hora', fr: 'Heure', de: 'Uhrzeit'));
  String get color => l10n(lang, _m(en: 'Color', tr: 'Renk', es: 'Color', fr: 'Couleur', de: 'Farbe'));
  String get repeat => l10n(lang, _m(en: 'Repeat', tr: 'Tekrar', es: 'Repetir', fr: 'Répéter', de: 'Wiederholen'));
  String get repeatNone =>
      l10n(lang, _m(en: 'No repeat', tr: 'Tekrar yok', es: 'Sin repetición', fr: 'Pas de répétition', de: 'Keine Wiederholung'));
  String get repeatDaily =>
      l10n(lang, _m(en: 'Daily', tr: 'Günlük', es: 'Diario', fr: 'Quotidien', de: 'Täglich'));
  String get repeatWeekly =>
      l10n(lang, _m(en: 'Weekly', tr: 'Haftalık', es: 'Semanal', fr: 'Hebdomadaire', de: 'Wöchentlich'));
  String get repeatMonthly =>
      l10n(lang, _m(en: 'Monthly', tr: 'Aylık', es: 'Mensual', fr: 'Mensuel', de: 'Monatlich'));
  String get repeatYearly =>
      l10n(lang, _m(en: 'Yearly', tr: 'Yıllık', es: 'Anual', fr: 'Annuel', de: 'Jährlich'));
  String get repeatCustom =>
      l10n(lang, _m(en: 'Custom', tr: 'Özel', es: 'Personalizado', fr: 'Personnalisé', de: 'Benutzerdefiniert'));
  String get repeatEvery =>
      l10n(lang, _m(en: 'Every', tr: 'Her', es: 'Cada', fr: 'Tous les', de: 'Alle'));
  String repeatDays(int count) => l10n(lang, _m(
        en: count == 1 ? 'day' : 'days',
        tr: 'gün',
        es: count == 1 ? 'día' : 'días',
        fr: count == 1 ? 'jour' : 'jours',
        de: count == 1 ? 'Tag' : 'Tage',
      ));
  String repeatWeeks(int count) => l10n(lang, _m(
        en: count == 1 ? 'week' : 'weeks',
        tr: 'hafta',
        es: count == 1 ? 'semana' : 'semanas',
        fr: count == 1 ? 'semaine' : 'semaines',
        de: count == 1 ? 'Woche' : 'Wochen',
      ));
  String repeatMonths(int count) => l10n(lang, _m(
        en: count == 1 ? 'month' : 'months',
        tr: 'ay',
        es: count == 1 ? 'mes' : 'meses',
        fr: count == 1 ? 'mois' : 'mois',
        de: count == 1 ? 'Monat' : 'Monate',
      ));

  String recurrenceTypeLabel(RecurrenceType type) => switch (type) {
        RecurrenceType.none => repeatNone,
        RecurrenceType.daily => repeatDaily,
        RecurrenceType.weekly => repeatWeekly,
        RecurrenceType.monthly => repeatMonthly,
        RecurrenceType.yearly => repeatYearly,
        RecurrenceType.custom => repeatCustom,
      };

  String recurrenceUnitLabel(RecurrenceUnit unit) => switch (unit) {
        RecurrenceUnit.days => repeatDays(2),
        RecurrenceUnit.weeks => repeatWeeks(2),
        RecurrenceUnit.months => repeatMonths(2),
      };

  String recurrenceLabel(RecurrenceSelection selection) {
    if (selection.type == RecurrenceType.none) return repeatNone;
    if (selection.type == RecurrenceType.custom) {
      final unit = switch (selection.unit) {
        RecurrenceUnit.days => repeatDays(selection.interval),
        RecurrenceUnit.weeks => repeatWeeks(selection.interval),
        RecurrenceUnit.months => repeatMonths(selection.interval),
      };
      return l10n(lang, _m(
        en: 'Every ${selection.interval} $unit',
        tr: 'Her ${selection.interval} $unit',
        es: 'Cada ${selection.interval} $unit',
        fr: 'Tous les ${selection.interval} $unit',
        de: 'Alle ${selection.interval} $unit',
      ));
    }
    return recurrenceTypeLabel(selection.type);
  }

  String get splitIntoSteps =>
      l10n(lang, _m(en: 'Split into steps', tr: 'Adımlara böl', es: 'Dividir en pasos', fr: 'Diviser en étapes', de: 'In Schritte aufteilen'));
  String get splitIntoStepsHint => l10n(lang, _m(
        en: 'AI breaks the task into smaller steps',
        tr: 'AI görevi küçük adımlara ayırır',
        es: 'La IA divide la tarea en pasos más pequeños',
        fr: 'L\'IA divise la tâche en petites étapes',
        de: 'KI teilt die Aufgabe in kleinere Schritte',
      ));

  // AI
  String get aiBreakdown =>
      l10n(lang, _m(en: 'AI subtask breakdown', tr: 'AI ile adımlara böl', es: 'División con IA', fr: 'Découpage IA', de: 'KI-Aufteilung'));
  String get aiBreakdownHint => l10n(lang, _m(
        en: 'Split this task into smaller steps with AI.',
        tr: 'Bu görevi AI ile küçük adımlara ayır.',
        es: 'Divide esta tarea en pasos más pequeños con IA.',
        fr: 'Divisez cette tâche en petites étapes avec l\'IA.',
        de: 'Teile diese Aufgabe mit KI in kleinere Schritte.',
      ));
  String get previewSteps =>
      l10n(lang, _m(en: 'Preview steps', tr: 'Adımları önizle', es: 'Vista previa de pasos', fr: 'Aperçu des étapes', de: 'Schritte anzeigen'));
  String get applySteps =>
      l10n(lang, _m(en: 'Apply steps', tr: 'Adımları uygula', es: 'Aplicar pasos', fr: 'Appliquer les étapes', de: 'Schritte anwenden'));
  String get aiThinking =>
      l10n(lang, _m(en: 'AI is thinking...', tr: 'AI düşünüyor...', es: 'La IA está pensando...', fr: 'L\'IA réfléchit...', de: 'KI denkt nach...'));
  String get applyingSteps =>
      l10n(lang, _m(en: 'Applying steps...', tr: 'Adımlar ekleniyor...', es: 'Aplicando pasos...', fr: 'Application des étapes...', de: 'Schritte werden hinzugefügt...'));
  String get aiPlanner =>
      l10n(lang, _m(en: 'AI Planner', tr: 'AI Planlayıcı', es: 'Planificador IA', fr: 'Planificateur IA', de: 'KI-Planer'));
  String get planDay =>
      l10n(lang, _m(en: 'Plan day', tr: 'Gün Planla', es: 'Planificar día', fr: 'Planifier la journée', de: 'Tag planen'));
  String get splitTask =>
      l10n(lang, _m(en: 'Split task', tr: 'Görev Böl', es: 'Dividir tarea', fr: 'Diviser la tâche', de: 'Aufgabe teilen'));
  String get createPlan =>
      l10n(lang, _m(en: 'Create plan', tr: 'Plan Oluştur', es: 'Crear plan', fr: 'Créer un plan', de: 'Plan erstellen'));
  String get addPlanToDay =>
      l10n(lang, _m(en: 'Add plan to day', tr: 'Planı Güne Ekle', es: 'Añadir plan al día', fr: 'Ajouter le plan au jour', de: 'Plan zum Tag hinzufügen'));
  String get poweredByGroq => 'Powered by Groq AI';

  String get planPrompt => l10n(lang, _m(
        en: 'Write or speak what\'s on your mind',
        tr: 'Aklındakileri yaz veya sesle söyle',
        es: 'Escribe o habla lo que tienes en mente',
        fr: 'Écrivez ou dites ce que vous avez en tête',
        de: 'Schreibe oder sprich, was dir durch den Kopf geht',
      ));
  String get breakdownPrompt => l10n(lang, _m(
        en: 'Write or speak the big task',
        tr: 'Büyük görevi yaz veya sesle söyle',
        es: 'Escribe o habla la tarea grande',
        fr: 'Écrivez ou dites la grande tâche',
        de: 'Schreibe oder sprich die große Aufgabe',
      ));
  String get planExample => l10n(lang, _m(
        en: 'E.g. "Morning workout, afternoon meeting, evening shopping"',
        tr: 'Örn: "Sabah spor, öğleden sonra toplantı, akşam alışveriş"',
        es: 'Ej.: "Ejercicio por la mañana, reunión por la tarde, compras por la noche"',
        fr: 'Ex. : « Sport le matin, réunion l\'après-midi, courses le soir »',
        de: 'Z.B. „Morgens Sport, nachmittags Meeting, abends einkaufen"',
      ));
  String get breakdownExample => l10n(lang, _m(
        en: 'E.g. "Clean the house" → breaks into small steps',
        tr: 'Örn: "Ev temizliği yapacağım" → küçük adımlara böler',
        es: 'Ej.: "Limpiar la casa" → lo divide en pasos pequeños',
        fr: 'Ex. : « Nettoyer la maison » → divise en petites étapes',
        de: 'Z.B. „Haus putzen" → teilt in kleine Schritte',
      ));
  String get planHint => l10n(lang, _m(
        en: 'What do you want to do today?',
        tr: 'Bugün ne yapmak istiyorsun?',
        es: '¿Qué quieres hacer hoy?',
        fr: 'Que voulez-vous faire aujourd\'hui ?',
        de: 'Was möchtest du heute tun?',
      ));
  String get breakdownHint => l10n(lang, _m(
        en: 'Which task should we split?',
        tr: 'Hangi görevi bölelim?',
        es: '¿Qué tarea dividimos?',
        fr: 'Quelle tâche diviser ?',
        de: 'Welche Aufgabe sollen wir teilen?',
      ));

  // Home & navigation
  String hello(String name) =>
      l10n(lang, _m(en: 'Hello, $name 👋', tr: 'Merhaba, $name 👋', es: 'Hola, $name 👋', fr: 'Bonjour, $name 👋', de: 'Hallo, $name 👋'));
  String get hourView =>
      l10n(lang, _m(en: 'Hour view', tr: 'Saat görünümü', es: 'Vista por horas', fr: 'Vue horaire', de: 'Stundenansicht'));
  String get listView =>
      l10n(lang, _m(en: 'List view', tr: 'Liste görünümü', es: 'Vista de lista', fr: 'Vue liste', de: 'Listenansicht'));
  String get today => l10n(lang, _m(en: 'Today', tr: 'Bugün', es: 'Hoy', fr: 'Aujourd\'hui', de: 'Heute'));
  String get week => l10n(lang, _m(en: 'Week', tr: 'Hafta', es: 'Semana', fr: 'Semaine', de: 'Woche'));
  String get day => l10n(lang, _m(en: 'Day', tr: 'Gün', es: 'Día', fr: 'Jour', de: 'Tag'));
  String get focus => l10n(lang, _m(en: 'Focus', tr: 'Odak', es: 'Enfoque', fr: 'Focus', de: 'Fokus'));
  String get weeklyPlanSummary => l10n(lang, _m(
        en: 'Weekly plan summary',
        tr: 'Haftalık plan özeti',
        es: 'Resumen semanal',
        fr: 'Résumé hebdomadaire',
        de: 'Wochenübersicht',
      ));
  String get focusTimer =>
      l10n(lang, _m(en: 'Focus timer', tr: 'Odak zamanlayıcı', es: 'Temporizador de enfoque', fr: 'Minuteur de focus', de: 'Fokus-Timer'));
  String get todaysPlan =>
      l10n(lang, _m(en: 'Today\'s plan', tr: 'Günün Planı', es: 'Plan de hoy', fr: 'Plan du jour', de: 'Tagesplan'));
  String get connectionError =>
      l10n(lang, _m(en: 'Connection error', tr: 'Bağlantı hatası', es: 'Error de conexión', fr: 'Erreur de connexion', de: 'Verbindungsfehler'));
  String get retry => l10n(lang, _m(en: 'Try again', tr: 'Tekrar Dene', es: 'Reintentar', fr: 'Réessayer', de: 'Erneut versuchen'));
  String get noPlanToday =>
      l10n(lang, _m(en: 'No plan for today', tr: 'Bugün için plan yok', es: 'Sin plan para hoy', fr: 'Aucun plan pour aujourd\'hui', de: 'Kein Plan für heute'));
  String get emptyPlanHint => l10n(lang, _m(
        en: 'Start your day by adding your first task.\nSmall steps make a big difference.',
        tr: 'İlk görevini ekleyerek güne başla.\nKüçük adımlar büyük fark yaratır.',
        es: 'Empieza el día añadiendo tu primera tarea.\nLos pequeños pasos marcan la diferencia.',
        fr: 'Commencez la journée en ajoutant votre première tâche.\nLes petits pas font la différence.',
        de: 'Starte den Tag mit deiner ersten Aufgabe.\nKleine Schritte bewirken Großes.',
      ));

  // Progress & status
  String get dayEmpty => l10n(lang, _m(en: 'Day is empty', tr: 'Gün boş', es: 'Día vacío', fr: 'Journée vide', de: 'Tag ist leer'));
  String get active => l10n(lang, _m(en: 'Active', tr: 'Aktif', es: 'Activo', fr: 'Actif', de: 'Aktiv'));
  String get paused =>
      l10n(lang, _m(en: 'Paused', tr: 'Duraklatıldı', es: 'En pausa', fr: 'En pause', de: 'Pausiert'));
  String get pausedUpper =>
      l10n(lang, _m(en: 'PAUSED', tr: 'DURAKLATILDI', es: 'EN PAUSA', fr: 'EN PAUSE', de: 'PAUSIERT'));
  String get currentlyActive =>
      l10n(lang, _m(en: 'Currently active', tr: 'Şu an aktif', es: 'Activo ahora', fr: 'Actif maintenant', de: 'Gerade aktiv'));
  String get oneTaskActive =>
      l10n(lang, _m(en: 'One task is active', tr: 'Bir görev şu an aktif', es: 'Una tarea está activa', fr: 'Une tâche est active', de: 'Eine Aufgabe ist aktiv'));
  String get addFirstTaskHint => l10n(lang, _m(
        en: 'Add your first task to get started',
        tr: 'İlk görevini ekleyerek başla',
        es: 'Añade tu primera tarea para empezar',
        fr: 'Ajoutez votre première tâche pour commencer',
        de: 'Füge deine erste Aufgabe hinzu',
      ));
  String get remainingTime =>
      l10n(lang, _m(en: 'remaining', tr: 'kalan süre', es: 'restante', fr: 'restant', de: 'verbleibend'));
  String get finish => l10n(lang, _m(en: 'Finish', tr: 'Bitir', es: 'Terminar', fr: 'Terminer', de: 'Beenden'));
  String get continueLabel =>
      l10n(lang, _m(en: 'Continue', tr: 'Devam', es: 'Continuar', fr: 'Continuer', de: 'Weiter'));
  String get focusModeOff =>
      l10n(lang, _m(en: 'Focus mode is off', tr: 'Odak modu kapalı', es: 'Modo enfoque desactivado', fr: 'Mode focus désactivé', de: 'Fokusmodus aus'));
  String get focusModeHint => l10n(lang, _m(
        en: 'When you start a task, the timer appears here.\nYou can also track it from the lock screen widget.',
        tr: 'Bir görevi başlattığında zamanlayıcı burada görünür.\nWidget ile kilit ekranından da takip edebilirsin.',
        es: 'Al iniciar una tarea, el temporizador aparece aquí.\nTambién puedes seguirlo desde el widget de la pantalla de bloqueo.',
        fr: 'Quand vous démarrez une tâche, le minuteur apparaît ici.\nVous pouvez aussi le suivre depuis le widget de l\'écran verrouillé.',
        de: 'Wenn du eine Aufgabe startest, erscheint der Timer hier.\nDu kannst ihn auch über das Sperrbildschirm-Widget verfolgen.',
      ));
  String get focusModeOn => l10n(lang, _m(
        en: 'You\'re in focus mode — keep going!',
        tr: 'Odak modundasın — devam et!',
        es: 'Estás en modo enfoque — ¡sigue!',
        fr: 'Vous êtes en mode focus — continuez !',
        de: 'Du bist im Fokusmodus — weiter so!',
      ));
  String get quickStart =>
      l10n(lang, _m(en: 'Quick start', tr: 'Hızlı başlat', es: 'Inicio rápido', fr: 'Démarrage rapide', de: 'Schnellstart'));
  String get focusMode =>
      l10n(lang, _m(en: 'Focus mode', tr: 'Odak Modu', es: 'Modo enfoque', fr: 'Mode focus', de: 'Fokusmodus'));
  String get noActiveTask =>
      l10n(lang, _m(en: 'No active task', tr: 'Aktif görev yok', es: 'Sin tarea activa', fr: 'Aucune tâche active', de: 'Keine aktive Aufgabe'));
  String get nextUp => l10n(lang, _m(en: 'Up next', tr: 'Sıradaki', es: 'Siguiente', fr: 'À suivre', de: 'Als Nächstes'));
  String get noPlanWidget =>
      l10n(lang, _m(en: 'No plan today', tr: 'Bugün plan yok', es: 'Sin plan hoy', fr: 'Aucun plan aujourd\'hui', de: 'Kein Plan heute'));

  // Auth
  String get loginTagline => l10n(lang, _m(
        en: 'Your visual daily planner',
        tr: 'Görsel günlük planlayıcın',
        es: 'Tu planificador visual diario',
        fr: 'Votre planificateur visuel quotidien',
        de: 'Dein visueller Tagesplaner',
      ));
  String get email => l10n(lang, _m(en: 'Email', tr: 'E-posta', es: 'Correo', fr: 'E-mail', de: 'E-Mail'));
  String get password => l10n(lang, _m(en: 'Password', tr: 'Şifre', es: 'Contraseña', fr: 'Mot de passe', de: 'Passwort'));
  String get emailRequired =>
      l10n(lang, _m(en: 'Email required', tr: 'E-posta gerekli', es: 'Correo obligatorio', fr: 'E-mail requis', de: 'E-Mail erforderlich'));
  String get passwordMin6 =>
      l10n(lang, _m(en: 'At least 6 characters', tr: 'En az 6 karakter', es: 'Al menos 6 caracteres', fr: 'Au moins 6 caractères', de: 'Mindestens 6 Zeichen'));
  String get login => l10n(lang, _m(en: 'Log in', tr: 'Giriş Yap', es: 'Iniciar sesión', fr: 'Se connecter', de: 'Anmelden'));
  String get noAccountRegister => l10n(lang, _m(
        en: 'Don\'t have an account? Sign up',
        tr: 'Hesabın yok mu? Kayıt ol',
        es: '¿No tienes cuenta? Regístrate',
        fr: 'Pas de compte ? Inscrivez-vous',
        de: 'Noch kein Konto? Registrieren',
      ));
  String get createAccount =>
      l10n(lang, _m(en: 'Create account', tr: 'Hesap Oluştur', es: 'Crear cuenta', fr: 'Créer un compte', de: 'Konto erstellen'));
  String get registerSubtitle => l10n(lang, _m(
        en: 'Sign up to start planning',
        tr: 'Planlamaya başlamak için kayıt ol',
        es: 'Regístrate para empezar a planificar',
        fr: 'Inscrivez-vous pour commencer à planifier',
        de: 'Registriere dich, um mit dem Planen zu beginnen',
      ));
  String get yourName => l10n(lang, _m(en: 'Your name', tr: 'Adın', es: 'Tu nombre', fr: 'Votre nom', de: 'Dein Name'));
  String get nameMin2 =>
      l10n(lang, _m(en: 'At least 2 characters', tr: 'En az 2 karakter', es: 'Al menos 2 caracteres', fr: 'Au moins 2 caractères', de: 'Mindestens 2 Zeichen'));
  String get validEmail =>
      l10n(lang, _m(en: 'Enter a valid email', tr: 'Geçerli e-posta gir', es: 'Introduce un correo válido', fr: 'Entrez un e-mail valide', de: 'Gültige E-Mail eingeben'));
  String get register =>
      l10n(lang, _m(en: 'Sign up', tr: 'Kayıt Ol', es: 'Registrarse', fr: 'S\'inscrire', de: 'Registrieren'));

  // Speech
  String get stopListening =>
      l10n(lang, _m(en: 'Stop listening', tr: 'Dinlemeyi durdur', es: 'Dejar de escuchar', fr: 'Arrêter l\'écoute', de: 'Zuhören beenden'));
  String get speakToType =>
      l10n(lang, _m(en: 'Speak to type', tr: 'Sesle yaz', es: 'Hablar para escribir', fr: 'Parler pour écrire', de: 'Sprechen zum Tippen'));

  // Errors
  String get sessionExpired => l10n(lang, _m(
        en: 'Session expired. Please log in again.',
        tr: 'Oturum süresi doldu. Tekrar giriş yapın.',
        es: 'Sesión expirada. Inicia sesión de nuevo.',
        fr: 'Session expirée. Veuillez vous reconnecter.',
        de: 'Sitzung abgelaufen. Bitte erneut anmelden.',
      ));
  String get aiRequestDenied => l10n(lang, _m(
        en: 'AI request denied. Restart the backend.',
        tr: 'AI isteği reddedildi. Backend\'i yeniden başlatın.',
        es: 'Solicitud de IA rechazada. Reinicia el backend.',
        fr: 'Requête IA refusée. Redémarrez le backend.',
        de: 'KI-Anfrage abgelehnt. Backend neu starten.',
      ));
  String get aiRequestDeniedWithHint => l10n(lang, _m(
        en: 'AI request denied. Restart the backend (./gradlew bootRun).',
        tr: 'AI isteği reddedildi. Backend\'i yeniden başlatın (./gradlew bootRun).',
        es: 'Solicitud de IA rechazada. Reinicia el backend (./gradlew bootRun).',
        fr: 'Requête IA refusée. Redémarrez le backend (./gradlew bootRun).',
        de: 'KI-Anfrage abgelehnt. Backend neu starten (./gradlew bootRun).',
      ));
  String get aiEndpointError => l10n(lang, _m(
        en: 'AI endpoint unreachable. Is the backend and ngrok running? Restart the backend.',
        tr: 'AI endpoint erişilemedi. Backend ve ngrok çalışıyor mu? Backend\'i yeniden başlatın.',
        es: 'Endpoint de IA inaccesible. ¿Están el backend y ngrok activos? Reinicia el backend.',
        fr: 'Endpoint IA inaccessible. Le backend et ngrok fonctionnent-ils ? Redémarrez le backend.',
        de: 'KI-Endpoint nicht erreichbar. Laufen Backend und ngrok? Backend neu starten.',
      ));
  String get groqUnavailable => l10n(lang, _m(
        en: 'AI service unavailable. Check the Groq API key.',
        tr: 'AI servisi kullanılamıyor. Groq API anahtarını kontrol edin.',
        es: 'Servicio de IA no disponible. Comprueba la clave API de Groq.',
        fr: 'Service IA indisponible. Vérifiez la clé API Groq.',
        de: 'KI-Dienst nicht verfügbar. Groq-API-Schlüssel prüfen.',
      ));
  String get serverUnreachable => l10n(lang, _m(
        en: 'Could not connect to server. Is the backend running?',
        tr: 'Sunucuya bağlanılamadı. Backend çalışıyor mu?',
        es: 'No se pudo conectar al servidor. ¿Está el backend activo?',
        fr: 'Impossible de se connecter au serveur. Le backend fonctionne-t-il ?',
        de: 'Verbindung zum Server fehlgeschlagen. Läuft das Backend?',
      ));
  String errorPrefix(Object error) => l10n(lang, _m(
        en: 'Error: $error',
        tr: 'Hata: $error',
        es: 'Error: $error',
        fr: 'Erreur : $error',
        de: 'Fehler: $error',
      ));
  String weeklyLoadError(Object error) => l10n(lang, _m(
        en: 'Could not load weekly plan: $error',
        tr: 'Haftalık plan yüklenemedi: $error',
        es: 'No se pudo cargar el plan semanal: $error',
        fr: 'Impossible de charger le plan hebdomadaire : $error',
        de: 'Wochenplan konnte nicht geladen werden: $error',
      ));

  String languageName(String code) => switch (code) {
        'en' => 'English',
        'tr' => 'Türkçe',
        'es' => 'Español',
        'fr' => 'Français',
        'de' => 'Deutsch',
        _ => code,
      };

  String minutesShort(int minutes) => l10n(lang, _m(
        en: '$minutes min',
        tr: '$minutes dk',
        es: '$minutes min',
        fr: '$minutes min',
        de: '$minutes Min.',
      ));

  String taskCount(int count) => l10n(lang, _m(
        en: count == 1 ? '1 task' : '$count tasks',
        tr: '$count görev',
        es: count == 1 ? '1 tarea' : '$count tareas',
        fr: count == 1 ? '1 tâche' : '$count tâches',
        de: count == 1 ? '1 Aufgabe' : '$count Aufgaben',
      ));

  String tasksCompleted(int completed, int total) => l10n(lang, _m(
        en: '$completed / $total tasks completed',
        tr: '$completed / $total görev tamamlandı',
        es: '$completed / $total tareas completadas',
        fr: '$completed / $total tâches terminées',
        de: '$completed / $total Aufgaben erledigt',
      ));

  String tasksRemaining(int count) => l10n(lang, _m(
        en: count == 1 ? '1 task remaining' : '$count tasks remaining',
        tr: '$count görev kaldı',
        es: count == 1 ? '1 tarea restante' : '$count tareas restantes',
        fr: count == 1 ? '1 tâche restante' : '$count tâches restantes',
        de: count == 1 ? '1 Aufgabe übrig' : '$count Aufgaben übrig',
      ));

  String stepsProgress(int completed, int total) => l10n(lang, _m(
        en: '$completed/$total steps',
        tr: '$completed/$total adım',
        es: '$completed/$total pasos',
        fr: '$completed/$total étapes',
        de: '$completed/$total Schritte',
      ));

  String stepsCount(int count) => l10n(lang, _m(
        en: count == 1 ? '1 step' : '$count steps',
        tr: '$count adım',
        es: count == 1 ? '1 paso' : '$count pasos',
        fr: count == 1 ? '1 étape' : '$count étapes',
        de: count == 1 ? '1 Schritt' : '$count Schritte',
      ));

  String planSummary(int tasks, int minutes) =>
      '${taskCount(tasks)} · ${minutesShort(minutes)}';

  String remainingLabel(String time) => l10n(lang, _m(
        en: '$time remaining',
        tr: '$time kaldı',
        es: '$time restante',
        fr: '$time restant',
        de: '$time verbleibend',
      ));

  String widgetPausedSubtitle(String remaining) => l10n(lang, _m(
        en: 'Paused · $remaining',
        tr: 'Duraklatıldı · $remaining',
        es: 'En pausa · $remaining',
        fr: 'En pause · $remaining',
        de: 'Pausiert · $remaining',
      ));

  String widgetActiveSubtitle(String remaining) => l10n(lang, _m(
        en: 'Active · $remaining left',
        tr: 'Aktif · $remaining kaldı',
        es: 'Activo · $remaining restante',
        fr: 'Actif · $remaining restant',
        de: 'Aktiv · $remaining verbleibend',
      ));

  String widgetNextSubtitle(String time) => '${nextUp} · $time';

  String durationTask(int minutes) => l10n(lang, _m(
        en: '$minutes minute task',
        tr: '$minutes dakikalık görev',
        es: 'Tarea de $minutes minutos',
        fr: 'Tâche de $minutes minutes',
        de: '$minutes-Minuten-Aufgabe',
      ));

  String deleteTaskConfirm(String title) => l10n(lang, _m(
        en: 'Delete "$title"?',
        tr: '"$title" silinsin mi?',
        es: '¿Eliminar "$title"?',
        fr: 'Supprimer « $title » ?',
        de: '"$title" löschen?',
      ));

  String tasksAddedToPlan(int count) => l10n(lang, _m(
        en: '$count tasks added to plan ✨',
        tr: '$count görev plana eklendi ✨',
        es: '$count tareas añadidas al plan ✨',
        fr: '$count tâches ajoutées au plan ✨',
        de: '$count Aufgaben zum Plan hinzugefügt ✨',
      ));

  String stepsTaskAdded(int count) => l10n(lang, _m(
        en: 'Task with $count steps added ✨',
        tr: '$count adımlı görev eklendi ✨',
        es: 'Tarea con $count pasos añadida ✨',
        fr: 'Tâche avec $count étapes ajoutée ✨',
        de: 'Aufgabe mit $count Schritten hinzugefügt ✨',
      ));

  String taskAdded(String title) => l10n(lang, _m(
        en: 'Added "$title" ✓',
        tr: '"$title" görevini ekledim ✓',
        es: 'Añadido "$title" ✓',
        fr: '« $title » ajouté ✓',
        de: '"$title" hinzugefügt ✓',
      ));

  String get sayTaskName => l10n(lang, _m(
        en: 'Say the task name.',
        tr: 'Görev adını söyle.',
        es: 'Di el nombre de la tarea.',
        fr: 'Dites le nom de la tâche.',
        de: 'Sag den Aufgabennamen.',
      ));

  String get taskAddFailed => l10n(lang, _m(
        en: 'Could not add task.',
        tr: 'Görev eklenemedi.',
        es: 'No se pudo añadir la tarea.',
        fr: 'Impossible d\'ajouter la tâche.',
        de: 'Aufgabe konnte nicht hinzugefügt werden.',
      ));

  String get taskAddRetry => l10n(lang, _m(
        en: 'Could not add task. Try again later.',
        tr: 'Görev eklenemedi. Biraz sonra tekrar dene.',
        es: 'No se pudo añadir la tarea. Inténtalo más tarde.',
        fr: 'Impossible d\'ajouter la tâche. Réessayez plus tard.',
        de: 'Aufgabe konnte nicht hinzugefügt werden. Später erneut versuchen.',
      ));

  String friendlyTaskActionError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'] as String;
      }
      final status = e.response?.statusCode;
      if (status == 401) return sessionExpired;
      if (status == 404) {
        return l10n(lang, _m(
          en: 'Task not found.',
          tr: 'Görev bulunamadı.',
          es: 'Tarea no encontrada.',
          fr: 'Tâche introuvable.',
          de: 'Aufgabe nicht gefunden.',
        ));
      }
    }
    final msg = e.toString();
    if (msg.contains('connection') || msg.contains('SocketException')) {
      return serverUnreachable;
    }
    return friendlyAiError(e);
  }

  String friendlyAiError(Object e, {bool includeBootRunHint = false}) {
    if (e is DioException) {
      final status = e.response?.statusCode;
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'] as String;
      }
      if (status == 401) return sessionExpired;
      if (status == 403) {
        return includeBootRunHint ? aiRequestDeniedWithHint : aiRequestDenied;
      }
    }
    final msg = e.toString();
    if (msg.contains('Groq')) return groqUnavailable;
    if (msg.contains('connection') || msg.contains('SocketException')) {
      return serverUnreachable;
    }
    return msg
        .replaceFirst('Exception: ', '')
        .replaceFirst('DioException [bad response]: ', '');
  }
}

Map<String, String> _m({
  required String en,
  required String tr,
  required String es,
  required String fr,
  required String de,
}) =>
    {'en': en, 'tr': tr, 'es': es, 'fr': fr, 'de': de};

final stringsProvider = Provider<S>((ref) {
  final lang = ref.watch(appLanguageProvider).valueOrNull ?? 'tr';
  return S(lang);
});
