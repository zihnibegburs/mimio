import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimio/core/storage/settings_storage.dart';

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

class S {
  S(this.lang);

  final String lang;

  bool get isEn => lang == 'en';

  String get profile => isEn ? 'Profile' : 'Profil';
  String get editProfile => isEn ? 'Edit profile' : 'Profili düzenle';
  String get displayName => isEn ? 'Display name' : 'Görünen ad';
  String get avatarColor => isEn ? 'Avatar color' : 'Avatar rengi';
  String get language => isEn ? 'Language' : 'Dil';
  String get preferences => isEn ? 'Preferences' : 'Tercihler';
  String get account => isEn ? 'Account' : 'Hesap';
  String get logout => isEn ? 'Log out' : 'Çıkış yap';
  String get save => isEn ? 'Save' : 'Kaydet';
  String get cancel => isEn ? 'Cancel' : 'İptal';
  String get version => isEn ? 'Version' : 'Sürüm';
  String get notifications => isEn ? 'Notifications' : 'Bildirimler';
  String get comingSoon => isEn ? 'Coming soon' : 'Yakında';
  String get profileUpdated => isEn ? 'Profile updated' : 'Profil güncellendi';
  String get taskOptions => isEn ? 'Task options' : 'Görev seçenekleri';
  String get startTask => isEn ? 'Start task' : 'Göreve başla';
  String get edit => isEn ? 'Edit' : 'Düzenle';
  String get delete => isEn ? 'Delete' : 'Sil';
  String get splitSubtasks => isEn ? 'Split into subtasks' : 'Adımlara böl';
  String get goToFocus => isEn ? 'Go to focus' : 'Odağa git';
  String get pause => isEn ? 'Pause' : 'Duraklat';
  String get resume => isEn ? 'Resume' : 'Devam et';
  String get complete => isEn ? 'Complete' : 'Tamamla';
  String get deleteTask => isEn ? 'Delete task' : 'Görevi sil';
  String get deleteConfirm => isEn ? 'Delete this task?' : 'Bu görev silinsin mi?';
  String get aiBreakdown => isEn ? 'AI subtask breakdown' : 'AI ile adımlara böl';
  String get aiBreakdownHint =>
      isEn ? 'Split this task into smaller steps with AI.' : 'Bu görevi AI ile küçük adımlara ayır.';
  String get previewSteps => isEn ? 'Preview steps' : 'Adımları önizle';
  String get applySteps => isEn ? 'Apply steps' : 'Adımları uygula';
  String get aiThinking => isEn ? 'AI is thinking...' : 'AI düşünüyor...';
  String get applyingSteps => isEn ? 'Applying steps...' : 'Adımlar ekleniyor...';

  String languageName(String code) => switch (code) {
        'en' => 'English',
        'tr' => 'Türkçe',
        _ => code,
      };
}

final stringsProvider = Provider<S>((ref) {
  final lang = ref.watch(appLanguageProvider).valueOrNull ?? 'tr';
  return S(lang);
});
